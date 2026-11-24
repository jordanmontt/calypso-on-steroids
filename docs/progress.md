# Progress board

The board below the preparation table is **not generated yet**: it needs the feature sheets and its generator (C1). It will be written by code, never by hand, so it cannot drift from reality.

## Preparation (kept by hand until the board exists)

Steps of [before-coding.md](before-coding.md). Updated in the commit that starts or finishes a step.

| Step | Status | Commits on `main` |
|---|---|---|
| A1 Review and commit the docs | done 2026-11-19 | `1072310` |
| A2 Decisions D-01..D-09 | done 2026-11-23 | `08f0ee4` |
| A3 Working process | done 2026-11-23 | `08f0ee4` |
| B1 Rebuild recipe and baseline | done 2026-11-23 | `44ce30c`, `14ad5d9` |
| B2 CI on the latest Pharo 15 | done 2026-11-23, green on every push since | `5a5c6de` |
| B3 Driver spike S-5 | done 2026-11-23 | `512c364`, `3d53a63`, `be96c4c`, `c04f24b` |
| B4 Command catalogue generator and check | done 2026-11-23; the board generator moved to C1, the screenshot harness dropped | `fafa99c`, `a9c0091`, `01001c3`, `7518748` |
| C1 Feature sheets per area, and the board generator with the first sheet | **in progress**: TAB reviewed; EDT and the board generator next | — |
| C2 Morphic driver and first scenarios | not started (needs B3, C1) | — |
| C3 Command placement parity | not started (needs B4) | — |
| D1 Spikes S-1..S-4 | not started | — |
| D2 Design notes | not started (needs D1) | — |
| E1 Calypso bug fixes B-01..B-05 | not started | — |
| E2 Spec issues for confirmed gaps | not started (needs D1) | — |


## What the board will show

One row per scenario of the [feature sheets](features/sheets/README.md), grouped by area and feature, with these columns:

| Column | Meaning | Source |
|---|---|---|
| Sheet reviewed | You approved the feature sheet of this area | The sheet's header (PR merged) |
| Test | A test implements the scenario | The test named next to the scenario in its sheet (it must exist) |
| Morphic | The test passes on today's browser (only where the Morphic driver applies, T-06) | Last test run |
| Spec | The test passes on the Spec browser | Last test run |
| Checked by you | The manual check of this scenario was done, with the PR and date | `docs/manual-checks.md`, a log you confirm in each PR |

A summary at the top gives, per area and per tier (M, P, X), how many scenarios are agreed, tested, green on Spec and checked by you, and lists the scenarios with no test.

## How it is produced

A class in the dev-only tooling package (PR 0.4, never shipped) reads the feature sheets, runs the tests they name, reads the manual-check log, and writes this file. The shipped code knows nothing about it. It is regenerated in every PR, and a test fails if the committed file is not up to date.
