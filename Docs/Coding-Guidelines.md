# Coding Guidelines

## Purpose

This document defines the coding standards that apply across the project
regardless of programming language.

The goal is consistency, readability, maintainability, and long-term
scalability.

------------------------------------------------------------------------

# Core Principles

-   Readability is more important than cleverness.
-   Preserve existing behavior during refactoring.
-   Prefer small, reviewable commits.
-   Keep public APIs stable whenever possible.
-   Minimize duplication.
-   Prefer composition over large monolithic functions.

---

# Refactoring Principles

When improving existing code:

- Preserve behavior before improving structure.
- Make one logical architectural change per branch.
- Prefer extracting reusable helpers over rewriting working code.
- Run targeted regression tests before committing.
- Keep each refactoring independently reviewable.

------------------------------------------------------------------------

# Architecture Rules

-   Business rules belong in dedicated helpers or providers.
-   Public cmdlets should orchestrate work, not implement business
    logic.
-   Private helpers should have a single responsibility.
-   Settings should be resolved through policy providers.
-   Object construction should be centralized in model factories.

------------------------------------------------------------------------

# Naming

Choose names that clearly describe intent.

Good examples:

-   Get-PCXEditPolicy
-   Get-PCXAnalysisPolicy
-   Resolve-PCXSilenceClassification
-   Select-PCXEditBoundaries

Avoid abbreviations unless they are already established.

------------------------------------------------------------------------

# Functions

Each function should ideally perform one responsibility.

If a function begins handling multiple independent concerns, consider
extracting private helpers.

------------------------------------------------------------------------

# Testing

Every architectural refactoring should include:

-   Appropriate unit tests.
-   Targeted regression tests.
-   Production validation when required.

Never remove tests simply because implementation changes.

------------------------------------------------------------------------

# Documentation

Whenever architecture changes:

-   Update Current-State.md.
-   Update Refactoring-History.md.
-   Update Decision-Log.md if the reasoning changed.
-   Update ADRs when appropriate.

Documentation is part of the implementation.

------------------------------------------------------------------------

# Git

Prefer:

-   Small commits.
-   Descriptive commit messages.
-   Feature branches.
-   Fast-forward merges when appropriate.

Do not mix unrelated work into a single commit.

---

# Pull Requests

When using pull requests:

- Keep each pull request focused on one logical change.
- Ensure tests pass before requesting review.
- Avoid mixing refactoring and new features in the same pull request.

------------------------------------------------------------------------

# Long-Term Goal

These guidelines should remain applicable even if the implementation
moves from PowerShell to JavaScript, TypeScript, Python, Java, Rust, or
another language.

The architecture should outlive the implementation language.

------------------------------------------------------------------------

# Update Rules

Update this document only when project-wide coding practices change.

Do not record feature-specific information here.

End of document.
