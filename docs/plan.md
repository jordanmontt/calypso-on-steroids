# Plan: Calypso in Spec

**Goal:** replace the Morphic UI of Calypso (the system browser; the query browser is already mostly replaced by NewTools' `StMethodBrowser`, see decision D-08) with a Spec UI, keeping every feature, without changing the model except through agreed refactorings merged in Pharo. **Sub-goal:** improve Spec where it cannot host Calypso.

This is a living plan. It is complete in scope (it covers every requirement of the project brief, listed at the end with where each is handled), but its details will change as spikes answer questions and as bugs appear. Update it in the same PR as the change that makes it wrong.

Related documents:

| Document | Content |
|---|---|
| [features/README.md](features/README.md) | The feature inventory (143 features, IDs used everywhere, 93 checked by clicking) |
| [features/walkthrough.md](features/walkthrough.md) | Guided tour of the real browser with screenshots, hidden behaviours and bugs found |
| [features/command-catalogue.md](features/command-catalogue.md) | All 397 command/tab/decorator declarations, generated |
| [calypso-architecture.md](calypso-architecture.md) | How Calypso works: layers, model, the life of a click, commands, tools, updates |
| [before-coding.md](before-coding.md) | The detailed preparation plan (Phases 0 and 1) and the ready-to-code gate |
| [spec-gaps.md](spec-gaps.md) | What Spec lacks, spikes, upstream PR candidates |
| [pain-points.md](pain-points.md) | What is hard in Calypso today, and the Calypso refactorings R-01..R-05 |
| [testing-plan.md](testing-plan.md) | TDD, five test layers, two drivers, parity check, manual checks, validation workflow |
| [coding-guidelines.md](coding-guidelines.md) | Rules every PR follows |

## Starting point (measured on 2026-11-16, Pharo 15 build 126)

- Calypso's commands are already Commander2 commands declared as data (`<calypsoCommands>`), UI-independent, documented. Spec renders Commander2 command groups. **This removes the largest risk of the project.**
- The model packages have no Morphic code. The UI coupling is in: the browser morphs (navigation rules inside views), `ClyQueryViewMorph` (selection rules), 47 decoration methods writing into Morphic cells, 6 command methods building widgets, and the tools (tabs), which are morphs, some from other projects.
- Calypso already embeds Spec: its notebook is a subclass of Spec's notebook morph, and its page header is a Spec presenter.
- Calypso's UI test suites pass (159 tests, 1 skipped).
- **Senders, implementors and references already open `StMethodBrowser`** (NewTools, Spec), not `ClyQueryBrowserMorph`. The old route to Calypso's query browser is broken (bug B-02). The query browser is therefore mostly out of scope (D-08).
- Dialogs used by Calypso (find class, choose package, confirmations) are already Spec.
- Using the browser revealed four bugs of today's Calypso (B-01..B-05, see the walkthrough). They become acceptance scenarios and small Pharo PRs.

## Strategy

Two tracks that converge, so something usable arrives early and the final browser is clean.

**Track A: embed Spec in the Morphic browser, tool by tool.** The tabs of Calypso are declared with `<calypsoCommands>` (`aCommandMap tabs add:`), and any package can `remove:` a tab and `add:` another one. So this repository can replace a Morphic tab by a Spec one **without modifying Calypso**: a small bridge tool morph hosts a Spec presenter in the existing notebook, behind an experimental setting. Editors are what users touch most, so this gives real value soon.

**Track B: grow a new Spec browser.** A Spec shell (window, panes, toolbar, notebook, status bars) that reuses the Spec tools of Track A, uses the same model and command registry, and hosts the remaining Morphic tools (from other projects) through `SpMorphPresenter`. It starts as a minimal read-only browser and gains features PR by PR, each with its acceptance scenarios, until parity.

Why the panes are not embedded one by one into the Morphic browser: the Morphic browser talks to its panes through `ClyQueryViewMorph`'s protocol (selection objects, data sources, state snapshots); a Spec pane would have to imitate it, which is throw-away glue. Spike S-1 measures that cost; if it is small, the method pane is also embedded (Track A), otherwise panes are only built in Track B. The rule is the cheapest path with the least throw-away code: embedding is a means to ship early, not a goal. *(decision D-02, decided)*

**Upstream first.** Calypso changes go to `pharo-project/pharo`, Spec changes to `pharo-spec/Spec`. Each upstream change is analysed in a short design note, merged, and only then used here. This repository never contains a modified copy of their code.

## Target architecture

```
                       ┌──────────────────────── Calypso (unchanged API) ─────────────────────────┐
                       │ Calypso-NavigationModel / Calypso-SystemQueries (queries, scopes, items)  │
                       │ Calypso-Commands (ClyCommandRegistry, ClyCommandMap, ClyToolContext)       │
                       │ + browser navigation model (R-01), selection rules (R-02),                 │
                       │   decoration descriptions (R-03), presentation hints (R-04),               │
                       │   tool lifecycle contract (R-05)                                           │
                       └──────────────▲───────────────────────────────▲───────────────────────────┘
                                      │                               │
             Morphic UI (today, shrinking)                 Spec UI (this project)
             Calypso-Browser, -FullBrowser...               Calypso-Spec-Core      command rendering (menus, toolbar,
                                                                                    keys, table icons, DnD), decoration
                                                                                    rendering, tool contract, application
                                                            Calypso-Spec-Panes     query view presenter (tree), filter
                                                            Calypso-Spec-Tools     editors, diff, comment, setUp
                                                            Calypso-Spec-FullBrowser / -QueryBrowser   shells
                                                            Calypso-Spec-Bridge    Spec-in-Morphic and Morphic-in-Spec
                                                                                   (deleted at the end)
```

- The Spec browser presenter implements the **browser protocol commands use** (the ~45 selectors measured, e.g. `selectClass:`, `switchToVariables`, `spawnBrowser:withState:`). This protocol is written down in `docs/design/browser-protocol.md` (Phase 0) and covered by a test that both browsers understand it.
- Contexts (`ClyFullBrowserClassContext`...) are created through `<calypsoSelectionContext>` declarations for the Spec browser class, so every command applies unchanged.
- Package and class naming are decision D-01 (proposal: packages `Calypso-Spec-*`, class prefix `ClySp`).

## Phases and pull requests

Sizes: **S** < 150 lines, **M** < 400, **L** must be split. "Usable" marks PRs after which you can try something new in the image. Every PR lists its feature IDs and acceptance scenarios, see [coding-guidelines.md](coding-guidelines.md).

### Phases 0 and 1 — Preparation (no browser code yet)

Detailed step by step in **[before-coding.md](before-coding.md)** (why, what, output, done-when, effort, your role for each step, and the ready-to-code gate). Summary:

| Stage | Steps | Main outputs |
|---|---|---|
| A — Agree | A1 review and commit the docs (PR 0.1) and run 8 manual keyboard/drag checks; A2 decisions; A3 working process | Agreed docs, decisions, working process, `upstream.md` (done) |
| B — Infrastructure | B1 baseline + rebuild recipe (PR 0.2); B2 CI; B3 driver spike S-5 (PR 0.3); B4 inventory tooling and progress board (PR 0.4) | Reproducible image, CI, drivers proven, catalogue guarded by a test |
| C — Specify | C1 feature sheets per area, with scenarios (PRs 0.6a–h); C2 Morphic driver + first scenarios (PR 0.7); C3 command placement parity check | Reviewed scenarios, safety net on today's browser |
| D — Unknowns | D1 spikes S-1..S-4; D2 design notes: architecture, browser protocol, R-01..R-05, query browser | Spike notes, approved designs, D-02 and D-08 decided |
| E — Upstream first | E1 Pharo PRs for bugs B-01..B-05; E2 Spec issues for the confirmed gaps (fixed iteratively, when a step needs them) | Bug PRs and Spec issues open |

Estimated 6–7 weeks for one developer, less in parallel. Phase 2 PRs 2.1–2.2 may start earlier (after B1, B2, S-4 and the architecture note) if you want the first deliverable sooner.

### Phase 2 — Track A: Spec tools inside the Morphic browser (first usable deliverables)

The setting "Calypso > Use Spec tools (experimental)" swaps the Morphic tabs for Spec ones through a `<calypsoCommands>` declaration of this repository (`tabs remove: … ; add: …`), and resets the registry cache when toggled. Turning it off restores today's browser exactly.

| PR | Content | Feature IDs | Size | Usable |
|---|---|---|---|---|
| 2.1 | Bridge: `ClySpToolHostMorph` (a `ClyBrowserToolMorph` hosting a presenter) + Spec tool base with the lifecycle (`shouldBeActivatedInContext:`, `isSimilarTo:`, dirty state, `belongsToCurrentBrowserContext`, attach/detach) + the setting | TAB-01..06 (contract) | M | — |
| 2.2 | Method diff tool in Spec (`SpDiffPresenter`) | TAB-08 | S | **yes, first deliverable** |
| 2.3 | Class definition editor in Spec: show, accept (fluid and old style), accept a method source, dirty state, expand definition | EDT-04, EDT-15, TAB-04 | M | yes |
| 2.4 | Class creation and method creation editors | EDT-02, EDT-05 | M | yes |
| 2.5 | Protocol/extension editor status bar (with its checkbox) and editor switches (line numbers, wrap, format-as-read, cursor position) | EDT-03, EDT-08, TAB-12 | M | yes |
| 2.6 | Method editor: show, accept, cancel, dirty, edit conflicts, highlight on open, do-it bindings | EDT-01, EDT-13, EDT-14, EDT-16 | L → 2 PRs | yes |
| 2.7 | Method editor: code navigation and source-code context menu/shortcuts (needs S-3 result) | EDT-09, CMD-01/02 in editors | M | yes |
| 2.8 | Test `setUp` editor | EDT-07 | S | yes |
| 2.9 | Left bar and debug point icons, critics panel (after the Spec PRs for G-17/G-18) | EDT-10..12 | L → 3 PRs | yes |

In parallel, the Spec upstream PRs found in Phase 1 (notebook header actions and reordering first).

### Phase 3 — Calypso refactorings (PRs to Pharo)

Each starts with a design note (`docs/design/R-0x.md`) agreed with you, then small PRs to `pharo-project/pharo`, each keeping the Morphic browser and its tests green (and the Morphic acceptance scenarios of 0.7). Order follows the needs of Phase 4.

| Ref | Refactoring | Needed by |
|---|---|---|
| R-02 | Selection rules (desired/symbolic, silent, highlight) out of `ClyQueryViewMorph` | 4.2 |
| R-03 | Decorations as descriptions (per family: groups and visibility levels, methods, classes, packages/projects, plugins) | 4.3 |
| R-04 | Presentation hints instead of widget-building in commands | 4.6 |
| R-05 | Tool lifecycle contract independent of `ClyBrowserToolMorph` (generalises 2.1) | 4.7 |
| R-01 | Full-browser navigation rules out of `ClyFullBrowserMorph` into a navigation model | 4.4 |

R-02 and R-03 can start as soon as Phase 1 ends; they run in parallel with Phase 2.

### Phase 4 — Track B: the Spec browser

Opened from its own menu entry "System Browser (Spec preview)" until parity.

| PR | Content | Feature IDs | Size | Usable |
|---|---|---|---|---|
| 4.1 | Command rendering for Spec: context menu tree, shortcuts (dynamic dispatch), double click, from `ClyCommandRegistry` | CMD-01, -02, -05, -08 | M | — |
| 4.2 | Query view presenter: tree of a Calypso query result, lazy children, multi-selection, selection rules (R-02), filter (after G-09) | SEL-*, FLT-* | L → 2–3 PRs | — |
| 4.3 | Decoration rendering (R-03) incl. table icons and checkbox rows | DEC-*, CMD-04, MGP-03 | M | — |
| 4.4 | Full browser shell: four panes wired to the navigation model (R-01); packages, classes (flat/hierarchy), protocols, methods; read-only | PKG-01/02, CLS-01/04/05/06, MGP-01/02, MTH-01, SEL-05 | L → 3 PRs | **yes, read-only browsing** |
| 4.5 | Notebook of tools: Spec tools from Phase 2, Morphic tools hosted (`SpMorphPresenter`), tab selection rules | TAB-01..14 | M | yes, editing |
| 4.6 | Toolbar with mode switches (R-04): projects/scoped, hierarchy/traits, instance/class side, methods/vars | BRW-12, PKG-03, CLS-02/03, MGP-04/05 | M | yes |
| 4.7 | Navigation history, spawn, across-window history, window title, close with dirty tools | HIS-*, BRW-03..05 | M | yes |
| 4.8 | Drag and drop | CMD-06, PKG-07/08, MGP-08/09, MTH-07, CLS-10 | M | yes |
| 4.9 | Find class / find method dialogs, keyboard focus between panes | CLS-09, MTH-06, BRW-11 | M | yes |
| 4.10 | Query results: no port of `ClyQueryBrowserMorph` (D-08); the Spec browser opens `StMethodBrowser` like today, and the remaining old entry points are routed to it (bug B-02 fixed upstream in E1) | QRY-* | S | yes |
| 4.11 | Live update on system changes, async groups with activity indicator | UPD-*, MGP-02 | M | yes |
| 4.12 | Plugins, scoped mode, Ring environments, settings | BRW-08..10, SET-* | M | yes |

### Phase 5 — Parity and hardening

- All P-tier scenarios green on the Spec driver; the generated command-placement parity test green.
- Performance on large images (all packages, `Object` methods, senders of `#new`): budgets defined and measured.
- Keyboard-only use of every pane; theme switching; HiDPI.
- Daily use by a few volunteers; bug fixing.
- The Spec browser can be chosen as the default browser (setting).

### Phase 6 — Integration in Pharo

- Move the packages into the Pharo repository (or load them in the Pharo baseline), with their tests; the acceptance tests move with them (D-03).
- The docs are not shipped. A short archive is kept (the key decisions, the upstream PRs, the refactorings and why), and the rest of `docs/` is retired.
- Spec browser becomes the default; the Morphic UI is deprecated for one release, then removed together with the bridge package and `Commander-Calypso-Compatibility`.

## Milestones (what you can test)

| Milestone | After | You get |
|---|---|---|
| M0 | 0.1 | This plan and the inventory to review |
| M1 | 2.2 | First Spec piece inside your normal Calypso (diff tool), switchable |
| M2 | 2.6 | Class and method editing in Spec inside your normal Calypso |
| M3 | 4.4 | A Spec browser you can navigate with |
| M4 | 4.12 | Spec full browser usable for daily work |
| M5 | Phase 5 | Parity, default browser |

## Decisions

| Id | Question | Proposal |
|---|---|---|
| D-01 | Package and class naming | **Decided (2026-11-23):** packages `Calypso-Spec-*`, class prefix `ClySp` |
| D-02 | Panes: embed in the Morphic browser too, or only in the new shell | **Decided (2026-11-19):** the cheapest option with the least throw-away code. Embedding exists only to ship small Spec pieces early; if spike S-1 shows that embedding a pane needs glue code, panes are not embedded and go only into the new shell. The main goal is a good Calypso in Spec. |
| D-03 | Where acceptance tests live once in Pharo | **Decided (2026-11-19):** they are plain SUnit, so they move into Pharo with the code |
| D-04 | Write the Morphic driver to pin behaviour before refactoring Calypso | **Decided (2026-11-19):** yes, limited to SEL, HIS, TAB and the areas R-0x touch. Always TDD: the pinning test is written and green before the refactoring starts. |
| D-05 | Target Pharo version | **Decided (2026-11-19):** Pharo 15 |
| D-06 | Features we may drop | **Decided (2026-11-23):** drop BRW-06 (window groups) and CMD-11 (legacy class annotations). Listed in the inventory's [Dropped features](features/README.md#dropped-features) with what it takes to add them back. |
| D-07 | MVP scope (M tier) | **Decided (2026-11-23):** as marked in the inventory, plus BRW-10, PKG-09, PKG-10, TAB-13 and ENT-04 moved to M. ENT-05 stays an external feature (X). |
| D-08 | `ClyQueryBrowserMorph`: port it, or retire it in favour of `StMethodBrowser` (already used for senders/implementors/references) | **Decided (2026-11-19):** retire it: route its remaining entry points to `StMethodBrowser`, port nothing |
| D-09 | Acceptance test framework | **Decided (2026-11-19):** SUnit with a browser driver, no Hera for now (see [testing-plan.md](testing-plan.md)) |

## Risks

| Risk | Mitigation |
|---|---|
| The drivers cannot drive trees, menus or keys reliably | Spike S-5 first; logic tested through the registry; real key presses and drags checked by hand (T-09) |
| Upstream PRs (Spec, Pharo) take long to merge | Start them early (Phase 1), keep them small, keep a documented local workaround only while waiting |
| Calypso refactorings break the Morphic browser | Design notes first, Morphic acceptance scenarios (0.7), Calypso suites, small PRs |
| Performance of Spec trees on large results | Measure in S-1/S-2; lazy children and query cursors; budgets in Phase 5 |
| Morphic tools from other projects (BeautifulComments, DA, Roassal) | Host them through `SpMorphPresenter` until they are replaced by Spec presenters (P-05) |
| Scope creep (redesigning the browser) | Parity first; improvements are listed as separate, later proposals |
| Background processes, flaky UI tests | UI updates only on the UI thread; test helpers wait for quiescence; process-leak checks |

## Staying on track

Two tools, decided on 2026-11-19, keep the work understandable and verifiable:

- **[Feature sheets](features/sheets/README.md)**, one per area: the complete specification of every feature (behaviour, code entry points, edge cases, scenarios). You review each sheet before any code for that area; the agent works only from reviewed sheets.
- **The [progress board](progress.md)**, generated from the code at every PR: for each scenario, whether it has a test, passes on Morphic, passes on Spec, and was checked by you. It answers "where are we?" without trusting anyone's summary.

## Working agreement

1. Every change is a small PR, reviewed by you in the image before it is opened.
2. A PR states its feature IDs, scenarios, dependencies and how to try it.
3. Spec or Calypso problems are fixed upstream first; this repo never patches them.
4. A Calypso model change happens only through an agreed refactoring (R-0x), merged in Pharo first, with the Morphic browser still working.
5. The inventory, catalogue and this plan are updated in the PR that makes them out of date.

## Requirements of the brief and where they are handled

| Requirement | Where |
|---|---|
| Inventory of all features, with hidden ones (navigation, selection, checkboxes in lists) | `features/README.md` (SEL, HIS, TAB-03/04, MGP-03, EDT-03), `command-catalogue.md` |
| Acceptance tests for each feature (Hera dropped for now, D-09); unit tests | `testing-plan.md`, PRs 0.3, 0.6, 0.7, every Phase 2/4 PR |
| What Spec is missing, and improving Spec upstream | `spec-gaps.md`, Phase 1, upstream PRs |
| Step by step, embedding Spec in Morphic | Track A (Phase 2), D-02 |
| Small, reviewable PRs, early usable deliverable | PR tables and sizes, milestones M1–M4 |
| Maintainable code | `coding-guidelines.md`, target architecture |
| Pain points | `pain-points.md` |
| Model untouched, or refactored separately and merged in Pharo first | `pain-points.md` R-01..R-05, Phase 3, working agreement 4 |
| Never patch Spec here | `spec-gaps.md` rule, guidelines rule 5 |
| Nothing breaks in Pharo | Experimental setting, Calypso suites, Morphic driver, Phase 6 deprecation cycle |
