# /veo-session-shorts — 900 portrait Shorts only

Build **Shorts-only** session: `prompts-shorts.md` (900) + `youtube-metadata-shorts.md` (300) + plan.  
**No** long prompts or long metadata in this mode.

**Shared rules:** read `.cursor/commands/veo-session-shared.md` (patches, veo3 format, resume).

## Usage

```
/veo-session-shorts
/veo-session-shorts cinematic
```

## Mode: `shorts`

| Phase | File | Target |
|-------|------|--------|
| 1 | `prompts-shorts.md` | 900 prompts (9:16) |
| 2 | `youtube-metadata-shorts.md` | 300 Shorts |

**Complete when:** both phases done. Then `/clear` → `/veo-session-shorts` for next channel.

## Steps

0. **Guards:** `.\tools\veo_session_guards.ps1 -Channel {ch} -Mode shorts` — if `Ok` is false, **stop**.
1. `.\tools\veo_session_next_channel.ps1 -Mode shorts` (if no channel in message)
2. If guards say `scaffold`: `.\tools\new_session_scaffold.ps1 -Channel {ch} -Mode shorts`
3. Follow `$g.Phase` and `$g.NextBatchStart`–`$g.NextBatchEnd` only
4. Work current `Phase` only — **10 prompts per append**, max **30** per turn
5. Pack header every **30** prompts (`## Pack NN — {channel}-shorts-pack-NN`)
6. Visual: portrait 9:16 + HOOK/RISE/LAND — see `docs/VEO3-PROMPT-SPEC.md`
7. **Variety (mandatory):** each Short = 3 prompts with **3 different places**, **3 different camera moves**, **3 unique Voice lines**. Read last 9 prompts before each batch; **never** clone the previous Short. Full rules: **Shorts variety** section in `VEO3-PROMPT-SPEC.md`.
8. Metadata phase: **`docs/YOUTUBE-METADATA-SPEC.md`** — unique title/description/tags **per Short** (from that Short's 3 prompts).

## End message

```
{cinematic} session-NN [shorts] — prompts 31-60 / 900
Next: /veo-session-shorts cinematic
```

When complete:

```
{cinematic} [shorts] COMPLETE. /clear then /veo-session-shorts for next channel.
```
