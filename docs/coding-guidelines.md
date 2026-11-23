# Coding guidelines

The code browser is the most used tool of Pharo, and it will be maintained by people who did not write it. These rules exist so that the new code stays understandable. A PR that breaks one of them is not merged, however well it works.

## Architecture rules

1. **Presenters render and forward, nothing more.** A presenter shows model objects and turns user gestures into messages to a model (navigation model, command, tool model). Navigation rules (what happens when a class is selected) live in model objects with unit tests, never in presenters.
2. **Commands are not touched for UI reasons.** The Spec UI uses `ClyCommandRegistry` and the `ClyToolContext` contract as they are. If a command needs a change, it is a Calypso PR.
3. **The model is not changed** except through an agreed refactoring (`pain-points.md`, R-0x) merged in Pharo first.
4. **No Morphic in Spec code.** Spec presenters do not reference morphs. Bridging code (Spec inside Morphic, Morphic inside Spec) lives only in the bridge package and is deleted at the end.
5. **No Spec patches here.** Missing Spec features go upstream (`spec-gaps.md`). A temporary workaround is allowed only if it is local, documented in `docs/workarounds.md` with the upstream link, and removed when the upstream PR is merged.
6. **One way to do each thing.** For instance there is one decoration description, one tool contract, one command renderer. No parallel mechanisms "for now".

## Smalltalk style

- Small methods, intention-revealing selectors, one level of abstraction per method.
- Class comments for every class: first sentence for users of the class (what it is), then responsibilities and collaborators. Commands' first paragraph is the tooltip (`ClyCommand>>#description`).
- No abstract "interface" classes made only of `subclassResponsibility`. Use polymorphism; add an abstract superclass only when it holds real shared state or behaviour. Tests substitute stub subclasses.
- No `isKindOf:`/`respondsTo:` type switches; ask the object.
- Never catch and swallow exceptions; never answer `nil` as a failure signal unless `nil` is part of the documented contract.
- Never write to the Transcript.
- No `fork`/background processes in UI code. Background work stays in the model's existing async queries; results reach the UI only on the UI thread.
- Names: class prefix `ClySp` for Spec presenters and their models (decision D-01), packages `Calypso-Spec-*`. No typos, no historical names (`TabManager`, "data source" for a list model).

## Tests

- Always TDD: write the failing test first (unit test or acceptance scenario), then the code. Before a refactoring, the test that pins today's behaviour is written and green first.
- Every PR comes with tests: unit tests for the code it adds, and acceptance tests for the scenarios it claims.
- **The code never refers to the docs.** No feature, scenario, gap or decision IDs, links or file names in classes, methods, comments or tests: the docs are not shipped. The docs point to the code, not the reverse. PR descriptions may reference the docs.
- **Comments add, never repeat.** A comment is welcome when it says what the code cannot: why, a non-obvious rule, a pitfall. It never restates the selector or the code, and stays short (one or two lines). Every class has a short class comment.
- Tests use fixtures, not the live image contents.
- UI tests close every window they open and leave no extra processes.

## Commits and pull requests

- **One commit, one goal.** Each commit does one thing you can review on its own (a refactoring, one behaviour, one test fixture…), and leaves everything green. Refactoring and behaviour change are never in the same commit.
- **A PR is a small set of such commits:** one concern, under ~400 changed lines of code (generated files and docs excluded).
- **Described:** the PR description lists the feature IDs and scenarios covered, the upstream PRs it depends on, how to try it in the image, the manual checks, and the code tour of each commit (template: `.github/pull_request_template.md`).
- **Green:** CI green, existing Calypso suites green.
- **Usable:** when a PR adds something user-visible, it is reachable behind the experimental setting so it can be tried.

## Code tour of each commit

You do not know Calypso's code yet, and the goal is that by the end of the project you understand its model, its interactions and the ideas behind them (less so its Morphic code, which is dropped). So each commit comes with a **code tour**, given in the chat when the commit is ready for review and copied into the PR description. You learn by doing and thinking, so the tour is mostly code and pointers, very little prose:

````markdown
### <commit title>
**Goal.** One line.
**Read, in this order.** `Class>>selector` (a few words at most), senders/implementors to follow, the test that shows the behaviour.
**Try.** Playground snippets to evaluate, inspect or debug step by step:
    browser := ClyFullBrowserMorph openOnClass: Point.
    browser navigationEnvironment inspect.
**Think.** One to three questions to answer by yourself ("why is the query built before the scope?", "what breaks if this method answers nil?"). Answers only when you ask.
````

- No paragraph of explanation where a snippet or a pointer does the job: too much text gives the illusion of learning.
- Tours favour Calypso's model and interactions (environments, scopes, queries, results, contexts, commands, tools) over Morphic details.
- You take your time: the next commit waits until you are done with this one.

## Working process

- **You are in control.** I propose, you decide: each step starts with your go, each commit waits for your OK after your review and manual checks, nothing is pushed without your OK. No new document is created without your OK (the list is in [CLAUDE.md](../CLAUDE.md)).
- **Branches.** One branch per PR, named after the PR id (`pr-0.2-baseline`). You may ask to merge straight to `main` instead of opening a PR (as for the docs on 2026-11-23).
- **Review.** For each commit: the code tour, your review in the image (Obscure Code Reviewer), the manual checks with exact steps (testing plan, T-09), then your OK and the commit.
- **Upstream.** Every issue or PR to Pharo or Spec is tracked in [upstream.md](upstream.md) with its status and the step it blocks. You open them, from your accounts, after reviewing them. Temporary workarounds are listed in [workarounds.md](workarounds.md).
- **Syncing with Pharo 15.** Pharo 15 changes daily. The image is rebuilt from the recipe (`docs/rebuild.md`, step B1) every week and whenever an upstream PR we need is merged; then the catalogue and the baseline tests are re-run to detect changes in Calypso.
- **Handing over between sessions.** At the end of a session, the "Current state" section of [CLAUDE.md](../CLAUDE.md) is updated (what was done, the next step, open questions), and committed with your OK. A new session starts from there.

## Documentation

The docs must stay small enough to read, without losing what you or the agent need to understand.

- **One fact, one place.** Every fact lives in exactly one document; the others link to it. A bug is described in the walkthrough, a decision in the plan, a feature's behaviour in its sheet.
- **Layers.** Short overviews for orientation (README, [plan](plan.md), [architecture](calypso-architecture.md)); details in the [feature sheets](features/sheets/README.md), one per area, read only when working on that area; lookups in generated files ([command catalogue](features/command-catalogue.md), [progress board](progress.md)), which are never read end to end and never edited by hand.
- **Budgets.** An overview document stays under about 3,000 words, a feature sheet under about 2,500 (split the area when it grows past that). A PR that goes over a budget trims or splits first.
- **Point to code, don't copy it.** Name `Class>>selector` and say its role; never paste method bodies. What a test already states precisely is not repeated in prose.
- **Done work shrinks.** When a stage or step is finished, its detailed section is replaced by one line with the result and a link to the PR. Decisions stay as one line each in the plan's table.
- **The agent's entry point** is [CLAUDE.md](../CLAUDE.md): one page saying which document to read for which task. It is updated whenever a document is added or removed.
