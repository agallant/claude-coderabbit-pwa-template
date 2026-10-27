<!--
TEMPLATE-README: this file still describes the template, not an app.
Claude: in the first PR that adds the app, replace this whole file with a README for the app
(see "Bootstrapping a new repo" in CLAUDE.md), and delete this comment.
-->

# Claude + CodeRabbit PWA template

A GitHub template for TypeScript progressive web apps aimed at phones and tablets, built by
Claude, reviewed by CodeRabbit, and deployed to GitHub Pages. No backend.

Claude opens every change as a pull request. CI, CodeQL, zizmor, Dependency review, a Lighthouse
mobile audit of a live preview, and CodeRabbit's review all have to pass, and then the PR merges
by itself and `main` deploys.

The template commits to **TypeScript** and **GitHub Pages**, nothing else: no framework, bundler,
test runner or package manager is chosen for you. CI calls `package.json` scripts by name
(`build`, `typecheck`, `lint`, `test`) and detects npm, pnpm, Yarn or Bun from the lockfile.

## Start a new app from this template

1. **Use this template → Create a new repository** (public is simplest; see why in the guide).
2. Add the new repo to the **CodeRabbit** and **Claude** GitHub Apps:
   [github.com/settings/installations](https://github.com/settings/installations) → app →
   **Configure** → *Repository access* → add the repo.
3. From a clone, run `.github/setup/setup-repo.sh` (needs `gh` logged in as admin, and `jq`).
4. Open [claude.ai/code](https://claude.ai/code), pick the repo, and describe the app.

The full guide, including why the app connections can't be baked into the template, is in
**[.github/setup/README.md](.github/setup/README.md)**.

## What's in here

| Path | Purpose |
| --- | --- |
| [`CLAUDE.md`](CLAUDE.md) | How Claude works in the repo: PR workflow, CI contract, PWA and mobile guidance, first-run bootstrap |
| [`.coderabbit.yaml`](.coderabbit.yaml) | CodeRabbit review settings: request changes, then approve |
| [`.github/workflows/`](.github/workflows) | CI, CodeQL, zizmor, Dependency review, PR preview + Lighthouse, deploy, auto-merge |
| [`.github/setup/`](.github/setup) | Setup script, `main` ruleset JSON, and the setup guide |
| [`.github/actions/setup/`](.github/actions/setup) | Shared step: detect package manager, install Node and dependencies |
| [`.github/lighthouserc.json`](.github/lighthouserc.json) | Lighthouse thresholds for the preview audit |
| `.editorconfig`, `.gitattributes`, `.gitignore`, `.nvmrc` | Editor and Git defaults; Node version for CI |

Changes to this template go through the same PR flow if you run the setup script on it, but
there's no app here to build: CI, CodeQL's JS/TS analysis, previews and Lighthouse skip
themselves until a `package.json` exists.
