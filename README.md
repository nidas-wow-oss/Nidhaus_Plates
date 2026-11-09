*[Leer en español](README.es.md)*

# Nidhaus_Plates

**Nameplates for World of Warcraft 3.3.5a (WotLK)** with threat tools and a battleground healer marker built in. One folder, one options panel, styled like Nidhaus UnitFrames.

**Author:** Nidhaus · **Version:** 1.1
**Credits:** see the section at the end.

## Why it exists

Good nameplates on 3.3.5a used to mean several addons installed and kept in sync separately, with a huge options panel where 90% of the settings are never touched. Nidhaus_Plates is one addon with the configuration trimmed down to what actually gets used.

## What's included

- **Full nameplate engine** — replaced nameplates, cast bars, widgets, target detection.
- **Threat system** — threat colouring, alpha and scale, with one simple set of threat levels.
- **Battleground healer marker** — highlights enemy healers in battlegrounds (ported from BattleGroundHealers by Khal).
- **Extra fonts** registered through LibSharedMedia and selectable from the options: *Accidental Presidency*, *Continuum Medium* and *Domyouji Regular*, alongside the default font.
- **Simplified options** — the panel trimmed down to the settings that matter.
- **Hide enemy Mirror Image nameplates** — an option that removes the clones' plates so the real mage stays readable.
- **Minimap button** to open the configuration without typing commands.
- Localisation included: `en`, `es`, `de`, `fr`, `ru`, `cn`, `tw`, `kr`.

## Installation

1. Close the game.
2. **Important:** disable any other nameplate addon or BattleGroundHealers. Nidhaus_Plates already does their job and they will conflict.
3. Copy the `Nidhaus_Plates` folder into `World of Warcraft\Interface\AddOns\`.
4. Start the game and enable the addon on the character selection screen.

## Commands

| Command | Action |
|---|---|
| `/nplates` or `/tptp` | Open the main options panel |
| `/nphealers` or `/bgh` | Battleground healer marker options |
| `/tptpol` | Toggle nameplate overlap control |
| `/tptpverbose` | Verbose output for debugging |



## What's new in 1.1

- Fixed the error `attempt to index field 'blizzFade'` when logging out or reloading while a nameplate was casting.
- Cast bars of NPCs that are not your target work again with spell IDs the client does not know (common on Warmane): they used to stop with a Lua error.
- Battlegrounds: friendly nameplates show the right class icon from the start, read from the scoreboard.

## Credits

This addon is derivative work. Credit for the engine and the theme belongs to their original authors:

- **Original nameplate engine** (Tidy Plates) — Binbwen and Friends / Suicidal Katt
- **3.3.5a backport** — Kader
- **Original threat theme** (Threat Plates) — its original authors
- **BattleGroundHealers** — Khal
- **Unification, simplification, fonts and maintenance** — Nidhaus

## Compatibility

Interface 30300 — WotLK 3.3.5a. Tested on Warmane.

## License

Distributed in accordance with the licenses of the original projects it builds on. If you redistribute it or build on it, keep the credits above.
