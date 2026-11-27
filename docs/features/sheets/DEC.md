# DEC: table decorations

Status: **draft**, to review. Code read on Pharo 15 (sources `b7a73b3`), 2026-11-27.

The icons, buttons, fonts and colours of the rows in the four panes and in the other Calypso tables. They tell the user what an item is (a test class, an extension, an abstract method) before they click it. Refactoring R-03 changes this code most: today each decorator changes the cell morph directly, so a Spec table cannot reuse them; R-03 turns them into descriptions (an icon, an emphasis, a colour, a button) that any table can render.

- A decorator is a class whose behaviour is all on the class side, a subclass of `ClyTableDecorator`. It is registered for a kind of item (or a browser context) in a `<calypsoCommands>` method: `aCommandMap tableDecorators add: ClyClassIconTableDecorator` (for example `ClyClass class>>calypsoSystemToolsCoreCommandsIn:`).
- For each row, `ClyQueryViewMorph>>decorateMainTableCell:of:` and `decorateTableCell:of:` ask `ClyCommandRegistry default activeActivationsOf: #tableDecorators inContext:` for the decorators of that item, in ascending `priority`, so the one with the largest priority wins where two set the same property.
- A decorator says whether it applies with `wantsDecorateTableCellOf:` (usually: the item is marked with a tag computed by the queries, such as `ClyAbstractItemTag`), and it is skipped when the browser lacks its plugin (`browserPluginClass`, `ClyTableDecorator class>>wantsDecorateTableCellInContext:`).
- The main column can get a definition icon or morph (`definitionIcon:`, `definitionMorph:`), extra icons and tools (`addExtraIcon:`, `addExtraTool:`), a label emphasis and colour, and a tooltip. Other columns only get the label style.
- Besides decorators, two things style rows: method groups decorate themselves (`ClyItemGroup>>decorateTableCell:of:` and subclasses, through `ClyGroupItemTableDecorator`), and the class and method panes set their names in display blocks (`ClyFullBrowserMorph>>specifyClassItemNameOn:for:`, `specifyMethodItemNameOn:for:`).

The scenarios below use fixture classes built by the tests (`factory newClass` and compiled methods), as the TAB tests do. A test reads a row's decoration through the driver (for example its definition icon name, its emphasis, its colour), in browser terms.

## DEC-01: Group rows (M)

**Behaviour.** In the method-group pane:
- Protocols named `private…` show the private icon; `initial…`, `class initial…`, `releas…`, `releaz…`, `finali…` show the protected icon.
- Extension groups (methods of the class in another package) show the extension icon. Their name is bold when the group's package is part of the package selection, in the extension colour otherwise.
- Groups computed by the browser, not edited by the user ("instance side", "extensions", "overridden", "flags"…), are in the frozen colour (blue in the default theme).
- Some computed groups have their own style: unclassified, failed tests, unimplemented, active breakpoints and undeclared in red (the last two with a debug icon); deprecated struck out; flags with the flag icon; FFI with its icon.
- The groups of inherited methods ("instance side" and its superclass levels) get a visibility tool: the hierarchy icon and a control to show superclass methods (MGP area).

**How to trigger.** Select a class.

**Code.**
- `ClyGroupItemTableDecorator class>>decorateMainTableCell:of:` delegates to the group, `groupItem actualObject decorateTableCell:of:`.
- `ClyItemGroup>>decorateTableCell:of:` (frozen colour when `isEditableGroup` is false), `ClyMethodsInProtocolGroup>>decorateTableCell:of:` (icons by name), `ClyExternalPackageMethodGroup>>decorateTableCell:of:` (extensions).
- `ClyMethodGroup>>decorateTableCell:of:` → its query's `decorateMethodGroupTableCell:of:` (`ClyUnclassifiedMethodsQuery`, `ClyFailedTestMethodsQuery`, `ClyDeprecatedMethodsQuery`, `ClyFlaggingMethodsQuery`, `ClyFFIMethodQuery`, `ClyActiveBreakpointsQuery`, `ClyUndeclaredMethodsQuery`, `ClyUnimplementedMethodsQuery`, `ClyAllExtensionMethodsQuery`; `ClyCompositeQuery` asks each subquery).
- `ClyInheritedMethodGroup>>decorateTableCell:of:` → each visibility level (`ClyFullVisibilityLevel`, `ClySuperclassVisibilityLevel`, `ClySingleTraitVisibilityLevel`).

**Edge cases.** A protocol that is both private and an extension (the extension group is a different row); class side (DEC-10); a group whose query runs in the background shows a spinning icon until it is done (`ClyAsyncMethodGroup`).

**Existing tests.** None on the decoration; the queries that compute the groups are tested in `Calypso-SystemQueries-Tests`.

**Scenarios.**
- `DEC-01.a` Given a class with protocols `private` and `initialization`, then `private` shows the private icon and `initialization` the protected icon.
- `DEC-01.b` Given a class extended by another package, then the extension group shows the extension icon, in bold when that package is selected and in the extension colour otherwise.
- `DEC-01.c` Given a class, then the computed groups ("instance side", "extensions") are in the frozen colour and the user's protocols are not.
- `DEC-01.d` Given a class with an unclassified method, then the unclassified group is in red.

**Manual check.** None.

**Notes.** Decoration is spread over groups, queries and visibility levels, not only decorators: R-03 must cover all of them ("per family", plan).

## DEC-03: Package and project rows (M)

**Behaviour.** Packages show the package icon, packages without classes the empty package icon. In Projects mode, projects show the coloured package icon, and their children shift with them when a project is collapsed (full indentation).

**How to trigger.** Look at the package pane; switch to Projects.

**Code.** `ClyPackageIconTableDecorator` (`definitionIcon: #package`), `ClyEmptyPackageTableDecorator` (priority one above, `#emptyPackage`, when the package item has no class children), registered in `Package class>>calypsoSystemToolsCoreCommandsIn:`. `ClyProjectIconTableDecorator` (`#packageColored`, `Project class>>calypsoSystemToolsCoreCommandsIn:`). `ClyProjectTableIndentationDecorator` (`useFullIndentation` for rows under a project, `ClyFullBrowserContext class>>calypsoSystemToolsFullBrowserCommandsIn:`).

**Edge cases.** A package whose only classes are extensions; a package emptied while shown (UPD).

**Existing tests.** None.

**Scenarios.**
- `DEC-03.a` Given a package with classes and an empty package, then the first shows the package icon and the second the empty package icon.
- `DEC-03.b` Given Projects mode, then a project shows the project icon.

**Manual check.** None.

## DEC-04: Class icons and comment tooltip (M)

**Behaviour.** Each class shows its icon (`systemIconName`: test case, exception, trait, plain class…). Hovering a class shows the first three lines of its comment, or "There is no comment!".

**How to trigger.** Look at the class pane; hover a class.

**Code.** `ClyClassIconTableDecorator class>>decorateMainTableCell:of:` looks the class up by name in the image (`Object environment at:`) and asks its `systemIconName`, so a remote class gets the icon of the local one. Its superclass `ClyClassTableDecorator class>>decorateTableCell:of:` sets the tooltip.

**Edge cases.** A class not present locally gets the `Object` icon; a ring class (comment `content`).

**Existing tests.** None.

**Scenarios.**
- `DEC-04.a` Given a test case class and a plain class, then each shows its own system icon.
- `DEC-04.b` Given a class with a five-line comment, then its tooltip shows the first three lines.

**Manual check.** That the tooltip appears on hover.

**Notes.** The tooltip was not in the inventory; it is part of this feature.

## DEC-10: Bold on the class side (M)

**Behaviour.** On the class side, the method groups, the "all methods" group and the variables are in bold, so the user sees at once which side they browse.

**Code.** `ClyClassSideBoldTableDecorator` (when the browser's `metaLevelScope` is `ClyClassSideScope`), registered for method groups (`ClyFullBrowserMethodGroupContext`) and variables (`ClyFullBrowserVariableContext`); `ClyAllMethodGroup>>decorateTableCell:of:` does the same for its own row.

**Existing tests.** None.

**Scenarios.**
- `DEC-10.a` Given a class, when I switch to the class side, then the method groups are in bold; back on the instance side, they are not.

**Manual check.** None.

**Notes.** The methods themselves are not in bold: the inventory's "method groups and methods" (class comment) is wrong for methods.

## DEC-13: Extensions and inherited methods in the class and method panes (M)

**Behaviour.**
- A class or method defined in a package that is not part of the package selection is in the extension colour (gray).
- With several packages selected, classes show their full name with their package; with several classes selected, methods show `Class>>selector`.
- A method of another class (shown when superclass methods are visible) is in italic with its full name.

**Code.** The display blocks of the panes, not decorators: `ClyFullBrowserMorph>>newClassView` → `specifyClassItemNameOn:for:`, `newMethodView` → `specifyMethodItemNameOn:for:` (`isPackagePartOfSelection:`, `printFullNameOf:`).

**Existing tests.** None.

**Scenarios.**
- `DEC-13.a` Given a package extending a class of another package, when I select the class in the extending package, then the methods of the class's own package are in the extension colour.
- `DEC-13.b` Given superclass methods shown, then an inherited method is in italic with its full name.

**Manual check.** None.

**Notes.** R-03 must move these display rules too, or the Spec panes lose them.
