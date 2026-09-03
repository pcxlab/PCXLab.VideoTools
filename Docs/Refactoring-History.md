# Refactoring History

## Purpose

This document records the architectural evolution of the project.

Unlike the changelog, it focuses on structural improvements rather than
feature additions or bug fixes.

------------------------------------------------------------------------

# Refactoring Principles

-   Preserve public APIs whenever possible.
-   Prefer small, reviewable changes.
-   Introduce private helpers before changing public behavior.
-   Maintain production compatibility.
-   Add or update tests with every refactoring stage.

------------------------------------------------------------------------

# Completed Stages

## Stage Template

### Stage X -- Title

Status: Complete

Summary:

- Primary architectural improvement
- Supporting refactoring
- Testing improvements
- Public API impact (if any)

Branch:

refactor/branch-name

Completed:

YYYY-MM-DD

## Stage 1 — Extract Edit Boundaries

Status: Complete

Summary: - Centralized edit boundary selection. - Added dedicated unit
tests. - Preserved behavior.

------------------------------------------------------------------------

## Stage 2 — Centralize Edit Policy

Status: Complete

Summary: - Introduced Get-PCXEditPolicy. - Removed duplicated editing
defaults. - Preserved public APIs.

------------------------------------------------------------------------

## Stage 3 — Centralize Analysis Policy

Status: Complete

Summary: - Introduced Get-PCXAnalysisPolicy. - Centralized silence and
black-frame defaults. - Preserved existing behavior.

------------------------------------------------------------------------

## Stage 4 — Extract Silence Classification

Status: Complete

Summary: - Introduced Resolve-PCXSilenceClassification. - Removed
duplicated classification logic. - Improved test coverage.

------------------------------------------------------------------------

## Stage 5 — Extract Analysis Event Conversion Helpers

Status: Complete

Summary: - Added Copy-PCXAnalysisEventClone. - Added
Restore-PCXAnalysisEventTimeSpans. - Reduced duplicated conversion
logic.

------------------------------------------------------------------------

## Stage 6 — Video Rendering Metadata (HorizontalFlip)

Status: Complete

Summary:
- Added optional `HorizontalFlip` rendering metadata to `PCXLab.VideoSegment`.
- Created private video filter builder `ConvertTo-PCXVideoFilter`.
- Integrated video post-processing filter compilation and pad rewiring into `ConvertTo-PCXFFmpegFilterGraph`.
- Preserved rendering metadata across segment optimization, timeline projection, and JSON serialization.
- Preserved 100% backward compatibility across all editing and rendering commands.

------------------------------------------------------------------------

# Future Stages

Record future refactoring work here as it is completed.

------------------------------------------------------------------------

# Update Rules

-   Add one section per completed stage.
-   Keep entries concise.
-   Link to ADRs or investigations where appropriate.
-   Never rewrite previous history; append new stages.

End of document.
