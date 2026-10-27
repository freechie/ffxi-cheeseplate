--[[
  Cheeseplate NIN GearSwap - keybinds only, no gear swaps yet

  Commands:
    //gs c binds - rebind for current level and list number-row keys
]]

function get_sets()
    include('binds.lua')
    send_command('bind !f1 input /ma "Hyoton: Ichi" <t>')
    send_command('bind !f2 input /ma "Doton: Ichi" <t>')
    send_command('bind !f3 input /ma "Tonko: Ichi" <me>')
    set_binds({
        fkeys = {
            ['!f1'] = 'Hyoton: Ichi',
            ['!f2'] = 'Doton: Ichi',
            ['!f3'] = 'Tonko: Ichi',
        },
        ['^'] = {
            title = 'Combat',
            {'EXP', 'tru exp'},
            {'Utsu Ni', 'input /ma "Utsusemi: Ni" <me>'},
            {'Utsu Ichi', 'input /ma "Utsusemi: Ichi" <me>'},
            {'Yonin', 'input /ja "Yonin" <me>'},
            {'Innin', 'input /ja "Innin" <me>'},
            {'Suiton: Ni', 'input /ma "Suiton: Ni" <t>'},
            {'Katon: Ichi', 'input /ma "Katon: Ichi" <t>'},
            {'Raiton: Ichi', 'input /ma "Raiton: Ichi" <t>'},
            {'Suiton: Ichi', 'input /ma "Suiton: Ichi" <t>'},
            {'Mijin Gakure', 'input /ja "Mijin Gakure" <t>'},
        },
        ['!'] = {
            title = 'Ninjutsu & WS',
            {'Katon: Ni', 'input /ma "Katon: Ni" <t>'},
            {'Hyoton: Ni', 'input /ma "Hyoton: Ni" <t>'},
            {'Huton: Ni', 'input /ma "Huton: Ni" <t>'},
            {'Doton: Ni', 'input /ma "Doton: Ni" <t>'},
            {'Raiton: Ni', 'input /ma "Raiton: Ni" <t>'},
            {'Blade: Jin', 'input /ws "Blade: Jin" <t>'},
            {'Blade: Ten', 'input /ws "Blade: Ten" <t>'},
            {'Blade: Teki', 'input /ws "Blade: Teki" <t>'},
            {'Blade: Chi', 'input /ws "Blade: Chi" <t>'},
            {'Huton: Ichi', 'input /ma "Huton: Ichi" <t>'},
        },
        ['~^'] = {
            title = 'Utility',
            {'Monomi', 'input /ma "Monomi: Ichi" <me>'},
            {'Tonko: Ni', 'input /ma "Tonko: Ni" <me>'},
            {'Echad Ring', 'gs c echad'},
            {'Caliber Ring', 'gs c caliber'},
            {'Warp Ring', 'gs c warp'},
            {'Food', 'input /item "Grape Daifuku" <me>'},
            {'Raise trusts', 'tru raise'},
            {'Trusts', 'tru'},
            {'Emperor Band', 'gs c emperor'},
            {'Dismiss', 'input /refa all'},
        },
        ['~!'] = {
            title = 'Enfeebles',
            {'Hojo: Ni', 'input /ma "Hojo: Ni" <t>'},
            {'Kurayami: Ni', 'input /ma "Kurayami: Ni" <t>'},
            {'Jubaku: Ichi', 'input /ma "Jubaku: Ichi" <t>'},
            {'Dokumori: Ichi', 'input /ma "Dokumori: Ichi" <t>'},
            {'Hojo: Ichi', 'input /ma "Hojo: Ichi" <t>'},
            {'Kurayami: Ichi', 'input /ma "Kurayami: Ichi" <t>'},
            {'Blade: To', 'input /ws "Blade: To" <t>'},
            {'Blade: Ei', 'input /ws "Blade: Ei" <t>'},
            {'Blade: Ku', 'input /ws "Blade: Ku" <t>'},
            {'Blade: Retsu', 'input /ws "Blade: Retsu" <t>'},
        },
    })

    send_command('@input /echo [GearSwap] NIN loaded - //gs c binds lists number keys')
end

function file_unload()
    clear_binds()
    send_command('unbind !f1')
    send_command('unbind !f2')
    send_command('unbind !f3')
end

function self_command(command)
    binds_command(command:lower())
end
