_addon.name = 'keylabels'
_addon.author = 'Cheeseplate'
_addon.version = '2.7'
_addon.commands = {'keylabels', 'kl'}

-- Shows number-row and function-key bind labels while a modifier combo is held.
-- GearSwap feeds: `kl clear`, `kl set <mod> <button> <label>`, `kl title <mod> <title>`.
-- mod is ctrl|alt|cshift|ashift|calt so Windower never sees !1/^1 in send_command.

local config = require('config')
local texts = require('texts')

-- Mid-left, below Timers (recast/buffs/custom at y≈70). Keep clear of that top row.
local defaults = {
    pos = {x = 20, y = 400},
    positions = {
        heading = {x = 20, y = 400},
        actions = {x = 20, y = 428},
        descriptions = {x = 185, y = 428},
    },
    locked = true,
    layout_version = 0,
    bg = {alpha = 140, red = 8, green = 12, blue = 24, visible = true},
}
local settings = config.load(defaults)

-- Migrate the old grouped position once, with extra heading clearance.
if settings.layout_version < 2 then
    settings.positions.heading.x = settings.pos.x
    settings.positions.heading.y = settings.pos.y
    settings.positions.actions.x = settings.pos.x
    settings.positions.actions.y = settings.pos.y + 28
    settings.positions.descriptions.x = settings.pos.x + 165
    settings.positions.descriptions.y = settings.pos.y + 28
    settings.layout_version = 2
    settings.locked = true
    config.save(settings)
end

local function visual_settings(pos, size, red, green, blue, bold)
    local bg = settings.bg or {}
    return {
        pos = {x = pos.x, y = pos.y},
        text = {
            font = 'Consolas',
            size = size,
            red = red,
            green = green,
            blue = blue,
            stroke = {width = 1, alpha = 255, red = 0, green = 0, blue = 0},
        },
        bg = {
            alpha = bg.alpha or 140,
            red = bg.red or 8,
            green = bg.green or 12,
            blue = bg.blue or 24,
        },
        padding = 4,
        flags = {draggable = false, bold = bold},
    }
end

-- These must use independent tables; sharing one makes position/color updates collide.
local heading_box
local left_box
local description_box
local dragged_overlay = false
local panels = {}
local shown = false

local function destroy_box(box)
    if box and box.destroy then box:destroy() end
end

local function apply_positions()
    for name, box in pairs(panels) do
        local pos = settings.positions[name]
        box:pos(pos.x, pos.y)
    end
end

local function apply_lock()
    for _, box in pairs(panels) do
        box:draggable(not settings.locked)
    end
end

local function make_draggable(name, box)
    box:register_event('drag', function(_, x, y)
        dragged_overlay = true
        settings.positions[name].x = x
        settings.positions[name].y = y
    end)
end

-- Text objects created before logout do not draw again. Rebuild them on login.
local function rebuild_boxes()
    destroy_box(heading_box)
    destroy_box(left_box)
    destroy_box(description_box)
    heading_box = texts.new('', visual_settings(settings.positions.heading, 10, 255, 165, 40, true))
    left_box = texts.new('', visual_settings(settings.positions.actions, 10, 120, 200, 255, false))
    description_box = texts.new('', visual_settings(settings.positions.descriptions, 10, 255, 255, 255, false))
    panels.heading = heading_box
    panels.actions = left_box
    panels.descriptions = description_box
    make_draggable('heading', heading_box)
    make_draggable('actions', left_box)
    make_draggable('descriptions', description_box)
    apply_positions()
    apply_lock()
    shown = false
end

rebuild_boxes()

local KEYS = {
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
    'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10', 'f11', 'f12',
}
local TITLES = {
    ['^'] = 'Ctrl',
    ['!'] = 'Alt',
    ['~^'] = 'Ctrl+Shift',
    ['~!'] = 'Alt+Shift',
    ['^!'] = 'Ctrl+Alt',
}
-- DirectInput scan codes: left and right of each modifier.
local MOD_KEYS = {
    [29] = 'ctrl', [157] = 'ctrl',
    [56] = 'alt', [184] = 'alt',
    [42] = 'shift', [54] = 'shift',
}

local labels = {}
local titles = {}
local down = {}

-- Must match KL_MOD names in GearSwap/data/binds.lua.
local MOD_FROM_NAME = {
    ctrl = '^', alt = '!', cshift = '~^', ashift = '~!', calt = '^!',
}

local function held(mod)
    for code in pairs(down) do
        if MOD_KEYS[code] == mod then return true end
    end
    return false
end

local function current_prefix()
    local c, a, s = held('ctrl'), held('alt'), held('shift')
    if c and a then return '^!' end
    if c then return s and '~^' or '^' end
    if a then return s and '~!' or '!' end
end

local function update()
    local prefix = current_prefix()
    if prefix == shown then return end
    shown = prefix

    local left_lines = {}
    local description_lines = {}
    if prefix then
        for _, k in ipairs(KEYS) do
            local label = labels[prefix..k]
            if label then
                local display_key = k:match('^f') and k:upper() or k
                local action, description = label:match('^(.-) %- (.+)$')
                action = action or label
                left_lines[#left_lines + 1] = display_key..'  '..action
                description_lines[#description_lines + 1] = description or ''
            end
        end
    end
    if #left_lines == 0 then
        left_box:hide()
        description_box:hide()
        heading_box:hide()
        return
    end
    local heading = TITLES[prefix]
    if titles[prefix] then heading = heading..': '..titles[prefix] end
    heading_box:text(heading)
    left_box:text(table.concat(left_lines, '\n'))
    description_box:text(table.concat(description_lines, '\n'))
    heading_box:show()
    left_box:show()
    description_box:show()
end

-- GearSwap reloads the job file on its own about 2s after login, which is
-- before job level exists, so that pass errors and the overlay stays empty.
-- Wait until the character is actually in, then reload once.
local generation = 0
local gear_loaded = false

local function player_ready()
    local player = windower.ffxi.get_player()
    local level = player and tonumber(player.main_job_level)
    if not player or not player.main_job_id or not player.vitals or not level or level < 1 then
        return false
    end
    return windower.ffxi.get_mob_by_index(player.index) ~= nil
end

local function kick()
    generation = generation + 1
    windower.send_command('wait 1; kl recover '..generation..' 1')
end

local function recover(gen, attempt)
    gen = tonumber(gen) or 0
    attempt = tonumber(attempt) or 1
    if gen ~= generation or gear_loaded then return end
    if not player_ready() then
        if attempt < 20 then
            windower.send_command('wait 2; kl recover '..gen..' '..(attempt + 1))
        end
        return
    end
    gear_loaded = true
    windower.send_command('gs reload')
    windower.send_command('wait 1; gs c labels')
    windower.add_to_chat(207, '[keylabels] GearSwap reloaded')
end

windower.register_event('load', function()
    if player_ready() then
        gear_loaded = true
        windower.send_command('wait 1; gs c labels')
    end
    windower.add_to_chat(207, '[keylabels] v2.7 loaded - //kl unlock to arrange')
end)

windower.register_event('login', function()
    settings = config.load(defaults)
    down = {}
    labels = {}
    titles = {}
    gear_loaded = false
    rebuild_boxes()
    kick()
end)

windower.register_event('logout', function()
    generation = generation + 1
    gear_loaded = false
    down = {}
    shown = false
    labels = {}
    titles = {}
    if heading_box then heading_box:hide() end
    if left_box then left_box:hide() end
    if description_box then description_box:hide() end
end)

windower.register_event('job change', function()
    windower.send_command('wait 3; gs c labels')
end)

-- Reload saves memory over the file. Read the file first so an edit to the
-- background alpha is not replaced by the value from when the addon loaded.
local function pull_bg()
    local fh = io.open(windower.addon_path .. 'data/settings.xml', 'r')
    if not fh then return end
    local text = fh:read('*a') or ''
    fh:close()
    local alpha, red, green, blue
    for body in text:gmatch('<bg>(.-)</bg>') do
        alpha = tonumber(body:match('<alpha>(%d+)</alpha>')) or alpha
        red = tonumber(body:match('<red>(%d+)</red>')) or red
        green = tonumber(body:match('<green>(%d+)</green>')) or green
        blue = tonumber(body:match('<blue>(%d+)</blue>')) or blue
    end
    settings.bg = settings.bg or {}
    if alpha then settings.bg.alpha = alpha end
    if red then settings.bg.red = red end
    if green then settings.bg.green = green end
    if blue then settings.bg.blue = blue end
end

local function save_settings()
    pull_bg()
    config.save(settings)
end

windower.register_event('mouse', function(event_type)
    if event_type == 2 and dragged_overlay then
        dragged_overlay = false
        save_settings()
    end
end)

windower.register_event('unload', function()
    save_settings()
end)

windower.register_event('keyboard', function(dik, pressed)
    if not MOD_KEYS[dik] then return end
    down[dik] = pressed or nil
    update()
end)

windower.register_event('addon command', function(cmd, key, ...)
    cmd = cmd and cmd:lower()
    if cmd == 'clear' then
        labels = {}
        titles = {}
    elseif cmd == 'set' and key then
        local args = {...}
        local mod = MOD_FROM_NAME[key:lower()]
        if mod and args[1] then
            labels[mod..args[1]:lower()] = table.concat(args, ' ', 2)
        end
    elseif cmd == 'title' and key then
        local mod = MOD_FROM_NAME[key:lower()]
        if mod then titles[mod] = table.concat({...}, ' ') end
    elseif cmd == 'unlock' then
        settings.locked = false
        apply_lock()
        windower.add_to_chat(207, '[keylabels] Unlocked: hold a modifier and drag each panel.')
        return
    elseif cmd == 'lock' then
        settings.locked = true
        apply_lock()
        save_settings()
        windower.add_to_chat(207, '[keylabels] Locked and saved.')
        return
    elseif cmd == 'pos' and tonumber(key) and tonumber((...)) then
        local x, y = tonumber(key), tonumber((...))
        local dx = x - settings.positions.heading.x
        local dy = y - settings.positions.heading.y
        for _, pos in pairs(settings.positions) do
            pos.x, pos.y = pos.x + dx, pos.y + dy
        end
        apply_positions()
        save_settings()
        return
    elseif cmd == 'refresh' then
        windower.send_command('gs c labels')
        return
    elseif cmd == 'recover' then
        recover(key, (...))
        return
    else
        windower.add_to_chat(207, 'keylabels: //kl unlock | lock | pos <x> <y> | refresh')
        return
    end
    shown = false
    update()
end)
