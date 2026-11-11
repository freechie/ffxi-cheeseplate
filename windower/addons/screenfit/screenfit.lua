_addon.name = 'screenfit'
_addon.author = 'Cheeseplate'
_addon.version = '2.3'
_addon.commands = {'screenfit', 'fit'}

-- Cheeseplate's HUD was laid out in a 1920x1080 window. Edge pieces are stored
-- as offsets (right/bottom flags) so they stick when the window changes size.
-- Timers, equipviewer, and enemybar only store absolute pixels, so this addon
-- shifts those when the UI resolution changes. It also reloads the anchored
-- addons, because they read the window size once at load.

local BASE_W, BASE_H = 1920, 1080

local TIMERS = {
    -- Left stack. keylabels start at y=400.
    RecastX = 20, RecastY = 340,
    -- One lower row, side by side, so a full stack stays above the chat
    -- and the party list. Bottom pin keeps that gap when the height changes.
    BuffsX = 900, BuffsY = 652,
    CustomX = 1140, CustomY = 652,
}

-- Right-edge gap is BASE_W - x. Top-edge y stays. Bottom-edge gap is BASE_H - y.
local ENEMYBAR = {
    {'target', 1278, 76, true, false},
    {'subtarget', 1282, 161, true, false},
    {'focustarget', 1271, 111, true, false},
}
-- Top-left of the 4x4 grid on a 1920x1080 UI. The grid is 112px, so this
-- sits just left of the target health bar and lines up with its bottom edge.
-- Right and bottom pins keep that same corner gap when the UI size changes.
local EQUIP = {x = 1674, y = 949, right = true, bottom = true}
local GEAR_COLS = 4

-- FFXIDB uses window pixels, not UI pixels. This is the 2560x1440 spot.
-- The same fraction of the window is used on 1920x1080 (1514, 669).
local MAP = {x = 2018, y = 892, w = 2560, h = 1440}

-- These read the window size when they load. Unload saves memory over the file,
-- so the cheeseplate block is written again after unload, then they load.
local ANCHORED = {'Debuffed', 'targetinfo', 'SpeedChecker', 'findAll'}
local SNAPSHOT = {'DistancePlus', 'invtracker'}

local BLOCKS = {
    -- Right anchor only. texts.lua mis-computes the grab point when right
    -- and bottom are both set, and the first drag saves the box off-screen.
    -- y is the 1080p top of the old bottom offset (-370).
    ['addons\\Debuffed\\data\\settings.xml'] = [[<cheeseplate>
        <flags>
            <bottom>false</bottom>
            <draggable>true</draggable>
            <right>true</right>
        </flags>
        <pos>
            <x>-697</x>
            <y>710</y>
        </pos>
    </cheeseplate>]],
    ['addons\\targetinfo\\data\\settings.xml'] = [[<cheeseplate>
        <display>
            <flags>
                <bottom>false</bottom>
                <draggable>true</draggable>
                <right>true</right>
            </flags>
            <pos>
                <x>-338</x>
                <y>548</y>
            </pos>
        </display>
    </cheeseplate>]],
    ['addons\\SpeedChecker\\data\\settings.xml'] = [[<cheeseplate>
        <flags>
            <bottom>true</bottom>
            <draggable>false</draggable>
            <right>true</right>
        </flags>
        <pos>
            <x>-297</x>
            <y>-210</y>
        </pos>
    </cheeseplate>]],
    ['addons\\findAll\\data\\settings.xml'] = [[<cheeseplate>
        <Tracker>
            <pos>
                <x>-323</x>
                <y>-70</y>
            </pos>
        </Tracker>
    </cheeseplate>]],
}

local applied_w, applied_h
local ticking = 0

local function ui_size()
    local s = windower.get_windower_settings()
    local w = s.ui_x_res or s.x_res
    local h = s.ui_y_res or s.y_res
    if not w or not h or w < 640 or h < 480 then return end
    return w, h
end

local function window_size()
    local s = windower.get_windower_settings()
    local w, h = s.x_res, s.y_res
    if not w or not h or w < 640 or h < 480 then return end
    return w, h
end

local function map_pos(sw, sh)
    return math.floor(MAP.x * sw / MAP.w + 0.5), math.floor(MAP.y * sh / MAP.h + 0.5)
end

local function place(x, y, w, h, pin_right, pin_bottom)
    if pin_right then x = x + (w - BASE_W) end
    if pin_bottom then y = y + (h - BASE_H) end
    return math.floor(x + 0.5), math.floor(y + 0.5)
end

local function root_path()
    return windower.addon_path:match('^(.*)addons[\\/]screenfit[\\/]')
end

local function replace_cheeseplate(path, block)
    local fh = io.open(path, 'r')
    if not fh then return end
    local text = fh:read('*a')
    fh:close()
    local start_at = text:find('<cheeseplate>', 1, true)
    local end_at = text:find('</cheeseplate>', 1, true)
    if not start_at or not end_at then return end
    text = text:sub(1, start_at - 1) .. block .. text:sub(end_at + #'</cheeseplate>')
    fh = io.open(path, 'w')
    if not fh then return end
    fh:write(text)
    fh:close()
end

local function clear_track(path)
    local fh = io.open(path, 'r')
    if not fh then return end
    local text = fh:read('*a')
    fh:close()
    local start_at = text:find('<Track>', 1, true)
    local end_at = text:find('</Track>', 1, true)
    if not start_at or not end_at then return end
    text = text:sub(1, start_at - 1) .. '<Track></Track>' .. text:sub(end_at + #'</Track>')
    fh = io.open(path, 'w')
    if not fh then return end
    fh:write(text)
    fh:close()
end

local function write_anchors()
    local root = root_path()
    if not root then return end
    for rel, block in pairs(BLOCKS) do
        replace_cheeseplate(root .. rel, block)
    end
    clear_track(root .. 'addons\\findAll\\data\\settings.xml')
end

-- Menu scale is read from settings.xml when Windower launches. Moving the
-- window saves the scale for the window size just set. The menus use it on
-- the next launch. The HUD refits as soon as the window size changes.
local helper_exe
local helper_rebuilt = false

local function compile_helper(dir, exe)
    local csc = (os.getenv('WINDIR') or 'C:\\Windows') .. '\\Microsoft.NET\\Framework\\v4.0.30319\\csc.exe'
    if os.execute then
        os.execute('"' .. csc .. '" /nologo /t:exe /out:"' .. exe .. '" "' .. dir .. 'monitor.cs"')
    end
end

local function ensure_helper()
    if helper_exe then return helper_exe end
    local dir = windower.addon_path
    local exe = dir .. 'monitor.exe'
    local fh = io.open(exe, 'rb')
    if not fh then compile_helper(dir, exe) end
    if fh then fh:close() end
    fh = io.open(exe, 'rb')
    if not fh then return end
    fh:close()
    helper_exe = exe
    return exe
end

-- Reads the game window. The window can be changed only from inside Windower,
-- so this helper never moves it.
local function run_monitor()
    local exe = ensure_helper()
    if not exe or not io.popen then return end
    local out = windower.addon_path .. 'monitor.txt'
    os.remove(out)
    local cmd = '"' .. exe .. '" "' .. out .. '"'
    local fh = io.popen(cmd, 'r')
    if fh then fh:close() end
    local rf = io.open(out, 'r')
    if not rf then return end
    local text = rf:read('*a') or ''
    rf:close()
    if not text:find('here ', 1, true) and not helper_rebuilt then
        helper_rebuilt = true
        helper_exe = nil
        compile_helper(windower.addon_path, exe)
        helper_exe = exe
        return run_monitor()
    end
    local function grab(key)
        local w, h, x, y = text:match(key .. ' (%d+)x(%d+) ([%-]?%d+) ([%-]?%d+)')
        return tonumber(w), tonumber(h), tonumber(x), tonumber(y)
    end
    local ww, wh, wx, wy = grab('window')
    if not ww then return end
    local mons = {}
    for i, w, h, x, y in text:gmatch('mon (%d+) (%d+)x(%d+) ([%-]?%d+) ([%-]?%d+)') do
        mons[tonumber(i)] = {w = tonumber(w), h = tonumber(h), x = tonumber(x), y = tonumber(y)}
    end
    for i, w, h, x, y in text:gmatch('work (%d+) (%d+)x(%d+) ([%-]?%d+) ([%-]?%d+)') do
        local mon = mons[tonumber(i)]
        if mon then
            mon.ww, mon.wh, mon.wx, mon.wy = tonumber(w), tonumber(h), tonumber(x), tonumber(y)
        end
    end
    return {
        ww = ww, wh = wh, wx = wx, wy = wy,
        framed = text:match('frame (%d)') == '1',
        here = tonumber(text:match('here (%d+)')) or 0,
        count = tonumber(text:match('count (%d+)')) or 1,
        mons = mons,
    }
end

local function scale_for(mw, mh)
    if (mw or 0) >= 2200 or (mh or 0) >= 1300 then return '1.45' end
    return '1'
end

local function write_uiscale(scale, label, report)
    local root = root_path()
    if not root then return end
    local path = root .. 'settings.xml'
    local fh = io.open(path, 'r')
    if not fh then return end
    local text = fh:read('*a')
    fh:close()
    local current = text:match('<uiscale>([^<]*)</uiscale>')
    if not current or current == scale then
        if report then
            windower.add_to_chat(207, '[screenfit] UI scale ' .. scale .. ' already saved' .. label .. '. Restart the game to apply it.')
        end
        return false
    end
    text = text:gsub('<uiscale>[^<]*</uiscale>', '<uiscale>' .. scale .. '</uiscale>', 1)
    fh = io.open(path, 'w')
    if not fh then return end
    fh:write(text)
    fh:close()
    if report then
        windower.add_to_chat(207, '[screenfit] UI scale ' .. scale .. ' saved' .. label .. '. Restart the game to apply it.')
    end
    return true
end

local function log_line(msg)
    local fh = io.open(windower.addon_path .. 'screenfit.log', 'a')
    if not fh then return end
    fh:write(os.date('%H:%M:%S ') .. msg .. '\n')
    fh:close()
end

local function describe(info)
    if not info then return 'unread' end
    local frame = info.framed and 'on' or 'off'
    return 'frame ' .. frame .. ' ' .. (info.ww or 0) .. 'x' .. (info.wh or 0) .. ' at ' .. (info.wx or 0) .. ',' .. (info.wy or 0)
end

-- Borderless mode snaps the window back onto the whole monitor. A move only
-- counts once the frame matches and the rect is no longer that monitor.
local function landed(info, x, y, w, h, want_frame, mon)
    if not info or info.framed ~= want_frame then return false end
    if math.abs((info.wx or 0) - x) > 30 or math.abs((info.wy or 0) - y) > 30 then return false end
    if mon and (w ~= mon.w or h ~= mon.h) then
        if info.ww == mon.w and info.wh == mon.h and (info.wx or 0) == mon.x and (info.wy or 0) == mon.y then
            return false
        end
    end
    if math.abs(info.ww - w) > 64 or math.abs(info.wh - h) > 64 then return false end
    return true
end

local function place_window(mode)
    local info = run_monitor()
    if not info or not info.mons[info.here] then
        windower.add_to_chat(207, '[screenfit] Could not read the game window.')
        return
    end
    local index = info.here
    if mode == 'other' then
        if info.count < 2 then
            windower.add_to_chat(207, '[screenfit] Only one monitor is connected.')
            return
        end
        index = (info.here + 1) % info.count
    end
    local mon = info.mons[index]
    if not mon then
        windower.add_to_chat(207, '[screenfit] Could not read the monitor.')
        return
    end
    local framed = mode == 'window'
    local x, y, w, h
    if framed then
        x, y, w, h = mon.wx or mon.x, mon.wy or mon.y, mon.ww or mon.w, mon.wh or mon.h
    else
        x, y, w, h = mon.x, mon.y, mon.w, mon.h
    end

    local function push()
        local now = run_monitor()
        if now and now.framed ~= framed then
            log_line('window_toggleframe')
            windower.send_command('window_toggleframe')
            coroutine.sleep(0.35)
        end
        log_line('wincontrol move ' .. x .. ' ' .. y .. ' resize ' .. w .. ' ' .. h)
        windower.send_command('wincontrol move ' .. x .. ' ' .. y)
        windower.send_command('wincontrol resize ' .. w .. ' ' .. h)
        coroutine.sleep(0.5)
        return run_monitor()
    end

    log_line('place ' .. mode .. ' from ' .. describe(info))
    local after = push()
    log_line('after ' .. describe(after))
    if not landed(after, x, y, w, h, framed, mon) then
        log_line('window_togglefullscreen')
        windower.send_command('window_togglefullscreen')
        coroutine.sleep(0.4)
        after = push()
        log_line('after unlock ' .. describe(after))
    end

    if not landed(after, x, y, w, h, framed, mon) then
        windower.add_to_chat(207, '[screenfit] The window stayed ' .. describe(after) .. '.')
        return
    end

    local aw, ah = after.ww, after.wh
    local scale = scale_for(aw, ah)
    local saved = write_uiscale(scale, ' for the ' .. aw .. 'x' .. ah .. ' window', false)
    local moved = after.ww ~= info.ww or after.wh ~= info.wh or (after.wx or 0) ~= (info.wx or 0) or (after.wy or 0) ~= (info.wy or 0)
    if moved then
        windower.send_command('fit apply')
    end
    local how = after.framed and 'Windowed' or 'Borderless'
    local where = how .. ' ' .. aw .. 'x' .. ah .. '. Menu scale ' .. scale .. '.'
    if saved then
        windower.add_to_chat(207, '[screenfit] ' .. where .. ' Restart PlayOnline to apply the menu scale. The HUD refits now.')
    else
        windower.add_to_chat(207, '[screenfit] ' .. where)
    end
end

local PRESETS = {
    ['1080'] = {scale = '1', label = '1920x1080'},
    ['1440'] = {scale = '1.45', label = '2560x1440'},
}

-- Save the menu scale for the monitor you are about to switch to.
local function prepare_monitor(kind)
    local preset = PRESETS[kind]
    if not preset then return false end
    write_uiscale(preset.scale, '', false)
    windower.add_to_chat(207, '[screenfit] Menu scale ' .. preset.scale .. ' saved for the ' .. preset.label .. ' monitor. Switch to that screen, then restart PlayOnline once.')
    return true
end

-- Unloading Timers saves its memory over Timers.xml and wipes this list.
-- Keep a copy beside this addon and write it back after that save.
local trust_filter

local function load_trust_filter()
    local fh = io.open(windower.addon_path .. 'trust_filter.txt', 'r')
    if not fh then return end
    local text = fh:read('*a') or ''
    fh:close()
    trust_filter = text:gsub('^%s+', ''):gsub('%s+$', '')
end

local function apply_trust_filter(text)
    if not trust_filter or trust_filter == '' then return text end
    local block = '<SpellRecastFilter>' .. trust_filter .. '</SpellRecastFilter>'
    local updated, n = text:gsub('<SpellRecastFilter%s*/>', block, 1)
    if n > 0 then return updated end
    return (text:gsub('<SpellRecastFilter>.-</SpellRecastFilter>', block, 1))
end

local function write_timers(w, h)
    local root = root_path()
    if not root then return end
    local path = root .. 'plugins\\settings\\Timers.xml'
    local fh = io.open(path, 'r')
    if not fh then return end
    local text = fh:read('*a')
    fh:close()
    local bx, by = place(TIMERS.BuffsX, TIMERS.BuffsY, w, h, true, true)
    local cx, cy = place(TIMERS.CustomX, TIMERS.CustomY, w, h, true, true)
    local values = {
        RecastX = TIMERS.RecastX, RecastY = TIMERS.RecastY,
        BuffsX = bx, BuffsY = by,
        CustomX = cx, CustomY = cy,
    }
    for tag, value in pairs(values) do
        text = text:gsub('(<' .. tag .. '>)[^<]*', '%1' .. tostring(value), 1)
    end
    text = apply_trust_filter(text)
    fh = io.open(path, 'w')
    if not fh then return end
    fh:write(text)
    fh:close()
end

local function write_map(sw, sh)
    local root = root_path()
    if not root then return end
    local path = root .. 'plugins\\settings\\ffxidb.xml'
    local fh = io.open(path, 'r')
    if not fh then return end
    local text = fh:read('*a')
    fh:close()
    local x, y = map_pos(sw, sh)
    local start_at = text:find('<Cheeseplate>', 1, true)
    local end_at = text:find('</Cheeseplate>', 1, true)
    if not start_at or not end_at then return x, y end
    local block = text:sub(start_at, end_at + #'</Cheeseplate>' - 1)
    block = block:gsub('(<X>)[^<]*', '%1' .. x, 1)
    block = block:gsub('(<Y>)[^<]*', '%1' .. y, 1)
    text = text:sub(1, start_at - 1) .. block .. text:sub(end_at + #'</Cheeseplate>')
    fh = io.open(path, 'w')
    if not fh then return x, y end
    fh:write(text)
    fh:close()
    return x, y
end

local function gear_pos(w, h)
    return place(EQUIP.x, EQUIP.y, w, h, EQUIP.right, EQUIP.bottom)
end

local function read_equip(text)
    local x, y, span
    local size = tonumber(text:match('<size>(%d+)</size>')) or 28
    for px, py in text:gmatch('<pos>%s*<x>([^<]*)</x>%s*<y>([^<]*)</y>') do
        x, y = tonumber(px), tonumber(py)
    end
    span = size * GEAR_COLS
    return x, y, span
end

local function gear_offscreen(x, y, span, w, h)
    if not x or not y then return true end
    return x < 0 or y < 0 or (x + span) > (w + 2) or (y + span) > (h + 2)
end

-- EquipViewer saves whatever is in memory on unload. Write the corner position
-- into the file first, then tell the running addon, so a 1080p coordinate
-- cannot stay parked past the edge of a larger monitor's UI.
local function write_equip(x, y)
    local root = root_path()
    if not root then return end
    local path = root .. 'addons\\equipviewer\\data\\settings.xml'
    local fh = io.open(path, 'r')
    if not fh then return end
    local text = fh:read('*a')
    fh:close()
    local updated = text:gsub('(<pos>%s*<x>)[^<]*(</x>%s*<y>)[^<]*', '%1' .. x .. '%2' .. y)
    if updated == text then return end
    fh = io.open(path, 'w')
    if not fh then return end
    fh:write(updated)
    fh:close()
end

local function place_gear(w, h, force)
    local root = root_path()
    if not root then return end
    local path = root .. 'addons\\equipviewer\\data\\settings.xml'
    local fh = io.open(path, 'r')
    if not fh then return end
    local text = fh:read('*a')
    fh:close()
    local x, y = gear_pos(w, h)
    local fx, fy, span = read_equip(text)
    if fx == x and fy == y then return end
    if not force and fx and not gear_offscreen(fx, fy, span, w, h) then return end
    write_equip(x, y)
    windower.send_command('ev pos ' .. x .. ' ' .. y)
end

local function shift_commands(w, h)
    place_gear(w, h, true)
    for _, bar in ipairs(ENEMYBAR) do
        local x, y = place(bar[2], bar[3], w, h, bar[4], bar[5])
        windower.send_command('eb set pos ' .. bar[1] .. ' ' .. x .. ' ' .. y)
    end
    local sw, sh = window_size()
    if not sw then return end
    local mx, my = map_pos(sw, sh)
    write_map(sw, sh)
    windower.send_command('ffxidb pos ' .. mx .. ' ' .. my)
end

local pending_w, pending_h
-- Startup loads each HUD addon once. A later size change has to unload first,
-- because unload writes memory back over the settings file.
local booted = false

local function load_hud()
    for _, name in ipairs(ANCHORED) do
        windower.send_command('lua load ' .. name)
    end
    windower.send_command('load timers')
    -- DistancePlus and invtracker are not unloaded on a resize. Reload those.
    local how = booted and 'lua r ' or 'lua load '
    for _, name in ipairs(SNAPSHOT) do
        windower.send_command(how .. name)
    end
    booted = true
end

local function commit()
    write_anchors()
    if pending_w then write_timers(pending_w, pending_h) end
    load_hud()
    if pending_w then
        windower.add_to_chat(207, '[screenfit] HUD fit to ' .. pending_w .. 'x' .. pending_h)
    end
end

local function apply()
    local w, h = ui_size()
    if not w or (w == applied_w and h == applied_h) then return end
    local resize = booted
    applied_w, applied_h = w, h
    pending_w, pending_h = w, h
    shift_commands(w, h)
    -- Timers saves its current spot over the file on unload. Unload first on
    -- a fresh load too, so a reload cannot write the old spot back.
    windower.send_command('unload timers')
    if resize then
        for _, name in ipairs(ANCHORED) do
            windower.send_command('lua unload ' .. name)
        end
    end
    windower.send_command('wait 1; fit commit')
end

load_trust_filter()

windower.register_event('load', function()
    load_trust_filter()
    windower.send_command('wait 2; fit apply')
end)

windower.register_event('prerender', function()
    ticking = ticking + 1
    if ticking < 180 then return end
    ticking = 0
    apply()
end)

windower.register_event('addon command', function(cmd, extra)
    cmd = cmd and cmd:lower()
    extra = extra and extra:lower()
    if cmd == '1080' or cmd == '1440' then
        prepare_monitor(cmd)
        return
    elseif cmd == 'commit' then
        commit()
        return
    elseif cmd == 'apply' or cmd == 'now' then
        applied_w, applied_h = nil, nil
        apply()
        return
    elseif cmd == 'scale' then
        if extra == '1080' or extra == '1440' then
            prepare_monitor(extra)
        elseif extra == '1' or extra == '1.0' then
            write_uiscale('1', '', true)
        elseif extra == '1.4' then
            write_uiscale('1.4', '', true)
        elseif extra == '1.45' then
            write_uiscale('1.45', '', true)
        elseif extra == '1.5' then
            write_uiscale('1.5', '', true)
        else
            local info = run_monitor()
            if not info then
                windower.add_to_chat(207, '[screenfit] Could not read the window. Use //fit 1080 or //fit 1440.')
                return
            end
            write_uiscale(scale_for(info.ww, info.wh), ' for the ' .. info.ww .. 'x' .. info.wh .. ' window', true)
        end
        return
    elseif cmd == 'window' or cmd == 'fill' or cmd == 'other' then
        place_window(cmd)
        return
    end
    windower.add_to_chat(207, 'screenfit: //fit window | //fit fill | //fit other')
end)
