# Investigation: FFmpeg blackdetect incorrectly detects entire Bandicam webcam recording as black

**Status:** Paused

**Priority:** Low

**Component:** Find-PCXBlackFrames

**Module Version:** PCXLab.VideoTools 1.1.0

**Investigation Date:** August 2026

---

# Summary

While implementing `Find-PCXBlackFrames`, an unexpected behaviour was discovered when analysing Bandicam webcam recordings.

The FFmpeg `blackdetect` filter reports that the **entire webcam recording is black**, even though the recording clearly contains visible video.

The PowerShell implementation appears to function correctly. The remaining uncertainty appears to be within FFmpeg behaviour and/or the characteristics of Bandicam webcam recordings.

The investigation has been intentionally paused to avoid spending additional engineering time until it becomes important for production.

---

# Test File

Primary sample used during investigation:

```
bandicam 2026-03-18 23-43-48-855.mp4.webcam.mp4
```

Located in recording group:

```
RG_20260318_233950_004
```

---

# Expected Behaviour

The recording contains a normal webcam image.

Expected result:

- Zero black regions
- Or only very short black regions (if any)

---

# Actual Behaviour

FFmpeg consistently reports:

```
black_start:0
black_end:212.9332
black_duration:212.9332
```

Meaning:

Entire recording detected as black.

---

# PowerShell Investigation

The following components were verified.

## Invoke-PCXFFmpeg

Verified.

- Correct executable
- Correct argument passing
- Correct ProcessStartInfo usage
- Correct stderr capture

No issues found.

---

## ConvertTo-PCXBlackFrame

Verified.

Regex successfully parses:

```
black_start
black_end
black_duration
```

Parser produces the expected object.

No issues found.

---

## Find-PCXBlackFrames

Verified.

Objects returned correctly.

Detection count matches parsed output.

No issues found.

---

## Object Creation

Verified.

Generated PCXBlackFrame object contains expected values.

No issues found.

---

# FFmpeg Investigation

Multiple parameter combinations were tested.

## picture_black_ratio (pic_th)

```
0.98
0.10
0.02
0.005
```

Result:

No behavioural change.

Entire recording still detected as black.

---

## pixel_black_threshold (pix_th)

Tested:

```
pix_th=0.10
pix_th=0.98
```

Result:

No behavioural change.

Entire recording still detected as black.

---

## blackframe filter

Tested.

No meaningful indication that frames are actually black.

---

## signalstats filter

Tested using:

```
signalstats,metadata=print
```

Example values:

```
YAVG = 134
YMIN = 15
YMAX = 235
```

These values clearly indicate that the sampled frame contains normal image data.

Therefore:

The decoded frame is NOT black.

---

# Contradiction

The investigation produced an important contradiction.

signalstats reports:

- normal luminance
- normal pixel distribution

blackdetect reports:

Entire recording is black.

These two results should not both be true.

---

# FFmpeg Help Verification

Verified current FFmpeg documentation.

```
picture_black_ratio_th
pic_th

pixel_black_th
pix_th
```

The module uses valid parameter names.

No issue found.

---

# Manual FFmpeg Testing

Manual command-line execution reproduced the same behaviour.

Therefore:

This is NOT caused by PowerShell.

---

# Additional Observations

The issue currently appears specific to webcam recordings.

Desktop recordings were not investigated during this session.

Further comparison testing is still required.

---

# Possible Causes

Unknown.

Possibilities include:

- Bandicam webcam encoder behaviour
- FFmpeg blackdetect bug
- Interaction between blackdetect and low-frame-rate webcam recordings
- Pixel format interpretation
- Colour range interpretation
- Unexpected behaviour in FFmpeg 8.x

None of these have been confirmed.

---

# Recommended Future Investigation

When time permits:

1. Compare desktop recordings.

2. Compare webcam recordings from OBS.

3. Compare recordings from different Bandicam versions.

4. Test older FFmpeg releases.

5. Test newer FFmpeg releases.

6. Inspect FFmpeg blackdetect source code.

7. Compare with histogram analysis.

8. Compare with custom luminance analysis.

9. Build a small standalone reproduction project independent of PCXLab.VideoTools.

---

# Current Decision

Investigation paused.

Continue development of remaining PCXLab.VideoTools features.

Return to this investigation only if webcam black-frame detection becomes important for production workflows.

---

# Confidence Assessment

PowerShell implementation

⭐⭐⭐⭐⭐

Parser

⭐⭐⭐⭐⭐

Object generation

⭐⭐⭐⭐⭐

FFmpeg behaviour

⭐⭐

Root cause

Unknown

---

# Lessons Learned

During this investigation we confirmed that:

- The module architecture is functioning correctly.
- The parser is robust.
- The object model is correct.
- Manual FFmpeg execution reproduces the issue.
- The problem is unlikely to be caused by the PowerShell implementation.

This investigation significantly reduced the possible fault area, making future debugging much easier.