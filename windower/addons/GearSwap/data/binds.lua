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

-- Overlay descriptions are intentionally limited to three words.
local DESCRIPTIONS = {
    ['Camps'] = 'Sakura regen party',
    ['EXP'] = 'Kupofried EXP party',
    ['Trusts'] = 'Balanced trust party',
    ['Raise trusts'] = 'Safer raise party',
    ['Dismiss'] = 'Release all trusts',
    ['Food'] = 'Use combat food',
    ['Echad Ring'] = 'EXP bonus',
    ['Caliber Ring'] = 'EXP bonus',
    ['Emperor Band'] = 'EXP bonus',
    ['Trizek Ring'] = 'CP bonus',
    ['Capacity Ring'] = 'CP bonus',
    ['Warp Ring'] = 'Return home',
    ['TP set'] = 'Cycle TP gear',
    ['Idle set'] = 'Cycle idle gear',
    ['TH set'] = 'Toggle treasure hunter',
    ['Weapons'] = 'Level-based weapons',
    ['Best Waltz'] = 'Auto-tier heal',
    ['Utsusemi'] = 'Create shadows (-Shihei)',

    ['Haste Samba'] = 'Party haste',
    ['Drain Samba'] = 'Party HP drain',
    ['Drain Samba III'] = 'Party HP drain',
    ['Aspir Samba II'] = 'Party MP drain',
    ['Box Step'] = 'Lower enemy defense (+FMs)',
    ['Quickstep'] = 'Lower enemy evasion (+FMs)',
    ['Feather Step'] = 'Raise crit rate (+FMs)',
    ['Stutter Step'] = 'Lower magic evasion (+FMs)',
    ['Reverse'] = 'Convert moves TP (-FMs)',
    ['Building'] = 'Boost next WS (-FMs)',
    ['C.Waltz II'] = 'Single target heal',
    ['C.Waltz III'] = 'Single target heal',
    ['C.Waltz IV'] = 'Single target heal',
    ['C.Waltz V'] = 'Single target heal',
    ['D.Waltz II'] = 'Party healing',
    ['Divine Waltz'] = 'Party healing',
    ['Healing Waltz'] = 'Remove status effect',
    ['Violent'] = 'Stun target (-1 FM)',
    ['Climactic'] = 'Force crit hit (-FMs)',
    ['Striking'] = 'Double attack bonus (-2 FMs)',
    ['Wild'] = 'Enables skillchain (-2 FMs)',
    ['Presto'] = 'Bonus FMs (+FMs)',
    ['Animated'] = 'Provoke with moves (-1 FM)',
    ['Desperate'] = 'Gravity with moves (-1 FM)',
    ['Trance'] = 'Free waltzes',
    ['Spectral Jig'] = 'Sneak and invisible',
    ['Chocobo Jig II'] = 'Faster movement',

    ['Sneak Attack'] = 'Crit from behind',
    ['Trick Attack'] = 'Transfer enmity',
    ['SA'] = 'Crit from behind',
    ['TA'] = 'Transfer enmity',
    ['SA Evisc'] = 'Sneak Evisceration',
    ['TA Evisc'] = 'Trick Evisceration',
    ['SATA'] = 'Sneak Trick WS',
    ['Bully'] = 'Intimidate target',
    ['Perfect Dodge'] = 'Evade physical attacks',
    ['Conspirator'] = 'Party ACC bonus',
    ['Steal'] = 'Steal item',
    ['Despoil'] = 'Steal and debuff',
    ['Mug'] = 'Steal gil',
    ['Flee'] = 'Faster movement',
    ['Hide'] = 'Shed enemy hate',
    ['Collab p1'] = 'Take some enmity',
    ['Collab p2'] = 'Take some enmity',
    ['Accomplice p1'] = 'Take more enmity',
    ['Accomplice p2'] = 'Take more enmity',
    ['Larceny'] = 'Steal beneficial effects',
    ['Ranged'] = 'Ranged attack',

    ['Utsu Ni'] = 'Create shadows (-Shihei)',
    ['Utsu Ichi'] = 'Create shadows (-Shihei)',
    ['Yonin'] = 'Tank stance (enmity+ ACC-)',
    ['Innin'] = 'Rear stance (dmg+ enmity-)',
    ['Tonko'] = 'Invisible (-Shinobi-tabi)',
    ['Tonko: Ni'] = 'Invisible (-Shinobi-tabi)',
    ['Monomi'] = 'Sneak (-Sairui-Ran)',
    ['Katon'] = 'Fire dmg (water-res-) (-Uchitake)',
    ['Katon: Ichi'] = 'Fire dmg (water-res-) (-Uchitake)',
    ['Katon: Ni'] = 'Fire dmg (water-res-) (-Uchitake)',
    ['Hyoton: Ni'] = 'Ice dmg (fire-res-) (-Tsurara)',
    ['Huton: Ichi'] = 'Wind dmg (ice-res-) (-Kawahori-Ogi)',
    ['Huton: Ni'] = 'Wind dmg (ice-res-) (-Kawahori-Ogi)',
    ['Doton: Ni'] = 'Earth dmg (wind-res-) (-Makibishi)',
    ['Raiton'] = 'Lightning dmg (earth-res-) (-Hiraishin)',
    ['Raiton: Ichi'] = 'Lightning dmg (earth-res-) (-Hiraishin)',
    ['Raiton: Ni'] = 'Lightning dmg (earth-res-) (-Hiraishin)',
    ['Suiton: Ichi'] = 'Water dmg (lightning-res-) (-Mizu-Deppo)',
    ['Suiton: Ni'] = 'Water dmg (lightning-res-) (-Mizu-Deppo)',
    ['Hojo: Ichi'] = 'Slow target (-Kaginawa)',
    ['Hojo: Ni'] = 'Slow target (-Kaginawa)',
    ['Kurayami: Ichi'] = 'Blind target (-Sairui-Ran)',
    ['Kurayami: Ni'] = 'Blind target (-Sairui-Ran)',
    ['Jubaku: Ichi'] = 'Paralyze target (-Jusatsu)',
    ['Dokumori: Ichi'] = 'Poison target (-Kodoku)',
    ['Mijin Gakure'] = 'Sacrifice for damage',

    ['Provoke'] = 'Gain enmity',
    ['Berserk'] = 'ATK up DEF-down',
    ['Defender'] = 'DEF up ATK-down',
    ['Warcry'] = 'Party ATK boost',
    ['Aggressor'] = 'ACC up EVA-down',

    ['Evisceration'] = 'Physical WS',
    ['Aeolian Edge'] = 'AoE magic damage',
    ['Shark Bite'] = 'Physical WS',
    ['Dancing Edge'] = 'Physical WS',
    ['Wasp Sting'] = 'Physical WS',
    ['Viper Bite'] = 'Physical WS',
    ['Blade: Jin'] = 'Physical WS',
    ['Blade: Ten'] = 'Physical WS',
    ['Blade: Teki'] = 'Water WS',
    ['Blade: Chi'] = 'Earth WS',
}

local function overlay_text(label)
    local description = DESCRIPTIONS[label]
    return description and (label..' - '..description) or label
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
    THF = {WAR = {11, 1}},
}

local function macro_location(prefix)
    local book = MACRO_BOOKS[player.main_job]
    if not book then return '' end
    local set = MACRO_SETS[prefix]
    if prefix == '^!' then
        local combos = COMBO_BOOK[player.main_job]
        local where = combos and combos[player.sub_job]
        if where then
            book, set = where[1], where[2]
        end
    end
    return ' (book '..book..' set '..set..')'
end

local function bind_rows(rows, lvl, job)
    -- Login reloads the job file before the level packet arrives. A nil
    -- level used to abort get_sets here, which left the overlay empty.
    lvl = tonumber(lvl) or 0
    job = job or ''
    for _, mod in ipairs(MODS) do
        local row = rows[mod[1]]
        if row and row.title then
            titles[mod[1]] = job..' '..row.title..macro_location(mod[1])
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
