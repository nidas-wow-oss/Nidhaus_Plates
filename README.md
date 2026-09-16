*[Leer en español](README.es.md)*

# Nidhaus_Plates

**A unified, simplified build of Tidy Plates + Threat Plates for World of Warcraft 3.3.5a (WotLK)**, with a battleground healer marker built in.

> **Looking for TidyPlates?** You are in the right place. Nidhaus_Plates is a maintained version of **TidyPlates** (with **Threat Plates** already merged in) ported and adapted for 3.3.5a. You install one folder instead of three separate addons.

**Author:** Nidhaus
**Based on:** Tidy Plates by *Binbwen and Friends* / *Suicidal Katt*, backport by *Kader* · Healer marker ported from *BattleGroundHealers* by *Khal*

## Why it exists

The classic nameplate stack on 3.3.5a was three addons you had to install and keep in sync separately (`TidyPlates`, `TidyPlates_ThreatPlates`, `BattleGroundHealers`), with a huge options panel where 90% of the settings are never touched. Nidhaus_Plates merges them into one addon and trims the configuration down to what actually gets used.

## What's included

- **The full Tidy Plates engine** — replaced nameplates, cast bars, widgets, target detection.
- **Threat Plates merged in** — threat colouring for tank and DPS, with nothing extra to install.
- **Battleground healer marker** — highlights enemy healers in battlegrounds (ported from BattleGroundHealers by Khal).
- **Extra fonts** registered through LibSharedMedia and selectable from the options: *Accidental Presidency*, *Continuum Medium* and *Domyouji Regular*, alongside the default font.
- **Simplified options** — the panel trimmed down to the settings that matter.
- **Hide enemy Mirror Image nameplates** — an option that removes the clones' plates so the real mage stays readable.
- **Minimap button** to open the configuration without typing commands.
- Localisation included: `en`, `es`, `de`, `fr`, `ru`, `cn`, `tw`, `kr`.

## Installation

1. Close the game.
2. **Important:** if you have `TidyPlates`, `TidyPlates_ThreatPlates` or `BattleGroundHealers` installed, delete or disable them. Nidhaus_Plates replaces all three and they will conflict.
3. Copy the `Nidhaus_Plates` folder into `World of Warcraft\Interface\AddOns\`.
4. Start the game and enable the addon on the character selection screen.

## Commands

| Command | Action |
|---|---|
| `/tidyplates` or `/tptp` | Open the main options panel |
| `/nphealers` or `/bgh` | Battleground healer marker options |
| `/tptpol` | Toggle nameplate overlap control |
| `/tptpverbose` | Verbose output for debugging |

> The addon detects your role from your talents and flips the threat colour scale automatically
> (and by shapeshift form on druids), so there are no manual tank/dps commands to remember.


## Credits

This addon is derivative work. Credit for the engine and the theme belongs to their original authors:

- **Tidy Plates** — Binbwen and Friends / Suicidal Katt
- **3.3.5a backport** — Kader
- **Threat Plates** — its original authors, included here as a merged theme
- **BattleGroundHealers** — Khal
- **Unification, simplification, fonts and maintenance** — Nidhaus

## Compatibility

Interface 30300 — WotLK 3.3.5a. Tested on Warmane.

## License

Distributed in accordance with the licenses of the original projects it builds on. If you redistribute it or build on it, keep the credits above.
