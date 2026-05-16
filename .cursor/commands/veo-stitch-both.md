# /veo-stitch-both — FFmpeg: Shorts + long from same scene folder

One **ScenesDir** (900 scene files) → both output folders.

**Shared rules:** `.cursor/commands/veo-stitch-shared.md`

## Usage

```
/veo-stitch-both cinematic D:\path\to\900\scenes
```

## Steps

0. Guards: `-Mode both`
1. `.\tools\veo_stitch.ps1 -Channel {ch} -ScenesDir "{path}" -Mode both -SkipMissingScenes`
2. Outputs:
   - `output/shorts/short-NNN.mp4` (300)
   - `output/long-videos/long-NN-…mp4` (5)

Same scene files are used for both; order is global Prompt 1–900.
