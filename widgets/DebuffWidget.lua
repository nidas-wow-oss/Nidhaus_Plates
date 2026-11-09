NidhausPlatesWidgets.DebuffWidgetBuild = 2

local GetSpellInfo = GetSpellInfo
local PolledHideIn = NidhausPlatesWidgets.PolledHideIn
local AuraMonitor = CreateFrame("Frame")

local WidgetList = setmetatable({}, {__mode = "kv"})
local weaktable = NidhausPlatesUtility.weaktable
local WidgetGUID = setmetatable({}, weaktable)

local UpdateWidget
local TargetOfGroupMembers = {}
local MaximumDisplayableDebuffs = 6

local AURA_TARGET_HOSTILE = 1
local AURA_TARGET_FRIENDLY = 2

local AURA_TYPE_BUFF = 1
local AURA_TYPE_DEBUFF = 6

local AURA_TYPE = {
	["Buff"] = 1,
	["Curse"] = 2,
	["Disease"] = 3,
	["Magic"] = 4,
	["Poison"] = 5,
	["Debuff"] = 6
}

local function GetAuraWidgetByGUID(guid)
	if guid then
		return WidgetGUID[guid]
	end
end

local function IsAuraShown(widget, aura)
	if widget and widget.IsShown then
		for i = 1, 6 do
			if widget.AuraIconFrames[i] and widget.AuraIconFrames[i]:IsShown() then
				return true
			end
		end
	end
end

local RaidIconBit = {
	["STAR"] = 0x00100000,
	["CIRCLE"] = 0x00200000,
	["DIAMOND"] = 0x00400000,
	["TRIANGLE"] = 0x00800000,
	["MOON"] = 0x01000000,
	["SQUARE"] = 0x02000000,
	["CROSS"] = 0x04000000,
	["SKULL"] = 0x08000000
}

local RaidIconIndex = {
	"STAR",
	"CIRCLE",
	"DIAMOND",
	"TRIANGLE",
	"MOON",
	"SQUARE",
	"CROSS",
	"SKULL"
}

local ByRaidIcon = setmetatable({}, weaktable)
local ByName = setmetatable({}, weaktable)

local PlayerDispelCapabilities = {
	["Curse"] = false,
	["Disease"] = false,
	["Magic"] = false,
	["Poison"] = false
}

local function UpdatePlayerDispelTypes()
	PlayerDispelCapabilities["Curse"] = IsSpellKnown(51886) or IsSpellKnown(475) or IsSpellKnown(2782)
	PlayerDispelCapabilities["Poison"] = IsSpellKnown(2782) or IsSpellKnown(32375) or IsSpellKnown(4987) or (IsSpellKnown(527) and IsSpellKnown(33167))
	PlayerDispelCapabilities["Magic"] = (IsSpellKnown(4987) and IsSpellKnown(53551)) or (IsSpellKnown(527) and IsSpellKnown(33167)) or IsSpellKnown(32375)
	PlayerDispelCapabilities["Disease"] = IsSpellKnown(4987) or IsSpellKnown(528)
end

local function CanPlayerDispel(debuffType)
	return PlayerDispelCapabilities[debuffType or ""]
end

local function DefaultFilterFunction(debuff)
	return (debuff.duration < 600)
end

local function FindWidgetByGUID(guid)
	return WidgetGUID[guid]
end

local function FindWidgetByName(SearchFor)
	for widget in pairs(WidgetList) do
		if widget.unit.name == SearchFor then
			return widget
		end
	end
end

local function FindWidgetByIcon(raidicon)
	for widget in pairs(WidgetList) do
		if widget.unit.isMarked and widget.unit.raidIcon == raidicon then
			return widget
		end
	end
end

local function CallForWidgetUpdate(guid, raidicon, name)
	local widget

	if guid then
		widget = FindWidgetByGUID(guid)
	end

	if not widget and name then
		widget = FindWidgetByName(name)
	end

	if not widget and raidicon then
		widget = FindWidgetByIcon(raidicon)
	end

	if widget then
		UpdateWidget(widget)
	end
end

NidhausPlatesData = NidhausPlatesData or {}
NidhausPlatesData.CachedAuraDurations = {}

local function GetSpellDuration(spellid)
	if spellid then
		return NidhausPlatesData.CachedAuraDurations[spellid]
	end
end

local function SetSpellDuration(spellid, duration)
	if spellid then
		NidhausPlatesData.CachedAuraDurations[spellid] = duration
	end
end

local newTable = NidhausPlatesUtility.NewTable
local delTable = NidhausPlatesUtility.DelTable

local Aura_List = setmetatable({}, weaktable)
local Aura_Spellid = {}
local Aura_Expiration = {}
local Aura_Stacks = {}
local Aura_Caster = {}
local Aura_Duration = {}
local Aura_Texture = {}
local Aura_Type = {}
local Aura_Target = {}

local function SetAuraInstance(guid, spellid, expiration, stacks, caster, duration, texture, auratype, auratarget)
	if guid and spellid and caster and texture then
		local aura_id = spellid .. (tostring(caster or "UNKNOWN_CASTER"))
		local aura_instance_id = guid .. aura_id
		Aura_List[guid] = Aura_List[guid] or newTable()
		Aura_List[guid][aura_id] = aura_instance_id
		Aura_Spellid[aura_instance_id] = spellid
		Aura_Expiration[aura_instance_id] = expiration
		Aura_Stacks[aura_instance_id] = stacks
		Aura_Caster[aura_instance_id] = caster
		Aura_Duration[aura_instance_id] = duration
		Aura_Texture[aura_instance_id] = texture
		Aura_Type[aura_instance_id] = auratype
		Aura_Target[aura_instance_id] = auratarget
	end
end

local function GetAuraInstance(guid, aura_id)
	if guid and aura_id then
		local aura_instance_id = guid .. aura_id
		local spellid, expiration, stacks, caster, duration, texture, auratype
		spellid = Aura_Spellid[aura_instance_id]
		expiration = Aura_Expiration[aura_instance_id]
		stacks = Aura_Stacks[aura_instance_id]
		caster = Aura_Caster[aura_instance_id]
		duration = Aura_Duration[aura_instance_id]
		texture = Aura_Texture[aura_instance_id]
		auratype = Aura_Type[aura_instance_id]
		auratarget = Aura_Target[aura_instance_id]
		return spellid, expiration, stacks, caster, duration, texture, auratype, auratarget
	end
end

local function WipeAuraList(guid)
	if guid and Aura_List[guid] then
		local unit_aura_list = Aura_List[guid]
		for aura_id, aura_instance_id in pairs(unit_aura_list) do
			Aura_Spellid[aura_instance_id] = nil
			Aura_Expiration[aura_instance_id] = nil
			Aura_Stacks[aura_instance_id] = nil
			Aura_Caster[aura_instance_id] = nil
			Aura_Duration[aura_instance_id] = nil
			Aura_Texture[aura_instance_id] = nil
			Aura_Type[aura_instance_id] = nil
			Aura_Target[aura_instance_id] = nil
			unit_aura_list[aura_id] = nil
		end
	end
end

local function GetAuraList(guid)
	if guid and Aura_List[guid] then
		return Aura_List[guid]
	end
end

local function RemoveAuraInstance(guid, spellid, caster)
	if guid and spellid and Aura_List[guid] then
		local aura_instance_id = tostring(guid) .. tostring(spellid) .. (tostring(caster or "UNKNOWN_CASTER"))
		local aura_id = spellid .. (tostring(caster or "UNKNOWN_CASTER"))
		if Aura_List[guid][aura_id] then
			Aura_Spellid[aura_instance_id] = nil
			Aura_Expiration[aura_instance_id] = nil
			Aura_Stacks[aura_instance_id] = nil
			Aura_Caster[aura_instance_id] = nil
			Aura_Duration[aura_instance_id] = nil
			Aura_Texture[aura_instance_id] = nil
			Aura_Type[aura_instance_id] = nil
			Aura_Target[aura_instance_id] = nil
			Aura_List[guid][aura_id] = nil
		end
	end
end

local function CleanAuraLists()
	local currentTime = GetTime()
	for guid, instance_list in pairs(Aura_List) do
		local auracount = 0
		for aura_id, aura_instance_id in pairs(instance_list) do
			local expiration = Aura_Expiration[aura_instance_id]
			if expiration and expiration < currentTime then
				Aura_List[guid][aura_id] = nil
				Aura_Spellid[aura_instance_id] = nil
				Aura_Expiration[aura_instance_id] = nil
				Aura_Stacks[aura_instance_id] = nil
				Aura_Caster[aura_instance_id] = nil
				Aura_Duration[aura_instance_id] = nil
				Aura_Texture[aura_instance_id] = nil
				Aura_Type[aura_instance_id] = nil
				Aura_Target[aura_instance_id] = nil
				auracount = auracount + 1
			end
		end
		if auracount == 0 then
			Aura_List[guid] = delTable(Aura_List[guid])
		end
	end
end

local function UpdateAurasByUnitID(unitid)

	local unitType
	if UnitIsFriend("player", unitid) then
		unitType = AURA_TARGET_FRIENDLY
	else
		unitType = AURA_TARGET_HOSTILE
	end
	if unitType == AURA_TARGET_FRIENDLY then
		return
	end

	local guid = UnitGUID(unitid)

	WipeAuraList(guid)

	for index = 1, 32 do
		local name, _, texture, count, dispelType, duration, expirationTime, unitCaster, _, _, spellid =
			UnitDebuff(unitid, index)
		if not name then
			break
		end
		SetSpellDuration(spellid, duration)
		SetAuraInstance(guid, spellid, expirationTime, count, UnitGUID(unitCaster or ""), duration, texture, AURA_TYPE[dispelType or "Debuff"], unitType)
	end

	if unitType == AURA_TARGET_FRIENDLY then
		for index = 1, 32 do
			local name, _, texture, count, dispelType, duration, expirationTime, unitCaster, _, _, spellid =
				UnitBuff(unitid, index)
			if not name then
				break
			end
			SetSpellDuration(spellid, duration)
			SetAuraInstance(guid, spellid, expirationTime, count, UnitGUID(unitCaster or ""), duration, texture, AURA_TYPE_BUFF, AURA_TARGET_FRIENDLY)
		end
	end

	local raidicon, name
	if UnitPlayerControlled(unitid) then
		name = UnitName(unitid)
	end
	raidicon = RaidIconIndex[GetRaidTargetIndex(unitid) or ""]
	if raidicon then
		ByRaidIcon[raidicon] = guid
	end

	CallForWidgetUpdate(guid, raidicon, name)
end

local function UpdateAuraByLookup(guid)
	if guid == UnitGUID("target") then
		UpdateAurasByUnitID("target")
	elseif guid == UnitGUID("mouseover") then
		UpdateAurasByUnitID("mouseover")
	elseif TargetOfGroupMembers[guid] then
		local unit = TargetOfGroupMembers[guid]
		if unit then
			local unittarget = UnitGUID(unit .. "target")
			if guid == unittarget then
				UpdateAurasByUnitID(unittarget)
			end
		end
	end
	return false
end

local function CombatLog_ApplyAura(...)
	local timestamp, sourceGUID, destGUID, destName, spellid = ...
	local duration = GetSpellDuration(spellid)
	local _, _, texture = GetSpellInfo(spellid)
	SetAuraInstance(destGUID, spellid, GetTime() + (duration or 0), 1, sourceGUID, duration, texture, AURA_TYPE_DEBUFF, AURA_TARGET_HOSTILE)
end

local function CombatLog_RemoveAura(...)
	local timestamp, sourceGUID, destGUID, destName, spellid = ...
	RemoveAuraInstance(destGUID, spellid, sourceGUID)
end

local function CombatLog_UpdateAuraStacks(...)
	local timestamp, sourceGUID, destGUID, destName, spellid, stackCount = ...
	local duration = GetSpellDuration(spellid)
	local _, _, texture = GetSpellInfo(spellid)
	SetAuraInstance(destGUID, spellid, GetTime() + (duration or 0), stackCount, sourceGUID, duration, texture, AURA_TYPE_DEBUFF, AURA_TARGET_HOSTILE)
end

local function EventUnitTarget()
	wipe(TargetOfGroupMembers)

	for name, unitid in pairs(NidhausPlatesUtility.GroupMembers.UnitId) do
		local targetOf = unitid .. ("target" or "")
		if UnitExists(targetOf) then
			TargetOfGroupMembers[UnitGUID(targetOf)] = targetOf
		end
	end
end

local function EventPlayerTarget()
	if UnitExists("target") then
		UpdateAurasByUnitID("target")
	end
end

local function EventUnitAura(unitid)
	if unitid == "target" then
		UpdateAurasByUnitID("target")
	elseif unitid == "focus" then
		UpdateAurasByUnitID("focus")
	end
end

local CombatLogEvents = {

	["SPELL_AURA_APPLIED"] = CombatLog_ApplyAura,
	["SPELL_AURA_REFRESH"] = CombatLog_ApplyAura,

	["SPELL_AURA_APPLIED_DOSE"] = CombatLog_UpdateAuraStacks,

	["SPELL_AURA_REMOVED_DOSE"] = CombatLog_UpdateAuraStacks,

	["SPELL_AURA_BROKEN"] = CombatLog_RemoveAura,
	["SPELL_AURA_BROKEN_SPELL"] = CombatLog_RemoveAura,
	["SPELL_AURA_REMOVED"] = CombatLog_RemoveAura
}

local GeneralEvents = {
	["UNIT_TARGET"] = EventUnitTarget,
	["UNIT_AURA"] = EventUnitAura,
	["PLAYER_ENTERING_WORLD"] = CleanAuraLists,
	["PLAYER_REGEN_ENABLED"] = CleanAuraLists,
	["PLAYER_TALENT_UPDATE"] = UpdatePlayerDispelTypes,
	["ACTIVE_TALENT_GROUP_CHANGED"] = UpdatePlayerDispelTypes
}

local function GetCombatEventResults(...)
	local timestamp, combatevent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellid, spellName, spellSchool, auraType, stackCount = ...
	return timestamp, combatevent, sourceGUID, destGUID, destName, destFlags, destFlags, auraType, spellid, stackCount
end

local function CombatEventHandler(frame, event, ...)

	if event ~= "COMBAT_LOG_EVENT_UNFILTERED" then
		if GeneralEvents[event] then
			GeneralEvents[event](...)
		end
		return
	end

	local timestamp, combatevent, sourceGUID, destGUID, destName, destFlags, destRaidFlag, auraType, spellid, stackCount = GetCombatEventResults(...)

	if (bit.band(destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) == 0) then
		local CombatLogUpdateFunction = CombatLogEvents[combatevent]

		if CombatLogUpdateFunction then

			if auraType == "DEBUFF" then

				if not UpdateAuraByLookup(destGUID) then

					CombatLogUpdateFunction(timestamp, sourceGUID, destGUID, destName, spellid, stackCount)
				end

				local name, raidicon

				if bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
					local rawName = strsplit("-", destName)
					ByName[rawName] = destGUID
					name = rawName
				end

				for iconname, bitmask in pairs(RaidIconBit) do
					if bit.band(destRaidFlag, bitmask) > 0 then
						ByRaidIcon[iconname] = destGUID
						raidicon = iconname
						break
					end
				end

				CallForWidgetUpdate(destGUID, raidicon, name)
			end
		end
	end
end

local function UpdateWidgetTime(frame, expiration)
	local timeleft = ceil(expiration - GetTime())
	if timeleft > 60 then
		frame.TimeLeft:SetText(ceil(timeleft / 60) .. "m")
	else
		frame.TimeLeft:SetText(ceil(timeleft))
	end
end

local function UpdateIcon(frame, texture, expiration, stacks)
	if frame and texture and expiration then

		frame.Icon:SetTexture(texture)

		if stacks > 1 then
			frame.Stacks:SetText(stacks)
		else
			frame.Stacks:SetText("")
		end

		UpdateWidgetTime(frame, expiration)
		frame:Show()
		PolledHideIn(frame, expiration)
	else
		PolledHideIn(frame, 0)
	end
end

local AuraSlotspellid = {}
local AuraSlotPriority = {}

local function debuffSort(a, b)
	return a.priority < b.priority
end

local DebuffCache = {}

local function UpdateIconGrid(frame, guid)
	local AuraIconFrames = frame.AuraIconFrames
	local AurasOnUnit = GetAuraList(guid)
	local AuraSlotIndex = 1

	wipe(DebuffCache)
	local debuffCount = 0

	if AurasOnUnit then
		frame:Show()
		for instanceid in pairs(AurasOnUnit) do
			local aura = {}
			aura.spellid, aura.expiration, aura.stacks, aura.caster, aura.duration, aura.texture, aura.type, aura.target =
				GetAuraInstance(guid, instanceid)

			if tonumber(aura.spellid) then
				aura.name = GetSpellInfo(tonumber(aura.spellid))
				aura.unit = frame.unit

				local show, priority = frame.Filter(aura)
				aura.priority = priority or 10

				if show and aura.expiration > GetTime() then
					debuffCount = debuffCount + 1
					DebuffCache[debuffCount] = aura
				end
			end
		end
	end

	if debuffCount > 0 then
		sort(DebuffCache, debuffSort)
		for index = 1, #DebuffCache do
			local cachedaura = DebuffCache[index]
			if cachedaura.spellid and cachedaura.expiration then
				UpdateIcon(AuraIconFrames[AuraSlotIndex], cachedaura.texture, cachedaura.expiration, cachedaura.stacks)
				AuraSlotIndex = AuraSlotIndex + 1
			end
			if AuraSlotIndex > MaximumDisplayableDebuffs then
				break
			end
		end
	end

	for index = AuraSlotIndex, MaximumDisplayableDebuffs do
		UpdateIcon(AuraIconFrames[index])
	end

	wipe(DebuffCache)
end

function UpdateWidget(frame)

	local unit = frame.unit
	local guid = unit.guid

	if not guid then

		if unit.type == "PLAYER" then
			guid = ByName[unit.name]
		elseif unit.isMarked then
			guid = ByRaidIcon[unit.raidIcon]
		end

		if guid then
			unit.guid = guid
		else
			frame:Hide()
			return
		end
	end

	UpdateIconGrid(frame, guid)
	NidhausPlates:RequestDelegateUpdate()
end

local function UpdateWidgetTarget(frame)
	UpdateIconGrid(frame, UnitGUID("target"))
end

local function UpdateWidgetContext(frame, unit)
	local guid = unit.guid
	frame.unit = unit
	frame.guidcache = guid

	WidgetList[frame] = true
	if guid then
		WidgetGUID[guid] = frame
	end

	if unit.isTarget then
		UpdateAurasByUnitID("target")
	elseif unit.isMouseover then
		UpdateAurasByUnitID("mouseover")
	end

	local raidicon, name
	if unit.isMarked then
		raidicon = unit.raidIcon
		if guid and raidicon then
			ByRaidIcon[raidicon] = guid
		end
	end
	if unit.type == "PLAYER" and unit.reaction == "HOSTILE" then
		name = unit.name
	end

	CallForWidgetUpdate(guid, raidicon, name)
end

local function ClearWidgetContext(frame)
	if frame.guidcache then
		WidgetGUID[frame.guidcache] = nil
		frame.unit = nil
	end
	WidgetList[frame] = nil
end

local AuraBorderArt = "Interface\\AddOns\\NidhausPlatesWidgets\\Aura\\AuraFrame"
local AuraGlowArt = "Interface\\AddOns\\NidhausPlatesWidgets\\Aura\\AuraGlow"
local AuraHighlightArt = "Interface\\AddOns\\NidhausPlatesWidgets\\Aura\\CCBorder"
local AuraTestArt = ""
local AuraFont = "Interface\\Addons\\Nidhaus_Plates\\Media\\DefaultFont.ttf"

local function Enable()
	AuraMonitor:SetScript("OnEvent", CombatEventHandler)
	AuraMonitor:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	for event in pairs(GeneralEvents) do
		AuraMonitor:RegisterEvent(event)
	end

	NidhausPlatesUtility:EnableGroupWatcher()

	if not NidhausPlatesData.CachedAuraDurations then
		NidhausPlatesData.CachedAuraDurations = {}
	end
end

local function Disable()
	AuraMonitor:SetScript("OnEvent", nil)
	AuraMonitor:UnregisterAllEvents()

end

local function CreateAuraIconFrame(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetWidth(26)
	frame:SetHeight(14)

	frame.Icon = frame:CreateTexture(nil, "BACKGROUND")
	frame.Icon:SetAllPoints(frame)
	frame.Icon:SetTexCoord(.07, 1 - .07, .23, 1 - .23)

	frame.Border = frame:CreateTexture(nil, "ARTWORK")
	frame.Border:SetWidth(32)
	frame.Border:SetHeight(32)
	frame.Border:SetPoint("CENTER", 1, -2)
	frame.Border:SetTexture(AuraBorderArt)

	frame.Glow = frame:CreateTexture(nil, "ARTWORK")
	frame.Glow:SetAllPoints(frame.Border)
	frame.Glow:SetTexture(AuraGlowArt)

	frame.TimeLeft = frame:CreateFontString(nil, "OVERLAY")
	frame.TimeLeft:SetFont(AuraFont, 9, "OUTLINE")
	frame.TimeLeft:SetShadowOffset(1, -1)
	frame.TimeLeft:SetShadowColor(0, 0, 0, 1)
	frame.TimeLeft:SetPoint("RIGHT", 0, 8)
	frame.TimeLeft:SetWidth(26)
	frame.TimeLeft:SetHeight(16)
	frame.TimeLeft:SetJustifyH("RIGHT")

	frame.Stacks = frame:CreateFontString(nil, "OVERLAY")
	frame.Stacks:SetFont(AuraFont, 10, "OUTLINE")
	frame.Stacks:SetShadowOffset(1, -1)
	frame.Stacks:SetShadowColor(0, 0, 0, 1)
	frame.Stacks:SetPoint("RIGHT", 0, -6)
	frame.Stacks:SetWidth(26)
	frame.Stacks:SetHeight(16)
	frame.Stacks:SetJustifyH("RIGHT")

	frame.AuraInfo = {Name = "", Icon = "", Stacks = 0, Expiration = 0, Type = ""}

	frame.Poll = parent.PollFunction
	frame:Hide()
	return frame
end

local function CreateAuraWidget(parent)

	local frame = CreateFrame("Frame", nil, parent)
	frame:SetWidth(128)
	frame:SetHeight(32)
	frame:Show()

	frame.PollFunction = UpdateWidgetTime
	frame.AuraIconFrames = {}
	local AuraIconFrames = frame.AuraIconFrames

	for index = 1, MaximumDisplayableDebuffs do
		AuraIconFrames[index] = CreateAuraIconFrame(frame)
	end
	local FirstRowCount = min(MaximumDisplayableDebuffs / 2)

	AuraIconFrames[1]:SetPoint("LEFT", frame)
	for index = 2, FirstRowCount do
		AuraIconFrames[index]:SetPoint("LEFT", AuraIconFrames[index - 1], "RIGHT", 5, 0)
	end
	AuraIconFrames[FirstRowCount + 1]:SetPoint("BOTTOMLEFT", AuraIconFrames[1], "TOPLEFT", 0, 8)
	for index = (FirstRowCount + 2), MaximumDisplayableDebuffs do
		AuraIconFrames[index]:SetPoint("LEFT", AuraIconFrames[index - 1], "RIGHT", 5, 0)
	end

	frame._Hide = frame.Hide
	frame.Hide = function()
		ClearWidgetContext(frame)
		frame:_Hide()
	end
	frame:SetScript("OnHide", function()
		for index = 1, 4 do
			PolledHideIn(AuraIconFrames[index], 0)
		end
	end)
	frame.Filter = DefaultFilterFunction
	frame.UpdateContext = UpdateWidgetContext
	frame.Update = UpdateWidgetContext
	frame.UpdateTarget = UpdateWidgetTarget
	return frame
end

NidhausPlatesWidgets.GetAuraWidgetByGUID = GetAuraWidgetByGUID
NidhausPlatesWidgets.IsAuraShown = IsAuraShown
NidhausPlatesWidgets.CanPlayerDispel = CanPlayerDispel

NidhausPlatesWidgets.CreateAuraWidget = CreateAuraWidget
NidhausPlatesWidgets.EnableAuraWatcher = Enable
NidhausPlatesWidgets.DisableAuraWatcher = Disable

do
	local CCSpells = {

		[GetSpellInfo(118)] = true,
		[GetSpellInfo(3355)] = true,
		[GetSpellInfo(6770)] = true,
		[GetSpellInfo(6358)] = true,
		[GetSpellInfo(60210)] = true,
		[GetSpellInfo(45524)] = true,
		[GetSpellInfo(33786)] = true,
		[GetSpellInfo(53308)] = true,
		[GetSpellInfo(2637)] = true,
		[GetSpellInfo(20066)] = true,
		[GetSpellInfo(9484)] = true,
		[GetSpellInfo(51722)] = true,
		[GetSpellInfo(710)] = true,
		[GetSpellInfo(12809)] = true,
		[GetSpellInfo(676)] = true,

		[GetSpellInfo(47476)] = true,
		[GetSpellInfo(49203)] = true,
		[GetSpellInfo(47481)] = true,
		[GetSpellInfo(49560)] = true,

		[GetSpellInfo(339)] = true,
		[GetSpellInfo(8983)] = true,
		[GetSpellInfo(16979)] = true,
		[GetSpellInfo(45334)] = true,
		[GetSpellInfo(22570)] = true,
		[GetSpellInfo(49803)] = true,

		[GetSpellInfo(5116)] = true,
		[GetSpellInfo(19503)] = true,
		[GetSpellInfo(19386)] = true,
		[GetSpellInfo(53548)] = true,
		[GetSpellInfo(4167)] = true,
		[GetSpellInfo(55509)] = true,
		[GetSpellInfo(24394)] = true,
		[GetSpellInfo(19577)] = true,
		[GetSpellInfo(53568)] = true,
		[GetSpellInfo(53543)] = true,
		[GetSpellInfo(50541)] = true,
		[GetSpellInfo(55492)] = true,
		[GetSpellInfo(26090)] = true,
		[GetSpellInfo(53575)] = true,
		[GetSpellInfo(53589)] = true,
		[GetSpellInfo(53562)] = true,
		[GetSpellInfo(1513)] = true,
		[GetSpellInfo(64803)] = true,

		[GetSpellInfo(31661)] = true,
		[GetSpellInfo(44572)] = true,
		[GetSpellInfo(122)] = true,
		[GetSpellInfo(33395)] = true,
		[GetSpellInfo(55021)] = true,

		[GetSpellInfo(853)] = true,
		[GetSpellInfo(10326)] = true,
		[GetSpellInfo(2812)] = true,
		[GetSpellInfo(31935)] = true,

		[GetSpellInfo(8122)] = true,
		[GetSpellInfo(605)] = true,
		[GetSpellInfo(15487)] = true,
		[GetSpellInfo(64044)] = true,

		[GetSpellInfo(408)] = true,
		[GetSpellInfo(2094)] = true,
		[GetSpellInfo(1833)] = true,
		[GetSpellInfo(1776)] = true,
		[GetSpellInfo(1330)] = true,

		[GetSpellInfo(51514)] = true,
		[GetSpellInfo(8056)] = true,
		[GetSpellInfo(64695)] = true,
		[GetSpellInfo(3600)] = true,
		[GetSpellInfo(39796)] = true,
		[GetSpellInfo(8034)] = true,

		[GetSpellInfo(6215)] = true,
		[GetSpellInfo(5484)] = true,
		[GetSpellInfo(30283)] = true,
		[GetSpellInfo(22703)] = true,
		[GetSpellInfo(6789)] = true,
		[GetSpellInfo(24259)] = true,

		[GetSpellInfo(5246)] = true,
		[GetSpellInfo(46968)] = true,
		[GetSpellInfo(6552)] = true,
		[GetSpellInfo(58357)] = true,
		[GetSpellInfo(7922)] = true,
		[GetSpellInfo(47995)] = true,
		[GetSpellInfo(12323)] = true,

		[GetSpellInfo(20549)] = true,
		[GetSpellInfo(28730)] = true,
		[GetSpellInfo(47779)] = true,
		[GetSpellInfo(50613)] = true,

		[GetSpellInfo(67890)] = true
	}
	NidhausPlatesWidgets.CCSpells = CCSpells
end

function DynamicHashTableSize(entries)
	if (entries == 0) then
		return 36
	else
		return math.pow(2, math.ceil(math.log(entries) / math.log(2))) * 40 + 36
	end
end

local TableMemory

TableMemory = function(pTable, level)
	level = level or 1
	local sum = 0
	local entries = 0
	local indent = " "
	for s = 1, level do
		indent = indent .. " "
	end

	for i, v in pairs(pTable) do
		if type(v) == "table" then
			local mem = TableMemory(v, level + 1)
			sum = sum + mem
			entries = entries + 1
		else
			entries = entries + 1
		end
	end
	return DynamicHashTableSize(entries) + sum, entries
end
