local ADDON_NAME = ...

local L = NidhausPlates.L

local CallIn = NidhausPlatesUtility.CallIn
local copytable = NidhausPlatesUtility.copyTable
local mergetable = NidhausPlatesUtility.mergeTable
local PanelHelpers = NidhausPlatesUtility.PanelHelpers
local InCombat = NidhausPlates.InCombat

local currentThemeName = ""
local activespec = "primary"
local useAutohide = false

local FORCED_THEME = "Nidhaus Plates"
local defaultPrimaryTheme = FORCED_THEME
local defaultSecondaryTheme = FORCED_THEME

local function SetAutoHide(option)
	useAutoHide = option
	if useAutoHide and (not InCombat) then
		SetCVar("nameplateShowEnemies", 0)
	end
end

local function SetSpellCastWatcher(enable)
	if enable then
		NidhausPlates:StartSpellCastWatcher()
	else
		NidhausPlates:StopSpellCastWatcher()
	end
end

local function ShowMinimapButton(enable)
	if enable then
		NidhausPlatesUtility:CreateMinimapButton()
		NidhausPlatesUtility:ShowMinimapButton()
	else
		NidhausPlatesUtility:HideMinimapButton()
	end
end

function NidhausPlates:GetCastWatcher()
	return NidhausPlatesOptions.EnableCastWatcher and true or false
end

function NidhausPlates:SetCastWatcher(enable)
	enable = enable and true or false
	NidhausPlatesOptions.EnableCastWatcher = enable
	SetSpellCastWatcher(enable)
	NidhausPlates:ForceUpdate()
end

function NidhausPlates:GetMinimapButton()
	return NidhausPlatesOptions.EnableMinimapButton and true or false
end

function NidhausPlates:SetMinimapButton(enable)
	enable = enable and true or false
	NidhausPlatesOptions.EnableMinimapButton = enable
	ShowMinimapButton(enable)
end

function NidhausPlates:OpenBlizzardNameplateOptions()
	InterfaceOptionsFrame_OpenToCategory(_G["InterfaceOptionsNamesPanel"])
end

NidhausPlatesOptions = {
	primary = defaultPrimaryTheme,
	secondary = defaultSecondaryTheme,
	FriendlyAutomation = L["No Automation"],
	EnemyAutomation = L["No Automation"],
	EnableCastWatcher = true,
	WelcomeShown = false,
	EnableMinimapButton = true,
	SimplePanelVersion = 0
}

local NidhausPlatesOptionsDefaults = copytable(NidhausPlatesOptions)
local NidhausPlatesThemeNames = {}
local warned = {}

local function LoadTheme(incomingtheme)
	local theme

	for themename, themetable in pairs(NidhausPlatesThemeList) do
		if themetable.OnActivateTheme then
			themetable.OnActivateTheme(nil, nil)
		end
	end

	if type(NidhausPlatesThemeList) == "table" then
		if type(incomingtheme) == "string" then
			theme = NidhausPlatesThemeList[incomingtheme]
		end
	end

	if type(theme) == "table" then
		if theme.SetStyle and type(theme.SetStyle) == "function" then

			for stylename, style in pairs(theme) do
				if type(style) == "table" then
					theme[stylename] = mergetable(NidhausPlates.Template, style)
				end
			end
		else

			for propertyname, oldvalue in pairs(NidhausPlates.Template) do
				local newvalue = theme[propertyname]
				if type(newvalue) == "table" then
					theme[propertyname] = mergetable(oldvalue, newvalue)
				else
					theme[propertyname] = copytable(oldvalue)
				end
			end
		end

		NidhausPlates:ActivateTheme(theme)
		if theme.OnActivateTheme then
			theme.OnActivateTheme(theme, incomingtheme)
		end
		currentThemeName = incomingtheme
		return theme
	else
		NidhausPlatesOptions[activespec] = "None"
		currentThemeName = "None"
		NidhausPlates:ActivateTheme(NidhausPlatesThemeList["None"])
		return nil
	end
end

NidhausPlates.LoadTheme = LoadTheme
NidhausPlates._LoadTheme = LoadTheme

function NidhausPlates:ReloadTheme()

	if NidhausPlates_RefreshLightBorder then NidhausPlates_RefreshLightBorder() end
	LoadTheme(NidhausPlatesOptions[activespec])
	NidhausPlates:ForceUpdate()
end

local ThemeDropdownMenuItems = {}
local ApplyPanelSettings

local version = GetAddOnMetadata(ADDON_NAME, "version") or ""
local versionString = string.gsub(string.gsub(string.gsub(version, "%$", ""), "%(", ""), "%)", "")
local addonString = GetAddOnMetadata(ADDON_NAME, "title") or ADDON_NAME
local titleString = addonString .. " " .. versionString
local firstShow = true

local panel = PanelHelpers:CreatePanelFrame("NidhausPlatesInterfaceOptions", "Nidhaus Plates", titleString)
local helppanel = PanelHelpers:CreatePanelFrame("NidhausPlatesInterfaceOptionsHelp", "Troubleshooting")
panel:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	insets = {left = 2, right = 2, top = 2, bottom = 2}
})

panel:SetBackdropColor(0.06, 0.06, 0.06, 0.85)

if panel.Label then
	local plain = string.gsub(titleString, "|c%x%x%x%x%x%x%x%x", "")
	plain = string.gsub(plain, "|r", "")
	panel.Label:SetText(plain)
	panel.Label:SetTextColor(0.55, 0.55, 0.55, 1)
end

local function UpdateThemeNames()
	local themecount = 1
	if type(NidhausPlatesThemeList) == "table" then
		for themename, themepointer in pairs(NidhausPlatesThemeList) do
			NidhausPlatesThemeNames[themecount] = themename

			themecount = themecount + 1
		end

		for index, name in pairs(NidhausPlatesThemeNames) do
			ThemeDropdownMenuItems[index] = {text = name, notCheckable = 1}
		end
	end
	table.sort(ThemeDropdownMenuItems, function(a, b) return (a.text < b.text) end)
end

local function ConfigureTheme(spec)
	local themename = FORCED_THEME
	if themename then
		local theme = NidhausPlatesThemeList[themename]
		if theme and theme.ShowConfigPanel and type(theme.ShowConfigPanel) == "function" then
			theme.ShowConfigPanel()
		end
	end
end

local function ThemeHasPanelLink(themename)
	if themename then
		local theme = NidhausPlatesThemeList[themename]
		if theme and theme.ShowConfigPanel and type(theme.ShowConfigPanel) == "function" then
			return true
		end
	end
end

local function ActivateInterfacePanel()
	panel.refresh = function() end
	panel.okay = ApplyPanelSettings

end

function NidhausPlates:ResetConfiguration()
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("nameplateShowEnemies", 1)
	SetCVar("threatWarning", 3)
	if _G["InterfaceOptionsNamesPanelUnitNameplatesFriends"] then
		_G["InterfaceOptionsNamesPanelUnitNameplatesFriends"]:SetChecked(false)
	end
	NidhausPlatesOptions = wipe(NidhausPlatesOptions)
	for i, v in pairs(NidhausPlatesOptionsDefaults) do
		NidhausPlatesOptions[i] = v
	end
	SetCVar("nameplateShowFriends", 0)
	ReloadUI()
end

local function ApplyAutomationSettings()
	SetSpellCastWatcher(NidhausPlatesOptions.EnableCastWatcher)

	if NidhausPlatesOptions.EnableCastWatcher then
		NidhausPlates:StartSpellCastWatcher()
	else
		NidhausPlates:StopSpellCastWatcher()
	end

	if NidhausPlatesOptions.EnableMinimapButton then
		NidhausPlatesUtility:CreateMinimapButton()
		NidhausPlatesUtility:ShowMinimapButton()
	end

	NidhausPlates:ForceUpdate()
end

ApplyPanelSettings = function()
	NidhausPlatesOptions.primary = FORCED_THEME
	NidhausPlatesOptions.secondary = FORCED_THEME
	NidhausPlatesOptions.FriendlyAutomation = L["No Automation"]
	NidhausPlatesOptions.EnemyAutomation = L["No Automation"]

	if NidhausPlatesWidgets then
		NidhausPlatesWidgets:ResetWidgets()
	end

	if currentThemeName ~= FORCED_THEME then
		LoadTheme(FORCED_THEME)
	end

	ApplyAutomationSettings()
end

local function ShowWelcome()
	if not NidhausPlatesOptions.WelcomeShown then
		SetCVar("ShowClassColorInNameplate", 1)
		SetCVar("nameplateShowEnemies", 1)
		SetCVar("nameplateShowFriends", 0)
		SetCVar("threatWarning", 3)
		NidhausPlatesOptions.WelcomeShown = true
	end
end

local panelevents = {}

local function ShowWarnings()
	if NidhausPlatesWidgets then
		if not (NidhausPlatesWidgets.DebuffWidgetBuild and NidhausPlatesWidgets.DebuffWidgetBuild > 1) then
			print(
				L["|cFFFF6600Nidhaus Plates: |cFFFFFFFFWidget file versions do not match. This may be caused by an issue with auto-updater software."],
				L["Please uninstall Nidhaus Plates, and then re-install. You do NOT need to clear your variables."]
			)
		end
	end

	if currentThemeName ~= FORCED_THEME and not warned[activespec] then
		print(L["|cFFFF6600Nidhaus Plates: |cFFFF9900Nidhaus Plates theme could not be loaded. The addon files may be damaged; reinstall Nidhaus Plates."])
		warned[activespec] = true
	end
end

function panelevents:ACTIVE_TALENT_GROUP_CHANGED()
	if GetActiveTalentGroup(false, false) == 2 then
		activespec = "secondary"
	else
		activespec = "primary"
	end
	NidhausPlatesOptions.primary = FORCED_THEME
	NidhausPlatesOptions.secondary = FORCED_THEME
	LoadTheme(FORCED_THEME)

	if NidhausPlatesWidgets then
		NidhausPlatesWidgets:ResetWidgets()
	end
	NidhausPlates:ForceUpdate()

	CallIn(ShowWarnings, 2)
end

function panelevents:PLAYER_ENTERING_WORLD()
	panelevents:ACTIVE_TALENT_GROUP_CHANGED()
end

local function SetCVarCombatCondition(cvar, mode, combat)
	if mode == L["Show during Combat, Hide when Combat ends"] then
		if combat then
			SetCVar(cvar, 1)
		else
			SetCVar(cvar, 0)
		end
	elseif mode == L["Hide when Combat starts, Show when Combat ends"] then
		if combat then
			SetCVar(cvar, 0)
		else
			SetCVar(cvar, 1)
		end
	end
end

local SIMPLE_PANEL_VERSION = 1
local function ApplySimplePanelDefaults()
	if NidhausPlatesOptions.SimplePanelVersion ~= SIMPLE_PANEL_VERSION then
		NidhausPlatesOptions.SimplePanelVersion = SIMPLE_PANEL_VERSION
		NidhausPlatesOptions.EnableCastWatcher = true
		NidhausPlatesOptions.EnableMinimapButton = true
	end
end

function panelevents:PLAYER_LOGIN()
	ApplySimplePanelDefaults()
	NidhausPlatesOptions.primary = FORCED_THEME
	NidhausPlatesOptions.secondary = FORCED_THEME
	NidhausPlatesOptions.FriendlyAutomation = L["No Automation"]
	NidhausPlatesOptions.EnemyAutomation = L["No Automation"]
	UpdateThemeNames()
	ActivateInterfacePanel()
	ShowWelcome()
	LoadTheme(FORCED_THEME)
	ApplyAutomationSettings()
end

panel:SetScript("OnEvent", function(self, event, ...) panelevents[event](self, ...) end)
for eventname in pairs(panelevents) do
	panel:RegisterEvent(eventname)
end

NidhausPlatesSlashCommands = {}

function slash_NidhausPlates(arg)
	if type(NidhausPlatesSlashCommands[arg]) == "function" then
		NidhausPlatesSlashCommands[arg]()
		NidhausPlates:ForceUpdate()
	else

		ConfigureTheme("primary")
	end
end

SLASH_NIDHAUSPLATES1 = "/nplates"
SLASH_NIDHAUSPLATES2 = "/nidhausplates"
SlashCmdList["NIDHAUSPLATES"] = slash_NidhausPlates
