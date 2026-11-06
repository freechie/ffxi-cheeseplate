_addon.name = 'padmacros'
_addon.author = 'Cheeseplate'
_addon.version = '1.1'
_addon.commands = {'padmacros', 'pad'}

local bit = require('bit')
local socket = require('socket')

local LEFT_SHOULDER = 0x0100
local RIGHT_SHOULDER = 0x0200
local DPAD_UP = 0x0001
local DPAD_DOWN = 0x0002
local START = 0x0010
local BACK = 0x0020
local LEFT_THUMB = 0x0040
local RIGHT_THUMB = 0x0080
local A = 0x1000
local X = 0x4000
local Y = 0x8000
local TRIGGER = 80

-- Same order on every page. RB shifts that set onto the function-key row.
local SELECT = {
    [DPAD_UP] = {pad = '1', fpad = 'f1'},
    [DPAD_DOWN] = {pad = '3', fpad = 'f3'},
    [Y] = {pad = '5', fpad = 'f5'},
    [LEFT_THUMB] = {pad = '6', fpad = 'f6'},
    [A] = {pad = '7', fpad = 'f7'},
    [X] = {pad = '8', fpad = 'f8'},
    [BACK] = {pad = '9', fpad = 'f9'},
    [START] = {pad = '0', fpad = 'f10'},
    [RIGHT_THUMB] = {fpad = 'f11'},
}

-- Same pages as the keylabels overlay. Number and function keys pick the row.
local KEY_FROM_DIK = {
    [2] = '1', [3] = '2', [4] = '3', [5] = '4', [6] = '5',
    [7] = '6', [8] = '7', [9] = '8', [10] = '9', [11] = '0',
    [59] = 'f1', [60] = 'f2', [61] = 'f3', [62] = 'f4', [63] = 'f5',
    [64] = 'f6', [65] = 'f7', [66] = 'f8', [67] = 'f9', [68] = 'f10',
    [87] = 'f11', [88] = 'f12',
}

local key_down = {}
local layer
local view
local prev_buttons = 0
local state_path
local watcher_ok = false

local function read_pad()
    if not state_path then return nil end
    local handle = io.open(state_path, 'r')
    if not handle then return nil end
    local line = handle:read('*l')
    handle:close()
    if not line then return nil end
    local buttons, lt, rt, stamp = line:match('^(%d+)%s+(%d+)%s+(%d+)%s+(%d+)')
    if not buttons then return nil end
    stamp = tonumber(stamp)
    -- A dead watcher used to leave the last trigger value in this file, so the
    -- Alt page stayed up after LT was released.
    local age = socket.gettime() * 1000 - stamp
    if age > 500 or age < -2000 then return nil end
    return {
        buttons = tonumber(buttons),
        lt = tonumber(lt),
        rt = tonumber(rt),
    }
end

local function layer_name(pad)
    local lt = pad.lt >= TRIGGER
    local rt = pad.rt >= TRIGGER
    local lb = bit.band(pad.buttons, LEFT_SHOULDER) ~= 0
    if lb and lt and rt then return 'cast' end
    if lt and rt then return 'calt' end
    if lb and lt then return 'ashift' end
    if lb and rt then return 'cshift' end
    if lt then return 'alt' end
    if rt then return 'ctrl' end
end

local function show_layer(name, next_view)
    if name == layer and next_view == view then return end
    layer = name
    view = next_view
    if name then
        windower.send_command('kl show '..name..' '..next_view)
    else
        windower.send_command('kl hide')
    end
end

local function start_watcher()
    state_path = windower.addon_path .. 'data\\pad.state'
    windower.create_dir(windower.addon_path .. 'data')
    local pythonw = 'C:\\Users\\jrmol\\AppData\\Local\\Programs\\Python\\Python313\\pythonw.exe'
    local script = windower.addon_path .. 'xinput_watch.py'
    local cmd = 'start "" /MIN "' .. pythonw .. '" "' .. script .. '" "' .. state_path .. '"'
    watcher_ok = os.execute(cmd) ~= nil
end

local function poll()
    if not watcher_ok then return end
    local pad = read_pad()
    if not pad then
        show_layer(nil, nil)
        prev_buttons = 0
        return
    end
    local name = layer_name(pad)
    if not name then
        show_layer(nil, nil)
        prev_buttons = pad.buttons
        return
    end
    local next_view = bit.band(pad.buttons, RIGHT_SHOULDER) ~= 0 and 'fpad' or 'pad'
    show_layer(name, next_view)
    local pressed = bit.band(pad.buttons, bit.bnot(prev_buttons))
    for mask, keys in pairs(SELECT) do
        if bit.band(pressed, mask) ~= 0 then
            local key = keys[next_view]
            if key then
                windower.send_command('gs c pad '..name..' '..key)
            end
        end
    end
    prev_buttons = pad.buttons
end

windower.register_event('load', function()
    start_watcher()
    if watcher_ok then
        windower.add_to_chat(207, 'Pad macros: hold LT, RT, LT+RT, LB+LT, LB+RT, or LB+LT+RT, then a pad button. Hold RB for the function keys.')
    else
        windower.add_to_chat(167, 'Pad macros: the controller watcher did not start.')
    end
end)

windower.register_event('unload', function()
    show_layer(nil, nil)
end)

windower.register_event('keyboard', function(dik, pressed)
    if not layer or not KEY_FROM_DIK[dik] then return end
    if pressed then
        if key_down[dik] then return true end
        key_down[dik] = true
        windower.send_command('gs c pad '..layer..' '..KEY_FROM_DIK[dik])
    else
        key_down[dik] = nil
    end
    return true
end)

windower.register_event('prerender', poll)
