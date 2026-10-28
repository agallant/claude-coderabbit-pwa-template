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

**Once:** mark this repo as a template, create a setup token and store it, and install the
CodeRabbit and Claude GitHub Apps. About five minutes, following
[Setting up repos](.github/setup/README.md#setting-up-repos).

**Then, for each app:** start a session at [claude.ai/code](https://claude.ai/code) on this
template repo and ask for it, e.g. *"Create a new app repo agallant/space-dodge: a one-thumb
arcade game for phones. Then develop it: …"*. Claude has the **Repo setup** workflow create and
configure the repo (settings, merge gates, GitHub Pages, Claude app access), then builds the app
in the same session.

The guide also covers why settings and app access can't be baked into the template, what the
setup token can do, and how to set up a repo without it: **[.github/setup/README.md](.github/setup/README.md)**.

## What's in here

| Path | Purpose |
| --- | --- |
| [`CLAUDE.md`](CLAUDE.md) | How Claude works in the repo: PR workflow, CI contract, PWA and mobile guidance, first-run bootstrap |
| [`.coderabbit.yaml`](.coderabbit.yaml) | CodeRabbit review settings: request changes, then approve |
| [`.github/workflows/`](.github/workflows) | CI, CodeQL, zizmor, Dependency review, PR preview + Lighthouse, deploy, auto-merge; plus Repo setup, which runs only in the template |
| [`.github/setup/`](.github/setup) | Setup script, `main` ruleset JSON, and the setup guide |
| [`.github/actions/setup/`](.github/actions/setup) | Shared step: detect package manager, install Node and dependencies |
| [`.github/lighthouserc.json`](.github/lighthouserc.json) | Lighthouse thresholds for the preview audit |
| `.editorconfig`, `.gitattributes`, `.gitignore`, `.nvmrc` | Editor and Git defaults; Node version for CI |

Changes to this template go through the same PR flow once it's set up (step 5 of the one-time
setup). There's no app here to build, so CI, CodeQL's JS/TS analysis, previews and Lighthouse
pass without doing anything until a `package.json` exists.
