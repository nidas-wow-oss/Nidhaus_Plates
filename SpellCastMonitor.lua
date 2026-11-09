local _
local RaidTargetReference = {
	STAR = 0x00100000,
	CIRCLE = 0x00200000,
	DIAMOND = 0x00400000,
	TRIANGLE = 0x00800000,
	MOON = 0x01000000,
	SQUARE = 0x02000000,
	CROSS = 0x04000000,
	SKULL = 0x08000000
}

-------------------------------------------------------------------------
-- Spell Cast Event Watcher.
-------------------------------------------------------------------------
local CombatCastEventWatcher
local CombatEventHandlers = {}

-- If you don't define a local reference,
-- the Nidhaus Plates table will get passed to the function.
local StartCastAnimationOnNameplate = NidhausPlates.StartCastAnimationOnNameplate

local function SearchNameplateByGUID(SearchFor)
	for VisiblePlate in pairs(NidhausPlates.NameplatesByVisible) do
		local UnitGUID = VisiblePlate.extended.unit.guid
		if UnitGUID and UnitGUID == SearchFor then
			return VisiblePlate
		end
	end
end

local function SearchNameplateByName(NameString)
	local SearchFor = strsplit("-", NameString)
	for VisiblePlate in pairs(NidhausPlates.NameplatesByVisible) do
		if VisiblePlate.extended.unit.name == SearchFor then
			return VisiblePlate
		end
	end
end

local function SearchNameplateByIcon(UnitFlags)
	local UnitIcon
	for iconname, bitmask in pairs(RaidTargetReference) do
		if bit.band(UnitFlags, bitmask) > 0 then
			UnitIcon = iconname
			break
		end
	end

	for VisiblePlate in pairs(NidhausPlates.NameplatesByVisible) do
		if VisiblePlate.extended.unit.isMarked and (VisiblePlate.extended.unit.raidIcon == UnitIcon) then -- BY Icon
			return VisiblePlate
		end
	end
end

--------------------------------------
-- OnSpellCast
-- Sends cast event to an available nameplate
--------------------------------------
local function OnSpellCast(...)
	local sourceGUID, sourceName, sourceFlags, spellid, spellname = ...
	local FoundPlate = nil

	-- Gather Spell Info
	--
	-- GetSpellInfo devuelve NIL ENTERO cuando el cliente no conoce el ID:
	-- hechizos propios del servidor, o IDs que aparecen en el registro de
	-- combate pero no estan en la base de datos del cliente. En Warmane pasa
	-- a menudo. Antes se leia castTime y se comparaba con 0 sin comprobar
	-- nada, asi que cada vez que casteaba un NPC que no era tu objetivo
	-- saltaba "attempt to compare nil with number" y la funcion se cortaba
	-- ahi: por eso no se dibujaba la barra.
	--
	-- La comprobacion de castTime no hace falta: SPELL_CAST_START solo se
	-- dispara con hechizos que tienen tiempo de lanzamiento (los instantaneos
	-- emiten SPELL_CAST_SUCCESS). Pero la guarda de nil SI hace falta, o se
	-- dibujaria una barra sin nombre ni icono.
	local spell, _, icon = GetSpellInfo(spellid)
	if not spell then
		return
	end

	if bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
		if bit.band(sourceFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
			--	destination plate, by name
			FoundPlate = SearchNameplateByName(sourceName)
		elseif bit.band(sourceFlags, COMBATLOG_OBJECT_CONTROL_NPC) > 0 then
			--	destination plate, by GUID
			FoundPlate = SearchNameplateByGUID(sourceGUID)
			if not FoundPlate then
				FoundPlate = SearchNameplateByIcon(sourceFlags)
			end
		else
			return
		end
	else
		return
	end

	-- If the unit's nameplate is visible, show the cast bar
	if FoundPlate then
		local FoundPlateUnit = FoundPlate.extended.unit
		if not FoundPlateUnit.isTarget then
			StartCastAnimationOnNameplate(FoundPlate, spell, spellid, icon, false, false)
		end
	end
end

function CombatEventHandlers.SPELL_CAST_START(...)
	OnSpellCast(...)
end

--------------------------------------
-- Casteos de aliados: party, raid y sus mascotas
--
-- OnSpellCast (registro de combate) solo atiende a los HOSTILES, asi que los
-- casteos de tu grupo nunca llegaban a su placa. Para ellos hay algo mejor
-- que el registro de combate: tienen unitID (party1, partypet1...), asi que
-- UnitCastingInfo da el hechizo con su inicio y su final exactos, y los
-- eventos UNIT_SPELLCAST_* avisan tambien de cortes y retrasos.
--------------------------------------
local function EsUnidadDeGrupo(unit)
	return unit == "pet"
		or unit:find("^party%d$") or unit:find("^partypet%d$")
		or unit:find("^raid%d+$") or unit:find("^raidpet%d+$")
end

local function BuscarPlacaAliada(unit)
	-- Primero por GUID, que es exacto; el motor lo conoce si la placa ya fue
	-- objetivo o paso el mouse por encima.
	local guid = UnitGUID(unit)
	local plate = guid and NidhausPlates.NameplatesByGUID[guid]
	if plate and NidhausPlates.NameplatesByVisible[plate] then
		return plate
	end
	-- Si no, por nombre, y solo entre placas aliadas: un enemigo con el mismo
	-- nombre no se tiene que llevar la barra.
	local name = UnitName(unit)
	if not name then return end
	for VisiblePlate in pairs(NidhausPlates.NameplatesByVisible) do
		local u = VisiblePlate.extended.unit
		if u.name == name and u.reaction == "FRIENDLY" then
			return VisiblePlate
		end
	end
end

local function OnGroupSpellCast(unit)
	if not unit or not EsUnidadDeGrupo(unit) then return end
	-- El objetivo ya lo maneja el motor con su propia barra.
	if UnitIsUnit(unit, "target") then return end
	local plate = BuscarPlacaAliada(unit)
	if not plate then return end

	local spell, _, _, icon, startMS, endMS, _, _, notInt = UnitCastingInfo(unit)
	local channel
	if not spell then
		spell, _, _, icon, startMS, endMS, _, notInt = UnitChannelInfo(unit)
		channel = true
	end
	if spell then
		StartCastAnimationOnNameplate(plate, spell, nil, icon, notInt, channel, startMS, endMS)
	else
		NidhausPlates.StopCastAnimationOnNameplate(plate)
	end
end

local GroupCastEvents = {
	"UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_FAILED",
	"UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_DELAYED",
	"UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE",
	"UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_INTERRUPTIBLE",
	"UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
}

--------------------------------------
-- Watch Combat Log Events
--------------------------------------

local function OnCombatEvent(self, event, ...)
	if event ~= "COMBAT_LOG_EVENT_UNFILTERED" then
		OnGroupSpellCast((...))
		return
	end
	local _, combatevent, sourceGUID, sourceName, sourceFlags, _, _, _, spellid, spellname = ...
	if CombatEventHandlers[combatevent] and sourceGUID ~= UnitGUID("player") and sourceGUID ~= UnitGUID("target") and spellid then
		CombatEventHandlers[combatevent](sourceGUID, sourceName, sourceFlags, spellid, spellname)
	end
end

-----------------------------------
-- External control functions
-----------------------------------

local function StartSpellCastWatcher()
	if not CombatCastEventWatcher then
		CombatCastEventWatcher = CreateFrame("Frame")
	end
	CombatCastEventWatcher:SetScript("OnEvent", OnCombatEvent)
	CombatCastEventWatcher:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	for _, ev in ipairs(GroupCastEvents) do
		CombatCastEventWatcher:RegisterEvent(ev)
	end
end

local function StopSpellCastWatcher()
	if CombatCastEventWatcher then
		CombatCastEventWatcher:SetScript("OnEvent", nil)
		CombatCastEventWatcher:UnregisterAllEvents()
		CombatCastEventWatcher = nil
	end
end

NidhausPlates.StartSpellCastWatcher = StartSpellCastWatcher
NidhausPlates.StopSpellCastWatcher = StopSpellCastWatcher

-- The spell ID number of Fireball is 133
-- To test spell cast: /run TestNidhausPlatesCastBar("Boognish", 133, true)
function NidhausPlates.TestCastBar(SearchFor, SpellID, Shielded, ForceChanneled)
	local FoundPlate
	local spell, _, icon = GetSpellInfo(SpellID)
	local channel

	-- Search for the nameplate, by name (you could also search by GUID)
	for VisiblePlate in pairs(NidhausPlates.NameplatesByVisible) do
		if VisiblePlate.extended.unit.name == SearchFor or VisiblePlate.extended.unit.guid == SearchFor then
			FoundPlate = VisiblePlate
			break
		end
	end

	-- If found, display the cast bar
	if FoundPlate then
		print("Testing Spell Cast on", SearchFor, "(no cast animation)")
		StartCastAnimationOnNameplate(FoundPlate, spell, spell, icon, Shielded, ForceChanneled)
	end
end