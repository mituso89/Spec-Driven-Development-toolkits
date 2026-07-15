---
name: m-test-driven-development
description: "Enforces test-driven development: write one failing test, watch it fail, write minimal code to pass, refactor — no production code without a failing test first. Use when implementing any feature, bugfix, or behavior change, before writing implementation code. Triggers: TDD, write tests first, red-green-refactor."
---

# Test-Driven Development (TDD)

> **TL;DR** — Write one failing test (RED) → watch it fail for the right reason → minimal code to pass (GREEN) → watch it pass with everything else green → refactor → repeat.

**Core principle:** if you didn't watch the test fail, you don't know it tests the right thing. Violating the letter of the rules is violating the spirit of the rules.

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Wrote code before the test? **Delete it** and re-implement from the tests — don't keep it as "reference", don't "adapt" it while writing tests. Applies to features, bug fixes, refactors, behavior changes. Exceptions (throwaway prototypes, generated code, config files) need your human partner's OK. Thinking "skip TDD just this once"? That's rationalization.

## The cycle

### RED — write one failing test
One behavior, clear name, real code (mocks only if unavoidable):

```typescript
test('retries failed operations 3 times', async () => {
  let attempts = 0;
  const operation = () => {
    attempts++;
    if (attempts < 3) throw new Error('fail');
    return 'success';
  };
  expect(await retryOperation(operation)).toBe('success');
  expect(attempts).toBe(3);
});
```

Anti-example: `test('retry works')` asserting call counts on a `jest.fn()` — vague name, tests the mock, not the code.

### Verify RED — watch it fail (mandatory, never skip)
Run the test. Confirm it **fails** (not errors), with the expected message, because the feature is missing (not a typo). Passes immediately → you're testing existing behavior; fix the test. Errors → fix and re-run until it fails correctly.

### GREEN — minimal code
The simplest code that passes: no speculative options or parameters, no features beyond the test, no refactoring other code (YAGNI).

### Verify GREEN — watch it pass (mandatory)
Run again. This test passes, all other tests still pass, output pristine (no errors or warnings). Test fails → fix the code, not the test. Other tests break → fix now.

### REFACTOR — after green only
Remove duplication, improve names, extract helpers. Stay green; add no behavior. Then write the next failing test.

## Rationalizations — all of these mean: delete the code, start over with TDD

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. The test takes 30 seconds. |
| "I'll test after" | Tests written after pass immediately — which proves nothing: they're biased by the implementation, test what you built (not what's required), and you never saw them catch anything. |
| "Tests after achieve the same goals" | Tests-after answer "what does this do?"; tests-first answer "what *should* this do?" and force edge-case discovery before implementing. |
| "Already manually tested" | Ad-hoc ≠ systematic: no record, can't re-run, cases forgotten under pressure. |
| "Deleting X hours is wasteful" | Sunk cost fallacy. Keeping code you can't trust is the real debt. |
| "Keep it as reference" | You'll adapt it — that's testing after. Delete means delete. |
| "Need to explore first" | Fine — throw the exploration away, then start with TDD. |
| "Test is hard to write" | Listen to the test: hard to test = hard to use. Simplify the design. |
| "TDD is dogmatic; I'm pragmatic" | TDD *is* pragmatic: bugs surface before commit, regressions get caught, tests document behavior and enable refactoring. Shortcuts = debugging in production. |
| "Existing code has no tests" | You're improving it — add tests for the code you touch. |

## Red flags — stop and start over

Code before test · test written after · test passes immediately · can't explain why the test failed · "just this once" · "I already manually tested it" · "keep as reference" / "adapt existing code" · "already spent X hours" · "it's about spirit, not ritual" · "this is different because…"

## Checklist before marking work complete

- [ ] Every new function/method has a test you watched fail for the expected reason
- [ ] Minimal code per test; all tests pass; output pristine
- [ ] Tests exercise real code (mocks only where unavoidable); edge cases and errors covered

Can't check every box? You skipped TDD — start over.

## When stuck

| Problem | Solution |
|---------|----------|
| Don't know how to test | Write the wished-for API; write the assertion first; ask your human partner. |
| Test too complicated | Design too complicated — simplify the interface. |
| Must mock everything | Code too coupled — use dependency injection. |
| Test setup huge | Extract helpers; still complex → simplify the design. |

## Bug fixes

Reproduce the bug with a failing test, then follow the cycle — the test proves the fix and prevents regression. Never fix a bug without a test.

## Testing anti-patterns

Adding mocks or test utilities? Read @testing-anti-patterns.md first: testing mock behavior instead of real behavior, test-only methods on production classes, mocking without understanding dependencies.

## Final rule

```
Production code → a test exists and failed first
Otherwise → not TDD
```

No exceptions without your human partner's permission.
