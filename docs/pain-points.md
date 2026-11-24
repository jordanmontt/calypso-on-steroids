# Pain points in today's Calypso

What makes the current browser hard to understand and change, and what each point means for this project. Found by reading the image (Pharo 15 build 126) on 2026-11-16.

Good news first: Calypso in Pharo 15 is in a better state than its reputation.

- Commands are **Commander2** commands (`ClyCommand < CmCommand`) declared as plain data with `<calypsoCommands>` (`ClyCommandMap`), documented in `doc/Calypso/Commands.md`. They are UI-independent: they run on a `ClyToolContext`. Spec already renders Commander2 groups.
- The **model** (`Calypso-NavigationModel`, `Calypso-SystemQueries` and the `*-Queries` plugin packages) has no Morphic code. Plugins only tag items (`decorateBrowserItem:`) with properties.
- Commands depend on the browser through a small set of messages: **about 45 selectors** sent to `browser` and 13 to `tool` across 521 command classes (measured). Only 6 command methods create Morphic widgets.

So the UI can be replaced without rewriting commands or the model. The pain is concentrated in the UI layer.

## P-01: The browser morph is the controller, the view and the state

`ClyBrowserMorph` (100 methods) and `ClyFullBrowserMorph` (94) are morphs that also own the navigation logic: what happens when a class is selected (`classSelectionChanged`), meta-level switching, method visibility, extension handling, history, plugins, title. The rules of the four-pane browser (SEL-05, CLS-04, CLS-05) are hidden inside morph methods that also do layout.

**Impact:** the Spec browser must not copy this. **Plan:** extract the navigation rules into a UI-independent "browser navigation model" (a plain object that holds the queries, the meta-level, the visibility scope and the selections, and announces changes). Both the Morphic and the Spec browsers use it. This is a Calypso refactoring PR (R-01) done before the Spec shell exists, tested against the Morphic browser.

## P-02: `ClyQueryViewMorph` mixes table rendering, selection logic and command dispatch

106 methods: FastTable setup, three kinds of selection (main, desired, highlighting) kept in sync with row indexes, filtering, drag and drop, menus, shortcuts, clicks, async state, navigation requests to the browser by selector (`requestNavigationBy: #classSelectionChanged`).

**Impact:** the Spec pane must reproduce the selection rules (SEL-01..07) exactly. **Plan:** separate the selection rules (desired selection, restore by name, silent selection) into objects usable by a Spec pane (R-02). Keep `ClyDataSource*` for Morphic only; the Spec pane gets its items from the query result directly (`ClyBrowserQueryResult`, cursor).

## P-03: Decorations write directly into Morphic cells

47 `decorate*TableCell:of:` methods, in UI packages but on *model* classes (groups, queries, visibility levels) and decorators, change a `ClyItemCellMorph` directly (`definitionIcon:`, label color, emphasis, extra tools). The method-visibility checkbox (`ClyMethodVisibilityMorph`) is created by `ClyFullVisibilityLevel`, a domain class, via an extension.

**Impact:** no decorator can be reused by Spec. **Plan:** introduce a small UI-independent *decoration description* (icon names with priority, emphasis, color role, extra actions) that decorators fill in; the Morphic cell renders it (so the Morphic browser keeps working); the Spec pane renders the same description (R-03). This is the most important Calypso refactoring for the Spec port, and the largest one, so it is split per decorator family.

## P-04: Commands that build widgets

`ClyCommand>>createTableCellButtonWith:using:`, `decorateTableCell:using:`, `ClySwitchBrowserModeCommand>>toolbarItemFor:`, `ClySwitchQueryScopeCommand>>toolbarItemFor:` create morphs; `ClyTestCommand>>notifyUserAboutResults:with:` too.

**Impact:** small. **Plan:** these become "presentation hints" (is it a toggle, what is its group, which item list for a combo box) rendered by each UI (R-04).

## P-05: Tools (tabs) are morphs, also outside Calypso

Every tab is a `ClyBrowserToolMorph` subclass: Calypso's editors, but also BeautifulComments, the dependency analyser and the Roassal baseline map, which live in other projects. `ClyTabEntry` holds the tool *class*.

**Impact:** the Spec browser must host Morphic tools for a long time. **Plan:** a Spec tool contract (a presenter class registered with `tabs add:` like today, with the same lifecycle: `shouldBeActivatedInContext:`, `isSimilarTo:`, `belongsToCurrentBrowserContext`, dirty state...) plus an adapter that hosts any existing `ClyBrowserToolMorph` in the Spec notebook through `SpMorphPresenter` (G-02). Hosting is temporary: the Spec browser will eventually accept only presenters, so every Morphic tool, external ones included, must be replaced by a Spec presenter (by its owners, or by us).

## P-06: Spec widgets already subclassed inside Calypso

`ClyNotebookMorph < SpNotebookMorph`, `ClyNotebookPageMorph < SpNotebookPageMorph`, `ClyNotebookPageHeaderPresenter < SpPresenter` add reordering and header actions to Spec's notebook from the Calypso side.

**Impact:** this is exactly "patching Spec in another repository". **Plan:** upstream these features to Spec (G-15) early; the Spec browser then uses the Spec API, and the Morphic browser can be simplified afterwards.

## P-07: Text editor customisation through Rubric subclasses

`ClyTextEditor < RubSmalltalkEditor` and `ClyTextEditingMode` override navigation (senders, implementors, browse) so the browser answers them; status-bar morphs poke into the text morph; the left bar and the critique segments are Rubric morphs.

**Impact:** the method editor is the hardest tool to port. **Plan:** port it late (Phase 4), after the panes; build it on `SpCodePresenter` and the shared method editor, upstreaming what is missing (G-17, G-18, G-19), so it is the same editor as everywhere in Pharo (plan, sub-goal).

## P-08: Background processes and deferred updates

Tools build in background (`TabManagerMorph` logic), async queries run in processes, data sources update from a low-priority process via `UIManager default defer:` (`ClyDataSourceUpdateScheduler`).

**Impact:** a source of flaky UI tests and of races. **Plan:** keep the model's async queries; in the Spec UI, apply updates only on the UI thread through the application, and give tests a way to wait for quiescence (needed by the acceptance-test drivers).

## P-09: Naming and leftovers

Classes named after old concepts (`TabManagerMorph` in comments, "data source" for table models), `ClyStatusBarMorph` comment says its own panel names are "completely strange", typos in class names (`ClyAccrossWindowNavigationState`, `Calypso-SystemTools-OldToolCompatibillity`, `ClyDebugBrokenCritiqueCommand` label…), deprecated compatibility package (`Commander-Calypso-Compatibility`) to be removed in Pharo 16.

**Impact:** low, but the new code must not copy these names. The Spec classes get clean names from day one (see `coding-guidelines.md`).

## P-10: The model reads methods from the method dictionary

Known limitation from the project brief: Calypso queries take methods from method dictionaries, which breaks proxy methods. **Out of scope** for the UI rewrite (the model is not changed), recorded here so that no Spec code adds a new direct dependency on method dictionaries.

## P-11: Shortcuts shared by several commands

Cmd+T, Cmd+R, Cmd+F, Cmd+E,M are each declared by several commands in overlapping contexts; which one runs depends on context, priority and `canBeExecuted`. Hard to discover, easy to break.

**Plan:** the acceptance suite has one scenario per shared key and context (CMD-02), and the generated catalogue flags shared keys.

## Refactorings of Calypso needed before the Spec work (summary)

These are PRs to **pharo-project/pharo** (Calypso lives there). Each one: no behaviour change, the Morphic browser keeps passing its 159 UI tests and our Morphic acceptance tests, and it is merged before the Spec step that needs it.

| Id | Refactoring | Needed by | Size |
|---|---|---|---|
| R-01 | Extract the full-browser navigation rules from `ClyFullBrowserMorph` into a UI-independent navigation model | Spec shell (Phase 3) | L, split in 3–4 PRs |
| R-02 | Extract the selection rules (desired/symbolic, silent, highlight) from `ClyQueryViewMorph` | Spec panes (Phase 2) | M |
| R-03 | Decorations as descriptions instead of direct cell changes (per family: groups, methods, classes, packages, plugin decorators) | Spec panes (Phase 2) | L, split per family |
| R-04 | Commands give presentation hints instead of building morphs | Spec toolbar (Phase 3) | S |
| R-05 | Tool lifecycle contract independent of `ClyBrowserToolMorph` (so a presenter can be a tab) | Spec notebook (Phase 3) | M |

Each refactoring is analysed in a short design note (`docs/design/R-0x.md`) and agreed **before** coding, because they touch the main Pharo repository.

## Findings from using the browser (second pass)

Using the browser (see [features/walkthrough.md](features/walkthrough.md)) added these points:

- **P-12: Calypso's query browser is half-retired.** Senders, implementors and references go to NewTools' `StMethodBrowser` (Spec), but `ClyBrowserMorph>>spawnQueryBrowserOn:withState:` still treats `Smalltalk tools messageList` as a Calypso browser and fails (bug B-02). Two query browsers coexist and one entry path is broken. **Plan:** decision D-08 (retire `ClyQueryBrowserMorph`, route everything to `StMethodBrowser`), fix B-02 upstream first.
- **P-13: Tool updates are fragile.** An edit conflict duplicates the status bar and drops the dirty marker (B-01); running tests from a row icon duplicates the method-creation tab (B-03). Both come from the update/recycling logic of tools (`ClyNotebookManager`, `ClyBrowserToolMorph>>update`), which the Spec notebook must not copy. **Plan:** the tool contract (R-05) defines update explicitly; B-01 and B-03 become acceptance scenarios.
- **P-14: `canBeExecuted` methods assume a selection.** Menus are built by asking every command `canBeExecuted`; one command that sends `first` to an empty selection opens a debugger on a right click in empty space (B-04). **Plan:** fix upstream; the Spec menu renderer must not hide such errors either (guidelines: no swallowed exceptions), so the fix is in the command.
- **P-15: Names that mislead users.** "Flat" shows a (local) hierarchy; the red "!" tab action is a menu, not a warning. Not to change now (parity first), but to list as later UX proposals.
