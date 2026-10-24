# SellNPC (Ivaar)

Queue items, then open any NPC shop — queued inventory stacks sell automatically.

## Commands

```
//lua load SellNPC          -- if not autoloaded
//sellnpc junk              -- queue the junk profile
//sellnpc bird feather      -- queue one item by name
```

Then talk to a standard shop NPC (e.g. city vendor) and open the shop window.

## Notes

- Only sells from **inventory** (not satchel/safe/case). Move stacks first.
- Skips equipped, bazaared, and No-NPC-Sale items.
- Packet-injecting shop sells; same class of risk as other Windower shop helpers.

## How `junk` is built

There is no official junk verifier. `profiles['junk']` is a curated allowlist from:

1. [Ivaar SellNPC](https://github.com/Ivaar/Windower-addons/blob/master/SellNPC/profiles.lua) upstream `junk`
2. [greeds.net SellNPC `all`](https://greeds.net/windower-addon-sellnpc-how-to/) community trash list
3. [Gamer Escape NPC sell guide](https://ffxi.gamerescape.com/wiki/NPC_sell_guide) (low-value common drops)
4. Prior Cheeseplate trash

An item is kept on the list only if:

- Selling it later is low regret (craft / quest / AH / job tools)
- It is not in the explicit exclude set (crystals, seals, seeds, cooking staples, etc.)
- SellNPC can NPC-sell it (`No NPC Sale` items never queue)

Keep `//sellnpc powder` and `//sellnpc ore` separate when you want those stacks.
