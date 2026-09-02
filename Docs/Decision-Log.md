# Decision Log

## Purpose

This document records important technical and architectural decisions
made during the life of the project.

Unlike source code, this document explains *why* decisions were made.

------------------------------------------------------------------------

# How to Use

Create a new entry whenever a significant architectural decision is
made.

Each entry should be short and reference the related ADR when
applicable.

----

# Decision Rules

Only record decisions that change the long-term architecture or development process.

Do not record:

- Bug fixes
- Small refactorings
- Formatting changes
- Temporary experiments
- Routine maintenance

A decision should explain WHY something changed, not HOW it was implemented.

------------------------------------------------------------------------

# Decision Template

## YYYY-MM-DD --- Title

### Decision

Describe the decision.

### Reason

Explain why it was made.

### Alternatives Considered

List any alternatives that were evaluated.

### Impact

Describe the expected impact on the project.

### Status

-   Proposed
-   Accepted
-   Superseded
-   Rejected

------------------------------------------------------------------------

# Current Decisions

## 2026-08 --- Centralize Edit Policy

### Decision

Created a private edit policy provider to eliminate duplicated editing
defaults.

### Reason

Improve maintainability while preserving public APIs.

### Status

Accepted

------------------------------------------------------------------------

## 2026-09 --- Centralize Analysis Policy

### Decision

Created a private analysis policy provider for silence and black-frame
defaults.

### Reason

Remove duplicated configuration logic.

### Status

Accepted

------------------------------------------------------------------------

## 2026-09 --- Extract Silence Classification

### Decision

Moved silence classification into a dedicated private helper.

### Reason

Centralize business rules and reduce duplication.

### Status

Accepted

------------------------------------------------------------------------

## 2026-09 --- Extract Analysis Event Conversion Helpers

### Decision

Extracted helper functions for cloning analysis events and restoring
deserialized analysis event types.

### Reason

Reduce duplicated implementation while preserving behavior.

### Status

Accepted

------------------------------------------------------------------------

## Update Rules

-   Record decisions, not implementation details.
-   Link to ADRs when available.
-   Never delete history; supersede older decisions instead.

End of document.
