# TAB: tools and tabs

Status: **reviewed** 2026-11-23 (manual checks done for TAB-01..07, 09, 14). Code read on Pharo 15 build 145, 2026-11-23.

Under the four panes, the browser shows a notebook of **tools**, one per tab: editors, the class comment, the diff, tools of other projects. Which tools appear depends only on the selection; the user never opens a tab by hand.

- `ClyNotebookManager` (one per browser, `browser tabManager`) decides which tools are shown and which tab is selected.
- Each tool is a `ClyBrowserToolMorph` subclass, declared in a command map with `aCommandMap tabs add: AToolClass` (the 15 `tabs` rows of the [catalogue](../command-catalogue.md)).
- `ClyNotebookMorph` / `ClyNotebookPageMorph` draw the tabs; the tab header is a Spec presenter, `ClyNotebookPageHeaderPresenter`.

## TAB-01: Tabs chosen from the selection (M)

**Behaviour.** Each time the selection changes, the browser asks which tools apply to it, keeps the ones already open, opens the new ones and closes the others. Today:

| Selection | Tools, in tab order |
|---|---|
| Package, no class | Dependencies (−10), Package comment (−10), Class creation (1) |
| Class | Class creation (1), Class definition (10), Comment (10.5), `setUp` (11, test classes only), Baseline map (`BaselineOf` subclasses), Method creation (1000) |
| One method | the class tools + Method editor (20) |
| Two or more methods | + Diff (10000, of the first two) |
| Protocol or variable | Method creation (1000) is added for that group |

**How to trigger.** Select anything in the four panes.

**Code.**
- `ClyNotebookManager>>updateTools` → `basicUpdateTools` → `updateTabs`: install, then remove, then tell every tool `browserContextWasChanged`.
- `ClyNotebookPageRecycler` compares the tools open with the tools the new contexts want (`toolsToInstall`, `toolsToRemove`).
- A tool applies when `ClyCommandRegistry` activates its `tabs` entry in the context, which asks `AToolClass class>>shouldBeActivatedInContext:` (e.g. the diff: `selectedMethods size > 1`).

**Edge cases.** Several classes or packages selected; class side; a `setUp` method selected by hand (then no `setUp` tab); a class of a test package without `setUp`.

**Existing tests.** `ClyBrowserToolValidityTest` (29 tests on `isValidInContext:`), `ClyNotebookPageRecyclerTest` (8).

**Scenarios.**
- `TAB-01.a` Given a package with classes, when I select the package and no class, then the tabs are the package's (no class definition, no method editor).
- `TAB-01.b` Given a class, when I select it, then there is a class definition tab, a comment tab and a method-creation tab ("+ Inst. side method"), and no method editor.
- `TAB-01.c` Given a class with a method, when I select the method, then a method editor tab, titled with the method's icon and name, is added to the class tabs.
- `TAB-01.d` Given two methods selected, then a diff tab is added.
- `TAB-01.e` Given a test class with a `setUp`, when I select it, then a `setUp` tab is shown; when I select one of its test methods, both the method editor and the `setUp` tab are shown; when I select its `setUp` method, only the method editor on `setUp` is shown.

**Manual check.** None.

## TAB-02: Similar tabs are reused, not rebuilt (M)

**Behaviour.** When the new selection wants a tool that is already open on the same thing, the open tool stays as it is (text, scroll, cursor); it is not rebuilt.

**Code.** `ClyBrowserToolMorph>>isSimilarTo:` (same class by default; redefined by tools with a model, e.g. `ClyMethodCodeEditorToolMorph>>isSimilarTo:` compares the method, then selector and class); `ClyBrowserToolMorph>>isValidInContext:`; `ClyNotebookPageRecycler>>matchTools`.

**Edge cases.** The same method reached from another protocol or from "all methods"; the class comment when moving between methods of one class.

**Existing tests.** `ClyNotebookPageRecyclerTest`.

**Scenarios.**
- `TAB-02.a` Given a method editor open on a method, when I select another protocol that also lists that method and select it again, then the editor is the same tool (not rebuilt).
- `TAB-02.b` Given a class selected, when I select one of its methods, then the class definition tab is the same tool as before.

**Manual check.** None.

## TAB-03: Which tab is selected (M)

**Behaviour.** After each change the manager selects the tool with the highest **activation priority**. A tool's priority is its tab order, multiplied by 1000 when its class is in the **desired selection**: the tools the last *manual* selection in a pane asked for. So:

- a class opens on its **comment** (10.5 beats the definition's 10);
- a method opens its **editor** (20);
- selecting a protocol or a variable **by hand** selects the method-creation tab, even when a method stays selected (`methodGroupSelectionChanged` sends `skipCurrentDesiredSelection`);
- the method-creation tab has priority 0 when no method group is selected, so it never wins over the class tabs (11 otherwise); the `setUp` tab has −100, so it is never selected automatically;
- a tab the user selected by hand stays selected when another item is selected, if the new item has that tab too: clicking a tab **swaps the priorities** of the new and the old tab, for as long as the browser is open (method editors opt out).

**How to trigger.** Click in a pane; navigation (history, `selectMethod:`) is not manual and does not change the desired selection.

**Code.** `ClyBrowserMorph>>changeStateOf:by:` (sets `desiredSelection:` when `changesWasInitiatedByUser`); `ClyNotebookManager>>selectMainTool`, `activationPriorityOf:`, `restoreSelectedTools:`; `ClyMethodCreationToolMorph>>activationPriority`; `ClyNotebookManager>>pageChanged:` (a tab click: clears the desired selection, records the old tab in the history, then `swapPrioritiesBetween:and:` stores the swapped priorities in `selectionPriorities`, read by `overridenPriorityOf:`); `allowsDifferentActivationPriority` (false for method editors); `ClyBrowserToolMorph>>activationPriorityInNonActiveContext` (a tool of another context, see TAB-04, gets −∞ unless the user opened it).

**Edge cases.** Cmd-click on a tab selects several tabs (extra selection) and they stay selected after a change; a tool not in the current context.

**Existing tests.** None on the choice of tab.

**Scenarios.**
- `TAB-03.a` Given a class, when I select it by hand, then the Comment tab is selected.
- `TAB-03.b` Given a class with a method, when I select the method by hand, then its method editor is selected.
- `TAB-03.c` Given a method selected, when I select a protocol by hand, then the method-creation tab is selected.
- `TAB-03.d` Given I selected the class definition tab by hand, when I select another class, then the class definition tab stays selected.

**Manual check.** None.

**Notes.** `TAB-03.d` checked by hand on 2026-11-23; the Spec browser keeps this behaviour. A tab click is also a step of the navigation history (HIS).

## TAB-04: Dirty tabs stay (M)

**Behaviour.** An editor with unaccepted edits shows `*` before its title and an orange triangle in its corner. When another item is selected, the dirty editor **stays** (with a "!" icon, the `#uncommentedClass` icon, because it no longer matches the selection), and the new item's editor opens and is selected. Selecting the dirty item again removes the extra editor and the "!".

**Code.** `ClyBrowserToolMorph>>wantsStayInDifferentContext` (true when `hasUnacceptedEdits`); `updateDirtyState` → `ClyNotebookPageMorph>>markDirty:` (the `*`); `belongsToCurrentBrowserContext` (method editor: the browser still selects its method); `warnUserAboutChangedContext` → `warnUserAboutDifferentContext` (the "!").

**Edge cases.** Two dirty editors; a dirty class definition; closing a dirty tab asks to discard (`okToClose` → `confirmDiscardChanges`); the window close asks too (`ClyNotebookManager>>okToChange`).

**Existing tests.** None.

**Scenarios.**
- `TAB-04.a` Given a method editor, when I type without accepting, then its tab title starts with `*`.
- `TAB-04.b` Given a dirty editor on `x`, when I select `y`, then the `x` editor stays, marked as not in the current context, and a `y` editor is selected.
- `TAB-04.c` Given then, when I select `x` again, then the `y` editor is gone and the `x` editor is no longer marked.
- `TAB-04.d` Given a dirty editor, when I close its tab and refuse to discard, then the tab stays.

**Manual check.** The orange triangle and the "!" icon (look). Checked 2026-11-23.

## TAB-05: Tabs close when their model is removed (M)

**Behaviour.** When the method or class a tool shows is removed (here or elsewhere), its tab closes, even if it had been kept by TAB-04, unless it has unaccepted edits: then it stays, marked with the "!".

**Code.** `belongsToRemovedBrowserContext` (method editor: `localMethodNamed:` fails; it also **re-binds** the editor to the new compiled method when the method was recompiled); `wantsStayInDifferentContext`.

**Edge cases.** Removed while dirty (stays, see EDT-13); a method moved to another class.

**Existing tests.** None.

**Scenarios.**
- `TAB-05.a` Given a method editor, when the method or its class is removed from another tool, then its tab closes.
- `TAB-05.b` Given a method editor, when the method is recompiled elsewhere, then the editor stays and shows the new source.
- `TAB-05.c` Given a method editor with unaccepted edits, when its class is removed, then its tab stays, marked as not in the current context.

**Manual check.** None.

## TAB-06: Tabs are live (M)

**Behaviour.** A tool follows changes of its model made elsewhere: a method editor shows the new source of its method, a class definition the new definition.

**Code.** `attachToSystem` per tool (method editor: `browser system when: (ClyMethodChange of: editingMethod) send: #triggerUpdate`); `ClyBrowserToolMorph>>update`.

**Edge cases.** The change arrives while the editor is dirty (EDT-13).

**Existing tests.** None.

**Scenarios.**
- `TAB-06.a` Given a method editor on `x`, when `x` is recompiled elsewhere with another source, then the editor shows the new source.

**Manual check.** None.

## TAB-07: Tab actions (P)

**Behaviour.** Small icons at the top right of the selected tab run commands on its context: class tabs have "Opens special class menu" (red "!", the class refactoring menu), back, forward; method tabs have copy method name, versions, commit history (with Iceberg), back, forward.

**Code.** The `tabActions` interaction (6 catalogue rows); `ClyBrowserToolMorph>>addNotebookPageOn:` builds them with `ClyCommandGroupBuilder` and `ClyCommandGroupMenuRenderer>>notebookActionsOf:`.

**Scenarios.**
- `TAB-07.a` Given a method editor, then its tab offers the actions declared for `ClyMethod` in `tabActions`.

**Manual check.** That the icons show and react to a click. Checked 2026-11-23.

## TAB-08: Diff tool (P)

**Behaviour.** Two methods selected: a "Diff" tab, last, shows the first two side by side with word-level colours.

**Code.** `ClyMethodDiffToolMorph` (`build` uses `DiffMorph`; `belongsToCurrentBrowserContext` needs both methods selected).

**Scenarios.**
- `TAB-08.a` Given two methods selected, then the diff tab compares their sources.

**Manual check.** The colours (look).

## TAB-09: Tab order and closing (M)

**Behaviour.** Tabs are sorted by tab order, never by the user; each tab has a close button. A closed tab comes back at the next selection change that wants it.

**Code.** `ClyNotebookManager>>initialize` → `ClyNotebookMorph>>useSortedTabsBy:`; `ClyBrowserToolMorph class>>tabOrder`; `closeTab:` → `okToClose`, `tabDeleted:`.

**Scenarios.**
- `TAB-09.a` Given a method selected, then the tabs are in tab order: class creation, class definition, comment, method editor, method creation.
- `TAB-09.b` Given a tab closed by hand, when I select another item that wants it, then it is back.

**Manual check.** None.

## TAB-10: Tools are built when first shown (P)

**Behaviour.** A tab's content is built the first time the tab is shown, not when the tab is added. (The inventory said "built in background": that is no longer true in Pharo 15.)

**Code.** `ClyNotebookPageMorph newLabel:icon:provider:` with `[ self buildPageAndDecorate ]`; `ClyBrowserToolMorph>>isBuilt`; `whenReadyDo:` runs at once.

**Scenarios.**
- `TAB-10.a` Given a class selected, then its non-selected tabs are not built yet.

**Manual check.** None.

## TAB-11: Tool decorations by plugins (P)

**Behaviour.** Browser plugins decorate tools when they are created: the critics plugin adds the critiques to editors (EDT-12).

**Code.** `ClyBrowserMorph>>decorateTool:` → each plugin's `decorateTool:`; `ClyBrowserToolMorph>>applyDecorations`; `ClyBrowserToolDecorator` subclasses (`ClyCriticDecorator`).

**Scenarios.** Covered by EDT-12.

## TAB-12: Per-tool status bar (M)

**Behaviour.** Under each tool, a status bar that the tool fills: method editors put the cursor position, the protocol editor and checkboxes (EDT-03, EDT-08); the class definition's stays empty.

**Code.** `ClyBrowserToolMorph>>buildStatusBar`, `fillStatusBar` (per tool), `rebuildStatusBar` (on context change, see bug B-01).

**Scenarios.**
- `TAB-12.a` Given a method editor, then its status bar shows the protocol of the method.

**Manual check.** None.

## TAB-13: Third-party tabs (M)

**Behaviour.** Other projects add tabs: Dependencies (`DABrowserToolMorph`, package), Baseline map (`RSMapBrowserToolMorph`, `BaselineOf` subclasses, Roassal), rich comments (`ClyRichTextClassCommentEditorToolMorph`, `ClyPackageRichTextCommentEditorToolMorph`, BeautifulComments). They are Morphic tools of their own packages.

**Code.** Their `tabs` entries in the catalogue; the same `ClyBrowserToolMorph` protocol.

**Scenarios.**
- `TAB-13.a` Given a package selected, then a Dependencies tab is shown.

**Notes.** The Spec browser hosts them as Morphic tools for now; they must become Spec presenters before Morphic tools stop being accepted (pain point [P-05](../../pain-points.md#p-05-tools-tabs-are-morphs-also-outside-calypso)).

## TAB-14: Maximize the tools (P)

**Behaviour.** Double-clicking a tab header hides the four panes and gives the window to the tools; double-clicking again restores them.

**Code.** `ClyNotebookManager>>addTool:` (`onDoubleClick: [ browser toggleFullWindowTabs ]`); `ClyBrowserMorph>>toggleFullWindowTabs` (moves the notebook between the window and the tool panel).

**Scenarios.**
- `TAB-14.a` Given a browser, when I maximize the tools, then the panes are hidden; when I do it again, they are back.

**Manual check.** The double click itself (checked 2026-11-23).
