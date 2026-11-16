# Keybinds: THF / DNC / NIN

Number-row keybinds replace in-game macros. GearSwap sets them when a job loads and clears them on job change. Source of truth: the `set_binds` tables in `addons/GearSwap/data/THF.lua`, `DNC.lua`, `NIN.lua`, and the shared logic in `binds.lua`.

**Maintained book:** **1 THF/DNC** (set 1 Ctrl = Dancer, Alt = openers; set 2 Ctrl = utility, Alt = Aeolian). Books 2–20 are blank. DNC-main and NIN-main books come back when those jobs hit 99. Regenerate with `python windower/scripts/sync_macro_names.py` (close FFXI first). It writes the repo copy and the Steam client's `FFXINA\SquareEnix\FINAL FANTASY XI\USER\158678d`.

| Modifier | Use (THF) |
| --- | --- |
| Ctrl 1-0 | Set 1 Dancer sub row |
| Alt 1-0 | Set 1 openers + THF tools |
| Ctrl+Shift 1-0 | Set 2 utility (keyboard) |
| Alt+Shift 1 | Set 2 Aeolian Edge (keyboard) |
| Alt+F1 | TP set toggle |
| Alt+F2 | Idle set toggle (Pants → Idle) |
| Alt+F3 | Force TH set |

In-game: switch to **macro set 2** for the utility palette (same rows). Building Flourish / Chocobo Jig II wait for DNC main (sub cap 49).

These keys take over the in-game Ctrl/Alt macro palettes. Hold a modifier combo to see its labels in the `keylabels` overlay (`addons/keylabels`, loaded from `scripts/init.txt`); `//kl pos <x> <y>` moves it, and `//kl refresh` re-pulls labels from GearSwap if the overlay comes up empty.

`//gs c binds` re-binds for your current level and prints every key in chat. Run it after leveling: actions above your level stay unbound until then.

Controller uses the native gamepad + in-game Ctrl/Alt books (no padmacros). Hold **LT** for the Ctrl overlay, **RT** for Alt (keylabels only). Keyboard modifiers always win over triggers so the overlay matches the in-game macro bar. LB tap for autorun can stay in the Steam layout when you use it.

Alt+F1–F3 (TP / Idle / TH) are GearSwap binds only — they show in the keylabels overlay, not on the in-game 1–0 macro bar.

## THF / DNC (book 1)

| Key | Ctrl (Dancer) | Alt (Openers) |
| --- | --- | --- |
| 1 | Box Step | Evisceration (WS only) |
| 2 | Quickstep | SA opener (SA → Feint → WS; skip CDs) |
| 3 | Haste Samba | TA opener (TA → Feint → WS; skip CDs) |
| 4 | Stutter Step | SATA (SA → TA → Feint → WS; skip CDs) |
| 5 | Reverse Flourish | Feint |
| 6 | Violent Flourish | Hide |
| 7 | Curing Waltz III | Despoil (TH tag) |
| 8 | Healing Waltz | Conspirator |
| 9 | Divine Waltz | Perfect Dodge |
| 0 | Animated Flourish | Flee |

### Set 2 (utility)

| Key | Ctrl | Alt |
| --- | --- | --- |
| 1 | Spectral Jig | Aeolian Edge |
| 2 | Drain Samba II | |
| 3 | Aspir Samba | |
| 4 | Assassin's Charge | |
| 5 | Collaborator (`<stpt>`) | |
| 6 | Accomplice (`<stpt>`) | |
| 7 | Bully | |
| 8 | Steal | |
| 9 | Mug | |
| 0 | Wild Flourish | |

Despoil is the JA TH tag on set 1; Alt+F3 still toggles force TH gear when `sets.TP.TH` has real TH pieces (e.g. Chaac Belt). SATA is Alt+4 on set 1 only (not an F-key).

## DNC (deferred)

Dancer-main macro book is not maintained until DNC 99. The `DNC.lua` GearSwap file still has older binds for leveling.

## NIN (deferred)

Ninja-main macro book is not maintained until NIN 99. The `NIN.lua` GearSwap file still has older binds for leveling.
