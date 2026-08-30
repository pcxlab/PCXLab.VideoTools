# PCXLab.VideoTools Roadmap

This document tracks future work for PCXLab.VideoTools.

Only completed, production-tested work should be removed from this list.

---

# Current Milestone

## Synchronized Editing

Status: ✅ Completed

Completed work:

- Implemented synchronized editing pipeline
- Audio correlation based synchronization
- Translation of analysis events across synchronized sources
- Synchronized FFmpeg rendering
- Production validation on multiple real recordings
- Fixed source offset translation bug
- Verified rendered output against Adobe Premiere Pro
- Restored production cleanup after debugging

---

# High Priority

## 1. Improve Natural Audio Flow

Status: Planned

Current rendering occasionally cuts speech too aggressively.

Words remain understandable, but natural pauses between spoken words are sometimes shortened enough that speech feels rushed.

Goal:

- Preserve more natural conversational pacing
- Reduce aggressive silence trimming without reducing edit quality

---

## 2. Validate Premiere JSX for Synchronized Editing

Status: Planned

Regular editing has already been validated.

Synchronized editing must also be verified.

Goal:

- Ensure razor cuts exactly match rendered keep sections
- Allow easy recovery of removed footage from original recordings
- Ensure Premiere project accurately represents rendered output

---

## 3. Horizontal Video Flip

Status: Planned

Add optional horizontal flip during rendering.

Primary use case:

- Webcam / face camera
- Better visual orientation for Picture-in-Picture layouts

Example:

Instructor should appear to face toward screen content instead of away from it.

---

## 4. Support Recording Sessions with Only Two Videos

Status: Investigation

Some recording sessions appear to be skipped when only two video sources exist.

Possible examples:

- Screen + Webcam
- Screen + Phone Camera

Need to determine:

- Whether synchronization requires three sources
- Or whether batch processing incorrectly skips these sessions

---

# Medium Priority

## 5. Investigate Low Correlation Recordings

Status: Deferred

Example:

Correlation confidence below minimum threshold.

Current implementation behaves correctly by rejecting uncertain matches.

Need future investigation into improving robustness without increasing false positives.

---

## 6. Investigate Empty SourceOffsets

Status: Investigation

Observed error:

Cannot bind argument to parameter 'SourceOffsets' because it is an empty collection.

Need to determine:

- Root cause
- Whether related to two-video recording sessions
- Appropriate handling

---

## 7. Verify Artifact Reuse

Status: Investigation

Observed message:

Artifact already exists.

Need to verify that artifact reuse never skips required processing.

Questions:

- Are reused artifacts guaranteed identical?
- Is any important processing bypassed?
- Should regeneration occur under additional conditions?

---

# Learning

## Pull Requests

Gain confidence with the complete GitHub workflow.

Topics:

- Creating feature branches
- Opening Pull Requests
- Reviewing changes
- Merging
- Cleaning up branches

---

# Future Ideas

Items intentionally postponed until current priorities are complete.

Future ideas include:

- Improved synchronization robustness
- Additional rendering options
- Performance optimizations
- Additional editing features