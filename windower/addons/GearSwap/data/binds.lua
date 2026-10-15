-- Number-row keybinds shared by the job files (replaces in-game macros).
-- Job files: include('binds.lua'), set_binds(rows) in get_sets, clear_binds() in file_unload,
-- and `if binds_command(command) then return end` at the top of self_command.
-- Defines sub_job_change, so job files must not define their own.
--
-- A row is up to 10 entries for keys 1-9, 0: {label, windower command, min level},
-- plus an optional title shown in the keylabels overlay.
-- Entries above the current level are left unbound until //gs c binds re-runs.

local KEYS = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0'}
local MODS = {
    {'^', 'Ctrl'},
    {'!', 'Alt'},
    {'~^', 'Ctrl+Shift'},
    {'~!', 'Alt+Shift'},
    {'^!', 'Ctrl+Alt'},
}

local SUB_ROWS = {
    THF = {
        {'SA', 'input /ja "Sneak Attack" <me>', 15},
        {'TA', 'input /ja "Trick Attack" <me>', 30},
        {'SA Evisc', 'gs c saevisc', 15},
        {'TA Evisc', 'gs c taevisc', 30},
        {'Steal', 'input /ja "Steal" <t>', 5},
        {'Mug', 'input /ja "Mug" <t>', 35},
        {'Flee', 'input /ja "Flee" <me>', 25},
        {'Hide', 'input /ja "Hide" <me>', 45},
    },
    NIN = {
        {'Utsu Ni', 'input /ma "Utsusemi: Ni" <me>', 37},
        {'Utsu Ichi', 'input /ma "Utsusemi: Ichi" <me>', 12},
        {'Yonin', 'input /ja "Yonin" <me>', 40},
        {'Innin', 'input /ja "Innin" <me>', 40},
        {'Tonko', 'input /ma "Tonko: Ichi" <me>', 9},
        {'Monomi', 'input /ma "Monomi: Ichi" <me>', 25},
        {'Katon', 'input /ma "Katon: Ichi" <t>', 15},
        {'Raiton', 'input /ma "Raiton: Ichi" <t>', 15},
    },
    DNC = {
        {'C.Waltz III', 'input /ja "Curing Waltz III" <stpc>', 45},
        {'C.Waltz II', 'input /ja "Curing Waltz II" <stpc>', 30},
        {'Haste Samba', 'input /ja "Haste Samba" <me>', 45},
        {'Drain Samba', 'input /ja "Drain Samba" <me>', 5},
        {'Box Step', 'input /ja "Box Step" <t>', 23},
        {'Quickstep', 'input /ja "Quickstep" <t>', 20},
        {'Animated', 'input /ja "Animated Flourish" <t>', 20},
        {'Divine Waltz', 'input /ja "Divine Waltz" <me>', 25},
        {'Healing Waltz', 'input /ja "Healing Waltz" <stpc>', 35},
        {'Spectral Jig', 'input /ja "Spectral Jig" <me>', 25},
    },
    WAR = {
        {'Provoke', 'input /ja "Provoke" <t>', 5},
        {'Berserk', 'input /ja "Berserk" <me>', 15},
        {'Defender', 'input /ja "Defender" <me>', 25},
        {'Warcry', 'input /ja "Warcry" <me>', 35},
        {'Aggressor', 'input /ja "Aggressor" <me>', 45},
    },
}

local RINGS = {
    echad = 'Echad Ring',
    caliber = 'Caliber Ring',
    emperor = 'Emperor Band',
    trizek = 'Trizek Ring',
    capring = 'Capacity Ring',
    warp = 'Warp Ring',
}

local CHAINS = {
    saevisc = 'input /ja "Sneak Attack" <me>; wait 1; input /ws "Evisceration" <t>',
    taevisc = 'input /ja "Trick Attack" <me>; wait 1; input /ws "Evisceration" <t>',
}
-- GearSwap re-equips after every action, so the ring slot is locked until the use goes off.
for cmd, ring in pairs(RINGS) do
    CHAINS[cmd] = 'gs disable ring1; input /equip ring1 "'..ring..'"; wait 11; input /item "'..ring..'" <me>; wait 3; gs enable ring1'
end
-- Warp Ring has a longer activation time than the experience/capacity rings.
CHAINS.warp = 'gs disable ring1; input /equip ring1 "Warp Ring"; wait 11; input /item "Warp Ring" <me>; wait 12; gs enable ring1'

for _, row in pairs(SUB_ROWS) do
    row.title = 'subjob'
end

local main_rows = {}
local active = {}
local titles = {}
local overlay_labels = {}

local function send_title(prefix)
    if titles[prefix] then send_command('kl title '..prefix..' '..titles[prefix]) end
end

local function bind_rows(rows, lvl, job)
    for _, mod in ipairs(MODS) do
        local row = rows[mod[1]]
        if row and row.title then
            titles[mod[1]] = job..' '..row.title
            send_title(mod[1])
        end
        for i, entry in ipairs(row or {}) do
            if lvl >= (entry[3] or 1) then
                local key = mod[1]..KEYS[i]
                send_command('bind '..key..' '..entry[2])
                send_command('kl set '..key..' '..entry[1])
                active[key] = entry[1]
            end
        end
    end
end

local function send_overlay_labels(rows)
    for key, label in pairs(rows.fkeys or {}) do
        send_command('kl set '..key..' '..label)
        overlay_labels[key] = label
    end
end

function clear_binds()
    for key in pairs(active) do
        send_command('unbind '..key)
    end
    send_command('kl clear')
    active = {}
    titles = {}
    overlay_labels = {}
end

function refresh_binds()
    clear_binds()
    bind_rows(main_rows, player.main_job_level, player.main_job)
    bind_rows({['^!'] = SUB_ROWS[player.sub_job]}, player.sub_job_level or 0, '/'..tostring(player.sub_job))
    send_overlay_labels(main_rows)
end

function set_binds(rows)
    main_rows = rows
    refresh_binds()
end

function sub_job_change()
    refresh_binds()
end

function binds_command(command)
    if CHAINS[command] then
        send_command(CHAINS[command])
        return true
    end
    if command == 'labels' then
        send_command('kl clear')
        for prefix in pairs(titles) do
            send_title(prefix)
        end
        for key, label in pairs(active) do
            send_command('kl set '..key..' '..label)
        end
        for key, label in pairs(overlay_labels) do
            send_command('kl set '..key..' '..label)
        end
        return true
    end
    if command == 'binds' then
        refresh_binds()
        for _, mod in ipairs(MODS) do
            for _, k in ipairs(KEYS) do
                local label = active[mod[1]..k]
                if label then windower.add_to_chat(207, mod[2]..' '..k..': '..label) end
            end
        end
        return true
    end
    return false
end
