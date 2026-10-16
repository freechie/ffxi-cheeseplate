--[[
  Cheeseplate DNC/NIN GearSwap - leveling 70 -> 99

  Built from findAll (Crow, War Hoop, Rune Kris, Venom Kukri, Gully, Verus,
  Arctier's, Kappa, Peiste Mantle, Loquacious, Mummu/Espial at 99).
  Missing pieces are skipped safely - fill gaps as you loot/buy.

  Recommended buys (not owned yet): 2x Cermet Kukri (~62), Swift Belt,
  Suppanomimi, Brutal Earring, Rajas Ring, AF waltz pieces.

  Commands:
    //gs c toggle TP set
    //gs c toggle Idle set
    //gs c weapons     - re-pick weapons for current level
    //gs c samba       - Haste Samba
    //gs c waltz       - best Curing Waltz for your level
    //gs c step        - Quickstep (build finishing moves)
    //gs c reverse     - Reverse Flourish (TP from FM)
    //gs c utsu        - Utsusemi: Ni (Ichi if Ni not ready)
    //gs c binds       - rebind for current level and list number-row keys

  Binds: Alt+F1 weapons, Alt+F2 waltz, Alt+F3 TP, Alt+F4 Idle, Alt+F5 utsu
  (Haste Samba is Ctrl+2, not on F-keys)
]]

function get_sets()
    TP_Index = 1
    Idle_Index = 1

    -- ============================================================
    -- Weapons: auto-picked by level (//gs c weapons after ding)
    -- ============================================================
    sets.Weapons = {}
    sets.Weapons.Lv70 = {main="Rune Kris", sub="Venom Kukri", ammo="War Hoop"}
    sets.Weapons.Lv72 = {main="Gully", sub="Rune Kris", ammo="War Hoop"}
    sets.Weapons.Lv87 = {main="Verus Knife", sub="Gully", ammo="War Hoop"}
    sets.Weapons.Lv99 = {main="Kaja Knife", sub="Homestead Dagger", ammo="War Hoop"}
    -- Fallback 99 sub if Homestead is elsewhere:
    -- sets.Weapons.Lv99 = {main="Kaja Knife", sub="Eminent Dagger", ammo="War Hoop"}

    -- ============================================================
    -- JA / Dance
    -- ============================================================
    sets.JA = {}

    -- Waltz: CHR/VIT. Swap in Dancer's Casaque / Tiara / Toe Shoes when you have them.
    sets.JA.Waltz = {
        head="Crow Beret",
        body="Crow Jupon",
        hands="Crow Bracers",
        legs="Crow Hose",
        feet="Crow Gaiters",
        neck="Kappa Necklace",
        back="Peiste Mantle",
    }

    sets.JA.Jig = {
        feet="Crow Gaiters", -- Dancer's Toe Shoes / Etoile Toe Shoes when available
    }

    sets.JA.Samba = {
        head="Crow Beret", -- Dancer's Tiara enhances Samba duration
    }

    sets.JA.Step = {
        head="Crow Beret",
        body="Crow Jupon",
        hands="Crow Bracers",
        legs="Crow Hose",
        feet="Crow Gaiters",
        neck="Arctier's Torque",
        back="Peiste Mantle",
        ammo="War Hoop",
    }

    sets.JA['Feather Step'] = sets.JA.Step
    sets.JA['No Foot Rise'] = {}
    sets.JA['Climactic Flourish'] = {}
    sets.JA['Striking Flourish'] = {}
    sets.JA['Reverse Flourish'] = {}
    sets.JA['Violent Flourish'] = {
        head="Crow Beret",
        body="Crow Jupon",
        hands="Crow Bracers",
        legs="Crow Hose",
        feet="Crow Gaiters",
        neck="Kappa Necklace",
    }
    sets.JA['Animated Flourish'] = {}
    sets.JA.Trance = {}
    sets.JA['Saber Dance'] = {}
    sets.JA['Fan Dance'] = {}

    -- ============================================================
    -- WS (leveling: Dancing Edge / Evisceration -> Exenterator -> Rudra's)
    -- ============================================================
    sets.WS = {}
    sets.WS.Base = {
        head="Crow Beret",
        body="Crow Jupon",
        hands="Crow Bracers",
        legs="Crow Hose",
        feet="Crow Gaiters",
        neck="Arctier's Torque",
        back="Peiste Mantle",
        ammo="War Hoop",
    }

    sets.WS['Dancing Edge'] = sets.WS.Base
    sets.WS.Evisceration = sets.WS.Base
    sets.WS['Shark Bite'] = sets.WS.Base
    sets.WS.Exenterator = sets.WS.Base
    sets.WS['Pyrrhic Kleos'] = sets.WS.Base
    sets.WS["Rudra's Storm"] = sets.WS.Base
    sets.WS['Aeolian Edge'] = sets.WS.Base

    -- At 99, prefer Mummu for WS/TP (swap these tables when you hit 99)
    sets.WS.Mummu = {
        head="Mummu Bonnet",
        body="Mummu Jacket",
        hands="Mummu Wrists",
        legs="Mummu Kecks",
        feet="Mummu Gamashes",
        neck="Arctier's Torque",
        back="Peiste Mantle",
        ammo="War Hoop",
    }

    -- ============================================================
    -- TP
    -- ============================================================
    TP_Set_Names = {'TP', 'Acc', 'Mummu'}
    sets.TP = {}

    sets.TP.TP = {
        head="Crow Beret",
        body="Crow Jupon",
        hands="Crow Bracers",
        legs="Crow Hose",
        feet="Crow Gaiters",
        neck="Kappa Necklace", -- Arctier's Torque at 80+
        back="Peiste Mantle",
        ammo="War Hoop",
        -- ear1="Suppanomimi", ear2="Brutal Earring",
        -- waist="Swift Belt", ring1="Rajas Ring", ring2="Epona's Ring",
    }

    sets.TP.Acc = {
        head="Ebon Headgear",
        body="Crow Jupon",
        hands="Crow Bracers",
        legs="Crow Hose",
        feet="Crow Gaiters",
        neck="Arctier's Torque",
        back="Peiste Mantle",
        ammo="War Hoop",
    }

    -- Engaged set once you can wear iLvl 119 (cap gear)
    sets.TP.Mummu = {
        head="Mummu Bonnet",
        body="Mummu Jacket",
        hands="Mummu Wrists",
        legs="Mummu Kecks",
        feet="Mummu Gamashes",
        neck="Arctier's Torque",
        waist="Patentia Sash",
        back="Peiste Mantle",
        ammo="War Hoop",
        left_ear="Loquac. Earring",
    }

    -- ============================================================
    -- Idle
    -- ============================================================
    Idle_Set_Names = {'Idle', 'Move'}
    sets.Idle = {}
    sets.Idle.Idle = {
        head="Crow Beret",
        body="Crow Jupon",
        hands="Crow Bracers",
        legs="Crow Hose",
        feet="Crow Gaiters",
        neck="Kappa Necklace",
        back="Peiste Mantle",
        ammo="War Hoop",
    }
    sets.Idle.Move = set_combine(sets.Idle.Idle, {feet="Sprinter's Shoes"})

    -- ============================================================
    -- Magic (Utsusemi from /NIN)
    -- ============================================================
    sets.FastCast = {
        left_ear="Loquac. Earring",
    }
    sets.Utsusemi = {
        left_ear="Loquac. Earring",
        head="Crow Beret",
        body="Crow Jupon",
        hands="Crow Bracers",
        legs="Crow Hose",
        feet="Crow Gaiters",
        back="Peiste Mantle",
    }

    apply_weapons()

    -- Drop the old Alt+F6–F11 layout before binding F1–F5.
    for _, key in ipairs({'!f6', '!f7', '!f8', '!f9', '!f10', '!f11'}) do
        send_command('unbind '..key)
    end
    send_command('bind !f1 gs c weapons')
    send_command('bind !f2 gs c waltz')
    send_command('bind !f3 gs c toggle TP set')
    send_command('bind !f4 gs c toggle Idle set')
    send_command('bind !f5 gs c utsu')

    include('binds.lua')
    set_binds({
        fkeys = {
            ['!f1'] = 'Weapons',
            ['!f2'] = 'Best Waltz',
            ['!f3'] = 'TP set',
            ['!f4'] = 'Idle set',
            ['!f5'] = 'Utsusemi',
        },
        ['^'] = {
            title = 'Steps & WS',
            {'EXP', 'tru exp'},
            {'Haste Samba', 'input /ja "Haste Samba" <me>', 45},
            {'Box Step', 'input /ja "Box Step" <t>', 23},
            {'Quickstep', 'input /ja "Quickstep" <t>', 20},
            {'Feather Step', 'input /ja "Feather Step" <t>', 83},
            {'Stutter Step', 'input /ja "Stutter Step" <t>', 40},
            {'Reverse', 'input /ja "Reverse Flourish" <me>', 40},
            {'Building', 'input /ja "Building Flourish" <me>', 50},
            {'Evisceration', 'input /ws "Evisceration" <t>'},
            {'Dancing Edge', 'input /ws "Dancing Edge" <t>'},
        },
        ['!'] = {
            title = 'Waltzes & flourishes',
            {'C.Waltz V', 'input /ja "Curing Waltz V" <stpc>', 87},
            {'C.Waltz IV', 'input /ja "Curing Waltz IV" <stpc>', 70},
            {'C.Waltz III', 'input /ja "Curing Waltz III" <stpc>', 45},
            {'D.Waltz II', 'input /ja "Divine Waltz II" <me>', 78},
            {'Healing Waltz', 'input /ja "Healing Waltz" <stpc>', 35},
            {'Violent', 'input /ja "Violent Flourish" <t>', 45},
            {'Climactic', 'input /ja "Climactic Flourish" <me>', 80},
            {'Striking', 'input /ja "Striking Flourish" <me>', 89},
            {'Wild', 'input /ja "Wild Flourish" <t>', 60},
            {'Presto', 'input /ja "Presto" <me>', 77},
        },
        ['~^'] = {
            title = 'Utility',
            {'Spectral Jig', 'input /ja "Spectral Jig" <me>', 25},
            {'Chocobo Jig II', 'input /ja "Chocobo Jig II" <me>', 70},
            {'Echad Ring', 'gs c echad'},
            {'Caliber Ring', 'gs c caliber'},
            {'Emperor Band', 'gs c emperor'},
            {'Warp Ring', 'gs c warp'},
            {'Trusts', 'tru'},
            {'Raise trusts', 'tru raise'},
            {'Aspir Samba II', 'input /ja "Aspir Samba II" <me>', 60},
            {'Drain Samba III', 'input /ja "Drain Samba III" <me>', 65},
        },
        ['~!'] = {
            title = 'Flourishes & toggles',
            {'Animated', 'input /ja "Animated Flourish" <t>', 20},
            {'Desperate', 'input /ja "Desperate Flourish" <t>', 30},
            {'Divine Waltz', 'input /ja "Divine Waltz" <me>', 25},
            {'Aeolian Edge', 'input /ws "Aeolian Edge" <t>'},
            {'Shark Bite', 'input /ws "Shark Bite" <t>'},
            {'Trance', 'input /ja "Trance" <me>'},
            {'Food', 'input /item "Grape Daifuku" <me>'},
            {'TP set', 'gs c toggle TP set'},
            {'Idle set', 'gs c toggle Idle set'},
            {'Dismiss', 'input /refa all'},
        },
    })

    send_command('input /macro book 1; wait 0.1; input /macro set 1')
    send_command('@input /echo [GearSwap] DNC/NIN leveling - Alt+F1 weapons | F2 waltz | F3 TP | F4 idle | F5 utsu | //gs c binds lists number keys')
end

function file_unload()
    clear_binds()
    send_command('unbind !f1')
    send_command('unbind !f2')
    send_command('unbind !f3')
    send_command('unbind !f4')
    send_command('unbind !f5')
    -- Clear previous Alt+F6–F11 layout if this file was reloaded mid-session.
    send_command('unbind !f6')
    send_command('unbind !f7')
    send_command('unbind !f8')
    send_command('unbind !f9')
    send_command('unbind !f10')
    send_command('unbind !f11')
end

function apply_weapons()
    local lvl = player.main_job_level
    local w
    if lvl >= 99 then
        w = sets.Weapons.Lv99
        if sets.WS.Mummu then
            sets.WS.Base = sets.WS.Mummu
            sets.WS['Dancing Edge'] = sets.WS.Mummu
            sets.WS.Evisceration = sets.WS.Mummu
            sets.WS['Shark Bite'] = sets.WS.Mummu
            sets.WS.Exenterator = sets.WS.Mummu
            sets.WS['Pyrrhic Kleos'] = sets.WS.Mummu
            sets.WS["Rudra's Storm"] = sets.WS.Mummu
        end
    elseif lvl >= 87 then
        w = sets.Weapons.Lv87
    elseif lvl >= 72 then
        w = sets.Weapons.Lv72
    else
        w = sets.Weapons.Lv70
    end
    sets.Weapons.Current = w
    equip(w)
    send_command('@input /echo [GearSwap] Weapons: '..(w.main or '?')..' / '..(w.sub or '?')..' (Lv'..lvl..')')
end

local function equip_tp()
    local set = sets.TP[TP_Set_Names[TP_Index]]
    equip(sets.Weapons.Current or {}, set)
end

local function equip_idle()
    equip(sets.Weapons.Current or {}, sets.Idle[Idle_Set_Names[Idle_Index]])
end

local function best_waltz()
    local lvl = player.main_job_level
    if lvl >= 87 then return 'Curing Waltz V' end
    if lvl >= 70 then return 'Curing Waltz IV' end
    if lvl >= 45 then return 'Curing Waltz III' end
    if lvl >= 30 then return 'Curing Waltz II' end
    return 'Curing Waltz'
end

function precast(spell)
    if spell.type == 'WeaponSkill' then
        equip(sets.WS[spell.english] or sets.WS.Base)
        if buffactive['Climactic Flourish'] then
            equip(sets.JA['Climactic Flourish'])
        elseif buffactive['Striking Flourish'] then
            equip(sets.JA['Striking Flourish'])
        end
        return
    end

    if spell.type == 'Waltz' then
        if buffactive['Saber Dance'] then
            windower.ffxi.cancel_buff(410)
        end
        equip(sets.JA.Waltz)
        return
    end

    if spell.type == 'Samba' then
        if buffactive['Fan Dance'] then
            windower.ffxi.cancel_buff(411)
        end
        equip(sets.JA.Samba)
        return
    end

    if spell.type == 'Jig' then
        if spell.english == 'Spectral Jig' and buffactive.sneak then
            windower.ffxi.cancel_buff(71)
        end
        equip(sets.JA.Jig)
        return
    end

    if spell.type == 'Step' then
        equip(sets.JA.Step)
        return
    end

    if sets.JA[spell.english] then
        equip(sets.JA[spell.english])
        return
    end

    if spell.action_type == 'Magic' then
        equip(sets.FastCast)
        if spell.english:find('Utsusemi') then
            equip(sets.Utsusemi)
            if spell.english == 'Utsusemi: Ichi'
                and (buffactive['Copy Image'] or buffactive['Copy Image (2)']
                    or buffactive['Copy Image (3)'] or buffactive['Copy Image (4+)']) then
                send_command('cancel 66; cancel 444; cancel 445; cancel 446')
            end
        end
    end
end

function midcast(spell)
    if spell.english:find('Utsusemi') then
        equip(sets.Utsusemi)
    elseif spell.type == 'Waltz' then
        equip(sets.JA.Waltz)
    elseif spell.type == 'Step' then
        equip(sets.JA.Step)
    elseif spell.type == 'Samba' then
        equip(sets.JA.Samba)
    elseif spell.type == 'Jig' then
        equip(sets.JA.Jig)
    elseif sets.JA[spell.english] then
        equip(sets.JA[spell.english])
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
    elseif command == 'weapons' then
        apply_weapons()
        if player.status == 'Engaged' then equip_tp() else equip_idle() end
    elseif command == 'samba' then
        send_command('input /ja "Haste Samba" <me>')
    elseif command == 'waltz' then
        send_command('input /ja "'..best_waltz()..'" <stpc>')
    elseif command == 'step' then
        send_command('input /ja "Quickstep" <t>')
    elseif command == 'reverse' then
        send_command('input /ja "Reverse Flourish" <me>')
    elseif command == 'utsu' then
        send_command('input /ma "Utsusemi: Ni" <me>')
    end
end
