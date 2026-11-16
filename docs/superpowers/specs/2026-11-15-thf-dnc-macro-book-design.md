# THF/DNC single macro book (Book 1)

Date: 2026-11-15  
Status: approved in chat; awaiting implementation plan

## Goals

- One maintained in-game macro book for **THF/DNC** (primary play).
- Palette matches keylabels intent: clear Ctrl/Alt rows; native gamepad only (Approach C). `padmacros` removed.
- No duplicate THF / THF/DNC / THF/WAR books.
- DNC-main and NIN-main books deferred until those jobs are 99.
- Openers use GearSwap chains that skip JAs on cooldown; slot 1 is WS-only fallback.
- Treasure Hunter tagging via **Despoil** on the Alt row (plus future TH gear / Alt+F11 when Chaac etc. exist).

## Book layout

**Book 1** title: `THF/DNC`  
**Books 2+:** blank/clear for now.

### Set 1 — Ctrl (Dancer sub)

| # | Macro |
|---|--------|
| 1 | Box Step |
| 2 | Quickstep |
| 3 | Haste Samba |
| 4 | Stutter Step |
| 5 | Reverse Flourish |
| 6 | Violent Flourish |
| 7 | Curing Waltz III |
| 8 | Healing Waltz |
| 9 | Divine Waltz |
| 0 | Animated Flourish |

**Out of Ctrl (function-key overflow):** Spectral Jig, Drain Samba II, Aspir Samba.

### Set 1 — Alt (openers + THF tools)

| # | Macro | Behavior |
|---|--------|----------|
| 1 | Evisceration | WS only |
| 2 | SA opener | Sneak Attack → Feint → Assassin’s Charge → Evisceration; skip any JA on recast; still WS if TP allows |
| 3 | TA opener | Trick Attack → Feint → Assassin’s Charge → Evisceration; same skip rules |
| 4 | SATA | SA → TA → Feint → Assassin’s Charge → Evisceration; skip JAs on recast (extend existing `gs c sata`) |
| 5 | Feint | `/ja` |
| 6 | Hide | `/ja` |
| 7 | Despoil | `/ja` — TH tag |
| 8 | Conspirator | `/ja` |
| 9 | Perfect Dodge | `/ja` |
| 0 | Flee | `/ja` |

### Set 2

Fully clear (no Ctrl/Alt macros). Rings, trusts, Idle toggle, TH/TP toggles are not on this book; Alt+F11 TH force and other existing fkey binds may remain in GearSwap until revisited.

## GearSwap / sync changes

- `MACRO_BOOKS.THF = 1`; stop opening combo book 11/12 for DNC/WAR sub.
- Treat THF with DNC sub as: Ctrl = Dancer row, Alt = opener row (keyboard binds + keylabels aligned with Book 1 set 1).
- `sync_macro_names.py`: write Book 1 from the tables above; blank obsolete books; drop multi-book THF combo duplication.
- New/extended GS commands for Alt 2–4 opener chains (recast-aware); keep Alt 1 as plain `/ws "Evisceration" <t>`.
- Live edits under game USER + mirror repo `game/USER/158678d` per existing sync script paths; Windower addon edits under `C:\Windower4` then mirror to repo.

## Out of scope (this change)

- Designing DNC-main or NIN-main books (later at 99).
- Filling `sets.TP.TH` with Chaac Belt (note only; toggle already exists).
- THF/WAR book.

## Success criteria

- In-game Book 1 titled THF/DNC; set 1 matches the tables; set 2 empty; other books blank.
- On THF login with DNC sub, GearSwap selects book 1 set 1; keylabels match set 1.
- Alt 2–4 skip CDed JAs and still attempt Evisceration when appropriate; Alt 1 is always WS-only.
- Despoil available on Alt 7 for TH tagging.
