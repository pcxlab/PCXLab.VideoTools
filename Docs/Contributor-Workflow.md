# Contributor Workflow

## Purpose

This document defines the standard workflow for anyone contributing to
the project, whether a human developer or an AI assistant.

The objective is to keep changes small, traceable, and easy to review.

------------------------------------------------------------------------

# Standard Workflow

1.  Read:

    -   Docs/00-Index.md
    -   Docs/05-AI/AI-Handoff.md
    -   Docs/Current-State.md

2.  Read only the architecture documents relevant to the task.

3.  Create a dedicated feature or documentation branch.

4.  Make one logical change at a time.

5.  Add or update tests when appropriate.

6.  Run targeted regression tests.

7.  Validate with production recordings if required.

8.  Update documentation:

    -   Current-State.md
    -   Refactoring-History.md
    -   Decision-Log.md
    -   Known-Issues.md (if applicable)

9.  Commit with a clear message.

10. Merge only after verification.

---

# Scope Control

Each branch should solve one logical problem only.

Avoid combining:

- Refactoring
- New features
- Bug fixes
- Documentation restructuring

Separate work into independent branches whenever practical.

------------------------------------------------------------------------

# Branch Naming

Examples:

-   feature/...
-   fix/...
-   refactor/...
-   docs/...
-   investigation/...

------------------------------------------------------------------------

# Commit Message Style

Use concise, descriptive messages.

Examples:

-   Centralize analysis policy
-   Extract silence classification helper
-   Add knowledge base foundation
-   Update testing strategy

------------------------------------------------------------------------

# AI Workflow

AI assistants should avoid repository-wide analysis unless documentation
is missing or outdated.

Prefer reading documentation first and only inspect the code directly
related to the requested task.

When documentation answers the question, prefer it over re-analyzing the repository.

Update documentation whenever new architectural knowledge is discovered.

------------------------------------------------------------------------

# Long-Term Goal

The workflow should remain valid even if the implementation language
changes in the future.

End of document.
