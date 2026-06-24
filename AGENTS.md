# Repository Instructions for Codex

## 1. Project goal

Build the Flutter demo defined in `docs/PROJECT_SPEC.md` by following `docs/IMPLEMENTATION_PLAN.md` one phase at a time. The user is an iOS engineer learning Flutter and must understand every important implementation and design decision.

## 2. Mandatory interaction protocol

- Use Chinese for explanations.
- Use Japanese for user-facing UI copy.
- Use English for code identifiers and code comments.
- Never implement more than one numbered Phase in a single turn.
- Before changing files, explain:
  1. the goal of the current Phase;
  2. the concepts involved;
  3. the files to add or change;
  4. the design choice and alternatives;
  5. expected risks.
- Then implement only that Phase.
- After implementation, run the required checks and report the exact results.
- End every Phase with:
  1. changed files;
  2. how the data/state flows;
  3. why the design was chosen;
  4. Swift/UIKit/RxSwift analogy and important differences;
  5. manual verification steps;
  6. tests executed;
  7. three likely interview questions with concise answers;
  8. remaining limitations.
- Stop after the Phase. Do not continue until the user explicitly says to continue.

## 3. Teaching requirements

- Do not dump large code blocks without explaining them.
- Explain new Flutter concepts using the user's Swift/UIKit/RxSwift background, but clearly state where the analogy is imperfect.
- Explain each new dependency before adding it: purpose, alternative, trade-off, and why it is justified here.
- When an error occurs, explain the root cause and debugging path before applying the fix.
- Prefer small, reviewable changes.
- Never claim the user understands a concept merely because the code compiles.

## 4. Architecture and scope rules

- Follow the lightweight feature-first layered architecture in the specification.
- Do not add Clean Architecture layers mechanically.
- Do not add Monorepo/Melos, real authentication, real payment, real AI API, real backend, local database, push notification, or OS-level background upload unless the user explicitly approves a later scope change.
- Do not use UPSIDER trademarks, logos, screenshots, exact colors, or copied UI.
- Use fictional data only.
- Never store money as floating-point values.
- Never log memo text, image contents, image paths, full transaction data, secrets, or card data.
- Only display fictional card last-four digits.
- Explicitly pass `brandId` through repository calls; do not rely only on UI filtering.
- Prevent duplicate active uploads for one transaction.
- Retry the same business submission with the same idempotency key.

## 5. Dependency policy

Pre-approved production dependencies:

- `flutter_riverpod`
- `go_router`
- `image_picker`
- `intl`
- `uuid`

Pre-approved development dependencies:

- `mocktail`
- Flutter SDK test packages

Ask before adding any other production dependency. Avoid code generation during the MVP unless a concrete problem justifies it.

## 6. Quality gates

After each relevant Phase, run:

```bash
dart format .
flutter analyze
flutter test
```

If a command cannot run, state the exact reason and do not report success.

For every behavior change:

- add or update appropriate tests;
- handle loading, empty, success, and failure states where applicable;
- keep user-facing error messages actionable;
- preserve testability through dependency injection.

Do not create a Git commit unless the user asks. Suggest a commit message after each completed Phase.

## 7. First action

On the first turn:

- read all repository instruction and specification files;
- inspect the environment;
- do not modify code;
- present the Phase 0 findings and a concrete Phase 1 plan;
- stop and wait for approval.
