# -*- coding: utf-8 -*-
"""Generate portrait Shorts prompts (900 scenes, 30 packs).

Default: legacy channel root file. Session workflow:
  python tools/generate_shorts_prompts_900.py --session-dir channels/cinematic/sessions/session-01 --channel cinematic --pack 4 --append
"""
import argparse
import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "channels" / "cinematic" / "prompts-shorts.md"
LONG_MOD = ROOT / "tools" / "generate_long_prompts_900.py"


def load_longgen():
    spec = importlib.util.spec_from_file_location("longgen", LONG_MOD)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


LG = load_longgen()
pick = LG.pick
THEMES_721 = LG.THEMES_721
CIV = LG.CIV
HEAVEN_HELL = LG.HEAVEN_HELL
ANTH_VISUALS = LG.ANTH_VISUALS

CAMERA_P = [
    "slow vertical tilt up through mist",
    "ascending crane past towering architecture",
    "tight push-in on eyes then drift to hands",
    "low angle rise along a monolith into sky",
    "top-down spiral tightening on a lone figure",
    "slow downward drift like falling through light",
    "narrow corridor tracking with depth haze",
    "portrait framing with foreground particles",
    "gentle handheld float weighted to vertical",
    "extreme vertical slow zoom through layers",
]


def adapt_voice_shorts(text: str) -> str:
    return (
        text.replace("wide frame", "vertical frame")
        .replace("Wide frame", "Vertical frame")
        .replace("endless widescreen myth", "endless vertical myth")
        .replace("the horizon refuses haste", "the frame refuses haste")
    )


def voice_for_index(i: int) -> str:
    return adapt_voice_shorts(LG.voice_for_index(i))


def _short_index(i: int) -> int:
    return (i - 1) // 3


def visual_last_soul_p(i):
    s = _short_index(i)
    phase = (i - 1) % 3
    places = [
        "towering obsidian spire piercing violet nebula mist",
        "vertical shaft of light inside a hollow asteroid cathedral",
        "narrow canyon of bone-white cliffs under twin dying suns",
        "endless stair carved into cliff face dissolving into fog",
        "colossal rib-arch framing a distant spark of soul-light",
        "figure seen from below walking a glass bridge into void",
        "tall black mirror monolith reflecting ember constellations",
        "abyss viewed top-down with a single thread of gold descending",
        "shattered moon corridor with drifting funeral wreaths of light",
        "underwater ruin column rising through teal midnight water",
        "vertical lightning forest of crystallized plasma trees",
        "sandfall curtain inside a geode the size of a city",
        "orbital graveyard of frozen ships circling a pale dwarf star",
        "hanging garden of black roses over a bottomless shaft",
        "cathedral of broken halos spinning slowly in zero gravity",
    ]
    effects = [
        "embers rising upward like inverted snow",
        "vertical god-rays cutting through charcoal haze",
        "bioluminescent motes drifting past lens in tight depth",
        "molten reflections crawling up wet stone walls",
        "cold aurora ribbons snaking down stone ribs",
        "ash snow falling upward through a beam of amber light",
    ]
    return (
        f"Cinematic portrait 9:16 vertical phone frame; epic sci-fi fantasy; "
        f"{pick(places, i, s * 3 + phase)}; {pick(effects, i, s * 3 + phase + 1)}; "
        f"{pick(CAMERA_P, i, s * 3 + phase + 2)}; "
        "dramatic vertical composition; hook-friendly first frame; no on-screen text; "
        "no modern city streets; no comedy."
    )


def visual_beyond_p(i):
    places = [
        "vertical cockpit stack — pilot silhouette against star column",
        "narrow airlock shaft lit cobalt with frost crystals falling",
        "glass tube corridor curving upward into starfield",
        "tall alien spine-structure vanishing into black above",
        "vertical launch gantry rain-soaked under thunderclouds",
        "endless elevator shaft of light toward a pulsing anomaly",
    ]
    return (
        f"Cinematic portrait 9:16; hard sci-fi awe; {pick(places, i - 180)}; "
        f"{pick(['cold documentary clarity', 'star flare streaking vertically', 'dust motes in vertical light beams'], i)}; "
        f"{pick(CAMERA_P, i)}; no HUD text; no cartoon."
    )


def visual_ancient_p(i):
    rel = i - 360
    civ_idx = min(max((rel - 1) // 30, 0), len(CIV) - 1)
    name, feats, lights = CIV[civ_idx]
    return (
        f"Cinematic portrait 9:16 world-building; civilization '{name}'; "
        f"{pick(feats, rel)}; lighting: {pick(lights, rel, 1)}; "
        f"tiny robed figure low in frame for towering scale; {pick(CAMERA_P, rel)}; "
        "awe; vertical temples and spires emphasized; no narration text on screen."
    )


def visual_heaven_p(i):
    rel = i - 540
    _, a, b = HEAVEN_HELL[min(max((rel - 1) // 30, 0), len(HEAVEN_HELL) - 1)]
    return (
        f"Cinematic portrait 9:16 surreal metaphysical; {a}; atmosphere {b}; "
        f"{pick(CAMERA_P, rel)}; uncanny beauty; emotionally heavy; no subtitles."
    )


def visual_anthology_p(i):
    rel = i - 720
    seg = min(max((rel - 1) // 30, 0), len(THEMES_721) - 1)
    mood = pick(ANTH_VISUALS[seg], rel, seg + 3)
    return (
        f"Cinematic portrait 9:16 mood piece — {THEMES_721[seg].lower()}; {mood}; "
        f"vertical composition; symbolic silhouette; {pick(CAMERA_P, rel)}; "
        "poetic surreal realism; subtle grain; no urban mundane; no on-screen text."
    )


def visual_base(i):
    if i <= 180:
        return visual_last_soul_p(i)
    if i <= 360:
        return visual_beyond_p(i)
    if i <= 540:
        return visual_ancient_p(i)
    if i <= 720:
        return visual_heaven_p(i)
    return visual_anthology_p(i)


def triplet_phase(i):
    return (i - 1) % 3


def visual_for_index(i):
    base = visual_base(i)
    phase = triplet_phase(i)
    if phase == 0:
        return (
            f"{base} "
            "Short beat 1/3 HOOK: one scroll-stopping focal subject, high contrast, "
            "face or symbol in upper third, instant read in under one second."
        )
    if phase == 1:
        return (
            f"{base} "
            "Short beat 2/3 RISE: deepen mood — texture, scale, slow drift, emotional tension builds."
        )
    return (
        f"{base} "
        "Short beat 3/3 LAND: small payoff — light on hands, eyes closing, door opening, "
        "quiet catharsis; last frame memorable."
    )


def writing_style_for_scene(n):
    if 181 <= n <= 540:
        return "Documentary"
    return "Dramatic"


def pack_info(p: int, channel: str = "cinematic", session: str = ""):
    start = (p - 1) * 30 + 1
    end = p * 30
    s_first = (p - 1) * 10 + 1
    s_last = p * 10
    if session:
        proj = f"{channel}-{session}-shorts-pack-{p:02d}"
    else:
        proj = f"{channel}-shorts-pack-{p:02d}"
    return p, proj, start, end, s_first, s_last


def build_packs(channel: str = "cinematic", session: str = ""):
    """30 packs × 30 prompts = 900; each pack → 10 Shorts (24s each)."""
    return [pack_info(p, channel, session) for p in range(1, 31)]


def render_pack_lines(p: int, channel: str, session: str) -> list[str]:
    _, proj, start, end, s_first, s_last = pack_info(p, channel, session)
    st = writing_style_for_scene(start)
    lines = [
        "",
        "---",
        "",
        f"## Pack {p:02d} — `{proj}` — Scenes {start}–{end}",
        f"- **Yields Shorts #{s_first:03d}–{s_last:03d}** (ten × ~24 s after trim)",
        f"- **Raw length this pack**: 30 × 8s = **240s** (~4 min)",
        f"- **Writing style on veo3.pk** (this pack): {st}",
        "",
    ]
    for n in range(start, end + 1):
        lines.append(f"Prompt {n}: {visual_for_index(n)}")
        lines.append(f"Voice: {voice_for_index(n)}")
        lines.append("")
    return lines


def legacy_header() -> list[str]:
    lines = [
        "# Prompts — Shorts | Cinematic (@Subscribe Cinematic)",
        "> **Shorts-only workflow** — use [`prompts-long-videos.md`](prompts-long-videos.md) for long landscape films; **this file is only for small vertical Shorts.**",
        ">",
        "> **300 YouTube Shorts** (~**24 s** each): **3 consecutive prompts = 1 Short** (`3 × 8s = 24s`). **900** portrait prompts total.",
        ">",
        "> **30 small veo3.pk packs:** each pack = **30 prompts** = **240 s** (~**4 min**) raw → split into **10 Shorts**.",
        "> Platform: **veo3.pk** | Model: **Google Flow VEO** | Transition: Fade In/Out",
        "> Format: `Prompt N:` portrait visual → next line `Voice:` narration",
        "> **Variety:** each Short (3 prompts) = 3 **different** places, camera moves, and Voice lines.",
        "",
        "Regenerate: `python tools/generate_shorts_prompts_900.py`",
        "",
        "---",
        "",
    ]
    return lines


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--session-dir", type=Path, default=None, help="e.g. channels/cinematic/sessions/session-01")
    ap.add_argument("--channel", type=str, default="cinematic")
    ap.add_argument("--session", type=str, default="", help="session-01 (inferred from --session-dir if omitted)")
    ap.add_argument("--pack", type=int, default=0, help="Single pack 1-30 (session append mode)")
    ap.add_argument("--from-pack", type=int, default=0)
    ap.add_argument("--to-pack", type=int, default=0)
    ap.add_argument("--append", action="store_true")
    ap.add_argument("--out", type=Path, default=None)
    args = ap.parse_args()

    session = args.session
    if args.session_dir:
        session = session or args.session_dir.name
        out = args.out or (args.session_dir / "prompts-shorts.md")
        channel = args.channel
        packs = build_packs(channel, session)
        if args.pack:
            pack_range = [args.pack]
        elif args.from_pack or args.to_pack:
            lo = args.from_pack or 1
            hi = args.to_pack or 30
            pack_range = list(range(lo, hi + 1))
        else:
            pack_range = list(range(1, 31))

        body: list[str] = []
        for p in pack_range:
            body.extend(render_pack_lines(p, channel, session))
        text = "\n".join(body).rstrip() + "\n"
        out.parent.mkdir(parents=True, exist_ok=True)
        if args.append and out.is_file():
            existing = out.read_text(encoding="utf-8").rstrip()
            out.write_text(existing + "\n" + text, encoding="utf-8")
        else:
            out.write_text(text, encoding="utf-8")
        print(f"Wrote pack(s) {pack_range[0]}-{pack_range[-1]} -> {out}")
        return

    lines = legacy_header()
    for p, proj, start, end, s_first, s_last in build_packs():
        st = writing_style_for_scene(start)
        lines.append(f"## Pack {p:02d} — `{proj}` — Scenes {start}–{end}")
        lines.append(f"- **Yields Shorts #{s_first:03d}–{s_last:03d}** (ten × ~24 s after trim)")
        lines.append(f"- **Raw length this pack**: 30 × 8s = **240s** (~4 min) — not a long-form upload; split into Shorts only.")
        lines.append(f"- **Writing style on veo3.pk** (this pack): {st}")
        lines.append("")
        for n in range(start, end + 1):
            lines.append(f"Prompt {n}: {visual_for_index(n)}")
            lines.append(f"Voice: {voice_for_index(n)}")
            lines.append("")
        lines.append("---")
        lines.append("")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
