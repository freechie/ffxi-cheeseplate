# FFXI · Cheeseplate

Personal Final Fantasy XI and Windower settings, plus the Cheeseplate (Asura) progress board. This is a snapshot of config files, not the game or Windower install.

PlayOnline login files, cookies, and mail are not included.

## Progress board

Job, mission, and currency tracker:

https://freechie.github.io/ffxi-cheeseplate/

Source lives in `docs/` (GitHub Pages).

Current: Dancer 94 / Thief 47, with Thief 99 and Ninja 70. Finish Dancer to 99 on Experience Points. On Thief, Mode Switch stays on Capacity Points until about 100 Job Points (27,373 / 30,000 toward Job Point 1). Then one Limit burst: Dagger 8/8, Crit 5/5, DEX 5/15, Triple Attack 5/5, and back to Capacity Points. HP merits stay 8/15.

## Layout

- `docs/` - progress board for GitHub Pages
- `windower/settings.xml` - launcher profile (UI scale, autoload list)
- `windower/scripts/` - `init.txt`, autoload, `sync_macro_names.py`, and `portwatch.ps1`
- `windower/plugins/settings/` - plugin configs
- `windower/plugins/ll/` - LightLuggage lists
- `windower/addons/*/data/` - addon settings, filters, and GearSwap
- `game/USER/` - in-game macros, equipment sets, and client options. Books are alphabetical: 1 DNC, 2 DNC/NIN, 3 DNC/THF, 4 DNC/WAR, 5 NIN, 6 NIN/DNC, 7 NIN/THF, 8 NIN/WAR, 9 PUP/DNC, 10 THF, 11 THF/WAR. Regenerate with `python windower/scripts/sync_macro_names.py` while PlayOnline is closed.
- `windower/keybinds.md` - THF / DNC / NIN number-row keybinds. GearSwap sets them, and the key overlay reloads once the character is in.
- `game/settings.xml` - retail client profile
- `dgvoodoo/dgVoodoo.conf` - DirectX 8 wrapper used by PlayOnline

XIPivot overlay settings are here. The `remapster` DAT files themselves stay in the Windower install.

## Restore

Copy each tree back over the matching folder:

- `windower/` → `C:\Windower4\`
- `game/USER/` → `FINAL FANTASY XI\USER\`
- `game/settings.xml` → `FINAL FANTASY XI\settings.xml`
- `dgvoodoo/dgVoodoo.conf` → `PlayOnlineViewer\dgVoodoo.conf`

Close PlayOnline before restoring `game/USER`.
