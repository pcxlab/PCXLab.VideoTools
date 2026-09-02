# Testing Strategy

## Purpose

This document defines the project's testing philosophy, scope, and
execution guidelines.

------------------------------------------------------------------------

# Objectives

-   Preserve existing behavior during refactoring.
-   Detect regressions early.
-   Keep tests fast, readable, and deterministic.
-   Validate production scenarios after major architectural work.

------------------------------------------------------------------------

# Test Levels

## Unit Tests

Focus on individual private helpers and object models.

Examples:

-   Policy providers
-   Classification helpers
-   Object factories
-   Conversion helpers

------------------------------------------------------------------------

## Public API Tests

Validate public cmdlets without depending on implementation details.

Examples:

-   Analysis
-   Editing
-   Synchronization

------------------------------------------------------------------------

## Regression Tests

Run targeted regression tests whenever a refactoring changes behavior or
shared logic.

Regression suites should include only components affected by the change.

------------------------------------------------------------------------

## Production Validation

After significant changes:

-   Process real recording sessions.
-   Compare outputs with previous validated runs.
-   Review logs and generated artifacts.
-   Confirm edited media quality.

----

# Test Selection

Run only the tests affected by the current change whenever practical.

Typical order:

1. New unit tests
2. Related regression tests
3. Public API tests
4. Production validation (when required)

Avoid running the full test suite unless the change has broad architectural impact.

------------------------------------------------------------------------

# Known Baseline

Current known baseline issue:

-   Find-PCXBlackFrames.Tests.ps1
    -   "Honours the requested minimum duration"
    -   Investigate separately from architectural refactoring.

------------------------------------------------------------------------

# Test Checklist

Before merging work:

-   Unit tests pass.
-   Regression tests pass.
-   Production validation completed when required.
-   No unintended public API changes.

------------------------------------------------------------------------

# Update Rules

Update this document whenever:

-   New test categories are introduced.
-   Validation workflow changes.
-   Regression strategy changes.

End of document.
