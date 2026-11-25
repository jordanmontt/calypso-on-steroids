# PKG: package pane

Status: **reviewed** 2026-11-25 (manual checks done for PKG-04, 07, 08). Code read on Pharo 15 build 145, 2026-11-24.

The first pane: the packages of the image (or the projects), with their tags as children. Its selection decides the classes shown (SEL-05).

- Built by `ClyFullBrowserMorph>>newPackageView`: a tree (`Project → packages`, `Package → tags`), a regex filter, and `#packageSelectionChanged`.
- Its content is a query: `switchToPackages` (`ClyAllPackagesQuery`) or `switchToProjects` (`ClyAllProjectsQuery`), both sorted.

## PKG-01: All packages, sorted (M)

**Behaviour.** The default mode lists every package of the image, sorted by name, with a package icon. Packages with tags have an expand triangle; deprecated packages are struck out (DEC).

**Code.** `ClyFullBrowserMorph>>switchToPackages`, `ClyAllPackagesQuery sortedFrom:`.

**Existing tests.** The queries have model tests in `Calypso-SystemQueries-Tests`; none through the pane.

**Scenarios.**
- `PKG-01.a` Given a new browser, then the package pane lists the packages of the image sorted by name.

**Manual check.** None.

## PKG-02: Tags as children (M)

**Behaviour.** A package expands to its tags, plus "Uncategorized" (blue, virtual: its classes without a tag, only when it has tags) and "Extensions" (blue, virtual: the classes it extends, only when it extends some). Selecting a tag shows only its classes.

**Code.** `Package class>>prepareClassGroupQueryFrom:in:` (`ClyAllPackageTagsQuery`); `ClyNoTagClassGroup`, `ClyTaggedClassGroup`.

**Scenarios.**
- `PKG-02.a` Given a package with tags, a class without tag and an extension, when I expand it, then it shows "Uncategorized", its tags and "Extensions".
- `PKG-02.b` Given a tag selected, then the class pane lists only the classes of that tag.

**Manual check.** None.

## PKG-03: Projects mode (P)

**Behaviour.** "Projects" in the toolbar lists the baselines of the image (project icon), each expanding to its packages and their tags. The package selection is dropped and comes back when switching back to "All Packages" (SEL-01.d).

**Code.** `ClySwitchToProjectsCommand`, `ClyFullBrowserMorph>>switchToProjects` (`ClyAllProjectsQuery`); `Project class>>prepareProjectItemsQueryFrom:in:`; `ClyProjectTableIndentationDecorator`.

**Scenarios.**
- `PKG-03.a` Given a baseline in the image, when I switch to Projects, then it is listed and expands to its packages.

**Manual check.** None.

## PKG-04: Regex filter, shared by new browsers (M)

**Behaviour.** The filter under the pane is a regex, applied after a short typing delay, and keeps the selection. Each change is stored for the whole image: a new browser opens with the last filter typed in any browser.

**Code.** `enableFilterUsing: ClyRegexPattern new` in `newPackageView`; `updateDefaultPackageFilter` (on each `RubTextChanged`, stores the class variable `DefaultPackageFilter`); `prepareDefaultState` (`activateFilterWith:`).

**Edge cases.** An invalid regex; clearing the filter (stored as nil).

**Scenarios.**
- `PKG-04.a` Given `Kernel.*` typed in the package filter, then only packages matching it are listed.
- `PKG-04.b` Given then, when I open a new browser, then its package filter is `Kernel.*`.

**Manual check.** The typing delay. Checked 2026-11-25.

## PKG-05: Package commands (M)

**Behaviour.** The package menu and shortcuts: new package (⌘K,P), rename (⌘R), remove (⌘X), duplicate (⌘C), new tag, commit (⌘S), browse critiques and dependencies, run tests (⌘T and the test icon), Scopes ▸, Extras ▸ (file out, recompile, inspect…).

**Code.** Catalogue sections `Package`, `ClyFullBrowserPackageContext`, `ClyFullBrowserProjectContext`.

**Scenarios.** The command placement check (C3) covers which commands are offered; their behaviour belongs to the `Syc…`/`Cly…` commands and their tests.

**Manual check.** None.

## PKG-06: Tag commands (P)

**Behaviour.** On a tag: Browse, Rename, New tag, Remove, Extras ▸.

**Code.** Catalogue sections `ClyTaggedClassGroup`, `ClyClassGroup`; `ClyRenamePackageTagCommand`, `ClyRemoveClassGroupCommand`.

**Scenarios.** Covered by C3.

## PKG-07: Drop classes on a package or tag (P)

**Behaviour.** Dragging classes onto a package, a tag or "Uncategorized" moves them there. Hovering a collapsed package during the drag expands it after a delay (SET-04).

**Code.** `ClyMoveClassToGroupCommand` (catalogue, `dragAndDrop` on `Package`, `ClyTaggedClassGroup`, `ClyNoTagClassGroup`); `ClyQueryViewMorph>>wantsDropPassenger:at:`, `isReadyToExpandForDrop:`.

**Existing tests.** `ClyQueryViewMorphShouldExpandTest` (the expand delay).

**Scenarios.**
- `PKG-07.a` Given class C in package P, when it is dropped on tag T of package Q, then C is in Q with tag T.

**Manual check.** The drag itself, and the expand on hover (T-09). Checked 2026-11-25.

## PKG-08: Drop methods or protocols on a package (P)

**Behaviour.** Dropping methods on a package makes them extensions of it; dropping a protocol converts it to an extension of that package.

**Code.** `SycMoveMethodsToPackageCommand`, `ClyMoveMethodGroupsToPackageCommand` (catalogue, `dragAndDrop` on `Package`).

**Scenarios.**
- `PKG-08.a` Given method `x` of class C, when it is dropped on package Q, then `x` is an extension of Q.

**Manual check.** The drag itself (T-09). Checked 2026-11-25.

## PKG-09: Package comment tab (M)

**Behaviour.** Selecting a package shows its comment, rendered as Microdown and editable like the class comment (EDT-06).

**Code.** `ClyPackageRichTextCommentEditorToolMorph` (BeautifulComments, an external tool, TAB-13).

**Scenarios.**
- `PKG-09.a` Given a package selected, when I change its comment and accept, then the package has the new comment.

**Manual check.** None.

## PKG-10: Dependencies tab (M)

**Behaviour.** Selecting a package shows the dependency analyser of that package as the first tab (order −10). It stays when a class of the package is selected.

**Code.** `DABrowserToolMorph` (Tool-DependencyAnalyser-UI, external, TAB-13).

**Scenarios.** Covered by `TAB-13.a`.

## PKG-11: Selecting a package opens the class-creation tab (M)

**Behaviour.** With a package or tag selected and no class, the class-creation tab is shown and selected, its template naming the package and tag (EDT-05). In Projects mode with nothing selected, the package is `_Unpackaged`.

**Code.** `ClyClassCreationToolMorph` (EDT-05); its activation in TAB-03.

**Scenarios.**
- `PKG-11.a` Given a package selected and no class, then the class-creation tab is selected.

**Manual check.** None.
