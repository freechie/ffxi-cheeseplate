--[[
  Cheeseplate THF GearSwap — starter

  Fill gear by dressing in-game, then:
    //gs export
  Or edit the tables below. Missing items are skipped safely.

  Commands:
    //gs c toggle TP set
    //gs c toggle Idle set
    //gs c th   — force Treasure Hunter set while engaged
    //gs c sata — Sneak Attack, Trick Attack, then Shark Bite (Alt+F8)
]]

function get_sets()
    TP_Index = 1
    Idle_Index = 1
    ForceTH = false

    -- ============================================================
    -- Replace these with your actual pieces (iLvl 117–119 Spark OK)
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

    -- Default WS set used when a named set is missing
    sets.WS.Base = {}
    sets.WS["Rudra's Storm"] = sets.WS.Base
    sets.WS.Evisceration = sets.WS.Base
    sets.WS.Exenterator = sets.WS.Base
    sets.WS['Mandalic Stab'] = sets.WS.Base
    sets.WS["Shark Bite"] = sets.WS.Base

    sets.WS.SA.Base = {}
    sets.WS.TA.Base = {}
    sets.WS.SATA.Base = {}

    TP_Set_Names = {'TP', 'TH', 'Acc'}
    sets.TP = {}
    sets.TP.TP = {}
    sets.TP.TH = {}  -- put TH+ gear here (e.g. Chaac Belt, TH gloves)
    sets.TP.Acc = {}

    Idle_Set_Names = {'Idle', 'DT'}
    sets.Idle = {}
    sets.Idle.Idle = {}
    sets.Idle.DT = {}

    sets.FastCast = {}
    sets.SneakAttack = {}
    sets.TrickAttack = {}

    send_command('input /macro book 1; wait 0.1; input /macro set 1')
    send_command('@input /echo [GearSwap] THF loaded — fill sets in addons/GearSwap/data/THF.lua or //gs export')
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
    if player.status == 'Engaged' then
        equip_tp()
    else
        equip_idle()
    end
end

function status_change(new, old)
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
        send_command('@input /echo ----- SATA: Shark Bite -----')
        send_command('input /ja "Sneak Attack" <me>; wait 1.2; input /ja "Trick Attack" <me>; wait 1.2; input /ws "Shark Bite" <t>')
    end
end
