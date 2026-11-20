# Progress board

Status: **not generated yet**. This file will be written by code (PR 0.4), never by hand, so it cannot drift from reality.

## What it will show

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
