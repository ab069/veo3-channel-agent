# /veo-stitch — Stitch scene downloads with FFmpeg

Pick workflow (same pattern as `/veo-session-*`):

| Command | Output |
|---------|--------|
| **`/veo-stitch-shorts`** | 300 Shorts (3 scenes × 8s each) |
| **`/veo-stitch-long`** | 5 long videos (180 scenes each) |
| **`/veo-stitch-both`** | Both folders |

**You provide:** folder path with `scene-001.mp4` … `scene-900.mp4` (or `scene_001` with `-FilePrefix`).

**Architecture:** `docs/VEO-STITCH-ARCHITECTURE.md`

## Quick example

```
/veo-stitch-shorts cinematic D:\downloads\cinematic-veo-scenes
```

## Missing scenes

Default: **skip** missing/corrupt scenes and continue. See `veo-stitch-shared.md`.

## vs `/veo-merge`

| | `/veo-stitch-*` | `/veo-merge` |
|---|-----------------|--------------|
| Input | 900 separate scene `.mp4` | Few large veo3 pack `.mp4` |
| Method | FFmpeg **concat** | FFmpeg **trim** from packs |
