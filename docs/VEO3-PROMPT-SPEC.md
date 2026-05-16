# veo3.pk prompt spec (Google Flow VEO)

Reference for `/veo-session`, `/veo-channel`, and all `prompts-*.md` files.  
**Read `channels/{name}/info.md` first** — tone, pillars, and style come from the channel.

---

## How veo3.pk works

| Rule | Value |
|------|--------|
| Platform | [veo3.pk](https://veo3.pk) |
| Model | **Google Flow VEO** |
| Project mode | **Prompts** (paste prompt list) |
| Visual type | **Video Clips** |
| **1 prompt** | **1 scene** | **8 seconds** |
| Transition (recommended) | **Fade In/Out** |
| Output per project | One merged video (all pasted prompts play in order) |

You paste `Prompt 1:` through `Prompt N:` into one veo3 project. veo3 generates each scene as an 8s clip and merges them in order.

---

## File-level format (required)

### Every prompt block (exactly this shape)

```text
Prompt 1: [single-line visual description for VEO]
Voice: [single-line narrator script for this 8 seconds]

Prompt 2: [visual...]
Voice: [voice...]
```

**Rules:**

- Label must be `Prompt N:` where `N` is a plain integer (1, 2, 3 … 900).
- **Next line** must start with `Voice:` (capital V, colon, space).
- **Blank line** between each prompt pair (matches veo3.pk paste and our generators).
- **One line** per `Prompt` and per `Voice` — no line breaks inside a prompt.
- Do **not** put narration inside the visual line. Do **not** use `Scene 1:` or markdown bullets for prompts.

### File header (top of each prompts file)

Include platform math so humans and agents know how to batch veo3 projects:

**Shorts file (`prompts-shorts.md`):**

```markdown
# Prompts — Shorts | {Channel Name}

> **900** portrait prompts · **8 sec/scene** · **3 prompts = 1 Short** (24s)
> **30 veo3 packs** × **30 prompts** (~4 min raw) → **10 Shorts** per pack
> Platform: **veo3.pk** | Model: **Google Flow VEO** | Transition: Fade In/Out
> Format: `Prompt N:` visual → next line `Voice:` narration
```

**Long file (`prompts-long-videos.md`):**

```markdown
# Prompts — Long Videos | {Channel Name}

> **900** landscape prompts · **8 sec/scene**
> **5 veo3 projects** × **180 prompts** (~24 min each)
> Orientation: **Landscape 16:9** | Platform: **veo3.pk** | Model: **Google Flow VEO**
> Format: `Prompt N:` visual → next line `Voice:` (~20–28 words)
```

### Section headers inside the file

**Shorts — every 30 prompts (one veo3 pack):**

```markdown
---

## Pack 01 — `{channel}-shorts-pack-01` — Scenes 1–30
- **Yields Shorts #001–010** (ten × ~24 s after trim)
- **Raw length this pack**: 30 × 8s = **240s** (~4 min)
- **Writing style on veo3.pk** (this pack): Dramatic
```

**Long — every 180 prompts (one long film):**

```markdown
---

## Batch — {channel}-long-01 — Scenes 1–180
- **Title arc**: {Story title from plan.md}
- **Writing style on veo3.pk**: Dramatic
```

Scene numbers in headers are **global** within that file (Pack 02 = scenes 31–60, etc.).

---

## Visual line anatomy (semicolon-separated)

Build the `Prompt N:` line from **left to right** in segments separated by `; `:

| Segment | Shorts (9:16) | Long (16:9) |
|---------|-----------------|-------------|
| 1. Frame + genre | `Cinematic portrait 9:16 vertical phone frame; epic sci-fi fantasy;` | `Cinematic ultra-wide 16:9 film frame; epic atmospheric sci-fi fantasy;` |
| 2. Subject / place | Specific environment, subject, scale | Same — wider compositions |
| 3. Light / atmosphere | Fog, god-rays, bioluminescence, reflections | Same |
| 4. Camera motion | `slow vertical tilt`, `ascending crane`, `tight push-in`… | `slow push-in`, `sweeping aerial pan`, `over-the-shoulder slow walk`… |
| 5. Style tail | `dramatic vertical composition; hook-friendly first frame; no on-screen text; no modern city streets; no comedy.` | `dramatic lighting; soulful mood; no text overlays; no modern cities; no comedy.` |
| 6. Short beat (Shorts only) | `Short beat 1/3 HOOK: …` / `2/3 RISE` / `3/3 LAND` | *(omit)* |

**Camera:** Always include motion — VEO needs movement (never “static wide shot” only).

**Negatives:** Always include channel-appropriate bans (no on-screen text, no HUD, no comedy, etc.) from `info.md`.

**Shorts HOOK / RISE / LAND:** Every group of 3 prompts = 1 YouTube Short:

| Position in trio | Beat | Job |
|------------------|------|-----|
| 1, 4, 7 … | `1/3 HOOK` | Scroll-stopper in first second |
| 2, 5, 8 … | `2/3 RISE` | Scale, tension, drift |
| 3, 6, 9 … | `3/3 LAND` | Quiet payoff, memorable last frame |

---

## Shorts variety — do NOT clone the same Short (CRITICAL)

**Problem to avoid:** recycling the same 8 locations and 4 voice lines so every Short feels identical (bad for VEO, YouTube, and metadata).

### One Short = one triplet (prompts N, N+1, N+2)

Each Short must be **visually and verbally distinct** from the Short before it.

| Rule | Requirement |
|------|----------------|
| **3 places** | HOOK, RISE, LAND each use a **different** subject/location (not the same cathedral / spire / canyon twice in one Short) |
| **3 cameras** | Three **different** camera motions (e.g. tilt, crane, push-in — not the same move 3×) |
| **3 voices** | Three **new** `Voice:` lines — **never** duplicate a voice line inside the same Short |
| **vs previous Short** | Do not copy the previous triplet’s place combo or the same HOOK subject as Short #(k−1) |
| **vs whole file** | No **identical** `Prompt N:` line anywhere in the file |
| **Voice reuse** | Same `Voice:` text max **once per 30-pack**; prefer **once per 90 prompts** |

### Before writing each batch of 10 prompts

1. Read the **last 9 prompts** already in the file (previous Short + current partial).
2. Note subjects, camera moves, and voice lines already used in this pack.
3. Pick **new** environments and lines for the next Short(s).

### Triplet checklist (verify every Short before appending)

```text
Short #K (prompts X, X+1, X+2):
  [ ] HOOK — place A, motion 1, voice line unique
  [ ] RISE  — place B (not A), motion 2, voice line unique
  [ ] LAND  — place C (not A or B), motion 3, voice line unique
  [ ] Not the same trio pattern as Short #(K-1)
```

### Expand the palette (channel-appropriate)

Rotate through **many** environments per pack — e.g. void abyss, glass bridge, rib-arch, obsidian spire, frost airlock, drowned cathedral, ember rain, crystal forest, rust orbit-ring, sleeping giant’s eye, ink ocean, etc. Pull pillars from `info.md` and `plan.md` so packs 1–30 don’t all feel like “the same dying galaxy.”

### Link to metadata

Unique prompts → unique `youtube-metadata-shorts.md` entries. See `docs/YOUTUBE-METADATA-SPEC.md`.

---

## Voice line rules

| Rule | Detail |
|------|--------|
| Length | **~20–28 words** (fits ~8 seconds at slightly slow epic pace) |
| Content | What the **narrator says** during this clip only |
| Tone | From channel `info.md` (poetic, epic, no “hey guys”) |
| Continuity | Lines may share **mood** across a pack; **do not** repeat the same sentence — see Shorts variety above |
| Format | Single line after `Voice:` — no quotes required |

**veo3.pk voice settings (typical for Cinematic):** deep male EN, speaking rate **-10% to -20%**, matches Writing Style on project.

---

## veo3.pk project settings (per paste batch)

When user creates a project on veo3.pk, match the file section:

| Setting | Long batches | Shorts packs |
|---------|--------------|--------------|
| Mode | Prompts | Prompts |
| Model | Google Flow VEO | Google Flow VEO |
| Visual type | Video Clips | Video Clips |
| Orientation | **Landscape 16:9** | **Portrait 9:16** |
| Writing style | Dramatic / Documentary (per batch in plan) | Dramatic / Documentary |
| Transition | Fade In/Out | Fade In/Out |

**Paste only the prompts for that project** (e.g. Prompt 1–180 for long-01, or Prompt 1–30 for shorts-pack-01 within that file’s numbering).

---

## Math cheat sheet

| Goal | Formula |
|------|---------|
| Raw duration | `scenes × 8` seconds |
| One long film | **180** scenes → **1440s** (~24 min) |
| Full long library | **900** scenes → 5 × 180 |
| One Short | **3** scenes → **24s** |
| All Shorts | **900** scenes → **300** Shorts |
| One Shorts veo3 pack | **30** scenes → **240s** raw → trim to **10** Shorts |

---

## Example (copy-paste ready)

**Shorts:**

```text
Prompt 1: Cinematic portrait 9:16 vertical phone frame; epic sci-fi fantasy; vertical shaft of light inside a hollow asteroid cathedral; bioluminescent motes drifting past lens in tight depth; portrait framing with foreground particles; dramatic vertical composition; hook-friendly first frame; no on-screen text; no modern city streets; no comedy. Short beat 1/3 HOOK: one scroll-stopping focal subject, high contrast, face or symbol in upper third, instant read in under one second.
Voice: I crossed the ash of galaxies to hear a heartbeat again. Stars bleed into charcoal mist.
```

**Long:**

```text
Prompt 1: Cinematic ultra-wide 16:9 film frame; epic atmospheric sci-fi fantasy; bridge of frozen lightning spanning dead nebulae; thin fog glowing with buried starlight; descending spiral reveal; dramatic lighting; soulful mood; no text overlays; no modern cities; no comedy.
Voice: I crossed the ash of galaxies to hear a heartbeat again. Stars bleed into charcoal mist.
```

---

## Common mistakes (do not)

- Dumping 900 prompts in one agent Write call (use **10** per `Add-Content` batch).
- `Scene 1` instead of `Prompt 1:`.
- Voice on the same line as the visual.
- Missing orientation in the visual line (9:16 vs 16:9).
- Forgetting `Short beat` on portrait Shorts prompts.
- Landscape wording in shorts file (or portrait wording in long file).
- On-screen dialogue/text in the visual prompt when channel bans it.
- **Same Short twice** — duplicate places, camera moves, or voice lines in one triplet.
- **Recycling** the same HOOK location every 2–3 Shorts (e.g. asteroid cathedral on 1, 9, 17…).

---

## Where this lives in a session

```
channels/{channel}/sessions/session-01/
  prompts-shorts.md          ← follow this spec, portrait
  prompts-long-videos.md     ← follow this spec, landscape
  plan.md                    ← which prompts go to which veo3 project name
```

Channel voice/style: `channels/{channel}/info.md`  
Full examples: `channels/cinematic/prompts-shorts.md`, `prompts-long-videos.md`
