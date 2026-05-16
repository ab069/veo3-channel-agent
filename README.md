# Veo3 Channel Agent

AI video channel content generator for [veo3.pk](https://veo3.pk) (Google Flow VEO).

## What It Does

Give it a channel name and details — it creates a complete content package:

| File | Contents |
|------|----------|
| `info.md` | Channel strategy, visual style, voice guide |
| `plan.md` | Scene distribution, veo3.pk batch plan, FFmpeg merge plan |
| `prompts-long-videos.md` | **900** prompts in **one file** → **5×~24 min** long videos (`180×8s` each) **or** **300×~24 s** Shorts (`3×8s` each), same scene order |
| `prompts-shorts.md` | **900** portrait prompts → **300** Shorts only — **30** small veo3 packs (30 prompts ≈ **4 min** raw → **10** Shorts each); `tools/generate_shorts_prompts_900.py` |
| `titles.md` | YouTube titles, descriptions, tags for every video |

**`prompts-long-videos.md`** (**16:9**): **five** ~24 min landscape films (**180** prompts each). **`prompts-shorts.md`** (**9:16**): **Shorts-only** — **30** packs × **30** prompts (~**4 min** raw per pack) → **10** Shorts each = **300** total. Same `Prompt 1`…`900` order across both files.

## Slash Commands

| Command | What it does |
|---------|-------------|
| `/veo-channel <name> [details]` | Create a new channel or load an existing one |
| `/veo-session-shorts [name]` | **900** portrait prompts + Shorts metadata only |
| `/veo-session-long [name]` | **900** landscape prompts + long metadata only |
| `/veo-session-both [name]` | Full package (shorts + long + all metadata) |
| `/veo-session [name]` | Router → defaults to **both** |
| `/clear` | After one channel is done — new chat, then run same session command again |

See **`docs/VEO-SESSION-ARCHITECTURE.md`**. Preflight: `.\tools\veo_session_guards.ps1 -Channel NAME -Mode shorts|long|both`

### Stitch (FFmpeg, per-scene downloads)

| Command | Output |
|---------|--------|
| `/veo-stitch-shorts <channel> <ScenesDir>` | 300 Shorts (`short-001.mp4`, 3 scenes each) |
| `/veo-stitch-long <channel> <ScenesDir>` | 5 long videos (180 scenes each) |
| `/veo-stitch-both <channel> <ScenesDir>` | Both |
| `/veo-stitch` | Router |

See **`docs/VEO-STITCH-ARCHITECTURE.md`**. Preflight: `.\tools\veo_stitch_guards.ps1`. Run: `.\tools\veo_stitch.ps1 -SkipMissingScenes` (skips missing/corrupt scenes by default).
| `/veo-merge <name>` | Generate FFmpeg commands to merge downloaded clips |

## Usage

```
/veo-channel cinematic niche:dark-cinematic tone:dramatic audience:18-35
```

Then:
1. **Long videos:** five veo3 projects from `prompts-long-videos.md` (**16:9**, **180** prompts each).
2. **Shorts only:** thirty veo3 projects from `prompts-shorts.md` (**9:16**, **30** prompts each ≈ **4 min** raw) → trim each file into **10** × ~**24 s** Shorts (**300** total). Run `/veo-merge cinematic` for FFmpeg trim lists if needed.

## Prompt Format (veo3.pk compatible)

See **`docs/VEO3-PROMPT-SPEC.md`** for full rules (pack headers, 9:16 vs 16:9, HOOK/RISE/LAND).

```
Prompt 1: [One-line visual for Google Flow VEO — 8 second scene]
Voice: [Narrator script, ~20-28 words]

Prompt 2: ...
```

## Channels

| Channel | Status |
|---------|--------|
| [cinematic](channels/cinematic/) | Active — 900 scenes planned |

## Folder Structure

```
veo3/
  CLAUDE.md                        ← project rules (batch writing, no delays)
  .claude/commands/
    veo-channel.md                 ← /veo-channel skill
    veo-merge.md                   ← /veo-merge skill
  channels/
    {channel-name}/
      info.md                      ← channel context (always here)
      sessions/
        session-01/                ← one veo3 production run (/veo-session)
          session.md, plan.md
          prompts-shorts.md
          youtube-metadata-shorts.md
          videos/, output/
      prompts-long-videos.md       ← optional full library
      prompts-shorts.md
      titles.md
      videos/
      output/
  docs/SESSIONS-PLAN.md            ← sessions workflow
  tools/new_session_scaffold.ps1     ← next session-NN folders
```
