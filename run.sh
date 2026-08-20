#!/usr/bin/env bash
#
# Assumes config is already done (backend/.env, frontend/local.properties).
#   1. Starts docker compose
#   2. Starts the emulator named AVD_NAME (default: "Pixel_9")
#   3. Builds, installs, and launches the app
#
# Override the emulator name if needed:
#   AVD_NAME=EMULATOR_NAME ./run.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

FRONTEND_DIR="${FRONTEND_DIR:-frontend}"
AVD_NAME="${AVD_NAME:-Pixel_9}"

info()  { printf '\033[34m==>\033[0m %s\n' "$*"; }
die()   { printf '\033[31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Prerequisites
# ---------------------------------------------------------------------------
command -v docker >/dev/null 2>&1 || die "Docker not found."
docker info >/dev/null 2>&1       || die "Docker is not running."
command -v java >/dev/null 2>&1    || die "Java not found."
command -v curl >/dev/null 2>&1    || die "curl not found."

[[ -f backend/.env ]] || die "Missing backend/.env — follow the student setup guide first."
[[ -f "$FRONTEND_DIR/local.properties" ]] || die "Missing $FRONTEND_DIR/local.properties."
[[ -x "$FRONTEND_DIR/gradlew" ]] || die "Missing $FRONTEND_DIR/gradlew."

if [[ -n "${ANDROID_HOME:-}" && -d "$ANDROID_HOME" ]]; then
  :
elif sdk_dir="$(grep -E '^sdk\.dir=' "$FRONTEND_DIR/local.properties" | head -1 | cut -d= -f2- | tr -d ' "')"; [[ -n "$sdk_dir" && -d "$sdk_dir" ]]; then
  export ANDROID_HOME="$sdk_dir"
else
  die "Set ANDROID_HOME or sdk.dir in $FRONTEND_DIR/local.properties."
fi

export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
EMULATOR="$ANDROID_HOME/emulator/emulator"
ADB="$ANDROID_HOME/platform-tools/adb"

[[ -x "$EMULATOR" ]] || die "Android emulator not installed."
[[ -x "$ADB" ]]     || die "adb not found."

BACKEND_PORT="$(grep -E '^PORT=' backend/.env | head -1 | cut -d= -f2- | tr -d ' "' || true)"
BACKEND_HEALTH_URL="${BACKEND_HEALTH_URL:-http://localhost:${BACKEND_PORT:-3000}/health}"

# ---------------------------------------------------------------------------
# Backend
# ---------------------------------------------------------------------------

info "Starting backend (docker compose up --build -d)..."
docker compose up --build -d

info "Waiting for $BACKEND_HEALTH_URL ..."
for _ in $(seq 1 120); do
  curl -sf "$BACKEND_HEALTH_URL" >/dev/null 2>&1 && break
  sleep 1
done
curl -sf "$BACKEND_HEALTH_URL" >/dev/null 2>&1 || die "Backend not healthy. Try: docker compose logs backend"

info "Backend is up."

# ---------------------------------------------------------------------------
# Emulator
# ---------------------------------------------------------------------------

if "$ADB" devices | grep -qE '^emulator-[0-9]+\s+device$'; then
  info "Emulator already running."
else
  "$EMULATOR" -list-avds 2>/dev/null | grep -qx "$AVD_NAME" || die \
    "No AVD named '$AVD_NAME'. Create it in Android Studio (Device Manager), or run: AVD_NAME=YourAvdName ./run.sh"

  info "Starting emulator '$AVD_NAME' ..."
  "$EMULATOR" -avd "$AVD_NAME" -no-snapshot-save >/dev/null 2>&1 &
  disown || true

  "$ADB" wait-for-device
  for _ in $(seq 1 120); do
    [[ "$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]] && break
    sleep 2
  done
  [[ "$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]] \
    || die "Emulator did not finish booting."
  info "Emulator ready."
fi

# ---------------------------------------------------------------------------
# Frontend
# ---------------------------------------------------------------------------

info "Building and installing app..."
( cd "$FRONTEND_DIR" && ./gradlew installDebug )

APPLICATION_ID="$(grep -E '[[:space:]]applicationId[[:space:]]*=' "$FRONTEND_DIR/app/build.gradle.kts" \
  | head -1 | sed -E 's/.*=[[:space:]]*"([^"]+)".*/\1/')"

info "Launching app..."
"$ADB" shell monkey -p "$APPLICATION_ID" -c android.intent.category.LAUNCHER 1 >/dev/null

echo
info "Done. Sign in on the emulator to verify. Stop backend: docker compose down"
