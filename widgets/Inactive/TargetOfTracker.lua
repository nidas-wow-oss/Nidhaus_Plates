local TrackedUnits = {}
local TrackedUnitTargets = {}
local TrackedUnitTargetHistory = {}

local function UpdateTracker()
	local widget, plate, guid
	local changes = false
	wipe(TrackedUnits)

	for id, tar in pairs(TrackedUnitTargets) do
		TrackedUnitTargetHistory[id] = tar
		TrackedUnitTargets[id] = nil
	end

	for id in pairs(TrackedUnits) do
		TrackedUnits[id] = nil
	end

	guid = UnitGUID("target")
	if guid then
		TrackedUnits[guid] = "target"
	end

	guid = UnitGUID("focus")
	if guid then
		TrackedUnits[guid] = "focus"
	end

	local raidsize = GetNumRaidMembers() - 1
	for index = 1, raidsize do
		unitid = "raid" .. index .. "target"
		guid = UnitGUID(unitid)
		if guid then
			TrackedUnits[guid] = unitid
		end
	end

	for id, unit in pairs(TrackedUnits) do
		if unit then
			TrackedUnitTargets[id] = UnitName(unit .. "target")
			if TrackedUnitTargets[id] ~= TrackedUnitTargetHistory[id] then
				changes = true
			end
		end
	end

	if changes then
		NidhausPlates:Update()
	end
end

local EventWatcher = CreateFrame("Frame")
EventWatcher:SetScript("OnEvent", UpdateTracker)
EventWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
EventWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")

EventWatcher:RegisterEvent("PLAYER_TARGET_CHANGED")
EventWatcher:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
EventWatcher:RegisterEvent("UNIT_TARGET")
