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
