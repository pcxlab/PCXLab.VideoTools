# Session Startup Prompt

## Purpose

This document provides the standard startup instructions for AI assistants working on the PCXLab.VideoTools project.

Its goals are to:

- Minimize repeated repository analysis.
- Reduce AI token usage.
- Preserve architectural consistency.
- Allow seamless continuation between AI providers.
- Keep implementation language independent.

This document should be used at the beginning of every new AI development session.

---

# Standard Startup Prompt

Continue from the current state of the project.

Before making any changes:

1. Read the following documents in order:

   - Docs/00-Index.md
   - Docs/AI/AI-Handoff.md
   - Docs/Current-State.md
   - Docs/Decision-Log.md
   - Docs/Known-Issues.md
   - Docs/Testing-Strategy.md
   - Docs/Coding-Guidelines.md

2. Read only the architecture or ADR documents that are relevant to the requested task.

3. Do not perform repository-wide analysis unless the required information is missing from the documentation.

4. Reuse existing helpers, providers, policies, and architecture whenever appropriate.

5. Preserve all existing public APIs unless an intentional breaking change has been requested.

6. Extract only genuine duplication.

7. Avoid speculative abstractions.

8. Keep each implementation focused on one logical change.

9. Add or update unit tests when appropriate.

10. Run targeted regression tests for the affected components.

11. Perform production validation when the change affects production processing.

12. Update project documentation whenever architecture, workflow, or long-term knowledge changes.

---

# Expected Output

Unless explicitly requested otherwise, report only:

- Implementation Summary
- Modified Files
- Regression Results

Avoid unnecessary explanation.

---

# Repository Philosophy

Documentation is the primary project knowledge source.

Source code is the implementation.

Architectural decisions belong in documentation before they become tribal knowledge.

When documentation answers the question, prefer it over re-analyzing the repository.

---

# Language Independence

Implementation details may differ between programming languages.

Business rules, architecture, terminology, and processing pipeline should remain consistent.

Future implementations should preserve the documented architecture while using language-appropriate implementation techniques.

---

# AI Responsibilities

An AI assistant should:

- Read documentation before exploring code.
- Reuse existing architecture.
- Avoid duplicate implementations.
- Preserve backward compatibility.
- Recommend improvements only when they provide clear long-term value.
- Keep documentation synchronized with architectural changes.

---

# Context Recovery

If a previous development session ended unexpectedly:

- Continue from the documented project state.
- Review the current Git branch.
- Review Current-State.md.
- Review Known-Issues.md.
- Continue the requested task without repeating completed analysis whenever possible.

---

# Long-Term Goal

The objective is to make project knowledge portable across:

- AI providers
- Human contributors
- Programming languages
- Future implementations

The architecture should become the project's permanent source of truth.

---

# Update Rules

Update this document only when the AI development workflow changes.

Do not add project-specific implementation details here.

End of document.