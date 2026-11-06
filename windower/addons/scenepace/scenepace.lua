_addon.name = 'scenepace'
_addon.author = 'Cheeseplate'
_addon.version = '1.0'
_addon.commands = {'scenepace'}

-- Cutscenes are timed for 30 FPS. Cheeseplate plays at 60, so they run at
-- double speed. The client has no pace between those two. A scene drops to
-- 30 while it is up and returns to 60 when it ends. Enternity still advances
-- the lines, so they keep moving without an Enter press.
-- The game uses this same state for menus, so a menu is at 30 until it closes.

local PLAY = 1
local SCENE = 2
local applied = nil

local function apply(status)
    local divisor = status == 4 and SCENE or PLAY
    if divisor == applied then
        return
    end
    applied = divisor
    windower.send_command('config FrameRateDivisor ' .. divisor)
end

local function playing()
    local player = windower.ffxi.get_player()
    if not player then
        return
    end
    apply(player.status)
end

windower.register_event('load', function()
    playing()
    windower.add_to_chat(207, '[scenepace] Cutscenes play at 30 FPS. Gameplay stays at 60.')
end)

windower.register_event('login', function()
    applied = nil
    apply(0)
end)

windower.register_event('status change', function(new)
    apply(new)
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
    local scene = player and player.status == 4
    local where = scene and ' A scene is playing now.' or ''
    windower.add_to_chat(207, '[scenepace] Cutscenes at 30 FPS. Gameplay at 60 FPS.' .. where)
end)
