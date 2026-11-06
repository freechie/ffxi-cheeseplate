-- SellNPC profiles. Load with: //sellnpc <profile>
-- Names must match item en/enl (case-insensitive).
local profiles = {}

-- Cheeseplate vendor trash (inventory only — move from satchel/safe first).
-- //sellnpc junk
--
-- Sources merged, then filtered:
--   - Ivaar SellNPC upstream junk (chestnut, san d'Or. carrot)
--   - greeds.net SellNPC profiles['all'] (JP community vendor-trash list)
--   - Gamer Escape NPC sell guide (low NPC gil / common trash drops)
--   - prior Cheeseplate junk list
--
-- Keep only if ALL are true:
--   1) Common drop / inventory filler (not a job tool, seal, crystal, kupon, etc.)
--   2) Selling later is low regret (no strong craft/quest/AH reason to hoard)
--   3) NPC-sellable (SellNPC skips No-NPC-Sale at queue time anyway)
--
-- Explicitly excluded even when online lists include them:
--   NIN tools, seals/crests, crystals, geodes other than snow geode, avatarites, imperial coin,
--   skins/hides with craft demand, scrolls, keys, kupons/pells/vouchers,
--   furniture, gear (except Voay -1 trash), yggrete, abjurations,
--   Velkk mask and necklace (those sell on the AH),
--   testimonies, gardening seeds/cuttings, cooking staples (honey/vanilla/etc.),
--   smithing ores kept in profiles['ore'], prize powder (profiles['powder']).
profiles['junk'] = S{
    -- Ivaar upstream
    'chestnut',
    'san d\'Or. carrot',
    -- food / fish / eggs / produce
    '2leaf mandra bud',
    'acorn',
    'apple au lait',
    'barnacle',
    'beef stewpot',
    'bream sushi',
    'burdock',
    'butterpear',
    'bastore bream',
    'bird egg',
    'black eel',
    'black prawn',
    'black sole',
    'bluetail',
    'brass loach',
    'cobalt jellyfish',
    'contortopus',
    'copper frog',
    'crayfish',
    'crescent fish',
    'dark bass',
    'deathball',
    'dwarf remora',
    'eggplant',
    'elshimo newt',
    'faerie apple',
    'giant catfish',
    'gigant squid',
    'gold carp',
    'grape juice',
    'hare meat',
    'kazham peppers',
    'land crab meat',
    'lizard egg',
    'mackerel',
    'melon pie',
    'moat carp',
    'napa',
    'pamamas',
    'persikos',
    'pipira',
    'popoto',
    'puk egg',
    'puffball',
    'quus',
    'red terrapin',
    'rolanberry',
    'ryugu titan',
    'rotten meat',
    'senroh sardine',
    'shall shell',
    'sleepshroom',
    'spicy cracker',
    'ulbukan lobster',
    'warthog meat',
    'watermelon',
    'wild onion',
    'woozyshroom',
    -- low-value mats / mob trash
    'antican pauldron',
    'arrowwood log',
    'bat fang',
    'bat wing',
    'beetle jaw',
    'beehive chip',
    'bird feather',
    'blue peas',
    'bomb ash',
    'bone chip',
    'chapuli horn',
    'chapuli wing',
    'colibri beak',
    'colibri feather',
    'copper nugget',
    'crab shell',
    'fish bones',
    'fenrite',
    'fish scales',
    'flint stone',
    'flytrap leaf',
    'gnat wing',
    'goblin grease',
    'igneous rock',
    'insect wing',
    'lizard skin',
    'lizard tail',
    'malboro vine',
    'pebble',
    'porxie wing',
    'ramuite',
    'revival root',
    'rock salt',
    'rusty bucket',
    'seashell',
    'sheep tooth',
    'shivite',
    'silica',
    'skull locust',
    'snow geode',
    'sulfur',
    'tin ore',
    'tulfaire feather',
    'voay staff -1',
    'voay sword -1',
    'yagudo feather',
    'zinc ore',
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
