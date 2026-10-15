_addon.name = 'keylabels'
_addon.author = 'Cheeseplate'
_addon.version = '2.0'
_addon.commands = {'keylabels', 'kl'}

-- Shows number-row and function-key bind labels while a modifier combo is held.
-- GearSwap's binds.lua feeds it with `kl clear`, `kl set <key> <label>`, and `kl title <prefix> <title>`.

local config = require('config')
local texts = require('texts')

local defaults = {
    pos = {x = 20, y = 300},
    positions = {
        heading = {x = 20, y = 300},
        actions = {x = 20, y = 328},
        descriptions = {x = 185, y = 328},
    },
    locked = true,
    layout_version = 0,
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
        bg = {alpha = 210, red = 8, green = 12, blue = 24},
        padding = 4,
        flags = {draggable = false, bold = bold},
    }
end

-- These must use independent tables; sharing one makes position/color updates collide.
local heading_box = texts.new('', visual_settings(settings.positions.heading, 10, 255, 165, 40, true))
local left_box = texts.new('', visual_settings(settings.positions.actions, 10, 70, 170, 255, false))
local description_box = texts.new('', visual_settings(settings.positions.descriptions, 10, 255, 255, 255, false))

local dragged_overlay = false

local panels = {
    heading = heading_box,
    actions = left_box,
    descriptions = description_box,
}

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

make_draggable('heading', heading_box)
make_draggable('actions', left_box)
make_draggable('descriptions', description_box)
apply_positions()
apply_lock()

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
local shown

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

windower.register_event('load', function()
    windower.send_command('gs c labels')
    windower.add_to_chat(207, '[keylabels] v2.0 loaded - //kl unlock to arrange')
end)

windower.register_event('mouse', function(event_type)
    if event_type == 2 and dragged_overlay then
        dragged_overlay = false
        config.save(settings)
    end
end)

windower.register_event('unload', function()
    config.save(settings)
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
        labels[key] = table.concat({...}, ' ')
    elseif cmd == 'title' and key then
        titles[key] = table.concat({...}, ' ')
    elseif cmd == 'unlock' then
        settings.locked = false
        apply_lock()
        windower.add_to_chat(207, '[keylabels] Unlocked: hold a modifier and drag each panel.')
        return
    elseif cmd == 'lock' then
        settings.locked = true
        apply_lock()
        config.save(settings)
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
        config.save(settings)
        return
    else
        windower.add_to_chat(207, 'keylabels: //kl unlock | lock | pos <x> <y>')
        return
    end
    shown = false
    update()
end)
