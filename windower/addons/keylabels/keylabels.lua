_addon.name = 'keylabels'
_addon.author = 'Cheeseplate'
_addon.version = '1.0'
_addon.commands = {'keylabels', 'kl'}

-- Shows number-row and function-key bind labels while a modifier combo is held.
-- GearSwap's binds.lua feeds it with `kl clear`, `kl set <key> <label>`, and `kl title <prefix> <title>`.

local config = require('config')
local texts = require('texts')

local defaults = {
    pos = {x = 20, y = 300},
    text = {font = 'Consolas', size = 10},
    bg = {alpha = 200},
    flags = {draggable = false},
}
local settings = config.load(defaults)
local box = texts.new('', settings)

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

    local lines = {}
    if prefix then
        for _, k in ipairs(KEYS) do
            local label = labels[prefix..k]
            if label then
                local display_key = k:match('^f') and k:upper() or k
                lines[#lines + 1] = display_key..'  '..label
            end
        end
    end
    if #lines == 0 then
        box:hide()
        return
    end
    local heading = TITLES[prefix]
    if titles[prefix] then heading = heading..': '..titles[prefix] end
    box:text(heading..'\n'..table.concat(lines, '\n'))
    box:show()
end

windower.register_event('load', function()
    windower.send_command('gs c labels')
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
    elseif cmd == 'pos' and tonumber(key) and tonumber((...)) then
        settings.pos.x, settings.pos.y = tonumber(key), tonumber((...))
        box:pos(settings.pos.x, settings.pos.y)
        config.save(settings)
        return
    else
        windower.add_to_chat(207, 'keylabels: //kl pos <x> <y> moves the box')
        return
    end
    shown = false
    update()
end)
