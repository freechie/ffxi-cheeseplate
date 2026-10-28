--[[
  Cheeseplate THF GearSwap - starter

  Fill gear by dressing in-game, then:
    //gs export
  Or edit the tables below. Missing items are skipped safely.

  Commands:
    //gs c toggle TP set
    //gs c toggle Idle set
    //gs c th   - force Treasure Hunter set while engaged
    //gs c sata - Sneak Attack, Trick Attack, then Evisceration (Alt+F8, Ctrl+Shift+8)
    //gs c binds - rebind for current level and list number-row keys
]]

-- Blocks a second press from queuing another Evisceration on top of the first.
local sata_ready_at = 0

function get_sets()
    TP_Index = 1
    Idle_Index = 1
    ForceTH = false

    -- ============================================================
    -- Replace these with your actual pieces (iLvl 117-119 Spark OK)
    -- ============================================================

    sets.JA = {}
    sets.JA['Perfect Dodge'] = {}
    sets.JA.Flee = {}
    sets.JA.Steal = {}
    sets.JA.Despoil = {}
    sets.JA.Mug = {}
    sets.JA.Collaborator = {}
    sets.JA.Accomplice = {}
    sets.JA.Conspirator = {}
    sets.JA.Waltz = {}

    sets.WS = {}
    sets.WS.SA = {}
    sets.WS.TA = {}
    sets.WS.SATA = {}

    -- Mummu combat set. Kaja Knife stays in the main hand for Evisceration.
    -- Toutatis's Cape is Sneak Attack +10 even before augments.
    -- Aptitude Mantle +1 is Capacity Points +30% and goes on for the weaponskill.
    -- Enlivened sits on the left so Capacity, Trizek, and Warp can take that hand.
    -- Vehemence stays the spare. Mummu stays on the right.
    local combat = {
        main="Kaja Knife",
        sub="Homestead Dagger",
        head="Mummu Bonnet +1",
        body="Mummu Jacket +1",
        hands="Mummu Wrists +1",
        legs="Mummu Kecks +1",
        feet="Mummu Gamash. +1",
        neck="Arctier's Torque",
        waist="Patentia Sash",
        left_ear="Volley Earring",
        left_ring="Enlivened Ring",
        right_ring="Mummu Ring",
        back="Toutatis's Cape",
    }

    local weaponskill = set_combine(combat, {back="Aptitude Mantle +1"})

    sets.WS.Base = weaponskill
    sets.WS["Rudra's Storm"] = sets.WS.Base
    sets.WS.Evisceration = sets.WS.Base
    sets.WS.Exenterator = sets.WS.Base
    sets.WS['Mandalic Stab'] = sets.WS.Base
    sets.WS["Shark Bite"] = sets.WS.Base
    sets.WS['Aeolian Edge'] = sets.WS.Base
    sets.WS['Dancing Edge'] = sets.WS.Base

    sets.WS.SA.Base = weaponskill
    sets.WS.TA.Base = weaponskill
    sets.WS.SATA.Base = weaponskill

    TP_Set_Names = {'TP', 'TH'}
    sets.TP = {}
    sets.TP.TP = combat
    -- No Treasure Hunter piece yet. Chaac Belt replaces the sash when it is available.
    sets.TP.TH = set_combine(combat, {})

    -- Idle macro cycles these. Sprinter's Shoes are movement speed +12%.
    -- Track Pants +1 are +8% and block feet, so that press clears the shoes.
    -- Engaging puts the Mummu legs and feet back on.
    Idle_Set_Names = {'Move', 'Pants', 'Idle'}
    sets.Idle = {}
    sets.Idle.Move = set_combine(combat, {feet="Sprinter's Shoes"})
    sets.Idle.Pants = set_combine(combat, {legs="Track Pants +1", feet=empty})
    sets.Idle.Idle = combat

    sets.FastCast = {}
    sets.SneakAttack = combat
    sets.TrickAttack = combat

    send_command('bind !f8 gs c sata')
    send_command('bind !f9 gs c toggle TP set')
    send_command('bind !f10 gs c toggle Idle set')
    send_command('bind !f11 gs c th')

    include('binds.lua')
    set_binds({
        fkeys = {
            ['!f8'] = 'SATA',
            ['!f9'] = 'TP set',
            ['!f10'] = 'Idle set',
            ['!f11'] = 'TH set',
        },
        ['^'] = {
            title = 'Combat',
            {'Feint', 'input /ja "Feint" <t>', 75},
            {'Sneak Attack', 'input /ja "Sneak Attack" <me>'},
            {'Trick Attack', 'input /ja "Trick Attack" <me>'},
            {'Bully', 'input /ja "Bully" <t>'},
            {'Hide', 'input /ja "Hide" <me>'},
            {'Collab p1', 'input /ja "Collaborator" <p1>'},
            {'Accomplice p1', 'input /ja "Accomplice" <p1>'},
            {'Larceny', 'input /ja "Larceny" <t>'},
            {'Perfect Dodge', 'input /ja "Perfect Dodge" <me>'},
            {'Conspirator', 'input /ja "Conspirator" <me>'},
        },
        ['!'] = {
            title = 'Steal & WS',
            {'Steal', 'input /ja "Steal" <t>'},
            {'Despoil', 'input /ja "Despoil" <t>'},
            {'Mug', 'input /ja "Mug" <t>'},
            {'Flee', 'input /ja "Flee" <me>'},
            {'Evisceration', 'input /ws "Evisceration" <t>'},
            {'Aeolian Edge', 'input /ws "Aeolian Edge" <t>'},
            {'Shark Bite', 'input /ws "Shark Bite" <t>'},
            {'Dancing Edge', 'input /ws "Dancing Edge" <t>'},
            {'Collab p2', 'input /ja "Collaborator" <p2>'},
            {'Accomplice p2', 'input /ja "Accomplice" <p2>'},
        },
        ['~^'] = {
            title = 'Utility',
            {'Trizek Ring', 'gs c trizek'},
            {'Capacity Ring', 'gs c capring'},
            {'Warp Ring', 'gs c warp'},
            {'Food', 'input /item "Grape Daifuku" <me>'},
            {'Raise trusts', 'tru raise'},
            {'EXP', 'tru exp'},
            {'TH set', 'gs c th'},
            {'SATA', 'gs c sata'},
            {'TP set', 'gs c toggle TP set'},
            {'Dismiss', 'input /refa all'},
        },
        ['~!'] = {
            title = 'Ranged',
            {'Ranged', 'input /ra <t>'},
            {'Wasp Sting', 'input /ws "Wasp Sting" <t>'},
            {'Viper Bite', 'input /ws "Viper Bite" <t>'},
            {'Idle set', 'gs c toggle Idle set'},
            {'Assassin\'s Charge', 'input /ja "Assassin\'s Charge" <me>'},
            {'Rudra\'s Storm', 'input /ws "Rudra\'s Storm" <t>'},
            {'Exenterator', 'input /ws "Exenterator" <t>'},
            {'Mandalic Stab', 'input /ws "Mandalic Stab" <t>'},
            {'Shadowstitch', 'input /ws "Shadowstitch" <t>'},
            {'Energy Drain', 'input /ws "Energy Drain" <t>'},
        },
    })

    if player.status == 'Engaged' then
        equip(sets.TP.TP)
    else
        equip(sets.Idle.Move)
    end

    -- Visible gear blinks when combat feet replace Sprinter's Shoes, and the client drops the camera lock.
    send_command('wait 0.5; du blinking self always on')
    send_command('@input /echo [GearSwap] THF loaded - Alt+F8 SATA | F9 TP | F10 idle | F11 TH | //gs c binds lists number keys')
end

function file_unload()
    clear_binds()
    send_command('unbind !f8')
    send_command('unbind !f9')
    send_command('unbind !f10')
    send_command('unbind !f11')
end

local function equip_tp()
    if ForceTH then
        equip(sets.TP.TH)
    else
        equip(sets.TP[TP_Set_Names[TP_Index]])
    end
end

local function equip_idle()
    equip(sets.Idle[Idle_Set_Names[Idle_Index]])
end

function precast(spell)
    if sets.JA[spell.english] then
        equip(sets.JA[spell.english])
        return
    end

    if spell.type == 'WeaponSkill' then
        local base = sets.WS[spell.english] or sets.WS.Base
        equip(base)

        local sa = buffactive['Sneak Attack'] or buffactive['sneak attack']
        local ta = buffactive['Trick Attack'] or buffactive['trick attack']

        if sa and ta then
            equip(sets.WS.SATA[spell.english] or sets.WS.SATA.Base or sets.SneakAttack)
        elseif sa then
            equip(sets.WS.SA[spell.english] or sets.WS.SA.Base or sets.SneakAttack)
        elseif ta then
            equip(sets.WS.TA[spell.english] or sets.WS.TA.Base or sets.TrickAttack)
        end
        return
    end

    if spell.english:find('Waltz') then
        equip(sets.JA.Waltz)
        return
    end

    if spell.action_type == 'Magic' then
        equip(sets.FastCast)
    end
end

function aftercast(spell)
    -- Keep Mummu on while the chain is between abilities. Idle would swap in Sprinter's Shoes.
    if os.clock() < sata_ready_at then
        equip(sets.TP.TP)
        return
    end
    if player.status == 'Engaged' then
        equip_tp()
    else
        equip_idle()
    end
end

function status_change(new, old)
    if os.clock() < sata_ready_at then
        equip(sets.TP.TP)
        return
    end
    if new == 'Engaged' then
        equip_tp()
    elseif new == 'Idle' or new == 'Resting' then
        equip_idle()
    end
end

function buff_change(buff, gain)
    buff = buff:lower()
    if buff == 'sneak attack' then
        if gain then
            equip(sets.SneakAttack)
        elseif player.status == 'Engaged' then
            equip_tp()
        end
    elseif buff == 'trick attack' then
        if gain then
            equip(sets.TrickAttack)
        elseif player.status == 'Engaged' then
            equip_tp()
        end
    end
end

function self_command(command)
    command = command:lower()
    if binds_command(command) then return end

    if command == 'toggle tp set' then
        TP_Index = TP_Index % #TP_Set_Names + 1
        send_command('@input /echo ----- TP Set: '..TP_Set_Names[TP_Index]..' -----')
        if player.status == 'Engaged' then equip_tp() end
    elseif command == 'toggle idle set' then
        Idle_Index = Idle_Index % #Idle_Set_Names + 1
        send_command('@input /echo ----- Idle Set: '..Idle_Set_Names[Idle_Index]..' -----')
        if player.status ~= 'Engaged' then equip_idle() end
    elseif command == 'th' then
        ForceTH = not ForceTH
        send_command('@input /echo ----- Force TH: '..tostring(ForceTH)..' -----')
        if player.status == 'Engaged' then equip_tp() end
    elseif command == 'sata' then
        if os.clock() < sata_ready_at then return end
        if (player.tp or 0) < 1000 then
            send_command('@input /echo ----- SATA needs 1000 TP -----')
            return
        end
        local recasts = windower.ffxi.get_ability_recasts()
        if (recasts[64] or 0) > 0 or (recasts[66] or 0) > 0 then
            send_command('@input /echo ----- SATA is on recast -----')
            return
        end
        if not player.target or player.target.type ~= 'MONSTER' then
            send_command('@input /echo ----- SATA needs a monster -----')
            return
        end
        -- Stay engaged. /attackoff drops the target and releases the camera.
        -- Hit this just after a swing so the weaponskill lands before the next one.
        sata_ready_at = os.clock() + 4
        send_command('@input /echo ----- SATA: Evisceration -----')
        send_command('input /ja "Sneak Attack" <me>; wait 1; input /ja "Trick Attack" <me>; wait 1; input /ws "Evisceration" <t>')
    end
end
