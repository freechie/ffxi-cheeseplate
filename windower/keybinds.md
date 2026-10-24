# Keybinds: THF / DNC / NIN

Number-row keybinds replace in-game macros. GearSwap sets them when a job loads and clears them on job change. Source of truth: the `set_binds` tables in `addons/GearSwap/data/THF.lua`, `DNC.lua`, `NIN.lua`, and the shared logic in `binds.lua`.

Official macro books are alphabetical and sequential: **1 DNC**, **2 DNC/NIN**, **3 DNC/THF**, **4 DNC/WAR**, **5 NIN**, **6 NIN/DNC**, **7 NIN/THF**, **8 NIN/WAR**, **9 PUP/DNC**, **10 THF**, **11 THF/WAR**. Main-job books use set 1 (Ctrl/Alt) and set 2 (Ctrl+Shift/Alt+Shift). Each combo book is set 1, and that subjob row is not copied into any other book. Regenerate with `python windower/scripts/sync_macro_names.py` (close FFXI first). It writes the repo copy and the Steam client's `FFXINA\SquareEnix\FINAL FANTASY XI\USER\158678d`.

| Modifier | Use |
| --- | --- |
| Ctrl 1-0 | Main combat row |
| Alt 1-0 | Main second row |
| Ctrl+Shift 1-0 | Utility (rings, warp, trusts) |
| Alt+Shift 1-0 | Utility, second row |
| Ctrl+Alt 1-0 | Subjob row, picked from your current subjob |

These keys take over the in-game Ctrl/Alt macro palettes. Hold a modifier combo to see its labels in the `keylabels` overlay (`addons/keylabels`, loaded from `scripts/init.txt`); `//kl pos <x> <y>` moves it, and `//kl refresh` re-pulls labels from GearSwap if the overlay comes up empty. Each heading shows the matching in-game macro book and set. DNC also uses Alt+F1 weapons, Alt+F2 waltz, Alt+F3 TP, Alt+F4 idle, Alt+F5 utsu (Haste Samba is Ctrl+2 only).

`//gs c binds` re-binds for your current level and prints every key in chat. Run it after leveling: actions above your level stay unbound until then.

Ring keys lock the ring slot in GearSwap, equip the ring, wait 11 seconds, use it, then unlock. Food is `Grape Daifuku`; change it in the job file.

## DNC

| Key | Ctrl | Alt | Ctrl+Shift | Alt+Shift |
| --- | --- | --- | --- | --- |
| 1 | EXP trusts (Kupofried) | Curing Waltz V | Spectral Jig | Animated Flourish |
| 2 | Haste Samba | Curing Waltz IV | Chocobo Jig II | Desperate Flourish |
| 3 | Box Step | Curing Waltz III | Echad Ring | Divine Waltz |
| 4 | Quickstep | Divine Waltz II | Caliber Ring | Aeolian Edge |
| 5 | Feather Step | Healing Waltz | Emperor Band | Shark Bite |
| 6 | Stutter Step | Violent Flourish | Warp Ring | Trance |
| 7 | Reverse Flourish | Climactic Flourish | Trusts (default) | Food |
| 8 | Building Flourish | Striking Flourish | Raise trusts | TP set toggle |
| 9 | Evisceration | Wild Flourish | Aspir Samba II | Idle set toggle |
| 0 | Dancing Edge | Presto | Drain Samba III | Dismiss trusts |

## THF

| Key | Ctrl | Alt | Ctrl+Shift | Alt+Shift |
| --- | --- | --- | --- | --- |
| 1 | Trusts (default) | Steal | Trizek Ring | Ranged attack |
| 2 | Sneak Attack | Despoil | Capacity Ring | Wasp Sting |
| 3 | Trick Attack | Mug | Warp Ring | Viper Bite |
| 4 | Bully | Flee | Food | Idle set toggle |
| 5 | Evisceration | Hide | Raise trusts | |
| 6 | Aeolian Edge | Collaborator p1 | EXP trusts (Kupofried) | |
| 7 | Shark Bite | Accomplice p1 | TH set toggle | |
| 8 | Dancing Edge | Larceny | SATA (SA, TA, Evisceration) | |
| 9 | Perfect Dodge | Collaborator p2 | TP set toggle | |
| 0 | Conspirator | Accomplice p2 | Dismiss trusts | |

## NIN

`NIN.lua` only sets keybinds; it has no gear sets yet.

| Key | Ctrl | Alt | Ctrl+Shift | Alt+Shift |
| --- | --- | --- | --- | --- |
| 1 | EXP trusts (Kupofried) | Katon: Ni | Monomi: Ichi | Hojo: Ni |
| 2 | Utsusemi: Ni | Hyoton: Ni | Tonko: Ni | Kurayami: Ni |
| 3 | Utsusemi: Ichi | Huton: Ni | Echad Ring | Jubaku: Ichi |
| 4 | Yonin | Doton: Ni | Caliber Ring | Dokumori: Ichi |
| 5 | Innin | Raiton: Ni | Warp Ring | Hojo: Ichi |
| 6 | Blade: Jin | Suiton: Ni | Food | Kurayami: Ichi |
| 7 | Blade: Ten | Katon: Ichi | Raise trusts | |
| 8 | Blade: Teki | Raiton: Ichi | Trusts (default) | |
| 9 | Blade: Chi | Suiton: Ichi | Emperor Band | |
| 0 | Mijin Gakure | Huton: Ichi | Dismiss trusts | |

## Subjob palettes

Ctrl+Alt still casts the row for the subjob you have on. Switch to that book to see the same macros on the palette.

| Book | Name | Set |
| --- | --- | --- |
| 1 | DNC | 1 and 2 |
| 2 | DNC/NIN | 1 |
| 3 | DNC/THF | 1 |
| 4 | DNC/WAR | 1 |
| 5 | NIN | 1 and 2 |
| 6 | NIN/DNC | 1 |
| 7 | NIN/THF | 1 |
| 8 | NIN/WAR | 1 |
| 9 | PUP/DNC | 1 |
| 10 | THF | 1 and 2 |
| 11 | THF/WAR | 1 |

## Subjob row (Ctrl+Alt)

| Key | /THF | /NIN | /DNC | /WAR |
| --- | --- | --- | --- | --- |
| 1 | Sneak Attack | Utsusemi: Ni | Curing Waltz III | Provoke |
| 2 | Trick Attack | Utsusemi: Ichi | Curing Waltz II | Berserk |
| 3 | SA + Evisceration | Yonin | Haste Samba | Defender |
| 4 | TA + Evisceration | Innin | Drain Samba | Warcry |
| 5 | Steal | Tonko: Ichi | Box Step | Aggressor |
| 6 | Mug | Monomi: Ichi | Quickstep | |
| 7 | Flee | Katon: Ichi | Animated Flourish | |
| 8 | Hide | Raiton: Ichi | Divine Waltz | |
| 9 | | | Healing Waltz | |
| 0 | | | Spectral Jig | |
