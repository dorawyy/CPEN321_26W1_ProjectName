# CPEN321_26W1_ProjectName

## Repository Setup

Complete these steps when your team first creates the repository.

### 1. Create a GitHub Organization

1. One team member creates a GitHub Organization.
2. Add all teammates as organization members.
3. Add all TAs as organization members with **write** access:
   - Masih [@Masihbr](https://github.com/Masihbr)
   - Michael [@mickowale](https://github.com/mickowale)
   - Yingying [@dorawyy](https://github.com/dorawyy)

### 2. Create Repository from Template

1. Create a new repository from this template under your organization: https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template .
2. Name it in format `CPEN321_26W1_YourProjectName` and replace with your actual project name.
3. Set visibility to **Public**.

### 3. Set Up Codacy

Codacy (https://www.codacy.com/) is an automated code review tool that you will be using in later milestones. It is a good idea to explore how to integrate it into your development pipeline early on, so you can write clean code upfront. 

1. Sign in to Codacy with GitHub.
2. Add your Organization and Repository.
3. In the `Tools` section of the `Code patterns` page, disable all code checking tools besides the ones listed below:
    * detekt for Kotlin
    * ESLint for TypeScript 
    * Trivy for Kotlin and TypeScript
4. The `detekt.yml` and `.eslintrc.json` in the repo root directory are configuration files for Codacy to use.
5. Configure Codacy to (a) use the selected configuration files for detekt and ESLint and (b) enable all five code patterns for Trivy: https://docs.codacy.com/repositories-configure/configuring-code-patterns/ .

> **⚠️ NOTE: Do not alter the provided configuration files or Codacy setup in any way. Specifically, do not disable any Codacy checks, do not exclude any files, do not use inline code comments to suppress issues, etc.**

### 4. Create a GitHub Project Board

Use GitHub Projects (https://docs.github.com/en/issues/planning-and-tracking-with-project-tables) to track your team's work:

1. In your Organization, create a new Project. 
2. Link it to your Repository. 
3. Use GitHub Issues for task tracking. You should create issues before starting work and reference them in PRs (e.g., `Closes #12`)

---

## Getting Started

### Backend

```bash
cp backend/.env.example backend/.env   # then fill in API keys and environment variables
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

This starts Docker services, runs backend typecheck/tests/build, polls `GET /health`, then builds the frontend and runs tests.

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

3. The **Release** workflow automatically builds the debug APK and creates a GitHub Release with the APK attached
4. Record the tagged commit SHA in your [testing document](doc/Testing_And_Code_Review.md)

| Milestone | Tag |
| --- | --- |
| Milestone 1 | `submission-m1` |
| Milestone 2 | `submission-m2` |
| Milestone 3 | `submission-m3` |
| Final | `submission-final` |

TAs grade the tagged commit locally with `./scripts/grade.sh` and download the APK from the GitHub Release. 

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
| `.eslintrc.json` | ESLint config read by Codacy (do not move or modify) |
| `detekt.yml` | Detekt config read by Codacy (do not move or modify) |
