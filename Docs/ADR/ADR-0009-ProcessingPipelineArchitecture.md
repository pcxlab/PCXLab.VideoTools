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
executed at most once through a checkpoint-aware analysis entry point, how
durable checkpoints protect work across process boundaries, and how the active
execution pipeline remains object-driven during first execution while
checkpoints are written as durable side-effects.

The architecture is founded on five invariants:

1. **Single Analysis.** A checkpoint-aware analysis entry point reuses the
   corresponding checkpoint when available and runs analysis on a cache miss.

2. **Durable Checkpoints.** Expensive processing stages write durable JSON
   checkpoints at their respective boundaries. These checkpoints protect
   completed work across process boundaries.

3. **Object-Driven Active Pipeline.** During first execution, in-memory
   objects flow through the analysis, editing, and rendering stages. JSON
   files are durable side-effects, not intermediaries for that execution.

4. **Checkpoint Reuse.** On subsequent executions, available checkpoints are
   reused and their corresponding processing stages are skipped when the
   checkpoint already exists.

5. **Failure Recovery.** Durable checkpoints provide a basis for resuming
   completed stages after interruption.

---

## 2. Context

`PCXLab.VideoTools` is a production-grade PowerShell module that automates
technical video editing. Its current capabilities include:

- **Media analysis** — media information, silence detection, and black frame
   detection
- **Video editing** — Keep/Remove timeline segment generation
- **Timeline mapping** — projection between original and edited timelines
- **Edited timeline generation** — edited analysis results and video segments
- **Premiere export** — markers and razor cuts
- **Video rendering** — non-linear editing of video through FFmpeg
- **Artifact management** — naming and lifecycle handling for generated outputs

---

## 3. Problem Statement

Several architectural pressures are converging:

**Cost of FFmpeg.** Analysis remains the most expensive step. Reusing completed
analysis work while preserving the correctness of downstream processing is
central to the processing model.

**Checkpoint consistency.** Multiple processing stages produce durable
checkpoints and generated artifacts. Their reuse must remain consistent with
the in-memory results and with the stages that depend on them.

**Cache freshness.** Existing checkpoints are reused across executions, while
the implementation does not establish freshness from source changes,
processing parameters, or dependency state.

**Timeline projection.** Markers, chapters, subtitles, and other
time-anchored content must remain consistent when projected from the original
timeline to the edited timeline.

**Pipeline orchestration.** Processing stages are composed through cmdlet
pipelines, while checkpoint reuse, edited artifact generation, and rendering
are coordinated across separate processing boundaries.

---
## 4. Architectural Review

Before prescribing the architecture, this section critically evaluates the
current design against SOLID, DRY, KISS, SRP, Separation of Concerns,
Open/Closed, and Dependency Inversion principles.

### 4.1 Strengths

| Strength | Evidence |
|----------|----------|
| Analysis checkpoint implemented | `Get-PCXVideoAnalysis` checks, imports, and exports the analysis checkpoint on cache hit and cache miss |
| Video segment checkpoint implemented | `Get-PCXVideoSegments` checks, imports, and exports the video segment checkpoint on cache hit and cache miss |
| Edited timeline checkpoints implemented | `Edit-PCXVideoSegments` creates projected edited analysis and invokes `Get-PCXVideoSegments` for edited segment generation |
| Artifact naming is centralized | `Get-PCXArtifactDefinitions` and `Get-PCXArtifactPath` provide the artifact catalog and path resolution |
| Artifact lifecycle is centralized | `Test-PCXShouldGenerateArtifact` controls generation, skipping, and forced regeneration for artifact writers |
| TimelineMap supports edited timeline projection | `New-PCXTimelineMapObject` computes coordinate intervals, edited duration, and seam data from in-memory segments |
| Analysis event contract is formalized | `Test-PCXAnalysisEvent` validates the required temporal and source properties used by segment generation |
| Edited-timeline artifacts are generated | `Edit-PCXVideoSegments` generates edited markers, edited cuts, projected analysis, and edited segments from in-memory processing state |
| Object-driven rendering is implemented | `Edit-PCXVideoSegments` passes collected `VideoSegment` objects to filter-graph and FFmpeg rendering functions |
| Provider-specific integrations are separated | FFmpeg and FFprobe operations are implemented in provider-specific functions under `Private/Providers/` |

### 4.2 Weaknesses

| Weakness | Severity | Impact |
|----------|----------|--------|
| `Edit-PCXVideoSegments` has mixed responsibilities | Critical | Rendering, audio settings resolution, FFmpeg filter graph construction, marker projection, and artifact lifecycle are all inside one public function |
| Checkpoint validation is existence-only | Moderate | Analysis and video-segment cache checks use file existence without validating source identity, schema, metadata, or checkpoint contents |
| Checkpoint freshness is not established | Moderate | Existing analysis checkpoints are reused without incorporating source changes, analysis parameters, module version, or dependency state |
| No central orchestration command | Moderate | The complete processing sequence is composed by callers across separate analysis, editing, export, and rendering commands |
| `Get-PCXArtifactPath` uses a closed `ValidateSet` | Moderate | Adding a new artifact type requires modifying the function signature and the catalog, a minor Open/Closed violation |
| Edited-timeline generation depends on attached analysis events | Moderate | `Edit-PCXVideoSegments` derives event-based markers and edited analysis from `$seg.AnalysisEvents`; segments without attached events produce no event-derived outputs |
| Edited segment results are not the renderer input | Moderate | `Edit-PCXVideoSegments` generates edited segments through `Get-PCXVideoSegments` but renders from the original `$Segments` collection |

### 4.3 Hidden Coupling

1. **Analysis configuration and checkpoint reuse.** `Get-PCXVideoAnalysis`
   selects the analysis checkpoint by source-derived path, while
   `Test-PCXVideoAnalysisCache` checks only whether that path exists. The
   checkpoint is therefore reused without configuration or source-freshness
   validation.

2. **Edited artifact generation coupled to segment event carriage.**
   `Edit-PCXVideoSegments` collects `$seg.AnalysisEvents` before generating
   edited markers and projected analysis. `Import-PCXVideoSegment` restores
   attached events when present, but the edited outputs remain dependent on
   that segment property.

3. **Edited checkpoint generation coupled to the original in-memory segments.**
   `Edit-PCXVideoSegments` passes projected analysis to
   `Get-PCXVideoSegments` to produce edited segments, but the rendering branch
   continues using the original segment collection.

4. **Companion artifact generation coupled to rendering control flow.**
   `Edit-PCXVideoSegments` performs edited cuts, markers, analysis, and segment
   processing inside a `try` block before the independent edited-video
   generation branch. Exceptions in the companion block are converted to
   warnings before rendering continues.

5. **Duration resolution coupled to input representation.**
   `Get-PCXVideoSegments` uses `Resolve-PCXVideoAnalysisDuration` for a
   `VideoAnalysis` container and `Get-PCXVideoDuration` for loose events.
   These paths resolve duration from different sources based on the supplied
   input shape.

### 4.4 Missing Considerations

- **Independent checkpoint ownership.** Analysis, original segments, edited
   analysis, and edited segments are created and reused by different command
   paths. The current implementation does not document their complete
   ownership relationship.

- **Projected analysis as an intermediate object.** `Edit-PCXVideoSegments`
   creates a synthetic analysis container, projects it onto the edited
   timeline, exports it, and passes it into segment generation. This intermediate
   object is not separately described in the current architectural record.

- **Conditional edited outputs.** Edited cuts, markers, analysis, and segments
   are generated only when their computed inputs are nonempty. The current
   implementation does not establish that every execution produces every
   edited artifact.

- **Companion processing before rendering.** Edited companion artifacts are
   attempted before the edited video render, and failures in that block are
   handled separately from the render branch.

### 4.5 Long-Term Risks

| Risk | Probability | Impact |
|------|-------------|--------|
| Analysis checkpoints reused after source or parameter changes | High | High — downstream analysis and editing results can remain based on older inputs |
| A JSON schema change in analysis or video-segment checkpoints breaks deserialization | Moderate | High — imported checkpoint objects may not satisfy current processing expectations |
| `AnalysisEvents` not faithfully preserved through segment export/import | Moderate | Moderate — event-derived edited markers and projected analysis may be absent |
| Independent artifact existence checks permit inconsistent stage outputs | High | Moderate — downstream artifacts can remain present while an upstream checkpoint is regenerated |
| Adding a new analysis collection requires corresponding container extraction support | Moderate | Moderate — the segment builder currently extracts defined analysis collections explicitly |

---

## 5. Requirements

The architecture must satisfy all of the following requirements.

### REQ-1: Single Analysis
Analysis must execute at most once per source file and analysis configuration.
Regeneration must require an explicit `Force` flag.

### REQ-2: Durable Checkpoints
Every expensive processing stage that produces reusable state must produce a
durable JSON checkpoint before the next expensive stage begins. The checkpoint
is the persistent source of truth for future executions.

### REQ-3: Object-Driven First Execution
During first execution, the pipeline continues using in-memory objects. JSON
checkpoints are written as side-effects. The pipeline must not serialize to
JSON and immediately deserialize the result.

### REQ-4: Checkpoint Reuse on Subsequent Executions
On subsequent executions, existing checkpoints must be loaded and their
corresponding stages skipped. Only stages whose checkpoints are absent may be
executed.

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
| 1 | **Correctness** | Artifacts and derived results must accurately represent their source inputs and processing state. |
| 2 | **Recoverability** | Completed processing stages must be independently resumable from durable checkpoints. |
| 3 | **Simplicity (KISS)** | No abstraction is introduced unless it eliminates real duplication or enables real extensibility. |
| 4 | **Single Responsibility (SRP)** | Each function, layer, and module has exactly one reason to change. |
| 5 | **Open/Closed** | The pipeline is open to new analysis types, exporters, and providers without requiring changes to established processing responsibilities. |
| 6 | **Dependency Inversion** | Higher layers depend on stable contracts and abstractions rather than concrete provider implementations. |
| 7 | **DRY** | Every piece of knowledge has a single authoritative location. |
| 8 | **Separation of Concerns** | Analysis, editing, export, rendering, and checkpoint management remain distinct responsibilities with limited cross-cutting behavior. |

---

## 7. Decision

**We adopt a durable-checkpoint, object-driven pipeline architecture.**

The processing pipeline flows through in-memory objects during first
execution. At the boundary of each reusable processing stage, a durable JSON
checkpoint is written as a side-effect. On subsequent executions, completed
stages are reused from their available checkpoints where applicable.

The active processing flow is object-driven, while durable checkpoints provide
persistent state across executions. Artifact ownership follows the processing
stage that produces each artifact.

The `TimelineMap` is the single authoritative source for all coordinate
projections between the original and edited timelines. Every exporter that
requires timeline projection uses the `TimelineMap`, and coordinate projection
logic is not duplicated across exporters.

---
## 8. Architecture Overview

### Layer Model

```
+------------------------------------------------------------------+
|  Layer 0 - Orchestration                                         |
|  Caller-composed processing commands                             |
|  Coordinates processing stages without business logic.           |
+------------------------------------------------------------------+
             |
+------------------------------------------------------------------+
|  Layer 1 - Media Information                                     |
|  Media, video, and audio information                             |
|                                                                  |
|  Discovers facts about media files. No editing decisions.        |
|  Uses media-information providers.                               |
+------------------------------------------------------------------+
             |
+------------------------------------------------------------------+
|  Layer 2 - Analysis                                              |
|  Analysis orchestration and event detection                      |
|                                                                  |
|  Produces VideoAnalysis and analysis event objects.               |
|  Analysis events conform to the analysis event contract.          |
|  Owns analysis-stage results and their durable checkpoint.         |
+------------------------------------------------------------------+
             |
+------------------------------------------------------------------+
|  Layer 3 - Editing Engine                                        |
|  Segment generation / optimization / timeline mapping             |
|                                                                  |
|  Transforms analysis events into Keep/Remove decisions and         |
|  provides timeline projection data.                               |
|  Owns editing-stage results and their durable checkpoints.         |
+--------------------------+-------------------+-------------------+
               |                   |
   +-------------------+          +--------+------------------+
   |  Layer 4A - Export|          |  Layer 4B - Rendering    |
   |  Premiere marker  |          |  Video rendering         |
   |  and cut export   |          |                          |
   |                   |          |  Consumes VideoSegment[]|
   |  Consumes        |          |  Consumes                |
   |  VideoSegment    |          |  VideoSegment            |
   |  and TimelineMap  |          |                          |
   +-------------------+          +---------------------------+
```

### Key Architectural Invariants

1. **Layer responsibilities remain separated.** Analysis produces facts,
   editing produces timeline decisions, exports produce external documents,
   and rendering produces edited media.

2. **Analysis events conform to a stable contract.** Editing consumes temporal
   event data through the analysis event contract rather than depending on
   event-specific implementation details.

3. **The `TimelineMap` is the authoritative source for timeline projection.**
   Coordinate transformations between original and edited timelines are
   represented by the map and shared by consumers that require them.

4. **Artifact lifecycle follows a consistent policy.** Generated artifacts
   follow consistent existence, skip, and forced-regeneration behavior.

5. **Artifact naming is centralized.** Artifact paths are resolved from a
   shared catalog rather than duplicated across processing stages.

---

## 9. Processing Pipeline

### 9.1 Complete Pipeline Diagram

```
Caller-composed processing stages
          |
          v
     Analysis object flow
          |
          +----> Analysis checkpoint
          |
          v
     VideoSegment generation
          |
          +----> VideoSegment checkpoint
          |
          v
     Edit-PCXVideoSegments
          |
          +----> TimelineMap
          |          |
          |          +----> Edited markers / edited cuts
          |
          +----> Projected edited analysis
          |          |
          |          +----> Edited analysis checkpoint
         |
         +----> Edited VideoSegment generation
         |          |
         |          +----> Edited segment checkpoint
         |
         +----> Original in-memory VideoSegment rendering
                |
                +----> Edited video
```

### 9.2 First Execution — Memory Flows Through

During a cache miss, processing continues with in-memory objects while durable
artifacts are written as side-effects:

```
Video File
   |
   v
Analysis object (memory) ----> Analysis checkpoint
   |
   v
VideoSegment[] (memory) -----> VideoSegment checkpoint
   |
   v
TimelineMap (memory)
   |
   +----> Edited markers and cuts
   |
   +----> Projected edited analysis (memory)
   |          |
   |          +----> Edited analysis checkpoint
   |
   +----> Edited VideoSegment[] (memory) -> Edited segment checkpoint
   |          |
   |          +----> Reusable edited segment state
   |
   +----> Original VideoSegment[] (memory) -> Edited video
```

> [!IMPORTANT]
> During first execution, the active processing flow uses in-memory objects.
> Checkpoints are written as durable side-effects and are not required as
> intermediaries for the objects already in flight.

### 9.3 Subsequent Executions — Checkpoints Are Reused

On subsequent executions, checkpoint-aware stages independently check for
existing checkpoints. Available checkpoints are imported and returned to the
caller; missing checkpoints cause the corresponding stage to execute.

```
Analysis checkpoint exists?
   YES -> Import analysis object
   NO  -> Generate analysis object -> Write checkpoint
            |
            v
VideoSegment checkpoint exists?
   YES -> Import VideoSegment[]
   NO  -> Generate VideoSegment[] -> Write checkpoint
            |
            v
Edited artifacts and edited video
   Existing outputs are skipped by their artifact lifecycle checks;
   missing outputs are generated from the available in-memory state. The
   renderer continues to consume the original in-memory VideoSegment[].
```

> [!NOTE]
> Each checkpoint is evaluated independently. A completed checkpoint can be
> reused by a later execution, while a missing checkpoint causes its associated
> processing stage to run. The implementation does not establish dependency
> freshness or automatic invalidation between checkpoints.

### 9.4 Failure Recovery Table

| Completed durable state | Next execution can begin with |
|-------------------------|-------------------------------|
| No checkpoint available | Analysis processing |
| Analysis checkpoint | Video segment processing |
| Video segment checkpoint | Edited processing or rendering |
| Edited checkpoint | The remaining caller-invoked stages |

The standard execution paths check for available checkpoints and reuse them
where supported. The implementation does not provide transactional writes,
automatic dependency invalidation, or a guarantee that every interrupted
execution leaves a complete checkpoint.

---

## 10. Timeline Mapping

`TimelineMap` is an in-memory representation of the relationship between the
original source timeline and the edited timeline. It is created from
`VideoSegment[]` after editing segments have been generated and retains the
source identity, original duration, edited duration, total removed duration,
kept timeline intervals, and edited cut points.

Each interval records the corresponding original and edited start and end
positions together with its duration. Coordinate projection uses these kept
intervals: events and markers that overlap kept content are shifted to the
edited timeline, clamped to the visible interval where necessary, and content
that falls entirely within removed content is omitted.

The map is consumed by edited analysis projection, edited marker projection,
and edited cut-point generation. It provides the coordinate relationship and
derived timeline values used by those stages.

`TimelineMap` does not detect analysis events, generate Keep/Remove segments,
render media, persist checkpoints, import artifacts, or perform filesystem
media probing. Those responsibilities remain outside the timeline mapping
object.

---

## 11. Artifact Dependency Graph

Durable artifacts represent persisted results of in-memory processing stages.
Their dependencies are:

```
VideoAnalysis
   |
   +----> Analysis checkpoint
   |
   +----> VideoSegment[]
           |
           +----> Video segment checkpoint
           |
           +----> TimelineMap
                  |
                  +----> Edited marker export
                  |
                  +----> Edited cut export
                  |
                  +----> Projected VideoAnalysis
                  |          |
                  |          +----> Edited analysis checkpoint
                  |
                  +----> Edited VideoSegment[]
                           |
                           +----> Edited segment checkpoint (reusable)

VideoSegment[]
   |
   +----> Edited video render (renderer input)
```

The analysis checkpoint is derived from the in-memory `VideoAnalysis` object
and is reusable as an imported analysis object. The video segment checkpoint
is derived from the in-memory `VideoSegment[]` result and is reusable as an
imported segment collection.

The projected edited analysis checkpoint is derived from projected analysis
objects. The edited segment checkpoint is created by the segment-generation
stage from the projected analysis and is reusable persisted processing state.
It is not the input to the edited video render; rendering consumes the original
in-memory `VideoSegment[]` collection.

Edited markers and edited cuts are terminal editor-export artifacts derived
from the segment data and the `TimelineMap`. The edited video is a terminal
media output derived from `VideoSegment[]`. These terminal outputs are not
inputs to the JSON processing checkpoints.

---

## 12. Artifact Lifecycle

Generated artifacts follow a common lifecycle. A missing target is generated,
an existing target is skipped, and an explicit force request permits
regeneration. Artifact ownership remains with the processing stage that
produces the artifact.

### Reusable Checkpoints

Durable JSON checkpoints are created from in-memory processing results and
written at the boundary of the stage that produces them. When a checkpoint is
available, its corresponding import path can restore the persisted object for
reuse. When it is absent, the producing stage generates the in-memory result
and writes a new checkpoint.

Checkpoint cache checks determine availability from the checkpoint path. The
implementation does not establish freshness or dependency invalidation as part
of this lifecycle. A checkpoint may therefore remain present while its source
or an upstream result has changed.

### Terminal Outputs

Exported editor artifacts are generated from the in-memory editing state when
their computed inputs are present. Existing outputs are skipped unless forced,
and missing outputs are written by their producing stage. The implementation
does not import these editor outputs as processing checkpoints.

Rendered media is a terminal filesystem output. Its existing path is checked
before rendering; an existing output is returned without rendering unless
forced, while an absent output is generated from the in-memory video segments.

---

## 13. Artifact Naming

Artifact naming is centralized through a shared catalog of logical artifact
types. Each type defines the naming information required to resolve its
filesystem path, including its suffix, extension, and separator conventions.

Processing stages identify an artifact by its logical type and source media
path. The naming system derives the default artifact location and filename
from that source, preserving consistent placement and naming across durable
checkpoints, editor exports, and rendered media outputs.

An explicitly supplied output path takes precedence over the default path
derived from the logical type and source. Path resolution therefore remains a
separate responsibility from artifact production, while artifact names remain
owned by the centralized naming catalog rather than by individual processing
stages.

---

## 14. Implementation Boundaries

The major architectural responsibilities are divided as follows:

| Component | Owns | Consumes | Produces | Does not own |
|-----------|------|----------|----------|--------------|
| Analysis | Discovery of media facts and temporal analysis events | Source media and analysis settings | Analysis event objects and analysis data | Editing decisions, timeline projection, or rendered media |
| Analysis entry point | Coordination of analysis results and their reusable analysis state | Source media and analysis configuration | `VideoAnalysis` objects and analysis checkpoints | Segment decisions, edited-timeline projection, or rendering |
| `VideoAnalysis` | Source identity, media metadata, and collections of analysis results | Media facts and analysis events | A complete analysis container | Keep/Remove decisions, `TimelineMap`, exports, or rendered media |
| VideoSegment generation | Conversion of analysis events into Keep/Remove timeline decisions and generation of segment checkpoint state | `VideoAnalysis` or analysis events | Original or projected `VideoSegment[]` and segment checkpoint state | Event detection, coordinate projection, or media rendering |
| `TimelineMap` | The coordinate relationship between original and edited timelines | `VideoSegment[]` | Kept intervals, edited duration, removed duration, and cut points | Event detection, segment generation, artifact persistence, or rendering |
| Editing | Coordination of segment decisions, timeline projection, edited analysis, and edited segment generation | `VideoSegment[]`, analysis events, and `TimelineMap` | Projected analysis and editing state for rendering or export | Ownership of segment generation or segment checkpoint export, media discovery, or provider-specific media operations |
| Export | Conversion of domain objects into external documents | Analysis objects, video segments, and timeline projection data where required | JSON checkpoints and editor export files | Analysis discovery, segment decisions, or media rendering |
| Rendering | Production of edited media from editing decisions | `VideoSegment[]` and source media | Rendered media output | Analysis discovery, checkpoint identity, or editor document formats |
| Artifact management | Logical artifact naming, path resolution, and artifact lifecycle policy | Logical artifact types, source paths, and output options | Resolved paths and artifact availability decisions | Analysis, editing, projection, or rendering decisions |
| Provider layer | Integration with external media-processing tools | Provider-specific requests and media files | Media facts, analysis results, or rendered media according to the provider operation | Domain editing policy and timeline ownership |

These boundaries distinguish analysis facts from editing decisions, timeline
projection from artifact production, and external document generation from
media rendering. Components may exchange their defined domain objects, but the
responsibility for producing those objects remains with the component that
owns that stage.

---

## 15. Design Principles Mapping

| Principle | Architectural alignment |
|-----------|-------------------------|
| **Correctness** | Domain objects retain source identity and temporal data, while timeline projection is represented by a dedicated mapping object. Checkpoint reuse is currently based on artifact availability rather than source, parameter, or dependency freshness. |
| **Recoverability** | Durable checkpoints preserve completed processing results for later reuse. The implementation does not provide transactional checkpoint writes or automatic dependency invalidation. |
| **Simplicity (KISS)** | Processing is expressed through focused domain objects, stage boundaries, and shared artifact services. The active processing sequence remains composed across separate processing commands. |
| **Single Responsibility (SRP)** | Analysis, segment generation, timeline projection, export, rendering, and artifact management have distinct architectural responsibilities. The editing boundary also coordinates companion artifact generation and rendering preparation. |
| **Open/Closed** | The analysis event contract allows editing components to consume temporal event objects without depending on concrete event type names. Container analysis collection handling and logical artifact types remain explicitly defined. |
| **Dependency Inversion** | Higher-level processing uses domain contracts such as analysis events, `VideoAnalysis`, `VideoSegment`, and `TimelineMap`. Media operations are connected through provider-specific boundaries. |
| **DRY** | Artifact naming, path resolution, lifecycle policy, and timeline coordinate projection are represented in centralized architectural responsibilities. |
| **Separation of Concerns** | Analysis facts, editing decisions, timeline projection, external document generation, rendered media, and artifact services are represented as separate concerns, with coordination at the editing boundary. |

---

## 16. Extensibility

The architecture exposes extension points through stable domain objects and
contracts rather than through a single processing implementation.

### Implemented Extension Mechanisms

- Analysis events conform to a shared temporal event contract, allowing the
   editing layer to consume different event shapes without depending on their
   concrete type names.
- `VideoAnalysis`, `VideoSegment`, and `TimelineMap` are reusable domain
   objects that can be consumed by multiple processing and export stages.
- Timeline-aware consumers use `TimelineMap` for edited marker projection,
   edited cut generation, and projected analysis data.
- Media operations are separated behind provider-specific integration points,
   while artifact naming is represented through logical artifact types in a
   shared catalog.

### Architectural Extension Points

Additional analysis providers can produce event objects that conform to the
analysis event contract. Additional exporters can consume the established
analysis, segment, and timeline objects to produce other external formats.
Additional rendering providers can consume `VideoSegment[]` as the editing
decision model while producing rendered media through their provider boundary.
Additional artifact types can be represented through the logical artifact
naming model.

These extension points describe capabilities enabled by the current domain
contracts and provider boundaries. The implementation currently provides the
existing analysis, Premiere export, and FFmpeg rendering integrations; other
provider, export-format, and artifact-type implementations are not present in
the current codebase.

---

## 17. Trade-offs

| Architectural choice | Benefit | Cost or limitation |
|----------------------|---------|--------------------|
| Object-driven processing with durable checkpoints | Keeps the active processing flow in memory while preserving completed work across executions | In-memory state and persisted state must remain consistent across processing boundaries |
| Independent checkpoint ownership | Allows each reusable processing stage to persist and restore its own results | Checkpoints can be evaluated independently without automatic dependency invalidation |
| Caller-composed orchestration | Keeps stage composition explicit and allows callers to combine analysis, editing, export, and rendering operations | The complete processing relationship is distributed across caller pipelines rather than one coordinating operation |
| Reusable domain objects | Allows analysis, editing, projection, export, and rendering stages to exchange structured results | Consumers must preserve the required object contracts and attached data between stages |
| Centralized artifact services | Keeps logical artifact naming, path resolution, and lifecycle policy consistent across output types | Artifact behavior remains dependent on the shared catalog and lifecycle rules |
| Provider abstraction | Separates media-tool integration from domain editing decisions | Provider-specific behavior remains necessary for media discovery, analysis, and rendering operations |
| Timeline projection through `TimelineMap` | Provides one coordinate relationship for original and edited timelines and allows multiple consumers to share projected positions | Projection depends on the available segment timeline and does not itself own analysis or editing decisions |
| Separate export responsibilities | Allows domain results to be represented in external editor documents without coupling those documents to media rendering | Export outputs remain separate terminal artifacts and do not form the live rendering input |

---

## 18. Alternatives Considered

| Alternative | Advantages | Disadvantages | Why the current architecture was preferred |
|-------------|------------|---------------|---------------------------------------------|
| Fully file-driven processing | Durable artifacts are the direct inputs between stages and can be inspected independently | Each stage depends on filesystem reads and loses the continuity of in-memory domain objects during one processing run | The selected object-driven flow preserves in-memory state while writing checkpoints for later reuse |
| Fully object-only processing | Minimal filesystem coordination and direct object exchange between stages | Completed processing state is not preserved across executions or process boundaries | The selected architecture combines in-memory processing with durable checkpoints |
| Centralized orchestration command | Provides one entry point for coordinating the complete processing relationship | Couples stage composition and lifecycle decisions to one coordinator | Caller-composed orchestration keeps the existing processing stages independently invokable |
| Shared ownership of checkpoints | A common owner can coordinate all persisted state in one place | Processing stages become coupled to a shared persistence responsibility | Stage-specific ownership keeps each checkpoint associated with the stage that produces its result |
| Duplicated projection logic | Each consumer can apply rules directly for its output format | Coordinate transformations can diverge between consumers | `TimelineMap` provides one shared coordinate relationship for projection consumers |
| Provider-specific logic inside business logic | Direct access to provider capabilities can simplify a single integration | Domain responsibilities become coupled to concrete media tools | Provider boundaries separate media-tool integration from analysis and editing decisions |

---

## 19. Risks and Mitigations

| Risk | Architectural Mitigation | Remaining Limitation |
|------|---------------------------|----------------------|
| Checkpoint reuse without freshness validation | Processing stages persist reusable results and use checkpoint-aware paths to restore completed work | Checkpoint availability is not validated against source changes, processing parameters, or dependency state |
| Dependency inconsistency across independently owned checkpoints | Each processing stage owns its persisted result and exposes the corresponding domain object for reuse | Checkpoints are evaluated independently and are not automatically invalidated when an upstream result changes |
| Serialization compatibility | Import and export boundaries preserve the persisted domain objects and restore their expected object types and temporal values | A changed checkpoint shape may not satisfy the expectations of the current import path |
| Object contract evolution | Shared contracts define the temporal data exchanged between analysis and editing stages | Consumers remain dependent on the required contract properties being present and valid |
| TimelineMap correctness | A dedicated map represents original and edited intervals and is shared by timeline-aware consumers | Projection depends on the segment timeline used to create the map |
| Provider dependency | External media operations are separated behind provider boundaries, keeping domain objects independent of tool invocation details | Analysis and rendering remain dependent on the availability and behavior of their providers |
| Artifact consistency | Centralized naming and lifecycle rules provide consistent path resolution and output handling | Independently generated artifacts can remain present when related upstream state has changed |
| Rendering consistency | Rendering consumes the established `VideoSegment` decision model and source media | Rendered media is produced from the in-memory segment collection and is not validated against every persisted companion artifact |
| Long-running processing interruption | Durable checkpoints preserve completed stage results for reuse after an interrupted execution | Transactional writes and complete recovery of every interrupted execution are not provided |

---

## 20. Future Considerations

The current architecture intentionally preserves extension points for
capabilities that can use the existing domain contracts and processing
boundaries without changing the architectural model.

- **Additional analysis providers.** Analysis providers can produce temporal
   event objects conforming to the established analysis event contract, allowing
   them to participate in existing editing and projection responsibilities.

- **Additional export formats.** Export formats can consume `VideoAnalysis`,
   `VideoSegment`, and `TimelineMap` objects through the existing export
   boundary, without changing the domain objects used by processing stages.

- **Additional rendering providers.** Rendering providers can consume the
   `VideoSegment` decision model through the rendering boundary, preserving the
   separation between editing decisions and media-tool integration.

- **Richer timeline-aware artifacts.** Artifacts that carry time-anchored
   analysis or editing data can use the existing `TimelineMap` representation
   to relate original and edited timeline coordinates.

- **Additional artifact types.** New persisted or generated outputs can use
   the existing logical artifact type and centralized path-resolution model.

- **Checkpoint evolution.** Additional reusable processing state can follow
   the existing checkpoint boundary while remaining separate from the
   in-memory objects used during active processing.

- **Additional domain objects.** New processing results can be represented as
   domain objects and exchanged through established contracts, provided their
   temporal or editing relationships remain compatible with the existing model.

These considerations describe capabilities enabled by the current
architecture. The corresponding providers, formats, artifact types, and
domain objects are not implemented unless already provided elsewhere in the
module.

---

## 21. Open Questions

- What freshness policy should determine whether a persisted checkpoint still
   represents its source media, processing configuration, and upstream state?

- What dependency invalidation strategy should govern independently owned
   checkpoints when an upstream processing result changes?

- How should checkpoint schemas evolve while preserving compatibility with
   persisted objects created by earlier versions of the architecture?

- What artifact compatibility rules should apply across module and domain
   object versions?

- What is the long-term ownership model for composing analysis, editing,
   export, rendering, and checkpoint-aware processing stages?

- How should future domain object and analysis event contract evolution remain
   compatible with persisted checkpoints and existing consumers?

---

## 22. Recommendations

- Treat this ADR as the authoritative architectural reference for the
   processing model.

- Update this ADR when architectural responsibilities, ownership boundaries,
   or processing relationships change.

- Record changes that alter the adopted architecture through an amendment or
   a new ADR.

- Keep architecture diagrams, ownership descriptions, and dependency graphs
   synchronized with the production implementation.

- Keep checkpoint, artifact, domain-object, and processing terminology
   consistent across related architectural records.

- Preserve the distinction between architectural decisions and implementation
   details when maintaining this ADR.

---
