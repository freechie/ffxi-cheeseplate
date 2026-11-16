#!/usr/bin/env python3
"""Write GearSwap overlay labels into official FFXI macro books (names + line 1).

Maintained now:
  1 THF/DNC — set 1 Ctrl=Dancer, Alt=openers;
    set 2 Ctrl=utility (Spectral/Drain II/Aspir + THF JAs), Alt=Aeolian.

Books 2–20 are blanked. DNC-main and NIN-main books return when those jobs hit 99.

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
    "Drain Samba II": "DrnSmb2",
    "Aspir Samba": "AspSamba",
    "D.Waltz II": "DWaltz2",
    "Healing Waltz": "HealWltz",
    "Violent": "Violent",
    "Climactic": "Climact",
    "Striking": "Striking",
    "Spectral Jig": "SpectJig",
    "Chocobo Jig II": "ChocoJig",
    "Aspir Samba II": "AspSmb2",
    "Drain Samba III": "DrnSmb3",
    "Collaborator": "Collab",
    "Accomplice": "Accomp",
    "Bully": "Bully",
    "Steal": "Steal",
    "Mug": "Mug",
    "Wild": "WildFlur",
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
    "SA opener": "SA open",
    "TA opener": "TA open",
    "Despoil": "Despoil",
}

JOBS = {
    "THF": {
        "book": 1,
        "book_title": "THF/DNC",
        "rows": {
            "^": [
                ("Box Step", 'input /ja "Box Step" <t>'),
                ("Quickstep", 'input /ja "Quickstep" <t>'),
                ("Haste Samba", 'input /ja "Haste Samba" <me>'),
                ("Stutter Step", 'input /ja "Stutter Step" <t>'),
                ("Reverse", 'input /ja "Reverse Flourish" <me>'),
                ("Violent", 'input /ja "Violent Flourish" <t>'),
                ("C.Waltz III", 'input /ja "Curing Waltz III" <stpc>'),
                ("Healing Waltz", 'input /ja "Healing Waltz" <stpc>'),
                ("Divine Waltz", 'input /ja "Divine Waltz" <me>'),
                ("Animated", 'input /ja "Animated Flourish" <t>'),
            ],
            "!": [
                ("Evisceration", 'input /ws "Evisceration" <t>'),
                ("SA opener", "gs c saopen"),
                ("TA opener", "gs c taopen"),
                ("SATA", "gs c sata"),
                ("Feint", 'input /ja "Feint" <t>'),
                ("Hide", 'input /ja "Hide" <me>'),
                ("Despoil", 'input /ja "Despoil" <t>'),
                ("Conspirator", 'input /ja "Conspirator" <me>'),
                ("Perfect Dodge", 'input /ja "Perfect Dodge" <me>'),
                ("Flee", 'input /ja "Flee" <me>'),
            ],
            # Set 2 Ctrl: utility. Building / Chocobo Jig II need DNC main (sub cap 49).
            "~^": [
                ("Spectral Jig", 'input /ja "Spectral Jig" <me>'),
                ("Drain Samba II", 'input /ja "Drain Samba II" <me>'),
                ("Aspir Samba", 'input /ja "Aspir Samba" <me>'),
                ("Assassin's Charge", 'input /ja "Assassin\'s Charge" <me>'),
                ("Collaborator", 'input /ja "Collaborator" <stpt>'),
                ("Accomplice", 'input /ja "Accomplice" <stpt>'),
                ("Bully", 'input /ja "Bully" <t>'),
                ("Steal", 'input /ja "Steal" <t>'),
                ("Mug", 'input /ja "Mug" <t>'),
                ("Wild", 'input /ja "Wild Flourish" <t>'),
            ],
            "~!": [
                ("Aeolian Edge", 'input /ws "Aeolian Edge" <t>'),
            ],
        },
    },
}

# Blank every book after THF/DNC. DNC/NIN books are recreated at 99.
BLANK_BOOKS = list(range(2, 21))


def macro_name(label: str) -> str:
    name = NAME_ALIASES.get(label, label)
    return name[:TITLE_LEN]


def to_macro_line(cmd: str) -> str:
    """Convert a GearSwap bind into a line the in-game macro book will run.

    A macro line that starts with // is a comment, so the client never sends it.
    Typing //gs in chat still works because Windower reads the chat box directly.
    /console is the command the macro book can actually execute.
    """
    if cmd.startswith("input "):
        return cmd[len("input ") :]
    if cmd.startswith("gs ") or cmd.startswith("tru") or cmd.startswith("kl "):
        return "/console " + cmd
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
            for job in JOBS:
                files = write_job(user_dir, job)
                book = JOBS[job]["book"]
                for set_no in (1, 2):
                    verify(user_dir / set_filename(book, set_no))
                print(f"  {job} book {book}: {', '.join(files)}")
            ttl = user_dir / "mcr.ttl"
            for book in BLANK_BOOKS:
                for set_no in range(1, 11):
                    path = user_dir / set_filename(book, set_no)
                    path.write_bytes(build_set([], []))
                    verify(path)
                if ttl.exists():
                    update_book_title(ttl, book, f"Book{book}")
                print(f"  blanked book {book}")
        except OSError as exc:
            print(f"  write failed (need elevation for Program Files?): {exc}")
            continue
    print("done — log in and open book 1 (THF/DNC)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
