# CPEN 321 — [ProjectName]

> Replace `[ProjectName]` with your project name after creating the repository.

## Repository Setup

Complete these steps **once** when your team first creates the repository.

### 1. Create a GitHub Organization

1. One team member creates a GitHub Organization (e.g., `CPEN321-26W1-team-xx`)
2. Add all teammates as organization members
3. Add all TAs as organization members with **write** access:
   - Masih [@Masihbr](https://github.com/Masihbr)
   - Michael [@mickowale](https://github.com/mickowale)
   - Yingying [@dorawyy](https://github.com/dorawyy)

### 2. Create Repository from Template

1. [Create a new repository from this template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template)
   under your organization
2. Name it `CPEN321_YourProjectName`
3. Set visibility to **Public**

### 3. Set Up Codacy

1. Sign in to [codacy.com](https://www.codacy.com) with GitHub
2. Add your organization and repository
3. Codacy automatically reads `detekt.yml` (Kotlin) and `.eslintrc.json`
   (TypeScript) from the repo root

### 4. Create a GitHub Project Board

Use [GitHub Projects](https://docs.github.com/en/issues/planning-and-tracking-with-project-tables)
to track your team's work:

1. In your organization, create a new Project (Board view recommended)
2. Link it to your repository
3. Use GitHub Issues for task tracking — create issues before starting work and
   reference them in PRs (e.g., `Closes #12`)
4. **Each milestone submission must include the Project board link**

### 5. Configure Branch Protection

In repository **Settings > Branches**, add a rule for `main`:

- [x] Require a pull request before merging
- [x] Require approvals (at least 1)
- [x] Require status checks to pass before merging (select `Backend CI` and
  `Frontend CI` after your first push triggers them)
- [x] Do not allow bypassing the above settings

---

## Pinned Toolchain

Every version below is **frozen for the term**. They are deliberately one
release line behind the newest available so that builds are reproducible on
every teammate's and every grader's machine.

| Component | Version | Pinned in |
| --- | --- | --- |
| Android Gradle Plugin | 8.13.2 | `frontend/gradle/libs.versions.toml` |
| Gradle | 8.14.5 | `frontend/gradle/wrapper/gradle-wrapper.properties` |
| Kotlin | 2.1.21 | `frontend/gradle/libs.versions.toml` |
| JDK (build + bytecode target) | 17 | `frontend/gradle/gradle-daemon-jvm.properties`, `kotlin { jvmToolchain(17) }` |
| `compileSdk` / `targetSdk` | 35 | `frontend/gradle/libs.versions.toml` |
| `minSdk` | 26 | `frontend/gradle/libs.versions.toml` |
| Compose BOM | 2025.06.01 | `frontend/gradle/libs.versions.toml` |
| Node.js | 22 (LTS) | `.nvmrc`, `backend/package.json` (`engines`) |
| npm | 10.9.9 | `backend/package.json` (`packageManager`) |

### Changing a pinned version

Don't, unless you have to. If you must: change it in the file listed above
(never in Android Studio's UI), verify `./scripts/grade.sh` still passes from a
clean clone, and record the change in `CHANGELOG.md` with the reason.

---

## Prerequisites

* **Android SDK.** Install the required packages and accept licenses:

  ```bash
  sdkmanager --licenses
  sdkmanager "platforms;android-35" "build-tools;35.0.0"
  ```

  Point the build at your SDK by exporting `ANDROID_HOME` (preferred) or
  letting Android Studio write `frontend/local.properties`. That file is
  machine-specific and **not** in version control.

* **JDK.** You do not need to install one.
  `frontend/gradle/gradle-daemon-jvm.properties` pins the daemon to Java 17 and
  Gradle downloads a matching JDK on first build.

* **Node.js 22.** With [nvm](https://github.com/nvm-sh/nvm), run `nvm use` in
  the repo root. Always install backend dependencies with `npm ci` (not
  `npm install`).

* **Docker.** Required for running the database and other services locally.

---

## Getting Started

### Backend

```bash
cp backend/.env.example backend/.env   # then fill in API keys
npm ci --prefix backend
npm run dev --prefix backend           # starts dev server with hot reload
```

Or use Docker for the full stack (backend + MongoDB):

```bash
./scripts/docker-up.sh
```

### Frontend

```bash
cp frontend/local.properties.example frontend/local.properties
# Edit local.properties: set sdk.dir, API_BASE_URL, and GOOGLE_CLIENT_ID
```

Then open `frontend/` in Android Studio, or build from the command line:

```bash
cd frontend && ./gradlew assembleDebug
```

### Verifying Your Setup

Run the same checks a TA runs:

```bash
./scripts/grade.sh
```

This starts Docker services, runs backend typecheck/tests/build, polls
`GET /health`, then builds the frontend and runs unit tests.

---

## CI/CD

This template includes three GitHub Actions workflows that run automatically:

| Workflow | Trigger | What it does |
| --- | --- | --- |
| **Backend CI** | Push / PR to `main` | `npm ci` → typecheck → test → build → health check |
| **Frontend CI** | Push / PR to `main` | `assembleDebug` → unit tests → **uploads APK as artifact** |
| **Release** | Push `submission-*` tag | Builds APK → creates GitHub Release with APK attached |

TAs download the debug APK from:
- **During development:** Actions tab → Frontend CI run → Artifacts section
- **At submission:** Releases page (created automatically when you push a tag)

---

## Submission Workflow

Each milestone submission uses a **git tag** and **GitHub Release**:

1. Make sure all CI checks pass on `main`
2. Tag the commit:

   ```bash
   git tag submission-m1
   git push origin submission-m1
   ```

3. The **Release** workflow automatically builds the debug APK and creates a
   GitHub Release with the APK attached
4. Record the tagged commit SHA in your
   [testing document](doc/Testing_And_Code_Review.md)

| Milestone | Tag |
| --- | --- |
| Milestone 1 | `submission-m1` |
| Milestone 2 | `submission-m2` |
| Milestone 3 | `submission-m3` |
| Final | `submission-final` |

TAs grade the tagged commit locally with `./scripts/grade.sh` and download the
APK from the GitHub Release — **do not submit APKs manually**.

---

## Template Structure

| Path | Purpose |
| --- | --- |
| `.github/workflows/` | CI/CD workflows (backend, frontend, release) |
| `.github/pull_request_template.md` | Standardized PR description template |
| `.github/ISSUE_TEMPLATE/` | Bug report and feature request templates |
| `backend/` | Node.js + TypeScript backend |
| `frontend/` | Android (Kotlin + Compose) frontend |
| `doc/` | Requirements, design, and testing documents |
| `scripts/grade.sh` | One-command local grading script for TAs |
| `docker-compose.yml` | Database and backend services for local dev |
| `.eslintrc.json` | ESLint config — read by Codacy (do not move) |
| `detekt.yml` | Detekt config — read by Codacy (do not move) |
| `.nvmrc` | Pins Node.js version for `nvm use` |
| `CHANGELOG.md` | Log of toolchain or template changes |
