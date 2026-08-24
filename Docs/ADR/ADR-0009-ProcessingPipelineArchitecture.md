# ADR-0009 — Processing Pipeline Architecture

| Field | Value |
|-------|-------|
| **ADR Number** | 0009 |
| **Title** | Processing Pipeline Architecture |
| **Status** | Accepted |
| **Date** | 2026-08-24 |
| **Authors** | PCXLab Architecture Team |
| **Supersedes** | — |
| **Superseded by** | — |

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Context](#2-context)
3. [Problem Statement](#3-problem-statement)
4. [Architectural Review](#4-architectural-review)
5. [Requirements](#5-requirements)
6. [Architectural Principles](#6-architectural-principles)
7. [Decision](#7-decision)
8. [Architecture Overview](#8-architecture-overview)
9. [Processing Pipeline](#9-processing-pipeline)
10. [Timeline Mapping](#10-timeline-mapping)
11. [Artifact Dependency Graph](#11-artifact-dependency-graph)
12. [Artifact Lifecycle](#12-artifact-lifecycle)
13. [Artifact Naming](#13-artifact-naming)
14. [Implementation Boundaries](#14-implementation-boundaries)
15. [Design Principles Mapping](#15-design-principles-mapping)
16. [Extensibility](#16-extensibility)
17. [Trade-offs](#17-trade-offs)
18. [Alternatives Considered](#18-alternatives-considered)
19. [Risks and Mitigations](#19-risks-and-mitigations)
20. [Future Considerations](#20-future-considerations)
21. [Open Questions](#21-open-questions)
22. [Recommendations](#22-recommendations)

---

## 1. Executive Summary

This ADR defines the authoritative long-term processing architecture for
`PCXLab.VideoTools`. It addresses how expensive analysis operations are
executed at most once, how durable checkpoints protect work across process
boundaries, and how the active execution pipeline remains completely
object-driven without depending on previously generated files.

The architecture is founded on five invariants:

1. **Single Analysis.** Each expensive FFmpeg operation executes exactly once
   per source file, per analysis configuration, unless regeneration is
   explicitly requested.

2. **Durable Checkpoints.** Every expensive stage writes a JSON checkpoint
   before the next stage begins. These checkpoints are the persistent source
   of truth.

3. **Object-Driven Active Pipeline.** During first execution, in-memory
   objects flow through every stage. JSON files are side-effects, not
   intermediaries.

4. **Checkpoint Reuse.** On all subsequent executions, existing checkpoints
   are loaded and expensive stages are skipped.

5. **Failure Recovery.** Interruption at any stage (power failure, crash,
   OOM) leaves the pipeline resumable from the last completed checkpoint.

---

## 2. Context

`PCXLab.VideoTools` is a production-grade PowerShell module that automates
technical video editing. Its current capabilities include:

- **FFmpeg analysis** — silence detection, black frame detection
- **Video segment generation** — converting analysis events into Keep/Remove
  timeline segments
- **Premiere marker export** — `.jsx` scripts for Adobe Premiere Pro
- **Premiere razor cut export** — `.jsx` scripts for razor cuts at edit seams
- **Video rendering** — FFmpeg-based non-linear editing via filter graphs
- **Artifact caching** — `Analysis.json` checkpoint for expensive FFmpeg runs

Planned future capabilities include Whisper transcripts, OCR, chapters,
AI-assisted edit suggestions, DaVinci Resolve XML, Final Cut Pro XML, EDL
export, and additional analysis providers.

The module already implements an analysis checkpoint (`Get-PCXVideoAnalysis`),
an artifact naming catalog (`Get-PCXArtifactDefinitions`), and a
`TimelineMap` that projects markers from the original timeline onto the
edited timeline.

---

## 3. Problem Statement

Several architectural pressures are converging:

**Cost of FFmpeg.** Analysis is the most expensive step. It must never run
twice for the same file. A partial checkpoint system exists for analysis, but
no consistent checkpoint strategy governs video segments or rendered output.

**Recoverability.** If a long pipeline run is interrupted (crash, OOM, power
failure), there is no mechanism to resume from the last completed stage. All
work must be repeated.

**Future expansion.** Adding Whisper, OCR, chapters, AI analysis, and new
export targets must be possible without redesigning the pipeline.

**Timeline projection.** Markers, chapters, subtitles, and other
time-anchored content must be accurately projected from the original timeline
to the edited timeline. This projection logic must exist in one place and must
be reusable across all future exporters.

**Artifact coherence.** Every generated file should follow the same lifecycle:
check, skip or generate, write. No artifact should be overwritten automatically.

---
## 4. Architectural Review

Before prescribing the architecture, this section critically evaluates the
current design against SOLID, DRY, KISS, SRP, Separation of Concerns,
Open/Closed, and Dependency Inversion principles.

### 4.1 Strengths

| Strength | Evidence |
|----------|----------|
| Analysis checkpoint already implemented | `Get-PCXVideoAnalysis` checks for `Analysis.json`, loads it on cache hit, and writes it on cache miss — without reading back the written file |
| Artifact naming is centralized | `Get-PCXArtifactDefinitions` + `Get-PCXArtifactPath` form a single-source-of-truth catalog |
| Artifact lifecycle is centralized | `Test-PCXShouldGenerateArtifact` is called consistently before every write |
| TimelineMap is well-designed | `New-PCXTimelineMapObject` computes coordinate projection between original and edited timelines entirely from in-memory segments |
| Analysis event contract is formalized | `Test-PCXAnalysisEvent` validates a duck-type interface (`SourcePath`, `Start`, `End`, `Duration`, `EventType`), making the segment builder open to new event types without type-name changes |
| Edited-timeline artifacts exist | `Edit-PCXVideoSegments` already generates edited markers and edited cuts using `ConvertTo-PCXEditedTimelineMarker` and `TimelineMap` |
| Provider directory structure exists | `Private/Providers/FFmpeg/`, `Private/Providers/FFprobe/`, `Private/Providers/Whisper/` establish the provider pattern for future expansion |

### 4.2 Weaknesses

| Weakness | Severity | Impact |
|----------|----------|--------|
| No checkpoint for `VideoSegments` | Critical | Segment generation cannot be skipped on subsequent runs; segments are regenerated every time even when analysis is cached |
| No checkpoint for edited-video companion artifacts | Moderate | If the render completes but the process crashes before the edited-segment JSON is written, partial state is silent |
| `Edit-PCXVideoSegments` has mixed responsibilities | Critical | Rendering, audio settings resolution, FFmpeg filter graph construction, marker projection, and artifact lifecycle are all inside one public function |
| `Analyze-PCXVideo` generates segments | Critical | Segment generation is an editing decision, not an analysis fact; this embeds an editing policy inside the analysis layer (SRP violation) |
| Analysis parameters not part of checkpoint key | Moderate | If a user changes `NoiseFloor` or `MinimumDuration` after the checkpoint was written, the stale checkpoint is silently reused |
| No orchestration command | Moderate | Users must understand the full dependency graph to construct correct pipelines; there is no single entry point for the canonical workflow |
| `Get-PCXArtifactPath` uses a closed `ValidateSet` | Moderate | Adding a new artifact type requires modifying the function signature and the catalog, a minor Open/Closed violation |
| Edited-timeline artifacts depend on in-memory events | Moderate | `Edit-PCXVideoSegments` projects markers from `$seg.AnalysisEvents` in memory; if segments are loaded from a JSON checkpoint and `AnalysisEvents` is absent, edited markers are silently empty |

### 4.3 Hidden Coupling

1. **Segment generation inside `Analyze-PCXVideo`.** The analysis layer
   produces editing decisions. Any consumer loading `Analysis.json` receives
   segments generated with the noise floor and duration thresholds active at
   cache-write time, not at load time. Changing thresholds without clearing
   the cache produces incorrect results silently.

2. **Premiere exporter coupled to in-memory event carriage.** The edited
   marker projection in `Edit-PCXVideoSegments` depends on
   `$seg.AnalysisEvents` being populated during the live pipeline run. If
   segments are deserialized from JSON and `AnalysisEvents` is not faithfully
   round-tripped, the edited markers are silently empty.

3. **`Get-PCXVideoDuration` re-invokes FFprobe.** During
   `Get-PCXVideoSegments`, duration is fetched via a fresh FFprobe call even
   though the caller already holds `MediaInformation` in memory. This is a
   hidden, redundant FFprobe invocation.

4. **`TimelineMap` is not serializable by design.** It is computed from
   segments and consumed by `ConvertTo-PCXEditedTimelineMarker`. If the edited
   video already exists but exported markers do not, a subsequent run must
   recompute the `TimelineMap` from `VideoSegments.json`. This path must be
   explicitly supported once the `VideoSegments.json` checkpoint is introduced.

### 4.4 Missing Considerations

- **No `VideoSegments.json` checkpoint.** The most impactful missing piece.
  Failure between analysis and render requires re-running analysis (cached)
  and segment generation before the renderer can continue.

- **No analysis parameter fingerprint.** If `NoiseFloor` changes, the cached
  `Analysis.json` is stale but will be reused silently. The architecture must
  define a detection mechanism.

- **Edited artifacts assume a live pipeline.** The current design only
  generates edited markers and cuts when `Edit-PCXVideoSegments` is called
  with live in-memory segments. Future runs loading from checkpoints cannot
  independently regenerate these artifacts.

### 4.5 Long-Term Risks

| Risk | Probability | Impact |
|------|-------------|--------|
| Adding Whisper requires threading a new event type through all analysis paths | High | Moderate — manageable if the `EventType` contract is strictly enforced |
| Adding DaVinci Resolve XML requires the TimelineMap to support different timecode formats | High | Low — TimelineMap is already decoupled; only the exporter needs to be authored |
| A JSON schema change in `VideoSegments.json` breaks deserialization | Moderate | High — requires a migration strategy |
| `AnalysisEvents` not faithfully serialized causes silent data loss on reload | Moderate | Moderate — edited markers silently disappear on subsequent runs |

---

## 5. Requirements

The architecture must satisfy all of the following requirements.

### REQ-1: Single Analysis
FFmpeg analysis must execute at most once per source file, per analysis
configuration. Re-execution must require an explicit `Force` flag.

### REQ-2: Durable Checkpoints
Every expensive processing stage must produce a durable JSON checkpoint before
the next expensive stage begins. The checkpoint is the persistent source of
truth for future executions.

### REQ-3: Object-Driven First Execution
During first execution, the pipeline continues using in-memory objects. JSON
checkpoints are written as side-effects. The pipeline must not serialize to
JSON and immediately deserialize the result.

### REQ-4: Checkpoint Reuse on Subsequent Executions
On all subsequent executions, existing checkpoints are loaded. Expensive stages
are skipped. Only stages whose checkpoints are absent are executed.

### REQ-5: Failure Recovery
The pipeline must be resumable from the last completed checkpoint after any
interruption: power failure, crash, OOM, deadlock, or OS restart.

### REQ-6: Consistent Artifact Lifecycle
Every artifact follows the same lifecycle:

```
Artifact exists?  -> Skip
Artifact absent?  -> Generate
Force specified?  -> Regenerate
```

No artifact is overwritten automatically.

### REQ-7: Object-Driven Renderer
The active execution pipeline must remain completely object-driven. The
renderer depends on in-memory `VideoSegment` objects, not on previously
generated artifact files.

### REQ-8: Extensible Without Redesign
Adding new analysis types, export targets, or rendering providers must not
require modifying the core pipeline, the artifact lifecycle, or the
orchestration layer.

---

## 6. Architectural Principles

All architectural decisions in this ADR are governed by the following
principles, applied in priority order when conflicts arise.

| Priority | Principle | Application |
|----------|-----------|-------------|
| 1 | **Correctness** | Artifacts must be accurate. Stale checkpoints must not produce incorrect output silently. |
| 2 | **Recoverability** | Every expensive stage must be independently resumable. |
| 3 | **Simplicity (KISS)** | No abstraction is introduced unless it eliminates real duplication or enables real extensibility. |
| 4 | **Single Responsibility (SRP)** | Each function, layer, and module has exactly one reason to change. |
| 5 | **Open/Closed** | The pipeline is open to new analysis types, exporters, and providers without modifying existing code. |
| 6 | **Dependency Inversion** | Higher layers depend on interfaces (the analysis event contract, the `VideoSegment` object), never on concrete providers. |
| 7 | **DRY** | Every piece of knowledge has a single authoritative location. |
| 8 | **Separation of Concerns** | Analysis, editing, export, and rendering are cleanly separated layers with no cross-cutting responsibilities. |

---

## 7. Decision

**We adopt a durable-checkpoint, object-driven pipeline architecture.**

The canonical pipeline flows entirely through in-memory objects during first
execution. At the boundary of each expensive stage, a JSON checkpoint is
written as a durable side-effect. On all subsequent executions, stages whose
checkpoints already exist are skipped and their checkpoints are loaded instead.

The renderer and all exporters depend exclusively on in-memory objects, never
on artifact files. The artifact system exists solely to support future
executions.

The `TimelineMap` is the single authoritative source for all coordinate
projections between the original and edited timelines. Every exporter that
requires timeline projection uses the `TimelineMap`. No exporter implements
its own coordinate math.

---
## 8. Architecture Overview

### Layer Model

```
+------------------------------------------------------------------+
|  Layer 0 - Orchestration                                         |
|  Invoke-PCXVideoPipeline (future)                                |
|  Coordinates the dependency graph. Contains no business logic.   |
+------------------------------------------------------------------+
                             |
+------------------------------------------------------------------+
|  Layer 1 - Media Information                                     |
|  Get-PCXMediaInformation                                         |
|  Get-PCXVideoInformation / Get-PCXAudioInformation               |
|                                                                  |
|  Discovers facts about media files. No editing decisions.        |
|  Depends on: FFprobe provider, MediaInfo provider                |
+------------------------------------------------------------------+
                             |
+------------------------------------------------------------------+
|  Layer 2 - Analysis                                              |
|  Analyze-PCXVideo                                                |
|  Find-PCXSilence / Find-PCXBlackFrames                           |
|  (future: Find-PCXWhisperTranscript, Find-PCXSceneChanges)       |
|                                                                  |
|  Detects temporal events. Produces analysis event objects.       |
|  All events conform to the analysis event contract.              |
|  Writes: Analysis.json (durable checkpoint)                      |
|  Depends on: FFmpeg provider, FFprobe provider                   |
+------------------------------------------------------------------+
                             |
+------------------------------------------------------------------+
|  Layer 3 - Editing Engine                                        |
|  Get-PCXVideoSegments / Optimize-PCXVideoSegments                |
|  New-PCXTimelineMapObject                                         |
|                                                                  |
|  Transforms analysis events into Keep/Remove editing decisions.  |
|  Builds the TimelineMap for timeline coordinate projection.      |
|  Writes: VideoSegments.json (durable checkpoint)                 |
|  Depends on: analysis event contract (not specific event types)  |
+--------------------------+-------------------+-------------------+
                           |                   |
       +-------------------+          +--------+------------------+
       |  Layer 4A - Export|          |  Layer 4B - Rendering    |
       |                   |          |  Edit-PCXVideoSegments   |
       |  Premiere .jsx    |          |  (future: Invoke-PCX-    |
       |  JSON             |          |   VideoRender)           |
       |  future: DaVinci  |          |                          |
       |  future: FCPXML   |          |  Depends on:             |
       |  future: EDL      |          |  VideoSegment[]          |
       |                   |          |  FFmpeg rendering        |
       |  Depends on:      |          |  provider                |
       |  VideoSegment[]   |          |  Writes: Edited.mp4      |
       |  TimelineMap      |          +---------------------------+
       +-------------------+
```

### Key Architectural Invariants

1. **Layer N never imports from Layer N+2.** Analysis does not know about
   exporters. The editing engine does not know about FFmpeg filter graphs.

2. **All analysis events conform to the analysis event contract.** The editing
   engine validates conformance via `Test-PCXAnalysisEvent` and never
   type-checks against specific event type names.

3. **The `TimelineMap` is the only location for timeline coordinate math.**
   It is computed once from `VideoSegment[]` and passed to every consumer
   that requires projected coordinates.

4. **Artifact lifecycle is governed by `Test-PCXShouldGenerateArtifact`.**
   No artifact is written without first testing this function.

5. **Artifact naming is governed by `Get-PCXArtifactPath`.** No artifact
   path is constructed inline in any function.

---

## 9. Processing Pipeline

### 9.1 Complete Pipeline Diagram

```
                    Source Video File
                           |
                           v
            +--------------+--------------+
            |   Layer 1: Media Information |
            |   Get-PCXMediaInformation    |
            +--------------+--------------+
                           |  MediaInformation (memory)
                           v
            +--------------+--------------+
            |   Layer 2: Analysis          |
            |   Find-PCXSilence            |
            |   Find-PCXBlackFrames        |
            |   (future analyzers...)      |
            +--------------+--------------+
                           |
              +------------+-----------+
              |  Memory                |  Checkpoint (side-effect)
              v                        v
   PCXLab.VideoAnalysis         Tutorial-Analysis.json
   (silence[], blackFrames[],   (written once, reused forever)
    media, statistics)
              |
              v
   +----------+---------------+
   |  Layer 3: Editing Engine  |
   |  Get-PCXVideoSegments     |
   |  Optimize-PCXVideoSegments|
   +----------+----------------+
              |
     +--------+--------+
     |  Memory         |  Checkpoint (side-effect)
     v                 v
VideoSegment[]   Tutorial-VideoSegments.json
(Keep/Remove)    (written once, reused forever)
     |
     +----------------------------------------+
     |                                        |
     v                                        v
+-------------------------+    +--------------------------------+
|  Layer 4A: Export       |    |  Layer 4B: Rendering          |
|                         |    |                               |
|  Export-PCXPremiereMarkers   |  Edit-PCXVideoSegments        |
|   -> Tutorial-Markers.jsx   |  (FFmpeg render via segments) |
|                         |    |   -> Tutorial-Edited.mp4     |
|  Export-PCXPremiereEditPoints|                               |
|   -> Tutorial-Cuts.jsx  |    +----------------+--------------+
|                         |                     |
+-------------------------+       Edited.mp4 exists
                                               |
                                               v
                              +----------------+---------------+
                              |  Post-Render Analysis (opt.)   |
                              |                                |
                              |  Analyze-PCXVideo (Edited)     |
                              |   -> Edited-Analysis.json      |
                              |                                |
                              |  Get-PCXVideoSegments          |
                              |   -> Edited-VideoSegments.json |
                              |                                |
                              |  Export-PCXPremiereMarkers     |
                              |   -> Edited-Markers.jsx        |
                              |                                |
                              |  Export-PCXPremiereEditPoints  |
                              |   -> Edited-Cuts.jsx           |
                              +--------------------------------+
```

### 9.2 First Execution — Memory Flows Through

During the first execution, the pipeline is entirely in-memory:

```
Video File
   |
   |  [FFprobe call - runs once]
   v
MediaInformation (memory) --write--> Analysis.json
   |                                 (checkpoint - not re-read)
   |
   |  [FFmpeg analysis - runs once]
   v
VideoAnalysis (memory)
   |  VideoAnalysis IS the analysis object. It is returned directly.
   |
   |  [Segment generation - CPU only]
   v
VideoSegment[] (memory) --write--> VideoSegments.json
   |                               (checkpoint - not re-read)
   |
   +-- [Export - CPU only]
   |      VideoSegment[] --> Markers.jsx, Cuts.jsx
   |
   +-- [Render - FFmpeg - runs once]
          VideoSegment[] --> Edited.mp4
```

> [!IMPORTANT]
> At no point does the active execution pipeline read back a file that was
> just written. Memory is the live data source throughout. Files are
> durability side-effects only.

### 9.3 Subsequent Executions — Checkpoints Are Reused

On all subsequent executions, each stage checks for its checkpoint before
executing:

```
Video File
   |
   +-- Analysis.json exists?
   |     YES -> Load Analysis.json -> VideoAnalysis (memory)
   |            [FFmpeg analysis SKIPPED]
   |     NO  -> Run analysis -> VideoAnalysis (memory)
   |            write -> Analysis.json
   |
   +-- VideoSegments.json exists?
   |     YES -> Load VideoSegments.json -> VideoSegment[] (memory)
   |            [Segment generation SKIPPED]
   |     NO  -> Run Get-PCXVideoSegments -> VideoSegment[] (memory)
   |            write -> VideoSegments.json
   |
   +-- Markers.jsx exists?
   |     YES -> Skip
   |     NO  -> Export-PCXPremiereMarkers -> Markers.jsx
   |
   +-- Cuts.jsx exists?
   |     YES -> Skip
   |     NO  -> Export-PCXPremiereEditPoints -> Cuts.jsx
   |
   +-- Edited.mp4 exists?
         YES -> Skip (render SKIPPED)
         NO  -> Edit-PCXVideoSegments -> Edited.mp4
```

> [!NOTE]
> Each checkpoint is evaluated independently. A pipeline that was interrupted
> after writing `Analysis.json` but before writing `VideoSegments.json` will
> resume from segment generation on the next run. The expensive FFmpeg analysis
> will not repeat.

### 9.4 Failure Recovery Table

| Interrupted After | Resumes From |
|-------------------|--------------|
| Nothing written | Full pipeline from start |
| `Analysis.json` written | Segment generation |
| `VideoSegments.json` written | Export and/or render |
| `Markers.jsx` written | Remaining exports and render |
| `Edited.mp4` written | Post-render analysis (if requested) |

Recovery requires no special recovery mode. The standard execution path
detects existing checkpoints and skips completed stages automatically.

---
