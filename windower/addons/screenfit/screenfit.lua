_addon.name = 'screenfit'
_addon.author = 'Cheeseplate'
_addon.version = '1.7'
_addon.commands = {'screenfit', 'fit'}

-- Cheeseplate's HUD was laid out in a 1920x1080 window. Edge pieces are stored
-- as offsets (right/bottom flags) so they stick when the window changes size.
-- Timers, equipviewer, and enemybar only store absolute pixels, so this addon
-- shifts those when the UI resolution changes. It also reloads the anchored
-- addons, because they read the window size once at load.

local BASE_W, BASE_H = 1920, 1080

local TIMERS = {
    RecastX = 20, RecastY = 70,
    BuffsX = 900, BuffsY = 320,
    CustomX = 900, CustomY = 520,
}

-- Right-edge gap is BASE_W - x. Top-edge y stays. Bottom-edge gap is BASE_H - y.
local ENEMYBAR = {
    {'target', 1278, 76, true, false},
    {'subtarget', 1282, 161, true, false},
    {'focustarget', 1271, 111, true, false},
}
-- //ev pos 1575 900 on the 1440p UI (about 1828x1028 at scale 1.4).
-- Right and bottom pins keep that same corner gap on the 1080p window.
local EQUIP = {x = 1667, y = 952, right = true, bottom = true}

-- These read the window size when they load. Unload saves memory over the file,
-- so the cheeseplate block is written again after unload, then they load.
local ANCHORED = {'Debuffed', 'targetinfo', 'SpeedChecker', 'findAll'}
local SNAPSHOT = {'DistancePlus', 'invtracker'}

local BLOCKS = {
    ['addons\\Debuffed\\data\\settings.xml'] = [[<cheeseplate>
        <flags>
            <bottom>true</bottom>
            <draggable>true</draggable>
            <right>true</right>
        </flags>
        <pos>
            <x>-697</x>
            <y>-370</y>
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

-- Menu scale is read from settings.xml when Windower launches. //fit scale reads
-- the monitor the game window is on and saves 1.4 for 2560x1440 or 1 for
-- 1920x1080. Nothing checks the monitor during play. A change applies on the
-- next launch.
local helper_exe

local function ensure_helper()
    if helper_exe then return helper_exe end
    local dir = windower.addon_path
    local exe = dir .. 'monitor.exe'
    local fh = io.open(exe, 'rb')
    if fh then
        fh:close()
        helper_exe = exe
        return exe
    end
    local csc = (os.getenv('WINDIR') or 'C:\\Windows') .. '\\Microsoft.NET\\Framework\\v4.0.30319\\csc.exe'
    if os.execute then
        os.execute('"' .. csc .. '" /nologo /t:exe /out:"' .. exe .. '" "' .. dir .. 'monitor.cs"')
    end
    fh = io.open(exe, 'rb')
    if not fh then return end
    fh:close()
    helper_exe = exe
    return exe
end

local function monitor_size()
    local exe = ensure_helper()
    if not exe or not io.popen then return end
    local out = windower.addon_path .. 'monitor.txt'
    local fh = io.popen('"' .. exe .. '" "' .. out .. '"', 'r')
    if not fh then return end
    fh:close()
    local rf = io.open(out, 'r')
    if not rf then return end
    local line = rf:read('*a') or ''
    rf:close()
    local mw, mh = line:match('(%d+)%s*x%s*(%d+)')
    mw, mh = tonumber(mw), tonumber(mh)
    if not mw or not mh or mw < 640 or mh < 480 then return end
    return mw, mh
end

local function scale_for(mw, mh)
    if (mw or 0) >= 2200 or (mh or 0) >= 1300 then return '1.4' end
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
        return
    end
    text = text:gsub('<uiscale>[^<]*</uiscale>', '<uiscale>' .. scale .. '</uiscale>', 1)
    fh = io.open(path, 'w')
    if not fh then return end
    fh:write(text)
    fh:close()
    windower.add_to_chat(207, '[screenfit] UI scale ' .. scale .. ' saved' .. label .. '. Restart the game to apply it.')
end

local function check_monitor(report)
    local ok, mw, mh = pcall(monitor_size)
    if not ok or not mw then
        local s = windower.get_windower_settings()
        mw = s.x_res or s.ui_x_res
        mh = s.y_res or s.ui_y_res
        if report then
            windower.add_to_chat(207, '[screenfit] Could not read the active monitor. Using the window size instead.')
        end
    end
    if not mw then return end
    local label = ' for the ' .. mw .. 'x' .. mh .. ' monitor'
    write_uiscale(scale_for(mw, mh), label, report)
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
    local bx, by = place(TIMERS.BuffsX, TIMERS.BuffsY, w, h, true, false)
    local cx, cy = place(TIMERS.CustomX, TIMERS.CustomY, w, h, true, false)
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

local function shift_commands(w, h)
    local ex, ey = place(EQUIP.x, EQUIP.y, w, h, EQUIP.right, EQUIP.bottom)
    windower.send_command('ev pos ' .. ex .. ' ' .. ey)
    for _, bar in ipairs(ENEMYBAR) do
        local x, y = place(bar[2], bar[3], w, h, bar[4], bar[5])
        windower.send_command('eb set pos ' .. bar[1] .. ' ' .. x .. ' ' .. y)
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
    if cmd == 'commit' then
        commit()
        return
    elseif cmd == 'apply' or cmd == 'now' then
        applied_w, applied_h = nil, nil
        apply()
        return
    elseif cmd == 'scale' then
        if extra == '1' or extra == '1.0' then
            write_uiscale('1', '', true)
        elseif extra == '1.4' then
            write_uiscale('1.4', '', true)
        else
            check_monitor(true)
        end
        return
    end
    windower.add_to_chat(207, 'screenfit: //fit scale')
end)
