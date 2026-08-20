# CPEN321_26W1_ProjectName

## Repository Setup

Complete these steps when your team first creates the repository.

### 1. Create a GitHub Organization

1. One team member creates a GitHub Organization.
2. Add all teammates as organization members.
3. Add all TAs as organization members with **write** access:
   - Masih [@Masihbr](https://github.com/Masihbr)
   - Michael [@mickowale](https://github.com/mickowale)
   - Sarah [@sarahdagger](https://github.com/sarahdagger)
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
cd backend
cp .env.example backend/.env   # then fill in API keys and environment variables
npm ci
npm run dev          # starts dev server with hot reload
```

### Frontend

```bash
cd frontend
cp local.properties.example frontend/local.properties
# Edit local.properties: set sdk.dir, API_BASE_URL, and GOOGLE_CLIENT_ID, etc
```

Then open `frontend/` in Android Studio, or build from the command line:

```bash
cd frontend && ./gradlew assembleDebug
```
---

## Template Structure

| Path | Purpose |
| --- | --- |
| `backend/` | Node.js + TypeScript backend |
| `frontend/` | Android (Kotlin + Compose) frontend |
| `doc/` | Requirements, design, and testing documents, weekly reports |
| `.eslintrc.json` | ESLint config read by Codacy (do not move or modify) |
| `detekt.yml` | Detekt config read by Codacy (do not move or modify) |
