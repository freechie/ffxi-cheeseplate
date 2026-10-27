# Keybinds: THF / DNC / NIN

Number-row keybinds replace in-game macros. GearSwap sets them when a job loads and clears them on job change. Source of truth: the `set_binds` tables in `addons/GearSwap/data/THF.lua`, `DNC.lua`, `NIN.lua`, and the shared logic in `binds.lua`.

Official macro books are alphabetical and sequential: **1 DNC**, **2 DNC/NIN**, **3 DNC/THF**, **4 DNC/WAR**, **5 NIN**, **6 NIN/DNC**, **7 NIN/THF**, **8 NIN/WAR**, **9 PUP/DNC**, **10 THF**, **11 THF/DNC**, **12 THF/WAR**. Main-job books use set 1 (Ctrl/Alt) and set 2 (Ctrl+Shift/Alt+Shift). Each combo book is set 1, and that subjob row is not copied into any other book. While Dancer is subbed, GearSwap opens the combo book so Ctrl shows the Dancer row and Alt shows the main job's Alt row. Regenerate with `python windower/scripts/sync_macro_names.py` (close FFXI first). It writes the repo copy and the Steam client's `FFXINA\SquareEnix\FINAL FANTASY XI\USER\158678d`.

| Modifier | Use |
| --- | --- |
| Ctrl 1-0 | Main combat row. While Dancer is subbed, this is the Dancer row |
| Alt 1-0 | Main second row. Weapon skills that used to be on Ctrl are on this row |
| Ctrl+Shift 1-0 | Utility (rings, warp, trusts) |
| Alt+Shift 1-0 | Utility, second row. While Dancer is subbed, Trance uses the first free function key |
| Ctrl+Alt 1-0 | Subjob row. While Dancer is subbed, this is the main combat row Ctrl used to hold |

These keys take over the in-game Ctrl/Alt macro palettes. Hold a modifier combo to see its labels in the `keylabels` overlay (`addons/keylabels`, loaded from `scripts/init.txt`); `//kl pos <x> <y>` moves it, and `//kl refresh` re-pulls labels from GearSwap if the overlay comes up empty. Each heading shows the matching in-game macro book and set. DNC also uses Alt+F1 weapons, Alt+F2 waltz, Alt+F3 TP, Alt+F4 idle, Alt+F5 utsu (Haste Samba is Ctrl+2 only).

`//gs c binds` re-binds for your current level and prints every key in chat. Run it after leveling: actions above your level stay unbound until then.

Ring keys lock the ring slot in GearSwap, equip the ring, wait 11 seconds, use it, then unlock. Food is `Grape Daifuku`; change it in the job file.

## DNC

| Key | Ctrl | Alt | Ctrl+Shift | Alt+Shift |
| --- | --- | --- | --- | --- |
| 1 | EXP trusts (Kupofried) | Curing Waltz V | Spectral Jig | Animated Flourish |
| 2 | Haste Samba | Curing Waltz IV | Chocobo Jig II | Desperate Flourish |
| 3 | Box Step | Curing Waltz III | Echad Ring | Divine Waltz |
| 4 | Quickstep | Divine Waltz II (AoE heal) | Caliber Ring | Aeolian Edge |
| 5 | Feather Step | Healing Waltz | Emperor Band | Shark Bite |
| 6 | Stutter Step | Violent Flourish | Warp Ring | Trance |
| 7 | Reverse Flourish | Climactic Flourish | Trusts (default) | Food |
| 8 | Building Flourish | Striking Flourish | Raise trusts | TP set toggle |
| 9 | Wild Flourish | Evisceration | Aspir Samba II | Idle set toggle |
| 0 | Presto | Dancing Edge | Drain Samba III | Dismiss trusts |

Alt+F6 Ternary Flourish. Alt+F7 Contradance. Alt+F8 No Foot Rise. Alt+F9 Saber Dance. Alt+F10 Fan Dance. Alt+F11 Exenterator. Alt+F12 Pyrrhic Kleos. Ctrl+F1 Rudra's Storm. Ctrl+F2 Shadowstitch. Ctrl+F3 Energy Drain. Saber Dance, Fan Dance, and No Foot Rise are merits. Exenterator is the merit weaponskill. Pyrrhic Kleos needs the mythic unlock, and Rudra's Storm needs the empyrean unlock.

## THF

| Key | Ctrl | Alt | Ctrl+Shift | Alt+Shift |
| --- | --- | --- | --- | --- |
| 1 | Feint | Steal | Trizek Ring | Ranged attack |
| 2 | Sneak Attack | Despoil | Capacity Ring | Wasp Sting |
| 3 | Trick Attack | Mug | Warp Ring | Viper Bite |
| 4 | Bully | Flee | Food | Idle set toggle |
| 5 | Hide | Evisceration | Raise trusts | Assassin's Charge |
| 6 | Collaborator p1 | Aeolian Edge | EXP trusts (Kupofried) | Rudra's Storm |
| 7 | Accomplice p1 | Shark Bite | TH set toggle | Exenterator |
| 8 | Larceny | Dancing Edge | SATA (SA, TA, Evisceration) | Mandalic Stab |
| 9 | Perfect Dodge | Collaborator p2 | TP set toggle | Shadowstitch |
| 0 | Conspirator | Accomplice p2 | Dismiss trusts | Energy Drain |

## NIN

Alt+F1 Hyoton: Ichi. Alt+F2 Doton: Ichi. Alt+F3 Tonko: Ichi. Blade: Ku needs the Bugi Soden quest. Blade: Yu is skill 290, so it waits until Ninja is higher than 70.

| Key | Ctrl | Alt | Ctrl+Shift | Alt+Shift |
| --- | --- | --- | --- | --- |
| 1 | EXP trusts (Kupofried) | Katon: Ni | Monomi: Ichi | Hojo: Ni |
| 2 | Utsusemi: Ni | Hyoton: Ni | Tonko: Ni | Kurayami: Ni |
| 3 | Utsusemi: Ichi | Huton: Ni | Echad Ring | Jubaku: Ichi |
| 4 | Yonin | Doton: Ni | Caliber Ring | Dokumori: Ichi |
| 5 | Innin | Raiton: Ni | Warp Ring | Hojo: Ichi |
| 6 | Suiton: Ni | Blade: Jin | Food | Kurayami: Ichi |
| 7 | Katon: Ichi | Blade: Ten | Raise trusts | Blade: To |
| 8 | Raiton: Ichi | Blade: Teki | Trusts (default) | Blade: Ei |
| 9 | Suiton: Ichi | Blade: Chi | Emperor Band | Blade: Ku |
| 0 | Mijin Gakure | Huton: Ichi | Dismiss trusts | Blade: Retsu |

## Subjob palettes

Ctrl+Alt still casts the row for the subjob you have on, except Dancer, which is on Ctrl. Switch to that book to see the same macros on the palette. While Dancer is subbed, the combo book opens on its own: Ctrl is the Dancer row, Alt is the main job's Alt row.

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
| 11 | THF/DNC | 1 |
| 12 | THF/WAR | 1 |

## Subjob row (Ctrl+Alt)

Ctrl+Alt casts this row. Dancer is the exception: those abilities are on Ctrl, and the main job's Ctrl row moves to Ctrl+Alt. Divine Waltz on that row is the AoE party heal (subjob 49 does not have Divine Waltz II). While Dancer is subbed, Trance takes the first free function key. Alt+Shift is already full on Thief and Ninja.

| Key | /THF | /NIN | /DNC (on Ctrl) | /WAR |
| --- | --- | --- | --- | --- |
| 1 | Sneak Attack | Utsusemi: Ni | Box Step | Provoke |
| 2 | Trick Attack | Utsusemi: Ichi | Quickstep | Berserk |
| 3 | SA + Evisceration | Yonin | Haste Samba | Defender |
| 4 | TA + Evisceration | Innin | Animated Flourish | Warcry |
| 5 | Steal | Tonko: Ni | Desperate Flourish | Aggressor |
| 6 | Mug | Monomi: Ichi | Reverse Flourish | Mighty Strikes |
| 7 | Flee | Katon: Ni | Violent Flourish | |
| 8 | Hide | Huton: Ni | Curing Waltz III | |
| 9 | Perfect Dodge | Hojo: Ni | Divine Waltz | |
| 0 | | Kurayami: Ni | Healing Waltz | |

/DNC flourishes stop at Violent Flourish. Subjob level is 49. Building Flourish is 50, Wild 60, Climactic 80, Striking 89, and Ternary 93, so those stay on Dancer main. On Dancer main, the AoE heal is Divine Waltz II on Alt+4. While Dancer is subbed, Trance takes the first free function key, then Stutter Step, Drain Samba II, Aspir Samba, and Spectral Jig. On Thief that is Alt+F1 through Alt+F5, because Alt+F8 through Alt+F11 are already used. While Ninja is subbed, the ninjutsu that did not fit Ctrl+Alt continues on the free function keys: the other Ni nukes, Dokumori, Jubaku, then the Ichi nukes, Huton: Ichi, and Tonko: Ichi. On Dancer that ninjutsu starts at Ctrl+F4. After Ctrl+F12 it continues on Alt+Shift+F. Trance on Dancer main stays Alt+Shift+6. Chocobo Jig is 55, so a level 49 subjob does not have it. Curing Waltz I and II stay off because III through V share that recast.
