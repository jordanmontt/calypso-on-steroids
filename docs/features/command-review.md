# Calypso commands, classified

Every command of today's Calypso system browser (Pharo 15, build 145), grouped by where you meet it, with what a static look at the code says about it. A one-time snapshot made on 2026-11-24 from the [command catalogue](command-catalogue.md); it is not kept up to date.

## How to read it

Each command has one of four marks:

| Mark | Meaning | Commands |
|---|---|---:|
| **shown** | in a menu, the toolbar, a tab icon or a list icon | 162 |
| **hidden** | only a shortcut, a drag and drop, a double click or the editor's left bar: nothing on screen tells you it exists | 6 |
| **duplicate** | the same action as another command, usually its older version; candidate to drop | 4 |
| **retired** | only in the old query browser, which is no longer opened (senders and implementors use the new method browser); candidate to drop | 5 |
| | **Total** | **177** |

The 397 entries of the catalogue are these 177 commands reached in several ways, plus 10 tabs and 21 list decorations (end of this page).

## At a glance

| Where | Commands | Hidden | Duplicate or retired |
|---|---:|---:|---:|
| Package pane | 21 | 0 | 0 |
| Class pane | 39 | 0 | 1 |
| Protocol pane | 19 | 1 | 0 |
| Variables (Vars mode) | 23 | 0 | 0 |
| Method pane | 44 | 1 | 1 |
| Code editors | 66 | 2 | 3 |
| Anywhere in the browser | 15 | 3 | 0 |
| Critiques | 6 | 0 | 0 |
| Old query browser (retired) | 5 | 0 | 5 |

**Crowded menus.** The largest submenus:

- Code editors, Source code: 48 entries
- Method pane, Method refactoring: 15 entries
- Class pane, (top level): 12 entries
- Package pane, (top level): 12 entries

**Shortcut clashes.** The same keys bound to several commands in the same place (the one that runs depends on the selection, or on declaration order):

- Class pane, ⌘T: `ClyOpenMenuGroupCommand`, `ClyRunTestsFromClassesCommand`
- Code editors, ⌘E, M: `SycExtractMethodAndOccurrencesCommand`, `SycExtractMethodCommand`
- Code editors, ⌘R: `SycRenameArgOrTempCommand2`, `SycRenameMessageCommand`
- Code editors, ⌘R: `SycRenameClassCommand2`, `SycRenameVariableCommand`
- Method pane, ⌘T: `ClyOpenMenuGroupCommand`, `ClyRunCoveringTestMethodsCommand`, `ClyRunTestsFromMethodsCommand`

## Package pane

| Command | How you reach it | Mark | Class |
|---|---|---|---|
| Commit | menu Commit | shown | `ClyCommitPackageCommand` |
| Create scope from selected package(s) | menu Create scope from selected package(s) | shown | `SycAddPackagesScopeCommand` |
| Duplicate package | menu Duplicate package<br>⌘C | shown | `SycDuplicatePackageCommand` |
| New package | menu New package | shown | `SycAddNewPackageCommand` |
| New tag | menu New tag | shown | `SycAddNewClassTagCommand` |
| Remove (package) | menu Remove<br>⌘X | shown | `SycRemovePackageCommand` |
| Remove (tag) | menu Remove<br>⌘X | shown | `ClyRemoveClassGroupCommand` |
| Rename (package) | menu Rename<br>⌘R | shown | `ClyRenamePackageTagCommand` |
| Rename (package) | menu Rename<br>⌘R | shown | `SycRenamePackageCommand` |
| Run tests (package) | menu Run tests<br>icon in the list<br>⌘T | shown | `ClyRunTestsFromPackagesCommand` |
| Run tests (tag) | menu Run tests<br>icon in the list<br>⌘T | shown | `ClyRunTestsFromClassGroupCommand` |
| Demote to package with tag | menu Package extra ▸ Demote to package with tag | shown | `SycDemoteToPackageWithTagCommand` |
| File out | menu Package extra ▸ File out | shown | `SycFileOutPackageCommand` |
| Inspect | menu Package extra ▸ Inspect | shown | `SycInspectPackageCommand` |
| Promote as package | menu Package extra ▸ Promote as package | shown | `SycPromotePackageFromTagCommand` |
| Recompile | menu Package extra ▸ Recompile | shown | `SycRecompilePackageCommand` |
| Browse critiques | menu Query ▸ Browse critiques | shown | `ClyOpenCriticBrowserCommand` |
| Browse dependencies | menu Query ▸ Browse dependencies | shown | `ClyOpenDependencyBrowserCommand` |
| All Packages | toolbar All Packages | shown | `ClySwitchToPackagesCommand` |
| Projects | toolbar Projects | shown | `ClySwitchToProjectsCommand` |
| Scoped View | toolbar Scoped View | shown | `ClySwitchToScopedViewCommand` |

## Class pane

| Command | How you reach it | Mark | Class |
|---|---|---|---|
| Abstract instance variables | menu Abstract instance variables<br>⌘A, A | shown | `SycAbstractAllInstVarAccessorsCommand` |
| Categorize all uncategorized | menu Categorize all uncategorized | shown | `SycCategorizeAllUnclassifiedMethodsCommand` |
| Generate accessors | menu Generate accessors<br>⌘G, A | shown | `SycGenerateAllInstVarAccessorsCommand` |
| Jump to test class | menu Jump to test class<br>⌘G, J | shown | `ClyJumpToTestClassCommand` |
| Migrate references | menu Migrate references | shown | `SycMigrateReferencesOfClassCommand` |
| New protocol | menu New protocol | shown | `SycAddNewProtocolCommand` |
| (T) Realize class | menu (T) Realize class | shown | `SycRealizeClassCommand` |
| (R) Remove | menu (R) Remove<br>⌘X | shown | `SycRemoveClassCommand` |
| Remove empty protocols | menu Remove empty protocols | shown | `SycRemoveEmptyMethodTagsCommand` |
| (R) Rename class | menu (R) Rename class<br>⌘R | shown | `SycRenameClassCommand2` |
| Run tests | menu Run tests<br>icon in the list<br>⌘T | shown | `ClyRunTestsFromClassesCommand` |
| Class Critique Browser | menu Class extra ▸ Class Critique Browser | shown | `SycClassCritiqueCommand` |
| Copy class name to Clipboard | menu Class extra ▸ Copy class name to Clipboard | shown | `SycCopyClassNameCommand` |
| File out | menu Class extra ▸ File out | shown | `SycFileOutClassCommand` |
| Inspect | menu Class extra ▸ Inspect | shown | `SycInspectClassCommand` |
| Update | menu Class extra ▸ Update | shown | `SycUpdateClassCommand` |
| Deprecate | menu Class refactoring ▸ Deprecate | shown | `SycDeprecateClassCommand` |
| Duplicate class | menu Class refactoring ▸ Duplicate class<br>⌘D | shown | `SycDuplicateClassCommand` |
| Generate equal and hash | menu Class refactoring ▸ Generate equal and hash | shown | `SycGenerateEqualAndHashCommand` |
| Generate printOn: | menu Class refactoring ▸ Generate printOn: | shown | `SycGeneratePrintOnCommand` |
| (R) Insert subclass | menu Class refactoring ▸ (R) Insert subclass | shown | `SycInsertSubclassCommand` |
| (R) Insert superclass | menu Class refactoring ▸ (R) Insert superclass | shown | `SycInsertSuperclassCommand` |
| (T) Make abstract | menu Class refactoring ▸ (T) Make abstract | shown | `SycMakeAbstractCommand` |
| Move to package | menu Class refactoring ▸ Move to package<br>drag and drop on ClyNoTagClassGroup<br>drag and drop on a tag<br>drag and drop on a package<br>⌘M, C | shown | `ClyMoveClassToGroupCommand` |
| Create new scope from selected class(es) | menu Class scopes ▸ Create new scope from selected class(es) | shown | `SycAddClassesScopeCommand` |
| Browse | menu Query ▸ Browse | shown | `SycBrowseClassCommand` |
| Class refs. | menu Query ▸ Class refs.<br>toolbar Class refs.<br>⌘N | shown | `ClyShowClassRefCommand` |
| Show pool users | menu Query ▸ Show pool users | shown | `ClyShowPoolUsersCommand` |
| Show trait users | menu Query ▸ Show trait users | shown | `ClyShowTraitUsersCommand` |
| Class side | toolbar Class side | shown | `ClySwitchToClassSideCommand` |
| Flat | toolbar Flat | shown | `ClySwitchToFlatClassesCommand` |
| Hier. | toolbar Hier.<br>⌘H | shown | `ClySwitchToFullHierarchyCommand` |
| Inst. side | toolbar Inst. side | shown | `ClySwitchToInstanceSideCommand` |
| Methods | toolbar Methods | shown | `ClySwitchToMethodGroupsCommand` |
| Open a submenu | tab icon<br>⌘T | shown | `ClyOpenMenuGroupCommand` |
| Traits | toolbar Traits | shown | `ClySwitchToInheritedTraitsCommand` |
| Users | toolbar Users | shown | `ClySwitchToTraitUsersCommand` |
| Vars | toolbar Vars | shown | `ClySwitchToVariablesCommand` |
| (Old refactor) rename class | menu (Old refactor) rename class | duplicate (older version of `SycRenameClassCommand2`) | `SycRenameClassCommand` |

## Protocol pane

| Command | How you reach it | Mark | Class |
|---|---|---|---|
| Abstract instance variables | menu Abstract instance variables | shown | `SycAbstractAllInstVarAccessorsCommand` |
| Categorize all uncategorized | menu Categorize all uncategorized | shown | `SycCategorizeAllUnclassifiedMethodsCommand` |
| Convert to extension | menu Convert to extension<br>drag and drop on a package | shown | `ClyMoveMethodGroupsToPackageCommand` |
| Convert to protocol | menu Convert to protocol | shown | `ClyConvertMethodGroupToProtocolCommand` |
| Generate accessors | menu Generate accessors | shown | `SycGenerateAllInstVarAccessorsCommand` |
| New protocol | menu New protocol | shown | `SycAddNewProtocolCommand` |
| (T) Realize class | menu (T) Realize class | shown | `SycRealizeClassCommand` |
| Remove | menu Remove<br>⌘X | shown | `ClyRemoveMethodGroupCommand` |
| (R) Remove | menu (R) Remove | shown | `SycRemoveClassCommand` |
| Remove empty protocols | menu Remove empty protocols | shown | `SycRemoveEmptyMethodTagsCommand` |
| Rename | menu Rename<br>⌘R | shown | `ClyRenameProtocolCommand` |
| Inspect variable | menu Method group extra ▸ Inspect variable | shown | `SycInspectVariableCommand` |
| Invert hierarchy (method) | menu Method group extra ▸ Invert hierarchy | shown | `ClyInvertMethodVisibilityHierarchyCommand` |
| Invert hierarchy (variable) | menu Method group extra ▸ Invert hierarchy | shown | `ClyInvertVariableOrderCommand` |
| Class refs. | menu Query ▸ Class refs. | shown | `ClyShowClassRefCommand` |
| Show in method browser | menu Query ▸ Show in method browser<br>double click | shown | `ClyShowGroupsInMethodBrowserCommand` |
| Show pool users | menu Query ▸ Show pool users | shown | `ClyShowPoolUsersCommand` |
| Show trait users | menu Query ▸ Show trait users | shown | `ClyShowTraitUsersCommand` |
| Move the protocol to another class | drag and drop on a class | hidden (no menu, toolbar or icon) | `ClyMoveMethodGroupToClassCommand` |

## Variables (Vars mode)

| Command | How you reach it | Mark | Class |
|---|---|---|---|
| Abstract accessors | menu Abstract accessors | shown | `SycAbstractVariableCommand` |
| (T) Generate accessors | menu (T) Generate accessors | shown | `SycGenerateVariableAccessorCommand` |
| (T) Generate lazy accessors | menu (T) Generate lazy accessors | shown | `SycGenerateVariableAccessorsWithLazyInitializationCommand` |
| Merge into another | menu Merge into another | shown | `SycMergeVariableCommand` |
| (T) Move to class side | menu (T) Move to class side | shown | `SycMoveInstanceVariableToClassSideCommand` |
| Protect | menu Protect | shown | `SycProtectVariableCommand` |
| Push down | menu Push down | shown | `SycPushDownVariableCommand` |
| (R) Push up | menu (R) Push up | shown | `SycPushUpVariableCommand` |
| Remove | menu Remove<br>⌘X | shown | `SycRemoveVariablesCommand` |
| Rename | menu Rename<br>⌘R | shown | `SycRenameVariableCommand` |
| Add debug point: (variable) | menu Debugging points ▸ Add debug point: | shown | `ClyDebugBreakOnVariableCommand` |
| Add debug point: (variable) | menu Debugging points ▸ Add debug point: | shown | `ClyDebugVariableCommand` |
| Add debug point: (variable) | menu Debugging points ▸ Add debug point: | shown | `ClyDebugWatchOnVariableCommand` |
| Break on access | menu Debugging points ▸ Break on access | shown | `ClyBreakOnVariableReadWriteCommand` |
| Break on read | menu Debugging points ▸ Break on read | shown | `ClyBreakOnVariableReadCommand` |
| Break on write | menu Debugging points ▸ Break on write | shown | `ClyBreakOnVariableWriteCommand` |
| Watch on access | menu Debugging points ▸ Watch on access | shown | `ClyDebugWatchOnVariableReadWriteCommand` |
| Watch on read | menu Debugging points ▸ Watch on read | shown | `ClyDebugWatchOnVariableReadCommand` |
| Watch on write | menu Debugging points ▸ Watch on write | shown | `ClyDebugWatchOnVariableWriteCommand` |
| Browse | menu Query ▸ Browse | shown | `SycBrowseVariableCommand` |
| Inspect value | menu Query ▸ Inspect value<br>double click<br>⌘I | shown | `SycInspectVariableValueCommand` |
| References | menu Query ▸ References<br>⌘N | shown | `ClyShowVariableRefCommand` |
| Writers | menu Query ▸ Writers<br>⌘M | shown | `ClyShowVariableWriterCommand` |

## Method pane

| Command | How you reach it | Mark | Class |
|---|---|---|---|
| Debug test setup | menu Debug test setup<br>⇧⌘D | shown | `ClyDebugTestSetupCommand` |
| Debug tests | menu Debug tests<br>⌘D | shown | `ClyDebugTestCommand` |
| (T) Deprecate method | menu (T) Deprecate method | shown | `SycDeprecateMessageCommand` |
| Hierarchical implementors | menu Hierarchical implementors<br>⌘H | shown | `ClyShowMethodInheritanceCommand` |
| Hierarchical senders | menu Hierarchical senders | shown | `SycShowLocalSendersCommand` |
| Profile method | menu Profile method | shown | `SycProfileTestMethodCommand` |
| (R) Remove | menu (R) Remove<br>⌘X | shown | `SycRemoveMethodCommand` |
| (R) Rename | menu (R) Rename<br>⌘R | shown | `SycRenameMessageCommand` |
| Run tests (method) | menu Run tests<br>icon in the list<br>⌘T | shown | `ClyRunCoveringTestMethodsCommand` |
| Run tests (method) | menu Run tests<br>icon in the list<br>⌘T | shown | `ClyRunTestsFromMethodsCommand` |
| Break on "node" | menu Method debug points ▸ Break on "node" | shown | `ClyAddBreakPointCommand` |
| Configure breakpoint on "node" | menu Method debug points ▸ Configure breakpoint on "node" | shown | `ClyAddAndConfigureBreakPointCommand` |
| Watch "node" | menu Method debug points ▸ Watch "node" | shown | `ClyAddWatchDebugPointCommand` |
| Classify methods | menu Method extra ▸ Classify methods | shown | `SycClassifyMethodsCommand` |
| Copy method name(s) to Clipboard (method) | menu Method extra ▸ Copy method name(s) to Clipboard | shown | `SycCopyMethodNameToClipboardCommand` |
| Copy test method selector(s) to Clipboard | menu Method extra ▸ Copy test method selector(s) to Clipboard | shown | `SycCopyTestMethodNameToClipboardCommand` |
| File out | menu Method extra ▸ File out | shown | `SycFileOutMethodCommand` |
| Inspect | menu Method extra ▸ Inspect | shown | `SycInspectMethodCommand` |
| Add argument | menu Method refactoring ▸ Add argument | shown | `SycAddMessageArgumentCommand` |
| (T) Find and Replace | menu Method refactoring ▸ (T) Find and Replace | shown | `SycFindAndReplaceMethodCommand` |
| Inline senders | menu Method refactoring ▸ Inline senders | shown | `SycInlineIntoLocalSendersMessageCommand` |
| Move to another class | menu Method refactoring ▸ Move to another class<br>drag and drop on a class | shown | `SycMoveMethodsToClassCommand` |
| Move to class side | menu Method refactoring ▸ Move to class side<br>⌘T, C | shown | `SycMoveMethodsToClassSideCommand` |
| Move to defining class | menu Method refactoring ▸ Move to defining class | shown | `SycMoveMethodsToTheDefiningClassCommand` |
| Move to instance side | menu Method refactoring ▸ Move to instance side<br>⌘T, I | shown | `SycMoveMethodsToInstanceSideCommand` |
| Move to package | menu Method refactoring ▸ Move to package<br>drag and drop on a package | shown | `SycMoveMethodsToPackageCommand` |
| (R) Pull up | menu Method refactoring ▸ (R) Pull up<br>⌘P, U | shown | `SycPullUpMethodCommand` |
| Push down | menu Method refactoring ▸ Push down<br>⌘P, D | shown | `SycPushDownMethodCommand` |
| Push down in some classes | menu Method refactoring ▸ Push down in some classes | shown | `SycPushDownMethodInSomeClassesCommand` |
| Remove all senders | menu Method refactoring ▸ Remove all senders | shown | `SycRemoveAllSendersCommand` |
| Remove and the ones in subclasses | menu Method refactoring ▸ Remove and the ones in subclasses | shown | `SycRemoveMethodsInHierarchyCommand` |
| Remove argument | menu Method refactoring ▸ Remove argument | shown | `SycRemoveMessageArgumentCommand` |
| (T) Replace senders | menu Method refactoring ▸ (T) Replace senders | shown | `SycReplaceMessageCommand` |
| Commit history | menu Query ▸ Commit history<br>tab icon | shown | `ClyIcebergShowMethodVersionCommand` |
| Implementors | menu Query ▸ Implementors<br>toolbar Implementors<br>⌘M | shown | `ClyShowMessageImplementorCommand` |
| Senders | menu Query ▸ Senders<br>toolbar Senders<br>⌘N | shown | `ClyShowMessageSenderCommand` |
| Versions | menu Query ▸ Versions<br>tab icon<br>⌘V | shown | `SycShowMethodVersionCommand` |
| Jump to test method | menu Sunit method ▸ Jump to test method<br>⌘H, J | shown | `ClyJumpToTestMethodCommand` |
| Open test method | menu Sunit method ▸ Open test method<br>⌘T, O | shown | `ClyOpenTestMethodCommand` |
| Find method | ⌘F | shown | `ClyFindMethodInBrowserCommand` |
| Open a submenu | ⌘T | shown | `ClyOpenMenuGroupCommand` |
| Run script | icon in the list | shown | `ClyRunClassScriptCommand` |
| Move to method group | drag and drop on all methods<br>drag and drop on an extension group<br>drag and drop on a protocol | hidden (no menu, toolbar or icon) | `ClyMoveMethodsToGroupCommand` |
| Copy method name(s) to Clipboard (method) | tab icon | duplicate (same action as `SycCopyMethodNameToClipboardCommand`, with a typo in its class name) | `SycCopyMethodNameToClypboardCommand` |

## Code editors

| Command | How you reach it | Mark | Class |
|---|---|---|---|
| Expand class definition | menu Expand class definition<br>menu Source code ▸ Expand class definition<br>⌘E | shown | `ClyExpandClassDefinitionCommand` |
| Abstract accessors | menu Source code ▸ Abstract accessors | shown | `SycAbstractVariableCommand` |
| Abstract instance variables | menu Source code ▸ Abstract instance variables | shown | `SycAbstractAllInstVarAccessorsCommand` |
| Add argument | menu Source code ▸ Add argument | shown | `SycAddMessageArgumentCommand` |
| Categorize all uncategorized | menu Source code ▸ Categorize all uncategorized | shown | `SycCategorizeAllUnclassifiedMethodsCommand` |
| (R) Convert to Instance Var | menu Source code ▸ (R) Convert to Instance Var | shown | `SycConvertTempToInstVarCommand` |
| (T) Deprecate method | menu Source code ▸ (T) Deprecate method | shown | `SycDeprecateMessageCommand` |
| Edit protocol | menu Source code ▸ Edit protocol<br>⌘E, P | shown | `ClyRequestProtocolForEditorCommand` |
| (R) Extract method (no occurrences) | menu Source code ▸ (R) Extract method (no occurrences)<br>⌘E, M, T | shown | `SycNewExtractMethodCommand` |
| (Old refactor) Extract method with occurrences | menu Source code ▸ (Old refactor) Extract method with occurrences<br>⌘E, M | shown (old refactoring engine) | `SycExtractMethodAndOccurrencesCommand` |
| Extract setUp | menu Source code ▸ Extract setUp | shown | `SycExtractSetUpCommand` |
| Extract temp | menu Source code ▸ Extract temp | shown | `SycExtractTempCommand` |
| (T) Find and Replace | menu Source code ▸ (T) Find and Replace | shown | `SycFindAndReplaceMethodCommand` |
| Format code | menu Source code ▸ Format code<br>⌘⇧F | shown | `SycFormatSourceCodeCommand` |
| Generate accessors | menu Source code ▸ Generate accessors | shown | `SycGenerateAllInstVarAccessorsCommand` |
| (T) Generate accessors | menu Source code ▸ (T) Generate accessors | shown | `SycGenerateVariableAccessorCommand` |
| (T) Generate lazy accessors | menu Source code ▸ (T) Generate lazy accessors | shown | `SycGenerateVariableAccessorsWithLazyInitializationCommand` |
| Hierarchical senders | menu Source code ▸ Hierarchical senders<br>⇧⌘Y | shown | `SycShowLocalSendersCommand` |
| Inline method | menu Source code ▸ Inline method | shown | `SycInlineMethodCommand` |
| Inline senders | menu Source code ▸ Inline senders | shown | `SycInlineIntoLocalSendersMessageCommand` |
| Inline temp | menu Source code ▸ Inline temp | shown | `SycInlineTempCommand` |
| Inspect node | menu Source code ▸ Inspect node | shown | `SycInspectNodeCommand` |
| Jump to test class | menu Source code ▸ Jump to test class | shown | `ClyJumpToTestClassCommand` |
| Merge into another | menu Source code ▸ Merge into another | shown | `SycMergeVariableCommand` |
| Migrate references | menu Source code ▸ Migrate references | shown | `SycMigrateReferencesOfClassCommand` |
| (R) Move temp. definition | menu Source code ▸ (R) Move temp. definition<br>⌘O | shown | `SycMoveTempDefinitionCommand` |
| (T) Move to class side | menu Source code ▸ (T) Move to class side | shown | `SycMoveInstanceVariableToClassSideCommand` |
| New protocol | menu Source code ▸ New protocol | shown | `SycAddNewProtocolCommand` |
| Protect | menu Source code ▸ Protect | shown | `SycProtectVariableCommand` |
| Push down | menu Source code ▸ Push down | shown | `SycPushDownVariableCommand` |
| (R) Push up | menu Source code ▸ (R) Push up | shown | `SycPushUpVariableCommand` |
| (T) Realize class | menu Source code ▸ (T) Realize class | shown | `SycRealizeClassCommand` |
| (R) Remove | menu Source code ▸ (R) Remove | shown | `SycRemoveClassCommand` |
| Remove | menu Source code ▸ Remove | shown | `SycRemoveVariablesCommand` |
| Remove all senders | menu Source code ▸ Remove all senders | shown | `SycRemoveAllSendersCommand` |
| Remove argument | menu Source code ▸ Remove argument | shown | `SycRemoveMessageArgumentCommand` |
| Remove empty protocols | menu Source code ▸ Remove empty protocols | shown | `SycRemoveEmptyMethodTagsCommand` |
| (R) Rename | menu Source code ▸ (R) Rename<br>⌘R | shown | `SycRenameMessageCommand` |
| Rename | menu Source code ▸ Rename<br>⌘R | shown | `SycRenameVariableCommand` |
| (R) Rename class | menu Source code ▸ (R) Rename class<br>⌘R | shown | `SycRenameClassCommand2` |
| (R) Rename temp | menu Source code ▸ (R) Rename temp<br>⌘R | shown | `SycRenameArgOrTempCommand2` |
| (T) Replace senders | menu Source code ▸ (T) Replace senders | shown | `SycReplaceMessageCommand` |
| Run test | menu Source code ▸ Run test<br>⌘E, T | shown | `SycRunTestCommand` |
| Select method package | menu Source code ▸ Select method package<br>⌘E, M, P | shown | `ClyRequestMethodPackageForEditorCommand` |
| Unclassify method | menu Source code ▸ Unclassify method<br>⌘E, U | shown | `ClyResetProtocolForEditorCommand` |
| Break on "node" | menu Source code debug points ▸ Break on "node"<br>left bar menu<br>left bar double click | shown | `ClyAddBreakPointCommand` |
| Configure breakpoint on "node" | menu Source code debug points ▸ Configure breakpoint on "node"<br>left bar menu | shown | `ClyAddAndConfigureBreakPointCommand` |
| Watch "node" | menu Source code debug points ▸ Watch "node"<br>left bar menu | shown | `ClyAddWatchDebugPointCommand` |
| Browse (class) | menu Source code query ▸ Browse | shown | `SycBrowseClassCommand` |
| Browse (variable) | menu Source code query ▸ Browse | shown | `SycBrowseVariableCommand` |
| Class refs. | menu Source code query ▸ Class refs. | shown | `ClyShowClassRefCommand` |
| Implementors | menu Source code query ▸ Implementors | shown | `ClyShowMessageImplementorCommand` |
| Inspect value | menu Source code query ▸ Inspect value<br>⌘I | shown | `SycInspectVariableValueCommand` |
| References | menu Source code query ▸ References | shown | `ClyShowVariableRefCommand` |
| Senders | menu Source code query ▸ Senders | shown | `ClyShowMessageSenderCommand` |
| Show pool users | menu Source code query ▸ Show pool users | shown | `ClyShowPoolUsersCommand` |
| Show trait users | menu Source code query ▸ Show trait users | shown | `ClyShowTraitUsersCommand` |
| Writers | menu Source code query ▸ Writers | shown | `ClyShowVariableWriterCommand` |
| go backward | ⌥← | shown | `ClyNavigateBrowserBackCommand` |
| go forward | ⌥→ | shown | `ClyNavigateBrowserForwardCommand` |
| Open a submenu | ⌘T | shown | `ClyOpenMenuGroupCommand` |
| Close the browser | ⌘W | hidden (no menu, toolbar or icon) | `ClyCloseBrowserCommand` |
| Open self context menu | left bar right click | hidden (no menu, toolbar or icon) | `ClyOpenTextLeftBarMenuCommand` |
| (Old refactor) Extract method (no occurrences) | menu Source code ▸ (Old refactor) Extract method (no occurrences)<br>⌘E, M | duplicate (older version of `SycNewExtractMethodCommand`) | `SycExtractMethodCommand` |
| (Old refactor) rename class | menu Source code ▸ (Old refactor) rename class | duplicate (older version of `SycRenameClassCommand2`) | `SycRenameClassCommand` |
| (Old refactor) rename temp | menu Source code ▸ (Old refactor) rename temp | duplicate (older version of `SycRenameArgOrTempCommand2`) | `SycRenameArgOrTempCommand` |

## Anywhere in the browser

| Command | How you reach it | Mark | Class |
|---|---|---|---|
| New class | menu New class | shown | `ClyCreateClassCommand` |
| New test class | menu New test class | shown | `ClyCreateTestCaseCommand` |
| New trait | menu New trait | shown | `ClyCreateTraitCommand` |
| Set up scope | menu Set up scope | shown | `ClySwitchToScopedModeCommand` |
| Browse | menu Query ▸ Browse<br>double click<br>⌘B | shown | `ClySpawnFullBrowserCommand` |
| Browse test class | menu Query ▸ Browse test class | shown | `ClyBrowseCoveringTestCaseCommand` |
| Find class | menu Query ▸ Find class<br>⌘F | shown | `ClyFindClassCommand` |
| Find method | menu Query ▸ Find method | shown | `ClyFindMethodInBrowserCommand` |
| Commit | ⌘S | shown | `ClyCommitPackageCommand` |
| go backward | tab icon<br>⌥← | shown | `ClyNavigateBrowserBackCommand` |
| go forward | tab icon<br>⌥→ | shown | `ClyNavigateBrowserForwardCommand` |
| New package | ⌘K, P | shown | `SycAddNewPackageCommand` |
| Close the browser | ⌘W | hidden (no menu, toolbar or icon) | `ClyCloseBrowserCommand` |
| Focus the next pane | → | hidden (no menu, toolbar or icon) | `ClySwitchFocusToNextBrowserPaneCommand` |
| Focus the previous pane | ← | hidden (no menu, toolbar or icon) | `ClySwitchFocusToPreviousBrowserPaneCommand` |

## Critiques

| Command | How you reach it | Mark | Class |
|---|---|---|---|
| Browse rule | menu Extra ▸ Browse rule | shown | `ClyBrowseCritiqueRuleCommand` |
| Ban the rule (×) | icon in the list | shown | `ClyBanCritiqueRuleCommand` |
| Debug the exception | icon in the list | shown | `ClyDebugBrokenCritiqueCommand` |
| Details (?) | icon in the list | shown | `ClyShowCritiqueDetailsCommand` |
| Fix it | icon in the list | shown | `ClyFixCritiqueCommand` |
| Show the dependency | icon in the list | shown | `ClyShowDependencyCritiqueCommand` |

## Old query browser (retired)

| Command | How you reach it | Mark | Class |
|---|---|---|---|
| Switch scope | menu Switch scope ▸ Switch scope<br>toolbar *(depends on the selection)* | retired (only in the old query browser) | `ClySwitchQueryScopeCommand` |
| Flat | toolbar Flat | retired (only in the old query browser) | `ClySwitchToFlatQueryResultCommand` |
| Hier. | toolbar Hier. | retired (only in the old query browser) | `ClySwitchToHierarchicalQueryResultCommand` |
| Run all tests of the list | toolbar Run all tests of the list | retired (only in the old query browser) | `ClyRunAllTestsFromMethodDataSourceCommand` |
| Run failed tests of the list | toolbar Run failed tests of the list | retired (only in the old query browser) | `ClyRunFailedTestsFromMethodDataSourceCommand` |

## Tabs

The tools shown under the panes (see the TAB feature sheet).

| Tool | Shown for |
|---|---|
| `ClyClassDefinitionEditorToolMorph` | class |
| `ClyRichTextClassCommentEditorToolMorph` | class |
| `ClyTestSetUpEditorToolMorph` | class |
| `RSMapBrowserToolMorph` | class |
| `ClyPackageRichTextCommentEditorToolMorph` | tag |
| `ClyClassCreationToolMorph` | tag |
| `ClyMethodCreationToolMorph` | protocol |
| `ClyMethodCodeEditorToolMorph` | method |
| `ClyMethodDiffToolMorph` | method |
| `DABrowserToolMorph` | package |

## List decorations

What adds icons, colours or styles to the rows of the panes. They are not commands: nothing to run, only something to see.

| Decoration | On |
|---|---|
| `ClyCommandBasedTableDecorator` | browser |
| `ClyAbstractClassTableDecorator` | class |
| `ClyClassIconTableDecorator` | class |
| `ClyUncommentedItemTableDecorator` | class |
| `ClyClassCommentTableDecorator` | class comment |
| `ClyGroupItemTableDecorator` | tag |
| `ClyProjectTableIndentationDecorator` | browser |
| `ClyClassSideBoldTableDecorator` | method |
| `ClyClassSideLinkTableDecorator` | method |
| `ClyAbstractMethodTableDecorator` | method |
| `ClyFFIMethodTableDecorator` | method |
| `ClyFlagMethodTableDecorator` | method |
| `ClyHaltMethodTableDecorator` | method |
| `ClyOverriddenMethodTableDecorator` | method |
| `ClyTraitMethodDecorator` | method |
| `ClyUndeclaredMethodTableDecorator` | method |
| `ClyDeprecatedItemTableDecorator` | selection |
| `ClyEmptyPackageTableDecorator` | package |
| `ClyPackageIconTableDecorator` | package |
| `ClyProjectIconTableDecorator` | project |
| `ClyCritiquesTableDecorator` | critique |
