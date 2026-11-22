# FFXI stock UI — what you can actually change

Short findings dump: how far you can push Final Fantasy XI’s built-in UI, what’s already built by the community, and Windower vs Ashita.

## Two different jobs

| Layer | What it changes | How |
|-------|-----------------|-----|
| **A — Stock art** | Real menus, window chrome, fonts, status icons | Client Config + DAT / XIPivot overlays |
| **B — HUD overlays** | Party list, HP/TP bars, hotbar, target bar, etc. | Windower/Ashita addons that *draw on top* |

Overlays do **not** restyle inventory/menus. DAT skins do **not** give you a modern party frame by themselves. People often use both later.

---

## Background color, font, and font size (stock UI)

These are three separate knobs.

### Window background / chrome color

- **Built-in:** `Config → Windows → Window Type` — 8 stock skins (transparent, metallic, etc.).
- **Custom colors:** replace window-tile DATs `ROM\0\14.DAT` through `21.DAT` (slots 1–8), then pick that Window Type in Config. XI View and older window-tile packs ship alternate tiles; rename the one you like into a slot.

### Font face (how the glyphs look)

- **No Config option.**
- Needs a DAT swap, mainly `ROM\119\51.DAT` (main UI/font atlas). XI View and community font packs do this.

### Font size

- **No “text only bigger” setting.**
- Windower **UI scale** (`uiscale` / launcher slider) scales the **whole** stock UI — menus and text together. Same idea as the FFXI Config UI slider.
- Typical comfortable values: ~1.2 at 1080p, ~1.5 at 1440p.

### Chat / battle message colors (not the window)

- `Config → Font Colors` — message categories only, not chrome.

**Key DAT files (if you go custom):**

| File | Role |
|------|------|
| `ROM\0\14.DAT`–`21.DAT` | Window Type slots 1–8 |
| `ROM\119\51.DAT` | Fonts / main GUI atlas |
| `ROM\119\57.DAT` | Status icons (set `Config → Misc → Icon Type 2` for XI View) |

---

## Windower vs Ashita

| Goal | Windower 4 | Ashita v4 |
|------|------------|-----------|
| Scale stock UI | UI scale — works | Works |
| Custom menu / window / font DATs via Pivot | **Menu DATs load too early** — Pivot usually can’t redirect them; need ROM overwrite or skip | **XIPivot can load UI DATs** without overwriting ROM |
| Hide native party chrome | No clean built-in; overlays often *cover* stock party | `HideParty` (community) exists |
| Mature all-in-one HUD | Fragmented (XivParty, XivUI, WXI, etc.) | **[XIUI](https://github.com/tirem/XIUI)** is the main stack |

Bottom line: **overlays work fine on Windower.** Changing real menu art cleanly is **easier on Ashita**. You don’t need to switch launchers just to try overlays.

---

## Prebuilt solutions (don’t write your own first)

### Layer B — HUD overlays (Windower-friendly)

| Project | What it is | Screenshots |
|---------|------------|-------------|
| [XivParty](https://github.com/Tylas11/XivParty) | FFXIV-style party list | [1](https://i.imgur.com/ZVwmwCW.jpg) · [2](https://i.imgur.com/58j2zMk.jpg) · [FFXIAH](https://www.ffxiah.com/forum/topic/55168/xivparty-party-list-addon-for-windower-4/) |
| [WXI Interface](https://github.com/TaruFFXI/WXIUI) | Full modular HUD (XIUI-inspired) | [FullUI](https://raw.githubusercontent.com/TaruFFXI/WXI-Interface/main/screenshots/FullUI.png) · [Party](https://raw.githubusercontent.com/TaruFFXI/WXI-Interface/main/screenshots/PartyHUD.png) · [Banner](https://raw.githubusercontent.com/TaruFFXI/WXI-Interface/main/screenshots/Banner.png) |
| [XivUI](https://github.com/maybeLynd/XivUI) | All-in-one FFXIV-look pack | See repo README |
| [XIVHotbar](https://github.com/SirEdeonX/FFXIAddons/tree/master/xivhotbar) / [Akirane fork](https://github.com/Akirane/XIVHotbar) | Action hotbar | [bars](http://i.imgur.com/RnpVLbZ.png) · [themes](http://i.imgur.com/g72PpaG.png) |
| [FFXI-Dream-UI](https://github.com/Noduko/FFXI-Dream-UI) | Bundled Windower layout | [example](https://raw.githubusercontent.com/Noduko/FFXI-Dream-UI/main/UI%20Example.png) |
| [OmniWatch](https://github.com/BalladOfWorms/OmniWatch) | Separate dashboard (2nd monitor) | [gallery](https://www.reddit.com/gallery/1t8tnmo) · [v1.6](https://www.reddit.com/gallery/1twa02a) |

### Layer A — stock menu / icon skins

| Project | What it is | Where to look |
|---------|------------|---------------|
| [XI View](https://github.com/Caradog/XI-View) | Menus, fonts, status icons | [FFXIAH screenshots](https://www.ffxiah.com/forum/topic/14051/xi-view-xi-vision-in-game-map-and-user-inter/) |
| HD UI / XI View variants | Fonts + menus | [FFXIAH thread](https://www.ffxiah.com/forum/topic/57037/hd-ui-and-skillspell-mods-xivew-variant/4/) |

### Ashita reference (look / later)

| Project | Screenshots |
|---------|-------------|
| [XIUI](https://github.com/tirem/XIUI) (current) | Features on GitHub |
| [HXUI](https://github.com/clanofartisans/HXUI) (same visual family) | [layout shot](https://user-images.githubusercontent.com/124013059/220468124-38323cf6-f6a8-40f8-860c-4420f9632130.png) |

---

## Safe “try it” order

1. **Zero risk:** `Config → Windows → Window Type` + Windower UI scale.
2. **Low risk Windower:** load **XivParty** once (`lua load xivparty`), drag it over the stock party strip, unload when done. Don’t add to `init.txt` until you like it.
3. **Bigger HUD look:** trial **WXI** or **XivUI** the same way (expect overlap with existing addons).
4. **Custom background/font:** DAT packs (XI View). On Windower = ROM overwrite with backups. On Ashita = Pivot preferred.
5. **Full modern stack later:** Ashita + XIUI (+ Pivot XI View if you want real menu skins).

---

## What usually isn’t worth building from scratch

A custom “replace the whole stock UI” plugin. The community already has party lists, hotbars, full HUD packs, and DAT skins. Build only if something specific is missing after trying the above.

---

## One-liner

**Scale + Window Type = easy. Custom chrome/fonts = DAT (Ashita Pivot is cleaner). Modern combat HUD = overlay addons (Windower or Ashita XIUI). Don’t invent a new UI stack first.**
