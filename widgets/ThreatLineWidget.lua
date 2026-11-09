local GetRelativeThreat = NidhausPlatesUtility.GetRelativeThreat

local FadeLater
do

	local Framelist = {}
	local Watcherframe = CreateFrame("Frame")
	local WatcherframeActive = false
	local select = select
	local nextScheduledUpdate = 0
	local updateInterval = .07

	local function CheckFramelist(self)
		local curTime = GetTime()
		if curTime < nextScheduledUpdate then
			return
		end

		local framecount, alpha, timeRemains = 0, 0, 0
		nextScheduledUpdate = curTime + updateInterval

		for frame, expiration in pairs(Framelist) do
			timeRemains = expiration - curTime
			if frame:IsShown() then
				if timeRemains > 0 then
					framecount = framecount + 1
					if timeRemains < .5 then
						frame:SetAlpha(timeRemains * 2)
					end
				else
					frame:SetAlpha(0)
					Framelist[frame] = nil
				end
			else
				Framelist[frame] = nil
			end
		end

		if framecount == 0 then
			Watcherframe:SetScript("OnUpdate", nil)
			WatcherframeActive = false
		end
	end

	function FadeLater(frame, expiration)
		frame:SetAlpha(1)

		Framelist[frame] = expiration

		if WatcherframeActive then
			return
		else
			Watcherframe:SetScript("OnUpdate", CheckFramelist)
			WatcherframeActive = true
		end
	end
end

local font = "FONTS\\ARIALN.ttf"
local art = "Interface\\Addons\\Nidhaus_Plates\\widgets\\ThreatLine\\ThreatLineUnified"
local artCoordinates = {
	Line = {0, .2, 0, 1},
	Right = {.5, .75, 0, 1},
	Left = {.25, .5, 0, 1}
}
local threatcolor

local WidgetList = {}

local testMode = false

local function UpdateThreatLine(frame, unitid)
	local maxwitdth = frame:GetWidth() / 2
	local leaderThreat, leaderThreatDelta, leaderThreatPct
	local leaderThreatMax, leaderThreatMin = frame.ThreatMax, frame.ThreatMin
	if testMode then
		leaderThreatPct, leaderUnitId = 180, "player"
	else
		leaderThreatPct, leaderUnitId, leaderThreatDelta = GetRelativeThreat(unitid)
	end

	if not leaderThreatPct then
		frame:_Hide()
		return
	end
	if leaderThreatPct and leaderThreatPct > 0 then
		if frame.UseRawValues then
			if leaderThreatDelta > 0 then
				leaderThreat = min(leaderThreatDelta, leaderThreatMax) / leaderThreatMax
			else
				leaderThreat = (-(max(leaderThreatDelta, leaderThreatMin))) / leaderThreatMin
			end
		else
			leaderThreat = leaderThreatPct
		end

		frame.Line:ClearAllPoints()

		if leaderThreat > 100 then

			frame.Line:SetWidth(maxwitdth * ((leaderThreat - 100) / 100))
			threatcolor = frame._HighColor
			frame.Line:SetPoint("LEFT", frame, "CENTER")
		else

			frame.Line:SetWidth(maxwitdth * ((100 - leaderThreat) / 100))
			threatcolor = frame._LowColor
			frame.Line:SetPoint("RIGHT", frame, "CENTER")
		end

		if leaderUnitId and leaderUnitId ~= "player" then
			if UnitIsUnit(leaderUnitId, "pet") or GetPartyAssignment("MAINTANK", leaderUnitId) or GetPartyAssignment("MAINASSIST", leaderUnitId) or ("TANK" == UnitGroupRolesAssigned(leaderUnitId)) then
				threatcolor = frame._TankedColor
			end

			frame.TargetText:SetText(UnitName(leaderUnitId))
			frame.TargetText:SetTextColor(threatcolor.r, threatcolor.g, threatcolor.b)
		else
			frame.TargetText:SetText("")
		end

		frame.Left:SetVertexColor(threatcolor.r, threatcolor.g, threatcolor.b)
		frame.Line:SetVertexColor(threatcolor.r, threatcolor.g, threatcolor.b)
		frame.Right:SetVertexColor(threatcolor.r, threatcolor.g, threatcolor.b)

		frame:Show()
		frame.FadeTime = GetTime() + 2
		frame:FadeLater(frame.FadeTime)
	else
		frame:_Hide()
	end
end

local function UpdateWidgetTarget(frame)
	if UnitExists("target") then
		UpdateThreatLine(frame, "target")
	else
		frame:Hide()
	end
end

local function UpdateWidgetContext(frame, unit)

	if testMode then
		UpdateThreatLine(frame)
		return
	end
	if unit.reaction == "FRIENDLY" or (not InCombatLockdown()) or (not (UnitInParty("player") or HasPetUI())) then
		frame:_Hide()
		return
	end

	local guid = unit.guid
	if guid then
		WidgetList[guid] = frame
	end
	frame.guid = guid
	frame.unit = unit

	if unit.isTarget then
		UpdateThreatLine(frame, "target")
	elseif unit.isMouseover then
		UpdateThreatLine(frame, "mouseover")
	end
end

local function ClearWidgetContext(frame)
	frame.unit = nil
	local guid = frame.guid
	if guid then
		WidgetList[guid] = nil
		frame.guid = nil
	end
end

local WatcherFrame = CreateFrame("Frame", nil, WorldFrame)
local isEnabled = false
WatcherFrame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
WatcherFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")

local TargetList = {}
local updateCap = 1
local lastUpdate = 0

local function WatcherFrameHandler(frame, event)
	if event == "UNIT_THREAT_LIST_UPDATE" and (lastUpdate + updateCap) > GetTime() then
		return
	end

	local widget

	for guid in pairs(TargetList) do
		TargetList[guid] = nil
	end

	guid = UnitGUID("target")
	if guid then
		TargetList[guid] = "target"
	end

	guid = UnitGUID("focus")
	if guid then
		TargetList[guid] = "focus"
	end

	local raidsize = GetNumRaidMembers() - 1
	for index = 1, raidsize do
		local unitid = "raid" .. index .. "target"
		guid = UnitGUID(unitid)
		if guid then
			TargetList[guid] = unitid
		end
	end

	for guid, unitid in pairs(TargetList) do
		widget = WidgetList[guid]
		if widget then
			UpdateThreatLine(widget, unitid)
		end
	end

	lastUpdate = GetTime()
end

local function EnableWatcherFrame(arg)
	if arg then
		WatcherFrame:SetScript("OnEvent", WatcherFrameHandler)
		isEnabled = true
	else
		WatcherFrame:SetScript("OnEvent", nil)
		isEnabled = false
	end
end

local function CreateWidgetFrame(parent)

	local frame = CreateFrame("Frame", nil, parent)
	frame:Hide()

	frame:SetWidth(100)
	frame:SetHeight(24)

	frame.Line = frame:CreateTexture(nil, "OVERLAY")
	frame.Line:SetTexture(art)
	frame.Line:SetTexCoord(unpack(artCoordinates["Line"]))
	frame.Line:SetHeight(32)

	frame.Left = frame:CreateTexture(nil, "OVERLAY")
	frame.Left:SetTexture(art)
	frame.Left:SetTexCoord(unpack(artCoordinates["Left"]))
	frame.Left:SetPoint("RIGHT", frame.Line, "LEFT")
	frame.Left:SetWidth(32)
	frame.Left:SetHeight(32)

	frame.Right = frame:CreateTexture(nil, "OVERLAY")
	frame.Right:SetTexture(art)
	frame.Right:SetTexCoord(unpack(artCoordinates["Right"]))
	frame.Right:SetPoint("LEFT", frame.Line, "RIGHT")
	frame.Right:SetWidth(32)
	frame.Right:SetHeight(32)

	frame.TargetText = frame:CreateFontString(nil, "OVERLAY")
	frame.TargetText:SetFont(font, 8, "OUTLINE")

	frame.TargetText:SetWidth(50)
	frame.TargetText:SetHeight(20)
	frame.TargetText:SetJustifyH("RIGHT")
	frame.TargetText:SetPoint("RIGHT", frame.Line, "LEFT", -5, 2)

	frame.FadeLater = FadeLater
	frame.FadeTime = 0
	frame:Hide()
	frame.ThreatMax, frame.ThreatMin, frame.UseRawValues = 1, 0, false

	frame._LowColor = {r = .14, g = .75, b = 1}
	frame._TankedColor = {r = 0, g = .9, b = .1}
	frame._HighColor = {r = 1, g = .67, b = .14}
	frame._ShowTargetOf = true

	frame.UpdateContext = UpdateWidgetContext
	frame.Update = UpdateWidgetTarget
	frame._Hide = frame.Hide
	frame.Hide = function()
		ClearWidgetContext(frame)
		frame:_Hide()
	end
	if not isEnabled then
		EnableWatcherFrame(true)
	end
	return frame
end

NidhausPlatesWidgets.CreateThreatLineWidget = CreateWidgetFrame
