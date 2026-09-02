# Release Checklist

## Purpose

This document defines the standard checklist to follow before merging,
tagging, or releasing changes.

It is intended to ensure that every release is consistent, repeatable,
and production-ready.

------------------------------------------------------------------------

# Pre-Merge Checklist

-   [ ] Working tree is clean.
-   [ ] Branch is up to date.
-   [ ] Commit messages are clear.
-   [ ] Public APIs remain compatible (unless intentionally changed).
-   [ ] Documentation updated where required.

------------------------------------------------------------------------

# Testing Checklist

-   [ ] New unit tests added when appropriate.
-   [ ] Existing unit tests pass.
-   [ ] Targeted regression tests pass.
-   [ ] Known baseline failures reviewed.
-   [ ] Production validation completed if required.

------------------------------------------------------------------------

# Architecture Checklist

-   [ ] No unnecessary duplication introduced.
-   [ ] Private helpers preferred over duplicated logic.
-   [ ] Naming follows project conventions.
-   [ ] ADRs updated for significant architectural decisions.
-   [ ] Current-State.md updated if project status changed.

------------------------------------------------------------------------

# Release Checklist

-   [ ] CHANGELOG updated.
-   [ ] Version updated (if applicable).
-   [ ] Git tags prepared (if applicable).
-   [ ] Release notes prepared.
-   [ ] Final verification completed.

------------------------------------------------------------------------

# Post-Release

-   Monitor production feedback.
-   Record follow-up work in Known-Issues.md.
-   Update Decision-Log.md if new architectural decisions emerge.

---

# Documentation Verification

Before merging, verify that documentation remains consistent.

Check whether updates are required for:

- AI-Handoff.md
- Current-State.md
- Decision-Log.md
- Known-Issues.md
- Refactoring-History.md
- Testing-Strategy.md

------------------------------------------------------------------------


# Update Rules

Keep this checklist concise. Expand only when the release process itself
changes.

End of document.
