# Calypso on steroids

A Spec version of Calypso, the Pharo system browser, built step by step so that every feature of today's Morphic browser is kept, and so that the new code stays maintainable. Spec is improved upstream wherever it cannot host Calypso yet.

Status: **planning**. No code yet.

## Documents

- [Plan](docs/plan.md): strategy, phases, pull requests, milestones, decisions, risks
- [Feature inventory](docs/features/README.md): the 143 features of Calypso, with IDs
- [Feature sheets](docs/features/sheets/README.md): the complete specification of each area, reviewed area by area
- [Progress board](docs/progress.md): generated status of every scenario
- [Walkthrough](docs/features/walkthrough.md): the real browser, screen by screen, with hidden behaviours and bugs found
- [How Calypso works](docs/calypso-architecture.md)
- [Before coding](docs/before-coding.md): the detailed preparation plan
- [Command catalogue](docs/features/command-catalogue.md): the 397 command, tab and decorator declarations (generated)
- [Spec gaps](docs/spec-gaps.md): what Spec needs, spikes, upstream candidates
- [Pain points](docs/pain-points.md): what is hard in Calypso today, and the Calypso refactorings needed
- [Testing plan](docs/testing-plan.md): TDD, the five test layers, manual checks, validation workflow
- [Coding guidelines](docs/coding-guidelines.md)
- [Workarounds](docs/workarounds.md): temporary workarounds waiting for upstream fixes

## Target

Pharo 15 (development version), Spec 2, SUnit for unit and acceptance tests.
