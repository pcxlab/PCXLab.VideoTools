# Feature Implementation Prompt

## Purpose

Use this prompt when implementing a new feature or capability in the project.

Its goals are to:

- Preserve architectural consistency.
- Minimize implementation risk.
- Maintain backward compatibility whenever practical.
- Reuse existing architecture.
- Keep new functionality modular and testable.

---

# Prompt

Continue from the current project state.

Before implementing:

1. Read:

   - Docs/00-Index.md
   - Docs/AI/AI-Handoff.md
   - Docs/Current-State.md
   - Docs/Coding-Guidelines.md
   - Docs/Testing-Strategy.md

2. Read only the architecture documents relevant to the requested feature.

3. Determine whether similar functionality already exists.

4. Reuse existing helpers, providers, and policies whenever appropriate.

5. Preserve existing behavior unless the requested feature intentionally changes it.

6. Keep implementation modular.

7. Avoid introducing unnecessary abstractions.

8. Implement one logical feature only.

9. Add dedicated unit tests.

10. Run targeted regression tests.

11. Update documentation if the feature changes architecture, workflow, terminology, or long-term project knowledge.

---

# Report

Provide only:

- Implementation Summary
- Modified Files
- Tests Added
- Regression Results

---

# Success Criteria

A successful feature should:

- Integrate naturally with the existing architecture.
- Preserve maintainability.
- Include appropriate tests.
- Follow project naming conventions.
- Avoid unnecessary complexity.

End of document.