# FFXI · Cheeseplate

Personal Final Fantasy XI and Windower settings, plus the Cheeseplate (Asura) progress board. This is a copy of config files. It is not the game, and it is not the Windower install.

PlayOnline login files, cookies, and mail are left out.

## Progress board

Job, mission, and currency tracker:

https://freechie.github.io/ffxi-cheeseplate/

The page source is in `docs/` (GitHub Pages).

Right now: Dancer 94 / Thief 47, with Thief 99 and Ninja 70. Finish Dancer to 99 on experience points. On Thief, Mode Switch stays on Capacity Points until about 100 Job Points (27,373 / 30,000 toward Job Point 1). Then one Limit burst: Dagger 8/8, Critical Hit 5/5, DEX 5/15, Triple Attack 5/5, and back to Capacity Points. HP merits stay 8/15.

## Layout

- `docs/` — progress board for GitHub Pages
- `windower/settings.xml` — launcher profile (window scale, addons that load at startup)
- `windower/scripts/` — startup script, autoload, the macro-name sync, and the port watch script
- `windower/plugins/settings/` — plugin configs
- `windower/plugins/ll/` — LightLuggage drop lists
- `windower/addons/*/data/` — addon settings, filters, and GearSwap
- `game/USER/` — in-game macros, equipment sets, and client options. Books are in alphabetical order: 1 Dancer, 2 Dancer/Ninja, 3 Dancer/Thief, 4 Dancer/Warrior, 5 Ninja, 6 Ninja/Dancer, 7 Ninja/Thief, 8 Ninja/Warrior, 9 Puppetmaster/Dancer, 10 Thief, 11 Thief/Dancer, 12 Thief/Warrior. Rebuild them with `python windower/scripts/sync_macro_names.py` while PlayOnline is closed.
- `windower/keybinds.md` — Thief, Dancer, and Ninja number-row keys. GearSwap sets them. The key overlay reloads once the character is in.
- `game/settings.xml` — retail client profile
- `dgvoodoo/dgVoodoo.conf` — DirectX 8 wrapper used by PlayOnline

XIPivot overlay settings are here. The `remapster` DAT files stay in the Windower install.

## Restore

Copy each folder back over the matching folder:

- `windower/` → `C:\Windower4\`
- `game/USER/` → `FINAL FANTASY XI\USER\`
- `game/settings.xml` → `FINAL FANTASY XI\settings.xml`
- `dgvoodoo/dgVoodoo.conf` → `PlayOnlineViewer\dgVoodoo.conf`

Close PlayOnline before restoring `game/USER`.
