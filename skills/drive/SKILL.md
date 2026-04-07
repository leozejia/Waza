---
name: drive
description: Invoke when implementing a new behavior or bug fix where correctness matters. Enforces Red-Green-Refactor with one behavior per cycle. Not for pure documentation edits or throwaway spikes.
version: 3.2.0
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Grep
  - Glob
  - AskUserQuestion
---

# Drive: Implement by Red-Green-Refactor

Write the test first, watch it fail for the right reason, then write the minimum code to pass.

If you did not see a meaningful failing test first, you did not verify behavior. You only wrote code.

## When to Use

Use this skill for:
- New feature behavior
- Bug fixes
- State transitions and business rules
- API contracts and validation paths

Do not use this skill for:
- Pure text changes
- One-off throwaway scripts
- Scaffolding that has no behavior yet

If unsure, default to using this skill.

## The Rule

No production behavior code before a failing test that proves the behavior is missing.

No exceptions based on confidence, speed, or "small change" claims.

## Phase 1: Define One Behavior

Choose exactly one behavior for this cycle.

Good:
- "Retries exactly three times before surfacing the error"
- "Rejects invalid email format at the API boundary"

Bad:
- "Fix auth and clean up user profile handling and improve logging"

If behavior scope is broad, split it into smaller cycles before touching code.

## Phase 2: RED

Write the smallest test that demonstrates the behavior.

Then run only that test.

Requirements for RED:
- Test fails
- Failure reason matches the missing behavior
- Failure is not caused by typos, setup mistakes, or missing imports

If the test passes immediately, you tested existing behavior. Rewrite the test.

## Phase 3: GREEN

Write the minimum code needed for the test to pass.

Constraints:
- No opportunistic refactor
- No extra features
- No unrelated cleanup

Run:
1. The focused test
2. The affected test subset

If failures appear outside the target area, stop and report before widening scope.

## Phase 4: REFACTOR

Only after GREEN:
- Remove duplication
- Improve names
- Extract small helpers if it reduces complexity

Re-run tests after each refactor step. Behavior must remain unchanged.

## Phase 5: Verify and Report

Before claiming completion:
- Run project verification command for the affected area
- Confirm regression coverage exists for the fixed behavior

Use this summary:

```
Behavior:   [what this cycle implemented]
Test:       [file:testcase]
RED seen:   yes/no
GREEN seen: yes/no
Refactor:   [none or brief note]
Verify:     [command] -> pass/fail
```

If RED or GREEN was not observed in this session, status is not complete.

## Rationalization Watch

Stop if you notice these thoughts:
- "I will add tests after the fix"
- "This is too small for TDD"
- "It obviously works"
- "I do not need to run the failing step"

Each one means the cycle is being skipped.

## Gotchas

Real failure patterns:
- Wrote implementation first, then adjusted tests to match the code
- Combined three behaviors into one test, making failures hard to diagnose
- Declared bug fixed without a regression test
- Ran only one focused test and skipped broader verification
- Refactored and changed behavior without noticing

## Outcome

Status is one of:
- **complete**: RED and GREEN observed, verification passed
- **partial**: behavior implemented but verification incomplete
- **blocked**: cannot get meaningful RED or cannot reach GREEN
