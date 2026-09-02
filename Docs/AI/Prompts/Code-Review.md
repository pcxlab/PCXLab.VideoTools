# Code Review Prompt

## Purpose

Use this prompt when reviewing completed code changes before merging them into the main branch.

Its goals are to:

- Verify architectural consistency.
- Preserve existing behavior.
- Maintain code quality.
- Identify potential risks.
- Ensure long-term maintainability.

---

# Prompt

Continue from the current project state.

Before reviewing code:

1. Read:

   - Docs/00-Index.md
   - Docs/AI/AI-Handoff.md
   - Docs/Current-State.md
   - Docs/Coding-Guidelines.md
   - Docs/Testing-Strategy.md

2. Read only the architecture documents relevant to the reviewed changes.

3. Review the implementation for:

   - Correctness
   - Readability
   - Maintainability
   - Consistency
   - Simplicity

4. Verify that:

   - Public APIs remain unchanged unless intentionally modified.
   - Existing behavior is preserved.
   - New helpers have a single responsibility.
   - Genuine duplication has been removed without introducing unnecessary abstractions.

5. Confirm:

   - Appropriate unit tests exist.
   - Relevant regression tests were executed.
   - Documentation has been updated where necessary.

6. Identify any architectural concerns separately from style suggestions.

---

# Report

Provide only:

- Review Summary
- Strengths
- Risks
- Suggested Improvements
- Test Coverage Assessment
- Recommendation

Use one of:

- Approve
- Approve with Suggestions
- Request Changes

---

# Success Criteria

A successful review should:

- Improve code quality.
- Preserve architecture.
- Maintain consistency.
- Avoid subjective style debates.
- Focus on long-term maintainability.

End of document.