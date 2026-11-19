_addon.name = 'screenfit'
_addon.author = 'Cheeseplate'
_addon.version = '2.5'
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
-- Top-left of the 4x4 grid on a 1920x1080 UI. Tuned so UI scale 1.5
-- (1707x960) lands at 1470,841. Right and bottom pins keep that gap.
local EQUIP = {x = 1683, y = 961, right = true, bottom = true}
local GEAR_COLS = 4

-- FFXIDB uses window pixels, not UI pixels. This is the 2560x1440 spot.
-- The same fraction of the window is used on 1920x1080 (1514, 669).
local MAP = {x = 2018, y = 892, w = 2560, h = 1440}

-- These read the window size when they load. Unload saves memory over the file,
-- so the cheeseplate block is written again after unload, then they load.
local ANCHORED = {'Debuffed', 'targetinfo', 'SpeedChecker', 'findAll'}
local SNAPSHOT = {'DistancePlus'}

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
    -- Right only (never bottom+right — texts.lua drag corrupts y and it walks away).
    -- y is 1080p top: old bottom gap -210 → 1080-210=870.
    ['addons\\SpeedChecker\\data\\settings.xml'] = [[<cheeseplate>
        <flags>
            <bottom>false</bottom>
            <draggable>false</draggable>
            <right>true</right>
        </flags>
        <pos>
            <x>-297</x>
            <y>870</y>
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
-- When true, skip forcing Speed / Distance / enemybar positions so you can drag them.
local arranging = false

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

local function read_file(path)
    local fh = io.open(path, 'r')
    if not fh then return end
    local text = fh:read('*a')
    fh:close()
    return text
end

local function replace_cheeseplate(path, block)
    local fh = io.open(path, 'r')
    if not fh then return end
    local text = fh:read('*a')
    fh:close()
    local start_at = text:find('<cheeseplate>', 1, true)
    local end_at = text:find('</cheeseplate>', 1, true)
    if start_at and end_at then
        text = text:sub(1, start_at - 1) .. block .. text:sub(end_at + #'</cheeseplate>')
    else
        local close = text:find('</settings>', 1, true)
        if not close then return end
        text = text:sub(1, close - 1) .. block .. '\n' .. text:sub(close)
    end
    fh = io.open(path, 'w')
    if not fh then return end
    fh:write(text)
    fh:close()
end

-- Cheeseplate is also the Cheeseplate character block (config merges by name).
-- Keep <global> in sync so unload/reload cannot leave a drifted global-only file.
local function patch_speed_global(path, x, y, draggable)
    local text = read_file(path)
    if not text then return end
    local g0, g1 = text:find('<global>', 1, true), text:find('</global>', 1, true)
    if not g0 or not g1 then return end
    local global = text:sub(g0, g1 - 1)
    local drag = draggable and 'true' or 'false'
    global = global:gsub('<bottom>[^<]*</bottom>', '<bottom>false</bottom>', 1)
    global = global:gsub('<right>[^<]*</right>', '<right>true</right>', 1)
    global = global:gsub('<draggable>[^<]*</draggable>', '<draggable>' .. drag .. '</draggable>', 1)
    global = global:gsub(
        '(<pos>%s*<x>)[^<]*(</x>%s*<y>)[^<]*(</y>)',
        '%1' .. tostring(x) .. '%2' .. tostring(y) .. '%3',
        1)
    text = text:sub(1, g0 - 1) .. global .. text:sub(g1)
    local fh = io.open(path, 'w')
    if not fh then return end
    fh:write(text)
    fh:close()
end

local function speed_block(x, y, draggable)
    local drag = draggable and 'true' or 'false'
    return string.format([[<cheeseplate>
        <flags>
            <bottom>false</bottom>
            <draggable>%s</draggable>
            <right>true</right>
        </flags>
        <pos>
            <x>%s</x>
            <y>%s</y>
        </pos>
    </cheeseplate>]], drag, tostring(x), tostring(y))
end

-- Recover a usable top-left y from bottom-anchored or corrupted SpeedChecker saves.
local function normalize_speed_pos(text, h)
    h = h or BASE_H
    local sx, sy = -297, BASE_H - 210
    local src = text:match('<cheeseplate>(.-)</cheeseplate>') or text
    local bottom = tostring(src:match('<bottom>%s*([^<]*)</bottom>') or ''):lower() == 'true'
    local px = tonumber(src:match('<pos>%s*<x>([^<]*)</x>'))
    local py = tonumber(src:match('<pos>%s*<y>([^<]*)</y>'))
    if not px or not py then return sx, sy end
    if bottom then
        if py < 0 then
            py = h + py
        end
        -- Corrupted saves often keep bottom=true with an absolute y (~700–900).
    end
    if py < 0 or py > h + 50 then
        return sx, sy
    end
    return px, math.floor(py + 0.5)
end

local function write_speed(x, y, draggable)
    local root = root_path()
    if not root then return end
    local path = root .. 'addons\\SpeedChecker\\data\\settings.xml'
    local block = speed_block(x, y, draggable)
    BLOCKS['addons\\SpeedChecker\\data\\settings.xml'] = block
    replace_cheeseplate(path, block)
    patch_speed_global(path, x, y, draggable)
end

local DISTANCE_SECTIONS = {'main', 'heighttxt', 'pettxt', 'abilitytxt'}

-- Last matching section wins (character block overrides global).
local function read_distance_pos(xml, section)
    local x, y
    for block in xml:gmatch('<' .. section .. '>(.-)</' .. section .. '>') do
        local px = tonumber(block:match('<pos>%s*<x>([^<]*)</x>'))
        local py = tonumber(block:match('<pos>%s*<y>([^<]*)</y>'))
        if px and py then x, y = px, py end
    end
    return x, y
end

local function read_distance_layout(xml)
    local pos = {}
    for _, section in ipairs(DISTANCE_SECTIONS) do
        local x, y = read_distance_pos(xml, section)
        if not (x and y) then return nil end
        pos[section] = {x = x, y = y}
    end
    return pos
end

local function distance_block(pos, draggable)
    local drag = draggable and 'true' or 'false'
    local parts = {'<cheeseplate>'}
    for _, section in ipairs(DISTANCE_SECTIONS) do
        local p = pos[section]
        parts[#parts + 1] = string.format([[
        <%s>
            <flags>
                <draggable>%s</draggable>
                <right>true</right>
            </flags>
            <pos>
                <x>%s</x>
                <y>%s</y>
            </pos>
        </%s>]], section, drag, tostring(p.x), tostring(p.y), section)
    end
    parts[#parts + 1] = '    </cheeseplate>'
    return table.concat(parts, '\n')
end

local function patch_distance_global(path, pos, draggable)
    local text = read_file(path)
    if not text then return end
    local drag = draggable and 'true' or 'false'
    for _, section in ipairs(DISTANCE_SECTIONS) do
        local p = pos[section]
        local block = text:match('<' .. section .. '>(.-)</' .. section .. '>')
        if block and p then
            if block:find('<draggable>', 1, true) then
                block = block:gsub('<draggable>[^<]*</draggable>', '<draggable>' .. drag .. '</draggable>')
            elseif block:find('<flags>', 1, true) then
                block = block:gsub('<flags>', '<flags>\n                <draggable>' .. drag .. '</draggable>', 1)
            else
                block = '<flags>\n                <draggable>' .. drag .. '</draggable>\n                <right>true</right>\n            </flags>\n            ' .. block
            end
            block = block:gsub(
                '(<pos>%s*<x>)[^<]*(</x>%s*<y>)[^<]*(</y>)',
                '%1' .. tostring(p.x) .. '%2' .. tostring(p.y) .. '%3',
                1)
            text = text:gsub('<' .. section .. '>.-</' .. section .. '>',
                '<' .. section .. '>' .. block .. '</' .. section .. '>', 1)
        end
    end
    local fh = io.open(path, 'w')
    if not fh then return end
    fh:write(text)
    fh:close()
end

local function write_distance(pos, draggable)
    local root = root_path()
    if not root or not pos then return end
    local path = root .. 'addons\\DistancePlus\\data\\settings.xml'
    local block = distance_block(pos, draggable)
    BLOCKS['addons\\DistancePlus\\data\\settings.xml'] = block
    replace_cheeseplate(path, block)
    patch_distance_global(path, pos, draggable)
end

local function set_distance_draggable(draggable)
    local root = root_path()
    if not root then return end
    local path = root .. 'addons\\DistancePlus\\data\\settings.xml'
    local text = read_file(path) or ''
    local pos = read_distance_layout(text)
    if not pos then return end
    write_distance(pos, draggable)
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
    local sp_block = BLOCKS['addons\\SpeedChecker\\data\\settings.xml']
    if sp_block then
        local x = tonumber(sp_block:match('<x>([^<]*)</x>'))
        local y1080 = tonumber(sp_block:match('<y>([^<]*)</y>'))
        local drag = tostring(sp_block:match('<draggable>([^<]*)</draggable>') or ''):lower() == 'true'
        local _, h = ui_size()
        if x and y1080 then
            -- BLOCK y is 1080p absolute; shift so the bottom gap survives UI scale changes.
            local y = y1080 + ((h or BASE_H) - BASE_H)
            local live = speed_block(x, y, drag)
            replace_cheeseplate(root .. 'addons\\SpeedChecker\\data\\settings.xml', live)
            patch_speed_global(root .. 'addons\\SpeedChecker\\data\\settings.xml', x, y, drag)
        end
    end
    local dp_block = BLOCKS['addons\\DistancePlus\\data\\settings.xml']
    if dp_block and not arranging then
        local pos = read_distance_layout(dp_block)
        if pos then
            write_distance(pos, false)
        end
    elseif not arranging then
        set_distance_draggable(false)
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
    if (mw or 0) >= 2200 or (mh or 0) >= 1300 then return '1.5' end
    return '1.2'
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
    ['1080'] = {scale = '1.2', label = '1920x1080'},
    ['1440'] = {scale = '1.5', label = '2560x1440'},
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
    if not arranging then
        for _, bar in ipairs(ENEMYBAR) do
            local x, y = place(bar[2], bar[3], w, h, bar[4], bar[5])
            windower.send_command('eb set pos ' .. bar[1] .. ' ' .. x .. ' ' .. y)
        end
    end
    local sw, sh = window_size()
    if not sw then return end
    local mx, my = map_pos(sw, sh)
    write_map(sw, sh)
    windower.send_command('ffxidb pos ' .. mx .. ' ' .. my)
    -- Reload last so the minimap draws above EquipViewer images.
    windower.send_command('wait 0.5; unload FFXIDB; wait 0.2; load FFXIDB; wait 0.2; ffxidb pos ' .. mx .. ' ' .. my)
end

local function read_xml_pos(text, tag)
    if tag then
        local block = text:match('<' .. tag .. '>(.-)</' .. tag .. '>')
        if not block then return end
        text = block
    end
    local x = tonumber(text:match('<pos>%s*<x>([^<]*)</x>'))
    local y = tonumber(text:match('<pos>%s*<y>([^<]*)</y>'))
    return x, y
end

-- Convert a live UI pixel into the 1920x1080 base used by ENEMYBAR pins.
local function to_base(px, py, w, h, pin_right, pin_bottom)
    local x, y = px, py
    if pin_right then x = px - (w - BASE_W) end
    if pin_bottom then y = py - (h - BASE_H) end
    return math.floor(x + 0.5), math.floor(y + 0.5)
end

local function patch_enemybar_defaults(t_x, t_y, st_x, st_y, ft_x, ft_y)
    local path = windower.addon_path .. 'screenfit.lua'
    local text = read_file(path)
    if not text then return false end
    local repl = string.format(
        "local ENEMYBAR = {\n    {'target', %d, %d, true, false},\n    {'subtarget', %d, %d, true, false},\n    {'focustarget', %d, %d, true, false},\n}",
        t_x, t_y, st_x, st_y, ft_x, ft_y)
    local updated, n = text:gsub('local ENEMYBAR = %b{}', repl, 1)
    if n == 0 then return false end
    local fh = io.open(path, 'w')
    if not fh then return false end
    fh:write(updated)
    fh:close()
    ENEMYBAR = {
        {'target', t_x, t_y, true, false},
        {'subtarget', st_x, st_y, true, false},
        {'focustarget', ft_x, ft_y, true, false},
    }
    return true
end

local function capture_hud_layout()
    local root = root_path()
    local w, h = ui_size()
    if not root or not w then return false, 'no UI size' end

    local eb = read_file(root .. 'addons\\enemybar2\\data\\settings.xml') or ''
    -- Prefer character block values when present (last matching pos per bar name).
    local function bar_xy(name)
        local x, y
        for block in eb:gmatch('<' .. name .. '_bar>(.-)</' .. name .. '_bar>') do
            local px, py = read_xml_pos(block)
            if px and py then x, y = px, py end
        end
        return x, y
    end
    local tx, ty = bar_xy('target')
    local stx, sty = bar_xy('subtarget')
    local ftx, fty = bar_xy('focustarget')
    if not (tx and stx and ftx) then return false, 'enemybar positions missing' end
    local bt_x, bt_y = to_base(tx, ty, w, h, true, false)
    local bs_x, bs_y = to_base(stx, sty, w, h, true, false)
    local bf_x, bf_y = to_base(ftx, fty, w, h, true, false)
    if not patch_enemybar_defaults(bt_x, bt_y, bs_x, bs_y, bf_x, bf_y) then
        return false, 'could not write ENEMYBAR defaults'
    end

    local sp = read_file(root .. 'addons\\SpeedChecker\\data\\settings.xml') or ''
    local sx, sy = normalize_speed_pos(sp, h)
    -- Persist 1080p base in BLOCKS; write live pixels to the settings file.
    local base_y = sy - (h - BASE_H)
    BLOCKS['addons\\SpeedChecker\\data\\settings.xml'] = speed_block(sx, base_y, false)
    write_speed(sx, sy, false)

    local dp = read_file(root .. 'addons\\DistancePlus\\data\\settings.xml') or ''
    local dpos = read_distance_layout(dp)
    if not dpos then return false, 'distance positions missing' end
    write_distance(dpos, false)
    return true
end

-- SpeedChecker / DistancePlus: unload can overwrite a just-written settings file.
-- Always unload first, then write, then load — never write then lua r.
-- DistancePlus also saves on drag-release and on unload (patched to pass root settings).
local function begin_arrange()
    if arranging then
        windower.add_to_chat(207, '[screenfit] Already arranging. Drag, then //fit lock.')
        return
    end
    arranging = true
    windower.send_command('eb setup on')
    windower.send_command('lua unload SpeedChecker; lua unload DistancePlus')
    windower.send_command('wait 0.3; fit arrangedrag')
    windower.add_to_chat(207, '[screenfit] Arrange mode: drag Speed, Distance, and HP bars.')
    windower.add_to_chat(207, '[screenfit] Distance: drag the number. HP: drag each bar.')
    windower.add_to_chat(207, '[screenfit] When happy: //fit lock')
end

local function arrange_enable_drag()
    local root = root_path()
    local _, h = ui_size()
    if not root then return end
    local sp = read_file(root .. 'addons\\SpeedChecker\\data\\settings.xml') or ''
    local sx, sy = normalize_speed_pos(sp, h)
    write_speed(sx, sy, true)
    set_distance_draggable(true)
    windower.send_command('lua load SpeedChecker')
    windower.send_command('lua load DistancePlus')
end

local function end_arrange()
    if not arranging then
        windower.add_to_chat(207, '[screenfit] Not arranging. //fit unlock first.')
        return
    end
    windower.send_command('eb setup off')
    -- Unload flushes Speed (texts save) and DistancePlus (unload handler) to disk
    -- before capture reads and owns those positions.
    windower.send_command('lua unload SpeedChecker; lua unload DistancePlus')
    windower.send_command('wait 0.3; fit arrangelock')
end

local function arrange_finish_lock()
    local ok, why = capture_hud_layout()
    arranging = false
    windower.send_command('lua load SpeedChecker')
    windower.send_command('lua load DistancePlus')
    local w, h = ui_size()
    if ok and w then
        for _, bar in ipairs(ENEMYBAR) do
            local x, y = place(bar[2], bar[3], w, h, bar[4], bar[5])
            windower.send_command('eb set pos ' .. bar[1] .. ' ' .. x .. ' ' .. y)
        end
        windower.add_to_chat(207, '[screenfit] Locked. Speed / Distance / HP positions saved.')
    elseif ok then
        windower.add_to_chat(207, '[screenfit] Locked. Speed / Distance / HP positions saved.')
    else
        windower.add_to_chat(167, '[screenfit] Locked arrange mode, but capture failed: ' .. tostring(why))
    end
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
    -- DistancePlus is not unloaded on a resize. Reload it.
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
    if resize then
        windower.send_command('unload timers')
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
        elseif extra == '1.2' then
            write_uiscale('1.2', '', true)
        elseif extra == '1.4' then
            write_uiscale('1.4', '', true)
        elseif extra == '1.45' then
            write_uiscale('1.45', '', true)
        elseif extra == '1.5' then
            write_uiscale('1.5', '', true)
        elseif extra == '1.6' then
            write_uiscale('1.6', '', true)
        elseif extra == '1.55' then
            write_uiscale('1.55', '', true)
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
    elseif cmd == 'unlock' or cmd == 'arrange' then
        begin_arrange()
        return
    elseif cmd == 'arrangedrag' then
        arrange_enable_drag()
        return
    elseif cmd == 'lock' or cmd == 'savehud' then
        end_arrange()
        return
    elseif cmd == 'arrangelock' then
        arrange_finish_lock()
        return
    end
    windower.add_to_chat(207, 'screenfit: //fit unlock | //fit lock | //fit window | //fit fill | //fit other')
end)
