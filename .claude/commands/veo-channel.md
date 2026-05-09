# /veo-channel — Channel Content Generator for veo3.pk

Generate a complete 900-scene content package for a YouTube/Shorts channel powered by veo3.pk (Google Flow VEO).

## Usage
```
/veo-channel <channel-name> [key:value pairs]
```

**Examples:**
```
/veo-channel dark-facts niche:mystery tone:dramatic audience:18-35 language:english style:documentary
/veo-channel motivational-daily niche:self-help tone:inspiring audience:teens-adults style:storytelling
/veo-channel science-explained niche:science tone:educational audience:students style:educational
```

---

## Step 1 — Parse Input

Extract from the arguments:
- `channel-name`: First argument (use as folder name, lowercase-hyphenated)
- `niche`: Content niche/topic
- `tone`: Writing style matching veo3.pk options (professional, casual, educational, entertaining, dramatic, documentary, storytelling)
- `audience`: Target audience description
- `language`: Language for voice scripts (default: English)
- `style`: Any extra style notes

If details are missing, infer them from the channel name.

---

## Step 2 — Check Existing Channel

Check if `D:\veo3\channels\{channel-name}\` already exists.

- **If YES**: Read `info.md` from that folder. Greet the user, show channel summary, and ask what they need (add more prompts, regenerate a section, create titles for a new batch, etc.). Do NOT overwrite existing files unless asked.
- **If NO**: Proceed to Step 3.

---

## Step 3 — Create Folder Structure

Create these folders and files:
```
D:\veo3\channels\{channel-name}\
  info.md
  prompts.md
  plan.md
  titles.md
  videos\        ← empty folder, user downloads clips here
```

---

## Step 4 — Generate `info.md`

Write a channel strategy document. Include:

```markdown
# Channel: {Channel Name}

## Overview
- **Niche**: ...
- **Tone**: ...
- **Target Audience**: ...
- **Language**: ...
- **Platform**: YouTube (long-form) + Shorts
- **Total Scenes**: 900 (each 8 seconds via Google Flow VEO on veo3.pk)
- **Total Raw Footage**: ~2 hours

## Content Pillars
List 5-7 recurring content themes/topics this channel will cover.
Each pillar should have a name, description, and approximate scene count.

## Visual Style Guide
- Color palette / mood
- Shot types preferred (cinematic, close-up, aerial, etc.)
- Recurring visual motifs
- What to avoid

## Voice & Narration Style
- Tone of narration
- Sentence length (short punchy vs longer explanatory)
- Recommended voice on veo3.pk (gender, accent suggestion)
- Speaking rate recommendation (-50% to +50%)

## Content Distribution
Show how 900 scenes are split across videos (derive from Step 5 plan).

## veo3.pk Settings Recommendation
- Visual Type: Video Clips
- Model: Google Flow VEO
- Orientation: [Landscape for long videos / Portrait for Shorts]
- Writing Style: [matching tone]
- Clip Merge Style: [recommended transition]
```

---

## Step 5 — Generate `plan.md`

Design the full content plan for 900 scenes. Think about the channel niche and decide the best split between long videos and shorts.

**General framework** (adjust per channel):
- Long videos: groups of 180-220 scenes → ~24-29 min videos, Landscape 16:9
- Medium videos: groups of 80-100 scenes → ~10-13 min, Landscape 16:9
- Shorts: groups of 2-4 scenes → 16-32 sec, Portrait 9:16

Write the plan in this format:

```markdown
# Content Plan — {Channel Name}

## Summary
- Total scenes: 900
- Long videos: X (scenes Y each)
- Shorts: X (scenes 2-4 each)
- Total videos: X

---

## Long Videos

### Video 1: {Compelling Title}
- **Scenes**: 1–180
- **Topic**: ...
- **Orientation**: Landscape (16:9)
- **veo3.pk Writing Style**: ...
- **Estimated Duration**: ~24 min
- **Publish Strategy**: ...

### Video 2: {Title}
- **Scenes**: 181–360
...

## Shorts

### Short 1: {Hook Title}
- **Scenes**: [specific scene numbers, e.g. 5–7]
- **Topic**: ...
- **Orientation**: Portrait (9:16)
- **Estimated Duration**: ~24 sec

### Short 2: ...
[Continue for all shorts]

---

## veo3.pk Project Batches

Since veo3.pk generates one video per project, list how to batch the 900 scenes:

| Batch | Project Name | Scenes | Orientation | Use For |
|-------|-------------|--------|-------------|---------|
| 1 | {channel}-long-01 | 1–180 | Landscape | Long Video 1 |
| 2 | {channel}-long-02 | 181–360 | Landscape | Long Video 2 |
...

## FFmpeg Merge Plan

List which downloaded video files to merge for final output:
- Final Video 1: batch-01.mp4 (no merge needed, full video)
- Short 1: extract scenes 5-7 from batch-01.mp4 → ffmpeg trim timestamps
```

---

## Step 6 — Generate Prompt Files (BATCH WRITE — DO NOT WRITE ALL AT ONCE)

**CRITICAL RULE**: Never write all prompts in one Write call. Always write 30 prompts at a time using PowerShell append. This keeps output fast and visible.

**Two files to create:**
- `prompts-long-videos.md` — 720 prompts (Batches 1–4, long videos)
- `prompts-shorts.md` — 180 prompts (Batches 5–10, shorts)

**Batch write loop:**
1. Generate 30 prompts
2. Immediately append to file using PowerShell `Add-Content`
3. Tell user: "Written prompts X–Y, continuing..."
4. Repeat until all prompts done

**Format — strictly follow this:**
```
Prompt 1: [Visual description for Google Flow VEO — cinematic, specific, vivid. Describe camera angle, subject, lighting, motion, mood. 1-3 sentences.]
Voice: [Narration script for this 8-second scene. ~20-25 words. Should match the visual and move the story/content forward.]

Prompt 2: [Visual description...]
Voice: [Narration...]

...
```

**Rules for visual prompts:**
- Always start with a camera/shot type (e.g., "Close-up of...", "Aerial view of...", "Slow motion shot of...")
- Include lighting details (golden hour, neon lights, dramatic shadows, etc.)
- Include motion (camera slowly pans, subject walks toward camera, etc.)
- Match the channel's visual style from info.md
- Keep visual continuity within each content pillar group

**Rules for voice scripts:**
- Each voice script = exactly what the narrator says during that 8-second clip
- ~20-25 words per scene (fits in 8 seconds at normal pace)
- No filler words, every word earns its place
- Build across scenes — each voice line should connect to the next within a video group
- Match channel tone (dramatic, educational, inspiring, etc.)

**Scene grouping in the file:**
Organize with clear headers so the user knows which batch each prompt belongs to:

```markdown
# Prompts — {Channel Name}

> Platform: veo3.pk | Model: Google Flow VEO | 8 sec/scene | 900 scenes total

---

## Batch 1 — {Video Title} (Scenes 1–180)
> Orientation: Landscape | veo3.pk Project: {channel}-long-01

Prompt 1: ...
Voice: ...

Prompt 2: ...
Voice: ...

[continue to 180]

---

## Batch 2 — {Video Title} (Scenes 181–360)
...
```

**Generation approach for 900 prompts:**
- Generate all 900 in one output if possible
- If the file would be too long, write it in 3 passes of 300 prompts each and tell the user to run `/veo-channel-continue` for the next batch
- Never stop mid-batch — always complete a full batch before pausing

---

## Step 7 — Generate `titles.md`

One entry per final video (long videos + shorts):

```markdown
# Titles, Descriptions & Tags — {Channel Name}

---

## Long Videos

### Video 1
**Title**: {YouTube-optimized title, under 70 chars, curiosity-driven}
**Description**:
{150-200 word description. First 2 sentences must hook — they show before "show more". Include keywords naturally. End with a call to action (subscribe/like).}
**Tags**: tag1, tag2, tag3, tag4, tag5, tag6, tag7, tag8, tag9, tag10, tag11, tag12, tag13, tag14, tag15

---

### Video 2
...

## Shorts

### Short 1
**Title**: {Under 50 chars, punchy hook}
**Description**: {50-80 words. Hashtags at end.}
**Tags**: tag1, tag2, tag3, hashtag1, hashtag2

---
```

---

## Completion Message

After generating all files, show:
```
Channel "{channel-name}" created successfully.

  D:\veo3\channels\{channel-name}\
    info.md     — channel strategy
    prompts.md  — 900 prompts (900 scenes × 8s = 2h raw footage)
    plan.md     — X long videos + X shorts
    titles.md   — titles, descriptions, tags
    videos\     — drop downloaded clips here

Next steps:
  1. Open veo3.pk → Create New Project
  2. Use "Prompts" mode, paste from prompts.md batch by batch
  3. Set orientation per batch (see plan.md)
  4. Download each video to channels/{channel-name}/videos/
  5. Run /veo-merge {channel-name} to merge and finalize
```
