# Feature sheets

The [inventory](../README.md) lists the 143 features in one line each. A **feature sheet** describes the features of one area (PKG, CLS, MGP, MTH, SEL, HIS, TAB, EDT, CMD, DEC, FLT, QRY, UPD, ENT, SET, BRW) completely, so that:

- **you** understand each feature and the code behind it, and approve the behaviour we keep;
- **the agent** has a full specification and never has to guess;
- **the tests** have agreed scenarios to implement (testing plan, T-08).

The sheets are working documents for us; they are not shipped with the code.

One file per area: `PKG.md`, `CLS.md`… Each sheet is written, then reviewed by you in its own text-only PR, before any code for that area. A sheet changes only through a reviewed PR; when the code teaches us something new, the sheet is updated first.

## Template

````markdown
# <AREA>: <area name>

Short overview: what this area is for the user, and the main classes behind it.

## <ID>: <feature name>   (tier M/P/X)

**Behaviour.** What the user does and sees, precisely (what is selected, what is shown, in which order, with which icon or style).

**How to trigger.** Mouse, menu, shortcut, toolbar, drag and drop; from which pane or context.

**Code.** The entry points, as `Class>>selector`, with one line each on their role. Where the rule lives (model, morph, command, decorator).

**Edge cases.** Empty selection, several items, class side, extensions, traits, filtered lists, read-only code…

**Existing tests.** Calypso tests that already cover it (`Class>>test…`), or "none".

**Scenarios.**
- `<ID>.a` Given … when … then … → `TestClass>>testSelector` (once written)
- `<ID>.b` …

**Manual check.** Exact steps if a real key press, drag or visual check is needed (T-09), otherwise "none".

**Notes.** Bugs, pain points, gaps (B-xx, P-xx, G-xx), open questions for you.
````

## Rules

- Scenario IDs (`SEL-01.a`) never change once agreed; a removed scenario is marked as removed, not renumbered.
- When a scenario's test is written, the sheet names it after the scenario: `` `SEL-01.a` Given … then … → `ClySpSelectionTest>>testSameSelectorStaysSelectedWhenChangingClass` ``. The [progress board](../../progress.md) is built from these links.
- The link goes one way only: the code never refers to the sheets or their IDs (testing plan, T-10).
- Code entry points are checked in the image when the sheet is written (the agent reads the code, not memory), and say which Pharo 15 build they were read on.
