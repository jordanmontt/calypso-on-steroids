# How Calypso works

An explanation of today's Calypso (Pharo 15), written to understand what the Spec version keeps, what it replaces, and why the plan is ordered the way it is. It is based on the code and on the [walkthrough](features/walkthrough.md). Class names are real; read their class comments for more.

## The layers

```
┌────────────────────────────────────────────────────────────────────────────┐
│ UI (Morphic)                                                               │
│  Calypso-Browser            browser framework: ClyBrowserMorph, panes      │
│                             (ClyQueryViewMorph + ClyDataSource), notebook, │
│                             toolbar, status bar, history, table decorators │
│  Calypso-SystemTools-*      the system browsers: ClyFullBrowserMorph,      │
│                             ClyQueryBrowserMorph, editors (tools), contexts│
│  Calypso-SystemPlugins-*-Browser   UI part of plugins (decorators, tools)  │
├────────────────────────────────────────────────────────────────────────────┤
│ Commands                                                                   │
│  Calypso-Commands           ClyCommand (Commander2), ClyCommandMap,        │
│                             ClyCommandRegistry, ClyToolContext, menus      │
│  SystemCommands-*           the commands themselves (Syc*): refactorings,  │
│                             renames, removals… (loaded before Calypso)     │
├────────────────────────────────────────────────────────────────────────────┤
│ Model (no UI)                                                              │
│  Calypso-NavigationModel    generic: environment, scopes, queries, results,│
│                             browser items, properties, async queries       │
│  Calypso-SystemQueries      the Pharo system: packages, classes, methods,  │
│                             groups, variables, hierarchies, plugins        │
│  Calypso-SystemPlugins-*-Queries   plugin model: tests, critiques, traits… │
└────────────────────────────────────────────────────────────────────────────┘
```

The project keeps the two lower layers and replaces the top one.

## The model in five ideas

1. **Environment** (`ClyNavigationEnvironment`): the entry point. It knows the system (`ClySystemEnvironment`, the image's globals), caches query results, and is told about system changes.
2. **Scope** (`ClyScope` subclasses): "where to look", built from objects. `ClyPackageScope of: aPackage`, `ClyClassScope of: aClass`, `ClyInstanceSideScope`/`ClyClassSideScope` (meta-level), `ClySuperclassScope` (inherited methods), `ClySystemEnvironmentScope` (everything).
3. **Query** (`ClyQuery` subclasses): "what to look for" in a scope. `ClyAllClassesQuery`, `ClyAllMethodGroupsQuery`, `ClyMessageSendersQuery of: #x`, `ClyVariableReferencesQuery`… Queries are values: two equal queries share one cached result.
4. **Result** (`ClyQueryResult`): the items of a query, kept up to date when the system changes, possibly **sorted**, **hierarchical** (`ClyHierarchicallySortedClassesResult`) or computed **asynchronously** (`ClyAsyncQueryResult`). Browsers read results through a cursor of `ClyBrowserItem`s.
5. **Browser item** (`ClyBrowserItem`): wraps an object (a class, a method, a group) with what a browser needs: name, position, depth, and **properties** (tags such as "abstract", "deprecated", "has failed tests") added by **environment plugins** (`ClySystemEnvironmentPlugin` subclasses, one per plugin package). Items have a *type* (`ClyClass`, `ClyMethod`, `Package`…) independent of the object's class.

Groups are model objects too: a protocol is a `ClyMethodsInProtocolGroup`, "extensions" a `ClyExternalPackageMethodGroup`, "instance side" a `ClyAllMethodGroup` carrying **visibility levels** (`ClySuperclassVisibilityLevel`…), which is how the inherited-method checkboxes are modelled.

## The life of a click in the full browser

Selecting a class in the class pane:

1. The pane (`ClyQueryViewMorph`) turns the FastTable selection into a `ClyDataSourceSelection` and records it as the **desired selection** (because the user did it).
2. The pane asks the browser to navigate: `requestNavigationBy: #classSelectionChanged` → `ClyFullBrowserMorph>>classSelectionChanged`.
3. Inside `changeStateBy:` the browser:
   - in hierarchy mode, silently selects the class's package (`silentlySelectPackageOfSelectedClass`);
   - builds the **method-group query** for the selected classes, at the current meta-level and visibility (`methodGroupQuery restrictedByScope: …`), handling extended classes (`adoptForExtendedClass`) and selecting the extension group if needed;
   - the method-group pane shows the new query; it **restores its desired selection** (same group name if it exists) without firing a new navigation; the method pane follows.
4. When the state change ends, the browser: creates a **context** for the new selection (`ClyFullBrowserClassContext`, chosen by `<calypsoSelectionContext>` declarations), updates the **tabs** (`ClyNotebookManager>>updateTools`: wanted tools from the `tabs` declarations of the context's anchors, reuse similar ones, keep dirty ones, select by priority among the desired tabs), rebuilds the **toolbar**, updates the **title**, records a **history** state (`ClyFullBrowserState`).

Each pane cell is rendered by `ClyItemCellMorph`, then **decorated**: table decorators declared for the item's context, by priority, write icons, fonts and colours into the cell; groups decorate their own cells (`decorateTableCell:of:`), which is where the visibility checkboxes come from.

## Contexts and commands

A **context** (`ClyToolContext` subclasses) is what commands see: the tool, the selected items, and convenience queries (`selectedMethods`, `lastSelectedClass`, `isMethodSelected`…). There is one context class per kind of selection per browser (`ClyFullBrowserMethodContext`, `ClyQueryBrowserContext`, `ClyMethodSourceCodeContext` for the editor…).

Commands are **declared, not wired**. A class-side method marked `<calypsoCommands>` on an *anchor* (a context class or an item type like `ClyMethod`) adds commands to the interactions of a `ClyCommandMap`:

```smalltalk
ClyMethod class >> calypsoSystemToolsCoreCommandsIn: aCommandMap
	<calypsoCommands>
	aCommandMap contextMenu add: SycRemoveMethodCommand order: 10000.
	aCommandMap shortcuts add: SycRemoveMethodCommand key: $x meta.
	aCommandMap tabs add: ClyMethodCodeEditorToolMorph
```

When the user right-clicks, the pane asks `ClyCommandRegistry` for the `#contextMenu` entries of its context, creates each command in the context, keeps those that `canBeExecuted` and are `isAvailableInMenuOf:`, builds a tree of `ClyMenuGroup`s (`ClyCommandGroupBuilder`) and renders it as a Morphic menu (`ClyCommandGroupMenuRenderer`). Shortcuts, clicks, double clicks, drag and drop, table icons, tab actions and the toolbar work the same way with their own interaction. The same declarations also list the **tabs** and the **table decorators** for an anchor.

This is the part that makes a Spec port realistic: the command layer is data plus Commander2 commands, and only the *renderers* (menu, toolbar, key dispatcher, table icons) are Morphic.

## Tools (tabs)

A tool is a `ClyBrowserToolMorph` subclass created for a context. Its lifecycle, called by `ClyNotebookManager`:

| Message | Purpose |
|---|---|
| `shouldBeActivatedInContext:` (class side) | Does it apply to this selection? |
| `setUpModelFromContext`, `setUpParametersFromModel` | Take the model (the method, the class) |
| `build` | Build the widgets (in background) |
| `isSimilarTo:` | Is an open tool equivalent? Then reuse it |
| `tabOrder`, `activationPriority` | Position and selection priority |
| `hasUnacceptedEdits`, `updateDirtyState` | Dirty state |
| `belongsToCurrentBrowserContext`, `warnUserAboutDifferentContext` | Dirty tool kept while the selection moved |
| `belongsToRemovedBrowserContext` | Close when the model is removed |
| `attachToSystem`, `detachFromSystem`, `update` | Follow model changes |
| `fillStatusBar` | Status bar items |

Text tools (`ClyTextEditorToolMorph`) wrap a Rubric text morph and add: syntax styling, a left bar of icons (debug points, critiques), the Calypso text editor (`ClyTextEditor`) that sends browse/senders/implementors requests to the browser, and the source-code context (`ClyMethodSourceCodeContext`) built from the AST node under the cursor.

## Updates from the system

System announcements (method added, class renamed…) reach the environment, which updates cached query results. Results notify their data sources; data sources register with `ClyDataSourceUpdateScheduler`, which runs updates later, from a low-priority process, through `UIManager default defer:`. When a pane's items change, its selections (main, desired, highlighted) are recomputed silently, and tools are updated or closed.

## History

A browser state (`ClyBrowserState`, `ClyFullBrowserState`) is a snapshot of every pane's state (query, selection, expansion), the selected tabs, the meta-level and the method-group query. `ClyNavigationHistory` keeps undo and redo lists of states; restoring a state re-applies it silently. A spawned browser starts with a `ClyAccrossWindowNavigationState` pointing to the original window.

## Where Spec is already used

- The notebook: `ClyNotebookMorph < SpNotebookMorph`, `ClyNotebookPageHeaderPresenter < SpPresenter`.
- The dialogs: "Choose class", "Choose package for method" (`StBrowserSearchPresenter`), confirmations (`SpModalWindowPresenter`).
- Senders, implementors and references: `StMethodBrowser` (NewTools-MethodBrowsers).

## What this means for the Spec version

| Part | Keep | Replace | Refactor first (in Pharo) |
|---|---|---|---|
| Environment, scopes, queries, results, items, plugins | ✔ | | |
| Commands (`Syc*`, `Cly*Command`), command maps, registry, contexts | ✔ | | presentation hints for the 6 widget-building methods (R-04) |
| Menu, toolbar, shortcut, click, drag-and-drop, table-icon renderers | | ✔ (Spec renderers) | |
| Panes (`ClyQueryViewMorph`, `ClyDataSource*`) | | ✔ | selection rules out of the view (R-02) |
| Table decorators | rules | ✔ rendering | decorations as descriptions (R-03) |
| Browser navigation rules (`ClyFullBrowserMorph`) | rules | ✔ shell | navigation model out of the morph (R-01) |
| Tools (tabs) | lifecycle | ✔ widgets | lifecycle contract independent of morphs (R-05) |
| History, browser states | ✔ | | |
| Query browser | | already replaced by `StMethodBrowser` | fix bug B-02, decide the fate of `ClyQueryBrowserMorph` (D-08) |
