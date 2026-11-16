# THF/DNC Book 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (or subagent-driven-development). Steps use checkbox (`- [ ]`) syntax.

**Goal:** One in-game macro book (Book 1 THF/DNC) matching the approved spec; GearSwap/keylabels/sync aligned; obsolete books blanked.

**Architecture:** THF.lua owns Ctrl=Dancer and Alt=openers. Opener chains live in THF `self_command` (recast-aware). `binds.lua` always opens book 1 set 1 for THF and does not move combat to Ctrl+Alt. `sync_macro_names.py` writes only Book 1 and blanks 2+. Edit live GearSwap under `C:\Windower4`, mirror to repo. Macro DATs: repo always; live Steam USER only when PlayOnline is closed.

**Tech Stack:** Lua (GearSwap), Python (`sync_macro_names.py`), FFXI macro DAT files.

## Global Constraints

- Live Windower path first for addons: `C:\Windower4\addons\GearSwap\data\`
- No git commit/push; suggest commit message only.
- PlayOnline open ⇒ do not write live `USER\158678d`; write repo copy and tell user to re-run sync after quit.

---

### Task 1: GearSwap opener commands + THF binds

**Files:**
- Modify: `C:\Windower4\addons\GearSwap\data\THF.lua`
- Mirror: `ffxi-cheeseplate/windower/addons/GearSwap/data/THF.lua`

- [ ] Replace `set_binds` rows with Book 1 set 1 Ctrl/Alt; drop `~^`/`~!`; keep fkeys Alt+F8–F11.
- [ ] Implement `saopen`, `taopen`, and update `sata` to skip SA/TA/Feint/Charge on CD (ids 64/66/68/67), always attempt Evisceration when TP≥1000.
- [ ] Mirror to repo.

### Task 2: binds.lua book selection + Dancer row/overflow

**Files:**
- Modify: `C:\Windower4\addons\GearSwap\data\binds.lua` (+ repo mirror)

- [ ] `MACRO_BOOKS.THF = 1`; `select_macro_book` always book 1 set 1 for THF.
- [ ] For THF main, bind `main_rows` as-is (no move `^` → `^!` when DNC sub).
- [ ] Update `SUB_ROWS.DNC` / `SUB_EXTRA.DNC` to match Ctrl + fkey overflow (Stutter on row; Spectral/Drain II/Aspir on overflow).
- [ ] Update overlay descriptions for new opener labels if needed.

### Task 3: sync_macro_names.py

**Files:**
- Modify: `ffxi-cheeseplate/windower/scripts/sync_macro_names.py`

- [ ] THF book 1 only with approved set 1 rows; set 2 empty.
- [ ] Blank books 2–20 titles/sets; remove combo book writers for now.
- [ ] Run script (repo USER; live if POL closed).

### Task 4: Docs

**Files:**
- Modify: `ffxi-cheeseplate/windower/keybinds.md` (THF/DNC book 1 tables)
- Optionally README macro book list if it still lists 12 books.

### Task 5: Verify + suggested commit

- [ ] Confirm live/repo GearSwap hashes match for THF.lua and binds.lua.
- [ ] Suggest commit message; do not commit.
