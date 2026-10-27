#!/usr/bin/env python3
"""Write GearSwap overlay labels into official FFXI macro books (names + line 1).

Books are alphabetical and sequential. Main jobs use sets 1 and 2.
Combo books are set 1 only.
  1 DNC, 2 DNC/NIN, 3 DNC/THF, 4 DNC/WAR, 5 NIN, 6 NIN/DNC,
  7 NIN/THF, 8 NIN/WAR, 9 PUP/DNC, 10 THF, 11 THF/DNC, 12 THF/WAR.

Macro names are capped at 8 characters (FFXI limit). Close the client before running.
"""

from __future__ import annotations

import hashlib
import shutil
import sys
from pathlib import Path

HEADER_PREFIX = bytes.fromhex("0100000098b15703")
LINE_LEN = 61
TITLE_LEN = 8
BOOK_TITLE_LEN = 16
MACROS = 20
FILE_LEN = 7624
TTL_LEN = 344

# Prefer readable 8-char names for labels that would otherwise truncate poorly.
NAME_ALIASES = {
    "Sneak Attack": "SneakAtk",
    "Trick Attack": "TrickAtk",
    "Evisceration": "Evisc",
    "Aeolian Edge": "Aeolian",
    "Shark Bite": "SharkBit",
    "Dancing Edge": "DancEdge",
    "Perfect Dodge": "PerfDdg",
    "Conspirator": "Conspir",
    "Accomplice p1": "Accomp1",
    "Accomplice p2": "Accomp2",
    "Collab p1": "Collab1",
    "Collab p2": "Collab2",
    "Raise trusts": "RaiseTru",
    "Capacity Ring": "Capacity",
    "Trizek Ring": "Trizek",
    "Warp Ring": "Warp",
    "Echad Ring": "Echad",
    "Caliber Ring": "Caliber",
    "Emperor Band": "Emperor",
    "Haste Samba": "HasteSmb",
    "Box Step": "BoxStep",
    "Quickstep": "Quickstp",
    "Feather Step": "Feather",
    "Stutter Step": "Stutter",
    "Reverse": "Reverse",
    "Building": "Building",
    "C.Waltz V": "CWaltzV",
    "C.Waltz IV": "CWaltzIV",
    "C.Waltz III": "CWaltz3",
    "C.Waltz II": "CWaltz2",
    "Drain Samba": "DrnSamba",
    "D.Waltz II": "DWaltz2",
    "Healing Waltz": "HealWltz",
    "Violent": "Violent",
    "Climactic": "Climact",
    "Striking": "Striking",
    "Spectral Jig": "SpectJig",
    "Chocobo Jig II": "ChocoJig",
    "Aspir Samba II": "AspSmb2",
    "Drain Samba III": "DrnSmb3",
    "Animated": "Animated",
    "Desperate": "Desperat",
    "Divine Waltz": "DivWaltz",
    "Idle set": "IdleSet",
    "TP set": "TP set",
    "TH set": "TH set",
    "Wasp Sting": "WaspStng",
    "Viper Bite": "ViperBit",
    "Assassin's Charge": "A.Charge",
    "Rudra's Storm": "Rudra",
    "Exenterator": "Exent",
    "Mandalic Stab": "Mandalic",
    "Shadowstitch": "Shadow",
    "Energy Drain": "EnDrain",
    "Mighty Strikes": "Mighty",
    "Blade: To": "Bld To",
    "Blade: Ei": "Bld Ei",
    "Blade: Ku": "Bld Ku",
    "Blade: Retsu": "BldRetsu",
    "Utsu Ni": "Utsu Ni",
    "Utsu Ichi": "UtsuIch",
    "Blade: Jin": "Bld Jin",
    "Blade: Ten": "Bld Ten",
    "Blade: Teki": "BldTeki",
    "Blade: Chi": "Bld Chi",
    "Mijin Gakure": "Mijin",
    "Katon: Ni": "KatonNi",
    "Hyoton: Ni": "HyotonNi",
    "Huton: Ni": "HutonNi",
    "Doton: Ni": "DotonNi",
    "Raiton: Ni": "RaitonNi",
    "Suiton: Ni": "SuitonNi",
    "Katon: Ichi": "Katon1",
    "Raiton: Ichi": "Raiton1",
    "Suiton: Ichi": "Suiton1",
    "Huton: Ichi": "Huton1",
    "Tonko: Ni": "TonkoNi",
    "Hojo: Ni": "Hojo Ni",
    "Kurayami: Ni": "KurayaNi",
    "Jubaku: Ichi": "Jubaku1",
    "Dokumori: Ichi": "Dokumor1",
    "Hojo: Ichi": "Hojo1",
    "Kurayami: Ichi": "Kuraya1",
    "Aggressor": "Aggressr",
    "SA Evisc": "SA Evisc",
    "TA Evisc": "TA Evisc",
}

JOBS = {
    "THF": {
        "book": 10,
        "book_title": "THF",
        "rows": {
            "^": [
                ("Feint", 'input /ja "Feint" <t>'),
                ("Sneak Attack", 'input /ja "Sneak Attack" <me>'),
                ("Trick Attack", 'input /ja "Trick Attack" <me>'),
                ("Bully", 'input /ja "Bully" <t>'),
                ("Hide", 'input /ja "Hide" <me>'),
                ("Collab p1", 'input /ja "Collaborator" <p1>'),
                ("Accomplice p1", 'input /ja "Accomplice" <p1>'),
                ("Larceny", 'input /ja "Larceny" <t>'),
                ("Perfect Dodge", 'input /ja "Perfect Dodge" <me>'),
                ("Conspirator", 'input /ja "Conspirator" <me>'),
            ],
            "!": [
                ("Steal", 'input /ja "Steal" <t>'),
                ("Despoil", 'input /ja "Despoil" <t>'),
                ("Mug", 'input /ja "Mug" <t>'),
                ("Flee", 'input /ja "Flee" <me>'),
                ("Evisceration", 'input /ws "Evisceration" <t>'),
                ("Aeolian Edge", 'input /ws "Aeolian Edge" <t>'),
                ("Shark Bite", 'input /ws "Shark Bite" <t>'),
                ("Dancing Edge", 'input /ws "Dancing Edge" <t>'),
                ("Collab p2", 'input /ja "Collaborator" <p2>'),
                ("Accomplice p2", 'input /ja "Accomplice" <p2>'),
            ],
            "~^": [
                ("Trizek Ring", "gs c trizek"),
                ("Capacity Ring", "gs c capring"),
                ("Warp Ring", "gs c warp"),
                ("Food", 'input /item "Grape Daifuku" <me>'),
                ("Raise trusts", "tru raise"),
                ("EXP", "tru exp"),
                ("TH set", "gs c th"),
                ("SATA", "gs c sata"),
                ("TP set", "gs c toggle TP set"),
                ("Dismiss", "input /refa all"),
            ],
            "~!": [
                ("Ranged", "input /ra <t>"),
                ("Wasp Sting", 'input /ws "Wasp Sting" <t>'),
                ("Viper Bite", 'input /ws "Viper Bite" <t>'),
                ("Idle set", "gs c toggle Idle set"),
                ("Assassin's Charge", 'input /ja "Assassin\'s Charge" <me>'),
                ("Rudra's Storm", 'input /ws "Rudra\'s Storm" <t>'),
                ("Exenterator", 'input /ws "Exenterator" <t>'),
                ("Mandalic Stab", 'input /ws "Mandalic Stab" <t>'),
                ("Shadowstitch", 'input /ws "Shadowstitch" <t>'),
                ("Energy Drain", 'input /ws "Energy Drain" <t>'),
            ],
        },
    },
    "DNC": {
        "book": 1,
        "book_title": "DNC",
        "rows": {
            "^": [
                ("EXP", "tru exp"),
                ("Haste Samba", 'input /ja "Haste Samba" <me>'),
                ("Box Step", 'input /ja "Box Step" <t>'),
                ("Quickstep", 'input /ja "Quickstep" <t>'),
                ("Feather Step", 'input /ja "Feather Step" <t>'),
                ("Stutter Step", 'input /ja "Stutter Step" <t>'),
                ("Reverse", 'input /ja "Reverse Flourish" <me>'),
                ("Building", 'input /ja "Building Flourish" <me>'),
                ("Wild", 'input /ja "Wild Flourish" <t>'),
                ("Presto", 'input /ja "Presto" <me>'),
            ],
            "!": [
                ("C.Waltz V", 'input /ja "Curing Waltz V" <stpc>'),
                ("C.Waltz IV", 'input /ja "Curing Waltz IV" <stpc>'),
                ("C.Waltz III", 'input /ja "Curing Waltz III" <stpc>'),
                ("D.Waltz II", 'input /ja "Divine Waltz II" <me>'),
                ("Healing Waltz", 'input /ja "Healing Waltz" <stpc>'),
                ("Violent", 'input /ja "Violent Flourish" <t>'),
                ("Climactic", 'input /ja "Climactic Flourish" <me>'),
                ("Striking", 'input /ja "Striking Flourish" <me>'),
                ("Evisceration", 'input /ws "Evisceration" <t>'),
                ("Dancing Edge", 'input /ws "Dancing Edge" <t>'),
            ],
            "~^": [
                ("Spectral Jig", 'input /ja "Spectral Jig" <me>'),
                ("Chocobo Jig II", 'input /ja "Chocobo Jig II" <me>'),
                ("Echad Ring", "gs c echad"),
                ("Caliber Ring", "gs c caliber"),
                ("Emperor Band", "gs c emperor"),
                ("Warp Ring", "gs c warp"),
                ("Trusts", "tru"),
                ("Raise trusts", "tru raise"),
                ("Aspir Samba II", 'input /ja "Aspir Samba II" <me>'),
                ("Drain Samba III", 'input /ja "Drain Samba III" <me>'),
            ],
            "~!": [
                ("Animated", 'input /ja "Animated Flourish" <t>'),
                ("Desperate", 'input /ja "Desperate Flourish" <t>'),
                ("Divine Waltz", 'input /ja "Divine Waltz" <me>'),
                ("Aeolian Edge", 'input /ws "Aeolian Edge" <t>'),
                ("Shark Bite", 'input /ws "Shark Bite" <t>'),
                ("Trance", 'input /ja "Trance" <me>'),
                ("Food", 'input /item "Grape Daifuku" <me>'),
                ("TP set", "gs c toggle TP set"),
                ("Idle set", "gs c toggle Idle set"),
                ("Dismiss", "input /refa all"),
            ],
        },
    },
    "NIN": {
        "book": 5,
        "book_title": "NIN",
        "rows": {
            "^": [
                ("EXP", "tru exp"),
                ("Utsu Ni", 'input /ma "Utsusemi: Ni" <me>'),
                ("Utsu Ichi", 'input /ma "Utsusemi: Ichi" <me>'),
                ("Yonin", 'input /ja "Yonin" <me>'),
                ("Innin", 'input /ja "Innin" <me>'),
                ("Suiton: Ni", 'input /ma "Suiton: Ni" <t>'),
                ("Katon: Ichi", 'input /ma "Katon: Ichi" <t>'),
                ("Raiton: Ichi", 'input /ma "Raiton: Ichi" <t>'),
                ("Suiton: Ichi", 'input /ma "Suiton: Ichi" <t>'),
                ("Mijin Gakure", 'input /ja "Mijin Gakure" <t>'),
            ],
            "!": [
                ("Katon: Ni", 'input /ma "Katon: Ni" <t>'),
                ("Hyoton: Ni", 'input /ma "Hyoton: Ni" <t>'),
                ("Huton: Ni", 'input /ma "Huton: Ni" <t>'),
                ("Doton: Ni", 'input /ma "Doton: Ni" <t>'),
                ("Raiton: Ni", 'input /ma "Raiton: Ni" <t>'),
                ("Blade: Jin", 'input /ws "Blade: Jin" <t>'),
                ("Blade: Ten", 'input /ws "Blade: Ten" <t>'),
                ("Blade: Teki", 'input /ws "Blade: Teki" <t>'),
                ("Blade: Chi", 'input /ws "Blade: Chi" <t>'),
                ("Huton: Ichi", 'input /ma "Huton: Ichi" <t>'),
            ],
            "~^": [
                ("Monomi", 'input /ma "Monomi: Ichi" <me>'),
                ("Tonko: Ni", 'input /ma "Tonko: Ni" <me>'),
                ("Echad Ring", "gs c echad"),
                ("Caliber Ring", "gs c caliber"),
                ("Warp Ring", "gs c warp"),
                ("Food", 'input /item "Grape Daifuku" <me>'),
                ("Raise trusts", "tru raise"),
                ("Trusts", "tru"),
                ("Emperor Band", "gs c emperor"),
                ("Dismiss", "input /refa all"),
            ],
            "~!": [
                ("Hojo: Ni", 'input /ma "Hojo: Ni" <t>'),
                ("Kurayami: Ni", 'input /ma "Kurayami: Ni" <t>'),
                ("Jubaku: Ichi", 'input /ma "Jubaku: Ichi" <t>'),
                ("Dokumori: Ichi", 'input /ma "Dokumori: Ichi" <t>'),
                ("Hojo: Ichi", 'input /ma "Hojo: Ichi" <t>'),
                ("Kurayami: Ichi", 'input /ma "Kurayami: Ichi" <t>'),
                ("Blade: To", 'input /ws "Blade: To" <t>'),
                ("Blade: Ei", 'input /ws "Blade: Ei" <t>'),
                ("Blade: Ku", 'input /ws "Blade: Ku" <t>'),
                ("Blade: Retsu", 'input /ws "Blade: Retsu" <t>'),
            ],
        },
    },
}

# Ctrl+Alt subjob rows from binds.lua.
SUB_NIN = [
    ("Utsu Ni", 'input /ma "Utsusemi: Ni" <me>'),
    ("Utsu Ichi", 'input /ma "Utsusemi: Ichi" <me>'),
    ("Yonin", 'input /ja "Yonin" <me>'),
    ("Innin", 'input /ja "Innin" <me>'),
    ("Tonko: Ni", 'input /ma "Tonko: Ni" <me>'),
    ("Monomi", 'input /ma "Monomi: Ichi" <me>'),
    ("Katon: Ni", 'input /ma "Katon: Ni" <t>'),
    ("Huton: Ni", 'input /ma "Huton: Ni" <t>'),
    ("Hojo: Ni", 'input /ma "Hojo: Ni" <t>'),
    ("Kurayami: Ni", 'input /ma "Kurayami: Ni" <t>'),
]

SUB_THF = [
    ("SA", 'input /ja "Sneak Attack" <me>'),
    ("TA", 'input /ja "Trick Attack" <me>'),
    ("SA Evisc", "gs c saevisc"),
    ("TA Evisc", "gs c taevisc"),
    ("Steal", 'input /ja "Steal" <t>'),
    ("Mug", 'input /ja "Mug" <t>'),
    ("Flee", 'input /ja "Flee" <me>'),
    ("Hide", 'input /ja "Hide" <me>'),
    ("Perfect Dodge", 'input /ja "Perfect Dodge" <me>'),
]

SUB_WAR = [
    ("Provoke", 'input /ja "Provoke" <t>'),
    ("Berserk", 'input /ja "Berserk" <me>'),
    ("Defender", 'input /ja "Defender" <me>'),
    ("Warcry", 'input /ja "Warcry" <me>'),
    ("Aggressor", 'input /ja "Aggressor" <me>'),
    ("Mighty Strikes", 'input /ja "Mighty Strikes" <me>'),
]

SUB_DNC = [
    ("Box Step", 'input /ja "Box Step" <t>'),
    ("Quickstep", 'input /ja "Quickstep" <t>'),
    ("Haste Samba", 'input /ja "Haste Samba" <me>'),
    ("Animated", 'input /ja "Animated Flourish" <t>'),
    ("Desperate", 'input /ja "Desperate Flourish" <t>'),
    ("Reverse", 'input /ja "Reverse Flourish" <me>'),
    ("Violent", 'input /ja "Violent Flourish" <t>'),
    ("C.Waltz III", 'input /ja "Curing Waltz III" <stpc>'),
    ("Divine Waltz", 'input /ja "Divine Waltz" <me>'),
    ("Healing Waltz", 'input /ja "Healing Waltz" <stpc>'),
]

TRANCE = [("Trance", 'input /ja "Trance" <me>')]

# Alphabetical combo books, set 1. Main-job books are 1 DNC, 5 NIN, 10 THF.
COMBOS = [
    (2, "DNC/NIN", SUB_NIN, []),
    (3, "DNC/THF", SUB_THF, []),
    (4, "DNC/WAR", SUB_WAR, []),
    (6, "NIN/DNC", SUB_DNC, JOBS["NIN"]["rows"]["!"]),
    (7, "NIN/THF", SUB_THF, []),
    (8, "NIN/WAR", SUB_WAR, []),
    (9, "PUP/DNC", SUB_DNC, TRANCE),
    (11, "THF/DNC", SUB_DNC, JOBS["THF"]["rows"]["!"]),
    (12, "THF/WAR", SUB_WAR, []),
]

# Sets left behind when a book changed jobs. Cleared so the palette matches the title.
STALE_SETS = [(1, 3), (2, 2), (2, 3), (3, 2), (3, 3), (6, 2), (6, 3), (8, 2)]

# Whole books that were a second copy of DNC or NIN. Removed, titles reset.
OBSOLETE_BOOKS = [13, 19]


def macro_name(label: str) -> str:
    name = NAME_ALIASES.get(label, label)
    return name[:TITLE_LEN]


def to_macro_line(cmd: str) -> str:
    """Convert GearSwap bind command to something usable as a macro line."""
    if cmd.startswith("input "):
        return cmd[len("input ") :]
    if cmd.startswith("gs ") or cmd.startswith("tru") or cmd.startswith("kl "):
        return "//" + cmd
    return cmd


def pad(text: str, size: int) -> bytes:
    raw = text.encode("ascii", "replace")[:size]
    return raw + b"\x00" * (size - len(raw))


def seal(body_from_24: bytes) -> bytes:
    digest = hashlib.md5(body_from_24).digest()
    return HEADER_PREFIX + digest + body_from_24


def blank_set() -> bytearray:
    buf = bytearray(FILE_LEN)
    buf[0:4] = b"\x01\x00\x00\x00"
    buf[4:8] = bytes.fromhex("98b15703")
    # hash filled by seal(); body from 24 is zeros for empty macros
    return buf


def write_slot(buf: bytearray, index: int, title: str, line1: str = "") -> None:
    assert 0 <= index < MACROS
    # offset of macro i: 28 + i*380 for i<19, last is same formula with smaller pad
    # Each of first 19: 366 + 8 + 6 = 380; last: 366 + 8 + 2 = 376
    off = 28
    for i in range(index):
        off += 380 if i < 19 else 376
    # Actually for i in 0..18 size is 380, so off = 28 + index * 380 for index <= 19
    # Wait last macro starts at 28 + 19*380 = 28 + 7220 = 7248, then 376 bytes → 7624.
    off = 28 + index * 380
    lines_size = 6 * LINE_LEN
    # clear lines + title
    end_title = off + lines_size + TITLE_LEN
    buf[off:end_title] = b"\x00" * (lines_size + TITLE_LEN)
    if line1:
        buf[off : off + LINE_LEN] = pad(line1, LINE_LEN)
    buf[off + lines_size : off + lines_size + TITLE_LEN] = pad(title, TITLE_LEN)


def build_set(ctrl_entries, alt_entries) -> bytes:
    buf = blank_set()
    for i, (label, cmd) in enumerate(ctrl_entries[:10]):
        write_slot(buf, i, macro_name(label), to_macro_line(cmd))
    for i, (label, cmd) in enumerate(alt_entries[:10]):
        write_slot(buf, 10 + i, macro_name(label), to_macro_line(cmd))
    body = bytes(buf[24:])
    return seal(body)


def set_filename(book: int, set_no: int) -> str:
    idx = (book - 1) * 10 + (set_no - 1)
    return "mcr.dat" if idx == 0 else f"mcr{idx}.dat"


def update_book_title(ttl_path: Path, book: int, title: str) -> None:
    data = bytearray(ttl_path.read_bytes())
    if len(data) != TTL_LEN:
        raise SystemExit(f"unexpected ttl size {len(data)} for {ttl_path}")
    # books 1-20 in mcr.ttl; offset 24 + (book-1)*16
    if not (1 <= book <= 20):
        raise SystemExit(f"book {book} not in mcr.ttl")
    off = 24 + (book - 1) * BOOK_TITLE_LEN
    data[off : off + BOOK_TITLE_LEN] = pad(title, BOOK_TITLE_LEN)
    sealed = seal(bytes(data[24:]))
    ttl_path.write_bytes(sealed)


def write_job(user_dir: Path, job: str) -> list[str]:
    cfg = JOBS[job]
    book = cfg["book"]
    rows = cfg["rows"]
    written = []

    sets = []
    if rows:
        sets.extend([
            (1, rows.get("^", []), rows.get("!", [])),
            (2, rows.get("~^", []), rows.get("~!", [])),
        ])
    for set_no, ctrl, alt in sets:
        path = user_dir / set_filename(book, set_no)
        path.write_bytes(build_set(ctrl, alt))
        written.append(str(path.name))

    ttl = user_dir / "mcr.ttl"
    if ttl.exists():
        update_book_title(ttl, book, cfg["book_title"])
        written.append("mcr.ttl")
    return written


def verify(path: Path) -> None:
    data = path.read_bytes()
    assert len(data) == FILE_LEN
    assert data[8:24] == hashlib.md5(data[24:]).digest()


def game_running() -> bool:
    import subprocess

    out = subprocess.run(
        ["tasklist", "/fi", "imagename eq pol.exe", "/nh"],
        capture_output=True, text=True,
    ).stdout
    return "pol.exe" in out.lower()


def main() -> int:
    running = game_running()
    repo = Path(__file__).resolve().parents[2] / "game" / "USER" / "158678d"
    live = Path(r"C:\Program Files (x86)\Steam\steamapps\common\FFXINA\SquareEnix\FINAL FANTASY XI\USER\158678d")
    targets = []
    if repo.is_dir():
        targets.append(repo)
    if live.is_dir() and not running:
        targets.append(live)
    elif running:
        print("PlayOnline is open, so the live macro files were left alone. Quit, then run this again.", file=sys.stderr)
    if not targets:
        print("no USER folders found", file=sys.stderr)
        return 1

    for user_dir in targets:
        # backup ttl once per target
        ttl = user_dir / "mcr.ttl"
        if ttl.exists():
            bak = ttl.with_suffix(".ttl.bak-overlay")
            if not bak.exists():
                try:
                    shutil.copy2(ttl, bak)
                except OSError as exc:
                    print(f"  (skip ttl backup: {exc})")
        print(f"== {user_dir}")
        try:
            for job in ("THF", "DNC", "NIN"):
                files = write_job(user_dir, job)
                book = JOBS[job]["book"]
                for set_no in (1, 2):
                    verify(user_dir / set_filename(book, set_no))
                print(f"  {job} book {book}: {', '.join(files)}")
            for book, title, ctrl, alt in COMBOS:
                path = user_dir / set_filename(book, 1)
                path.write_bytes(build_set(ctrl, alt))
                verify(path)
                ttl = user_dir / "mcr.ttl"
                if ttl.exists():
                    update_book_title(ttl, book, title)
                print(f"  {title} book {book}: {path.name}")
            for book, set_no in STALE_SETS:
                path = user_dir / set_filename(book, set_no)
                path.write_bytes(build_set([], []))
                verify(path)
                print(f"  cleared book {book} set {set_no}: {path.name}")
            for book in OBSOLETE_BOOKS:
                for set_no in (1, 2, 3):
                    path = user_dir / set_filename(book, set_no)
                    if path.exists():
                        path.unlink()
                        print(f"  removed duplicate book {book} set {set_no}: {path.name}")
                ttl = user_dir / "mcr.ttl"
                if ttl.exists():
                    update_book_title(ttl, book, f"Book{book}")
        except OSError as exc:
            print(f"  write failed (need elevation for Program Files?): {exc}")
            continue
    print("done — log in and open the book/set listed in keybinds.md")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
