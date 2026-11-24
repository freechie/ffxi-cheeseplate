_addon.name = 'scenepace'
_addon.author = 'Cheeseplate'
_addon.version = '1.1'
_addon.commands = {'scenepace'}

-- Cutscenes are timed for 30 FPS. Cheeseplate plays at 60, so they run at
-- double speed. The client only offers 30, 60, or uncapped (FrameRateDivisor
-- 2 / 1 / 0). A scene drops to 30 while it is up and returns to 60 when it
-- ends. Enternity still advances the lines, so they keep moving without an
-- Enter press.
-- Status 4 is shared with menus. Keep menus at 60 when menu_open is set so
-- inventory and config stay snappy; only force 30 for event status without
-- a menu (cinematics). Dialogue boxes that also set menu_open stay at 60.

local PLAY = 1
local SCENE = 2
local applied = nil

local function want_divisor()
    local player = windower.ffxi.get_player()
    if not player then
        return PLAY
    end
    if player.status ~= 4 then
        return PLAY
    end
    local info = windower.ffxi.get_info()
    if info and info.menu_open then
        return PLAY
    end
    return SCENE
end

local function apply(divisor)
    if divisor == applied then
        return
    end
    applied = divisor
    windower.send_command('config FrameRateDivisor ' .. divisor)
end

local function sync()
    apply(want_divisor())
end

windower.register_event('load', function()
    sync()
    windower.add_to_chat(207, '[scenepace] Cutscenes at 30 FPS. Menus and gameplay at 60.')
end)

windower.register_event('login', function()
    applied = nil
    sync()
end)

windower.register_event('status change', function()
    sync()
end)

-- menu_open can flip without a status change (dialogue box inside an event).
windower.register_event('prerender', function()
    local player = windower.ffxi.get_player()
    if player and player.status == 4 then
        sync()
    end
end)

windower.register_event('logout', function()
    applied = nil
    windower.send_command('config FrameRateDivisor ' .. PLAY)
end)

windower.register_event('unload', function()
    applied = nil
    windower.send_command('config FrameRateDivisor ' .. PLAY)
end)

windower.register_event('addon command', function()
    local player = windower.ffxi.get_player()
    local info = windower.ffxi.get_info()
    local scene = player and player.status == 4 and not (info and info.menu_open)
    local menu = player and player.status == 4 and info and info.menu_open
    local where = scene and ' A cutscene is active.' or (menu and ' A menu is open (60 FPS).' or '')
    windower.add_to_chat(207, '[scenepace] Cutscenes at 30 FPS. Menus and gameplay at 60 FPS.' .. where)
end)
