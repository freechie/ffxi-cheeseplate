--[[
  Cheeseplate THF GearSwap - starter

  Fill gear by dressing in-game, then:
    //gs export
  Or edit the tables below. Missing items are skipped safely.

  Commands:
    //gs c toggle TP set
    //gs c toggle Idle set
    //gs c th   - force Treasure Hunter set while engaged
    //gs c saopen / taopen / sata - openers (skip JAs on recast, then Evisceration)
    //gs c cp   - toggle Aptitude Mantle for the whole fight (on while farming CP)
    //gs c binds - rebind for current level and list number-row keys

  Macro book 1 = THF/DNC (Ctrl dancer, Alt openers).
]]

-- Blocks a second press from queuing another Evisceration on top of the first.
local sata_ready_at = 0

-- Ability recast ids: SA 64, TA 66, Feint 68. Assassin's Charge is its own macro.
local RECAST_SA, RECAST_TA, RECAST_FEINT = 64, 66, 68

local function ability_ready(recasts, id)
    if not recasts then return true end
    return (recasts[id] or 0) <= 0
end

local function opener_chat(msg)
    windower.add_to_chat(207, '[THF] '..msg)
end

-- Engaged <t> is enough even if the type packet briefly lags behind MONSTER.
local function has_fight_target()
    local t = player.target
    if not t or not t.id or t.id == 0 then return false end
    if t.type == 'MONSTER' then return true end
    return player.status == 'Engaged'
end

-- steps: {recast_id, windower input command}
-- Always ends with Evisceration when TP allows. Skips any JA still on recast.
local function run_opener(label, steps)
    if os.clock() < sata_ready_at then
        opener_chat(label..' ignored (chain still running)')
        return
    end
    if (player.tp or 0) < 1000 then
        opener_chat(label..' needs 1000 TP (have '..tostring(player.tp or 0)..')')
        return
    end
    if not has_fight_target() then
        opener_chat(label..' needs a monster target (or be engaged)')
        return
    end
    local recasts = windower.ffxi.get_ability_recasts()
    local parts = {}
    local waits = 0
    for _, step in ipairs(steps) do
        local id, cmd = step[1], step[2]
        if ability_ready(recasts, id) then
            parts[#parts + 1] = cmd
            waits = waits + 1
        end
    end
    parts[#parts + 1] = 'input /ws "Evisceration" <t>'
    -- One second per JA + a beat so the WS is not clipped by the next press.
    sata_ready_at = os.clock() + math.max(1.5, waits * 1.2 + 0.5)
    if waits == 0 then
        opener_chat(label..': WS only (openers on recast)')
    else
        opener_chat(label..': '..waits..' JA(s) then Evisceration')
    end
    windower.send_command(table.concat(parts, '; wait 1.2; '))
end

-- On while Job Points are the goal. Both bonuses are checked when the mob dies,
-- so the mantle and Jubilee Ring stay on idle, engaged, and weaponskills.
-- Jubilee takes the left hand. Mummu stays on the right. Use-rings borrow the
-- left hand, then //gs c regear puts Jubilee back. //gs c cp returns Toutatis
-- and Enlivened until the next toggle.
local CpMode = true

local function apply_cp(set)
    if CpMode then
        return set_combine(set, {back="Aptitude Mantle +1", left_ring="Jubilee Ring"})
    end
    return set
end

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

    -- Mummu combat set with Meg legs. Tauret is main (Kaja upgraded).
    -- Shijo path D offhand is capped (TA+2, DW+5, DEX+15).
    -- Toutatis's Cape is Sneak Attack +10 even before augments.
    -- Aptitude Mantle +1 is Capacity Points +30%. CpMode wears it the whole fight.
    -- With CpMode off, Toutatis stays on combat and Aptitude swaps in for the weaponskill.
    -- WS: Meg Gloves (WSD+5%) and Mummu Kecks (crit) over TP hands/legs.
    -- Enlivened sits on the left when CP mode is off. Jubilee replaces it while CP mode is on.
    -- Vehemence stays the spare. Mummu stays on the right.
    -- Eabani is DW; Belatz Pearl is the spare melee ear.
    local combat = {
        main="Tauret",
        sub="Shijo",
        head="Mummu Bonnet +1",
        body="Mummu Jacket +2",
        hands="Mummu Wrists +1",
        legs="Meg. Chausses +2",
        feet="Mummu Gamash. +1",
        neck="Dampener's Torque",
        waist="Patentia Sash",
        left_ear="Eabani Earring",
        right_ear="Belatz Pearl",
        left_ring="Enlivened Ring",
        right_ring="Mummu Ring",
        back="Toutatis's Cape",
    }

    local weaponskill = set_combine(combat, {
        hands="Meg. Gloves +1",
        legs="Mummu Kecks +1",
        back="Aptitude Mantle +1",
    })

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

    -- Idle macro cycles these. Track Pants +1 are +8% movement and clear feet.
    -- Engaging puts combat legs and feet back on.
    Idle_Set_Names = {'Pants', 'Idle'}
    sets.Idle = {}
    sets.Idle.Pants = set_combine(combat, {legs="Track Pants +1", feet=empty})
    sets.Idle.Idle = combat

    sets.FastCast = {}
    sets.SneakAttack = combat
    sets.TrickAttack = combat

    -- Clear old Alt+F layouts if this file was reloaded mid-session.
    for _, key in ipairs({'!f1', '!f2', '!f3', '!f4', '!f5', '!f6', '!f7', '!f8', '!f9', '!f10', '!f11'}) do
        send_command('unbind '..key)
    end
    -- SATA is Alt+4 on set 1. F-keys: TP / Idle / TH on F1–F3 (bound in set_binds).
    include('binds.lua')
    set_binds({
        fkeys = {
            ['!f1'] = {'TP set', 'gs c toggle TP set'},
            ['!f2'] = {'Idle set', 'gs c toggle Idle set'},
            ['!f3'] = {'TH set', 'gs c th'},
        },
        -- Book 1 set 1 Ctrl: Dancer sub.
        ['^'] = {
            title = 'Dancer',
            {'Box Step', 'input /ja "Box Step" <t>', 23},
            {'Quickstep', 'input /ja "Quickstep" <t>', 20},
            {'Haste Samba', 'input /ja "Haste Samba" <me>', 45},
            {'Stutter Step', 'input /ja "Stutter Step" <t>', 40},
            {'Reverse', 'input /ja "Reverse Flourish" <me>', 40},
            {'Violent', 'input /ja "Violent Flourish" <t>', 45},
            {'C.Waltz III', 'input /ja "Curing Waltz III" <stpc>', 45},
            {'Healing Waltz', 'input /ja "Healing Waltz" <stpc>', 35},
            {'Divine Waltz', 'input /ja "Divine Waltz" <me>', 25},
            {'Animated', 'input /ja "Animated Flourish" <t>', 20},
        },
        -- Book 1 set 1 Alt: openers + THF tools. Despoil tags TH.
        ['!'] = {
            title = 'Openers',
            {'Evisceration', 'input /ws "Evisceration" <t>'},
            {'SA opener', 'gs c saopen'},
            {'TA opener', 'gs c taopen'},
            {'SATA', 'gs c sata'},
            {'Feint', 'input /ja "Feint" <t>', 75},
            {'Hide', 'input /ja "Hide" <me>'},
            {'Despoil', 'input /ja "Despoil" <t>'},
            {'Conspirator', 'input /ja "Conspirator" <me>'},
            {'Perfect Dodge', 'input /ja "Perfect Dodge" <me>'},
            {'Flee', 'input /ja "Flee" <me>'},
        },
        -- Book 1 set 2 Ctrl: utility (DNC overflow + THF JAs). Building/Jig II need DNC main.
        ['~^'] = {
            title = 'Utility',
            {'Spectral Jig', 'input /ja "Spectral Jig" <me>', 25},
            {'Drain Samba II', 'input /ja "Drain Samba II" <me>', 35},
            {'Aspir Samba', 'input /ja "Aspir Samba" <me>', 25},
            {'Assassin\'s Charge', 'input /ja "Assassin\'s Charge" <me>', 75},
            {'Collaborator', 'input /ja "Collaborator" <stpt>', 65},
            {'Accomplice', 'input /ja "Accomplice" <stpt>', 65},
            {'Bully', 'input /ja "Bully" <t>', 93},
            {'Steal', 'input /ja "Steal" <t>', 5},
            {'Mug', 'input /ja "Mug" <t>', 15},
            {'Wild', 'input /ja "Wild Flourish" <t>', 30},
        },
        -- Book 1 set 2 Alt: spare WS.
        ['~!'] = {
            title = 'WS 2',
            {'Aeolian Edge', 'input /ws "Aeolian Edge" <t>'},
        },
    })

    if player.status == 'Engaged' then
        equip(apply_cp(sets.TP.TP))
    else
        equip(apply_cp(sets.Idle.Idle))
    end

    send_command('wait 0.5; du blinking self always on')
    send_command('@input /echo [GearSwap] THF/DNC book 1 - CP gear on (Aptitude + Jubilee) | //gs c cp toggles off')
end

function file_unload()
    clear_binds()
end

local function equip_tp()
    if ForceTH then
        equip(apply_cp(sets.TP.TH))
    else
        equip(apply_cp(sets.TP[TP_Set_Names[TP_Index]]))
    end
end

local function equip_idle()
    equip(apply_cp(sets.Idle[Idle_Set_Names[Idle_Index]]))
end

function precast(spell)
    if sets.JA[spell.english] then
        equip(sets.JA[spell.english])
        return
    end

    if spell.type == 'WeaponSkill' then
        local base = sets.WS[spell.english] or sets.WS.Base
        equip(apply_cp(base))

        local sa = buffactive['Sneak Attack'] or buffactive['sneak attack']
        local ta = buffactive['Trick Attack'] or buffactive['trick attack']

        if sa and ta then
            equip(apply_cp(sets.WS.SATA[spell.english] or sets.WS.SATA.Base or sets.SneakAttack))
        elseif sa then
            equip(apply_cp(sets.WS.SA[spell.english] or sets.WS.SA.Base or sets.SneakAttack))
        elseif ta then
            equip(apply_cp(sets.WS.TA[spell.english] or sets.WS.TA.Base or sets.TrickAttack))
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
    -- Keep Mummu on while the chain is between abilities.
    if os.clock() < sata_ready_at then
        equip(apply_cp(sets.TP.TP))
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
        equip(apply_cp(sets.TP.TP))
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
            equip(apply_cp(sets.SneakAttack))
        elseif player.status == 'Engaged' then
            equip_tp()
        end
    elseif buff == 'trick attack' then
        if gain then
            equip(apply_cp(sets.TrickAttack))
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
    elseif command == 'cp' then
        CpMode = not CpMode
        if CpMode then
            opener_chat('CP gear on: Aptitude Mantle +1 and Jubilee Ring stay equipped')
        else
            opener_chat('CP gear off: Toutatis and Enlivened, Aptitude on weaponskill')
        end
        if player.status == 'Engaged' then equip_tp() else equip_idle() end
    elseif command == 'regear' then
        if player.status == 'Engaged' then equip_tp() else equip_idle() end
    elseif command == 'saopen' then
        -- Stay engaged. Openers skip any JA still cooling, then WS.
        run_opener('SA opener', {
            {RECAST_SA, 'input /ja "Sneak Attack" <me>'},
            {RECAST_FEINT, 'input /ja "Feint" <t>'},
        })
    elseif command == 'taopen' then
        run_opener('TA opener', {
            {RECAST_TA, 'input /ja "Trick Attack" <me>'},
            {RECAST_FEINT, 'input /ja "Feint" <t>'},
        })
    elseif command == 'sata' then
        run_opener('SATA', {
            {RECAST_SA, 'input /ja "Sneak Attack" <me>'},
            {RECAST_TA, 'input /ja "Trick Attack" <me>'},
            {RECAST_FEINT, 'input /ja "Feint" <t>'},
        })
    elseif command == 'openertest' then
        opener_chat('opener commands reachable (try //gs c saopen with TP + target)')
    end
end
