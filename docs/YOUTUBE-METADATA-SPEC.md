# YouTube Shorts metadata spec (per-Short, not copy-paste)

Each Short must feel **written for that video**, not stamped from one template.

## What went wrong (old generator)

| Field | Old behavior | Why it feels "all the same" |
|-------|----------------|------------------------------|
| Title | First voice line + `... \| Cinematic Short #NNN` | Same ~6 voice lines repeat across 900 scenes |
| Description | Always 3 voice lines + same footer/hashtags | No variety; reads like a script dump |
| Tags | One fixed list + `cinematic short 001` | No topic tags from what's on screen |

## What each Short needs

### Title (unique, <= 100 chars)

Rotate **formulas** — use **this Short's visuals**, not only voice line 1:

- Visual hook: `The obsidian spire pierces the violet mist | Cinematic Shorts`
- Question: `What waits inside the hollow asteroid cathedral?`
- POV: `POV: you find a thread of gold in the abyss`
- Line + mood: `Silence learns your name at the rim of everything`
- Number only when needed: `| #047` at end — not the main hook

**Never** duplicate the same title for two Shorts in a row. If voices repeat, **title from imagery**.

### Description (unique structure per Short)

Pick **one** style per Short (rotate across the catalog):

1. **Cinematic blurb** (2–3 sentences): describe the 24s journey using **specific places** from the 3 scenes — weave **one** voice line, not all three pasted.
2. **Hook + quote**: one question, then the strongest single `Voice:` line from the triplet.
3. **Visual-only beats**: three short bullets (what the viewer sees), then subscribe line.
4. **Micro-story**: beginning → tension → landing in prose (no bullet dump of all voices).

Always end with channel CTA — but **vary** hashtag sets (pick 4–6 from channel list, not identical block every time).

Optional compact block:

```text
On screen: [HOOK scene noun phrase] → [RISE] → [LAND]
```

### Tags (mix fixed + unique)

- **6–8 channel base tags** (same channel-wide)
- **4–6 tags from this Short only**: nouns from prompts (e.g. `obsidian spire`, `void abyss`, `bioluminescent`, `soul light`)
- **1** serial tag optional: `cinematic short 047`

Do not use the same 12 tags for every Short.

## Source of truth

| Data | From |
|------|------|
| Visual uniqueness | `prompts-shorts.md` prompts 1–3 of that Short |
| Voice (sparingly) | `Voice:` lines for that triplet |
| Tone | `channels/{channel}/info.md` |

**Upstream:** if prompts repeat the same places/voices, metadata will still feel same-y. Fix prompts first — `docs/VEO3-PROMPT-SPEC.md` → **Shorts variety**.

## Regenerate

```powershell
python tools/generate_shorts_youtube_metadata.py --prompts channels/cinematic/prompts-shorts.md --out channels/cinematic/youtube-metadata-shorts.md
```

`/veo-session-shorts` metadata phase must follow this doc (not the old template).
