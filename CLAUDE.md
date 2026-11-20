# Calypso on steroids: agent guide

Goal: a Spec version of Calypso (the Pharo system browser) with every feature of today's Morphic browser, for Pharo 15. Calypso and Spec problems are fixed upstream (pharo-project/pharo, pharo-spec/Spec), never patched here.

## Before any work

- Read [docs/plan.md](docs/plan.md) (strategy, decisions) and [docs/progress.md](docs/progress.md) (where we are).
- Follow [docs/testing-plan.md](docs/testing-plan.md) (TDD, validation workflow) and [docs/coding-guidelines.md](docs/coding-guidelines.md).
- Nothing is committed without the user's explicit OK after their review and manual checks.

## What to read for which task

| Task | Read |
|---|---|
| Work on a feature or area | Its sheet in [docs/features/sheets/](docs/features/sheets/README.md) (only reviewed sheets are a specification); the [inventory](docs/features/README.md) for IDs |
| Understand how Calypso works | [docs/calypso-architecture.md](docs/calypso-architecture.md) |
| A command, shortcut, tab or decorator | [docs/features/command-catalogue.md](docs/features/command-catalogue.md) (search it, don't read it whole) |
| A Spec limitation | [docs/spec-gaps.md](docs/spec-gaps.md), then [docs/workarounds.md](docs/workarounds.md) |
| A Calypso refactoring or bug | [docs/pain-points.md](docs/pain-points.md), bugs in [docs/features/walkthrough.md](docs/features/walkthrough.md#bugs-found-during-the-walkthrough) |
| Preparation steps (Phases 0–1) | [docs/before-coding.md](docs/before-coding.md) |

## Rules for docs

Keep them small: one fact in one place, link instead of copying, point to code as `Class>>selector`. See "Documentation" in [docs/coding-guidelines.md](docs/coding-guidelines.md).
