# Language Migration Prompt

## Purpose

Use this prompt when planning or implementing a migration of the project, or part of the project, to another programming language.

Its goals are to:

- Preserve business rules.
- Preserve architecture.
- Preserve public behavior.
- Minimize migration risk.
- Avoid language-specific redesign unless necessary.

---

# Prompt

Continue from the current project state.

Before planning or implementing a migration:

1. Read:

   - Docs/00-Index.md
   - Docs/AI/AI-Handoff.md
   - Docs/Current-State.md
   - Docs/Project-Vision.md
   - Docs/Coding-Guidelines.md
   - Docs/Glossary.md
   - Docs/Terminology.md

2. Read only the architecture documents relevant to the subsystem being migrated.

3. Preserve:

   - Business rules
   - Processing pipeline
   - Public APIs (where practical)
   - Terminology
   - Testing philosophy

4. Distinguish between:

   - Architecture
   - Business rules
   - Language-specific implementation

5. Use language-appropriate design patterns instead of translating PowerShell syntax directly.

6. Keep migration incremental whenever practical.

7. Preserve existing tests or replace them with equivalent tests in the target language.

8. Update documentation if migration changes project architecture or long-term knowledge.

---

# Report

Provide only:

- Migration Summary
- Components Migrated
- Architectural Differences
- Testing Strategy
- Risks
- Recommendations

---

# Success Criteria

A successful migration should:

- Preserve project behavior.
- Preserve architecture.
- Improve maintainability where appropriate.
- Follow best practices of the target language.
- Avoid unnecessary redesign.

The implementation language may change.

The architecture should remain recognizable.

End of document.