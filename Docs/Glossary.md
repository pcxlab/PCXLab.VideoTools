# Glossary

## Purpose

This glossary defines the common terminology used throughout the PCXLab.VideoTools project.

Its goals are to:

- Ensure consistent terminology across documentation and source code.
- Reduce ambiguity.
- Help new developers and AI assistants understand the architecture.
- Keep terminology independent from any programming language.

---

# Analysis

The process of extracting information from one or more media files.

Examples include:

- Silence detection
- Black-frame detection
- Media information
- Chapters
- Subtitles

---

# Analysis Event

A single event produced during media analysis.

Examples:

- Silence
- Black Frame

Analysis events are later consumed by synchronization and editing.

---

# Artifact

A generated file that can be reused by future executions.

Examples include:

- Analysis JSON
- Recording Session JSON
- Cached synchronization data

Artifacts should be deterministic whenever possible.

---

# Black Frame

A detected period where the video is considered visually black.

Used during editing and quality analysis.

---

# Business Rule

A rule that defines project behaviour independently from the implementation language.

Business rules should never depend on PowerShell, JavaScript, Python, or any specific technology.

---

# Editing

The process of transforming analyzed media into the desired output timeline.

Editing uses analysis and synchronization results to determine which portions of media should be kept or removed.

---

# Helper

A reusable private function that performs one focused task.

Helpers should avoid implementing orchestration logic.

---

# Keep Block

A continuous section of media that should remain in the edited output.

Keep Blocks form the edited timeline.

---

# Policy

A reusable component that encapsulates decision-making logic.

Policies should contain business rules rather than orchestration.

---

# Provider

A reusable component responsible for supplying data or implementing shared business logic.

Providers should have a single responsibility.

---

# Recording Session

A collection of media files that belong to the same recording.

A recording session may contain:

- Webcam
- Screen recording
- Mobile camera
- External cameras

---

# Refactoring

Improving the internal structure of the project while preserving external behaviour.

Refactoring must not intentionally change public APIs unless explicitly planned.

---

# Regression Test

A test that verifies previously working functionality continues to work after changes.

---

# Rendering

The process of producing the final edited media output.

Rendering is the final stage of the processing pipeline.

---

# Silence

A detected period of audio below the configured threshold.

Silence is used when determining edit boundaries.

---

# Synchronization

The process of aligning multiple recordings using common audio events.

Synchronization produces offsets that allow media to be edited together.

---

# Timeline

A representation of media over time.

Timelines are progressively transformed from original recordings into edited output.

---

# Unit Test

A test that validates one isolated unit of functionality.

Unit tests should remain fast, deterministic, and independent.

---

# Update Rules

Update this glossary whenever new terminology becomes part of the project architecture.

Definitions should remain implementation independent.

End of document.