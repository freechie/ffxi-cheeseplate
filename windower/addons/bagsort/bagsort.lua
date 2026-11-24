_addon.name = 'bagsort'
_addon.author = 'Cheeseplate'
_addon.version = '2.0.0'
_addon.commands = {'bagsort', 'bsort'}

local res = require('resources')
local rules_file = require('rules')

-- Moves items between bags. Never drops, sells, or trades.
-- Lost Sickle: one stays in a wardrobe. Extra sickles are filed with the spare gear.

-- Case, safe2, and storage are scanned so listed items can leave them.
-- The safe (furniture) stays untouched.
local SCAN_BAGS = {
    'inventory', 'wardrobe', 'wardrobe2',
    'locker', 'satchel', 'sack',
    'case', 'safe2', 'storage',
}

local bag_api_to_id = {}
for bag in res.bags:it() do
    if bag.api then
        bag_api_to_id[bag.api] = bag.id
    end
end

local function to_set(list)
    local set = {}
    for _, name in ipairs(list or {}) do
        set[name:lower()] = true
    end
    return set
end

local sets = {
    inventory = to_set(rules_file.inventory),
    wear = to_set(rules_file.wear),
    locker = to_set(rules_file.locker),
    overflow = to_set(rules_file.overflow),
    satchel = to_set(rules_file.satchel),
    currency = to_set(rules_file.currency),
}

local running = false
local blocked = {}
local sent = {}

local function chat(msg)
    windower.add_to_chat(207, 'bagsort: '..msg)
end

local function item_name(id)
    local item = res.items[id]
    return item and item.en or ('#'..tostring(id))
end

local function bag_info(api)
    local id = bag_api_to_id[api]
    if id == nil then return nil end
    return windower.ffxi.get_bag_info(id)
end

local function bag_enabled(api)
    local info = bag_info(api)
    return info and info.enabled or false
end

local function bag_free(api)
    local info = bag_info(api)
    if not info or not info.enabled then return 0 end
    return math.max(0, (info.max or 0) - (info.count or 0))
end

local function role_for(name)
    local low = name:lower()
    if sets.inventory[low] then return 'inventory' end
    if sets.wear[low] then return 'wear' end
    if sets.locker[low] then return 'locker' end
    if sets.overflow[low] then return 'overflow' end
    if sets.currency[low] then return 'currency' end
    if sets.satchel[low] then return 'satchel' end
    return nil
end

-- Spare and artifact gear is finished once it is out of the wardrobes.
-- Moving it between the sack and storage just bounces the same stack.
local FILED_BAGS = {
    locker = true,
    sack = true,
    storage = true,
    case = true,
    safe2 = true,
}

local function at_home(src, role)
    if role == 'wear' then
        return src == 'wardrobe' or src == 'wardrobe2'
    end
    if role == 'inventory' then return src == 'inventory' end
    if role == 'satchel' or role == 'currency' then return src == 'satchel' end
    if role == 'locker' or role == 'overflow' then
        return FILED_BAGS[src] == true
    end
    return false
end

local function each_item(api, fn)
    local id = bag_api_to_id[api]
    if id == nil or not bag_enabled(api) then return end
    local bag = windower.ffxi.get_items(id)
    if not bag then return end
    local seen = {}
    local max_slot = bag.max or 0
    for slot = 1, max_slot do
        local item = bag[slot]
        if type(item) == 'table' and item.id and item.id ~= 0 then
            local use_slot = item.slot or slot
            if not seen[use_slot] then
                seen[use_slot] = true
                fn(item, use_slot)
            end
        end
    end
    for _, item in ipairs(bag) do
        if type(item) == 'table' and item.id and item.id ~= 0 and item.slot and not seen[item.slot] then
            seen[item.slot] = true
            fn(item, item.slot)
        end
    end
end

local function row_key(row)
    return row.src_api..':'..tostring(row.slot)..':'..tostring(row.id)
end

local function add_row(rows, src_api, slot, id, stack_count, move_count, role)
    rows[#rows + 1] = {
        name = item_name(id),
        id = id,
        src_api = src_api,
        src_id = bag_api_to_id[src_api],
        slot = slot,
        stack_count = stack_count,
        move_count = move_count,
        role = role,
        frees_source = move_count >= stack_count,
    }
end

-- One Lost Sickle stays in a wardrobe. Further sickles are spare.
local function collect_rows()
    local rows = {}
    local skipped = {}
    local sickles = {}

    for _, api in ipairs(SCAN_BAGS) do
        each_item(api, function(item, slot)
            local name = item_name(item.id)
            if (item.status or 0) ~= 0 then
                local role = role_for(name)
                if role and not at_home(api, role) then
                    skipped[#skipped + 1] = name..' ('..api..')'
                end
                return
            end
            if name:lower() == 'lost sickle' then
                sickles[#sickles + 1] = {
                    api = api,
                    slot = slot,
                    id = item.id,
                    count = item.count or 1,
                }
                return
            end
            local role = role_for(name)
            if role and not at_home(api, role) then
                local key = api..':'..tostring(slot)..':'..tostring(item.id)
                if not blocked[key] then
                    add_row(rows, api, slot, item.id, item.count or 1, item.count or 1, role)
                end
            end
        end)
    end

    table.sort(sickles, function(a, b)
        local function rank(api)
            if api == 'wardrobe' then return 0 end
            if api == 'wardrobe2' then return 1 end
            return 2
        end
        if rank(a.api) ~= rank(b.api) then return rank(a.api) < rank(b.api) end
        return a.slot < b.slot
    end)

    if #sickles > 0 then
        local keeper = sickles[1]
        for _, stack in ipairs(sickles) do
            if stack.api == 'wardrobe' or stack.api == 'wardrobe2' then
                keeper = stack
                break
            end
        end

        if keeper.api ~= 'wardrobe' and keeper.api ~= 'wardrobe2' then
            local key = keeper.api..':'..tostring(keeper.slot)..':'..tostring(keeper.id)
            if not blocked[key] then
                add_row(rows, keeper.api, keeper.slot, keeper.id, keeper.count, 1, 'wear')
            end
        elseif keeper.count > 1 then
            local key = keeper.api..':'..tostring(keeper.slot)..':'..tostring(keeper.id)
            if not blocked[key] then
                add_row(rows, keeper.api, keeper.slot, keeper.id, keeper.count, keeper.count - 1, 'overflow')
            end
        end

        for _, stack in ipairs(sickles) do
            if stack ~= keeper then
                local key = stack.api..':'..tostring(stack.slot)..':'..tostring(stack.id)
                if not blocked[key] then
                    add_row(rows, stack.api, stack.slot, stack.id, stack.count, stack.count, 'overflow')
                end
            end
        end
    end

    return rows, skipped
end

local function rank_of(row)
    if row.src_api == 'inventory' and (row.role == 'locker' or row.role == 'overflow' or row.role == 'currency') then
        return 0
    end
    if row.role == 'locker' then return 1 end
    if row.role == 'overflow' then return 2 end
    if row.role == 'inventory' then return 3 end
    if row.role == 'wear' then return 4 end
    if row.role == 'satchel' then return 5 end
    if row.role == 'currency' then return 6 end
    return 9
end

local function choose_dest(free, enabled, role)
    local function has(api)
        return enabled[api] and (free[api] or 0) > 0
    end
    if role == 'locker' then
        if has('locker') then return 'locker' end
        if has('sack') then return 'sack' end
        if has('storage') then return 'storage' end
        if has('case') then return 'case' end
        if has('safe2') then return 'safe2' end
    elseif role == 'overflow' then
        if has('sack') then return 'sack' end
        if has('locker') then return 'locker' end
        if has('storage') then return 'storage' end
        if has('case') then return 'case' end
        if has('safe2') then return 'safe2' end
    elseif role == 'inventory' then
        if has('inventory') then return 'inventory' end
    elseif role == 'wear' then
        local wardrobe_free = has('wardrobe') and free.wardrobe or 0
        local wardrobe2_free = has('wardrobe2') and free.wardrobe2 or 0
        if wardrobe_free <= 0 and wardrobe2_free <= 0 then return nil end
        if wardrobe_free >= wardrobe2_free then return 'wardrobe' end
        return 'wardrobe2'
    elseif role == 'satchel' or role == 'currency' then
        if has('satchel') then return 'satchel' end
    end
    return nil
end

local function live_free()
    local free = {}
    local enabled = {}
    for _, api in ipairs(SCAN_BAGS) do
        enabled[api] = bag_enabled(api)
        free[api] = bag_free(api)
    end
    return free, enabled
end

local function plan_moves(rows)
    local free, enabled = live_free()
    table.sort(rows, function(a, b)
        local ra, rb = rank_of(a), rank_of(b)
        if ra ~= rb then return ra < rb end
        if a.name:lower() ~= b.name:lower() then return a.name:lower() < b.name:lower() end
        return a.slot < b.slot
    end)

    local moves = {}
    local stayed = {}
    for _, row in ipairs(rows) do
        local dest = choose_dest(free, enabled, row.role)
        if dest and dest ~= row.src_api then
            row.dest_api = dest
            row.dest_id = bag_api_to_id[dest]
            moves[#moves + 1] = row
            free[dest] = free[dest] - 1
            if row.frees_source then
                free[row.src_api] = (free[row.src_api] or 0) + 1
            end
        else
            stayed[#stayed + 1] = row
        end
    end
    return moves, stayed
end

local function count_by(moves, field)
    local counts = {}
    for _, row in ipairs(moves) do
        local key = row[field]
        counts[key] = (counts[key] or 0) + 1
    end
    return counts
end

local function preview()
    local rows, skipped = collect_rows()
    local moves, stayed = plan_moves(rows)

    chat('files items into bags. Nothing is dropped or sold.')
    for _, api in ipairs({'locker', 'sack', 'storage', 'case', 'satchel'}) do
        local info = bag_info(api)
        if not info then
            chat(api..' is missing')
        elseif not info.enabled then
            chat(('%s is closed (%d/%d)'):format(api, info.count or 0, info.max or 0))
        else
            local free = math.max(0, (info.max or 0) - (info.count or 0))
            chat(('%s free %d (%d/%d)'):format(api, free, info.count or 0, info.max or 0))
        end
    end
    if not bag_enabled('locker') or bag_free('sack') < 1 then
        chat('Gear that cannot fit in the locker or sack goes to storage, then the case.')
    end

    if #moves == 0 and #stayed == 0 then
        chat('everything listed is already filed')
        return
    end

    chat(('would move %d stack(s)'):format(#moves))
    local by_dest = count_by(moves, 'dest_api')
    local dests = {}
    for dest in pairs(by_dest) do dests[#dests + 1] = dest end
    table.sort(dests)
    for _, dest in ipairs(dests) do
        chat(('  %s: %d (free %d)'):format(dest, by_dest[dest], bag_free(dest)))
    end

    for _, row in ipairs(moves) do
        chat(('%s x%d  %s -> %s'):format(row.name, row.move_count, row.src_api, row.dest_api))
    end

    if #stayed > 0 then
        chat(('left in place: %d (destination full or closed)'):format(#stayed))
        for _, row in ipairs(stayed) do
            chat(('  %s stays in %s'):format(row.name, row.src_api))
        end
    end

    if #skipped > 0 then
        chat(('skipped %d equipped or locked stack(s)'):format(#skipped))
        for _, name in ipairs(skipped) do
            chat('  '..name)
        end
    end

    chat('//bagsort go')
end

local function stack_count_now(bag_id, slot, item_id)
    local bag = windower.ffxi.get_items(bag_id)
    if not bag then return 0 end
    local item = bag[slot]
    if item and item.id == item_id then
        return item.count or 0
    end
    return 0
end

local move_next

local function finish_move(row, tries_left, is_shuttle)
    if not running then return end

    local left = stack_count_now(row.src_id, row.slot, row.id)
    local moved = left <= (row.stack_count - row.move_count)
    if moved then
        local dest_name = is_shuttle and 'inventory' or row.dest_api
        chat(('%s x%d  %s -> %s'):format(row.name, row.move_count, row.src_api, dest_name))
        move_next()
        return
    end

    if tries_left > 0 then
        coroutine.schedule(function()
            finish_move(row, tries_left - 1, is_shuttle)
        end, 0.35)
        return
    end

    local can_shuttle = (not is_shuttle)
        and row.dest_api ~= 'inventory'
        and row.src_api ~= 'inventory'
        and bag_free('inventory') > 0
    if can_shuttle then
        chat(('retry %s through inventory'):format(row.name))
        windower.ffxi.move_item(row.src_id, bag_api_to_id.inventory, row.slot, row.move_count)
        finish_move(row, 8, true)
        return
    end

    blocked[row_key(row)] = true
    chat(('left %s in %s'):format(row.name, row.src_api))
    move_next()
end

move_next = function()
    if not running then return end

    local rows = collect_rows()
    local moves = plan_moves(rows)
    local row = moves[1]
    if not row then
        running = false
        local _, stayed = plan_moves(collect_rows())
        if #stayed > 0 then
            chat(('done. %d stack(s) stayed because the destination is full or closed'):format(#stayed))
        else
            chat('done')
        end
        return
    end

    local trip = row.src_api..'>'..row.dest_api..'>'..tostring(row.id)
    local back = row.dest_api..'>'..row.src_api..'>'..tostring(row.id)
    if sent[back] then
        blocked[row_key(row)] = true
        chat(('left %s in %s'):format(row.name, row.src_api))
        move_next()
        return
    end
    sent[trip] = true

    windower.ffxi.move_item(row.src_id, row.dest_id, row.slot, row.move_count)
    finish_move(row, 8, false)
end

local function start_sort()
    if running then
        chat('already running')
        return
    end
    if not windower.ffxi.get_info().logged_in then
        chat('not logged in')
        return
    end

    blocked = {}
    sent = {}
    local rows = collect_rows()
    local moves, stayed = plan_moves(rows)
    if #moves == 0 then
        if #stayed > 0 then
            chat(('nothing can move. %d stack(s) stayed because the destination is full or closed'):format(#stayed))
        else
            chat('everything listed is already filed')
        end
        return
    end

    chat(('moving %d stack(s). Nothing is dropped or sold.'):format(#moves))
    running = true
    move_next()
end

windower.register_event('addon command', function(cmd, ...)
    cmd = (cmd or ''):lower()
    local args = {...}
    local arg1 = (args[1] or ''):lower()

    if cmd == '' or cmd == 'preview' or cmd == 'list' then
        preview()
    elseif cmd == 'go' or cmd == 'run' then
        start_sort()
    elseif cmd == 'all' then
        if arg1 == 'go' or arg1 == 'run' then
            start_sort()
        else
            preview()
        end
    elseif cmd == 'stop' then
        running = false
        chat('stopped')
    elseif cmd == 'help' then
        chat('//bagsort - preview the filing plan')
        chat('//bagsort go - move items. Does not drop, sell, or trade.')
        chat('//bagsort stop - cancel')
        chat('Wear gear stays in wardrobe 1 or 2.')
        chat('Artifact and relic pieces go to the locker.')
        chat('Spare gear goes to the sack.')
        chat('If those are full, storage then the case.')
        chat('Warp and the use-rings stay in the inventory.')
        chat('Currencies go to the satchel.')
        chat('Unlisted items stay where they are.')
    else
        chat('unknown command. //bagsort help')
    end
end)

windower.register_event('unload', function()
    running = false
end)

windower.register_event('logout', function()
    running = false
end)
