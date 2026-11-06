# FFXI · Cheeseplate

Personal Final Fantasy XI and Windower settings for Cheeseplate on Asura, plus the progress board. A clone gives you the launcher profile, addon settings, plugin settings, GearSwap files, LightLuggage lists, in-game macro books, and five addons that live in this repo.

The Windower program and the retail client stay installed on your machine. PlayOnline login files, cookies, and mail stay out of this repo.

## Progress board

Job, mission, and currency tracker:

https://freechie.github.io/ffxi-cheeseplate/

The page source is in `docs/` (GitHub Pages).

Right now: Thief 99, Dancer 94, Ninja 70. Job Points come first on Thief. The board has the camp and the merit order.

## What a clone contains

- `docs/` — progress board for GitHub Pages
- `windower/settings.xml` — launcher profile (window scale, addons and plugins that load at startup)
- `windower/scripts/` — `init.txt`, autoload, macro-name sync, keybind export, port watch
- `windower/plugins/settings/` — plugin configs
- `windower/plugins/ll/` — LightLuggage drop lists
- `windower/addons/*/data/` — settings, filters, and GearSwap for addons you install from the launcher
- `windower/keybinds.md` — Thief, Dancer, and Ninja number-row keys. GearSwap sets them. The key overlay reloads once the character is in.
- `windower/steam/controller_xbox360.vdf` — Xbox pad layout used with `padmacros`
- `game/USER/158678d/` — Cheeseplate's macros, equipment sets, and client options. Books are alphabetical: 1 Dancer, 2 Dancer/Ninja, 3 Dancer/Thief, 4 Dancer/Warrior, 5 Ninja, 6 Ninja/Dancer, 7 Ninja/Thief, 8 Ninja/Warrior, 9 Puppetmaster/Dancer, 10 Thief, 11 Thief/Dancer, 12 Thief/Warrior. Rebuild them with `python windower/scripts/sync_macro_names.py` while PlayOnline is closed.
- `game/settings.xml` — retail client profile (UI scale, console key)
- `dgvoodoo/dgVoodoo.conf` — DirectX 8 wrapper used by PlayOnline

These addons are in the repo as source. The launcher does not ship them:

- `keylabels` — key overlay
- `padmacros` — Xbox pad to those keys (needs Python 3)
- `scenepace` — 30 FPS during cutscenes, 60 FPS the rest of the time
- `screenfit` — places the HUD for the current window size
- `SellNPC` — vendor list. See `windower/addons/SellNPC/README.md`

XIPivot overlay settings are here. The `remapster` DAT files stay in the Windower install, under `addons/XIPivot/data/DATs`.

`game/USER/macro-backup-*` are old macro snapshots. `game/USER/1618733` is the other saved character folder.

## Set up

Close PlayOnline and Windower before copying. Install Windower 4 from [windower.net](https://windower.net/) first. This setup uses the stable branch, usually at `C:\Windower4`. The retail client on this PC is the Steam copy:

`C:\Program Files (x86)\Steam\steamapps\common\FFXINA\SquareEnix\`

### 1. Install from the Windower launcher

Plugins:

Config, DelayMeNot, FFXIDB, LightLuggage, LuaCore, MipmapFix, Tickle, Timers, WeatherMon, WinControl

Addons:

autoenterkey, BattleMod, BattleStations, ConsoleBG, Debuffed, DistancePlus, DressUp, enternity, Equipviewer, findAll, GearSwap, InfoBar, InfoReplacer, instaLS, invtracker, Itemizer, Lookup, MacroChanger, MountMuzzle, MountRoulette, ROE, SATACast, Scoreboard, SetTarget, Shortcuts, SpeedChecker, TargetInfo, timestamp, TParty, Trusts, Update

The launcher also installs `libs` for the addons that need it.

Two more addons come from GitHub. Install them before the copy in the next step, so this repo's settings land on top of the addon code.

- [XIPivot v0.4.7 Windower zip](https://github.com/HealsCodes/XIPivot/releases/tag/v0.4.7). Later XIPivot releases are for Ashita. Unzip into `addons/XIPivot`. Put your own overlay DATs in `addons/XIPivot/data/DATs`. This repo only has the overlay list.
- [enemybar2](https://github.com/AkadenTK/enemybar2). Clone or copy it to `addons/enemybar2`. The launcher addon named Enemybar is a different addon.

### 2. Copy this repo onto the install

The copy merges. Files already in Windower that this repo does not contain stay where they are.

```powershell
$Repo = "C:\path\to\ffxi-cheeseplate"
$Windower = "C:\Windower4"
$Game = "C:\Program Files (x86)\Steam\steamapps\common\FFXINA\SquareEnix"

Copy-Item "$Repo\windower\settings.xml" "$Windower\settings.xml" -Force
Copy-Item "$Repo\windower\keybinds.md" "$Windower\keybinds.md" -Force
Copy-Item "$Repo\windower\scripts\*" "$Windower\scripts\" -Recurse -Force
Copy-Item "$Repo\windower\addons\*" "$Windower\addons\" -Recurse -Force
Copy-Item "$Repo\windower\plugins\settings\*" "$Windower\plugins\settings\" -Force
Copy-Item "$Repo\windower\plugins\ll\*" "$Windower\plugins\ll\" -Force
Copy-Item "$Repo\game\settings.xml" "$Game\FINAL FANTASY XI\settings.xml" -Force
Copy-Item "$Repo\dgvoodoo\dgVoodoo.conf" "$Game\PlayOnlineViewer\dgVoodoo.conf" -Force
```

Change `$Repo`, `$Windower`, and `$Game` if your folders differ. `sync_macro_names.py` writes the live books to `USER\158678d` under that same Steam path. Edit `live` at the bottom of the script when the client lives somewhere else.

### 3. Macros

Cheeseplate's books are `game/USER/158678d`. The folder name is the character id.

Same character, same id:

```powershell
Copy-Item "$Repo\game\USER\158678d\*" "$Game\FINAL FANTASY XI\USER\158678d\" -Recurse -Force
```

Another character: copy `mcr.dat`, `mcr*.dat`, `mcr.ttl`, `mcr_2.ttl`, and `mcr.sys` into that character's own `USER\<id>\` folder. Leave the rest of `158678d` (equipment sets and client options) in place unless you mean to replace that character's files.

### 4. Point padmacros at Python

`padmacros` starts `xinput_watch.py` with the Python path from this PC. In `windower/addons/padmacros/padmacros.lua`, set `pythonw` inside `start_watcher` to your `pythonw.exe`. Python 3 is enough. The script uses the standard library.

The pad layout is `windower/steam/controller_xbox360.vdf` (tap L to autorun; holds pick the macro row). Steam keeps the live file under your own `Steam Controller Configs\<steamid>\config\230330\controller_xbox360.vdf`. Copy this file onto the one Steam already created for FFXI, or import it from Steam's controller settings.

### 5. Character name

Per-character blocks are saved as `Cheeseplate` in `plugins/settings/config.xml` and `plugins/settings/ffxidb.xml`, and as `cheeseplate` in the addon settings `screenfit` moves. Windower applies the block that matches the logged-in character. Another character uses `<global>` until those tags match the new name.

Rename both tags to the new character name in the settings files, and rename the two searches in `windower/addons/screenfit/screenfit.lua` (`<cheeseplate>` and `<Cheeseplate>`). Leave `windower/addons/findAll/data/Cheeseplate.lua` as it is. That file is a stored findAll list.

## After you log in

Insert opens the Windower console. The launcher loads the plugins and addons from `settings.xml`. `scripts/init.txt` then loads XIPivot, enemybar2, keylabels, padmacros, screenfit, and scenepace. Leave XIPivot and SATACast out of a second load. Each one errors with "already loaded" when both the launcher list and `init.txt` start it.

`screenfit` fits the HUD to the window and writes the UI scale back into `settings.xml` for the next launch (1 on 1920x1080, 1.45 on 2560x1440). Once the character is in, GearSwap loads the job file and the key overlay reloads.

Save Records of Eminence once, then the daily set comes back with:

```
//roe save daily
//roe set daily
```
