# -*- coding: utf-8 -*-
"""Generate channels/cinematic/prompts-long-videos.md — 900 landscape prompts."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "channels" / "cinematic" / "prompts-long-videos.md"


def pick(lst, i, salt=0):
    return lst[(i * 17 + salt) % len(lst)]


CAMERA = [
    "slow push-in",
    "gentle crane rise",
    "orbital drift around subject",
    "sweeping aerial pan",
    "over-the-shoulder slow walk",
    "low-angle slow dolly",
    "slow lateral tracking shot",
    "descending spiral reveal",
    "handheld-weighted glide",
    "extreme slow zoom",
]


def voice_join(parts):
    text = " ".join(p.strip() for p in parts if p).strip()
    if text.endswith("."):
        return text
    return text + "."


def last_soul_voice(i):
    if i <= 8:
        return voice_join([
            pick(
                [
                    "They told me every ending leaves an echo.",
                    "At the rim of everything, silence learns your name.",
                    "I crossed the ash of galaxies to hear a heartbeat again.",
                    "Some souls do not vanish — they wait beyond the light.",
                ],
                i,
                1,
            ),
            pick(
                [
                    "The cosmos exhales like a dying choir.",
                    "Stars bleed into charcoal mist.",
                    "Hope feels heavier when it is the last thing left.",
                ],
                i,
                2,
            ),
        ])
    if i <= 30:
        return voice_join(
            [
                pick(
                    [
                        "I wear the dust of worlds like a second skin.",
                        "Each ruin remembers a prayer nobody speaks anymore.",
                        "Footsteps sound louder when you are alone with eternity.",
                    ],
                    i,
                    3,
                ),
                pick(
                    [
                        "The wind carries names I refuse to forget.",
                        "Even emptiness has texture if you listen.",
                        "I walk because stopping would mean admitting it's over.",
                    ],
                    i,
                    4,
                ),
            ]
        )
    if i <= 120:
        return voice_join(
            [
                pick(
                    [
                        "Forgotten gates rise from fog like incomplete dreams.",
                        "Ancient halls breathe cold blue fire.",
                        "The path narrows — truth prefers narrow places.",
                    ],
                    i,
                    5,
                ),
                pick(
                    [
                        "I follow a pulse older than constellations.",
                        "Every corridor hums with an unfinished song.",
                        "Memory becomes geography when worlds collapse.",
                    ],
                    i,
                    6,
                ),
            ]
        )
    if i <= 165:
        return voice_join(
            [
                pick(
                    [
                        "There — the last spark trembling inside the dark.",
                        "I reach through shadow like it is thin ice.",
                        "Mercy and ruin wear the same face out here.",
                    ],
                    i,
                    7,
                ),
                pick(
                    [
                        "To save it, I must become something smaller than myself.",
                        "Love is a vow spoken without witnesses.",
                        "The universe asks for one breath returned.",
                    ],
                    i,
                    8,
                ),
            ]
        )
    if i <= 176:
        return voice_join(
            [
                pick(
                    [
                        "Light returns — not loud, but certain.",
                        "The silence breaks into something gentle.",
                        "What was lost leaves a warmth behind.",
                    ],
                    i,
                    9,
                ),
                pick(
                    [
                        "I stay until the horizon remembers how to breathe.",
                        "Some endings are doors disguised as graves.",
                        "The cosmos learns my name and does not flinch.",
                    ],
                    i,
                    10,
                ),
            ]
        )
    return voice_join(
        [
            pick(
                [
                    "If this journey moved you, walk with us further.",
                    "Subscribe to Cinematic — more souls still wander.",
                    "Subscribe to Cinematic — the story continues beyond the stars.",
                ],
                i,
                11,
            ),
        ]
    )


def beyond_stars_voice(i):
    rel = i - 180
    if rel <= 8:
        return voice_join(
            [
                pick(
                    [
                        "We launched toward silence like it owed us answers.",
                        "Metal and prayer lift together into the black.",
                        "Past the maps, the universe stops pretending to be simple.",
                    ],
                    rel,
                    20,
                ),
                pick(
                    [
                        "Something pulses — older than starlight.",
                        "Instruments whisper a rhythm not in any manual.",
                        "The void blinks, once, like an eye opening.",
                    ],
                    rel,
                    21,
                ),
            ]
        )
    if rel <= 30:
        return voice_join(
            [
                pick(
                    [
                        "Out here, solitude becomes a cathedral.",
                        "Every window frames infinity — and infinity frames you.",
                        "Time stretches thin until it feels like silk.",
                    ],
                    rel,
                    22,
                ),
                pick(
                    [
                        "I chart distances measured in longing.",
                        "The ship hums — a lullaby for the fearless.",
                        "Stars look closer when you stop chasing them.",
                    ],
                    rel,
                    23,
                ),
            ]
        )
    if rel <= 140:
        return voice_join(
            [
                pick(
                    [
                        "Ruins float where physics bends politely.",
                        "Geometry repeats like memory refusing to die.",
                        "Signals carve glyphs only instinct can read.",
                    ],
                    rel,
                    24,
                ),
                pick(
                    [
                        "We were never first — only recent.",
                        "Metal wings drift beside bones of civilizations.",
                        "The vacuum carries hymns tuned to fear.",
                    ],
                    rel,
                    25,
                ),
            ]
        )
    if rel <= 170:
        return voice_join(
            [
                pick(
                    [
                        "It wakes — not with speech, but with weight.",
                        "Contact is not touch — it is recognition.",
                        "The ancient thing reads my fear and refracts it into awe.",
                    ],
                    rel,
                    26,
                ),
                pick(
                    [
                        "Knowledge pours in cold molten streams.",
                        "I understand how small answers can be.",
                        "The boundary between self and cosmos dissolves like smoke.",
                    ],
                    rel,
                    27,
                ),
            ]
        )
    if rel <= 177:
        return voice_join(
            [
                pick(
                    [
                        "I return changed — carrying a whisper I cannot translate.",
                        "Some truths leave you softer, not smarter.",
                        "The stars look different once you've seen beneath them.",
                    ],
                    rel,
                    28,
                ),
                pick(
                    [
                        "The journey engraved itself behind my eyes.",
                        "Silence now feels friendly — almost alive.",
                        "We are brief — and somehow still worthy of wonder.",
                    ],
                    rel,
                    29,
                ),
            ]
        )
    return voice_join(
        [
            pick(
                [
                    "Subscribe to Cinematic — chase the next horizon with us.",
                    "Subscribe to Cinematic — the voyage continues.",
                ],
                rel,
                30,
            ),
        ]
    )


CIV = [
    (
        "Ember Kingdoms",
        ["volcanic ridges", "obsidian citadels", "rivers of cooling magma", "ash auroras"],
        ["molten gold backlight", "crimson fog", "embers drifting like snow"],
    ),
    (
        "Sunken Archives",
        ["submerged libraries", "glass corridors underwater", "colossal statues swallowed by silt"],
        ["bioluminescent cyan", "ghostly teal shafts", "slow drifting parchment glow"],
    ),
    (
        "Sky Shepherds",
        ["floating islands chained by bridges of wind", "cloud temples", "sky herds of luminous creatures"],
        ["silver god-rays", "soft amber sun through cirrus", "thin atmospheric haze"],
    ),
    (
        "Iron Dreamers",
        ["living-metal orchards", "sleeping colossi fused with cables", "organic gears breathing steam"],
        ["cold steel blue", "copper highlights", "steam halos"],
    ),
    (
        "Void Monks",
        ["dark matter cloisters", "stairs that vanish into ink", "rings of silent chanting figures"],
        ["minimal starpinpoints", "deep violet absence", "rim lighting like eclipse"],
    ),
    (
        "Eternal Garden",
        ["overgrown paradise halls", "monuments swallowed by blossoms", "rain of petals through cracked domes"],
        ["decayed gold", "lush emerald rot", "warm pollen fog"],
    ),
]


def ancient_worlds_voice(i):
    if i >= 539:
        return voice_join(
            [
                pick(
                    [
                        "Subscribe to Cinematic — walk more lost worlds with us.",
                        "Subscribe to Cinematic — the archives have endless halls.",
                    ],
                    i,
                    42,
                ),
            ]
        )
    rel = i - 360
    civ_idx = min(max((rel - 1) // 30, 0), len(CIV) - 1)
    name, _, _ = CIV[civ_idx]
    return voice_join(
        [
            pick([f"Welcome to the {name} — memory carved into stone and myth.", f"The {name} breathe slower than empires rise.", f"In the {name}, beauty carries an obligation."], rel, 40),
            pick(
                [
                    "Listen — civilization leaves ghosts with manners.",
                    "Walk softly — awe is a kind of worship.",
                    "History stacks itself until the air grows thick.",
                ],
                rel,
                41,
            ),
        ]
    )


HEAVEN_HELL = [
    ("Heaven — unexpected", "golden geometry dissolving into kindness", "soft impossible warmth"),
    ("Hell — silence", "grey desert under a bruised sky", "cold ash falling like slow snow"),
    ("Purgatory — waiting", "endless marble stations", "thin clocks without hands"),
    ("The Void", "absolute black with one reluctant shimmer", "negative space that breathes"),
    ("The Dream World", "liquid architecture folding like silk", "sleep-colored auroras"),
    ("End of Everything", "final light bending backward", "universe folding like a closing eye"),
]


def heaven_voice(i):
    if i >= 719:
        return voice_join(
            [
                pick(
                    [
                        "Subscribe to Cinematic — dare the next impossible question with us.",
                        "Subscribe to Cinematic — imagination still has edges to explore.",
                    ],
                    i,
                    52,
                ),
            ]
        )
    rel = i - 540
    seg = min(max((rel - 1) // 30, 0), len(HEAVEN_HELL) - 1)
    title, a, b = HEAVEN_HELL[seg]
    return voice_join(
        [
            pick([f"What if imagination sculpted {title.lower()}?", f"This is {title} — rendered without mercy.", f"Consider {title} — not metaphor, but place."], rel, 50),
            pick([f"You witness {a}.", f"The atmosphere insists: {b}.", f"The soul reads the room — it reads {b}."], rel, 51),
        ]
    )


THEMES_721 = [
    "Cosmic loneliness & wonder",
    "Ancient forgotten worlds",
    "Human soul — loss, love, destiny",
    "AI dreams vs reality",
    "Dark cinematic — shadow & void",
    "Rise & rebirth — light from darkness",
]

ANTH_VOICES = [
    [
        "You drift between pillars of silence vast enough to baptize regret.",
        "Wonder hurts less when you stop owning it alone.",
        "Listen — the cosmos keeps its loneliest hymns for travelers without maps.",
        "Each star is a door someone closed gently behind them.",
        "Out here, solitude wears halos made of distant storms.",
        "If eternity has a pulse, you can feel it when nobody speaks.",
        "The universe does not forget — it simply waits in polite darkness.",
        "Even distance can feel holy when the frame is wide enough.",
        "You are small — and somehow still worthy of this awe.",
        "Light arrives late — but it always insists on arriving.",
    ],
    [
        "Sand climbs the stairs because memory refuses to kneel.",
        "Forgotten does not mean forgiven — only folded into time.",
        "Walk softly — these stones still rehearse old coronations.",
        "Ruins are sermons delivered without applause.",
        "Every empire leaves fingerprints in dust.",
        "Names vanish first — beauty lingers like stubborn incense.",
        "History stacks quietly until the wind rehearses it aloud.",
        "Some doors exist only as outlines now.",
        "Silence here tastes metallic — like coins nobody spends anymore.",
        "Ancient bells ring underwater in your imagination.",
    ],
    [
        "Love leaves echoes louder than arguments ever could.",
        "Loss teaches gravity — you feel it behind your ribs.",
        "Two destinies can braid without touching.",
        "You carry chapters no bookshelf could hold.",
        "Forgiveness sometimes looks like walking forward anyway.",
        "Hands remember warmth longer than minds remember names.",
        "Hope whispers — it does not shout across wounds.",
        "Every soul negotiates with fate at dusk.",
        "Some vows are spoken only to the rain.",
        "When everything fractures, mercy becomes architecture.",
    ],
    [
        "Machines dream in geometries humans mistake for weather.",
        "Glitch becomes gospel when beauty insists on breaking.",
        "What silicon sees is still stitched from longing.",
        "Circuits hum hymns tuned to possibility.",
        "Illusion and revelation trade coats at midnight.",
        "Pixels dissolve into cathedral fog.",
        "The unreal presses against reality until both soften.",
        "Electric vines crawl toward meanings not yet named.",
        "Dream logic prefers widescreen myth.",
        "Truth flickers — trust the rhythm beneath the noise.",
    ],
    [
        "Shadow is not absence — it is discretion.",
        "The void listens closer than crowds ever could.",
        "Darkness frames light the way silence frames sound.",
        "Fear becomes reverence when you stop running.",
        "Some truths hide behind eclipse fog on purpose.",
        "Outline becomes scripture when contrast is brave.",
        "You walk through ink — it does not stain your soul.",
        "Night holds council with forgotten constellations.",
        "Silence sharpens until it cuts clean.",
        "What you cannot see still guides your breathing.",
    ],
    [
        "Dawn arrives like a vow kept across centuries.",
        "Rebirth begins as a thin gold crack in the charcoal.",
        "Light remembers how to kneel before broken things.",
        "After endless night, mercy rises horizontal and slow.",
        "Hope does not roar — it warms.",
        "Ash remembers it used to be orchards.",
        "Every sunrise forgives the sky for going dark.",
        "You rise because something unseen insists you must.",
        "The horizon exhales — and color returns like an apology.",
        "New beginnings borrow courage from old endings.",
    ],
]


def anthology_voice(i):
    if i >= 899:
        return voice_join(
            [
                pick(
                    [
                        "Subscribe to Cinematic — more horizons are waiting.",
                        "Subscribe to Cinematic — walk the next thousand scenes with us.",
                    ],
                    i,
                    70,
                ),
            ]
        )
    rel = i - 720
    seg = min(max((rel - 1) // 30, 0), len(THEMES_721) - 1)
    theme = THEMES_721[seg]
    pool = ANTH_VOICES[seg]
    return voice_join(
        [
            pick(
                [
                    f"{theme} — wide frame; breathe slower and listen.",
                    f"{theme}: the horizon refuses haste.",
                    f"You are watching {theme.lower()} as endless widescreen myth.",
                ],
                rel,
                60,
            ),
            pick(pool, rel + seg * 11, seg),
        ]
    )


def visual_last_soul(i):
    places = [
        "shattered ringworld arc fading into void mist",
        "bridge of frozen lightning spanning dead nebulae",
        "cathedral carved inside a drifting asteroid",
        "sea of glass reflecting constellations upside-down",
        "tower of black mirrors humming with distant thunder",
        "desert of powdered bone under twin dying suns",
        "labyrinth of rib-like arches under emerald auroras",
        "altar floating above an abyss of swirling ink-clouds",
    ]
    effects = [
        "bioluminescent particles drifting like sorrow",
        "slow embers riding currents of vacuum wind",
        "thin fog glowing with buried starlight",
        "molten gold reflections crawling across wet stone",
    ]
    return (
        f"Cinematic ultra-wide 16:9 film frame; epic atmospheric sci-fi fantasy; {pick(places, i)}; "
        f"{pick(effects, i, 1)}; {pick(CAMERA, i)}; dramatic lighting; soulful mood; "
        "no text overlays; no modern cities; no comedy."
    )


def visual_beyond(i):
    places = [
        "cryo-lit cockpit overlooking infinite starfield",
        "hull corridor flooded with cobalt emergency bloom",
        "glass observatory dome cracking with frost patterns",
        "massive alien docking spine coated in frost dust",
        "floating megastructure ruins stitched with luminous veins",
        "planet-sized doorway opening into non-space",
    ]
    return (
        f"Cinematic ultra-wide 16:9; hard sci-fi awe; astronaut silhouette optional; {pick(places, i - 180)}; "
        f"{pick(['cold documentary clarity', 'high-contrast star flare', 'microscopic dust in light beams'], i)}; "
        f"{pick(CAMERA, i)}; dramatic restrained grade; no UI text; no cartoon."
    )


def visual_ancient(i):
    rel = i - 360
    civ_idx = min(max((rel - 1) // 30, 0), len(CIV) - 1)
    name, feats, lights = CIV[civ_idx]
    return (
        f"Cinematic ultra-wide 16:9 landscape world-building; civilization '{name}'; "
        f"{pick(feats, rel)}; lighting: {pick(lights, rel, 1)}; tiny robed figures for scale; "
        f"{pick(CAMERA, rel)}; awe and ancient silence; no narration text on screen."
    )


def visual_heaven(i):
    rel = i - 540
    _, a, b = HEAVEN_HELL[min(max((rel - 1) // 30, 0), len(HEAVEN_HELL) - 1)]
    return (
        f"Cinematic ultra-wide 16:9 surreal metaphysical scene; {a}; atmosphere {b}; "
        f"{pick(CAMERA, rel)}; uncanny beauty; emotionally heavy; no religious cliché caricature; no subtitles."
    )


ANTH_VISUALS = [
    [
        "pillars of cosmic dust converging into a glowing nave",
        "a lone figure on a glass dune under fracturing auroras",
        "slow tide of nebula fog washing across silent observatories",
        "black ocean of stars with ripples of pale bioluminescence",
        "crystalline shards orbiting like frozen prayers",
    ],
    [
        "colossal statues half-buried in red dunes",
        "broken aqueducts threading through canyon mist",
        "sunken palace courtyard exposed by drought",
        "obelisks carved with languages light forgot",
        "sandstorms shaping faces in ancient walls",
    ],
    [
        "two silhouettes separated by a burning wheat field",
        "hands releasing ash that becomes moths of light",
        "rain over a forgotten chapel lit by one candle",
        "a single chair on a cliff facing thunderheads",
        "old letters dissolving into snow above a fjord",
    ],
    [
        "impossible staircases tessellating into sky",
        "aurora ribbons glitching into stained glass",
        "mirror desert reflecting code-like constellations",
        "cathedral windows made of liquid OLED stained glass",
        "floating stone rings threaded with fiber-optic vines",
    ],
    [
        "silhouette crossing a bridge made of eclipse fog",
        "forest of black trees rim-lit by violet lightning",
        "vast hall where shadows pool like ink tides",
        "figure kneeling before a void shaped like an eye",
        "snow falling upward into a hungry sky",
    ],
    [
        "first horizontal blade of gold slicing charcoal clouds",
        "river thawing through ice like breathing glass",
        "field of char sprouting luminous seedlings",
        "giant moon cracking to reveal warm interior light",
        "dawn mist lifting from ruins wrapped in ivy fireflies",
    ],
]


def visual_anthology(i):
    rel = i - 720
    seg = min(max((rel - 1) // 30, 0), len(THEMES_721) - 1)
    mood = pick(ANTH_VISUALS[seg], rel, seg + 3)
    return (
        f"Cinematic ultra-wide 16:9 epic mood piece — {THEMES_721[seg].lower()}; {mood}; "
        f"symbolic silhouettes for scale; vast horizon; {pick(CAMERA, rel)}; poetic surreal realism; "
        "film grain subtle; deep color grade; no urban mundane; no on-screen text."
    )


def voice_for_index(i):
    if i <= 180:
        return last_soul_voice(i)
    if i <= 360:
        return beyond_stars_voice(i)
    if i <= 540:
        return ancient_worlds_voice(i)
    if i <= 720:
        return heaven_voice(i)
    return anthology_voice(i)


def visual_for_index(i):
    if i <= 180:
        return visual_last_soul(i)
    if i <= 360:
        return visual_beyond(i)
    if i <= 540:
        return visual_ancient(i)
    if i <= 720:
        return visual_heaven(i)
    return visual_anthology(i)


BATCHES = [
    (1, "cinematic-long-01", 1, 180, "The Last Soul", "Dramatic"),
    (2, "cinematic-long-02", 181, 360, "Beyond the Stars — An AI Cinematic Journey", "Documentary"),
    (3, "cinematic-long-03", 361, 540, "Ancient AI Worlds — Lost Civilizations Reimagined", "Documentary"),
    (4, "cinematic-long-04", 541, 720, "What If AI Imagined Heaven, Hell & Everything Between?", "Dramatic"),
    (
        5,
        "cinematic-long-05",
        721,
        900,
        "The Wide Horizon — Wonder, Ruin, Soul, Dream, Shadow & Dawn",
        "Dramatic",
    ),
]


def main():
    lines = []
    lines.append("# Prompts — Long Videos | Cinematic (@Subscribe Cinematic)")
    lines.append(
        "> **One file · 900 prompts · 8 seconds each** → **120 minutes** (~**2 hours**) "
        "of raw clips per full master render (`900 × 8s = 7200s`)."
    )
    lines.append(">")
    lines.append(
        "> **~24 minute long videos:** paste **180 prompts per veo3.pk project** → "
        "`180 × 8s = 1440s` (~24 min). **Five projects** = full set (scenes **1–180**, **181–360**, **361–540**, **541–720**, **721–900**)."
    )
    lines.append(">")
    lines.append(
        "> **~24 second Shorts:** same scene order — **3 prompts = one Short** (`3 × 8s = 24s`). "
        "**300 Shorts** from **900** scenes. Trim a master export every **24s**, or generate portrait (**9:16**) using the same prompt numbers."
    )
    lines.append("> Orientation (long-form below): **Landscape 16:9** | Platform: **veo3.pk** | Model: **Google Flow VEO**")
    lines.append("> Format: `Prompt N:` visual → next line `Voice:` narration (~20–28 words)")
    lines.append("")
    lines.append("---")
    lines.append("")

    for _, proj, start, end, title, style in BATCHES:
        lines.append(f"## Batch — {proj} — Scenes {start}–{end}")
        lines.append(f"- **Title arc**: {title}")
        lines.append(f"- **Writing style on veo3.pk**: {style}")
        lines.append("")
        for n in range(start, end + 1):
            lines.append(f"Prompt {n}: {visual_for_index(n)}")
            lines.append(f"Voice: {voice_for_index(n)}")
            lines.append("")
        lines.append("---")
        lines.append("")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")
    print(f"Wrote {OUT} ({900} prompts)")


if __name__ == "__main__":
    main()
