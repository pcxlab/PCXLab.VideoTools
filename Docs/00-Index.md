# PCXLab.VideoTools Documentation Index

## Purpose

This document is the master navigation page for the entire project
knowledge base.

Both developers and AI assistants should begin here before reading any
other documentation.

The objective is to avoid repeatedly analysing the entire repository
when only a small area is relevant.

------------------------------------------------------------------------

# Reading Order

## 1. AI Onboarding

-   05-AI/AI-Handoff.md

Read first before making architectural or implementation changes.

------------------------------------------------------------------------

## 2. Project Overview

-   README.md
-   ROADMAP.md
-   CHANGELOG.md

Understand the project's purpose, current direction, and recent history.

------------------------------------------------------------------------

## 3. Architecture

Read only the documents related to the feature being modified.

Examples include:

-   ModuleArchitecture.md
-   ProviderArchitecture.md
-   ObjectModel.md
-   Logging.md
-   ErrorHandling.md
-   Settings.md
-   Versioning.md

------------------------------------------------------------------------

## 4. Architecture Decision Records (ADR)

The ADR folder records important design decisions and the reasoning
behind them.

Read an ADR whenever changing code related to that decision.

------------------------------------------------------------------------

## 5. Investigations

Contains research, experiments, production findings, and technical
investigations.

These documents provide supporting evidence rather than project
requirements.

------------------------------------------------------------------------

# Working Rules

Before implementing a feature:

1.  Read AI-Handoff.md.
2.  Read this index.
3.  Read only the documentation relevant to the task.
4.  Avoid repository-wide analysis unless documentation is missing.
5.  Update documentation whenever architecture changes.

------------------------------------------------------------------------

# Long-Term Vision

The PowerShell implementation is the reference implementation.

The architecture, business rules, and documentation should remain
language independent so future implementations in JavaScript,
TypeScript, Python, Java, Rust, or other languages can follow the same
design.

------------------------------------------------------------------------

# Documentation Roadmap

Core documents planned for this knowledge base include:

-   Current-State.md
-   Decision-Log.md
-   Refactoring-History.md
-   Known-Issues.md
-   Testing-Strategy.md
-   Coding-Guidelines.md
-   Release-Checklist.md

End of document.
