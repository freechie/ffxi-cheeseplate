"""Write windower/keybinds.xlsx from the GearSwap bind tables.

Levels match the bars that load in game: Dancer 94, Thief 99, Ninja 70,
subjob 49. A level gate keeps its key slot empty instead of shifting the row.
"""

from __future__ import annotations

import zipfile
from pathlib import Path
from xml.sax.saxutils import escape

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "keybinds.xlsx"

KEYS = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
FIDS = [f"f{i}" for i in range(1, 13)]
MODS = [
    ("^", "Ctrl"),
    ("!", "Alt"),
    ("~^", "Ctrl+Shift"),
    ("~!", "Alt+Shift"),
    ("^!", "Ctrl+Alt"),
]
MOD_NAME = dict(MODS)
PREFIXES = ["^!", "~^", "~!", "^", "!"]
F_SCAN = ["!", "^", "~!", "~^"]
MACRO_BOOKS = {"DNC": 1, "NIN": 5, "THF": 10}
MACRO_SETS = {"^": 1, "!": 1, "~^": 2, "~!": 2, "^!": 3}
COMBO_BOOK = {
    "DNC": {"NIN": (2, 1), "THF": (3, 1), "WAR": (4, 1)},
    "NIN": {"DNC": (6, 1), "THF": (7, 1), "WAR": (8, 1)},
    "THF": {"DNC": (11, 1), "WAR": (12, 1)},
}
LEVELS = {"DNC": 94, "THF": 99, "NIN": 70, "WAR": 49}
JOB_NAME = {"DNC": "Dancer", "THF": "Thief", "NIN": "Ninja", "WAR": "Warrior"}

DESC = {
    "Camps": "Sakura regen",
    "EXP": "EXP party",
    "Trusts": "Trust party",
    "Raise trusts": "Raise party",
    "Dismiss": "Release trusts",
    "Food": "Daifuku",
    "Echad Ring": "EXP",
    "Caliber Ring": "EXP",
    "Emperor Band": "EXP",
    "Trizek Ring": "CP",
    "Capacity Ring": "CP",
    "Warp Ring": "Home",
    "TP set": "Mummu then TH",
    "Idle set": "Move then Mummu",
    "TH set": "Lock Mummu",
    "Feint": "-eva",
    "Weapons": "Level weapons",
    "Best Waltz": "Best heal",
    "Utsusemi": "Shadows",
    "Haste Samba": "Haste",
    "Drain Samba II": "HP drain",
    "Drain Samba III": "HP drain",
    "Aspir Samba": "MP drain",
    "Aspir Samba II": "MP drain",
    "Box Step": "-def",
    "Quickstep": "-eva",
    "Feather Step": "+crit",
    "Stutter Step": "-m.eva",
    "Reverse": "To TP",
    "Building": "Boost WS",
    "C.Waltz III": "Heal",
    "C.Waltz IV": "Heal",
    "C.Waltz V": "Heal",
    "D.Waltz II": "AoE heal",
    "Divine Waltz": "AoE heal",
    "Healing Waltz": "Erase",
    "Violent": "Stun",
    "Climactic": "Crit",
    "Striking": "DA bonus",
    "Ternary": "Triple",
    "Wild": "Skillchain",
    "Presto": "+FM",
    "No Foot Rise": "+FM",
    "Saber Dance": "DA up",
    "Fan Dance": "-dmg",
    "Contradance": "Boost waltz",
    "Animated": "Provoke",
    "Desperate": "Gravity",
    "Trance": "Free waltz",
    "Spectral Jig": "Sneak Invis",
    "Chocobo Jig II": "Move speed",
    "Assassin's Charge": "Triple hit",
    "Mighty Strikes": "All crits",
    "Sneak Attack": "Crit behind",
    "Trick Attack": "Move hate",
    "SA": "Crit behind",
    "TA": "Move hate",
    "SA Evisc": "Sneak WS",
    "TA Evisc": "Trick WS",
    "SATA": "Sneak Trick WS",
    "Bully": "Intimidate",
    "Perfect Dodge": "Evade",
    "Conspirator": "Party acc",
    "Steal": "Item",
    "Despoil": "Debuff",
    "Mug": "Gil",
    "Flee": "Move speed",
    "Hide": "Drop hate",
    "Collab p1": "Share hate",
    "Collab p2": "Share hate",
    "Accomplice p1": "Take hate",
    "Accomplice p2": "Take hate",
    "Larceny": "Steal buffs",
    "Ranged": "Shoot",
    "Utsu Ni": "Shadows",
    "Utsu Ichi": "Shadows",
    "Yonin": "Tank",
    "Innin": "Rear",
    "Tonko: Ichi": "Invis",
    "Tonko: Ni": "Invis",
    "Monomi": "Sneak",
    "Katon: Ichi": "Fire",
    "Katon: Ni": "Fire",
    "Hyoton: Ichi": "Ice",
    "Hyoton: Ni": "Ice",
    "Huton: Ichi": "Wind",
    "Huton: Ni": "Wind",
    "Doton: Ichi": "Earth",
    "Doton: Ni": "Earth",
    "Raiton: Ichi": "Thunder",
    "Raiton: Ni": "Thunder",
    "Suiton: Ichi": "Water",
    "Suiton: Ni": "Water",
    "Hojo: Ichi": "Slow",
    "Hojo: Ni": "Slow",
    "Kurayami: Ichi": "Blind",
    "Kurayami: Ni": "Blind",
    "Jubaku: Ichi": "Paralyze",
    "Dokumori: Ichi": "Poison",
    "Mijin Gakure": "Sacrifice",
    "Provoke": "Hate",
    "Berserk": "+atk -def",
    "Defender": "+def -atk",
    "Warcry": "Party atk",
    "Aggressor": "+acc -eva",
    "Evisceration": "Physical",
    "Aeolian Edge": "AoE magic",
    "Shark Bite": "Physical",
    "Dancing Edge": "Physical",
    "Rudra's Storm": "Physical",
    "Exenterator": "4-hit",
    "Pyrrhic Kleos": "4-hit",
    "Mandalic Stab": "Physical",
    "Shadowstitch": "Bind",
    "Energy Drain": "Steal MP",
    "Blade: To": "Ice",
    "Blade: Ei": "Dark",
    "Blade: Ku": "5-hit",
    "Blade: Retsu": "Paralyze",
    "Wasp Sting": "Physical",
    "Viper Bite": "Physical",
    "Blade: Jin": "Physical",
    "Blade: Ten": "Physical",
    "Blade: Teki": "Water",
    "Blade: Chi": "Earth",
}
CD = {
    "Sneak Attack": "1m", "SA": "1m", "SA Evisc": "1m",
    "Trick Attack": "1m", "TA": "1m", "TA Evisc": "1m",
    "Feint": "2m", "Bully": "3m",
    "Steal": "5m", "Mug": "5m", "Despoil": "5m", "Flee": "5m", "Hide": "5m",
    "Conspirator": "5m",
    "Collab p1": "1m", "Collab p2": "1m",
    "Accomplice p1": "1m", "Accomplice p2": "1m",
    "Perfect Dodge": "1h", "Larceny": "1h", "Trance": "1h", "Mijin Gakure": "1h",
    "Box Step": "5s", "Quickstep": "5s", "Feather Step": "5s", "Stutter Step": "5s",
    "Haste Samba": "1m", "Drain Samba III": "1m", "Aspir Samba II": "1m",
    "Animated": "30s", "Desperate": "30s", "Violent": "30s",
    "Reverse": "30s", "Building": "30s", "Wild": "30s",
    "Climactic": "1m30s", "Striking": "1m30s", "Ternary": "1m30s",
    "No Foot Rise": "3m", "Saber Dance": "3m", "Fan Dance": "3m", "Contradance": "5m",
    "Drain Samba II": "1m", "Aspir Samba": "1m",
    "Assassin's Charge": "5m", "Mighty Strikes": "1h",
    "C.Waltz III": "10s", "C.Waltz IV": "13s", "C.Waltz V": "16s",
    "Healing Waltz": "8s", "Divine Waltz": "13s", "D.Waltz II": "20s",
    "Spectral Jig": "30s", "Chocobo Jig II": "1m", "Presto": "15s",
    "Provoke": "30s", "Berserk": "5m", "Defender": "3m", "Warcry": "5m", "Aggressor": "5m",
    "Yonin": "3m", "Innin": "3m",
    "Utsu Ni": "45s", "Utsu Ichi": "30s",
    "Tonko: Ichi": "30s", "Tonko: Ni": "45s", "Monomi": "30s",
    "Katon: Ichi": "30s", "Katon: Ni": "45s",
    "Hyoton: Ni": "45s", "Hyoton: Ichi": "30s", "Huton: Ichi": "30s", "Huton: Ni": "45s",
    "Doton: Ni": "45s", "Doton: Ichi": "30s",
    "Raiton: Ichi": "30s", "Raiton: Ni": "45s",
    "Suiton: Ichi": "30s", "Suiton: Ni": "45s",
    "Hojo: Ichi": "30s", "Hojo: Ni": "45s",
    "Kurayami: Ichi": "30s", "Kurayami: Ni": "45s",
    "Jubaku: Ichi": "30s", "Dokumori: Ichi": "30s",
}

# label, command, min level. Omitted level means 1.
DNC = {
    "^": [
        ("EXP", "tru exp"),
        ("Haste Samba", 'input /ja "Haste Samba" <me>', 45),
        ("Box Step", 'input /ja "Box Step" <t>', 23),
        ("Quickstep", 'input /ja "Quickstep" <t>', 20),
        ("Feather Step", 'input /ja "Feather Step" <t>', 83),
        ("Stutter Step", 'input /ja "Stutter Step" <t>', 40),
        ("Reverse", 'input /ja "Reverse Flourish" <me>', 40),
        ("Building", 'input /ja "Building Flourish" <me>', 50),
        ("Wild", 'input /ja "Wild Flourish" <t>', 60),
        ("Presto", 'input /ja "Presto" <me>', 77),
    ],
    "!": [
        ("C.Waltz V", 'input /ja "Curing Waltz V" <stpc>', 87),
        ("C.Waltz IV", 'input /ja "Curing Waltz IV" <stpc>', 70),
        ("C.Waltz III", 'input /ja "Curing Waltz III" <stpc>', 45),
        ("D.Waltz II", 'input /ja "Divine Waltz II" <me>', 78),
        ("Healing Waltz", 'input /ja "Healing Waltz" <stpc>', 35),
        ("Violent", 'input /ja "Violent Flourish" <t>', 45),
        ("Climactic", 'input /ja "Climactic Flourish" <me>', 80),
        ("Striking", 'input /ja "Striking Flourish" <me>', 89),
        ("Evisceration", 'input /ws "Evisceration" <t>'),
        ("Dancing Edge", 'input /ws "Dancing Edge" <t>'),
    ],
    "~^": [
        ("Spectral Jig", 'input /ja "Spectral Jig" <me>', 25),
        ("Chocobo Jig II", 'input /ja "Chocobo Jig II" <me>', 70),
        ("Echad Ring", "gs c echad"),
        ("Caliber Ring", "gs c caliber"),
        ("Emperor Band", "gs c emperor"),
        ("Warp Ring", "gs c warp"),
        ("Trusts", "tru"),
        ("Raise trusts", "tru raise"),
        ("Aspir Samba II", 'input /ja "Aspir Samba II" <me>', 60),
        ("Drain Samba III", 'input /ja "Drain Samba III" <me>', 65),
    ],
    "~!": [
        ("Animated", 'input /ja "Animated Flourish" <t>', 20),
        ("Desperate", 'input /ja "Desperate Flourish" <t>', 30),
        ("Divine Waltz", 'input /ja "Divine Waltz" <me>', 25),
        ("Aeolian Edge", 'input /ws "Aeolian Edge" <t>'),
        ("Shark Bite", 'input /ws "Shark Bite" <t>'),
        ("Trance", 'input /ja "Trance" <me>'),
        ("Food", 'input /item "Grape Daifuku" <me>'),
        ("TP set", "gs c toggle TP set"),
        ("Idle set", "gs c toggle Idle set"),
        ("Dismiss", "input /refa all"),
    ],
    "fkeys": {
        "!f1": ("Weapons", "gs c weapons"),
        "!f2": ("Best Waltz", "gs c waltz"),
        "!f3": ("TP set", "gs c toggle TP set"),
        "!f4": ("Idle set", "gs c toggle Idle set"),
        "!f5": ("Utsusemi", "gs c utsu"),
        "!f6": ("Ternary", 'input /ja "Ternary Flourish" <me>'),
        "!f7": ("Contradance", 'input /ja "Contradance" <me>'),
        "!f8": ("No Foot Rise", 'input /ja "No Foot Rise" <me>'),
        "!f9": ("Saber Dance", 'input /ja "Saber Dance" <me>'),
        "!f10": ("Fan Dance", 'input /ja "Fan Dance" <me>'),
        "!f11": ("Exenterator", 'input /ws "Exenterator" <t>'),
        "!f12": ("Pyrrhic Kleos", 'input /ws "Pyrrhic Kleos" <t>'),
        "^f1": ("Rudra's Storm", 'input /ws "Rudra\'s Storm" <t>'),
        "^f2": ("Shadowstitch", 'input /ws "Shadowstitch" <t>'),
        "^f3": ("Energy Drain", 'input /ws "Energy Drain" <t>'),
    },
}
THF = {
    "^": [
        ("Feint", 'input /ja "Feint" <t>', 75),
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
    "fkeys": {
        "!f8": ("SATA", "gs c sata"),
        "!f9": ("TP set", "gs c toggle TP set"),
        "!f10": ("Idle set", "gs c toggle Idle set"),
        "!f11": ("TH set", "gs c th"),
    },
}
NIN = {
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
    "fkeys": {
        "!f1": ("Hyoton: Ichi", 'input /ma "Hyoton: Ichi" <t>'),
        "!f2": ("Doton: Ichi", 'input /ma "Doton: Ichi" <t>'),
        "!f3": ("Tonko: Ichi", 'input /ma "Tonko: Ichi" <me>'),
    },
}
JOBS = {"DNC": DNC, "THF": THF, "NIN": NIN}
SUB = {
    "THF": [
        ("SA", 'input /ja "Sneak Attack" <me>', 15),
        ("TA", 'input /ja "Trick Attack" <me>', 30),
        ("SA Evisc", "gs c saevisc", 15),
        ("TA Evisc", "gs c taevisc", 30),
        ("Steal", 'input /ja "Steal" <t>', 5),
        ("Mug", 'input /ja "Mug" <t>', 35),
        ("Flee", 'input /ja "Flee" <me>', 25),
        ("Hide", 'input /ja "Hide" <me>', 45),
        ("Perfect Dodge", 'input /ja "Perfect Dodge" <me>', 1),
    ],
    "NIN": [
        ("Utsu Ni", 'input /ma "Utsusemi: Ni" <me>', 37),
        ("Utsu Ichi", 'input /ma "Utsusemi: Ichi" <me>', 12),
        ("Yonin", 'input /ja "Yonin" <me>', 40),
        ("Innin", 'input /ja "Innin" <me>', 40),
        ("Tonko: Ni", 'input /ma "Tonko: Ni" <me>', 34),
        ("Monomi", 'input /ma "Monomi: Ichi" <me>', 25),
        ("Katon: Ni", 'input /ma "Katon: Ni" <t>', 40),
        ("Huton: Ni", 'input /ma "Huton: Ni" <t>', 40),
        ("Hojo: Ni", 'input /ma "Hojo: Ni" <t>', 48),
        ("Kurayami: Ni", 'input /ma "Kurayami: Ni" <t>', 44),
    ],
    "DNC": [
        ("Box Step", 'input /ja "Box Step" <t>', 23),
        ("Quickstep", 'input /ja "Quickstep" <t>', 20),
        ("Haste Samba", 'input /ja "Haste Samba" <me>', 45),
        ("Animated", 'input /ja "Animated Flourish" <t>', 20),
        ("Desperate", 'input /ja "Desperate Flourish" <t>', 30),
        ("Reverse", 'input /ja "Reverse Flourish" <me>', 40),
        ("Violent", 'input /ja "Violent Flourish" <t>', 45),
        ("C.Waltz III", 'input /ja "Curing Waltz III" <stpc>', 45),
        ("Divine Waltz", 'input /ja "Divine Waltz" <me>', 25),
        ("Healing Waltz", 'input /ja "Healing Waltz" <stpc>', 35),
    ],
    "WAR": [
        ("Provoke", 'input /ja "Provoke" <t>', 5),
        ("Berserk", 'input /ja "Berserk" <me>', 15),
        ("Defender", 'input /ja "Defender" <me>', 25),
        ("Warcry", 'input /ja "Warcry" <me>', 35),
        ("Aggressor", 'input /ja "Aggressor" <me>', 45),
        ("Mighty Strikes", 'input /ja "Mighty Strikes" <me>', 1),
    ],
}
EXTRA = {
    "DNC": [
        ("Stutter Step", 'input /ja "Stutter Step" <t>', 40),
        ("Drain Samba II", 'input /ja "Drain Samba II" <me>', 35),
        ("Aspir Samba", 'input /ja "Aspir Samba" <me>', 25),
        ("Spectral Jig", 'input /ja "Spectral Jig" <me>', 25),
    ],
    "NIN": [
        ("Hyoton: Ni", 'input /ma "Hyoton: Ni" <t>', 40),
        ("Doton: Ni", 'input /ma "Doton: Ni" <t>', 40),
        ("Raiton: Ni", 'input /ma "Raiton: Ni" <t>', 40),
        ("Suiton: Ni", 'input /ma "Suiton: Ni" <t>', 40),
        ("Dokumori: Ichi", 'input /ma "Dokumori: Ichi" <t>', 27),
        ("Jubaku: Ichi", 'input /ma "Jubaku: Ichi" <t>', 30),
        ("Katon: Ichi", 'input /ma "Katon: Ichi" <t>', 15),
        ("Hyoton: Ichi", 'input /ma "Hyoton: Ichi" <t>', 15),
        ("Doton: Ichi", 'input /ma "Doton: Ichi" <t>', 15),
        ("Raiton: Ichi", 'input /ma "Raiton: Ichi" <t>', 15),
        ("Suiton: Ichi", 'input /ma "Suiton: Ichi" <t>', 15),
        ("Huton: Ichi", 'input /ma "Huton: Ichi" <t>', 15),
        ("Tonko: Ichi", 'input /ma "Tonko: Ichi" <me>', 9),
    ],
}
COMBOS = [
    ("DNC", "THF"),
    ("DNC", None),
    ("DNC", "NIN"),
    ("DNC", "WAR"),
    ("THF", None),
    ("THF", "DNC"),
    ("THF", "WAR"),
    ("NIN", None),
    ("NIN", "DNC"),
    ("NIN", "THF"),
    ("NIN", "WAR"),
]


def lvl_of(entry):
    return entry[2] if len(entry) > 2 else 1


def split_key(full):
    for prefix in PREFIXES:
        if full.startswith(prefix):
            return prefix, full[len(prefix):]
    raise ValueError(full)


def book_for(main, sub, prefix):
    book = MACRO_BOOKS[main]
    combos = COMBO_BOOK.get(main, {})
    dnc_book = combos.get("DNC") if sub == "DNC" else None
    if dnc_book and prefix in ("^", "!"):
        return dnc_book
    if dnc_book and prefix == "^!":
        return book, 1
    set_no = MACRO_SETS[prefix]
    if prefix == "^!" and sub and sub in combos:
        return combos[sub]
    return book, set_no


def combo_title(main, sub):
    if sub:
        return f"{JOB_NAME[main]} / {JOB_NAME[sub]}"
    return JOB_NAME[main]


def sheet_name(main, sub):
    name = JOB_NAME[main] if not sub else f"{JOB_NAME[main]} {JOB_NAME[sub]}"
    return name[:31]


def first_free(used):
    for prefix in F_SCAN:
        for fid in FIDS:
            key = prefix + fid
            if key not in used:
                return key
    return None


def build(main, sub):
    """Return (mod, key) -> record. key is '1' or 'f1'."""
    job = JOBS[main]
    main_lvl = LEVELS[main]
    sub_lvl = LEVELS[sub] if sub else 0
    binds = {}
    used_f = set(job["fkeys"])

    def put(prefix, key, entry, gated):
        del gated
        if prefix == "^" and sub == "DNC":
            level = sub_lvl
        elif prefix == "^!" and sub and sub != "DNC":
            level = sub_lvl
        else:
            level = main_lvl
        if level < lvl_of(entry):
            return
        label, command = entry[0], entry[1]
        binds[(prefix, key)] = {
            "label": label,
            "desc": DESC.get(label, ""),
            "cd": CD.get(label, ""),
            "min": lvl_of(entry) if len(entry) > 2 else "",
            "command": command,
        }

    rows = {k: v for k, v in job.items() if k != "fkeys"}
    if sub == "DNC":
        for prefix, entries in rows.items():
            target = "^!" if prefix == "^" else prefix
            for i, entry in enumerate(entries):
                put(target, KEYS[i], entry, False)
        for i, entry in enumerate(SUB["DNC"]):
            put("^", KEYS[i], entry, False)
    else:
        for prefix, entries in rows.items():
            for i, entry in enumerate(entries):
                put(prefix, KEYS[i], entry, False)
        if sub:
            for i, entry in enumerate(SUB[sub]):
                put("^!", KEYS[i], entry, False)

    for full, entry in job["fkeys"].items():
        prefix, key = split_key(full)
        label, command = entry
        binds[(prefix, key)] = {
            "label": label,
            "desc": DESC.get(label, ""),
            "cd": CD.get(label, ""),
            "min": "",
            "command": command,
        }

    if sub == "DNC":
        row = rows["~!"]
        if len(row) < len(KEYS):
            key = "~!" + KEYS[len(row)]
            prefix, button = split_key(key)
        else:
            key = first_free(used_f)
            used_f.add(key)
            prefix, button = split_key(key)
        binds[(prefix, button)] = {
            "label": "Trance",
            "desc": DESC["Trance"],
            "cd": CD["Trance"],
            "min": 1,
            "command": 'input /ja "Trance" <me>',
        }

    if sub in EXTRA:
        for entry in EXTRA[sub]:
            if sub_lvl < lvl_of(entry):
                continue
            key = first_free(used_f)
            used_f.add(key)
            prefix, button = split_key(key)
            label, command = entry[0], entry[1]
            binds[(prefix, button)] = {
                "label": label,
                "desc": DESC.get(label, ""),
                "cd": CD.get(label, ""),
                "min": lvl_of(entry),
                "command": command,
            }
    return binds


def col_letter(n):
    s = ""
    while n:
        n, r = divmod(n - 1, 26)
        s = chr(65 + r) + s
    return s


def cell(ref, text, style):
    if text is None:
        text = ""
    text = str(text)
    if text == "":
        return f'<c r="{ref}" s="{style}"/>'
    attr = ' xml:space="preserve"' if text[:1].isspace() or text[-1:].isspace() or "\n" in text else ""
    return f'<c r="{ref}" t="inlineStr" s="{style}"><is><t{attr}>{escape(text)}</t></is></c>'


STYLES = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <fonts count="4">
    <font><sz val="11"/><name val="Calibri"/></font>
    <font><b/><sz val="16"/><name val="Calibri"/><color rgb="FF1B3A4B"/></font>
    <font><b/><sz val="11"/><name val="Calibri"/><color rgb="FFFFFFFF"/></font>
    <font><b/><sz val="11"/><name val="Calibri"/></font>
  </fonts>
  <fills count="5">
    <fill><patternFill patternType="none"/></fill>
    <fill><patternFill patternType="gray125"/></fill>
    <fill><patternFill patternType="solid"><fgColor rgb="FF1B3A4B"/></patternFill></fill>
    <fill><patternFill patternType="solid"><fgColor rgb="FFF7F4EE"/></patternFill></fill>
    <fill><patternFill patternType="solid"><fgColor rgb="FFE7EEF2"/></patternFill></fill>
  </fills>
  <borders count="2">
    <border><left/><right/><top/><bottom/><diagonal/></border>
    <border>
      <left style="thin"><color rgb="FFD5D0C8"/></left>
      <right style="thin"><color rgb="FFD5D0C8"/></right>
      <top style="thin"><color rgb="FFD5D0C8"/></top>
      <bottom style="thin"><color rgb="FFD5D0C8"/></bottom>
      <diagonal/>
    </border>
  </borders>
  <cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>
  <cellXfs count="6">
    <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>
    <xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/>
    <xf numFmtId="0" fontId="2" fillId="2" borderId="1" xfId="0" applyFont="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment horizontal="center" vertical="center" wrapText="1"/></xf>
    <xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyBorder="1" applyAlignment="1"><alignment vertical="center" wrapText="1"/></xf>
    <xf numFmtId="0" fontId="3" fillId="3" borderId="1" xfId="0" applyFont="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment horizontal="center" vertical="center"/></xf>
    <xf numFmtId="0" fontId="3" fillId="4" borderId="1" xfId="0" applyFont="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment vertical="center" wrapText="1"/></xf>
  </cellXfs>
</styleSheet>
"""


SUBHEADERS = ("Action", "Description", "Recast")
GRID_LAST = col_letter(1 + len(MODS) * len(SUBHEADERS))


def grid_headers(r):
    top = [cell(f"A{r}", "Key", 2)]
    sub = [cell(f"A{r + 1}", "", 2)]
    merges = [f"A{r}:A{r + 1}"]
    col = 2
    for _, name in MODS:
        start = col_letter(col)
        end = col_letter(col + 2)
        top.append(cell(f"{start}{r}", name, 2))
        top.append(cell(f"{col_letter(col + 1)}{r}", "", 2))
        top.append(cell(f"{end}{r}", "", 2))
        merges.append(f"{start}{r}:{end}{r}")
        for header in SUBHEADERS:
            sub.append(cell(f"{col_letter(col)}{r + 1}", header, 2))
            col += 1
    rows = (
        f'<row r="{r}" ht="20" customHeight="1">{"".join(top)}</row>'
        f'<row r="{r + 1}" ht="20" customHeight="1">{"".join(sub)}</row>'
    )
    return rows, merges


def grid_data(r, label, key_id, binds):
    bits = [cell(f"A{r}", label, 4)]
    col = 2
    for prefix, _ in MODS:
        rec = binds.get((prefix, key_id))
        values = (rec["label"], rec["desc"], rec["cd"]) if rec else ("", "", "")
        for value in values:
            bits.append(cell(f"{col_letter(col)}{r}", value, 3))
            col += 1
    return f'<row r="{r}" ht="18" customHeight="1">{"".join(bits)}</row>'


def grid_sheet(main, sub, binds):
    title = combo_title(main, sub)
    if sub == "DNC":
        opened = COMBO_BOOK[main]["DNC"][0]
        subtitle = f"Opens book {opened}. Dancer 94, Thief 99, Ninja 70, subjob 49."
    elif sub:
        opened = MACRO_BOOKS[main]
        palette = COMBO_BOOK[main][sub][0]
        subtitle = (
            f"Opens book {opened}. Ctrl+Alt macros are book {palette}. "
            "Dancer 94, Thief 99, Ninja 70, subjob 49."
        )
    else:
        subtitle = f"Opens book {MACRO_BOOKS[main]}. Dancer 94, Thief 99, Ninja 70."
    merges = [f"A1:{GRID_LAST}1", f"A2:{GRID_LAST}2"]
    rows_xml = [
        f'<row r="1" ht="22" customHeight="1">{cell("A1", title, 1)}</row>',
        f'<row r="2" ht="18" customHeight="1">{cell("A2", subtitle, 0)}</row>',
    ]
    header_xml, header_merges = grid_headers(3)
    rows_xml.append(header_xml)
    merges.extend(header_merges)
    r = 5
    for key in KEYS:
        rows_xml.append(grid_data(r, key, key, binds))
        r += 1
    r += 1
    rows_xml.append(
        f'<row r="{r}" ht="20" customHeight="1">{cell(f"A{r}", "Function keys", 5)}</row>'
    )
    merges.append(f"A{r}:{GRID_LAST}{r}")
    r += 1
    header_xml, header_merges = grid_headers(r)
    rows_xml.append(header_xml)
    merges.extend(header_merges)
    r += 2
    for fid in FIDS:
        rows_xml.append(grid_data(r, fid.upper(), fid, binds))
        r += 1
    last = r - 1
    cols = ['<col min="1" max="1" width="12" customWidth="1"/>']
    for i in range(len(MODS)):
        start = 2 + i * 3
        cols.append(f'<col min="{start}" max="{start}" width="22" customWidth="1"/>')
        cols.append(f'<col min="{start + 1}" max="{start + 1}" width="16" customWidth="1"/>')
        cols.append(f'<col min="{start + 2}" max="{start + 2}" width="10" customWidth="1"/>')
    merge_xml = "".join(f'<mergeCell ref="{ref}"/>' for ref in merges)
    return f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <dimension ref="A1:{GRID_LAST}{last}"/>
  <sheetViews><sheetView workbookViewId="0"><pane ySplit="4" topLeftCell="A5" activePane="bottomLeft" state="frozen"/></sheetView></sheetViews>
  <cols>{"".join(cols)}</cols>
  <sheetData>{"".join(rows_xml)}</sheetData>
  <mergeCells count="{len(merges)}">{merge_xml}</mergeCells>
</worksheet>
"""


def all_sheet(records):
    headers = ["Combo", "Book", "Set", "Modifier", "Key", "Label", "Description", "Recast", "Min level", "Command"]
    rows_xml = [
        f'<row r="1" ht="20" customHeight="1">{"".join(cell(f"{col_letter(i+1)}1", h, 2) for i, h in enumerate(headers))}</row>'
    ]
    for n, rec in enumerate(records, start=2):
        vals = [
            rec["combo"], rec["book"], rec["set"], rec["modifier"], rec["key"],
            rec["label"], rec["desc"], rec["cd"], rec["min"], rec["command"],
        ]
        bits = "".join(cell(f"{col_letter(i+1)}{n}", v, 3) for i, v in enumerate(vals))
        rows_xml.append(f'<row r="{n}">{bits}</row>')
    last = len(records) + 1
    return f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <dimension ref="A1:J{last}"/>
  <sheetViews><sheetView workbookViewId="0"><pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/></sheetView></sheetViews>
  <cols>
    <col min="1" max="1" width="22" customWidth="1"/>
    <col min="2" max="3" width="8" customWidth="1"/>
    <col min="4" max="4" width="14" customWidth="1"/>
    <col min="5" max="5" width="8" customWidth="1"/>
    <col min="6" max="6" width="20" customWidth="1"/>
    <col min="7" max="8" width="16" customWidth="1"/>
    <col min="9" max="9" width="12" customWidth="1"/>
    <col min="10" max="10" width="46" customWidth="1"/>
  </cols>
  <sheetData>{"".join(rows_xml)}</sheetData>
  <autoFilter ref="A1:J{last}"/>
</worksheet>
"""


def notes_sheet():
    lines = [
        "Keybinds",
        "Each job sheet is the keyboard for that combo. Every modifier has Action, Description, and Recast columns. The All sheet is the same binds in filterable rows.",
        "Levels used: Dancer 94, Thief 99, Ninja 70, subjob 49. A key below its min level stays blank and does not shift the row.",
        "Function keys are Windower binds. They are not written into the macro books.",
        "While Dancer is the subjob, Ctrl is the Dancer row and the main job Ctrl row moves to Ctrl+Alt.",
        "Trance on Dancer main is Alt+Shift+6. Subjob Trance takes the first free function key.",
        "On Dancer / Ninja, the extra ninjutsu starts at Ctrl+F4 and continues on Alt+Shift+F after Ctrl+F12.",
        "On Thief / Dancer, Trance is Alt+F1, then Stutter Step, Drain Samba II, Aspir Samba, and Spectral Jig on Alt+F2 through Alt+F5.",
        "Description and recast match the overlay. Recast is the base time, before merits.",
    ]
    rows = []
    for i, line in enumerate(lines, start=1):
        style = 1 if i == 1 else 0
        rows.append(f'<row r="{i}" ht="18" customHeight="1">{cell(f"A{i}", line, style)}</row>')
    return f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <dimension ref="A1:A{len(lines)}"/>
  <cols><col min="1" max="1" width="120" customWidth="1"/></cols>
  <sheetData>{"".join(rows)}</sheetData>
</worksheet>
"""


def main():
    sheets = []
    flat = []
    key_order = {k: i for i, k in enumerate(KEYS + FIDS)}
    mod_order = {p: i for i, (p, _) in enumerate(MODS)}
    for main, sub in COMBOS:
        binds = build(main, sub)
        name = sheet_name(main, sub)
        sheets.append((name, grid_sheet(main, sub, binds)))
        for (prefix, key), rec in binds.items():
            book, set_no = ("", "")
            if not key.startswith("f"):
                book, set_no = book_for(main, sub, prefix)
            flat.append({
                "combo": combo_title(main, sub),
                "book": book,
                "set": set_no,
                "modifier": MOD_NAME[prefix],
                "key": key.upper() if key.startswith("f") else key,
                "sort_key": key_order[key],
                "sort_mod": mod_order[prefix],
                "label": rec["label"],
                "desc": rec["desc"],
                "cd": rec["cd"],
                "min": rec["min"],
                "command": rec["command"],
            })
    combo_order = {combo_title(m, s): i for i, (m, s) in enumerate(COMBOS)}
    flat.sort(key=lambda r: (combo_order[r["combo"]], r["sort_mod"], r["sort_key"]))
    sheets.append(("All", all_sheet(flat)))
    sheets.append(("Notes", notes_sheet()))

    overrides = []
    workbook_sheets = []
    rels = []
    for i, (name, _) in enumerate(sheets, start=1):
        workbook_sheets.append(
            f'<sheet name="{escape(name)}" sheetId="{i}" r:id="rId{i}"/>'
        )
        rels.append(
            f'<Relationship Id="rId{i}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet{i}.xml"/>'
        )
    style_id = len(sheets) + 1
    rels.append(
        f'<Relationship Id="rId{style_id}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
    )
    workbook = f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheets>{"".join(workbook_sheets)}</sheets>
</workbook>
"""
    workbook_rels = f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">{"".join(rels)}</Relationships>
"""
    root_rels = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
</Relationships>
"""
    content = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
  <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
"""
    for i in range(1, len(sheets) + 1):
        content += f'  <Override PartName="/xl/worksheets/sheet{i}.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>\n'
    content += "</Types>"

    if OUT.exists():
        OUT.unlink()
    with zipfile.ZipFile(OUT, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        zf.writestr("[Content_Types].xml", content)
        zf.writestr("_rels/.rels", root_rels)
        zf.writestr("xl/workbook.xml", workbook)
        zf.writestr("xl/_rels/workbook.xml.rels", workbook_rels)
        zf.writestr("xl/styles.xml", STYLES)
        for i, (_, xml) in enumerate(sheets, start=1):
            zf.writestr(f"xl/worksheets/sheet{i}.xml", xml)
    print(f"wrote {OUT} ({len(flat)} binds)")


if __name__ == "__main__":
    main()
