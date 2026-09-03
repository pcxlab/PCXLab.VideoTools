# Current Project State

## Purpose

This document records the current state of the project. It is intended
to be the first project-specific document read by developers and AI
assistants after `00-Index.md` and `05-AI/AI-Handoff.md`.

It should always describe the project **as it exists today**, not the
future vision.

------------------------------------------------------------------------

# Project Status

Project: **PCXLab.VideoTools**

Primary Language: **PowerShell 7**

Architecture Status: **Production capable and actively evolving**

Overall Goal:

Build a maintainable, modular, production-ready video editing toolkit
whose architecture can later be implemented in JavaScript, TypeScript,
Python, Java, or other languages without changing the business rules.

------------------------------------------------------------------------

# Current Architecture

Completed major improvements include:

-   Centralized edit policy provider
-   Centralized analysis policy provider
-   Extracted edit boundary selection
-   Extracted silence classification helper
-   Extracted analysis event conversion helpers
-   Metadata-driven horizontal flip video rendering support
-   Improved unit test coverage for private helpers
-   Continued preservation of public APIs during refactoring
-   Business rules continue to be extracted into reusable private providers and helper functions while preserving public APIs.

------------------------------------------------------------------------

# Current Design Principles

The project currently follows these architectural principles:

- Preserve existing public APIs.
- Prefer composition over duplication.
- Extract only genuine shared logic.
- Keep helper functions single-purpose.
- Separate business rules from orchestration.
- Preserve backward compatibility.
- Maintain high unit test coverage.
- Prefer incremental refactoring over large rewrites.
- Rendering behavior should be driven by explicit metadata rather than inferred from filenames or media characteristics.

------------------------------------------------------------------------

# Production Status

Current production processing is functional and has been validated
against real recording sessions.

Production validation should continue after major architectural changes.

------------------------------------------------------------------------

# Current Testing Baseline

Known passing areas include:

-   Editing helpers
-   Synchronization
-   Recording session round-trip
-   Edit policy
-   Analysis policy
-   Silence classification
-   Analysis event conversion
-   Video analysis

Known baseline issue:

-   `Find-PCXBlackFrames.Tests.ps1`
    -   Test: **Honours the requested minimum duration**
    -   This failure existed before the latest refactoring work and
        should be investigated separately.
    -   Do not treat it as a regression without confirmation.

------------------------------------------------------------------------

# Active Priorities

Current focus:

1.  Continue architecture refactoring.
2.  Reduce duplicated private logic.
3.  Keep public APIs stable.
4.  Maintain or improve test coverage.
5.  Validate changes against production recordings.

------------------------------------------------------------------------

# Deferred Work

Examples of future work already identified:

-   Improve natural conversational pacing by refining silence padding.
-   Validate synchronized JSX edit accuracy.
-   Improve handling of recording sessions containing only two sources.
-   Investigate low synchronization confidence cases.
-   Investigate "SourceOffsets is an empty collection".
-   Review "Artifact already exists" behaviour.
-   Improve project documentation and contributor onboarding.

------------------------------------------------------------------------

# Current Documentation

The project knowledge base currently consists of:

- AI-Handoff.md
- Current-State.md
- Decision-Log.md
- Known-Issues.md
- Refactoring-History.md
- Testing-Strategy.md
- Coding-Guidelines.md
- Contributor-Workflow.md
- Release-Checklist.md

Architecture documentation and ADRs provide detailed design information when additional implementation detail is required.

------------------------------------------------------------------------

# Update Rules

Update this document whenever one of the following changes:

-   Architecture milestone completed
-   Major feature completed
-   Important investigation completed
-   Production validation status changes
-   Testing baseline changes
-   New long-term priorities are established

Do not duplicate detailed design decisions here. Those belong in ADRs or
architecture documents.

End of document.
