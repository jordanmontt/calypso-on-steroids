# CLS: class pane

Status: **reviewed** 2026-11-25 (manual checks done for CLS-09, 11). Code read on Pharo 15 build 145, 2026-11-24.

The second pane: the classes of the selected packages, or a hierarchy around the selected class. Its selection decides the method groups and methods shown (SEL-05).

- Built by `ClyFullBrowserMorph>>newClassView`: a tree with a substring filter, pre-expanded items that can be collapsed, rows named by `specifyClassItemNameOn:for:`, and `#classSelectionChanged`.
- Its mode is one of the class-view mode commands in the toolbar: `ClySwitchToFlatClassesCommand` ("Flat"), `ClySwitchToFullHierarchyCommand` ("Hier."), `ClySwitchToInheritedTraitsCommand` ("Traits"), `ClySwitchToTraitUsersCommand` ("Users"). They show only when a class is selected.

## CLS-01: "Flat": the classes of the selected packages (M)

**Behaviour.** Despite its name, a tree: the classes of the selected packages or tags, each nested under its superclass when both are listed, pre-expanded. The classes the packages extend come after them, in gray. With several packages selected, each class shows its full name. Selecting a package always switches back to this mode.

**Code.** `ClyFullBrowserMorph>>switchToFlatClasses` (`prepareClassQueriesFrom:in:` per selected item type, `ClyExtensionLastSortedClassResult hierarchical`); `specifyClassItemNameOn:for:` (full name, extension colour); `packageSelectionChanged`.

**Edge cases.** Traits; a class whose superclass is in another package (not nested); a tag and a package of another project selected together.

**Existing tests.** `ClyExtensionLastSortedClassesTest` (the sorting, as a model test).

**Scenarios.**
- `CLS-01.a` Given a package with A and its subclass B, when I select it, then B is listed under A.
- `CLS-01.b` Given a package that extends class E, when I select it, then E is listed after the package's own classes.

**Manual check.** None.

## CLS-02: "Hier.": the full hierarchy of the selected class (M)

**Behaviour.** From `ProtoObject` down to the selected class, and the class's subclasses, across packages. ⌘H switches to it.

**Code.** `ClySwitchToFullHierarchyCommand` (toolbar, ⌘H); `ClyFullBrowserMorph>>switchToFullClassHierarchy` (`asFullHierarchyScope`, `ClyHierarchicallySortedClassesResult`).

**Scenarios.**
- `CLS-02.a` Given class B (subclass of A, subclass of `Object`) selected, when I switch to Hier., then the pane shows `ProtoObject`, `Object`, A, B and B's subclasses, nested, and B is still selected.

**Manual check.** None.

## CLS-03: Trait hierarchies (P)

**Behaviour.** "Traits" shows the traits the selected class uses; "Users" shows the classes using the selected trait. Each button is shown only when it applies.

**Code.** `ClySwitchToInheritedTraitsCommand>>canBeExecuted` (`isSelectedClassUsesTraits`), `ClySwitchToTraitUsersCommand>>canBeExecuted` (`isTraitSelected`), package `Calypso-SystemPlugins-Traits-Browser`.

**Scenarios.**
- `CLS-03.a` Given a class using trait T selected, when I switch to Traits, then T is listed.
- `CLS-03.b` Given trait T selected, when I switch to Users, then the classes using T are listed.

**Manual check.** None.

## CLS-04: The package of a class follows silently (M)

**Behaviour.** When a class is selected outside the flat mode (Hier., Traits, Users), its package (or tag) is selected in the package pane, without changing the class pane and without a history step.

**Code.** `ClyFullBrowserMorph>>classSelectionChanged` → `silentlySelectPackageOfSelectedClass` (SEL-04).

**Scenarios.** Covered by `SEL-04.a`.

## CLS-05: Selecting an extended (gray) class (M)

**Behaviour.** Selecting a class that the selected package extends shows its method groups (never variables) with the extension group of that package, selects that group, and lists only the extension methods. In Projects mode, the groups of every package of the project that extends the class are added.

**Code.** `ClyFullBrowserMorph>>adoptForExtendedClass` (`ClyExtendedClassTag`, `ClyGroupedExtendingPackagesResult`), `selectCurrentExtensionMethodGroup`.

**Scenarios.**
- `CLS-05.a` Given package P extending class E, when I select E in P, then the extension group of P is selected and only P's methods of E are listed.

**Manual check.** None.

## CLS-06: Class row (M)

**Behaviour.** The class icon (`C`, `Σ` for traits…), italic for abstract classes, struck out when deprecated, gray when extended, and the test result circle instead of the icon for test classes.

**Code.** `specifyClassItemNameOn:for:` and the class decorators (DEC).

**Scenarios.** In the DEC sheet.

**Manual check.** The look of each kind of row.

## CLS-07: Class filter (M)

**Behaviour.** A substring filter under the pane.

**Code.** `enableFilter` in `newClassView` (FLT).

**Scenarios.**
- `CLS-07.a` Given `Point` typed in the class filter, then only classes whose name contains `Point` are listed.

**Manual check.** None.

## CLS-08: Class commands (M)

**Behaviour.** The class menu and shortcuts: Browse, Class refs. (⌘N), rename (⌘R), Remove (⌘X), move to package (⌘M,⌘C), Generate accessors (⌘G,A), Abstract instance variables (⌘A,A), New class / trait / test class, Jump to test class (⌘G,J), Realize class, Refactorings ▸, Scopes ▸, Extras ▸; the class refactorings menu as a tab action (TAB-07).

**Code.** Catalogue sections `ClyClass`, `ClyFullBrowserClassContext` (`calypsoSystemToolsFullBrowserCommandsIn:`).

**Scenarios.** Covered by C3.

## CLS-09: Find class (M)

**Behaviour.** ⌘F (a shortcut of the whole browser; the method pane has its own find, MTH-06), or "Find class" in the package menu, opens the Spec dialog "Choose class" (Substring, Regexp, Exact, Match case) and selects the chosen class. Today it lists every class of the image (bug B-05); the Spec browser lists only the classes of the selected packages.

**Code.** Catalogue: `ClyFullBrowserGlobalContext` (⌘F), `ClySystemBrowserContext` (menu, shown only in the package pane by `isAvailableInMenuOf:`); `ClyFindClassCommand>>prepareFullExecution` (`context requestSingleClass:`), `executeRefactoring` (`browser selectClass:`).

**Scenarios.**
- `CLS-09.a` Given package P selected, when I find a class, then the dialog lists only the classes of P (B-05: fails on Morphic today).
- `CLS-09.b` Given the dialog, when I choose class C, then C is selected in the browser.

**Manual check.** ⌘F (T-09). Checked 2026-11-25, with bug B-05 (every class of the image listed).

## CLS-10: Drag classes (P)

**Behaviour.** Dragging classes onto a package or tag moves them (PKG-07).

**Scenarios.** Covered by `PKG-07.a`.

## CLS-11: Double click spawns a browser (P)

**Behaviour.** A double click on a class selects it with the first click and opens a new browser on it with the second; the new browser can go back to this one (HIS-04).

**Code.** `ClySpawnFullBrowserCommand` (catalogue: `doubleClick` on `ClyFullBrowserContext`), which acts on the browser's selection (B3 finding).

**Scenarios.**
- `CLS-11.a` Given class C, when I double click it, then a new browser opens on C.

**Manual check.** The double click (T-09). Checked 2026-11-25.
