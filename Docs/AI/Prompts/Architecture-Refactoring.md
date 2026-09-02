# Architecture Refactoring Prompt

## Purpose

Use this prompt when performing architectural improvements or refactoring existing code.

Its goals are to:

- Preserve behavior.
- Improve maintainability.
- Reduce duplication.
- Keep public APIs stable.
- Maintain architectural consistency.

---

# Prompt

Continue from the current project state.

Before implementing changes:

1. Read:

   - Docs/00-Index.md
   - Docs/AI/AI-Handoff.md
   - Docs/Current-State.md
   - Docs/Decision-Log.md
   - Docs/Coding-Guidelines.md

2. Read only the architecture documents relevant to this task.

3. Do not perform repository-wide analysis unless documentation is insufficient.

4. Preserve all existing behavior.

5. Preserve public APIs.

6. Identify only genuine duplication.

7. Extract reusable helpers only when they provide clear architectural value.

8. Avoid speculative abstractions.

9. Keep the refactoring focused on one logical improvement.

10. Add dedicated unit tests for new helpers when appropriate.

11. Run targeted regression tests.

12. Update:

- Current-State.md
- Decision-Log.md
- Refactoring-History.md

if architecture changes.

---

# Report

Provide only:

- Implementation Summary
- Modified Files
- Regression Results

Avoid unnecessary explanation.

---

# Success Criteria

A successful refactoring should:

- Reduce duplication.
- Improve maintainability.
- Preserve behavior.
- Preserve public APIs.
- Increase architectural clarity.
- Improve long-term portability.

End of document.