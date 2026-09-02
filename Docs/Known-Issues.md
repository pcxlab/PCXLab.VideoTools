# Known Issues

## Purpose

This document tracks confirmed issues, limitations, and investigations.

It is not a bug tracker. Its purpose is to preserve technical knowledge
and prevent repeated investigation of the same problems.

---

# Scope

This document tracks confirmed issues and ongoing investigations.

It should not contain:

- Feature requests
- Planned enhancements
- Completed issues
- Architectural decisions

Feature ideas belong in the roadmap.

Architectural decisions belong in the Decision Log or ADRs.

------------------------------------------------------------------------

# Issue Template

## Title

### Status

-   Open
-   Investigating
-   Resolved
-   Deferred

### Description

Describe the issue.

### Impact

Describe how it affects the project.

### Current Understanding

Summarize what is known.

### Next Steps

Describe the next action.

------------------------------------------------------------------------

# Current Known Issues

## Find-PCXBlackFrames minimum duration test

Status: Investigating

Description: The test **Honours the requested minimum duration**
currently fails.

Current Understanding: - Failure predates the recent architecture
refactoring. - Not considered a regression unless proven otherwise.

Next Steps: Investigate FFmpeg blackdetect filtering and expected
behavior.

------------------------------------------------------------------------

## Aggressive silence trimming

Status: Deferred

Description: Edited speech can occasionally sound rushed because natural
pauses are shortened too aggressively.

Next Steps: Design configurable pre/post padding around retained speech.

------------------------------------------------------------------------

## Two-source recording sessions

Status: Investigating

Description: Some recording sessions containing only two media sources
may not process as expected.

Next Steps: Determine whether synchronization or batch processing
assumptions are responsible.

------------------------------------------------------------------------

## Synchronization confidence

Status: Deferred

Description: Low correlation confidence should be investigated in a
future improvement cycle.

------------------------------------------------------------------------

## Artifact already exists

Status: Investigating

Description: Confirm that artifact reuse never skips required processing
or produces stale results.

------------------------------------------------------------------------

## Empty SourceOffsets

Status: Investigating

Description:
Some recording sessions produce:

"Cannot bind argument to parameter 'SourceOffsets' because it is an empty collection."

Current Understanding:

May be related to recording sessions containing only two synchronized sources.

Not yet confirmed.

Next Steps:

Determine whether synchronization discovery or batch processing assumptions cause an empty SourceOffsets collection.

---

# Update Rules

-   Update issue status as understanding improves.
-   Link to investigation documents where appropriate.
-   Keep historical entries instead of deleting them.

End of document.
