*[Read in English](README.md)*

# Nidhaus_Plates

**Placas de nombre para World of Warcraft 3.3.5a (WotLK)** con herramientas de amenaza y marcador de sanadores en battlegrounds integrado. Una sola carpeta, un solo panel de opciones, con el estilo de Nidhaus UnitFrames.

**Autor:** Nidhaus · **Versión:** 1.1
**Créditos:** ver la sección del final.

## Por qué existe

Tener buenas nameplates en 3.3.5a era instalar y mantener varios addons por separado, con un panel de opciones enorme donde el 90% de las opciones no se tocan nunca. Nidhaus_Plates es un solo addon con la configuración recortada a lo que realmente se usa.

## Qué trae

- **Motor de placas completo** — nameplates reemplazadas, castbars, widgets, detección de objetivo.
- **Sistema de amenaza** — color, transparencia y escala por amenaza, con un solo juego de niveles.
- **Marcador de sanadores en BG** — resalta a los healers enemigos en battlegrounds (portado de BattleGroundHealers, de Khal).
- **Fuentes extra** registradas vía LibSharedMedia, seleccionables desde las opciones: *Accidental Presidency*, *Continuum Medium* y *Domyouji Regular*, además de la fuente por defecto.
- **Opciones simplificadas** — panel recortado a los ajustes que se usan de verdad.
- **Ocultar las placas de los Mirror Image enemigos** — una opción que saca las placas de los clones para que el mago real se lea.
- **Botón de minimapa** para abrir la configuración sin comandos.
- Localización incluida: `en`, `es`, `de`, `fr`, `ru`, `cn`, `tw`, `kr`.

## Instalación

1. Cerrá el juego.
2. **Importante:** desactivá cualquier otro addon de nameplates o BattleGroundHealers. Nidhaus_Plates ya hace lo suyo y van a chocar entre sí.
3. Copiá la carpeta `Nidhaus_Plates` dentro de `World of Warcraft\Interface\AddOns\`.
4. Iniciá el juego y activá el addon en el selector de la pantalla de personajes.

## Comandos

| Comando | Qué hace |
|---|---|
| `/nplates` o `/tptp` | Abre el panel de opciones principal |
| `/nphealers` o `/bgh` | Opciones del marcador de sanadores en BG |
| `/tptpol` | Alterna el control de superposición de nameplates |
| `/tptpverbose` | Salida detallada para depurar |



## Novedades de la 1.1

- Arreglado el error `attempt to index field 'blizzFade'` al salir o recargar mientras una placa estaba casteando.
- Las barras de casteo de los NPC que no son tu objetivo vuelven a andar con IDs de hechizo que el cliente no conoce (pasa seguido en Warmane): antes se cortaban con un error de Lua.
- Campos de batalla: las placas aliadas muestran el icono de clase correcto desde el principio, leído del marcador.

## Créditos

Este addon es trabajo derivado. El crédito del motor y del tema es de sus autores originales:

- **Motor de placas original** (Tidy Plates) — Binbwen and Friends / Suicidal Katt
- **Backport a 3.3.5a** — Kader
- **Tema de amenaza original** (Threat Plates) — sus autores originales
- **BattleGroundHealers** — Khal
- **Unificación, simplificación, fuentes y mantenimiento** — Nidhaus

## Compatibilidad

Interface 30300 — WotLK 3.3.5a. Probado en Warmane.

## Licencia

Se distribuye respetando las licencias de los proyectos originales en los que se basa. Si lo redistribuís o lo usás como base, mantené los créditos de arriba.
