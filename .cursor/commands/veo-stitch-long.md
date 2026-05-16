# /veo-stitch-long — FFmpeg: 180 scenes → 1 long video (~24 min)

Concat **per-scene** downloads into **5** long videos.

**Shared rules:** `.cursor/commands/veo-stitch-shared.md`

## Usage

```
/veo-stitch-long cinematic D:\path\to\900\scenes
```

User must provide **ScenesDir**. Ask if missing.

## What it does

| Segment | Scenes | Output (~24 min) |
|---------|--------|------------------|
| Long 1 | 1–180 | `long-01-scenes-1-180.mp4` |
| Long 2 | 181–360 | `long-02-scenes-181-360.mp4` |
| Long 3 | 361–540 | … |
| Long 4 | 541–720 | … |
| Long 5 | 721–900 | … |

Aligns with `plan.md` / `cinematic-long-01` … `05`.

## Steps

0. `.\tools\veo_stitch_guards.ps1 -Channel {ch} -ScenesDir "{path}" -Mode long`
1. `.\tools\veo_stitch.ps1 -Channel {ch} -ScenesDir "{path}" -Mode long -SkipMissingScenes -Session session-01`
2. Outputs → `output/long-videos/`

## Missing scenes

- **Default:** skip missing/corrupt; long file is **shorter** than 24 min (warn user).
- **Strict:** add `-LongsSkipIncomplete` to skip entire long if any of its 180 scenes missing.

## After stitch

Use `youtube-metadata-long-videos.md` for upload copy.
