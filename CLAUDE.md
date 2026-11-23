# Calypso on steroids: agent guide

Goal: a Spec version of Calypso (the Pharo system browser) with every feature of today's Morphic browser, for Pharo 15. Calypso and Spec problems are fixed upstream (pharo-project/pharo, pharo-spec/Spec), never patched here.

## Current state (update at the end of each session)

- **Where the project stands:** the preparation table in [docs/progress.md](docs/progress.md) (done steps, next step, commits).
- **Open questions:** none.

## Working with the user

The user is in control and wants to understand Calypso's code by the end of the project. Read "Commits and pull requests", "Code tour of each commit" and "Working process" in [docs/coding-guidelines.md](docs/coding-guidelines.md) before any work. In short:

- Each step starts with the user's go. Nothing is committed or pushed without their explicit OK, after their review and manual checks.
- One commit, one goal. Each commit comes with a code tour: mostly code, pointers and Playground snippets, very little prose, and questions for the user to think about.
- TDD always; acceptance tests are SUnit through browser drivers ([docs/testing-plan.md](docs/testing-plan.md)).
- The shipped code never refers to the docs.
- No new document without the user's OK.

## The image

Pharo 15 image in `/Users/sebas/Documents/PharoCliImages/calypso-on-steroids`, with a Pharo MCP server over HTTP at `http://localhost:4001/` (root path, header `Accept: application/json, text/event-stream`). If its tools are not registered in the session, call `tools/call` on it with a small HTTP client. Anything that may open a modal must be triggered with `UIManager default defer:`.

## The documents (this list is complete)

| Task | Read |
|---|---|
| Strategy, phases, decisions | [docs/plan.md](docs/plan.md) |
| The current preparation step | [docs/before-coding.md](docs/before-coding.md) |
| Work on a feature or area | Its sheet in [docs/features/sheets/](docs/features/sheets/README.md) (only reviewed sheets are a specification); the [inventory](docs/features/README.md) for IDs, tiers and dropped features |
| How the browser behaves today, bugs, manual checks | [docs/features/walkthrough.md](docs/features/walkthrough.md) |
| How Calypso works | [docs/calypso-architecture.md](docs/calypso-architecture.md) |
| A command, shortcut, tab or decorator | [docs/features/command-catalogue.md](docs/features/command-catalogue.md) (search it, don't read it whole) |
| A Calypso refactoring | [docs/pain-points.md](docs/pain-points.md) |
| A Spec limitation | [docs/spec-gaps.md](docs/spec-gaps.md), then [docs/workarounds.md](docs/workarounds.md) |
| Tests | [docs/testing-plan.md](docs/testing-plan.md), [docs/progress.md](docs/progress.md) |
| Rules for code, commits, docs | [docs/coding-guidelines.md](docs/coding-guidelines.md) |
| Issues and PRs in other repositories | [docs/upstream.md](docs/upstream.md) |
| Rebuilding the image | [docs/rebuild.md](docs/rebuild.md) |
