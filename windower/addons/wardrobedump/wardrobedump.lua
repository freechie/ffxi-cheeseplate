_addon.name = 'wardrobedump'
_addon.author = 'Cheeseplate'
_addon.version = '1.0.0'
_addon.commands = {'wardrobedump', 'wdump'}

local res = require('resources')
local keep_names = require('keep')

local SOURCE_BAGS = {'wardrobe', 'wardrobe2'}
local MOVE_DELAY = 0.55

local keep_set = {}
for _, name in ipairs(keep_names) do
    keep_set[name:lower()] = true
end

local bag_api_to_id = {}
for bag in res.bags:it() do
    if bag.api then
        bag_api_to_id[bag.api] = bag.id
    end
end

local running = false

local function chat(msg)
    windower.add_to_chat(207, 'wardrobedump: '..msg)
end

local function item_name(id)
    local item = res.items[id]
    return item and item.en or ('#'..tostring(id))
end

local function inventory_free()
    local info = windower.ffxi.get_bag_info(bag_api_to_id.inventory)
    if not info then return 0 end
    return math.max(0, (info.max or 0) - (info.count or 0))
end

local function bag_enabled(api)
    local id = bag_api_to_id[api]
    if not id then return false end
    local info = windower.ffxi.get_bag_info(id)
    return info and info.enabled
end

-- Returns { {bag_id=, bag_api=, slot=, count=, id=, name=}, ... }
local function collect_dumps()
    local dumps = {}
    local sickle_kept = false

    for _, api in ipairs(SOURCE_BAGS) do
        if bag_enabled(api) then
            local bag_id = bag_api_to_id[api]
            for _, item in ipairs(windower.ffxi.get_items(bag_id)) do
                if item and item.id and item.id ~= 0 and (item.status or 0) == 0 then
                    local name = item_name(item.id)
                    local low = name:lower()
                    local keep = keep_set[low]

                    if keep and low == 'lost sickle' then
                        if sickle_kept then
                            keep = false
                        else
                            sickle_kept = true
                        end
                    end

                    if not keep then
                        dumps[#dumps + 1] = {
                            bag_id = bag_id,
                            bag_api = api,
                            slot = item.slot,
                            count = item.count,
                            id = item.id,
                            name = name,
                        }
                    end
                end
            end
        end
    end

    table.sort(dumps, function(a, b)
        if a.bag_api ~= b.bag_api then return a.bag_api < b.bag_api end
        return a.name:lower() < b.name:lower()
    end)
    return dumps
end

local function preview()
    local dumps = collect_dumps()
    local free = inventory_free()
    chat(('would move %d stack(s); inventory free %d'):format(#dumps, free))
    if #dumps == 0 then
        chat('nothing to move')
        return
    end
    for _, row in ipairs(dumps) do
        chat(('%s x%d  [%s]'):format(row.name, row.count, row.bag_api))
    end
    if #dumps > free then
        chat(('warning: need %d free slots, have %d - clear inventory or run //wdump go in batches'):format(#dumps, free))
    end
    chat('run //wdump go to move')
end

local function find_next_dump()
    local dumps = collect_dumps()
    return dumps[1]
end

local function move_next()
    if not running then return end

    local free = inventory_free()
    if free < 1 then
        running = false
        chat('inventory full - stopped. Clear space and //wdump go again')
        return
    end

    local row = find_next_dump()
    if not row then
        running = false
        chat('done')
        return
    end

    windower.ffxi.move_item(row.bag_id, bag_api_to_id.inventory, row.slot, row.count)
    chat(('moved %s x%d from %s'):format(row.name, row.count, row.bag_api))
    coroutine.schedule(move_next, MOVE_DELAY)
end

local function start_dump()
    if running then
        chat('already running')
        return
    end
    if not windower.ffxi.get_info().logged_in then
        chat('not logged in')
        return
    end

    local dumps = collect_dumps()
    local free = inventory_free()
    if #dumps == 0 then
        chat('nothing to move')
        return
    end
    if free < 1 then
        chat('inventory has no free slots')
        return
    end

    chat(('moving up to %d stack(s) into inventory (%d free)...'):format(math.min(#dumps, free), free))
    running = true
    move_next()
end

local function show_keep()
    chat('keep list:')
    local names = {}
    for name in pairs(keep_set) do
        names[#names + 1] = name
    end
    table.sort(names)
    for _, name in ipairs(names) do
        chat('  '..name)
    end
    chat('Lost Sickle: keep 1, move extras')
end

windower.register_event('addon command', function(cmd, ...)
    cmd = (cmd or 'list'):lower()
    if cmd == 'go' or cmd == 'run' or cmd == 'dump' then
        start_dump()
    elseif cmd == 'keep' or cmd == 'keeps' then
        show_keep()
    elseif cmd == 'stop' then
        running = false
        chat('stopped')
    elseif cmd == 'help' then
        chat('//wdump - preview dump list')
        chat('//wdump go - move unnecessary wardrobe/wardrobe2 items to inventory')
        chat('//wdump keep - show keep whitelist')
        chat('//wdump stop - cancel an in-progress dump')
    else
        preview()
    end
end)
