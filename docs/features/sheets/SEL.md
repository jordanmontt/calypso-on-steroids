# SEL: selection

Status: **reviewed** 2026-11-24 (manual checks done for SEL-03, 06). Code read on Pharo 15 build 145, 2026-11-24.

How the four panes select, what they keep when their items change, and how a selection drives the rest of the browser. These rules are invisible but the browser feels wrong without them; refactoring R-02 moves them out of the Morphic views so a Spec pane can use them.

- Each pane is a `ClyQueryViewMorph`. It holds three selections of the same kind (`ClyDataSourceSelection`, items of its data source): `selection` (what is selected), `highlighting` (SEL-03), and `desiredSelection` (a `ClyDesiredSelection`, SEL-01).
- `changesWasInitiatedByUser` tells a user's click from a change made by code.
- A pane tells the browser through its `navigationSelector` (`#packageSelectionChanged`, `#classSelectionChanged`, `#methodGroupSelectionChanged`, `#methodSelectionChanged`), sent from `ClyQueryViewMorph>>selectionChanged`.

## SEL-01: Desired selection (M)

**Behaviour.** A pane remembers the user's last selection *by hand* and, each time it gets new items, selects again the same items or, failing that, items of the same kind with the same name. So the method `x` stays selected when moving from `Point` to another class that has `x`; a method comes back after a round trip to the class side; a package comes back after Projects mode. Selections made by code do not replace what the user asked for: after a class without `x`, the next class with `x` selects it again. When the restored items are the same as before, no selection change is signalled. The method-group pane is the exception: it never restores, so changing class drops the protocol selection and shows all methods.

**How to trigger.** Select by hand, then select something in a pane to the left.

**Code.**
- `ClyQueryViewMorph>>updateSelection`: on a user change, `desiredSelection := selection asDesiredSelection`; otherwise it only updates its "same as current" flag.
- `ClyQueryViewMorph>>setUpDataSource:` → `showDesiredSelection` → `ClyDesiredSelection>>restoreCurrentSelection:` (same items: silently; otherwise `findItemsSimilarTo:`).
- `ClyBrowserQueryResult>>findItemsSimilarTo:` → `ClyBrowserItem>>isSimilarTo:` (same type, and same name or equal).
- `ClyFullBrowserMorph>>newMethodGroupView` sends `neverRestoreSelection`.

**Edge cases.** Several items selected (each restored by name); a class extended by the selected package (the extension group is selected instead, CLS-05); a filter typed in the pane (FLT).

**Existing tests.** None on restoring by name.

**Scenarios.**
- `SEL-01.a` Given method `x` selected by hand in class A, when I select class B which has `x`, then `x` is selected in B. → `ClySpSelectionTest>>testSameSelectorStaysSelectedWhenChangingClass`
- `SEL-01.b` Given then, when I select class C which has no `x`, then no method is selected; when I select class D which has `x`, then `x` is selected in D. → `ClySpSelectionTest>>testSelectorComesBackAfterAClassWithoutIt`
- `SEL-01.c` Given a method selected on the instance side, when I switch to the class side and back, then the method is selected again.
- `SEL-01.d` Given a package selected, when I switch to Projects and back to All Packages, then the package is selected again.
- `SEL-01.e` Given a protocol selected in class A, when I select class B which has the same protocol, then no protocol is selected and all methods of B are shown.

**Manual check.** `SEL-01.e` in the image (read from the code only).

## SEL-02: Selection survives item changes (M)

**Behaviour.** When the items of a pane change (a method added or removed elsewhere, a tree expanded or collapsed), the same objects stay selected; a removed object is no longer selected. Unlike SEL-01, an update never moves the selection to a *similar* item. The desired selection keeps its items even when they are removed, so they come back if they reappear. Left and right arrows collapse and expand the selected tree items.

**Code.** `ClyQueryViewMorph>>itemsChangedIn:` → `updateSelectedItemsOf:` → `ClyDesiredSelection>>updateItemsWhichBelongsTo:`, `restoreCurrentSelectionAfterUpdate:` (`findItemsWith:` the actual objects); `selectionRejected:` (arrows).

**Existing tests.** `ClyQueryViewStateTest`, `ClyQueryViewMorphShouldExpandTest` (expansion, not selection after an update).

**Scenarios.**
- `SEL-02.a` Given method `x` selected, when another method is added to the class elsewhere, then `x` is still selected.
- `SEL-02.b` Given method `x` selected, when `x` is removed elsewhere, then no method is selected.
- `SEL-02.c` Given then, when `x` is compiled again elsewhere, then `x` is selected again.

**Manual check.** None.

## SEL-03: Highlighting (P)

**Behaviour.** When methods are selected, the method groups that contain them are highlighted (light background, not selected): their protocol, the visibility rows, and in variables mode the variables they use. This is the only use of highlighting.

**Code.** `ClyFullBrowserMorph>>methodSelectionChanged` → `methodGroupView highlightItemsWhich:` (`includesMethod:`); `ClyHighlightingSelection`.

**Scenarios.**
- `SEL-03.a` Given method `x` in protocol `accessing` selected with no protocol selected, then `accessing` is highlighted and not selected.

**Manual check.** The highlight colour (look). Checked 2026-11-24.

## SEL-04: Silent selection (M)

**Behaviour.** Some selections are made without telling the browser (no downstream update, SEL-05) or without a history step (HIS-02): the package of a class selected in hierarchy mode, the restore of history states, updates after system changes.

**Code.** `ClyQueryViewMorph>>ignoreNavigationDuring:` (sets `navigationSelector` to nil for the block); `ClyBrowserMorph>>ignoreNavigationDuring:` (no history); senders `silentlySelectPackageOfSelectedClass`, `itemsChangedIn:`.

**Scenarios.**
- `SEL-04.a` Given hierarchy mode, when I select a class of another package, then its package is selected in the package pane and the class pane still shows the hierarchy.

**Manual check.** None.

## SEL-05: Selection drives the panes to its right (M)

**Behaviour.** Package → its classes (switching to flat mode); class → its method groups, with all its methods sorted by selector; method group → its methods; no group → all methods; methods → highlighting (SEL-03). Every change updates the tabs (TAB-01), the title and the history (HIS-02) once, however many panes changed.

**Code.** `ClyFullBrowserMorph>>packageSelectionChanged` (`switchToFlatClasses`), `classSelectionChanged` (`changeMethodGroupQueryBy:`, `selectCurrentExtensionMethodGroup`), `methodGroupSelectionChanged` (`showQueries:as:`, `showAllMethods`), `methodSelectionChanged`; `ClyBrowserMorph>>changeStateBy:` (one title, history and tools update per change).

**Scenarios.**
- `SEL-05.a` Given a package, when I select it, then the class pane lists its classes.
- `SEL-05.b` Given a class, when I select it, then the group pane lists its protocols and the method pane all its methods, sorted by selector.
- `SEL-05.c` Given a class selected, when I select a protocol, then the method pane lists only its methods.

**Manual check.** None.

## SEL-06: Deselection (M)

**Behaviour.** Every pane of the full browser can be deselected (⌘-click on the selected item), a feature few users know. Deselecting the method group shows all methods again.

**Code.** `ClyQueryViewMorph>>initializeTable` (`allowsDeselection: true`); only the retired query browser denies it.

**Scenarios.**
- `SEL-06.a` Given a protocol selected, when I deselect it, then all methods of the class are shown.

**Manual check.** ⌘-click deselects (T-09). Checked 2026-11-24.

## SEL-07: Ensure a selection after updates (dropped)

**Behaviour.** A pane that does not allow deselection selects an item (the first, or near the last desired one) when it gets items. No pane of the full browser is in that case, so there this only scrolls the selection into view.

**Code.** `ClyQueryViewMorph>>ensureSelectedItemIfNeeded`, `ensureSelectedItem`, `ensureVisibleSelection`.

**Scenarios.** None in the full browser.

**Notes.** Only the query browser (retired, D-08) uses it. Dropped on 2026-11-24 (D-06).
