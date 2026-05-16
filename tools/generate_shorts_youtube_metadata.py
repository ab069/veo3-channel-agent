#!/usr/bin/env python3
"""Emit youtube-metadata-shorts.md — unique title/description/tags per Short."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_PROMPTS = ROOT / "channels" / "cinematic" / "prompts-shorts.md"
DEFAULT_OUT = ROOT / "channels" / "cinematic" / "youtube-metadata-shorts.md"

BLOCK = re.compile(
    r"^Prompt (\d+): (.+)\nVoice:\s*(.+)$",
    re.MULTILINE,
)

BEAT_RE = re.compile(r"Short beat (\d/3) (HOOK|RISE|LAND)")

META_SEGMENTS = {
    "dramatic vertical composition",
    "vertical composition",
    "hook-friendly first frame",
    "no on-screen text",
    "no modern city streets",
    "no comedy",
    "no HUD text",
    "no cartoon",
    "no narration text on screen",
    "emotionally heavy",
    "no subtitles",
    "no urban mundane",
    "vertical temples and spires emphasized",
    "symbolic silhouette",
    "poetic surreal realism",
    "subtle grain",
    "uncanny beauty",
    "tiny robed figure low in frame for towering scale",
}

GENRE_SEGMENTS = {
    "epic sci-fi fantasy",
    "hard sci-fi awe",
    "awe",
    "world-building",
    "surreal metaphysical",
    "mood piece",
}

STOPWORDS = {
    "cinematic", "portrait", "vertical", "phone", "frame", "through", "past",
    "into", "like", "with", "from", "under", "over", "slow", "gentle", "tight",
    "dramatic", "inside", "across", "along", "seen", "viewed", "weight",
}

HASHTAG_POOL = [
    "#Shorts", "#Cinematic", "#AIVideo", "#SciFi", "#VerticalVideo",
    "#SubscribeCinematic", "#AICinema", "#CosmicArt", "#FantasyArt",
    "#Soulful", "#EpicCinematic", "#VeoAI",
]

TAGS_BASE = (
    "youtube shorts, ai cinematic short, vertical cinematic, 9:16, "
    "veo ai video, subscribe cinematic"
)


def norm_seg(s: str) -> str:
    return s.strip().rstrip(".").strip()


def yt_plain(s: str) -> str:
    return (
        s.replace("\u2014", "-")
        .replace("\u2013", "-")
        .replace("\u2026", "...")
        .replace("\u2019", "'")
        .replace("\u2018", "'")
        .replace("\u201c", '"')
        .replace("\u201d", '"')
        .replace("\u2212", "-")
    )


def prompt_parts(prompt_line: str) -> list[str]:
    base = prompt_line.split(" Short beat")[0].strip()
    parts = [p.strip() for p in base.split(";") if p.strip()]
    while parts and norm_seg(parts[-1]) in META_SEGMENTS:
        parts.pop()
    while parts and (
        parts[0].startswith("Cinematic portrait")
        or parts[0].startswith("Cinematic ultra-wide")
    ):
        parts.pop(0)
    while parts and norm_seg(parts[0]) in GENRE_SEGMENTS:
        parts.pop(0)
    return parts


def visual_hook(prompt_line: str, max_len: int = 200) -> str:
    parts = prompt_parts(prompt_line)
    s = "; ".join(parts).strip()
    if len(s) > max_len:
        s = s[: max_len - 1].rsplit(";", 1)[0].strip() + "..."
    return s or "cinematic vertical scene"


def subject_phrase(prompt_line: str, max_words: int = 6) -> str:
    """Short natural phrase from the main visual (not keyword soup)."""
    parts = prompt_parts(prompt_line)
    if not parts:
        return "the void"
    text = max(parts[:3], key=len, default=parts[0])
    for cut in (" under ", " inside ", " seen from ", " viewed "):
        if cut in text.lower():
            text = text.split(cut, 1)[0]
    words = re.findall(r"[a-zA-Z'-]+", text)
    words = [w for w in words if w.lower() not in STOPWORDS][:max_words]
    if len(words) >= 3:
        phrase = " ".join(words)
        return phrase[0].upper() + phrase[1:] if phrase else "the void"
    return text[:48].strip().rstrip(",;")


def extract_keywords(*prompt_lines: str, limit: int = 6) -> list[str]:
    seen: set[str] = set()
    out: list[str] = []
    for line in prompt_lines:
        for part in prompt_parts(line):
            for w in re.findall(r"[a-z]{4,}", part.lower()):
                if w in STOPWORDS or w in seen:
                    continue
                seen.add(w)
                out.append(w.replace("bioluminescent", "bioluminescent glow") if w == "bioluminescent" else w)
                if len(out) >= limit:
                    return out
    return out


def extract_beat(prompt_line: str) -> str:
    m = BEAT_RE.search(prompt_line)
    return f"{m.group(1)} {m.group(2)}" if m else "beat"


def trim_title(s: str, max_len: int = 100) -> str:
    s = yt_plain(s.strip())
    if len(s) <= max_len:
        return s
    return s[: max_len - 3].rsplit(" ", 1)[0] + "..."


def first_sentence(voice: str) -> str:
    v = yt_plain(voice.strip())
    for sep in (". ", "? ", "! "):
        if sep in v:
            return v.split(sep, 1)[0] + sep.strip()
    return v


def make_title(
    n: int,
    pa: str,
    pb: str,
    pc: str,
    va: str,
    vb: str,
    vc: str,
    used: set[str],
) -> str:
    sa, sb, sc = subject_phrase(pa), subject_phrase(pb), subject_phrase(pc)
    va_s, vb_s, vc_s = first_sentence(va), first_sentence(vb), first_sentence(vc)

    candidates = [
        f"{sa} — {vc_s.rstrip('.')}? | #{n:03d}",
        f"What hides in {sb}? | AI Cinematic Shorts",
        f"POV: {sc} | Cinematic",
        f"{va_s.rstrip('.')} | Vertical AI Film",
        f"24s: {sa} → {sb} → {sc}",
        f"The {sb} | Soulful AI Cinema #{n:03d}",
        f"When {sc} meets the void | Cinematic Shorts",
        f"{visual_hook(pa, 55)} | Cinematic",
        f"{vb_s.rstrip('.')} | #Shorts",
        f"From {sa} to {sc} | Cinematic #{n:03d}",
    ]
    for i, base in enumerate(candidates):
        t = trim_title(base if (n + i) % 3 != 2 else base.replace(" | Cinematic", ""))
        key = t.lower()[:60]
        if key not in used:
            used.add(key)
            return t
    t = trim_title(f"{sa} at the edge of light | #{n:03d}")
    used.add(t.lower()[:60])
    return t


def make_description(
    n: int,
    pa: str,
    pb: str,
    pc: str,
    va: str,
    vb: str,
    vc: str,
) -> str:
    sa, sb, sc = subject_phrase(pa), subject_phrase(pb), subject_phrase(pc)
    ha, hb, hc = visual_hook(pa, 120), visual_hook(pb, 120), visual_hook(pc, 120)
    va, vb, vc = yt_plain(va), yt_plain(vb), yt_plain(vc)

    style = n % 5
    if style == 0:
        body = (
            f"A 24-second vertical journey: {ha}. Then {hb.lower()}. "
            f"It lands on {hc.lower()}.\n\n"
            f'"{first_sentence(vc).strip()}"\n\n'
            "AI cinematic Short — Google Flow VEO. Subscribe @SubscribeCinematic."
        )
    elif style == 1:
        body = (
            f"Can you feel the scale of {sb}?\n\n"
            f"{va}\n\n"
            f"Watch the rise through {sc} — portrait 9:16 sci-fi fantasy.\n\n"
            "Subscribe: @SubscribeCinematic"
        )
    elif style == 2:
        body = (
            "In 24 seconds you will see:\n"
            f"• HOOK — {ha}\n"
            f"• RISE — {hb}\n"
            f"• LAND — {hc}\n\n"
            f"{vb}\n\n"
            "#Shorts #Cinematic #AIVideo"
        )
    elif style == 3:
        body = (
            f"It begins with {sa}. The frame tightens toward {sb}. "
            f"Something settles at {sc}.\n\n"
            f"{vb} {vc}\n\n"
            "Portrait AI cinema | @SubscribeCinematic"
        )
    else:
        body = (
            f"{va}\n\n"
            f"Visual arc: {sa} / {sb} / {sc}.\n\n"
            "Epic mood. No dialogue on screen — voice and image only.\n"
            "Subscribe for more Cinematic Souls-style AI films."
        )

    tags_line = " ".join(HASHTAG_POOL[n % len(HASHTAG_POOL) : n % len(HASHTAG_POOL) + 5])
    if len(tags_line.split()) < 4:
        tags_line = " ".join(HASHTAG_POOL[:6])
    return body + "\n\n" + tags_line


def make_tags(n: int, pa: str, pb: str, pc: str) -> str:
    kw = extract_keywords(pa, pb, pc, limit=6)
    unique = ", ".join(kw)
    serial = f"cinematic short {n:03d}"
    return f"{TAGS_BASE}, {unique}, {serial}"


def load_prompt_voice(path: Path) -> dict[int, tuple[str, str]]:
    text = path.read_text(encoding="utf-8")
    return {int(m.group(1)): (m.group(2).strip(), m.group(3).strip()) for m in BLOCK.finditer(text)}


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--prompts", type=Path, default=DEFAULT_PROMPTS)
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT)
    ap.add_argument("--max-scenes", type=int, default=0)
    args = ap.parse_args()

    pv = load_prompt_voice(args.prompts)
    max_prompt = max(pv.keys()) if pv else 0
    max_shorts = max_prompt // 3
    if args.max_scenes and args.max_scenes > 0:
        max_shorts = min(max_shorts, args.max_scenes // 3)

    lines: list[str] = [
        "# Cinematic Shorts - metadata for YouTube Studio",
        "",
        "Channel: Cinematic (@SubscribeCinematic)",
        "",
        "Per-Short unique titles/tags — see docs/YOUTUBE-METADATA-SPEC.md",
        "",
        "How to use: upload short-NNN.mp4, paste Title, Description, Tags.",
        "",
        "---",
        "",
    ]

    used_titles: set[str] = set()

    for n in range(1, max_shorts + 1):
        a, b, c = 3 * n - 2, 3 * n - 1, 3 * n
        pa, va = pv.get(a, ("", ""))
        pb, vb = pv.get(b, ("", ""))
        pc, vc = pv.get(c, ("", ""))

        title = make_title(n, pa, pb, pc, va, vb, vc, used_titles)
        desc = make_description(n, pa, pb, pc, va, vb, vc)
        tags = make_tags(n, pa, pb, pc)

        lines.append(f"## Short #{n:03d} - short-{n:03d}.mp4 - prompts {a}-{c}")
        lines.append("")
        lines.append("Title:")
        lines.append(title)
        lines.append("")
        lines.append("Description:")
        lines.append(desc)
        lines.append("")
        lines.append("Tags:")
        lines.append(tags)
        lines.append("")
        lines.append("---")
        lines.append("")

    lines.append("<!-- Regenerate: python tools/generate_shorts_youtube_metadata.py -->")
    lines.append("")

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")
    print(f"Wrote {max_shorts} unique Short blocks -> {args.out}")


if __name__ == "__main__":
    main()
