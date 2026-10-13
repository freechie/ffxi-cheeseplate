-- SellNPC profiles. Load with: //sellnpc <profile>
-- Names must match item en/enl (case-insensitive).
local profiles = {}

-- Cheeseplate vendor trash (inventory only — move from satchel/safe first).
-- Excludes: NIN tools, seals/crests, crystals, imperial coin, geodes,
-- avatarites, skins, scrolls, keys, kupons, furniture, gear, quest items.
-- //sellnpc junk
profiles['junk'] = S{
    -- food / fish / eggs
    '2leaf mandra bud',
    'bird egg',
    'puk egg',
    'land crab meat',
    'barnacle',
    'red terrapin',
    'senroh sardine',
    'crayfish',
    'copper frog',
    'elshimo newt',
    'hare meat',
    'mackerel',
    'shall shell',
    'grape juice',
    'moat carp',
    'kazham peppers',
    -- low-value mats
    'bird feather',
    'bone chip',
    'crab shell',
    'flint stone',
    'rusty bucket',
    'pebble',
    'beehive chip',
    'colibri feather',
    'copper nugget',
    'tin ore',
    'zinc ore',
    'sulfur',
    'revival root',
    'silica',
}

-- Stock example profiles
profiles['powder'] = S{
    'prize powder',
}

profiles['ore'] = S{
    'iron ore',
    'copper ore',
    'tin ore',
}

return profiles
