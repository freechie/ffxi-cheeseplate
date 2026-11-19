# screenfit as layout director

Date: 2026-11-17  
Status: approved in chat; awaiting implementation plan

## Goal

Make screenfit apply an accurate HUD layout automatically per monitor/window size, with less hitching, without day-to-day ownership of other addons’ `settings.xml` files. EquipViewer remains the one special-cased placement target. Normal use needs no `//fit unlock` / `//fit lock`.

## Context

- Windower loads from `C:\Windower4`. `ffxi-cheeseplate/windower/` is the git mirror.
- Today screenfit stores layout in Lua constants / `BLOCKS`, writes cheeseplate sections into many addon settings files, and often **unload → rewrite → reload** so those files stick. That cascade causes hitches and races (e.g. DistancePlus positions snapping back when drag never saved / unload overwrote writes).
- User goals locked in brainstorming:
  - Hitch less **and** stop owning other addons’ settings as the source of truth
  - Reposition everything screenfit already manages, accurately per monitor
  - Addons should move in their **native** coordinate/anchor model
  - **EquipViewer** is the exception: screenfit places it
  - Fully **automatic** apply on monitor/size — no unlock/lock in normal use

## Decision: Approach 1 — layout profiles + command-first apply

screenfit becomes a **layout director**.

| Concern | Owner |
|--------|--------|
| Per-monitor layout source of truth | `addons/screenfit/data/layouts/` profiles |
| Runtime positions of enemybar / EquipViewer / map | Addon APIs (`eb set pos`, `ev pos`, `ffxidb pos`) |
| Timers | Plugin settings write only as needed (no HUD-pack reload) |
| Text addons without a pos API | One-shot write only when required; never unload/reload just to move them |
| EquipViewer corner under UI scale | screenfit special case (keep) |
| Debuffed / targetinfo / SpeedChecker / DistancePlus / findAll settings files | Stay the addons’; not screenfit’s live mirror |

**Hard rule:** no unload → rewrite → reload cascades for layout.

## Architecture

```text
monitor.exe / ui_size()
        │
        ▼
 pick profile (1080 | 1440)
        │
        ▼
 apply widgets (command-first)
        │
        ├── EquipViewer     ev pos (+ corner math)
        ├── enemybar2       eb set pos
        ├── FFXIDB          ffxidb pos (+ isolated reload only if required)
        ├── Timers          plugin XML write
        └── text widgets    native coords; file touch only if no command API
```

- **Not** the source of truth: in-Lua `BLOCKS` as a permanent twin of every addon settings file.
- **Not** primary UX: `//fit unlock` / `//fit lock` (optional later as a maint “capture into profile” tool only).

## Profiles

- Keys: `1080` and `1440`, same split already used (`scale_for`: large ≈ window ≥ 2200×1300 → `1440` / UI scale `1.5`; else `1080` / `1.2`).
- Each profile lists managed widgets with:
  - addon / widget id
  - native coordinates (and anchor flags where the addon uses them)
  - apply method: `command` | `timers` | `equip_special` | `oneshot_settings` (last resort)
- Seed from today’s known-good constants (ENEMYBAR, EQUIP, MAP, TIMERS, text offsets), not from whatever drifted XML is on disk at cutover.

## Detect and apply

**Detect**

- Keep `monitor.exe` + cheap UI-size polling.
- Profile = f(window / monitor class + current UI res).
- UI scale still written to Windower `settings.xml` for the **next** PlayOnline launch (menus). HUD apply uses current `ui_x_res` / `ui_y_res` immediately.

**Apply order**

1. Resolve profile from current window/UI size  
2. EquipViewer via `ev pos` (special case)  
3. enemybar2 via `eb set pos`  
4. FFXIDB via `ffxidb pos` (reload only if that plugin still requires it — sole allowed reload, isolated)  
5. Timers via plugin settings write (no multi-addon HUD unload)  
6. Text addons without a pos API: one-shot cheeseplate/pos write if needed — **never** unload SpeedChecker / DistancePlus / Debuffed / targetinfo / findAll just to move them  

**Monitor switch** (`//fit window` | `fill` | `other`)

- Place window → wait until landed → auto-apply matching profile.

## Migration

1. Bake current good layout into `data/layouts/1080` and `1440`.  
2. Replace live `BLOCKS` ownership with profile reads on apply.  
3. Keep the DistancePlus root-settings / unload-save fix (correct addon behavior); screenfit must not depend on unload races to capture Distance.  
4. Remove arrange mode from the happy path (`unlock` / `lock` not required for daily monitor use).  
5. Edit live under `C:\Windower4\addons\screenfit\` first; mirror into `ffxi-cheeseplate/windower/addons/screenfit/` for git.

## Failure modes

- Addon missing / not loaded: skip that widget, one chat line, continue.  
- Command apply no-ops: log once; do **not** fall back into unload/reload storms.  
- UI scale change still needs PlayOnline restart for menus; HUD still refits to current UI res.  
- FFXIDB reload, if unavoidable, stays isolated and documented.

## Out of scope

- Replacing enemybar2 / DistancePlus / SpeedChecker with screenfit-drawn UI  
- Repositioning InfoBar, keylabels, GearSwap overlay, scoreboard (unless added later as explicit profile widgets)  
- Continuous per-frame layout beyond cheap size polling  
- Making unlock/lock the primary layout editor  

## Success criteria

- Switch 1080 ↔ 1440 (or `//fit other`): HUD lands correctly without a multi-addon reload hitch.  
- EquipViewer corner stays correct under UI scale 1.5.  
- screenfit does not routinely rewrite DistancePlus / SpeedChecker / Debuffed / targetinfo / findAll settings just to keep layout.  
- No `//fit unlock` / `//fit lock` required for normal monitor use.  

## Follow-ups (optional, later)

- Maint-only “capture current HUD into active profile” command.  
- Tiny pos shims for text addons that lack a runtime API, so even one-shot settings writes go away.
