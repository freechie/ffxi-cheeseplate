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

-- Overlay descriptions stay short. Ability recasts are the base time, before merits.
local DESCRIPTIONS = {
    ['Camps'] = 'Sakura regen',
    ['EXP'] = 'EXP party',
    ['Trusts'] = 'Trust party',
    ['Raise trusts'] = 'Raise party',
    ['Dismiss'] = 'Release trusts',
    ['Food'] = 'Daifuku',
    ['Echad Ring'] = 'EXP',
    ['Caliber Ring'] = 'EXP',
    ['Emperor Band'] = 'EXP',
    ['Trizek Ring'] = 'CP',
    ['Capacity Ring'] = 'CP',
    ['Warp Ring'] = 'Home',
    ['TP set'] = 'Mummu then TH',
    ['Idle set'] = 'Shoes, pants, Mummu',
    ['TH set'] = 'Lock Mummu',
    ['Feint'] = '-eva',
    ['Weapons'] = 'Level weapons',
    ['Best Waltz'] = 'Best heal',
    ['Utsusemi'] = 'Shadows',

    ['Haste Samba'] = 'Haste',
    ['Drain Samba'] = 'HP drain',
    ['Drain Samba II'] = 'HP drain',
    ['Drain Samba III'] = 'HP drain',
    ['Aspir Samba'] = 'MP drain',
    ['Aspir Samba II'] = 'MP drain',
    ['Box Step'] = '-def',
    ['Quickstep'] = '-eva',
    ['Feather Step'] = '+crit',
    ['Stutter Step'] = '-m.eva',
    ['Reverse'] = 'To TP',
    ['Building'] = 'Boost WS',
    ['C.Waltz II'] = 'Heal',
    ['C.Waltz III'] = 'Heal',
    ['C.Waltz IV'] = 'Heal',
    ['C.Waltz V'] = 'Heal',
    ['D.Waltz II'] = 'AoE heal',
    ['Divine Waltz'] = 'AoE heal',
    ['Healing Waltz'] = 'Erase',
    ['Violent'] = 'Stun',
    ['Climactic'] = 'Crit',
    ['Striking'] = 'DA bonus',
    ['Ternary'] = 'Triple',
    ['Wild'] = 'Skillchain',
    ['Presto'] = '+FM',
    ['No Foot Rise'] = '+FM',
    ['Saber Dance'] = 'DA up',
    ['Fan Dance'] = '-dmg',
    ['Contradance'] = 'Boost waltz',
    ['Animated'] = 'Provoke',
    ['Desperate'] = 'Gravity',
    ['Trance'] = 'Free waltz',
    ['Spectral Jig'] = 'Sneak Invis',
    ['Chocobo Jig II'] = 'Move speed',

    ['Assassin\'s Charge'] = 'Triple hit',
    ['Mighty Strikes'] = 'All crits',
    ['Sneak Attack'] = 'Crit behind',
    ['Trick Attack'] = 'Move hate',
    ['SA'] = 'Crit behind',
    ['TA'] = 'Move hate',
    ['SA Evisc'] = 'Sneak WS',
    ['TA Evisc'] = 'Trick WS',
    ['SATA'] = 'Sneak Trick WS',
    ['Bully'] = 'Intimidate',
    ['Perfect Dodge'] = 'Evade',
    ['Conspirator'] = 'Party acc',
    ['Steal'] = 'Item',
    ['Despoil'] = 'Debuff',
    ['Mug'] = 'Gil',
    ['Flee'] = 'Move speed',
    ['Hide'] = 'Drop hate',
    ['Collab p1'] = 'Share hate',
    ['Collab p2'] = 'Share hate',
    ['Accomplice p1'] = 'Take hate',
    ['Accomplice p2'] = 'Take hate',
    ['Larceny'] = 'Steal buffs',
    ['Ranged'] = 'Shoot',

    ['Utsu Ni'] = 'Shadows',
    ['Utsu Ichi'] = 'Shadows',
    ['Yonin'] = 'Tank',
    ['Innin'] = 'Rear',
    ['Tonko'] = 'Invis',
    ['Tonko: Ichi'] = 'Invis',
    ['Tonko: Ni'] = 'Invis',
    ['Monomi'] = 'Sneak',
    ['Katon'] = 'Fire',
    ['Katon: Ichi'] = 'Fire',
    ['Katon: Ni'] = 'Fire',
    ['Hyoton: Ichi'] = 'Ice',
    ['Hyoton: Ni'] = 'Ice',
    ['Huton: Ichi'] = 'Wind',
    ['Huton: Ni'] = 'Wind',
    ['Doton: Ichi'] = 'Earth',
    ['Doton: Ni'] = 'Earth',
    ['Raiton'] = 'Thunder',
    ['Raiton: Ichi'] = 'Thunder',
    ['Raiton: Ni'] = 'Thunder',
    ['Suiton: Ichi'] = 'Water',
    ['Suiton: Ni'] = 'Water',
    ['Hojo: Ichi'] = 'Slow',
    ['Hojo: Ni'] = 'Slow',
    ['Kurayami: Ichi'] = 'Blind',
    ['Kurayami: Ni'] = 'Blind',
    ['Jubaku: Ichi'] = 'Paralyze',
    ['Dokumori: Ichi'] = 'Poison',
    ['Mijin Gakure'] = 'Sacrifice',

    ['Provoke'] = 'Hate',
    ['Berserk'] = '+atk -def',
    ['Defender'] = '+def -atk',
    ['Warcry'] = 'Party atk',
    ['Aggressor'] = '+acc -eva',

    ['Evisceration'] = 'Physical',
    ['Aeolian Edge'] = 'AoE magic',
    ['Shark Bite'] = 'Physical',
    ['Dancing Edge'] = 'Physical',
    ['Rudra\'s Storm'] = 'Physical',
    ['Exenterator'] = '4-hit',
    ['Pyrrhic Kleos'] = '4-hit',
    ['Mandalic Stab'] = 'Physical',
    ['Shadowstitch'] = 'Bind',
    ['Energy Drain'] = 'Steal MP',
    ['Blade: To'] = 'Ice',
    ['Blade: Ei'] = 'Dark',
    ['Blade: Ku'] = '5-hit',
    ['Blade: Retsu'] = 'Paralyze',
    ['Wasp Sting'] = 'Physical',
    ['Viper Bite'] = 'Physical',
    ['Blade: Jin'] = 'Physical',
    ['Blade: Ten'] = 'Physical',
    ['Blade: Teki'] = 'Water',
    ['Blade: Chi'] = 'Earth',
}

-- Base recast. Shared timers: Steps 5s, Flourish I 30s, Flourish II 30s,
-- Flourish III 1m30s, Sambas 1m, Collaborator/Accomplice 1m.
local COOLDOWNS = {
    ['Sneak Attack'] = '1m', ['SA'] = '1m', ['SA Evisc'] = '1m',
    ['Trick Attack'] = '1m', ['TA'] = '1m', ['TA Evisc'] = '1m',
    ['Feint'] = '2m',
    ['Bully'] = '3m',
    ['Steal'] = '5m', ['Mug'] = '5m', ['Despoil'] = '5m', ['Flee'] = '5m', ['Hide'] = '5m',
    ['Conspirator'] = '5m',
    ['Collab p1'] = '1m', ['Collab p2'] = '1m',
    ['Accomplice p1'] = '1m', ['Accomplice p2'] = '1m',
    ['Perfect Dodge'] = '1h', ['Larceny'] = '1h', ['Trance'] = '1h', ['Mijin Gakure'] = '1h',

    ['Box Step'] = '5s', ['Quickstep'] = '5s', ['Feather Step'] = '5s', ['Stutter Step'] = '5s',
    ['Haste Samba'] = '1m', ['Drain Samba'] = '1m', ['Drain Samba III'] = '1m', ['Aspir Samba II'] = '1m',
    ['Animated'] = '30s', ['Desperate'] = '30s', ['Violent'] = '30s',
    ['Reverse'] = '30s', ['Building'] = '30s', ['Wild'] = '30s',
    ['Climactic'] = '1m30s', ['Striking'] = '1m30s', ['Ternary'] = '1m30s',
    ['No Foot Rise'] = '3m', ['Saber Dance'] = '3m', ['Fan Dance'] = '3m', ['Contradance'] = '5m',
    ['Drain Samba II'] = '1m', ['Aspir Samba'] = '1m',
    ['Assassin\'s Charge'] = '5m', ['Mighty Strikes'] = '1h',
    ['C.Waltz II'] = '8s', ['C.Waltz III'] = '10s', ['C.Waltz IV'] = '13s', ['C.Waltz V'] = '16s',
    ['Healing Waltz'] = '8s', ['Divine Waltz'] = '13s', ['D.Waltz II'] = '20s',
    ['Spectral Jig'] = '30s', ['Chocobo Jig II'] = '1m', ['Presto'] = '15s',

    ['Provoke'] = '30s', ['Berserk'] = '5m', ['Defender'] = '3m', ['Warcry'] = '5m', ['Aggressor'] = '5m',
    ['Yonin'] = '3m', ['Innin'] = '3m',
    ['Utsu Ni'] = '45s', ['Utsu Ichi'] = '30s',
    ['Tonko'] = '30s', ['Tonko: Ichi'] = '30s', ['Tonko: Ni'] = '45s', ['Monomi'] = '30s',
    ['Katon'] = '30s', ['Katon: Ichi'] = '30s', ['Katon: Ni'] = '45s',
    ['Hyoton: Ni'] = '45s', ['Hyoton: Ichi'] = '30s', ['Huton: Ichi'] = '30s', ['Huton: Ni'] = '45s',
    ['Doton: Ni'] = '45s', ['Doton: Ichi'] = '30s',
    ['Raiton'] = '30s', ['Raiton: Ichi'] = '30s', ['Raiton: Ni'] = '45s',
    ['Suiton: Ichi'] = '30s', ['Suiton: Ni'] = '45s',
    ['Hojo: Ichi'] = '30s', ['Hojo: Ni'] = '45s',
    ['Kurayami: Ichi'] = '30s', ['Kurayami: Ni'] = '45s',
    ['Jubaku: Ichi'] = '30s', ['Dokumori: Ichi'] = '30s',
}

local function overlay_text(label)
    local description = DESCRIPTIONS[label]
    local cd = COOLDOWNS[label]
    if description and cd then return label..' - '..description..' '..cd end
    if description then return label..' - '..description end
    if cd then return label..' - '..cd end
    return label
end

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
        {'Perfect Dodge', 'input /ja "Perfect Dodge" <me>', 1},
    },
    NIN = {
        {'Utsu Ni', 'input /ma "Utsusemi: Ni" <me>', 37},
        {'Utsu Ichi', 'input /ma "Utsusemi: Ichi" <me>', 12},
        {'Yonin', 'input /ja "Yonin" <me>', 40},
        {'Innin', 'input /ja "Innin" <me>', 40},
        {'Tonko: Ni', 'input /ma "Tonko: Ni" <me>', 34},
        {'Monomi', 'input /ma "Monomi: Ichi" <me>', 25},
        {'Katon: Ni', 'input /ma "Katon: Ni" <t>', 40},
        {'Huton: Ni', 'input /ma "Huton: Ni" <t>', 40},
        {'Hojo: Ni', 'input /ma "Hojo: Ni" <t>', 48},
        {'Kurayami: Ni', 'input /ma "Kurayami: Ni" <t>', 44},
    },
    -- Subjob cap is 49. Flourish I and Reverse are the full set at that level.
    -- Building (50) and the later flourishes need Dancer as main.
    DNC = {
        {'Box Step', 'input /ja "Box Step" <t>', 23},
        {'Quickstep', 'input /ja "Quickstep" <t>', 20},
        {'Haste Samba', 'input /ja "Haste Samba" <me>', 45},
        {'Animated', 'input /ja "Animated Flourish" <t>', 20},
        {'Desperate', 'input /ja "Desperate Flourish" <t>', 30},
        {'Reverse', 'input /ja "Reverse Flourish" <me>', 40},
        {'Violent', 'input /ja "Violent Flourish" <t>', 45},
        {'C.Waltz III', 'input /ja "Curing Waltz III" <stpc>', 45},
        {'Divine Waltz', 'input /ja "Divine Waltz" <me>', 25},
        {'Healing Waltz', 'input /ja "Healing Waltz" <stpc>', 35},
    },
    WAR = {
        {'Provoke', 'input /ja "Provoke" <t>', 5},
        {'Berserk', 'input /ja "Berserk" <me>', 15},
        {'Defender', 'input /ja "Defender" <me>', 25},
        {'Warcry', 'input /ja "Warcry" <me>', 35},
        {'Aggressor', 'input /ja "Aggressor" <me>', 45},
        {'Mighty Strikes', 'input /ja "Mighty Strikes" <me>', 1},
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
-- Ctrl while Dancer is subbed. Trance is the first open Alt+Shift key.
SUB_ROWS.DNC.title = 'Dancer'

local main_rows = {}
local active = {}
local titles = {}
local overlay_labels = {}

-- Windower treats !1/^1 as key tokens inside send_command, so overlay traffic
-- uses words: `kl set ctrl 2 …` / `kl title alt …` (must match keylabels.lua).
local KL_MOD_ORDER = {'^!', '~^', '~!', '^', '!'}
local KL_MOD = {['^!'] = 'calt', ['~^'] = 'cshift', ['~!'] = 'ashift', ['^'] = 'ctrl', ['!'] = 'alt'}

local function send_kl_set(fullkey, label)
    for _, prefix in ipairs(KL_MOD_ORDER) do
        if fullkey:sub(1, #prefix) == prefix then
            local button = fullkey:sub(#prefix + 1)
            if button ~= '' then
                send_command('kl set '..KL_MOD[prefix]..' '..button..' '..label)
            end
            return
        end
    end
end

local function send_title(prefix)
    local name = KL_MOD[prefix]
    if name and titles[prefix] then
        send_command('kl title '..name..' '..titles[prefix])
    end
end

-- Must match the books written by scripts/sync_macro_names.py.
local MACRO_BOOKS = {DNC = 1, NIN = 5, THF = 10, PUP = 9}
local MACRO_SETS = {['^'] = 1, ['!'] = 1, ['~^'] = 2, ['~!'] = 2, ['^!'] = 3}
-- Alphabetical combo books, set 1. One book per combo; subjob rows are not copied elsewhere.
local COMBO_BOOK = {
    DNC = {NIN = {2, 1}, THF = {3, 1}, WAR = {4, 1}},
    NIN = {DNC = {6, 1}, THF = {7, 1}, WAR = {8, 1}},
    PUP = {DNC = {9, 1}},
    THF = {DNC = {11, 1}, WAR = {12, 1}},
}

local function macro_location(prefix)
    local book = MACRO_BOOKS[player.main_job]
    if not book then return '' end
    local combos = COMBO_BOOK[player.main_job]
    local dnc_book = player.sub_job == 'DNC' and combos and combos.DNC
    -- Dancer abilities take Ctrl, so that palette is the combo book.
    if dnc_book and (prefix == '^' or prefix == '!') then
        return ' book '..dnc_book[1]..' set '..dnc_book[2]
    end
    -- The main Ctrl row moves to Ctrl+Alt and still lives on the main book.
    if dnc_book and prefix == '^!' then
        return ' book '..book..' set 1'
    end
    local set = MACRO_SETS[prefix]
    if prefix == '^!' then
        local where = combos and combos[player.sub_job]
        if where then
            book, set = where[1], where[2]
        end
    end
    return ' book '..book..' set '..set
end

local function bind_rows(rows, lvl, job)
    -- Login reloads the job file before the level packet arrives. A nil
    -- level used to abort get_sets here, which left the overlay empty.
    lvl = tonumber(lvl) or 0
    job = job or ''
    for _, mod in ipairs(MODS) do
        local row = rows[mod[1]]
        if row and row.title then
            local who = row.title
            if job and job ~= '' then who = job..' '..who end
            titles[mod[1]] = who..macro_location(mod[1])
            send_title(mod[1])
        end
        for i, entry in ipairs(row or {}) do
            if lvl >= (entry[3] or 1) then
                local key = mod[1]..KEYS[i]
                send_command('bind '..key..' '..entry[2])
                local label = overlay_text(entry[1])
                send_kl_set(key, label)
                active[key] = label
            end
        end
    end
end

local function send_overlay_labels(rows)
    for key, label in pairs(rows.fkeys or {}) do
        local display = overlay_text(label)
        send_kl_set(key, display)
        overlay_labels[key] = display
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

local FKEY_IDS = {'f1','f2','f3','f4','f5','f6','f7','f8','f9','f10','f11','f12'}

-- Abilities and spells that do not fit the 10-key sub row.
-- Ichi stays beside Ni. Each of those spells has its own recast.
local SUB_EXTRA = {
    DNC = {
        {'Stutter Step', 'input /ja "Stutter Step" <t>', 40},
        {'Drain Samba II', 'input /ja "Drain Samba II" <me>', 35},
        {'Aspir Samba', 'input /ja "Aspir Samba" <me>', 25},
        {'Spectral Jig', 'input /ja "Spectral Jig" <me>', 25},
    },
    NIN = {
        {'Hyoton: Ni', 'input /ma "Hyoton: Ni" <t>', 40},
        {'Doton: Ni', 'input /ma "Doton: Ni" <t>', 40},
        {'Raiton: Ni', 'input /ma "Raiton: Ni" <t>', 40},
        {'Suiton: Ni', 'input /ma "Suiton: Ni" <t>', 40},
        {'Dokumori: Ichi', 'input /ma "Dokumori: Ichi" <t>', 27},
        {'Jubaku: Ichi', 'input /ma "Jubaku: Ichi" <t>', 30},
        {'Katon: Ichi', 'input /ma "Katon: Ichi" <t>', 15},
        {'Hyoton: Ichi', 'input /ma "Hyoton: Ichi" <t>', 15},
        {'Doton: Ichi', 'input /ma "Doton: Ichi" <t>', 15},
        {'Raiton: Ichi', 'input /ma "Raiton: Ichi" <t>', 15},
        {'Suiton: Ichi', 'input /ma "Suiton: Ichi" <t>', 15},
        {'Huton: Ichi', 'input /ma "Huton: Ichi" <t>', 15},
        {'Tonko: Ichi', 'input /ma "Tonko: Ichi" <me>', 9},
    },
}

local function fkey_used(key)
    if active[key] then return true end
    local fkeys = main_rows.fkeys
    return fkeys ~= nil and fkeys[key] ~= nil
end

local function first_free_fkey()
    for _, prefix in ipairs({'!', '^', '~!', '~^'}) do
        for _, fk in ipairs(FKEY_IDS) do
            local key = prefix..fk
            if not fkey_used(key) then return key end
        end
    end
end

local function bind_entry(key, entry)
    send_command('bind '..key..' '..entry[2])
    local label = overlay_text(entry[1])
    send_kl_set(key, label)
    active[key] = label
end

local function bind_overflow(list, lvl)
    lvl = tonumber(lvl) or 0
    for _, entry in ipairs(list or {}) do
        if lvl >= (entry[3] or 1) then
            local key = first_free_fkey()
            if not key then return end
            bind_entry(key, entry)
        end
    end
end

local function bind_trance(sub_lvl)
    if (tonumber(sub_lvl) or 0) < 1 then return end
    local row = main_rows['~!'] or {}
    local key
    if #row < #KEYS then
        key = '~!'..KEYS[#row + 1]
    else
        key = first_free_fkey()
    end
    if not key then return end
    bind_entry(key, {'Trance', 'input /ja "Trance" <me>'})
end

local function select_macro_book()
    if not player or not player.main_job then return end
    local book = MACRO_BOOKS[player.main_job]
    local set_no = 1
    if not book then return end
    if player.sub_job == 'DNC' then
        local where = COMBO_BOOK[player.main_job] and COMBO_BOOK[player.main_job].DNC
        if where then
            book, set_no = where[1], where[2]
        end
    end
    send_command('input /macro book '..book..'; wait 0.1; input /macro set '..set_no)
end

function refresh_binds()
    clear_binds()
    local main_lvl = player.main_job_level
    local sub_lvl = player.sub_job_level or 0
    local job = player.main_job
    local sub = player.sub_job
    -- Dancer subjob takes Ctrl. The main Ctrl row moves to Ctrl+Alt.
    if sub == 'DNC' and main_rows['^'] then
        local rest = {}
        for key, row in pairs(main_rows) do
            if key ~= '^' and key ~= 'fkeys' then
                rest[key] = row
            end
        end
        bind_rows(rest, main_lvl, job)
        bind_rows({['^!'] = main_rows['^']}, main_lvl, job)
        bind_rows({['^'] = SUB_ROWS.DNC}, sub_lvl, '')
    else
        bind_rows(main_rows, main_lvl, job)
        bind_rows({['^!'] = SUB_ROWS[sub]}, sub_lvl, '/'..tostring(sub))
    end
    if sub == 'DNC' then
        bind_trance(sub_lvl)
    end
    if SUB_EXTRA[sub] then
        bind_overflow(SUB_EXTRA[sub], sub_lvl)
    end
    send_overlay_labels(main_rows)
    select_macro_book()
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
            send_kl_set(key, label)
        end
        for key, label in pairs(overlay_labels) do
            send_kl_set(key, label)
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
