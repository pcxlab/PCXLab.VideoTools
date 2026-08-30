# Production Recording Architecture

## Recording Hierarchy

F:\Recordings
    YYYYMMDD [Optional Title]
        RG_YYYYMMDD_HHMMSS_###

The Recording Group (RG) is the logical recording session.
The date folder is only for organization.

---

## Recording Session

A recording session may contain:

- One or more desktop recordings
- Zero or more webcam recordings
- Zero or more phone recordings
- Generated metadata
- Generated outputs

The software must never assume a fixed number of recordings.

---

## RecordingSession.json

RecordingSession.json is the canonical description of a recording session.

Commands should operate on the RecordingSession model rather than individual files wherever possible.

---

## Processing Model

Sources
    ↓
Synchronization
    ↓
Analysis
    ↓
Video Segments
    ↓
Editing
    ↓
Premiere Export

Each stage produces additional artifacts.
Original recordings are never modified.

---

## Production Dataset

The production recordings act as an integration/regression dataset.

Representative sessions should be retained to validate future changes, including:

- Desktop only
- Desktop + Webcam
- Desktop + Phone
- Desktop + Webcam + Phone
- Multiple desktop recordings
- Multiple phone recordings
- Long recordings
- Short recordings
- Partially processed sessions