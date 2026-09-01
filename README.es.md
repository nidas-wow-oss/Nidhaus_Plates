*[Read in English](README.md)*

# Nidhaus_Plates

**Build unificada y simplificada de Tidy Plates + Threat Plates para World of Warcraft 3.3.5a (WotLK)**, con marcador de sanadores en battlegrounds integrado.

> **Buscabas TidyPlates?** Estás en el lugar correcto. Nidhaus_Plates es una versión mantenida de **TidyPlates** (con **Threat Plates** ya fusionado adentro) portada y adaptada para 3.3.5a. Instalás una sola carpeta en vez de tres addons separados.

**Autor:** Nidhaus
**Basado en:** Tidy Plates de *Binbwen and Friends* / *Suicidal Katt*, backport de *Kader* · Marcador de sanadores portado de *BattleGroundHealers* de *Khal*

## Por qué existe

El stack clásico de nameplates en 3.3.5a eran tres addons que había que instalar y mantener por separado (`TidyPlates`, `TidyPlates_ThreatPlates`, `BattleGroundHealers`), con un panel de opciones enorme donde el 90% de las opciones no se tocan nunca. Nidhaus_Plates los junta en un solo addon y recorta la configuración a lo que realmente se usa.

## Qué trae

- **Motor Tidy Plates completo** — nameplates reemplazadas, castbars, widgets, detección de objetivo.
- **Tema Threat Plates fusionado** — coloreo por amenaza para tanque y para DPS, sin instalarlo aparte.
- **Marcador de sanadores en BG** — resalta a los healers enemigos en battlegrounds (portado de BattleGroundHealers, de Khal).
- **Fuentes extra** registradas vía LibSharedMedia, seleccionables desde las opciones: *Accidental Presidency*, *Continuum Medium* y *Domyouji Regular*, además de la fuente por defecto.
- **Opciones simplificadas** — panel recortado a los ajustes que se usan de verdad.
- **Botón de minimapa** para abrir la configuración sin comandos.
- Localización incluida: `en`, `es`, `de`, `fr`, `ru`, `cn`, `tw`, `kr`.

## Instalación

1. Cerrá el juego.
2. **Importante:** si tenías `TidyPlates`, `TidyPlates_ThreatPlates` o `BattleGroundHealers` instalados, borralos o desactivalos. Nidhaus_Plates los reemplaza a los tres y van a chocar entre sí.
3. Copiá la carpeta `Nidhaus_Plates` dentro de `World of Warcraft\Interface\AddOns\`.
4. Iniciá el juego y activá el addon en el selector de la pantalla de personajes.

## Comandos

| Comando | Qué hace |
|---|---|
| `/tidyplates` | Abre el panel de opciones principal |
| `/nphealers` o `/bgh` | Opciones del marcador de sanadores en BG |
| `/tptptoggle` | Alterna el tema Threat Plates |
| `/tptptank` | Modo tanque |
| `/tptpdps` | Modo DPS |
| `/tptpol` | Alterna el control de superposición de nameplates |
| `/tptpverbose` | Salida detallada para depurar |

## Créditos

Este addon es trabajo derivado. El crédito del motor y del tema es de sus autores originales:

- **Tidy Plates** — Binbwen and Friends / Suicidal Katt
- **Backport a 3.3.5a** — Kader
- **Threat Plates** — sus autores originales, incluido aquí como tema fusionado
- **BattleGroundHealers** — Khal
- **Unificación, simplificación, fuentes y mantenimiento** — Nidhaus

## Compatibilidad

Interface 30300 — WotLK 3.3.5a. Probado en Warmane.

## Licencia

Se distribuye respetando las licencias de los proyectos originales en los que se basa. Si lo redistribuís o lo usás como base, mantené los créditos de arriba.
