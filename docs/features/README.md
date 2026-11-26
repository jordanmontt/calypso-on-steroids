# Calypso feature inventory

This is the reference list of what the Calypso system browser does, so that the Spec version keeps all of it. Every feature has a stable ID. Acceptance tests (see the [testing plan](../testing-plan.md)), PRs and issues refer to these IDs, and a feature is only "done" in the Spec browser when its acceptance scenario passes there.

- **Sources:** the live image (Pharo 15.0 build 126, sha `0aaea4b`), inspected on 2026-11-16 through the Pharo MCP. Two passes:
  1. reading the code: class comments, the 397 command declarations (`<calypsoCommands>`), settings, tests, and the Pharo guide `doc/Calypso/Commands.md`;
  2. **using the browser**: driving the real Morphic UI with mouse events and screenshots. See the [walkthrough](walkthrough.md), with 22 screenshots.
- **Companion files:** [walkthrough.md](walkthrough.md) (what each screen shows, bugs found), [command-catalogue.md](command-catalogue.md) (all command, tab and decorator declarations, generated).

## How to read the tables

| Column | Meaning |
|---|---|
| ID | Stable identifier, `AREA-nn`. Never reuse an ID; mark removed features as *dropped* with the reason. |
| Feature | What the user can do or see. |
| Hidden behaviour / notes | The non-obvious part, the one easy to lose in a rewrite. |
| Implementation | Where it lives today, to read before reimplementing. |
| Seen | How the feature was verified: **click** = exercised in the running browser (see walkthrough), **code** = read in the code only, **hand** = checked by hand by you on 2026-11-23 (keyboard and drag and drop, which could not be simulated; see the walkthrough's last table), **manual** = still to check by hand. |
| Tier | **M** = needed for the minimum usable Spec browser, **P** = needed for parity, **X** = contributed by a package outside Calypso and not needed for the minimum browser (external features you chose for it are **M**), **Dropped** = not in the Spec browser, see [Dropped features](#dropped-features). Decided with you on 2026-11-23 (D-07). |

## What the full browser is

The full browser (`ClyFullBrowserMorph`) is a window with:

1. a **navigation panel** of four panes: packages, classes, method groups (or variables), methods. Each pane is a `ClyQueryViewMorph` (a FastTable) showing the result of a Calypso query;
2. a **toolbar** below the panes whose content depends on the selection: package modes (All Packages / Scoped View / Projects), class modes (Flat / Hier., plus Traits / Users for trait users), meta-level (Inst. side / Class side), Methods / Vars, and buttons (Class refs., Implementors, Senders);
3. a **notebook of tools** (tabs) chosen from the selection: class definition, comment, method editor, method creation, class creation, test `setUp`, diff, and tabs contributed by other packages (dependencies, baseline map, rich comments). Each tool may have a status bar.

In Pharo 15, **Senders / Implementors / References open `StMethodBrowser`** (NewTools, already written in Spec), not Calypso's own query browser `ClyQueryBrowserMorph`, which is now only reached through old entry points (see QRY).

---

## 1. Browser window and shell (BRW)

| ID | Feature | Hidden behaviour / notes | Implementation | Seen | Tier |
|---|---|---|---|---|---|
| BRW-01 | Open a full browser (world menu, `Smalltalk tools browser open`) | Initial state: package view or project view (SET-01). New browsers start with the last package filter (PKG-04). | `ClyFullBrowserMorph class>>open`, `registerToolsOn:` | click | M |
| BRW-02 | Open on a class / method / package (`openOnClass:`, `openOnClass:selector:`, `openOnMethod:`, `openOnPackage:`, `openOnClass:selector:highlight:`) | Opening on a class selects its **tag** in the package pane (or the package if untagged) and expands the package. | `ClyFullBrowserMorph class` | click | M |
| BRW-03 | Window title follows the selection | "Package: X", "Class: X", "Class: X class", "Method: X>>y", "Current image" when nothing is selected in projects mode. | `buildTitleFromSelections` | click | M |
| BRW-04 | Close the browser; confirm when there are unsaved edits | Spec modal "Please confirm — Changes have not been saved. Is it OK to discard changes?" No / Yes. ⌘W closes too. | `okToChange`, `confirmDiscardChanges` | click | M |
| BRW-05 | Spawn a browser from the current state (⌘B, "Browse", double click on a class) | Opens at +20 px with the default size, with the selection of the source. Its history starts with an across-window state (HIS-04). | `ClySpawnFullBrowserCommand`, `spawnBrowser:withState:` | click | M |
| BRW-06 | Window groups (several browsers in one tabbed window) | Only created by `ClyQueryBrowserMorph>>openInWindow:`, which normal use no longer reaches in Pharo 15. **Candidate to drop** (decision D-06). | `ClyGroupWindowMorph`, `createWindowGroupFrom:` | code | Dropped |
| BRW-07 | Resizable panes and tool area | Splitters between panes and between panes and tools. | `ClyBrowserMorph>>layoutChildren` | click | M |
| BRW-08 | Browser plugins | Auto-activated `ClyBrowserPlugin` subclasses decorate tools (critics panel) and enable families of decorators. | `ClyBrowserPlugin` and subclasses | code | P |
| BRW-09 | Scoped View | **Scopes the browser immediately to the selected packages** (no dialog); only they stay in the package list. "Set up scope" / "Create scope from selected package(s)" / "Scopes ▸" in menus manage named scopes. | `ClySwitchToScopedViewCommand`, `ClySwitchToScopedModeCommand`, `setUpScopedModeWith:` | click | P |
| BRW-10 | Browse another environment (Ring) | Iceberg "Browse repository / commit / package" opens Calypso on a Ring model. | `ClyRing2Environment` | code | M |
| BRW-11 | Keyboard focus between panes | Right / Left arrows move to the next / previous pane. | `ClySwitchFocusTo*BrowserPaneCommand` | hand | M |
| BRW-12 | Toolbar depends on the selection | No class selected: only package modes and meta-level. Class selected: + Flat/Hier., Methods/Vars, Class refs. Method selected: + Implementors, Senders. Rendered as radio-like labels and link-style buttons with icons. | `ClyToolbarMorph` | click | M |

## 2. Package pane (PKG)

| ID | Feature | Hidden behaviour / notes | Implementation | Seen | Tier |
|---|---|---|---|---|---|
| PKG-01 | All packages, sorted | Deprecated packages struck out; packages with tags have an expand triangle; package icon. | `newPackageView`, `ClyAllPackagesQuery` | click | M |
| PKG-02 | Tags as children of a package | Children: "Uncategorized" (blue, virtual, only when tags exist and some classes have none), the tags, "Extensions" (blue, virtual, only when the package extends classes). Selecting a tag filters the classes. | `Package -> #prepareClassGroupQueryFrom:in:` | click | M |
| PKG-03 | Projects mode | Baselines (108 here) with a project icon; project → packages → tags. **The package selection is lost** in projects mode and **restored** when going back to All Packages. | `ClySwitchToProjectsCommand`, `ClyProjectTableIndentationDecorator` | click | P |
| PKG-04 | Regex filter, remembered across browsers | Applied after a short typing delay; keeps the selection. The text is stored in the class variable `DefaultPackageFilter` on each change and **new browsers start with it**. | `enableFilterUsing: ClyRegexPattern new`, `updateDefaultPackageFilter` | click | M |
| PKG-05 | Package commands | New package (⌘K,P), rename (⌘R), remove (⌘X), duplicate (⌘C), new tag, commit (⌘S), browse critiques, browse dependencies, run tests (⌘T and icon), Scopes, Extras (promote/demote tag, file out, recompile, inspect). | catalogue: `Package`, `ClyFullBrowserPackageContext` | click (menu) | M |
| PKG-06 | Tag commands | Browse, Rename, New tag, Remove, Extras ▸. | `ClyRenamePackageTagCommand`, `ClyRemoveClassGroupCommand` | click (menu) | P |
| PKG-07 | Drop classes on a package or tag | Hover a collapsed node during a drag to expand it after a delay (SET-04). | `ClyMoveClassToGroupCommand`, `isReadyToExpandForDrop:` | hand | P |
| PKG-08 | Drop methods or protocols on a package (make extension) | `SycMoveMethodsToPackageCommand`, `ClyMoveMethodGroupsToPackageCommand`. | catalogue | hand | P |
| PKG-09 | Package comment tab | Rich text (BeautifulComments). | `ClyPackageRichTextCommentEditorToolMorph` | click | M |
| PKG-10 | Dependencies tab | Dependency analyser, first tab (order -10), kept when a class of the package is selected. | `DABrowserToolMorph` | click | M |
| PKG-11 | Selecting a package opens the class-creation tab | The "New class" tab is selected, template with `package:` (and `tag:`) filled. In projects mode with nothing selected the package is `_Unpackaged`. | `ClyClassCreationToolMorph` | click | M |

## 3. Class pane (CLS)

| ID | Feature | Hidden behaviour / notes | Implementation | Seen | Tier |
|---|---|---|---|---|---|
| CLS-01 | "Flat" mode (default): classes of the selected packages/tags **as a local hierarchy** | Despite its name it is a tree: classes of the package are nested under their superclass when both are in the package (`ClyItemLocalHierarchyProperty`), pre-expanded, collapsible. Classes **extended** by the package are listed **gray, after** the package's classes. Traits sorted first. | `newClassView`, `ClyHierarchicallySortedClassesResult`, `ClyExtensionLastSortedClassResult` | click | M |
| CLS-02 | "Hier." mode: full hierarchy of the selected class | From `ProtoObject` down to the class and its subclasses, across packages. | `ClySwitchToFullHierarchyCommand` | click | M |
| CLS-03 | Trait hierarchies ("Traits" / "Users") | Shown only for classes using traits / traits. | `ClySwitchToInheritedTraitsCommand`, `ClySwitchToTraitUsersCommand` | code | P |
| CLS-04 | Selecting a class from another package selects its package silently | No navigation event, no history entry. | `silentlySelectPackageOfSelectedClass` | code | M |
| CLS-05 | Selecting an extended (gray) class | Switches to the meta-level of the extension and **selects the extension group of the current package** (shown bold); only extension methods are listed. | `adoptForExtendedClass`, `selectCurrentExtensionMethodGroup` | click | M |
| CLS-06 | Class row display | `systemIcon` (`C`, `Σ`…), abstract classes italic, deprecated struck out, extended classes gray, test classes show their **test result circle instead of the icon**. | decorators, `specifyClassItemNameOn:for:` | click | M |
| CLS-07 | Class filter | Substring filter under the pane. | `enableFilter` | code | M |
| CLS-08 | Class commands | See the captured menu (walkthrough §12): Browse, Browse test class, Class refs. (⌘N), Show trait users, rename (⌘R, two variants), Migrate references, Scopes ▸, Realize class, Abstract inst vars (⌘A,A), Generate accessors (⌘G,A), New trait / class / test class, Jump to test class (⌘G,J), Remove (⌘X), Refactorings ▸, Extras ▸. | catalogue `ClyClass`, `ClyFullBrowserClassContext` | click (menu) | M |
| CLS-09 | Find class (⌘F) | **Spec** modal "Choose class": filter with Substring / Regexp / Exact / Match case. Today it lists every class of the image (bug B-05); the Spec browser lists only the classes of the selected package(s). | `ClyFindClassCommand` | click | M |
| CLS-10 | Drag classes onto packages/tags | | `ClyMoveClassToGroupCommand` | hand | P |
| CLS-11 | Double click spawns a browser on the class | First click selects, second spawns. | `ClySpawnFullBrowserCommand` | click | P |

## 4. Method-group pane: protocols, virtual groups, inherited methods, variables (MGP)

| ID | Feature | Hidden behaviour / notes | Implementation | Seen | Tier |
|---|---|---|---|---|---|
| MGP-01 | Protocols of the selected classes | Multi-selection; no selection = all methods. Protocol icons from names: `private*` red square, `initial*`, `class initial*`, `releas*`, `finali*` "protected" diamond. | `newMethodGroupView`, `ClyMethodsInProtocolGroup>>decorateTableCell:of:` | click | M |
| MGP-02 | Virtual groups | "instance side"/"class side" (all methods, expandable), "extensions" (folder, expandable to `*Package` groups), unclassified, abstract, overridden, overrides, should be implemented, deprecated (struck out), FFI calls, flags (orange "!"), breakpoints, failed tests, expected failures, undeclared; async groups computed in background. Blue text for virtual groups. | `ClyAllMethodGroupsQuery`, `*MethodGroupProvider`s | click | M (core), P (plugins) |
| MGP-03 | **Inherited methods: checkboxes in the list** | Expanding "instance side" lists the superclass chain, indented, each with a checkbox (the class itself ticked). Ticking a superclass adds its methods (italic, "(Superclass)" suffix) and protocols. Then the "instance side" row gains a hierarchy icon and a **second checkbox** ("show all inherited"). The visibility is kept when switching meta-level. The checkboxes are created by domain objects (`ClyFullVisibilityLevel`, `ClySuperclassVisibilityLevel`). | `ClyMethodVisibilityMorph`, `ClyInheritedMethodGroup>>decorateTableCell:of:` | click | M |
| MGP-04 | Instance side / class side | Class side: title "Class: X class", all groups and methods **bold**, visibility kept, the previous selection on each side is restored when coming back. | `ClySwitchToClassSideCommand`, `ClyClassSideBoldTableDecorator` | click | M |
| MGP-05 | Variables mode ("Vars") | "instance side" row, then per defining class a gray header and its variables. Selecting a variable shows the methods referencing it. The variables used by the selected method are highlighted. Order of classes: setting SET-05. | `ClySwitchToVariablesCommand`, `ClyGroupedInstanceVariablesResult` | click | M |
| MGP-06 | Variable commands | Rename ⌘R, remove ⌘X, references ⌘N, writers ⌘M, inspect value ⌘I / double click, push up/down, accessors, protect, merge, move to class side, debug points (break/watch on read/write/access). | catalogue `ClyFullBrowserVariableContext` | code | P |
| MGP-07 | Protocol commands | Browse, Show in method browser (also double click), Rename, New protocol, Convert to extension, Categorize all uncategorized, Remove empty protocols, Remove. | catalogue `ClyFullBrowserMethodGroupContext` | click (menu) | M |
| MGP-08 | Drop methods on a protocol / extension group / all-methods group | Reclassify. | `ClyMoveMethodsToGroupCommand` | hand | P |
| MGP-09 | Drop a protocol on a class | Moves group and methods. | `ClyMoveMethodGroupToClassCommand` | hand | P |
| MGP-10 | "see class side" link | Protocols/methods named "see class side" get a forward-arrow **button** that switches to the class side. | `ClyClassSideLinkTableDecorator` | code | P |
| MGP-11 | Invert hierarchy | Reverses the order of the visibility / variable class list (menu "Extras ▸ Invert hierarchy"). | `ClyInvert*Command` | code | P |

## 5. Method pane (MTH)

| ID | Feature | Hidden behaviour / notes | Implementation | Seen | Tier |
|---|---|---|---|---|---|
| MTH-01 | Methods of the selected groups or variables | Binary selectors first, then alphabetical. Extension methods from other packages in gray. | `ClySortMethodBySelectorFunction` | click | M |
| MTH-02 | Method row display | Override arrows (up = overrides, down = overridden, both), abstract italic + icon, trait method icon, halt/breakpoint, FFI, flag, undeclared (red), deprecated (struck out), test circle (clickable), class script run icon, inherited methods italic with "(Class)". | decorators | click | M |
| MTH-03 | Method commands | Captured menu, walkthrough §3. Shortcut labels including chords (⌘H,⌘J). | catalogue `ClyMethod` | click (menu) | M |
| MTH-04 | Run / debug tests | Click the circle: runs, turns green/yellow/red, notification. ⌘T, ⌘D, ⇧⌘D. Covering tests for non-test methods. | `ClySUnit*` | click | P |
| MTH-05 | Run class scripts from the row | Icon on `initialize`, `<script>`, `<example>`, `<sampleInstance>` class-side methods. | `ClyRunClassScriptCommand` | click | P |
| MTH-06 | Find method (⌘F) | | `ClyFindMethodInBrowserCommand` | hand | P |
| MTH-07 | Drag methods | Onto class, package, protocol. | catalogue | hand | P |
| MTH-08 | Multi-selection | Two methods: first editor kept, Diff tab added last (TAB-08). | `ClyDataSourceSelection` | click | M |

## 6. Selection semantics (SEL) — hidden, critical

| ID | Feature | Hidden behaviour / notes | Implementation | Seen | Tier |
|---|---|---|---|---|---|
| SEL-01 | **Desired (symbolic) selection** | The view remembers the user's last manual selection and re-selects the same item, or one with the same name, when its items change: same selector across classes, previous method after a class-side round trip, previous package after projects mode. Restoring is silent when the item is the same. | `ClyDesiredSelection` | click | M |
| SEL-02 | Selection survives tree changes | Expand/collapse, items added/removed by system changes. | `updateSelectedItemsOf:` | code | M |
| SEL-03 | **Highlighting** (secondary selection) | When methods are selected, the groups containing them are highlighted: their protocol, the visibility rows, the variables they use in Vars mode. The only use of highlighting. | `ClyFullBrowserMorph>>methodSelectionChanged`, `ClyHighlightingSelection` | click | P |
| SEL-04 | Silent selection | Changes without navigation events or history entries (`ignoreNavigationDuring:`), used by CLS-04, history restore, system updates. | `ignoreNavigationDuring:` | code | M |
| SEL-05 | Selection drives everything downstream | Package → classes; class → groups (scope = classes × meta-level × visibility); groups → methods; any → tabs, toolbar, title, history. | `*SelectionChanged`, `changeStateBy:` | click | M |
| SEL-06 | Deselection | Allowed where "nothing" has a meaning (no group = all methods). | `allowsDeselection:` | code | M |
| SEL-07 | Ensure selection after updates | `ensureSelectedItemIfNeeded` when a view becomes non-empty after a change. | `ClyQueryViewMorph` | code | Dropped |

## 7. Navigation history (HIS)

| ID | Feature | Hidden behaviour / notes | Implementation | Seen | Tier |
|---|---|---|---|---|---|
| HIS-01 | Back / forward | Tab-action arrows, Alt+Left / Alt+Right (also in editors). Mode switches (vars, side) are entries. | `ClyNavigationHistory` | click (API + buttons), manual (keys) | M |
| HIS-02 | What is recorded | Not the silent changes, not the restores. | `recordNavigationState:` | code | M |
| HIS-03 | History holds no query results | | `ClyNavigationHistory` | code | P |
| HIS-04 | Across-window history | "Back" in a spawned browser **closes it and re-activates the original window** (re-creates it if closed). | `ClyAccrossWindowNavigationState` | click | P |
| HIS-05 | Pluggable history class | Setting. | `settingsNavigationHistoryOn:` | code | Dropped |

## 8. Tools and tabs (TAB)

| ID | Feature | Hidden behaviour / notes | Implementation | Seen | Tier |
|---|---|---|---|---|---|
| TAB-01 | Tabs chosen from the selection | Package: Dependencies, Comment, New class. Class: (Dependencies), definition, Comment, (setUp), method creation. Method: + method editor. Two methods: + Diff. | `ClyNotebookManager>>updateTools` | click | M |
| TAB-02 | Similar tabs are reused, not rebuilt | | `ClyNotebookPageRecycler` | code | M |
| TAB-03 | **Which tab is selected** | Highest activation priority among the "desired" tabs. Consequences seen: a class opens on its **Comment** (order 10.5 > definition 10); a method opens its editor; **selecting a protocol or variable by hand switches to the method-creation tab** even if a method stays selected; the user's manual tab choice is kept when moving to another item of the same kind. | `ClyNotebookManager` (desiredSelection) | click | M |
| TAB-04 | Dirty tabs stay | Title `*name`, **orange corner triangle**; when another method is selected the dirty tab stays with a "!" icon and a second editor opens; going back clears the "!" and removes the extra editor. | `belongsToCurrentBrowserContext`, `updateDirtyState` | click | M |
| TAB-05 | Tabs close when their model is removed | | `belongsToRemovedBrowserContext` | code | M |
| TAB-06 | Tabs are live | Subscriptions to the model. | `attachToSystem` | click | M |
| TAB-07 | Tab actions (icons, top right) | Class: "Opens special class menu" (red "!"), back, forward. Method: copy method name, versions, back, forward (also commit history with Iceberg). | `ClyNotebookPageHeaderPresenter` (Spec) | click | P |
| TAB-08 | Diff tool | Side-by-side, word-level colours. | `ClyMethodDiffToolMorph` | click | P |
| TAB-09 | Tab order and closing | Tabs are **sorted automatically** by `tabOrder` (no user reordering); each has a close button. | `ClyNotebookMorph>>useSortedTabsBy:` | click | M |
| TAB-10 | Tools are built in background | | `ClyBrowserToolMorph` | code | P |
| TAB-11 | Tool decorations by plugins | Critics panel. | `ClyBrowserToolDecorator` | click | P |
| TAB-12 | Per-tool status bar | Method editors only (the class definition has none). | `ClyStatusBarMorph` | click | M |
| TAB-13 | Third-party tabs | Dependencies, baseline map, rich comments: Morphic tools from other projects. | — | click | M |
| TAB-14 | **Maximize the tools** | **Double-click a tab header**: the panes disappear and the tools take the whole window; double-click again restores. | `toggleFullWindowTabs` | click | P |

## 9. Editors (EDT)

| ID | Feature | Hidden behaviour / notes | Implementation | Seen | Tier |
|---|---|---|---|---|---|
| EDT-01 | Method editor | Syntax highlighting; **syntax errors shown while typing** (red "!" in the left bar, dotted underline); Accept ⌘S, Cancel ⌘L. | `ClyMethodCodeEditorToolMorph` | click | M |
| EDT-02 | Method creation editor | Template `methodSelectorAndArgumentNames …` with a hint of the variable scope; protocol = selected protocol; several classes selected → the user chooses. Plain editor menu (no Source code ▸). | `ClyMethodCreationToolMorph` | click | M |
| EDT-03 | Protocol / extension editor in the status bar | "Edit protocol: X" (click to change, ⌘E,P), **Extension checkbox** → Spec dialog "Choose package for method"; cancelling unticks it. | `ClyProtocolEditorMorph` | click | M |
| EDT-04 | Class definition editor | Fluid definition; accepting a method source here compiles a method; "Expand class definition" (⌘E). No status bar. | `ClyClassDefinitionEditorToolMorph` | click | M |
| EDT-05 | Class creation editor | Template with `package:`/`tag:`. | `ClyClassCreationToolMorph` | click | M |
| EDT-06 | Class comment | Rendered Microdown; "Toggle Edit / View comment" switches to source; "Syntax Help". | `ClyRichTextClassCommentEditorToolMorph` (BeautifulComments) | click | M |
| EDT-07 | Test `setUp` editor | Tab on test classes. | `ClyTestSetUpEditorToolMorph` | click | P |
| EDT-08 | Status bar | Cursor `line/lines [column]` (or a range), Format, Line numbers, Word Wrap checkboxes. **Line numbers are per editor**: a rebuilt editor goes back to the setting's default. | `ClyText*SwitchMorph`, `ClyCursorPositionLabelMorph` | click | P |
| EDT-09 | Code navigation and refactoring on the node | Context menu "Source code ▸" (refactorings, browse/senders/implementors of the node), done by the browser (`ClyTextEditor`). | `ClyMethodSourceCodeContext`, `SycSourceCodeMenuGroup` | click (menu) | M |
| EDT-10 | Left bar | The icon column (not the line numbers). Right click: **selects the node of the line first**, then "Break on", "Configure Breakpoint on", "Watch". Double click: breakpoint. | `ClyOpenTextLeftBarMenuCommand`, `RubTextSegmentIconDisplayer` | click | P |
| EDT-11 | Debug point icons in the code | | `DebugPointIconStyler` | code | P |
| EDT-12 | Critiques | Spinner "critiques analysis" in the status bar while computing; a blue "i" in the left bar; on class definitions a **panel under the editor** listing critiques with ban (×) and details (?) icons. | `ClyCriticDecorator` | click | P |
| EDT-13 | Edit conflict | Method changed elsewhere while edited: **red corner triangle**. See bug B-01. | `editionTimestamp`, `pendingText` | click | M |
| EDT-14 | Highlight the searched text | `openOnClass:selector:highlight:`; in Calypso's query browser all occurrences of the searched selector are highlighted (text match). | `selectStringAsInMessageBrowser:` | click | M |
| EDT-15 | Format code | ⇧⌘F, and "Format" checkbox = format as you read. | `SycFormatSourceCodeCommand`, `ClyFormatAsReadSwitchMorph` | code | M |
| EDT-16 | Do-it in the class context | Do it / print it / inspect it / debug it from the editor menu. | rubric interaction model | click (menu) | P |
| EDT-17 | Dialogs remember the last package | Package request dialogs pre-select the last package chosen. | `ClySystemBrowserContext class>>rememberedPackage` | code | P |

## 10. Commands and interactions (CMD)

The 397 entries are in [command-catalogue.md](command-catalogue.md). Command *behaviour* is UI-independent; what the Spec browser must keep is every *interaction*.

| ID | Feature | Hidden behaviour / notes | Implementation | Seen | Tier |
|---|---|---|---|---|---|
| CMD-01 | Context menus | Groups as sub-menus or inlined between lines; shortcut labels with chords; commands that cannot run are hidden. Pane menus are normal pop-ups; **the editor menu is modal**. | `ClyCommandGroupBuilder`, `ClyCommandGroupMenuRenderer` | click | M |
| CMD-02 | Shortcuts | **Shared keys** chosen by context and priority (⌘T, ⌘R, ⌘F, ⌘E,M); chords. Little known even by long-time users (K-4): worth making discoverable later. | `ClyKMDispatcher` | hand | M |
| CMD-03 | Toolbar commands | BRW-12. | `ClyToolbarMorph` | click | M |
| CMD-04 | Table icons | Run tests, run script, critique actions. | `ClyCommandBasedTableDecorator` | click | P |
| CMD-05 | Double click | Spawn browser (class), show in method browser (protocol), inspect value (variable). | `ClyMouseInteractionHandler` | click (class) | P |
| CMD-06 | Drag and drop | | `ClyDragPassenger` | hand | P |
| CMD-07 | Tab actions | TAB-07. | | click | P |
| CMD-08 | Open a sub-menu from a key or tab action | ⌘T on methods, the class tab's red "!". | `ClyOpenMenuGroupCommand` | click (tab action) | P |
| CMD-09 | Refactoring preview and failures | | `SycRefactoringCommand`s | code | M |
| CMD-10 | Commands declared by other packages | `<calypsoCommands>`, `remove:`, `rebind:to:`. | `ClyCommandMap` | code | M |
| CMD-11 | Legacy class annotations | Deprecated, removed in Pharo 16. | `Commander-Calypso-Compatibility` | code | Dropped |
| SEL-07 | Ensure a selection after updates | Only panes that forbid deselection select an item by themselves, and every pane of the full browser allows it; only the retired query browser (D-08) used it. | Deny deselection on a pane and call `ensureSelectedItemIfNeeded` when it gets items (`ClyQueryViewMorph`). |
| HIS-05 | Pluggable history class | `ClyNavigationHistory` has no subclass, so the setting offers a single choice. | A class-side setting naming the history class (`ClyBrowserMorph class>>settingsNavigationHistoryOn:`). |

## 11. Table decorations (DEC)

| ID | Feature | Decorator | Seen | Tier |
|---|---|---|---|---|
| DEC-01 | Group rows: icons by kind and by protocol name, blue virtual groups, bold/extension colour for extension groups | `ClyGroupItemTableDecorator` and group `decorateTableCell:of:` | click | M |
| DEC-02 | Test result circles (gray, green, yellow, red), clickable | `ClyCommandBasedTableDecorator` + SUnit plugin | click | P |
| DEC-03 | Package / empty package / project icons, project indentation | `Cly*Package*Decorator`, `ClyProjectTableIndentationDecorator` | click | M |
| DEC-04 | Class icons (`systemIcon`) | `ClyClassIconTableDecorator` | click | M |
| DEC-05 | Abstract in italic (+ icon on methods) | `ClyAbstract*TableDecorator` | click | P |
| DEC-06 | Uncommented class icon; comment icon | `ClyUncommentedItemTableDecorator`, `ClyClassCommentTableDecorator` | code | P |
| DEC-07 | Override arrows | `ClyOverriddenMethodTableDecorator` | click | P |
| DEC-08 | Deprecated struck out (packages, groups, methods) | `ClyDeprecatedItemTableDecorator` | click | P |
| DEC-09 | FFI, flag, halt, trait, undeclared markers | `ClyFFI…`, `ClyFlag…`, `ClyHalt…`, `ClyTrait…`, `ClyUndeclared…` | click (flag) | P |
| DEC-10 | Bold on class side | `ClyClassSideBoldTableDecorator` | click | M |
| DEC-11 | "see class side" button | `ClyClassSideLinkTableDecorator` | code | P |
| DEC-12 | Critique severity icons | `ClyCritiquesTableDecorator` | click | P |
| DEC-13 | Gray extension classes and methods; italic "(Class)" inherited methods | display blocks of the views | click | M |

## 12. Filtering and search (FLT)

| ID | Feature | Seen | Tier |
|---|---|---|---|
| FLT-01 | Filter fields: packages (regex, delayed, remembered), classes (substring) | click | M |
| FLT-02 | Type-ahead search in panes. **Works only in the method-group and method panes**, not in the package and class panes (K-2); whether this is intended is to find out in the FLT sheet | hand | M |
| FLT-03 | Filtering keeps the selection | click | M |
| FLT-04 | Enter / Escape in filter fields | hand | P |
| FLT-05 | Query browser filter on several columns | code | P |

## 13. Query results (QRY)

In Pharo 15 the user-visible query browser is **`StMethodBrowser`** (NewTools, Spec), opened by Calypso's Senders / Implementors / References commands through `Smalltalk tools messageList`. Calypso's own `ClyQueryBrowserMorph` remains for old entry points. This changes the scope of the project (plan, decision D-08).

| ID | Feature | Notes | Seen | Tier |
|---|---|---|---|---|
| QRY-01 | Senders / implementors / references from the browser open `StMethodBrowser` | Tabbed result window, scope drop-down, toolbar, columns Location / Selector / Package. **Not part of Calypso.** | click | — (exists) |
| QRY-02 | `spawnQueryBrowserOn:` path (code search "class names containing it", unused-variable check, Scopes tool) | **Broken**: bug B-02. | click | M (fix) |
| QRY-03 | `ClyQueryBrowserMorph` (old API `ClyOldMessageBrowserAdapter`, `browseBreakpoints`) | List + editor side by side, scope drop-down, Flat/Hier., Run all (n), all occurrences of the searched selector highlighted. | click | decision D-08 |

## 14. Live update (UPD)

| ID | Feature | Seen | Tier |
|---|---|---|---|
| UPD-01 | Panes update on system changes, deferred and batched (`ClyDataSourceUpdateScheduler`) | click (tests run, recompilation) | M |
| UPD-02 | Selection and expansion survive updates | click | M |
| UPD-03 | Tools update / close on change / removal | click (conflict) | M |
| UPD-04 | Inheritance hints update when hierarchy changes | code | P |
| UPD-05 | Package removal while editing | code | P |

## 15. Integration and entry points (ENT)

| ID | Feature | Seen | Tier |
|---|---|---|---|
| ENT-01 | Default system browser (`Smalltalk tools browser` = `ClyFullBrowserMorph`) | click | M |
| ENT-02 | "Browse" from everywhere opens Calypso | code | M |
| ENT-03 | Senders/implementors from everywhere → `StMethodBrowser` (not Calypso) | click | — |
| ENT-04 | Iceberg integration: browse repo/commit/package, commit (⌘S), method commit history | code | M |
| ENT-05 | Hera integration commands (external) | code | X |

## 16. Settings (SET)

| ID | Setting | Implementation | Tier |
|---|---|---|---|
| SET-01 | Show the project view by default | `ClyFullBrowserMorph class>>settingsGroupOn:` | P |
| SET-02 | Navigation history class | `ClyBrowserMorph class>>settingsNavigationHistoryOn:` | P |
| SET-03 | Show line numbers for all browsers (default of each editor) | `ClyTextLineNumbersSwitchMorph class>>settingsOn:` | P |
| SET-04 | Drag-and-drop expansion delay | `ClyQueryViewMorph class>>settingsDragAndDropDelayOn:` | P |
| SET-05 | Order of variables and of inherited-method classes (superclass first or not) | `ClySubclassHierarchy class>>settingsOn:` (two settings) | P |

---

## Bugs of today's Calypso found in this inventory

Details and reproduction in the [walkthrough](walkthrough.md#bugs-found-during-the-walkthrough). Each becomes an acceptance scenario that the Spec version must pass.

| Id | Bug |
|---|---|
| B-01 | After an edit conflict the tab loses its `*` and the status bar is duplicated; the `*` is also lost when the class of a dirty editor is removed (TAB-05.d) |
| B-02 | `spawnQueryBrowserOn:` opens a debugger (`StMethodBrowser class` does not understand `#on:systemScope:`) |
| B-03 | Duplicate method-creation tab after running tests from a class icon |
| B-04 | Debugger on right click in the empty area of the method pane |
| B-05 | ⌘F (Find class) in the class pane lists every class of the image, not only the classes of the selected package (found by you, K-5). **To fix in the Spec browser**: list only the classes of the selected package(s) |
| B-06 | Going back after clicking tabs by hand sometimes shows another tab than the one left, with no tab marked as selected (HIS-02.c) |

## Dropped features

Decided with you on 2026-11-23 and 2026-11-24 (D-06). A dropped feature can come back later: its ID is kept, and this table says what it would take.

| ID | Feature | Why dropped | To add it back |
|---|---|---|---|
| BRW-06 | Window groups | Only created by the retired query browser (`ClyQueryBrowserMorph>>openInWindow:`, D-08); no normal path reaches it in Pharo 15. | A Spec window that hosts several browsers as tabs; read `ClyGroupWindowMorph` and `createWindowGroupFrom:`. Needs gap G-22. |
| CMD-11 | Legacy class annotations (Commander 1 style) | Nothing real uses it in Pharo 15 (27 `<classAnnotation>` pragmas, all in tests except one in `Commander-Activators-TextView`); the package is removed in Pharo 16. | Read the converted annotations through `ClyAnnotationConversion` (package `Commander-Calypso-Compatibility`) when building the command map. |

## Counts

| Area | Features | Seen by clicking |
|---|---|---|
| BRW | 12 | 8 |
| PKG | 11 | 9 |
| CLS | 11 | 7 |
| MGP | 11 | 6 |
| MTH | 8 | 6 |
| SEL | 7 | 3 |
| HIS | 5 | 2 |
| TAB | 14 | 11 |
| EDT | 17 | 14 |
| CMD | 11 | 6 |
| DEC | 13 | 11 |
| FLT | 5 | 2 |
| QRY | 3 | 3 |
| UPD | 5 | 3 |
| ENT | 5 | 2 |
| SET | 5 | 0 |
| **Total** | **143** | **93** |

## Existing tests (baseline, 2026-11-16)

159 UI-level tests pass (1 skipped: `NavigationInteractionTest>>#testBrowseMethodViaImplementorActuallyBrowseTheClass`) in `Calypso-Browser-Tests`, `Calypso-SystemTools-FullBrowser-Tests`, `Calypso-SystemTools-QueryBrowser-Tests`, `Calypso-Commands-Tests` and `Commander-Calypso-Compatibility-Tests`. The model has about 640 more tests. The UI tests are the closest thing to acceptance tests today and a source of scenarios.
