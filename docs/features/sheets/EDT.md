# EDT: editors

Status: **reviewed** 2026-11-24 (manual checks done for EDT-01, 06, 09..13). Code read on Pharo 15 build 145, 2026-11-23.

The tools of [TAB](TAB.md) that show code: the method editor, the method and class creation templates, the class definition, the class comment, the `setUp` editor, with their status bars, left bars and menus.

- All of them are `ClyTextEditorToolMorph` subclasses: a Rubric text morph (`textMorph`, `textModel`) whose interaction model is the tool itself.
- `ClyTextEditorToolMorph>>subscribeOnTextChanges` wires the three Rubric events: `RubTextAccepted` → `changesAccepted`, `RubTextChanged` → `textChanged:`, `RubCancelEditRequested` → `changesCancelRequested:`.
- Each tool answers `editingText` (the text it shows) and `applyChanges` (what accepting does, true when it worked).
- Shortcuts typed in the editor go to Commander first: `ClyKMDispatcher attachedTo: textMorph textArea withCommandsFrom: self` in `buildTextMorph`.

**Where each feature goes** (plan, sub-goal, decided 2026-11-24). Three layers: what any code needs goes into `SpCodePresenter`; what any tool editing a *method* needs (Calypso, the method browser, the debugger) goes into one shared method editor built on it, upstream in NewTools; only what depends on the browser's selection stays in Calypso.

| Goes to | Features |
|---|---|
| `SpCodePresenter`: any code, the Playground included | EDT-01 styling, live errors, accept/cancel, dirty state; EDT-08 cursor, wrap, line numbers; EDT-09 source code menu (the host answers browse/senders/implementors); EDT-10 the left bar itself (a per-line click, double-click and menu API, G-17); EDT-14 highlight; EDT-15 format; EDT-16 do-it |
| Shared method editor (NewTools, on `SpCodePresenter`): any tool editing a method | EDT-01 compile in the method's class and protocol; EDT-03 protocol and extension editor; EDT-10 breakpoints and watches from the left bar; EDT-11 debug point icons; EDT-12 critiques; EDT-13 edit conflict (the method changed elsewhere) |
| Calypso (context-dependent) | EDT-02 method creation from the selection; EDT-04 class definition (accepting a method there, "Expand class definition"); EDT-05 class creation; EDT-07 `setUp` tab; EDT-17 remembered package |
| Other projects | EDT-06 rich comments (BeautifulComments, TAB-13) |

## EDT-01: Method editor (M)

**Behaviour.** Shows the source of the selected method, styled. Syntax errors are shown while typing (red "!" in the left bar, dotted underline). Accept (⌘S) compiles the text in the method's class and protocol; if the selector changed, a new method is created and the editor switches to it. Cancel (⌘L) puts back the method's source, and its protocol and package. A compile error leaves the text and the `*` as they are.

**How to trigger.** Select a method; type; ⌘S or ⌘L, or Accept / Cancel in the editor menu.

**Code.**
- `ClyTextEditorToolMorph>>changesAccepted`: runs `applyChanges` inside `applyChangesBy:`; on success resets the text and the dirty state and gives the focus back to the tab; on an error resets the text and re-signals.
- `ClyMethodCodeEditorToolMorph>>applyChanges`: `compile:classified:withStamp:notifying:logSource:`, then `setMethodProtocol:`, `protocolAndPackageEditingMethod:` (EDT-03) and `switchToMethod:`. The AST is rebuilt, which clears its breakpoints (comment "To be improved").
- `ClyMethodCodeEditorToolMorph>>cancelChanges` → `updateProtocolAndPackage`, then `ClyTextEditorToolMorph>>cancelChanges` (`setText: self editingText`).
- `textChanged:` → `updateDirtyState` (the `*`, TAB-04).
- The error marks while typing come from Rubric's styling; the exact class is still to find.

**Edge cases.** A renamed selector (the old method stays); a class-side method; an extension method; a literal method (not styled, `applyDecorations`); accepting while the method changed elsewhere (EDT-13).

**Existing tests.** `ClyBrowserToolValidityTest` (validity only), `ClyTextEditorToolMorphTest>>testFindAnyStringIn`. None on accept or cancel.

**Scenarios.**
- `EDT-01.a` Given a method editor, when I change the source and accept, then the method has the new source and the tab is no longer dirty.
- `EDT-01.b` Given a method editor, when I change the selector and accept, then a new method exists, the old one is unchanged, and the editor shows the new one.
- `EDT-01.c` Given a dirty method editor, when I cancel, then it shows the method's source again and is not dirty.
- `EDT-01.d` Given a method editor, when I accept code with a syntax error, then no method changes and the editor stays dirty.

**Manual check.** ⌘S and ⌘L from the keyboard (T-09); the error marks while typing (look). Checked 2026-11-24.

## EDT-02: Method creation editor (M)

**Behaviour.** The "+ Inst. side method" (or class side) tab shows the class's method template. The new method goes to the selected protocol; with the extension group of a package selected, it becomes an extension of that package; with no protocol, it is classified automatically. When several classes are selected, accepting asks "Where to install new method?". After accepting, the creation tab closes and the new method is selected with its editor.

**How to trigger.** Select a class, protocol or extension group, then the "+ … method" tab.

**Code.**
- `ClyMethodCreationToolMorph>>editingText` (`methodClass sourceCodeTemplate`), `setUpModelFromContext` (protocol or extending package from the last selected method group), `setUpTargetClasses` (`browser chooseClassesForNewMethod`).
- `ClyMethodCreationToolMorph>>applyChanges`: `chooseClassForNewMethodIfNone:` (an `StBrowserSearchPresenter` dialog when several classes), compile, `MethodClassifier classify:fallbackProtocol:`, `protocolAndPackageEditingMethod:`, `removeFromBrowser`, `desiredSelection: {ClyMethodCodeEditorToolMorph}`, `browser selectMethod:`.
- `isSimilarTo:`: same class, protocol and extending package (TAB-02).

**Edge cases.** Cancelling the class dialog (nothing compiled); a selector that already exists (it is overwritten); a virtual group selected (no protocol).

**Existing tests.** None.

**Scenarios.**
- `EDT-02.a` Given a protocol selected, when I accept a new method in the creation tab, then the method exists in that protocol, it is selected and its editor is shown.
- `EDT-02.b` Given no protocol selected, when I accept a new method, then it is classified automatically.
- `EDT-02.c` Given the extension group of a package selected, when I accept a new method, then it is an extension of that package.
- `EDT-02.d` Given two classes selected, when I accept a new method and choose one class, then the method is created only in that class.

**Manual check.** None.

## EDT-03: Protocol and extension editor (M)

**Behaviour.** In the status bar of method editors: a pencil button, "Edit protocol: X" (or the package name for an extension), and an "Extension" checkbox. The pencil (or ⌘E,P) asks for a protocol; ticking "Extension" asks "Choose package for method", and cancelling unticks it. On a clean editor the change applies at once; on a dirty one it applies at accept, and cancel drops it.

**How to trigger.** Click in the status bar; ⌘E,P (protocol), ⌘E,M,P (package), ⌘E,U (unclassify).

**Code.**
- `ClyProtocolEditorMorph>>openEditor`, `toggleExtension`, `requestProtocol` (`StProtocolNameChooserPresenter`; same name → `CmCommandAborted`), `requestPackage` (`context requestSinglePackage:`), `requestChangeBy:` (catches the abort, then `update`).
- `ClyMethodCodeEditorToolMorph>>methodProtocol:` / `extendingPackage:`: apply now unless `hasUnacceptedEdits`.
- `ClyMethodEditorToolMorph>>protocolAndPackageEditingMethod:` → `editProtocolOf:`, then `packageEditingMethod:` (`SycMoveMethodsToPackageCommand` or `SycMoveMethodsToTheDefiningClassCommand`).
- Commands `ClyRequestProtocolForEditorCommand`, `ClyRequestMethodPackageForEditorCommand`, `ClyResetProtocolForEditorCommand` (catalogue, `ClyTextEditorContext`).

**Edge cases.** Unticking "Extension" moves the method back to its class's package; the method creation editor (applied at accept).

**Existing tests.** None.

**Scenarios.**
- `EDT-03.a` Given a clean method editor, when I choose another protocol, then the method is in that protocol at once.
- `EDT-03.b` Given a dirty method editor, when I choose another protocol and accept, then the method has the new source and the new protocol.
- `EDT-03.c` Given a method editor, when I tick "Extension" and choose a package, then the method is an extension of that package.
- `EDT-03.d` Given an extension method, when I untick "Extension", then the method is back in its class's package.
- `EDT-03.e` Given a method editor, when I tick "Extension" and cancel the dialog, then the checkbox is unticked and nothing changed.

**Manual check.** None.

## EDT-04: Class definition editor (M)

**Behaviour.** Shows the fluid class definition. Accepting a definition (first line contains `<<`) changes the class; accepting anything else compiles it as a **method** of the class, which is then selected. An old-style definition is accepted with a warning. "Expand class definition" (⌘E) shows the full definition. No status bar items.

**Code.** `ClyClassDefinitionEditorToolMorph>>editingText` (`definitionString`), `applyChanges` → `codeLooksLikeAClassDefinition:`, `applyChangesAsClassDefinition`, `applyChangesAsMethodDefinition` (classified by `MethodClassifier`), `applyChangesAsOldClassDefinition:`; `ClyExpandClassDefinitionCommand`.

**Edge cases.** Renaming the class in the definition; adding a slot; class side (`class << …`); a definition with a syntax error.

**Existing tests.** `ClyBrowserToolValidityTest` (validity only).

**Scenarios.**
- `EDT-04.a` Given a class definition editor, when I add a slot and accept, then the class has the slot.
- `EDT-04.b` Given a class definition editor, when I type a method and accept, then the method exists in the class and its editor is selected.

**Manual check.** None.

## EDT-05: Class creation editor (M)

**Behaviour.** With a package or a tag selected, the class creation tab shows a fluid template with that `package:` and `tag:` (`_Unpackaged` when there is none). Accepting creates the class, closes the tab and selects the new class.

**Code.** `ClyClassCreationToolMorph>>setUpModelFromContext`, `classTemplate` (`ClassDefinitionPrinter fluid compactClassDefinitionTemplateInPackage:tag:`), `applyChanges` (`browser compileANewClassFrom:notifying:startingFrom:`, `removeFromBrowser`, `selectClass:`).

**Existing tests.** `ClyBrowserToolValidityTest` (5 tests on validity).

**Scenarios.**
- `EDT-05.a` Given a package tag selected, then the template names that package and tag.
- `EDT-05.b` Given the template, when I accept a new class, then the class exists in that package and is selected.

**Manual check.** None.

## EDT-06: Class comment (M)

**Behaviour.** The comment is rendered as Microdown. "Toggle Edit / View comment" in the status bar switches to the source (also a double click on the text); "Syntax Help" explains Microdown. Accepting saves the comment.

**Code.** `ClyRichTextClassCommentEditorToolMorph` (package BeautifulComments, an external tool, see TAB-13) with the trait `TClyRichTextCommentEditorPaneMorph` (`renderComment:of:`, `changesAccepted`); `fillStatusBar`, `reactToRubTextAreaDoubleClick:`.

**Existing tests.** `ClyBrowserToolValidityTest` (validity only).

**Scenarios.**
- `EDT-06.a` Given a class comment in edit mode, when I change it and accept, then the class has the new comment.

**Manual check.** The rendering and the toggle (look). Checked 2026-11-24.

## EDT-07: `setUp` editor (P)

**Behaviour.** On a test class that has `setUp` (its own or inherited), a `setUp` tab edits the `setUp` method; when the class has none, it shows a template. Its activation priority is −100, so it is never selected automatically. It is not shown when `setUp` itself is selected.

**Code.** `ClyTestSetUpEditorToolMorph` (a `ClyMethodCodeEditorToolMorph`): `shouldBeActivatedInContext:`, `activationPriority`, `defaultTemplateForNewSetUp`, `belongsToCurrentBrowserContext`.

**Existing tests.** `ClyBrowserToolValidityTest` (3 tests).

**Scenarios.** Covered by `TAB-01.e`.

**Manual check.** None.

## EDT-08: Status bar items (P)

**Behaviour.** Method editors show the cursor position `line/lines [column]` (or a range), then the protocol editor (EDT-03), and the checkboxes Word Wrap, Line numbers, Format. Line numbers are per editor: a rebuilt editor goes back to the setting "Show line numbers for all browsers".

**Code.** `ClyMethodEditorToolMorph>>fillStatusBar`; `ClyCursorPositionLabelMorph`, `ClyTextWrapModeSwitchMorph`, `ClyTextLineNumbersSwitchMorph` (`toggle`, class-side setting `showLineNumbers`), `ClyFormatAsReadSwitchMorph` (EDT-15).

**Existing tests.** None.

**Scenarios.**
- `EDT-08.a` Given a method editor with the cursor on line 2, then the status bar shows line 2.
- `EDT-08.b` Given a method editor, when I tick "Line numbers", then the editor shows line numbers.

**Manual check.** None.

## EDT-09: Source code menu (M)

**Behaviour.** The editor context menu starts with "Source code ▸": refactorings and navigation on the node under the cursor or the selection (rename, extract, inline, senders, implementors…), then the generic Rubric menu. The same commands have shortcuts (⌘R rename, ⌘B browse, ⌘E,M extract…).

**Code.** `ClyMethodCodeEditorToolMorph>>createCommandContextForCursorAt:` and `findSourceNodeAt:` build a `ClyMethodSourceCodeContext`; commands come from `ClySourceCodeContext` and `ClyMethodSourceCodeContext` in the [catalogue](../command-catalogue.md) (49 `Syc…` commands in `SycSourceCodeMenuGroup`).

**Edge cases.** The method creation editor has no "Source code ▸"; the menu is opened modally.

**Existing tests.** The `Syc…` commands have their own tests; none through the editor.

**Scenarios.**
- `EDT-09.a` Given the cursor on a message send, then the editor's command context offers the refactorings of that message.

**Manual check.** That the menu opens on right click. Checked 2026-11-24.

## EDT-10: Left bar (P)

**Behaviour.** The icon column left of the text. A right click first selects something, then shows "Break on", "Configure Breakpoint on", "Watch" for it: with nothing selected, the whole method; with the cursor in a line, that line. A double click adds a breakpoint: on the line of the cursor, or on the method node (shown on the selector) when there is no cursor.

**Code.** `ClyMethodCodeEditorToolMorph>>buildLeftSideBar` (`textLeftBarClick`, `textLeftBarDoubleClick`); `ClyOpenTextLeftBarMenuCommand>>execute` (`showSourceNode`, `invokeModal`); `ClyAddBreakPointCommand` and the debug point commands (catalogue, `ClyMethodSourceCodeContext`).

**Scenarios.**
- `EDT-10.a` Given a method editor with the cursor in a line, when the left bar is double clicked, then a breakpoint is set on that line.
- `EDT-10.b` Given a method editor with no cursor, when the left bar is double clicked, then a breakpoint is set on the method node.
- `EDT-10.c` Given a method editor with nothing selected, when the left bar is right clicked, then the whole method is selected before the menu opens.

**Manual check.** The right click and the double click (checked 2026-11-24).

## EDT-11: Debug point icons (P)

**Behaviour.** Breakpoints and other debug points show as icons in the code. `applyDecorations` runs `IconStyler withStaticStylers` (which includes `DebugPointIconStyler`).

**Scenarios.** None (look).

**Manual check.** A breakpoint shows an icon. Checked 2026-11-24.

## EDT-12: Critiques (P)

**Behaviour.** Each editor lists the critiques of *its own* object in a panel under the editor (under the status bar for methods), one per line: a method editor those of the method, the class definition those of the class (e.g. too many methods), never those of its methods. A tool with no critique has no panel. Each line has a severity icon (warning triangle, red "!"), the rule's text, ban (×) and details (?). A critique on a method also shows a blue "i" in the left bar. The walkthrough saw a "critiques analysis" spinner in the status bar while they are computed; it could not be reproduced on 2026-11-24.

**Code.** `ClyCriticDecorator` (`decorateTool`, `createCriticView` — a `ClyQueryViewMorph` 50 pixels high, `refreshCritiques`); the tools' `criticAnalysisScope`, `decorateByCritic:` (package `Calypso-SystemPlugins-Critic-Browser`). The queries run in background processes (B3 finding).

**Scenarios.**
- `EDT-12.a` Given a class with a critique, when its definition is shown, then the critiques panel lists it.
- `EDT-12.b` Given an `initialize` method without `super initialize`, when its editor is shown, then the critiques panel lists the missing super send.
- `EDT-12.c` Given then, when the class definition is shown, then its panel does not list the method's critique.

**Manual check.** The panel and its icons (checked 2026-11-24); the "i" (look).

## EDT-13: Edit conflict (M)

**Behaviour.** When a method changes elsewhere while its editor is dirty, the editor keeps the user's text and its corner triangle turns red. Accepting then asks "This method may have been changed elsewhere… Accept anyway?". Bug B-01: the tab loses its `*` and the status bar is shown twice.

**Code.** `ClyTextEditorToolMorph>>update` (keeps the pending text, `hasEditingConflicts: true`); `RubScrolledTextMorph>>acceptContents` (the confirmation); `rebuildStatusBar` (B-01). `editionTimestamp` answers the current time, so it does not record when editing started.

**Existing tests.** None.

**Scenarios.**
- `EDT-13.a` Given a dirty method editor, when the method is recompiled elsewhere, then the editor keeps my text and is marked as in conflict.
- `EDT-13.b` Given then, the tab title still starts with `*` and the status bar has one protocol editor (B-01: fails on Morphic today).

**Manual check.** The red triangle and the confirmation dialog. Checked 2026-11-24.

## EDT-14: Highlight the searched text (M)

**Behaviour.** A browser opened on a method for a search selects the searched text in the editor.

**Code.** `ClyFullBrowserMorph class>>openOnClass:selector:highlight:` → `selectAnyString:`; `ClyMethodCodeEditorToolMorph>>selectStringAsInMessageBrowser:` (query browser).

**Existing tests.** `ClyTextEditorToolMorphTest>>testFindAnyStringIn`.

**Scenarios.**
- `EDT-14.a` Given a method that sends `foo`, when I open a browser on it highlighting `foo`, then `foo` is selected in the editor.

**Manual check.** None.

## EDT-15: Format code (M)

**Behaviour.** ⇧⌘F (or "Format code" in Source code ▸) formats the editor's text, without accepting. The "Format" checkbox turns on format-as-you-read: editors format the method when it is shown, without making it dirty.

**Code.** `SycFormatSourceCodeCommand`; `ClyMethodEditorToolMorph>>formatSourceCode`, `formatTextIfNeeded` (`formatAsYouReadPolicy`, then `clearUserEdits`); `ClyFormatAsReadSwitchMorph>>toggle`.

**Edge cases.** The setting is global: ticking it in one editor changes all browsers.

**Scenarios.**
- `EDT-15.a` Given a badly formatted method, when I format it, then the editor shows the formatted source and is dirty.
- `EDT-15.b` Given format-as-you-read on, when I select a badly formatted method, then the editor shows it formatted and is not dirty.

**Manual check.** None.

## EDT-16: Do it in the class context (P)

**Behaviour.** Do it, Print it, Inspect it, Debug it from the editor evaluate the selection with the class (instance side) as `self`.

**Code.** `ClyTextEditorToolMorph>>doItReceiver` (`selectedClassOrMetaClass instanceSide`), `doItContext` (nil), `bindingOf:`.

**Scenarios.**
- `EDT-16.a` Given an editor on a method of `Point`, when I print `self name`, then it prints `'Point'`.

**Manual check.** None.

## EDT-17: Package dialogs remember the last package (P)

**Behaviour.** A package request (Extension checkbox, move to package…) opens with the last chosen package selected.

**Code.** `ClySystemBrowserContext>>requestSinglePackage:` and the class-side `rememberedPackage`.

**Scenarios.**
- `EDT-17.a` Given I chose package P in a package dialog, when another package dialog opens, then P is preselected.

**Manual check.** None.
