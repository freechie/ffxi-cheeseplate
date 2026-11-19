# screenfit Layout Director Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make screenfit apply per-monitor HUD layouts automatically via profiles and command-first positioning, without unload/reload cascades or day-to-day ownership of other addons’ settings files.

**Architecture:** Seed `data/layouts/1080.lua` and `1440.lua` as the source of truth. `screenfit.lua` picks a profile from window/UI size, then applies widgets in a fixed order (EquipViewer → enemybar → map → Timers → text oneshots). Runtime APIs first; oneshot settings writes only for text addons with no pos command, with at most an isolated single-addon refresh — never a multi-addon cascade. Remove unlock/lock from the happy path.

**Tech Stack:** Windower 4 Lua (`screenfit`), layout Lua tables under `addons/screenfit/data/layouts/`, existing `monitor.exe`, PowerShell for mirror/verify.

## Global Constraints

- Edit live paths under `C:\Windower4` before mirroring to `C:\Users\jrmol\ffxi-cheeseplate\windower\`.
- Do not run `git commit` or `git push`; show a suggested commit message only.
- Hard rule: no unload → rewrite → reload cascades for layout.
- EquipViewer remains screenfit-placed (`ev pos` + corner math).
- Do not reposition InfoBar, keylabels, GearSwap overlay, or scoreboard in this plan.
- Keep DistancePlus root-settings / unload-save fix; do not reintroduce arrange-mode capture races.
- Spec: `docs/superpowers/specs/2026-11-17-screenfit-layout-director-design.md`.

## File map

| Path | Role |
|------|------|
| `C:\Windower4\addons\screenfit\data\layouts\1080.lua` | Profile for smaller / 1080-class windows |
| `C:\Windower4\addons\screenfit\data\layouts\1440.lua` | Profile for large / 1440-class windows |
| `C:\Windower4\addons\screenfit\screenfit.lua` | Director: load profile, apply, window/scale; drop BLOCKS ownership + arrange happy path |
| Repo mirrors under `ffxi-cheeseplate/windower/addons/screenfit/` | Git copies of the above |
| `ffxi-cheeseplate/README.md` | Update screenfit blurb if it still describes unlock/BLOCKS ownership |

---

### Task 1: Seed layout profile files

**Files:**
- Create: `C:\Windower4\addons\screenfit\data\layouts\1080.lua`
- Create: `C:\Windower4\addons\screenfit\data\layouts\1440.lua`
- Mirror: `C:\Users\jrmol\ffxi-cheeseplate\windower\addons\screenfit\data\layouts\1080.lua`
- Mirror: `C:\Users\jrmol\ffxi-cheeseplate\windower\addons\screenfit\data\layouts\1440.lua`

**Interfaces:**
- Consumes: current known-good constants from live `screenfit.lua` (`TIMERS`, `ENEMYBAR`, `EQUIP`, `MAP`, `BLOCKS` text offsets, DistancePlus defaults from live settings)
- Produces: each file returns one Lua table `profile` with fields documented below

- [ ] **Step 1: Create the layouts directory (live)**

```powershell
New-Item -ItemType Directory -Force -Path "C:\Windower4\addons\screenfit\data\layouts" | Out-Null
```

- [ ] **Step 2: Write `1080.lua`**

Create `C:\Windower4\addons\screenfit\data\layouts\1080.lua` with this exact return table (base UI 1920×1080; native anchors preserved):

```lua
-- screenfit layout profile: 1080-class (UI scale 1.2 path)
-- Coords are native to each addon. right=true means x is offset from UI right edge.
return {
    id = '1080',
    base_w = 1920,
    base_h = 1080,
    uiscale = '1.2',
    equip = { x = 1683, y = 961, right = true, bottom = true, cols = 4 },
    enemybar = {
        { id = 'target', x = 1278, y = 76, right = true, bottom = false },
        { id = 'subtarget', x = 1282, y = 161, right = true, bottom = false },
        { id = 'focustarget', x = 1271, y = 111, right = true, bottom = false },
    },
    map = { x = 1514, y = 669, ref_w = 1920, ref_h = 1080 }, -- window px; 1080-class fraction of 2560x1440 spot
    timers = {
        RecastX = 20, RecastY = 340,
        BuffsX = 900, BuffsY = 652,
        CustomX = 1140, CustomY = 652,
    },
    texts = {
        Debuffed = { path = 'addons\\Debuffed\\data\\settings.xml', x = -697, y = 710, right = true, bottom = false },
        targetinfo = { path = 'addons\\targetinfo\\data\\settings.xml', x = -338, y = 548, right = true, bottom = false, nested = 'display' },
        SpeedChecker = { path = 'addons\\SpeedChecker\\data\\settings.xml', x = -297, y = 870, right = true, bottom = false },
        findAll = { path = 'addons\\findAll\\data\\settings.xml', x = -323, y = -70, right = false, bottom = false, nested = 'Tracker' },
        DistancePlus = {
            path = 'addons\\DistancePlus\\data\\settings.xml',
            sections = {
                main = { x = -178, y = 136 },
                heighttxt = { x = -238, y = 136 },
                pettxt = { x = -178, y = 160 },
                abilitytxt = { x = -80, y = 160 },
            },
            right = true,
        },
    },
}
```

Note on `map` for 1080: use window-pixel position scaled from the existing 2560×1440 anchor `(2018, 892)` → `(1514, 669)` on 1920×1080, matching current `map_pos` math.

- [ ] **Step 3: Write `1440.lua`**

Create `C:\Windower4\addons\screenfit\data\layouts\1440.lua` as a copy of `1080.lua` with these differences:

```lua
id = '1440',
uiscale = '1.5',
map = { x = 2018, y = 892, ref_w = 2560, ref_h = 1440 },
```

Keep the same `equip`, `enemybar`, `timers`, and `texts` as 1080 — right-offset texts and base-pinned enemybar/equip are resolved at apply time with current UI size via `place()`.

- [ ] **Step 4: Mirror into the repo**

```powershell
New-Item -ItemType Directory -Force -Path "C:\Users\jrmol\ffxi-cheeseplate\windower\addons\screenfit\data\layouts" | Out-Null
Copy-Item "C:\Windower4\addons\screenfit\data\layouts\1080.lua" "C:\Users\jrmol\ffxi-cheeseplate\windower\addons\screenfit\data\layouts\1080.lua" -Force
Copy-Item "C:\Windower4\addons\screenfit\data\layouts\1440.lua" "C:\Users\jrmol\ffxi-cheeseplate\windower\addons\screenfit\data\layouts\1440.lua" -Force
```

- [ ] **Step 5: Verify**

```powershell
Get-ChildItem "C:\Windower4\addons\screenfit\data\layouts","C:\Users\jrmol\ffxi-cheeseplate\windower\addons\screenfit\data\layouts" | Select-Object FullName, Length
```

Expected: both dirs contain `1080.lua` and `1440.lua` with non-zero size.

- [ ] **Step 6: Suggested commit message (do not commit)**

```text
Add screenfit 1080/1440 layout profile seeds.

Bake known-good HUD coords into data/layouts for the layout-director work.
```

---

### Task 2: Profile loader and selection in screenfit

**Files:**
- Modify: `C:\Windower4\addons\screenfit\screenfit.lua`
- Mirror: `C:\Users\jrmol\ffxi-cheeseplate\windower\addons\screenfit\screenfit.lua`

**Interfaces:**
- Consumes: `data/layouts/<id>.lua` return tables from Task 1
- Produces:
  - `load_profile(id) -> profile|nil, err`
  - `profile_id_for_window(mw, mh) -> '1080'|'1440'` (same thresholds as `scale_for`)
  - `active_profile(ui_w, ui_h, win_w, win_h) -> profile|nil`

- [ ] **Step 1: Add loader helpers near the top of `screenfit.lua` (after `BASE_W`/`BASE_H`)**

```lua
local function profile_id_for_window(mw, mh)
    if (mw or 0) >= 2200 or (mh or 0) >= 1300 then return '1440' end
    return '1080'
end

local function load_profile(id)
    local path = windower.addon_path .. 'data\\layouts\\' .. id .. '.lua'
    local chunk, err = loadfile(path)
    if not chunk then return nil, err or ('missing layout ' .. tostring(id)) end
    local ok, profile = pcall(chunk)
    if not ok then return nil, profile end
    if type(profile) ~= 'table' or not profile.enemybar then
        return nil, 'invalid layout ' .. tostring(id)
    end
    return profile
end

local function active_profile()
    local info = run_monitor()
    local mw, mh = 1920, 1080
    if info and info.ww and info.wh then
        mw, mh = info.ww, info.wh
    else
        local ww, wh = window_size()
        if ww then mw, mh = ww, wh end
    end
    return load_profile(profile_id_for_window(mw, mh))
end
```

If `run_monitor` is defined later in the file, place these functions after `run_monitor`, or keep `active_profile` after it and only put `profile_id_for_window` / `load_profile` early.

- [ ] **Step 2: Align `scale_for` with profile ids**

Keep existing:

```lua
local function scale_for(mw, mh)
    if (mw or 0) >= 2200 or (mh or 0) >= 1300 then return '1.5' end
    return '1.2'
end
```

Ensure `profile_id_for_window` uses the same thresholds (already does in Step 1).

- [ ] **Step 3: Smoke-load profiles from a Windower console or temporary command**

Add a temporary debug command branch (removed or kept as `//fit profile` in Task 5):

```lua
elseif cmd == 'profile' then
    local p, err = active_profile()
    if not p then
        windower.add_to_chat(167, '[screenfit] profile: ' .. tostring(err))
    else
        windower.add_to_chat(207, '[screenfit] profile ' .. p.id .. ' equip=' .. p.equip.x .. ',' .. p.equip.y)
    end
    return
```

- [ ] **Step 4: In-game verify**

```text
//lua r screenfit
//fit profile
```

Expected chat: `[screenfit] profile 1440 equip=1683,961` (on large window) or `1080` on small.

- [ ] **Step 5: Mirror and suggest commit message (do not commit)**

```powershell
Copy-Item "C:\Windower4\addons\screenfit\screenfit.lua" "C:\Users\jrmol\ffxi-cheeseplate\windower\addons\screenfit\screenfit.lua" -Force
```

```text
Add screenfit layout profile loader and selection.
```

---

### Task 3: Command-first `apply_profile` (no cascade)

**Files:**
- Modify: `C:\Windower4\addons\screenfit\screenfit.lua`
- Mirror: repo copy of `screenfit.lua`

**Interfaces:**
- Consumes: `active_profile()`, existing `place()`, `gear_pos()` / EquipViewer helpers, `write_timers`, `write_map`, `ui_size()`, `window_size()`
- Produces: `apply_profile(profile) -> ok, err` applying widgets in spec order

- [ ] **Step 1: Implement EquipViewer + enemybar + map apply from profile**

```lua
local function apply_equip(profile, ui_w, ui_h)
    local e = profile.equip
    local x, y = place(e.x, e.y, ui_w, ui_h, e.right, e.bottom)
    write_equip(x, y)
    windower.send_command('ev pos ' .. x .. ' ' .. y)
end

local function apply_enemybar(profile, ui_w, ui_h)
    for _, bar in ipairs(profile.enemybar) do
        local x, y = place(bar.x, bar.y, ui_w, ui_h, bar.right, bar.bottom)
        windower.send_command('eb set pos ' .. bar.id .. ' ' .. x .. ' ' .. y)
    end
end

local function apply_map(profile)
    local sw, sh = window_size()
    if not sw then return end
    local mx = math.floor(profile.map.x * sw / profile.map.ref_w + 0.5)
    local my = math.floor(profile.map.y * sh / profile.map.ref_h + 0.5)
    write_map(sw, sh) -- keep writing plugin settings if still required for persistence
    windower.send_command('ffxidb pos ' .. mx .. ' ' .. my)
    -- Isolated reload only for FFXIDB if pos does not stick without it:
    windower.send_command('wait 0.5; unload FFXIDB; wait 0.2; load FFXIDB; wait 0.2; ffxidb pos ' .. mx .. ' ' .. my)
end
```

- [ ] **Step 2: Implement Timers apply from profile**

Reuse existing `write_timers` but feed profile values. Either:

```lua
local function apply_timers(profile, ui_w, ui_h)
    local t = profile.timers
    -- Temporarily set TIMERS from profile, or change write_timers to accept a table:
    write_timers_from(t, ui_w, ui_h)
end
```

Refactor `write_timers` to accept a timers table argument (profile.timers) instead of the global `TIMERS` constant. Keep bottom-pin math for Buffs/Custom as today.

- [ ] **Step 3: Implement text oneshot writers (no multi-addon cascade)**

For each entry in `profile.texts`:

1. Write cheeseplate (and global pos if that addon needs it) to `path` using native x/y/right/bottom.
2. Do **not** unload other addons.
3. Optional isolated refresh: only if the widget will not move from a file write alone, queue **one** `lua r <AddonName>` for that addon after its write — never loop `ANCHORED` as a pack.

DistancePlus: write all four sections’ pos with `right=true`, matching the Task 1 profile structure.

- [ ] **Step 4: `apply_profile` orchestration**

```lua
local function apply_profile(profile)
    local ui_w, ui_h = ui_size()
    if not ui_w then return false, 'no UI size' end
    apply_equip(profile, ui_w, ui_h)
    apply_enemybar(profile, ui_w, ui_h)
    apply_map(profile)
    apply_timers(profile, ui_w, ui_h)
    apply_texts(profile, ui_h)
    return true
end
```

- [ ] **Step 5: Replace old `apply`/`commit` HUD path**

- Remove `ANCHORED` unload loop from `apply()`.
- Remove `load_hud()` packing Debuffed/targetinfo/SpeedChecker/findAll/DistancePlus for layout purposes.
- New flow:

```lua
local function apply()
    local w, h = ui_size()
    if not w or (w == applied_w and h == applied_h) then return end
    applied_w, applied_h = w, h
    local profile, err = active_profile()
    if not profile then
        windower.add_to_chat(167, '[screenfit] ' .. tostring(err))
        return
    end
    local ok, why = apply_profile(profile)
    if ok then
        windower.add_to_chat(207, '[screenfit] HUD fit to ' .. w .. 'x' .. h .. ' (' .. profile.id .. ')')
    else
        windower.add_to_chat(167, '[screenfit] apply failed: ' .. tostring(why))
    end
end
```

Trust filter restore for Timers can remain inside `write_timers_from` as today.

- [ ] **Step 6: In-game verify (large window)**

```text
//lua r screenfit
//fit apply
```

Expected: EquipViewer bottom-right, enemy bars top-right, map moves, **no** chat spam from mass unload; FPS hitch much smaller than old cascade.

- [ ] **Step 7: Mirror + suggested commit message (do not commit)**

```text
Apply screenfit layouts command-first from profiles.

Drop the multi-addon unload cascade; keep FFXIDB reload isolated.
```

---

### Task 4: Wire monitor place + remove arrange happy path

**Files:**
- Modify: `C:\Windower4\addons\screenfit\screenfit.lua`
- Mirror: repo `screenfit.lua`
- Modify: `C:\Users\jrmol\ffxi-cheeseplate\README.md` (screenfit paragraph only if it mentions unlock/BLOCKS)

**Interfaces:**
- Consumes: `place_window` success path, `apply()` from Task 3
- Produces: monitor switch auto-applies profile; `//fit unlock`/`lock` removed or reduced to a one-line “not used” message

- [ ] **Step 1: After successful window land in `place_window`, force apply**

Where today it calls `fit apply` / scale save, ensure:

```lua
applied_w, applied_h = nil, nil
windower.send_command('fit apply')
```

so the matching profile always runs after `//fit window|fill|other`.

- [ ] **Step 2: Remove arrange mode from normal UX**

Delete or gut: `begin_arrange`, `arrange_enable_drag`, `end_arrange`, `arrange_finish_lock`, `capture_hud_layout`, `arranging` flag, and command branches `unlock`/`arrange`/`lock`/`savehud`/`arrangedrag`/`arrangelock`.

Replace unlock/lock with:

```lua
elseif cmd == 'unlock' or cmd == 'lock' or cmd == 'arrange' or cmd == 'savehud' then
    windower.add_to_chat(207, '[screenfit] Layout is automatic from profiles. Use //fit apply or //fit other.')
    return
```

- [ ] **Step 3: Delete dead BLOCKS-owned write path used only for arrange**

Remove or stop calling: live `BLOCKS` table as source of truth, `write_anchors` multi-addon ownership loop driven by BLOCKS, Speed/Distance arrange capture. Keep minimal helpers still needed for oneshot text writes in Task 3.

Bump `_addon.version` to `3.0`.

- [ ] **Step 4: Help text**

```lua
windower.add_to_chat(207, 'screenfit: //fit apply | //fit window | //fit fill | //fit other | //fit profile')
```

- [ ] **Step 5: README**

If README still says screenfit unlock/lock or “owns addon settings,” update to: profiles under `data/layouts`, automatic apply per monitor, EquipViewer special-cased.

- [ ] **Step 6: In-game verify monitor switch**

```text
//fit other
```

Expected: window moves, then HUD refits to the other profile without unlock/lock and without unloading Speed/Distance/Debuffed as a pack.

- [ ] **Step 7: Mirror + suggested commit message (do not commit)**

```text
Make screenfit monitor layouts automatic from profiles.

Remove unlock/lock arrange mode and BLOCKS ownership from the happy path.
```

---

### Task 5: End-to-end verification checklist

**Files:**
- None (manual + PowerShell verify)
- Optional log: `C:\Windower4\addons\screenfit\screenfit.log`

**Interfaces:**
- Consumes: Tasks 1–4 complete on live Windower
- Produces: pass/fail against spec success criteria

- [ ] **Step 1: File presence**

```powershell
@('1080.lua','1440.lua') | ForEach-Object {
  Test-Path "C:\Windower4\addons\screenfit\data\layouts\$_"
  Test-Path "C:\Users\jrmol\ffxi-cheeseplate\windower\addons\screenfit\data\layouts\$_"
}
Select-String -Path "C:\Windower4\addons\screenfit\screenfit.lua" -Pattern "ANCHORED|begin_arrange|BLOCKS\s*=" 
```

Expected: layout files exist; `begin_arrange` absent (or only in comments); no layout cascade via `ANCHORED`.

- [ ] **Step 2: In-game — apply on current monitor**

```text
//lua r screenfit
//fit profile
//fit apply
```

Check: EquipViewer corner, enemy HP bars, map, timers stack look correct for current UI scale.

- [ ] **Step 3: In-game — other monitor**

```text
//fit other
```

Check: lands on other display; HUD matches that class (1080 vs 1440); no multi-addon unload hitch.

- [ ] **Step 4: Confirm unlock not required**

```text
//fit unlock
```

Expected: message that layout is automatic — not arrange mode.

- [ ] **Step 5: Spec success criteria sign-off**

Mark each:

- [ ] 1080 ↔ 1440 / `//fit other` lands correctly without multi-addon reload hitch  
- [ ] EquipViewer correct at UI scale 1.5  
- [ ] screenfit does not routinely rewrite Distance/Speed/Debuffed/targetinfo/findAll except oneshot apply  
- [ ] No unlock/lock required for normal use  

- [ ] **Step 6: Final suggested commit message for the whole feature (do not commit)**

```text
Turn screenfit into a per-monitor layout director.

Profiles drive command-first HUD apply; drop settings ownership cascades and arrange mode.
```

---

## Spec coverage (self-review)

| Spec requirement | Task |
|------------------|------|
| Profiles as source of truth under `data/layouts/` | Task 1 |
| 1080 / 1440 split + uiscale pairing | Tasks 1–2 |
| Command-first apply order (equip → eb → map → timers → texts) | Task 3 |
| No unload/reload cascade | Tasks 3–4 |
| EquipViewer special case | Task 3 |
| Auto apply on monitor switch | Task 4 |
| Remove unlock/lock happy path | Task 4 |
| Keep DistancePlus save fix; no arrange capture | Task 4 |
| Live then mirror | All tasks |
| Success criteria verification | Task 5 |
| Out of scope (InfoBar, replace overlays, etc.) | Not scheduled |

**Placeholder scan:** none intentional.  
**Type consistency:** profile fields `equip`, `enemybar`, `map`, `timers`, `texts` used the same across Tasks 1–3.
