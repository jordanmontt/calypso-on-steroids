# What Spec needs to host Calypso

This document lists what the Spec version of Calypso needs from Spec, and what Spec 2 in Pharo 15 (build 126) provides. It was written from the API present in the image (selectors and classes checked on 2026-11-16), **not yet from spikes**. Each gap is a hypothesis until a spike confirms it (plan, Phase 1).

**Rule:** a Spec gap or bug is never patched in this repository. It becomes an issue and a PR to [pharo-spec/Spec](https://github.com/pharo-spec/Spec) (or to Pharo for the Morphic adapters), with its own tests. Calypso work that depends on it waits, or uses a *documented* temporary workaround that lives in the presenter that needs it and is removed when the Spec PR is merged. Each workaround is logged in `docs/workarounds.md` and in the upstream backlog.

## Legend

- **OK**: available, enough as far as the API shows.
- **Partial**: available but missing something Calypso needs.
- **Gap**: not available.
- **Calypso-side**: not a Spec problem; it is about how Calypso is written.

## Summary

| # | Need | Calypso features | Spec today | Status |
|---|---|---|---|---|
| G-01 | Spec presenter inside a Morphic browser | Incremental migration | `SpPresenter>>build` answers a morph | OK (to validate: focus, keymaps, theme, resize, deferred updates) |
| G-02 | Morph inside a Spec presenter | Keep Morphic tools (plugin tabs) during the migration | `SpMorphPresenter` | OK (to validate: keyboard focus and keymaps) |
| G-03 | Tree with lazy children, multi-selection, expand/collapse by path, keep selection on refresh | All panes | `SpTreeTablePresenter` (`lazilyComputeChildren`, `selectPath:`, `updateRootsKeepingSelection:`), `SpTreeListViewPresenter` | OK / Partial: no API for *symbolic* restore (by equal or same-name item), see G-04 |
| G-04 | Restore a selection by identity, then by name, silently (no event) | SEL-01, SEL-04 | `disableSelectionDuring:` exists on list views; restore by name is not a Spec concern | Calypso-side (keep `ClyDesiredSelection` logic in a Calypso presenter); verify that a silent selection does not fire `whenSelectionChangedDo:` |
| G-05 | Secondary highlighting of rows (not selected) | SEL-03 | Per-cell `displayBackgroundColor:` only | Partial: needs a per-row "highlighted" state that survives refresh and theme. Candidate Spec PR. |
| G-06 | Per-row decoration: icon(s), bold/italic/strikethrough/color, gray, indentation | DEC-*, CLS-06, MTH-02 | `SpStringTableColumn` display* blocks, `SpImageTableColumn`, `SpCompositeTableColumn`; list views with setup/bind | OK for one icon + style. Several icons, and their priority, are Calypso-side (decoration model, see pain point P-03). |
| G-07 | Clickable icon buttons inside a row (table icons) | CMD-04, MTH-04, MTH-05, EDT-12 | `SpImageTableColumn` has no action; `SpLinkTableColumn` is text; list views can host any presenter per row | Partial: tree *table* has no clickable image column. Either a Spec PR (action on image column) or use `SpTreeListViewPresenter` rows. Decide in spike S-2. |
| G-08 | A checkbox inside a tree row, mixed with plain rows | MGP-03 inherited visibility | `SpCheckBoxTableColumn` (whole column); list views per-row presenter | Partial: needs a checkbox on *some* rows only. Spike S-2. |
| G-09 | Filter field over a tree (substring and regex), keeping selection | PKG-04, CLS-07, FLT-* | `SpFilteringListPresenter` is for flat lists only; type-ahead search (`enableSearch`) for trees | Gap: no filtering tree presenter. Candidate Spec PR (`SpFilteringTreePresenter` or a filter on tree tables). |
| G-10 | Drag and drop between panes with per-target acceptance, drop highlight, expand on hover | CMD-06, PKG-07, MGP-08 | `dragEnabled:`, `dropEnabled:`, `wantsDrop:`, `acceptDrop:` on lists and trees | Partial: verify the drop target row is given to `wantsDrop:`, the hover highlight, and hover-to-expand with delay (SET-04). |
| G-11 | Context menu computed at open time from the selection | CMD-01 | `contextMenu:` with a block, `contextMenuFromCommandsGroup:` (Commander2) | OK: Calypso commands are already Commander2 `CmCommand`s. Validate sub-menus, inlined groups with lines, shortcut labels, icons. |
| G-12 | Shortcuts resolved at key-press time from the selection (several commands per key, chords) | CMD-02 | `contextKeyBindings:` (static KMCategory), actions with `shortcutKey` | Partial: keymaps are installed statically. Calypso needs a dispatcher that asks the registry on each key (as `ClyKMDispatcher` does). Spike S-3: either a Spec hook for a dynamic key dispatcher, or rebuilding bindings on selection change. |
| G-13 | Double click / activation per context | CMD-05 | `whenActivatedDo:`, `activateOnDoubleClick` | OK |
| G-14 | Toolbar rebuilt per context, with mode switches (radio-like) and custom widgets (scope combo box) | BRW-12, QRY-02 | `SpToolbarPresenter` (`removeAllItems`, `addItem:`, toggle buttons), drop lists | OK / Partial: toggle groups that behave as radio buttons; custom widget items. |
| G-15 | Notebook with closable, reorderable pages, page header actions (icon buttons), dirty marker in title, lazy page building | TAB-* | `SpNotebookPresenter`, `SpNotebookPage` (`beCloseable`, `icon:`, `presenterProvider:`, `whenRetrievedDo:`) | Gap: no header actions, no reordering in Spec's API. **Calypso already subclasses Spec's Morphic widgets** (`ClyNotebookMorph < SpNotebookMorph`, `ClyNotebookPageMorph < SpNotebookPageMorph`, `ClyNotebookPageHeaderPresenter`) to get them: these belong in Spec. Candidate Spec PR #1. |
| G-16 | Code editor: syntax highlighting, method/class interaction models, accept/cancel, dirty state, line numbers, wrap | EDT-01..05, EDT-08 | `SpCodePresenter` (`whenSubmitDo:`, `hasUnacceptedEdits`, `withLineNumbers`, `wrapWord:`, `interactionModel:` with `SpCodeMethodInteractionModel`/`SpCodeBehaviorInteractionModel`) | OK (to validate: cancel, edit-conflict detection, pending text) |
| G-17 | Editor gutter (left bar): click, double click and menu per line | EDT-10 | No gutter API on `SpCodePresenter` | Gap. Candidate Spec PR. |
| G-18 | Text decorations: underlined critique ranges with hover menu, icons in text (debug points) | EDT-11, EDT-12 | `addTextSegmentDecoration:` / `removeAllTextSegmentDecorations` | Partial: verify icons and hover menus on segments; `DebugPointIconStyler` is a Rubric `IconStyler` (Morphic-only). |
| G-19 | Code navigation on the node under the cursor (browse/senders/implementors done by the host tool) | EDT-09 | Interaction model + `editionContextMenu`, `overrideContextMenu:` | Partial: Calypso overrides navigation in `ClyTextEditor`. Need a clean hook for "who handles browse/senders/implementors" (probably the application or interaction model). |
| G-20 | Status bar per tool with arbitrary items (labels, checkbox, toggles, spinner) | TAB-12, EDT-03, EDT-08 | `SpStatusBarPresenter` (text messages) | Partial: Calypso needs a small layout of presenters, which a plain `SpBoxLayout` gives; `SpStatusBarPresenter` is not needed. Calypso-side. |
| G-21 | Async loading with spinner in lists and status bar | MGP-02 async groups, EDT-12, QRY-01 | Nothing specific | Gap (small): a spinner/activity presenter. Could use an animated image. Candidate Spec PR. |
| G-22 | Window groups (several browsers in a tabbed window) | BRW-06 | Not in `SpWindowPresenter` | Gap, low priority. Decide whether to keep the feature. |
| G-23 | Window title updated from the presenter, `okToChange` on close | BRW-03, BRW-04 | `withWindowDo:` `title:`, `askOkToClose`, `whenWillCloseDo:` | OK |
| G-24 | UI updates coming from a background process (deferred, batched) | UPD-01 | Spec runs on the UI thread; `application defer:`-style APIs | Calypso-side: keep `ClyDataSourceUpdateScheduler`, adapt its sink. |
| G-25 | Testing support: find presenters by label, click, type, select in lists/trees, open context menus, press keys | All acceptance tests | `SpPresenter` test helpers; acceptance tests use our own Spec driver (no Hera, D-09) | Partial: selecting in trees, building context menus and pressing keys work through presenters and adapters (spike S-5, see the testing plan); missing helpers become Spec PRs when a test needs them. |

## Spikes to run first (Phase 1)

Each spike is time-boxed (one or two days), lives on a throw-away branch, and ends with a short note in `docs/spikes/` stating the result and the issues or PRs to open.

| Spike | Question | Gaps |
|---|---|---|
| S-1 | Embed a Spec tree in `ClyFullBrowserMorph` in place of one `ClyQueryViewMorph`: focus, keymaps, theme, resize, selection events, deferred updates | G-01, G-03, G-04, G-24 |
| S-2 | Render the method-group pane (protocols, virtual groups with icons, inherited groups with a checkbox, bold class side) with `SpTreeTablePresenter` and with `SpTreeListViewPresenter` | G-06, G-07, G-08 |
| S-3 | Context menu and shortcuts of a pane from `ClyCommandRegistry` on a Spec tree, including shared keys and chords | G-11, G-12 |
| S-4 | `SpCodePresenter` as the method editor inside a Morphic tab: accept/cancel, dirty state, interaction model, navigation hook, text segments | G-16, G-18, G-19 |
| S-5 | The test drivers drive a Spec tree and the Morphic panes (select path, open context menu, run a shortcut); what remains manual | G-25 |

## Upstream candidates (expected PRs to Spec)

Gaps are fixed **iteratively**: a Spec PR is made when the step that needs it comes, then that step continues. The list below is the expected order of need, not a batch to do up front.

1. Notebook page header actions + reordering (move what `ClyNotebookMorph`/`ClyNotebookPageMorph` do into Spec) — G-15.
2. Dynamic key dispatch for presenters (ask a block on key press) — G-12.
3. Filtering tree presenter — G-09.
4. Clickable image column / row action icons — G-07.
5. Row highlighting state — G-05.
6. Code presenter gutter interactions — G-17.
7. Activity (spinner) presenter — G-21.

Each one: an issue first (describe the need with the Calypso case), then a PR with tests in Spec's test suites (`Spec2-Tests`, `Spec2-Morphic-Backend-Tests`), then the Calypso step that uses it. Until the PR is merged, the step waits or uses a documented workaround ([workarounds.md](workarounds.md)), with your approval.
