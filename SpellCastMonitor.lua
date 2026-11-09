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

local CombatCastEventWatcher
local CombatEventHandlers = {}

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
		if VisiblePlate.extended.unit.isMarked and (VisiblePlate.extended.unit.raidIcon == UnitIcon) then
			return VisiblePlate
		end
	end
end

local function OnSpellCast(...)
	local sourceGUID, sourceName, sourceFlags, spellid, spellname = ...
	local FoundPlate = nil

	local spell, _, icon = GetSpellInfo(spellid)
	if not spell then
		return
	end

	if bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
		if bit.band(sourceFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then

			FoundPlate = SearchNameplateByName(sourceName)
		elseif bit.band(sourceFlags, COMBATLOG_OBJECT_CONTROL_NPC) > 0 then

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

local function EsUnidadDeGrupo(unit)
	return unit == "pet"
		or unit:find("^party%d$") or unit:find("^partypet%d$")
		or unit:find("^raid%d+$") or unit:find("^raidpet%d+$")
end

local function BuscarPlacaAliada(unit)

	local guid = UnitGUID(unit)
	local plate = guid and NidhausPlates.NameplatesByGUID[guid]
	if plate and NidhausPlates.NameplatesByVisible[plate] then
		return plate
	end

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

function NidhausPlates.TestCastBar(SearchFor, SpellID, Shielded, ForceChanneled)
	local FoundPlate
	local spell, _, icon = GetSpellInfo(SpellID)
	local channel

	for VisiblePlate in pairs(NidhausPlates.NameplatesByVisible) do
		if VisiblePlate.extended.unit.name == SearchFor or VisiblePlate.extended.unit.guid == SearchFor then
			FoundPlate = VisiblePlate
			break
		end
	end

	if FoundPlate then
		print("Testing Spell Cast on", SearchFor, "(no cast animation)")
		StartCastAnimationOnNameplate(FoundPlate, spell, spell, icon, Shielded, ForceChanneled)
	end
end
