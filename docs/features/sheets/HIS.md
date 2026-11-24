# HIS: navigation history

Status: **reviewed** 2026-11-24 (manual check done for HIS-01). Code read on Pharo 15 build 145, 2026-11-24.

Back and forward through what the user looked at, like a web browser, also across the windows spawned from a browser.

- Each browser has a `ClyNavigationHistory` (an undo list and a redo list of browser states).
- A state (`ClyBrowserState`, `ClyFullBrowserState` for the full browser) holds, per pane, a copy of its data source and its selection as a desired selection (`ClyQueryViewState`), the selected tabs, the system scope, the meta-level and the method group query.

## HIS-01: Back and forward (M)

**Behaviour.** Back restores the previous state: the panes, their selections, the side, the mode (methods or variables) and the selected tabs. Forward goes the other way. A new step after going back clears the forward list.

**How to trigger.** The green arrows in the tab header (tab actions), Alt+Left / Alt+Right in the panes and in the editors.

**Code.**
- `ClyNavigateBrowserBackCommand` / `ClyNavigateBrowserForwardCommand` (catalogue: `ClyBrowserContext`, `ClyTextEditorContext`) → `ClyBrowserMorph>>navigateBack` / `navigateForward`.
- `ClyNavigationHistory>>undoNavigationOf:` / `redoNavigationOf:` → `restoreNavigationState:of:` → the state's `applyTo:byUndo:`; `executeUndoBy:` records the state left into the redo list.
- `ClyQueryViewState>>applyTo:` restores a pane's data source, then its selection like a desired selection (SEL-01).

**Edge cases.** Back with an empty history (nothing happens); the restored class was removed since.

**Existing tests.** `ClyBrowserStateTest`, `ClyFullBrowserStateTest`, `ClyQueryViewStateTest` (taking and applying states); none on back and forward.

**Scenarios.**
- `HIS-01.a` Given class A selected, then class B, when I go back, then A is selected; when I go forward, then B is selected.
- `HIS-01.b` Given method `x` selected, then method `y`, when I go back, then `x` is selected and its editor is shown.
- `HIS-01.c` Given the class side shown, when I go back, then the instance side is shown.
- `HIS-01.d` Given I went back, when I select another class, then going forward does nothing.

**Manual check.** Alt+Left / Alt+Right in a pane and in an editor (T-09). Checked 2026-11-23 (walkthrough, K-6).

## HIS-02: What is a step (M)

**Behaviour.** Each change made through the browser is one step, however many panes it changes: the step stores the state *before* the change. A change that leaves the state as it was is not a step, nor is a silent change (SEL-04: system updates, restores), nor a state where no pane shows anything. A tab clicked by hand is a step (TAB-03); switching side or mode is a step.

**Code.** `ClyBrowserMorph>>changeStateBy:` (snapshot before, `isCurrentStateOf:` after, then `recordNavigationState:`); `ClyNavigationHistory>>recordState:` (`representsConcreteQuery`, `waitingNewState`); `ignoreNavigationDuring:`; `ClyNotebookManager>>pageChanged:` (tab click).

**Scenarios.**
- `HIS-02.a` Given class A selected, when I select A again, then no step is added.
- `HIS-02.b` Given class A selected, when a method is added to A elsewhere, then no step is added.
- `HIS-02.c` Given a class with its Comment tab selected, when I click its definition tab and go back, then the Comment tab is selected again.

**Manual check.** None.

## HIS-03: States hold no query results (P)

**Behaviour.** A state keeps the queries of the panes, not their results, so going back shows the system as it is now, not as it was.

**Code.** `ClyQueryViewState` (`copyForBrowserStateSnapshot` of the data source; its class comment).

**Existing tests.** `ClyQueryViewStateTest` (closed data sources).

**Scenarios.**
- `HIS-03.a` Given class A selected, then class B, when a method is added to A and I go back, then A's methods include the new one.

**Manual check.** None.

## HIS-04: Across windows (P)

**Behaviour.** A browser spawned from another (double click on a class, "Browse") starts with a step back to its origin. Going back there closes the spawned browser and brings the original window to the front, or reopens it in its state if it was closed. Going forward from the original goes to the spawned browser again. If the original window is open but no longer shows the state it had when the browser was spawned, going back does nothing.

**Code.** `ClyBrowserMorph>>wasSpawnedFrom:` (records a `ClyAccrossWindowNavigationState`); `ClyAccrossWindowNavigationState>>applyTo:byUndo:` (the "does nothing" check, then `recordAcrossWindowNavigationFrom:byUndo:`, `close`, `restoreBrowserWindow`, which re-creates the browser with `createBrowser`).

**Existing tests.** `ClyAccrossWindowNavigationStateTest` (10 tests on taking the state and creating the browser).

**Scenarios.**
- `HIS-04.a` Given a browser spawned from another, when I go back in it, then it is closed and the original browser is active.
- `HIS-04.b` Given the original browser closed, when I go back in the spawned one, then the original is reopened with its selection.
- `HIS-04.c` Given the original browser selected another class since, when I go back in the spawned one, then nothing happens.

**Manual check.** None.

**Notes.** `HIS-04.c` is today's behaviour read from the code; the Spec browser keeps it (2026-11-24).

## HIS-05: Pluggable history class (dropped)

**Behaviour.** A setting, Calypso ▸ Navigation History, chooses the history class among `ClyNavigationHistory` and its subclasses.

**Code.** `ClyBrowserMorph class>>settingsNavigationHistoryOn:`, `navigationHistoryClass`.

**Scenarios.** None.

**Notes.** `ClyNavigationHistory` has no subclass in the image, so the setting offers one choice. Dropped on 2026-11-24 (D-06).
