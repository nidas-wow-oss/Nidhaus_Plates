NidhausPlatesData = NidhausPlatesData or {}
NidhausPlatesData.UnitDescriptions = {}
NidhausPlatesData.UnitClass = {}
NidhausPlatesData.Friends = {}
NidhausPlatesData.Guild = {}

local UnitCacheMonitor
local UnitCacheMonitorEvents = {}

local function UpdateGuildCache()
	if not NidhausPlatesData.Guild then
		NidhausPlatesData.Guild = {}
	end
	local guildname = GetGuildInfo("player")
	if not guildname then
		return
	end
	local numGuildMembers, numOnline = GetNumGuildMembers()
	for index = 1, numGuildMembers do
		local name, rank, rankIndex, level, class = GetGuildRosterInfo(index)
		NidhausPlatesData.Guild[name] = true
		NidhausPlatesData.UnitClass[name] = class
		NidhausPlatesData.UnitDescriptions[name] = guildname
	end
end

local function UpdateFriendCache()
	if not NidhausPlatesData.Friends then
		NidhausPlatesData.Friends = {}
	end

	local numFriends = GetNumFriends()
	for index = 1, numFriends do
		local name, level, class = GetFriendInfo(index)
		if name then
			NidhausPlatesData.Friends[name] = true
		end
	end
end

function UnitCacheMonitorEvents.UPDATE_MOUSEOVER_UNIT(self, ...)
	local name, class, level, description, _, unitadded

	if UnitIsPlayer("mouseover") then

		name = UnitName("mouseover")
		description = GetGuildInfo("mouseover")
		class = select(2, UnitClass("mouseover"))

		if NidhausPlatesData.UnitClass[name] ~= class then
			unitadded = true
			NidhausPlatesData.UnitClass[name] = class
		end
	elseif GameTooltipTextLeft1:GetText() == UnitName("mouseover") then
		name = GameTooltipTextLeft1:GetText()
		description = GameTooltipTextLeft2:GetText()
		if description then
			level = select(2, strsplit(" ", description))
			if tonumber(level) or level == "??" then
				description = nil
			end
		end
	end

	if NidhausPlatesData.UnitDescriptions[name] ~= description then
		unitadded = true
		NidhausPlatesData.UnitDescriptions[name] = description
	end

	if unitadded then
		NidhausPlates:RequestDelegateUpdate()
	end
end

function UnitCacheMonitorEvents.GUILD_ROSTER_UPDATE(self, ...)
	UpdateGuildCache()
end

function UnitCacheMonitorEvents.FRIENDLIST_UPDATE(self, ...)
	UpdateFriendCache()
end

local function OnEvent(frame, event, ...)
	UnitCacheMonitorEvents[event](...)
end

local function Enable()
	if not UnitCacheMonitor then
		UnitCacheMonitor = CreateFrame("Frame")
	end
	for event in pairs(UnitCacheMonitorEvents) do
		UnitCacheMonitor:RegisterEvent(event)
	end
	UnitCacheMonitor:SetScript("OnEvent", OnEvent)

	if not NidhausPlatesData.UnitDescriptions then
		NidhausPlatesData.UnitDescriptions = {}
	end
	if not NidhausPlatesData.UnitClass then
		NidhausPlatesData.UnitClass = {}
	end
	if not NidhausPlatesData.Guild then
		NidhausPlatesData.Guild = {}
	end
	if not NidhausPlatesData.Friends then
		NidhausPlatesData.Friends = {}
	end

	if IsInGuild() then
		GuildRoster()
	end
	UpdateFriendCache()
end

local function Disable()
	if UnitCacheMonitor then
		UnitCacheMonitor:SetScript("OnEvent", nil)
		UnitCacheMonitor:UnregisterAllEvents()
		UnitCacheMonitor = nil
	end
end

NidhausPlatesUtility.EnableUnitCache = Enable
NidhausPlatesUtility.DisableUnitCache = Disable
