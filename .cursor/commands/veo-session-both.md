# /veo-session-both — Full library (Shorts + long)

Same as full pipeline: **900 shorts + 900 long + all metadata + plan**.

**Shared rules:** read `.cursor/commands/veo-session-shared.md` (patches, veo3 format, resume).

## Usage

```
/veo-session-both
/veo-session-both cinematic
```

## Mode: `both`

| Phase | File | Target |
|-------|------|--------|
| 1 | `prompts-shorts.md` | 900 |
| 2 | `prompts-long-videos.md` | 900 |
| 3 | `youtube-metadata-shorts.md` | 300 |
| 4 | `youtube-metadata-long-videos.md` | 5 |

**Complete when:** all four phases done. Then `/clear` → `/veo-session-both` for next channel.

## Steps

0. **Guards:** `.\tools\veo_session_guards.ps1 -Channel {ch} -Mode both` — if `Ok` is false, **stop**.
1. `.\tools\veo_session_next_channel.ps1 -Mode both` (if no channel in message)
2. If guards say `scaffold`: `.\tools\new_session_scaffold.ps1 -Channel {ch} -Mode both`
3. Follow `$g.Phase` and `$g.NextBatchStart`–`$g.NextBatchEnd` only
4. **10 items per append**, max **30** per turn
5. Shorts: pack headers every 30; long: batch headers every 180
6. `docs/VEO3-PROMPT-SPEC.md` + `channels/{channel}/info.md`
7. **Shorts only:** **Shorts variety** in spec — 3 unique places/voices per Short; never clone the previous triplet

## End message

```
{cinematic} session-NN [both] — shorts 331-360 / 900
Next: /veo-session-both cinematic
```

When complete:

```
{cinematic} [both] COMPLETE. /clear then /veo-session-both for next channel.
```
