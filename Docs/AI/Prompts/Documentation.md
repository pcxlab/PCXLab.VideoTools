# Documentation Prompt

## Purpose

Use this prompt when creating, reviewing, or updating project documentation.

Its goals are to:

- Keep documentation accurate.
- Preserve consistency across the knowledge base.
- Reduce duplicated information.
- Maintain language independence.
- Ensure documentation evolves with the architecture.

---

# Prompt

Continue from the current project state.

Before updating documentation:

1. Read:

   - Docs/00-Index.md
   - Docs/AI/AI-Handoff.md
   - Docs/Current-State.md
   - Docs/Decision-Log.md

2. Read only the documentation relevant to the requested update.

3. Preserve the responsibility of each document.

4. Avoid duplicating information already documented elsewhere.

5. Keep documentation implementation independent whenever practical.

6. Update cross-references if new documents are added.

7. Keep terminology consistent with:

   - Glossary.md
   - Terminology.md

8. Update architecture documentation only when architecture changes.

9. Update Current-State.md when the project state changes.

10. Update Decision-Log.md only for long-term architectural decisions.

11. Update Refactoring-History.md only after completed architectural milestones.

---

# Report

Provide only:

- Documentation Updated
- Files Modified
- Cross-References Updated

---

# Success Criteria

Successful documentation should:

- Be accurate.
- Be concise.
- Avoid duplication.
- Be easy to maintain.
- Help both developers and AI assistants understand the project.

End of document.