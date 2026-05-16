# /veo-stitch-shorts — FFmpeg: 3 scenes → 1 Short (~24s)

Concat **per-scene** downloads into **300** Shorts: `short-001.mp4` … `short-300.mp4`.

**Shared rules:** `.cursor/commands/veo-stitch-shared.md`

## Usage

```
/veo-stitch-shorts cinematic D:\path\to\900\scenes
/veo-stitch-shorts cinematic
```

User must give **ScenesDir** (folder with `scene-001.mp4` … `scene-900.mp4`). Ask if missing.

## What it does

| Input | Output |
|-------|--------|
| 900 × ~8s scene files | **300** Shorts (3 scenes each) |

```
Scenes 1-3   → short-001.mp4
Scenes 4-6   → short-002.mp4
…
Scenes 898-900 → short-300.mp4
```

## Steps

0. `.\tools\veo_stitch_guards.ps1 -Channel {ch} -ScenesDir "{path}" -Mode shorts`
1. `.\tools\veo_stitch.ps1 -Channel {ch} -ScenesDir "{path}" -Mode shorts -SkipMissingScenes -Session session-01`
2. Outputs → `channels/{ch}/sessions/session-01/output/shorts/` (or channel `output/shorts`)
3. Read `stitch-report.json` + warnings for skipped scenes

## Missing scenes

Default: **skip** bad/missing clips. Re-download failed scene numbers, re-run stitch for that range only if needed.

## After stitch

Paste metadata from `youtube-metadata-shorts.md` — `short-NNN.mp4` matches `Short #NNN`.
