# Testing plan

Status: **approved on 2026-11-19** (points T-01..T-09). Updated the same day: scenarios live in the feature sheets, and the code never refers to the docs (T-07, T-08, T-10).

Calypso is the tool every Pharo developer uses all day, and this code goes to the main Pharo repository. So the testing plan has one goal: **no change reaches Pharo unless we can show that nothing the user relies on is broken.**

## Principles

- **T-01. Always TDD.** The failing test is written first, then the code. Before a refactoring of Calypso, the test that pins today's behaviour is written and green first, and stays green after the refactoring.
- **T-02. You validate everything before a commit.** Nothing is committed (here or upstream) until you have reviewed the code and the tests, and you have done the manual checks of that change. See [the validation workflow](#validation-workflow-for-each-pr).
- **T-03. SUnit only, no Hera for now.** Acceptance tests are plain SUnit tests written through a browser driver. They need no new dependency, so they can move to Pharo with the code and run in Pharo's CI. Hera can be added later as a layer over the same driver if it becomes worth it.
- **T-04. Tests use fixtures, never the live image.** The Calypso test packages already provide them (`Calypso-SystemQueries-Tests-P1WithHierarchy`, `-P5WithTags`, `ClyClassScriptsExample`…). New fixtures go to a dedicated fixtures package.
- **T-05. Tests are clean.** A test that opens a window closes it, and leaves no extra windows or processes (checked by the test base class). No `Delay` waits: a test waits for the UI to be idle through a helper (pain point P-08).

## The five layers

| # | Layer | What it protects | Runs |
|---|---|---|---|
| 1 | **Existing Calypso suites** (about 800 tests, 159 of them UI tests, all green on 2026-11-16) | Today's browser and model | Every Calypso PR to Pharo, and our CI |
| 2 | **Unit tests** | Each new class: model objects from the refactorings, presenters, helpers | CI, every PR |
| 3 | **Acceptance tests** | What the user sees and does, one or more tests per feature of the [inventory](features/README.md) | CI, every PR |
| 4 | **Command placement parity** (generated) | The 397 command entries appear in the same places in Spec as in Morphic | CI, every PR |
| 5 | **Manual checks by you** | What automated tests cannot reach reliably: real key presses, drag and drop, look and feel | Each PR, before commit |

### 1. Existing Calypso suites

They are not changed by us, except to add tests. A Calypso refactoring PR (R-01..R-05) or bug fix (B-01..B-05) to Pharo must keep all of them green.

### 2. Unit tests

- Each model object added by a refactoring (navigation model, decoration description, selection rules, tool contract) is tested with no UI at all.
- Each Spec presenter is built on fixtures and tested without opening a window when possible (Spec presenters can be built and queried without a window).

### 3. Acceptance tests

**What they are.** A test describes what a user does and sees, in browser terms, without touching widgets:

```smalltalk
testSameSelectorStaysSelectedWhenChangingClass
	"Lets the user compare the implementations of one selector along a hierarchy"
	browser openOnPackageNamed: 'Calypso-SystemQueries-Tests-P1WithHierarchy'.
	browser selectClassNamed: 'ClyClass1FromP1Mock'.
	browser selectMethodNamed: #tag1Method1.

	browser selectClassNamed: 'ClySubclassN1OfClass1FromP1Mock'.

	self assert: browser selectedMethodNames equals: #(tag1Method1)
```

**The driver.** `browser` above is a driver: an object that speaks in browser terms (open, select a package/class/protocol/method, read what a pane shows, run a menu item, run a shortcut, read the tabs…). There are two drivers with the same messages:

```
acceptance test (SUnit, per area, named and commented by behaviour)
        │
        ▼
driver ──┬── Morphic driver : today's ClyFullBrowserMorph, through its API
         │                    (selectClass:, methodView…) and ClyCommandRegistry
         └── Spec driver    : the new Spec browser, through its presenters
```

- Each acceptance test class has two concrete subclasses, one per driver, so **the same tests run on both browsers**. A test that passes on Morphic and on Spec proves parity for that feature.
- **T-06. The Morphic driver is limited** (decision D-04): it covers selection, history, tabs, and the areas touched by the refactorings R-01..R-05. Its job is to pin today's behaviour before we change Calypso. The Spec driver covers everything.
- A test that only makes sense in one browser lives only in that browser's class.
- No interface class: a test checks that both drivers understand the same selectors.

**Linking scenarios and tests.** **T-07.** The link goes from the docs to the code, never the reverse: each scenario in a feature sheet names the test that implements it (`ClySpSelectionTest>>testSameSelectorStaysSelectedWhenChangingClass`). The tests carry no doc IDs and no pragmas. The test class groups an area (its comment says in a sentence or two what the area does for the user), the selector says the behaviour, and a one-line comment is added only when it says something the code does not, usually why the behaviour matters. So the tests stay meaningful when the docs are gone. The [progress board](progress.md) is generated from the sheets by dev-only tooling, which also lists agreed scenarios with no test and sheet links to tests that no longer exist.

**Scenarios first, as text.** **T-08.** Before tests are written for an area, the scenarios are listed in plain English (in the [feature sheet](features/sheets/README.md) of the area, e.g. "Given a class with a selected method, when I select a subclass, then the same method is selected"). You review them: is this the behaviour we want to keep? Each scenario then becomes a test, written first (red) in the PR that implements it.

**Known bugs.** The four bugs found (B-01..B-05) get tests describing the *correct* behaviour. On Morphic they are marked as expected failures until the Pharo fix is merged; the Spec browser must pass them.

### 4. Command placement parity (generated)

397 command entries cannot be tested by hand, and their behaviour is already covered by Calypso's tests and is UI-independent. What we check is their **placement**:

- For a set of fixture contexts (a package, a class, a class side, a protocol, a method, several methods…), the test asks `ClyCommandRegistry` what each interaction should offer (context menu tree, toolbar, shortcuts, table icons, tab actions, double click, drop targets), and compares it with what the browser under test offers.
- It is written first against the Morphic browser, where it must pass, then runs on Spec.
- Each kind of interaction also gets one hand-written acceptance test (open a menu and run an item, run a shortcut, click a table icon, double-click, drop, tab action), plus one per shared shortcut (CMD-02, pain point P-11).
- The catalogue generator (PR 0.4) fails when Calypso adds or removes a command, so a new command never silently goes missing from the Spec UI.

### 5. Manual checks by you

**T-09. Keyboard bindings and drag and drop are checked by you, by hand, for every PR that affects them.** Synthetic key events sent to the world did not reach Calypso's key dispatcher, and simulated drags are not reliable.

- Automated tests still cover the *logic*: which command a key resolves to in a given context is asked to the dispatcher or the registry directly; what a drop does is tested through the command. What only you check is that the real key press or drag reaches it.
- For each PR, I write the exact steps in the PR description ("open a browser on `ClyClass1FromP1Mock`, select `tag1Method1`, press ⌘T, expect: the test runs and the method icon turns green"). You do them, and tell me the result. A failed check blocks the commit.
- The list K-1..K-8 in the [walkthrough](features/walkthrough.md#manual-checks-keyboard-drag-and-drop) is the starting set; it grows with each PR.

## Validation workflow for each PR

1. **Scenarios agreed.** The PR's scenarios are in the reviewed feature sheets (for refactorings: the behaviour to pin).
2. **Red.** I write the tests first and show them failing (or, for a refactoring, show the pinning tests green on today's code).
3. **Green.** I write the code until the new tests pass.
4. **Everything else still green.** I run, in the image: our unit and acceptance tests, the parity test, and the Calypso suites.
5. **Your review.** I open the changes for you in the image (Obscure Code Reviewer) and give you the list of manual checks with exact steps.
6. **Your manual checks.** You run them and report; the result goes to `docs/manual-checks.md`, which feeds the progress board. Problems go back to step 3.
7. **Commit only on your explicit OK.** Then push and open the PR; CI must be green before merge.

## Where tests run and live

- **In the image:** the Test Runner (or the MCP `test_run`), during development.
- **On CI:** smalltalkCI on Pharo 15 (GitHub Actions), every PR. It uses the latest Pharo 15 build, like the development image.
- **Once integrated in Pharo** (decision D-03): the tests move with the code into the Pharo repository and run in Pharo's CI. This is possible because they are plain SUnit (T-03).

## Points to agree

| Id | Point |
|---|---|
| T-01 | Always TDD, pinning tests before refactorings |
| T-02 | Nothing is committed before your review and manual checks |
| T-03 | SUnit with a browser driver; no Hera for now |
| T-04 | Fixtures only |
| T-05 | No window or process leaks; no `Delay` waits |
| T-06 | Two drivers; Morphic driver limited to what the refactorings touch |
| T-07 | Sheets link scenarios to tests; tests carry no doc IDs; the progress board is generated from the sheets |
| T-10 | Shipped code and tests never depend on or refer to the docs (no doc IDs, links or files); the docs are not shipped. PRs may reference the docs |
| T-08 | Scenarios as plain text in the feature sheets, reviewed by you before their tests |
| T-09 | Keyboard and drag and drop: logic tested automatically, real gestures checked by you per PR with exact steps |
