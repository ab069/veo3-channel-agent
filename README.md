# Veo3 Channel Agent

AI video channel content generator for [veo3.pk](https://veo3.pk) (Google Flow VEO).

## What It Does

Give it a channel name and details — it creates a complete content package:

| File | Contents |
|------|----------|
| `info.md` | Channel strategy, visual style, voice guide |
| `plan.md` | Scene distribution, veo3.pk batch plan, FFmpeg merge plan |
| `prompts-long-videos.md` | 720 prompts for long videos (Landscape 16:9) |
| `prompts-shorts.md` | 180 prompts for Shorts (Portrait 9:16) |
| `titles.md` | YouTube titles, descriptions, tags for every video |

**Total output per channel: 900 prompts = ~2 hours of AI video**

## Slash Commands

| Command | What it does |
|---------|-------------|
| `/veo-channel <name> [details]` | Create a new channel or load an existing one |
| `/veo-merge <name>` | Generate FFmpeg commands to merge downloaded clips |

## Usage

```
/veo-channel cinematic niche:dark-cinematic tone:dramatic audience:18-35
```

Then:
1. Paste prompts into veo3.pk → Create New Project → Prompts mode
2. Download the generated video
3. Run `/veo-merge cinematic` to get FFmpeg commands for merging Shorts

## Prompt Format (veo3.pk compatible)

```
Prompt 1: [Cinematic visual description for Google Flow VEO]
Voice: [Narrator script, ~20-25 words, for this 8-second scene]

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
      info.md
      plan.md
      prompts-long-videos.md       ← 720 prompts
      prompts-shorts.md            ← 180 prompts
      titles.md
      videos/                      ← gitignored, drop downloads here
      output/                      ← gitignored, merged finals go here
```
