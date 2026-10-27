# Repository setup and merge gates

This repo came from [claude-coderabbit-pwa-template](https://github.com/agallant/claude-coderabbit-pwa-template).
Claude opens PRs; CodeRabbit, CodeQL and CI review them; a PR merges by itself once every gate
passes; `main` deploys to GitHub Pages. This page explains the setup and how each part works.
It stays accurate for the life of the repo, so the root README doesn't need to repeat it.

## One-time setup for a new repo

A template copies files only. GitHub App access, rulesets and repo settings don't come along, so
each new repo needs these steps (about five minutes).

1. **Create the repo** from the template: *Use this template → Create a new repository*. Make it
   **public** unless you pay for GitHub Code Security and Pages on private repos: CodeQL, secret
   scanning, dependency review and Pages are free only on public repos.
2. **Give CodeRabbit access** to the new repo. CodeRabbit is the reviewer whose approval every PR
   needs, so nothing merges until this is done.
   - Already installed (you use it on other repos): open
     [github.com/settings/installations](https://github.com/settings/installations) → **CodeRabbit**
     → **Configure** → *Repository access* → **Select repositories** → add the new repo → **Save**.
   - Not installed yet: [github.com/apps/coderabbitai](https://github.com/apps/coderabbitai) →
     **Install** → choose *Only select repositories* → pick the repo.
3. **Give Claude access** the same way: [github.com/settings/installations](https://github.com/settings/installations)
   → **Claude** → **Configure** → *Repository access* → add the repo. (Not installed yet:
   [github.com/apps/claude](https://github.com/apps/claude) → **Install** → *Only select repositories*.)
   This lets cloud sessions at [claude.ai/code](https://claude.ai/code) clone, push and open PRs,
   and enables *Auto-fix*, where Claude watches a PR and fixes failing checks or review comments.
4. **Run the setup script** from a clone, with the [GitHub CLI](https://cli.github.com) logged in
   as a repo admin and [jq](https://jqlang.org/download/) installed:

   ```sh
   .github/setup/setup-repo.sh            # or: .github/setup/setup-repo.sh owner/name
   ```

   It sets squash-only auto-merge, creates the `main` ruleset, turns on Dependabot alerts and
   security updates and secret scanning with push protection, creates the `gh-pages` branch and
   points GitHub Pages at it. Safe to re-run any time (for example after editing the ruleset).
5. **Start building**: in [claude.ai/code](https://claude.ai/code), pick the repo and describe the
   app. `CLAUDE.md` tells Claude how to bootstrap it (pick a stack, scaffold, rewrite the README).

### Does connecting the template repo carry over?

No. GitHub App access is per repository, and a template copies files, nothing else. Connecting
CodeRabbit or Claude to the *template* only matters for reviewing changes to the template itself.

What does carry over is the configuration in files: `.coderabbit.yaml`, `CLAUDE.md`, the
workflows and the ruleset JSON (which the setup script applies). So each new repo needs only the
two "add repository" clicks above plus the script.

To skip the clicks, you can install an app on *All repositories*. That's a reasonable trade for
CodeRabbit (it reads code and comments on PRs). For Claude it means access to every repo you own,
present and future, which is what you want to avoid, so keep Claude on *Only select repositories*.

## How a PR gets merged

```
Claude pushes a branch and opens a PR
  ├─ Auto-merge workflow ─── enables GitHub auto-merge (squash)
  ├─ CI ─────────────────── typecheck, lint, test, build, build-output check
  ├─ CodeQL ─────────────── code scanning of the app (JS/TS) and of the workflows
  ├─ zizmor ─────────────── security audit of the workflows
  ├─ Dependency review ──── blocks newly added vulnerable dependencies
  ├─ PR preview ─────────── deploys to …/pr-preview/pr-N/, comments link + QR code
  │    └─ Lighthouse ────── mobile audit of the live preview
  └─ CodeRabbit ─────────── reviews; requests changes or approves
       Claude fixes or answers each comment and resolves the threads; CodeRabbit re-reviews
All required checks green + CodeRabbit approval + no open threads → squash-merge → deploy
```

The `main` ruleset ([`ruleset-main.json`](ruleset-main.json)) requires:

| Gate | What blocks a merge |
| --- | --- |
| Pull request | 1 approving review (CodeRabbit is the only reviewer who isn't the author), all review threads resolved, squash merges only |
| `CI` | Any failing script, a missing `build` script, no `index.html`, or no linked web app manifest |
| `Analyze (javascript-typescript)`, `Analyze (actions)` | The analysis failing to run |
| Code scanning results | A new CodeQL alert of high/critical security severity or error level, or a zizmor alert of medium+ severity |
| `zizmor` | The audit failing to run (or any finding, when `CODE_SCANNING=off`) |
| `Dependency review` | A PR that adds a dependency with a known high/critical vulnerability |
| `Lighthouse` | Accessibility or best-practices score under 90 on mobile (performance is reported, not gated) |

Required checks must come from GitHub Actions (the ruleset pins them to its app ID), so a status
posted by anyone else can't satisfy them. Nobody is on the bypass list, including admins acting
through Claude. To merge something by hand, edit the ruleset in *Settings → Rules*, or add an
admin bypass there.

**Why CodeRabbit's approval rather than its status check:** CodeRabbit's
`auto_approvals` mode (in `.coderabbit.yaml`) requests changes when it has blocking findings and
approves once they're resolved. Requiring an approval fails closed: if CodeRabbit is not
installed, rate-limited or skipped the PR, nothing approves and nothing merges. PR authors can't
self-approve with `@coderabbitai approve` (`allow_author_approval: false`), which matters because
Claude's comments are posted as you.

## Repository variables

Optional, under *Settings → Secrets and variables → Actions → Variables*:

| Variable | Default | Use |
| --- | --- | --- |
| `BUILD_DIR` | `dist` | Folder the `build` script writes the site to |
| `SITE_BASE_PATH` | `/<repo>/` | Path the site is served from. Set to `/` for a custom domain |
| `AUTOMERGE` | on | `off` stops PRs from merging by themselves |
| `CODE_SCANNING` | on | `off` skips CodeQL, Dependency review and zizmor's upload; the setup script sets it on private repos without Code Security |

## Holding a PR back

Open it as a draft, add the `manual-merge` label before opening it, or run
`gh pr merge --disable-auto <number>`.

## Deploys and previews

- `deploy.yml` builds `main` into the root of the `gh-pages` branch on every push to `main`. An
  hourly run catches merges that didn't trigger a push event and exits early if `main` is already
  live. GitHub Pages can cache pages for up to 10 minutes.
- `preview.yml` builds each PR into `gh-pages:/pr-preview/pr-N/`, comments the URL and a QR code
  for opening it on a phone, runs Lighthouse against it, and deletes it when the PR closes. Fork
  PRs get no preview, since their token can't write.
- The build gets `BASE_PATH` (`/<repo>/` or `/<repo>/pr-preview/pr-N/`), `BUILD_SHA` and
  `BUILD_LABEL` (`main`, `PR #N`, or `ci`) as environment variables.

## Keeping the template's files up to date

Dependabot updates the SHA-pinned actions weekly (after a 7-day cooldown) as ordinary PRs that go
through the same gates. To pull later improvements from the template, compare the files in
`.github/`, `CLAUDE.md` and `.coderabbit.yaml` with the template repo.
