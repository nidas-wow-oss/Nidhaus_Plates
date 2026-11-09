local NidhausPlatesTheme = LibStub("AceAddon-3.0"):GetAddon("NidhausPlatesTheme")
local L = LibStub("AceLocale-3.0"):GetLocale("NidhausPlatesTheme")
local LDS = LibStub("LibDualSpec-1.0", true)
local class = select(2, UnitClass("Player"))

local ADDON_NAME = ...
NidhausPlatesTheme.title = NidhausPlatesTheme.DISPLAY_NAME
local path = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Media\\Artwork\\"
local db

local themeList = {"normal", "tank", "dps", "totem", "unique", "text"}
local FullAlign = {
	TOPLEFT = "TOPLEFT",
	TOP = "TOP",
	TOPRIGHT = "TOPRIGHT",
	LEFT = "LEFT",
	CENTER = "CENTER",
	RIGHT = "RIGHT",
	BOTTOMLEFT = "BOTTOMLEFT",
	BOTTOM = "BOTTOM",
	BOTTOMRIGHT = "BOTTOMRIGHT"
}
local AlignH = {LEFT = "LEFT", CENTER = "CENTER", RIGHT = "RIGHT"}
local AlignV = {BOTTOM = "BOTTOM", CENTER = "CENTER", TOP = "TOP"}
local FontStyle = {
	NONE = L["None"],
	OUTLINE = L["Outline"],
	THICKOUTLINE = L["Thick Outline"],
	["NONE, MONOCHROME"] = L["No Outline, Monochrome"],
	["OUTLINE, MONOCHROME"] = L["Outline, Monochrome"],
	["THICKOUTLINE, MONOCHROME"] = L["Thick Outline, Monochrome"]
}
local DebuffMode = {
	["whitelist"] = L["White List"],
	["blacklist"] = L["Black List"],
	["whitelistMine"] = L["White List (Mine)"],
	["blacklistMine"] = L["Black List (Mine)"],
	["all"] = L["All Debuffs"],
	["allMine"] = L["All Debuffs (Mine)"],
	["prefix"] = L["By Prefix"],
}
local totemID = {
	[1] = {8177, "A1", "b8d1ff"},
	[2] = {10595, "A2", "b8d1ff"},
	[3] = {10600, "A2", "b8d1ff"},
	[4] = {10601, "A2", "b8d1ff"},
	[5] = {25574, "A2", "b8d1ff"},
	[6] = {58746, "A2", "b8d1ff"},
	[7] = {58749, "A2", "b8d1ff"},
	[8] = {6495, "A3", "b8d1ff"},
	[9] = {8512, "A4", "b8d1ff"},
	[10] = {3738, "A5", "b8d1ff"},
	[11] = {2062, "E1", "ffb31f"},
	[12] = {2484, "E2", "ffb31f"},
	[13] = {5730, "E3", "ffb31f"},
	[14] = {6390, "E3", "ffb31f"},
	[15] = {6391, "E3", "ffb31f"},
	[16] = {6392, "E3", "ffb31f"},
	[17] = {10427, "E3", "ffb31f"},
	[18] = {10428, "E3", "ffb31f"},
	[19] = {25525, "E3", "ffb31f"},
	[20] = {58580, "E3", "ffb31f"},
	[21] = {58581, "E3", "ffb31f"},
	[22] = {58582, "E3", "ffb31f"},
	[23] = {8071, "E4", "ffb31f"},
	[24] = {8154, "E4", "ffb31f"},
	[25] = {8155, "E4", "ffb31f"},
	[26] = {10406, "E4", "ffb31f"},
	[27] = {10407, "E4", "ffb31f"},
	[28] = {10408, "E4", "ffb31f"},
	[29] = {25508, "E4", "ffb31f"},
	[30] = {25509, "E4", "ffb31f"},
	[31] = {58751, "E4", "ffb31f"},
	[32] = {58753, "E4", "ffb31f"},
	[33] = {8075, "E5", "ffb31f"},
	[34] = {8160, "E5", "ffb31f"},
	[35] = {8161, "E5", "ffb31f"},
	[36] = {10442, "E5", "ffb31f"},
	[37] = {25361, "E5", "ffb31f"},
	[38] = {25528, "E5", "ffb31f"},
	[39] = {57622, "E5", "ffb31f"},
	[40] = {58643, "E5", "ffb31f"},
	[41] = {8143, "E6", "ffb31f"},
	[42] = {2894, "F1", "ff8f8f"},
	[43] = {8227, "F2", "ff8f8f"},
	[44] = {8249, "F2", "ff8f8f"},
	[45] = {10526, "F2", "ff8f8f"},
	[46] = {16387, "F2", "ff8f8f"},
	[47] = {25557, "F2", "ff8f8f"},
	[48] = {58649, "F2", "ff8f8f"},
	[49] = {58652, "F2", "ff8f8f"},
	[50] = {58656, "F2", "ff8f8f"},
	[51] = {8181, "F3", "ff8f8f"},
	[52] = {10478, "F3", "ff8f8f"},
	[53] = {10479, "F3", "ff8f8f"},
	[54] = {25560, "F3", "ff8f8f"},
	[55] = {58741, "F3", "ff8f8f"},
	[56] = {58745, "F3", "ff8f8f"},
	[57] = {8190, "F4", "ff8f8f"},
	[58] = {10585, "F4", "ff8f8f"},
	[59] = {10586, "F4", "ff8f8f"},
	[60] = {10587, "F4", "ff8f8f"},
	[61] = {25552, "F4", "ff8f8f"},
	[62] = {58731, "F4", "ff8f8f"},
	[63] = {58734, "F4", "ff8f8f"},
	[64] = {3599, "F5", "ff8f8f"},
	[65] = {6363, "F5", "ff8f8f"},
	[66] = {6364, "F5", "ff8f8f"},
	[67] = {6365, "F5", "ff8f8f"},
	[68] = {10437, "F5", "ff8f8f"},
	[69] = {10438, "F5", "ff8f8f"},
	[70] = {25533, "F5", "ff8f8f"},
	[71] = {58699, "F5", "ff8f8f"},
	[72] = {58703, "F5", "ff8f8f"},
	[73] = {58704, "F5", "ff8f8f"},
	[74] = {30706, "F6", "ff8f8f"},
	[75] = {57720, "F6", "ff8f8f"},
	[76] = {57721, "F6", "ff8f8f"},
	[77] = {57722, "F6", "ff8f8f"},
	[78] = {8170, "W1", "2b76ff"},
	[79] = {8184, "W2", "2b76ff"},
	[80] = {10537, "W2", "2b76ff"},
	[81] = {10538, "W2", "2b76ff"},
	[82] = {25563, "W2", "2b76ff"},
	[83] = {58737, "W2", "2b76ff"},
	[84] = {58739, "W2", "2b76ff"},
	[85] = {5394, "W3", "2b76ff"},
	[86] = {6375, "W3", "2b76ff"},
	[87] = {6377, "W3", "2b76ff"},
	[88] = {10462, "W3", "2b76ff"},
	[89] = {10463, "W3", "2b76ff"},
	[90] = {25567, "W3", "2b76ff"},
	[91] = {58755, "W3", "2b76ff"},
	[92] = {58756, "W3", "2b76ff"},
	[93] = {58757, "W3", "2b76ff"},
	[94] = {5675, "W4", "2b76ff"},
	[95] = {10495, "W4", "2b76ff"},
	[96] = {10496, "W4", "2b76ff"},
	[97] = {10497, "W4", "2b76ff"},
	[98] = {25570, "W4", "2b76ff"},
	[99] = {58771, "W4", "2b76ff"},
	[100] = {58773, "W4", "2b76ff"},
	[101] = {58774, "W4", "2b76ff"},
	[102] = {16190, "W5", "2b76ff"}
}
StaticPopupDialogs["TPTP Donate"] = {
	text = NidhausPlatesTheme.title .. L["\n\nThank you for supporting my work!\n"],
	button1 = ACCEPT,
	hasEditBox = 1,
	editBoxWidth = 350,
	OnShow = function(self)
		self.editBox:SetText("bkader@mail.com")
		self.editBox:SetFocus()
	end,
	OnHide = function(self)
		self.editBox:SetText("")
	end,
	timeout = 30,
	whileDead = 1,
	hideOnEscape = 1
}

local MediaFetch = NidhausPlatesUtility.MediaFetch
local MediaList = NidhausPlatesUtility.MediaList
local MediaRegister = NidhausPlatesUtility.MediaRegister
MediaRegister("statusbar", "NidhausPlatesBar", [[Interface\Addons\Nidhaus_Plates\Theme\Media\Artwork\TP_BarTexture.tga]])
MediaRegister("font", "Accidental Presidency", [[Interface\Addons\Nidhaus_Plates\Theme\Media\Fonts\Accidental Presidency.ttf]])

MediaRegister("font", "Continuum Medium", [[Interface\Addons\Nidhaus_Plates\Theme\Media\Fonts\ContinuumMedium.ttf]])
MediaRegister("font", "Domyouji Regular", [[Interface\Addons\Nidhaus_Plates\Theme\Media\Fonts\DomyoujiRegular.ttf]])

local function GetSpellName(number)
	return (GetSpellInfo(number))
end

local function Update()
	NidhausPlates:ReloadTheme()
	NidhausPlates:ForceUpdate()
end

local function UpdateSpecial()
	db.uniqueSettings.list = {}
	for k_c, k_v in pairs(db.uniqueSettings) do
		if db.uniqueSettings[k_c].name then
			if type(db.uniqueSettings[k_c].name) == "string" then
				db.uniqueSettings.list[k_c] = db.uniqueSettings[k_c].name
			end
		end
	end
	Update()
end

local SplitToTable
do
	local t = {}
	function SplitToTable(...)
		wipe(t)
		for index = 1, select("#", ...) do
			local line = select(index, ...)
			if line ~= "" then
				t[line] = true
			end
		end
		return t
	end
end

local function TableToString(t)
	local list = ""
	for i = 1, #t do
		if list then
			if (t[(i + 1)] ~= "") then
				list = list .. (tostring(t[i])) .. "\n"
			else
				list = list .. (tostring(t[i]))
			end
		else
			list = (tostring(t[i])) .. "\n"
		end
	end
	return list
end

local function ThreatDisabled()
	if db.threat.ON then
		return false
	else
		return true
	end
end

local function GetValue(info)
	local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	if d then
		return db[a][b][c][d]
	elseif c and not d then
		return db[a][b][c]
	elseif b and not d and not c then
		return db[a][b]
	elseif a and not d and not c and not b then
		return db[a]
	end
end

local function SetValue(info, val)
	local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]

	if d then
		db[a][b][c][d] = val
	elseif c and not d then
		db[a][b][c] = val
	elseif b and not d and not c then
		db[a][b] = val
	elseif a and not d and not c and not b then
		db[a] = val
	end
	Update()
end

local function BGHmodule()
	return _G.NidhausPlatesHealers
end

local function BGHready()
	return BGHsettings ~= nil
end

local function GetBGHflag(info)
	return BGHready() and BGHsettings[info.arg] == 1
end

local function SetBGHflag(info, val)
	if not BGHready() then return end
	local key = info.arg
	if key == "enabled" then
		local m = BGHmodule()
		if m and m.SetEnabled then m.SetEnabled(val and true or false) return end
	end
	BGHsettings[key] = val and 1 or 0
	local m = BGHmodule()
	if m and m.ApplySettings then m.ApplySettings() end
end

local function GetBGH(info)
	return BGHready() and BGHsettings[info.arg]
end

local function SetBGH(info, val)
	if not BGHready() then return end
	BGHsettings[info.arg] = val
	local m = BGHmodule()
	if m and m.ApplySettings then m.ApplySettings() end
end

local function BGHoff()
	return not (BGHready() and BGHsettings.enabled == 1)
end

local function GetValueChar(info)
	local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	local t = NidhausPlatesTheme.db.char
	if d then
		return t[a][b][c][d]
	elseif c and not d then
		return t[a][b][c]
	elseif b and not d and not c then
		return t[a][b]
	elseif a and not d and not c and not b then
		return t[a]
	end
end

local function SetValueChar(info, val)
	local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	local t = NidhausPlatesTheme.db.char
	if d then
		t[a][b][c][d] = val
	elseif c and not d then
		t[a][b][c] = val
	elseif b and not d and not c then
		t[a][b] = val
	elseif a and not d and not c and not b then
		t[a] = val
	end
	Update()
end

local function GetColor(info)
	local h, i, j, k = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	local color
	if k then
		color = db[h][i][j][k]
	elseif j and not k then
		color = db[h][i][j]
	elseif i and not j and not k then
		color = db[h][i]
	elseif h and not i and not j and not k then
		color = db[h]
	end
	return color.r, color.g, color.b, color.a
end

local function SetColor(info, r, g, b)
	local h, i, j, k = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	local color
	if k then
		color = db[h][i][j][k]
	elseif j and not k then
		color = db[h][i][j]
	elseif i and not j and not k then
		color = db[h][i]
	elseif h and not i and not j and not k then
		color = db[h]
	end
	color.r, color.g, color.b = r, g, b
	Update()
end

local function GetColorAlpha(info)
	local h, i, j, k = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	local color
	if k then
		color = db[h][i][j][k]
	elseif j and not k then
		color = db[h][i][j]
	elseif i and not j and not k then
		color = db[h][i]
	elseif h and not i and not j and not k then
		color = db[h]
	end
	return color.r, color.g, color.b, color.a
end

local function SetColorAlpha(info, r, g, b, a)
	local h, i, j, k = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	local color
	if k then
		color = db[h][i][j][k]
	elseif j and not k then
		color = db[h][i][j]
	elseif i and not j and not k then
		color = db[h][i]
	elseif h and not i and not j and not k then
		color = db[h]
	end
	color.r, color.g, color.b, color.a = r, g, b, a
	Update()
end

local function SetThemeValue(info, val)
	local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	db[a][b][c] = val
	for i = 1, #themeList do
		NidhausPlatesThemeList["Nidhaus Plates"][themeList[i]][b][c] = val
	end
	Update()
end

local function SetThemeValueArt(info, val)
	local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	db[a][b][c] = val
	for i = 1, #themeList do
		NidhausPlatesThemeList["Nidhaus Plates"][themeList[i]][b][c] = path .. val
	end
	Update()
end

local function GetCastBorder(info)
	if db.lightCast then return "Border_Light" end
	return GetValue(info)
end

local function SetCastBorder(info, val)
	local light = (val == "Border_Light")
	db.lightCast = light
	if NidhausPlates_RefreshLightBorder then NidhausPlates_RefreshLightBorder() end
	if light then
		Update()
	else
		SetThemeValueArt(info, val)
	end
end

local function GetTargetHighlight(info)
	if db.roundTarget then return "Border_Rounded" end
	return GetValue(info)
end

local function SetTargetHighlight(info, val)
	local round = (val == "Border_Rounded")
	db.roundTarget = round
	if NidhausPlates_RefreshLightBorder then NidhausPlates_RefreshLightBorder() end
	if round then
		Update()
	else
		SetThemeValueArt(info, val)
	end
end

local function GetHealthBorder(info)
	if db.lightBorder then return "Border_Light" end
	return GetValue(info)
end

local function SetHealthBorder(info, val)
	local light = (val == "Border_Light")
	db.lightBorder = light
	if NidhausPlates_RefreshLightBorder then NidhausPlates_RefreshLightBorder() end
	if light then
		Update()
	else
		SetThemeValueArt(info, val)
	end
end

local function SetLSMFont(info, val)
	local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	db[a][b][c] = val
	for i = 1, #themeList do
		NidhausPlatesThemeList["Nidhaus Plates"][themeList[i]][b][c] = MediaFetch("font", db[a][b][c])
	end
	Update()
end

local function SetLSMTexture(info, val)
	local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	db[a][b][c] = val
	for i = 1, #themeList do
		NidhausPlatesThemeList["Nidhaus Plates"][themeList[i]][b][c] = MediaFetch("statusbar", db[a][b][c])
	end
	Update()
end

local function GetToggleNameplate(info)
	return db.nameplate.toggle[info.arg]
end

local function SetToggleNameplate(info)
	db.nameplate.toggle[info.arg] = not db.nameplate.toggle[info.arg]
	Update()
end

local options = nil
local function GetOptions()
	if not options then
		options = {
			name = NidhausPlatesTheme.title,
			handler = NidhausPlatesTheme,
			type = "group",
			childGroups = "tab",
			args = {

				NameplateSettings = {
					name = L["Nameplate Settings"],
					type = "group",
					order = 10,
					args = {
						GeneralSettings = {
							name = L["General Settings"],
							type = "group",
							order = 10,
							args = {
								Hiding = {
									name = L["Hiding"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										ShowNeutral = {
											type = "toggle",
											order = 1,
											name = L["Show Neutral"],
											get = GetToggleNameplate,
											set = SetToggleNameplate,
											arg = "Neutral"
										},
										ShowNormal = {
											type = "toggle",
											order = 2,
											name = L["Show Normal"],
											get = GetToggleNameplate,
											set = SetToggleNameplate,
											arg = "Normal"
										},
										ShowElite = {
											type = "toggle",
											order = 3,
											name = L["Show Elite"],
											get = GetToggleNameplate,
											set = SetToggleNameplate,
											arg = "Elite"
										},
										ShowBoss = {
											type = "toggle",
											order = 4,
											name = L["Show Boss"],
											get = GetToggleNameplate,
											set = SetToggleNameplate,
											arg = "Boss"
										},
										HideSnakes = {
											type = "toggle",
											order = 5,
											width = "double",
											name = L["Hide Hunter Snakes"],
											desc = L["Hides the nameplates of Viper and Venomous Snake from the hunter's Snake Trap."],
											descStyle = "inline",
											get = GetValue,
											set = SetValue,
											arg = {"hideSnakes"}
										},
										HideSnakesFriendly = {
											type = "toggle",
											order = 6,
											width = "double",
											name = L["Hide Your Own Snakes"],
											desc = L["Also hides the snakes summoned by you and your allies, not just the enemy ones."],
											descStyle = "inline",
											get = GetValue,
											set = SetValue,
											arg = {"hideSnakesFriendly"}
										},
										HideMirrorImage = {
											type = "toggle",
											order = 7,
											width = "double",
											name = L["Hide Mirror Images"],
											desc = L["Hides the nameplates of the mage's Mirror Image copies."],
											descStyle = "inline",
											get = GetValue,
											set = SetValue,
											arg = {"hideMirrorImage"}
										}
									}
								},
								BlizzSettings = {
									name = L["Blizzard Settings"],
									type = "group",
									order = 2,
									inline = true,
									args = {
										OpenBlizzardSettings = {
											name = L["Open Blizzard Settings"],
											type = "execute",
											order = 1,
											func = function()
												InterfaceOptionsFrame_OpenToCategory(_G["InterfaceOptionsNamesPanel"])
												LibStub("AceConfigDialog-3.0"):Close("Nidhaus Plates")
											end
										},
										Friendly = {
											type = "group",
											name = L["Friendly"],
											order = 2,
											inline = true,
											args = {
												nameplateShowFriends = {
													name = L["Show Friends"],
													type = "toggle",
													order = 1,
													get = function()
														return (GetCVar("nameplateShowFriends") == "1")
													end,
													set = function()
														SetCVar("nameplateShowFriends", abs(GetCVar("nameplateShowFriends") - 1))
													end
												},
												nameplateShowFriendlyTotems = {
													name = L["Show Friendly Totems"],
													type = "toggle",
													order = 2,
													get = function()
														return (GetCVar("nameplateShowFriendlyTotems") == "1")
													end,
													set = function()
														SetCVar("nameplateShowFriendlyTotems", abs(GetCVar("nameplateShowFriendlyTotems") - 1))
													end
												},
												nameplateShowFriendlyPets = {
													name = L["Show Friendly Pets"],
													type = "toggle",
													order = 3,
													get = function()
														return (GetCVar("nameplateShowFriendlyPets") == "1")
													end,
													set = function()
														SetCVar("nameplateShowFriendlyPets", abs(GetCVar("nameplateShowFriendlyPets") - 1))
													end
												},
												nameplateShowFriendlyGuardians = {
													name = L["Show Friendly Guardians"],
													type = "toggle",
													order = 4,
													get = function()
														return (GetCVar("nameplateShowFriendlyGuardians") == "1")
													end,
													set = function()
														SetCVar("nameplateShowFriendlyGuardians", abs(GetCVar("nameplateShowFriendlyGuardians") - 1))
													end
												}
											}
										},
										Enemy = {
											type = "group",
											name = L["Enemy"],
											order = 3,
											inline = true,
											args = {
												nameplateShowEnemies = {
													name = L["Show Enemies"],
													type = "toggle",
													order = 1,
													get = function()
														return (GetCVar("nameplateShowEnemies") == "1")
													end,
													set = function()
														SetCVar("nameplateShowEnemies", abs(GetCVar("nameplateShowEnemies") - 1))
													end
												},
												nameplateShowEnemyTotems = {
													name = L["Show Enemy Totems"],
													type = "toggle",
													order = 2,
													get = function()
														return (GetCVar("nameplateShowEnemyTotems") == "1")
													end,
													set = function()
														SetCVar("nameplateShowEnemyTotems", abs(GetCVar("nameplateShowEnemyTotems") - 1))
													end
												},
												nameplateShowEnemyPets = {
													name = L["Show Enemy Pets"],
													type = "toggle",
													order = 3,
													get = function()
														return (GetCVar("nameplateShowEnemyPets") == "1")
													end,
													set = function()
														SetCVar("nameplateShowEnemyPets", abs(GetCVar("nameplateShowEnemyPets") - 1))
													end
												},
												nameplateShowEnemyGuardians = {
													name = L["Show Enemy Guardians"],
													type = "toggle",
													order = 4,
													get = function()
														return (GetCVar("nameplateShowEnemyGuardians") == "1")
													end,
													set = function()
														SetCVar("nameplateShowEnemyGuardians", abs(GetCVar("nameplateShowEnemyGuardians") - 1))
													end
												}
											}
										}
									}
								}
							}
						},
						HealthBarTexture = {
							name = L["Healthbar"],
							type = "group",
							inline = false,
							order = 20,
							args = {
								Size = {
									name = L["Size"],
									type = "group",
									inline = true,
									order = 0,
									args = {
										Width = {
											type = "range",
											name = L["Width"],
											order = 10,
											get = GetValue,
											set = function(info, val)
												SetThemeValue({arg = {"settings", "healthbar", "width"}}, val)
												SetThemeValue({arg = {"settings", "frame", "width"}}, val + 4)
												SetThemeValue({arg = {"settings", "threatborder", "width"}}, (val * 2) + 20)
												SetThemeValue({arg = {"settings", "highlight", "width"}}, (val * 2) + 20)
												SetThemeValue({arg = {"settings", "healthborder", "width"}}, (val * 2) + 20)
												SetThemeValue({arg = {"settings", "castborder", "width"}}, (val * 2) + 20)
												SetThemeValue({arg = {"settings", "castnostop", "width"}}, (val * 2) + 20)
												SetThemeValue({arg = {"settings", "castbar", "width"}}, val)
												SetThemeValue(info, val)
											end,
											min = 80,
											max = 240,
											step = 0.1,
											bigStep = 1,
											arg = {"settings", "healthbar", "width"}
										},
										Height = {
											type = "range",
											name = L["Height"],
											order = 10,
											get = GetValue,
											set = function(info, val)
												SetThemeValue({arg = {"settings", "healthbar", "height"}}, val)
												SetThemeValue({arg = {"settings", "frame", "height"}}, val + 20)
												SetThemeValue({arg = {"settings", "threatborder", "height"}}, val + 54)
												SetThemeValue({arg = {"settings", "highlight", "height"}}, val + 54)
												SetThemeValue({arg = {"settings", "healthborder", "height"}}, val + 54)
												SetThemeValue({arg = {"settings", "castborder", "height"}}, val + 54)
												SetThemeValue({arg = {"settings", "castnostop", "height"}}, val + 54)
												SetThemeValue(info, val)
											end,
											min = 10,
											max = 20,
											step = 0.1,
											bigStep = 1,
											arg = {"settings", "healthbar", "height"}
										}
									}
								},
								HealthBarGroup = {
									name = L["Textures"],
									type = "group",
									inline = true,
									order = 10,
									args = {
										HealthBarTexture = {
											name = L["Healthbar"],
											type = "select",
											width = "double",
											dialogControl = "LSM30_Statusbar",
											order = 1,
											values = MediaList("statusbar"),
											get = GetValue,
											set = SetLSMTexture,
											arg = {"settings", "healthbar", "texture"}
										},
										Header1 = {
											type = "header",
											order = 1.5,
											name = ""
										},
										HealthBorderToggle = {
											type = "toggle",
											order = 2,
											name = L["Show Border"],
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "healthborder", "show"}
										},
										HealthBorder = {
											type = "select",
											order = 3,
											name = L["Normal Border"],
											desc = L["The same thin frame the minimap uses. The cast bar has its own setting."],
											get = GetHealthBorder,
											set = SetHealthBorder,
											disabled = function()
												return not db.settings.healthborder.show
											end,
											values = {
												TP_HealthBarOverlay = "Default",
												TP_HealthBarOverlayThin = "Thin",
												Border_Light = L["Light"],
											},
											arg = {"settings", "healthborder", "texture"}
										},
										Header2 = {
											type = "header",
											order = 3.5,
											name = ""
										},
										EliteHealthBorderToggle = {
											type = "toggle",
											order = 4,
											name = L["Show Elite Border"],
											get = GetValue,
											set = SetValue,
											arg = {"settings", "elitehealthborder", "show"}
										},
										EliteBorder = {
											type = "select",
											order = 5,
											name = L["Elite Border"],
											get = GetValue,
											set = SetValue,
											disabled = function()
												return not db.settings.elitehealthborder.show
											end,
											values = {
												TP_HealthBarEliteOverlay = "Default",
												TP_HealthBarEliteOverlayThin = "Thin"
											},
											arg = {"settings", "elitehealthborder", "texture"}
										},
										Header3 = {
											type = "header",
											order = 5.5,
											name = ""
										},
										Target = {
											type = "select",
											order = 6,
											name = L["Target"],
											desc = L["Rounded swaps the square highlight for a frame with rounded corners."],
											get = GetTargetHighlight,
											set = SetTargetHighlight,
											values = {
												TP_HealthBarHighlight = "Default",
												Border_Rounded = L["Rounded"],
												Empty = "None",
											},
											arg = {"settings", "target", "texture"}
										},
										Mouseover = {
											type = "select",
											order = 6.5,
											name = L["Mouseover"],
											get = GetValue,
											set = SetThemeValueArt,
											values = {TP_HealthBarHighlight = "Default", Empty = "None"},
											arg = {"settings", "highlight", "texture"}
										}
									}
								},
								Placement = {
									name = L["Placement"],
									type = "group",
									inline = true,
									order = 20,
									args = {
										Warning = {
											type = "description",
											descStyle = "inline",
											name = L["Changing these settings will alter the placement of the nameplates, however the mouseover area does not follow. |cffff0000Use with caution!|r"],
											order = 1,
											width = "full"
										},
										OffsetX = {
											name = L["Offset X"],
											type = "range",
											min = -60,
											max = 60,
											step = 1,
											order = 2,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "frame", "x"}
										},
										Offsety = {
											name = L["Offset Y"],
											type = "range",
											min = -60,
											max = 60,
											step = 1,
											order = 3,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "frame", "y"}
										}
									}
								},
								Coloring = {
									name = L["Coloring"],
									type = "group",
									inline = true,
									order = 30,
									args = {
										ColorByHPLevel = {
											name = L["Color HP by amount"],
											type = "toggle",
											desc = L["Changes the HP color depending on the amount of HP the nameplate shows."],
											descStyle = "inline",
											width = "double",
											order = 0,
											get = GetValue,
											set = SetValue,
											arg = {"healthColorChange"}
										},
										ClassColors = {
											name = L["Class Coloring"],
											order = 2,
											type = "group",
											inline = true,
											args = {
												Enemy = {
													name = L["Enemy Class Colors"],
													type = "group",
													inline = true,
													order = 1,
													disabled = function()
														return db.healthColorChange
													end,
													args = {
														Enable = {
															name = L["Enable Enemy Class colors"],
															type = "toggle",
															width = "double",
															get = GetValue,
															set = SetValue,
															order = 1,
															arg = {"allowClass"}
														}
													}
												},
												Friendly = {
													name = L["Friendly Class Colors"],
													type = "group",
													inline = true,
													order = 2,
													disabled = function()
														return db.healthColorChange
													end,
													args = {
														FriendlyClass = {
															name = L["Enable Friendly Class Colors"],
															type = "toggle",
															desc = L["Enable the showing of friendly player class color on hp bars."],
															descStyle = "inline",
															order = 1,
															width = "double",
															get = GetValue,
															set = SetValue,
															arg = {"friendlyClass"}
														},
														FriendlyCaching = {
															name = L["Friendly Caching"],
															type = "toggle",
															desc = L["This allows you to save friendly player class information between play sessions or nameplates going off the screen.|cffff0000(Uses more memory)"],
															descStyle = "inline",
															order = 2,
															width = "double",
															disabled = function()
																return (not db.friendlyClass or db.healthColorChange)
															end,
															get = GetValue,
															set = SetValue,
															arg = {"cacheClass"}
														},
														FriendlyTextOnly = {
															name = L["Name Only"],
															desc = L["Show only names above friendly units."],
															descStyle = "inline",
															order = 3,
															type = "toggle",
															width = "double",
															get = GetValue,
															set = SetValue,
															arg = {"friendlyNameOnly"}
														},
														FriendlyClickThrough = {
															name = L["Click Through"],
															order = 4,
															type = "toggle",
															width = "double",
															get = GetValue,
															set = SetValue,
															arg = {"friendlyClickThrough"},
															hidden = function() return not db.friendlyNameOnly end,
															disabled = function() return not db.friendlyNameOnly end
														}
													}
												}
											}
										},

										ThreatColors = {
											name = L["Threat Colors"],
											order = 1,
											type = "group",
											inline = true,
											args = {

												Header = {
													name = L["Colors"],
													type = "header",
													order = 2
												},
												Low = {
													name = L["|cff00ff00Low threat|r"],
													type = "color",
													order = 3,
													get = GetColorAlpha,
													set = SetColorAlpha,
													arg = {"settings", "normal", "threatcolor", "LOW"},
													hasAlpha = true
												},
												Med = {
													name = L["|cffffff00Medium threat|r"],
													type = "color",
													order = 4,
													get = GetColorAlpha,
													set = SetColorAlpha,
													arg = {"settings", "normal", "threatcolor", "MEDIUM"},
													hasAlpha = true
												},
												High = {
													name = L["|cffff0000High threat|r"],
													type = "color",
													get = GetColorAlpha,
													set = SetColorAlpha,
													order = 5,
													arg = {"settings", "normal", "threatcolor", "HIGH"},
													hasAlpha = true
												}
											}
										}
									}
								}
							}
						},
						CastBarSettings = {
							name = L["Castbar"],
							type = "group",
							order = 30,
							args = {
								Toggles = {
									name = L["Enable"],
									type = "group",
									inline = true,
									order = 1,
									args = {
										CastbarToggle = {
											name = L["Enable"],
											type = "toggle",
											order = 1,
											get = function()
												return (GetCVar("ShowVKeyCastbar") == "1")
											end,
											set = function(info, val)
												SetCVar("ShowVKeyCastbar", abs(GetCVar("ShowVKeyCastbar") - 1))
												Update()
											end,
											arg = {"settings", "castbar", "show"}
										},
										Header1 = {
											type = "header",
											name = L["Non-Target Castbars"],
											order = 2
										},
										SmartCastbarsToggle = {
											name = L["Enable"],
											type = "toggle",
											desc = L["This allows the castbar to attempt to create a castbar on nameplates of players or creatures you have recently moused over."],
											descStyle = "inline",
											width = "double",
											order = 4,
											disabled = function()
												return (GetCVar("ShowVKeyCastbar") ~= "1")
											end,
											get = function(info)
												return NidhausPlatesOptions.EnableCastWatcher
											end,
											set = function(info, val)
												NidhausPlatesOptions.EnableCastWatcher = not NidhausPlatesOptions.EnableCastWatcher
												if NidhausPlatesOptions.EnableCastWatcher then
													NidhausPlates:StartSpellCastWatcher()
												else
													NidhausPlates:StopSpellCastWatcher()
												end
											end
										}
									}
								},
								Textures = {
									name = L["Textures"],
									type = "group",
									inline = true,
									order = 1,
									disabled = function()
										return (GetCVar("ShowVKeyCastbar") ~= "1")
									end,
									args = {
										CastBarTexture = {
											name = L["Castbar"],
											type = "select",
											width = "double",
											dialogControl = "LSM30_Statusbar",
											order = 1,
											values = MediaList("statusbar"),
											get = GetValue,
											set = SetLSMTexture,
											arg = {"settings", "castbar", "texture"}
										},
										CastBorder = {
											name = L["Border"],
											type = "select",
											order = 2,
											desc = L["Light also frames the spell icon, which travels with the cast bar."],
											get = GetCastBorder,
											set = SetCastBorder,
											values = {
												TP_CastBarOverlay = "Default",
												Border_Light = L["Light"],
											},
											arg = {"settings", "castborder", "texture"}
										}
									}
								},
								Placement = {
									name = L["Placement"],
									type = "group",
									inline = true,
									order = 20,
									disabled = function()
										return (GetCVar("ShowVKeyCastbar") ~= "1")
									end,
									args = {
										PlacementX = {
											name = L["X"],
											type = "range",
											min = -60,
											max = 60,
											step = 1,
											order = 2,
											get = GetValue,
											set = function(info, val)
												local b1 = {arg = {"settings", "castborder", "x"}}
												local b2 = {arg = {"settings", "castnostop", "x"}}
												SetThemeValue(b1, val)
												SetThemeValue(b2, val)
												SetThemeValue(info, val)
											end,
											arg = {"settings", "castbar", "x"}
										},
										PlacementY = {
											name = L["Y"],
											type = "range",
											min = -60,
											max = 60,
											step = 1,
											order = 3,
											get = GetValue,
											set = function(info, val)
												local b1 = {arg = {"settings", "castborder", "y"}}
												local b2 = {arg = {"settings", "castnostop", "y"}}
												SetThemeValue(b1, val)
												SetThemeValue(b2, val)
												SetThemeValue(info, val)
											end,
											arg = {"settings", "castbar", "y"}
										}
									}
								},
								Coloring = {
									name = L["Coloring"],
									type = "group",
									inline = true,
									order = 30,
									args = {
										Enable = {
											name = L["Enable Coloring"],
											type = "toggle",
											order = 1,
											set = SetValue,
											get = GetValue,
											disabled = function()
												return (GetCVar("ShowVKeyCastbar") ~= "1")
											end,
											arg = {"castbarColor", "toggle"}
										},
										Interruptable = {
											name = L["Interruptable Casts"],
											type = "color",
											order = 2,
											get = GetColorAlpha,
											set = SetColorAlpha,
											disabled = function()
												return (not db.castbarColor.toggle or GetCVar("ShowVKeyCastbar") ~= "1")
											end,
											arg = {"castbarColor"}
										},
										Header1 = {
											type = "header",
											order = 3,
											name = ""
										},
										Enable2 = {
											name = L["Shielded Coloring"],
											type = "toggle",
											order = 4,
											set = SetValue,
											get = GetValue,
											disabled = function()
												return (not db.castbarColor.toggle or GetCVar("ShowVKeyCastbar") ~= "1")
											end,
											arg = {"castbarColorShield", "toggle"}
										},
										Shielded = {
											name = L["Uninterruptable Casts"],
											type = "color",
											order = 5,
											get = GetColorAlpha,
											set = SetColorAlpha,
											disabled = function()
												return (GetCVar("ShowVKeyCastbar") ~= "1" or not db.castbarColor.toggle or not db.castbarColorShield.toggle)
											end,
											arg = {"castbarColorShield"}
										}
									}
								}
							}
						},
						Alpha = {
							name = L["Alpha"],
							type = "group",
							order = 40,
							args = {
								BlizzFadeEnable = {
									name = L["Blizzard Target Fading"],
									type = "group",
									order = 1,
									inline = true,
									get = GetValue,
									set = SetValue,
									args = {
										Enable = {
											name = L["Enable Blizzard 'On-Target' Fading"],
											type = "toggle",
											desc = L["Enabling this will allow you to set the alpha adjustment for non-target nameplates."],
											descStyle = "inline",
											order = 1,
											get = GetValue,
											set = SetValue,
											width = "double",
											arg = {"blizzFade", "toggle"}
										},
										Adjustment = {
											name = L["Non-Target Alpha"],
											type = "range",
											order = 2,
											width = "double",
											disabled = function()
												return not db.blizzFade.toggle
											end,
											min = -1,
											max = 0,
											step = 0.01,
											isPercent = true,
											arg = {"blizzFade", "amount"}
										}
									}
								},
								NameplateAlpha = {
									name = L["Alpha Settings"],
									type = "group",
									order = 2,
									inline = true,
									get = GetValue,
									set = SetValue,
									args = {
										Neutral = {
											type = "range",
											order = 2,
											name = COMBATLOG_FILTER_STRING_NEUTRAL_UNITS,
											arg = {"nameplate", "alpha", "Neutral"},
											step = 0.05,
											min = 0,
											max = 1,
											isPercent = true
										},
										Normal = {
											type = "range",
											order = 3,
											name = PLAYER_DIFFICULTY1,
											arg = {"nameplate", "alpha", "Normal"},
											step = 0.05,
											min = 0,
											max = 1,
											isPercent = true
										},
										Elite = {
											type = "range",
											order = 4,
											name = ELITE,
											arg = {"nameplate", "alpha", "Elite"},
											step = 0.05,
											min = 0,
											max = 1,
											isPercent = true
										},
										Boss = {
											type = "range",
											order = 5,
											name = BOSS,
											arg = {"nameplate", "alpha", "Boss"},
											step = 0.05,
											min = 0,
											max = 1,
											isPercent = true
										}
									}
								}
							}
						},
						Scale = {
							name = L["Scale"],
							type = "group",
							order = 50,
							args = {
								NameplateScale = {
									name = L["Scale Settings"],
									type = "group",
									order = 2,
									inline = true,
									get = GetValue,
									set = SetValue,
									args = {
										Neutral = {
											type = "range",
											order = 2,
											name = COMBATLOG_FILTER_STRING_NEUTRAL_UNITS,
											arg = {"nameplate", "scale", "Neutral"},
											step = 0.05,
											min = 0.6,
											max = 1.3,
											isPercent = true
										},
										Normal = {
											type = "range",
											order = 3,
											name = PLAYER_DIFFICULTY1,
											arg = {"nameplate", "scale", "Normal"},
											step = 0.05,
											min = 0.6,
											max = 1.3,
											isPercent = true
										},
										Elite = {
											type = "range",
											order = 4,
											name = ELITE,
											arg = {"nameplate", "scale", "Elite"},
											step = 0.05,
											min = 0.6,
											max = 1.3,
											isPercent = true
										},
										Boss = {
											type = "range",
											order = 5,
											name = BOSS,
											arg = {"nameplate", "scale", "Boss"},
											step = 0.05,
											min = 0.6,
											max = 1.3,
											isPercent = true
										},
										Target = {
											type = "range",
											order = 5,
											name = STATUS_TEXT_TARGET,
											arg = {"nameplate", "scale", "Target"},
											step = 0.05,
											min = 0.6,
											max = 1.3,
											isPercent = true
										}
									}
								}
							}
						},
						Nametext = {
							name = L["Name Text"],
							type = "group",
							order = 60,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable Name Text"],
											type = "toggle",
											desc = L["Enables the showing of text on nameplates."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "name", "show"}
										}
									}
								},
								Options = {
									name = L["Options"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function()
										return not db.settings.name.show
									end,
									args = {
										FontLooks = {
											name = L["Font"],
											type = "group",
											inline = true,
											order = 1,
											args = {
												Font = {
													name = L["Font"],
													type = "select",
													order = 1,
													dialogControl = "LSM30_Font",
													values = AceGUIWidgetLSMlists.font,
													get = GetValue,
													set = SetLSMFont,
													arg = {"settings", "name", "typeface"}
												},
												FontStyle = {
													type = "select",
													order = 2,
													name = L["Font Style"],
													desc = L["Set the outlining style of the text."],
													values = FontStyle,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "name", "flags"}
												},
												Header1 = {
													type = "header",
													order = 3,
													name = ""
												},
												Color = {
													type = "color",
													order = 3,
													name = L["Color"],
													get = GetColor,
													set = SetColor,
													arg = {"settings", "name", "color"},
													hasAlpha = false
												},
												Shadow = {
													name = L["Enable Shadow"],
													order = 5,
													type = "toggle",
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "name", "shadow"}
												}
											}
										},
										FontSize = {
											name = L["Text Bounds and Sizing"],
											type = "group",
											order = 2,
											inline = true,
											args = {
												FontSize = {
													name = L["Font Size"],
													type = "range",
													width = "double",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "name", "size"},
													max = 36,
													min = 6,
													step = 1,
													isPercent = false
												},
												TextBounds = {
													name = L["Text Boundaries"],
													type = "group",
													order = 2,
													args = {
														Description = {
															type = "description",
															name = L["These settings will define the space that text can be placed on the nameplate.\nHaving too large a font and not enough height will cause the text to be not visible."],
															descStyle = "inline",
															order = 1,
															width = "full"
														},
														Width = {
															type = "range",
															order = 2,
															name = L["Text Width"],
															get = GetValue,
															set = SetThemeValue,
															arg = {"settings", "name", "width"},
															max = 250,
															min = 20,
															step = 1,
															isPercent = false
														},
														Height = {
															type = "range",
															order = 3,
															name = L["Text Height"],
															get = GetValue,
															set = SetThemeValue,
															arg = {"settings", "name", "height"},
															max = 40,
															min = 8,
															step = 1,
															isPercent = false
														}
													}
												}
											}
										},
										Placement = {
											name = L["Placement"],
											order = 3,
											type = "group",
											inline = true,
											args = {
												X = {
													name = L["X"],
													type = "range",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "name", "x"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Y = {
													name = L["Y"],
													type = "range",
													order = 2,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "name", "y"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												AlignH = {
													name = L["Horizontal Align"],
													type = "select",
													order = 3,
													values = AlignH,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "name", "align"}
												},
												AlignV = {
													name = L["Vertical Align"],
													type = "select",
													order = 4,
													values = AlignV,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "name", "vertical"}
												}
											}
										}
									}
								}
							}
						},
						Healthtext = {
							name = L["Health Text"],
							type = "group",
							order = 70,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable Health Text"],
											type = "toggle",
											desc = L["Enables the showing of text on nameplates."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "customtext", "show"}
										}
									}
								},
								Options = {
									name = L["Options"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function()
										if db.settings.customtext.show then
											return false
										else
											return true
										end
									end,
									args = {
										DisplaySettings = {
											name = L["Display Settings"],
											type = "group",
											order = 0,
											inline = true,
											args = {
												Full = {
													name = L["Text at Full HP"],
													type = "toggle",
													order = 0,
													width = "double",
													desc = L["Display health text on targets with full HP."],
													descStyle = "inline",
													get = GetValue,
													set = SetValue,
													arg = {"text", "full"}
												},
												EnablePercent = {
													name = L["Percent Text"],
													type = "toggle",
													order = 1,
													width = "double",
													desc = L["Display health percentage text."],
													descStyle = "inline",
													get = GetValue,
													set = SetValue,
													arg = {"text", "percent"}
												},
												EnableAmount = {
													name = L["Amount Text"],
													type = "toggle",
													order = 2,
													width = "double",
													desc = L["Display health amount text."],
													descStyle = "inline",
													get = GetValue,
													set = SetValue,
													arg = {"text", "amount"}
												},
												AmountSettings = {
													name = L["Amount Text Formatting"],
													type = "group",
													order = 3,
													inline = true,
													get = GetValue,
													set = SetValue,
													disabled = function()
														return not (db.text.amount and db.settings.customtext.show)
													end,
													args = {
														Truncate = {
															name = L["Truncate Text"],
															type = "toggle",
															order = 1,
															width = "double",
															desc = L["This will format text to a simpler format using M or K for millions and thousands. Disabling this will show exact HP amounts."],
															descStyle = "inline",
															arg = {"text", "truncate"}
														},
														MaxHP = {
															name = L["Max HP Text"],
															type = "toggle",
															order = 2,
															width = "double",
															desc = L["This will format text to show both the maximum hp and current hp."],
															descStyle = "inline",
															arg = {"text", "max"}
														},
														Deficit = {
															name = L["Deficit Text"],
															type = "toggle",
															order = 3,
															width = "double",
															desc = L["This will format text to show hp as a value the target is missing."],
															descStyle = "inline",
															arg = {"text", "deficit"}
														}
													}
												}
											}
										},
										FontLooks = {
											name = L["Font"],
											type = "group",
											inline = true,
											order = 1,
											args = {
												Font = {
													name = L["Font"],
													type = "select",
													order = 1,
													dialogControl = "LSM30_Font",
													values = AceGUIWidgetLSMlists.font,
													get = GetValue,
													set = SetLSMFont,
													arg = {"settings", "customtext", "typeface"}
												},
												FontStyle = {
													type = "select",
													order = 2,
													name = L["Font Style"],
													desc = L["Set the outlining style of the text."],
													values = FontStyle,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "customtext", "flags"}
												},
												Shadow = {
													name = L["Enable Shadow"],
													order = 4,
													type = "toggle",
													width = "double",
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "customtext", "shadow"}
												}
											}
										},
										FontSize = {
											name = L["Text Bounds and Sizing"],
											type = "group",
											order = 2,
											inline = true,
											args = {
												FontSize = {
													name = L["Font Size"],
													type = "range",
													width = "double",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "customtext", "size"},
													max = 36,
													min = 6,
													step = 1,
													isPercent = false
												},
												TextBounds = {
													name = L["Text Boundaries"],
													type = "group",
													order = 2,
													args = {
														Description = {
															type = "description",
															order = 1,
															name = L["These settings will define the space that text can be placed on the nameplate.\nHaving too large a font and not enough height will cause the text to be not visible."],
															width = "full"
														},
														Width = {
															type = "range",
															order = 2,
															name = L["Text Width"],
															get = GetValue,
															set = SetThemeValue,
															arg = {"settings", "customtext", "width"},
															max = 250,
															min = 20,
															step = 1,
															isPercent = false
														},
														Height = {
															type = "range",
															order = 3,
															name = L["Text Height"],
															get = GetValue,
															set = SetThemeValue,
															arg = {"settings", "customtext", "height"},
															max = 40,
															min = 8,
															step = 1,
															isPercent = false
														}
													}
												}
											}
										},
										Placement = {
											name = L["Placement"],
											order = 3,
											type = "group",
											inline = true,
											args = {
												X = {
													name = L["X"],
													type = "range",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "customtext", "x"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Y = {
													name = L["Y"],
													type = "range",
													order = 2,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "customtext", "y"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												AlignH = {
													name = L["Horizontal Align"],
													type = "select",
													order = 3,
													values = AlignH,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "customtext", "align"}
												},
												AlignV = {
													name = L["Vertical Align"],
													type = "select",
													order = 4,
													values = AlignV,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "customtext", "vertical"}
												}
											}
										}
									}
								}
							}
						},
						SpellText = {
							name = L["Spell Text"],
							type = "group",
							order = 80,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable Spell Text"],
											type = "toggle",
											desc = L["Enables the showing of text on nameplates."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "spelltext", "show"}
										}
									}
								},
								Options = {
									name = L["Options"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function()
										return not db.settings.spelltext.show
									end,
									args = {
										FontLooks = {
											name = L["Font"],
											type = "group",
											inline = true,
											order = 1,
											args = {
												Font = {
													name = L["Font"],
													type = "select",
													order = 1,
													dialogControl = "LSM30_Font",
													values = AceGUIWidgetLSMlists.font,
													get = GetValue,
													set = SetLSMFont,
													arg = {"settings", "spelltext", "typeface"}
												},
												FontStyle = {
													type = "select",
													order = 2,
													name = L["Font Style"],
													desc = L["Set the outlining style of the text."],
													values = FontStyle,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spelltext", "flags"}
												},
												Shadow = {
													name = L["Enable Shadow"],
													order = 4,
													type = "toggle",
													width = "double",
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spelltext", "shadow"}
												}
											}
										},
										FontSize = {
											name = L["Text Bounds and Sizing"],
											type = "group",
											order = 2,
											inline = true,
											args = {
												FontSize = {
													name = L["Font Size"],
													type = "range",
													width = "double",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spelltext", "size"},
													max = 36,
													min = 6,
													step = 1,
													isPercent = false
												},
												TextBounds = {
													name = L["Text Boundaries"],
													type = "group",
													order = 2,
													args = {
														Description = {
															type = "description",
															order = 1,
															name = L["These settings will define the space that text can be placed on the nameplate.\nHaving too large a font and not enough height will cause the text to be not visible."],
															width = "full"
														},
														Width = {
															type = "range",
															order = 2,
															name = L["Text Width"],
															get = GetValue,
															set = SetThemeValue,
															arg = {"settings", "spelltext", "width"},
															max = 250,
															min = 20,
															step = 1,
															isPercent = false
														},
														Height = {
															type = "range",
															order = 3,
															name = L["Text Height"],
															get = GetValue,
															set = SetThemeValue,
															arg = {"settings", "spelltext", "height"},
															max = 40,
															min = 8,
															step = 1,
															isPercent = false
														}
													}
												}
											}
										},
										Placement = {
											name = L["Placement"],
											order = 3,
											type = "group",
											inline = true,
											args = {
												X = {
													name = L["X"],
													type = "range",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spelltext", "x"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Y = {
													name = L["Y"],
													type = "range",
													order = 2,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spelltext", "y"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												AlignH = {
													name = L["Horizontal Align"],
													type = "select",
													order = 3,
													values = AlignH,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spelltext", "align"}
												},
												AlignV = {
													name = L["Vertical Align"],
													type = "select",
													order = 4,
													values = AlignV,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spelltext", "vertical"}
												}
											}
										}
									}
								}
							}
						},
						Leveltext = {
							name = L["Level Text"],
							type = "group",
							order = 90,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable Level Text"],
											type = "toggle",
											desc = L["Enables the showing of text on nameplates."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "level", "show"}
										}
									}
								},
								Options = {
									name = L["Options"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function()
										return not db.settings.level.show
									end,
									args = {
										FontLooks = {
											name = L["Font"],
											type = "group",
											inline = true,
											order = 1,
											args = {
												Font = {
													name = L["Font"],
													type = "select",
													order = 1,
													dialogControl = "LSM30_Font",
													values = AceGUIWidgetLSMlists.font,
													get = GetValue,
													set = SetLSMFont,
													arg = {"settings", "level", "typeface"}
												},
												FontStyle = {
													type = "select",
													order = 2,
													name = L["Font Style"],
													desc = L["Set the outlining style of the text."],
													values = FontStyle,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "level", "flags"}
												},
												Shadow = {
													name = L["Enable Shadow"],
													order = 4,
													type = "toggle",
													width = "double",
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "level", "shadow"}
												}
											}
										},
										FontSize = {
											name = L["Text Bounds and Sizing"],
											type = "group",
											order = 2,
											inline = true,
											args = {
												FontSize = {
													name = L["Font Size"],
													type = "range",
													width = "double",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "level", "size"},
													max = 36,
													min = 6,
													step = 1,
													isPercent = false
												},
												TextBounds = {
													name = L["Text Boundaries"],
													type = "group",
													order = 2,
													args = {
														Description = {
															type = "description",
															name = L["These settings will define the space that text can be placed on the nameplate.\nHaving too large a font and not enough height will cause the text to be not visible."],
															order = 1,
															width = "full"
														},
														Width = {
															type = "range",
															order = 2,
															name = L["Text Width"],
															get = GetValue,
															set = SetThemeValue,
															arg = {"settings", "level", "width"},
															max = 250,
															min = 20,
															step = 1,
															isPercent = false
														},
														Height = {
															type = "range",
															order = 3,
															name = L["Text Height"],
															get = GetValue,
															set = SetThemeValue,
															arg = {"settings", "level", "height"},
															max = 40,
															min = 8,
															step = 1,
															isPercent = false
														}
													}
												}
											}
										},
										Placement = {
											name = L["Placement"],
											order = 3,
											type = "group",
											inline = true,
											args = {
												X = {
													name = L["X"],
													type = "range",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "level", "x"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Y = {
													name = L["Y"],
													type = "range",
													order = 2,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "level", "y"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												AlignH = {
													name = L["Horizontal Align"],
													type = "select",
													order = 3,
													values = AlignH,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "level", "align"}
												},
												AlignV = {
													name = L["Vertical Align"],
													type = "select",
													order = 4,
													values = AlignV,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "level", "vertical"}
												}
											}
										}
									}
								}
							}
						},
						EliteIcon = {
							name = L["Elite Icon"],
							type = "group",
							order = 100,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable Elite Icon"],
											type = "toggle",
											desc = L["Enables the showing of the elite icon on nameplates."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "eliteicon", "show"}
										}
									}
								},
								Options = {
									name = L["Options"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function()
										return not db.settings.eliteicon.show
									end,
									args = {
										Texture = {
											name = L["Texture"],
											type = "group",
											inline = true,
											order = 1,
											args = {
												Preview = {
													name = L["Preview"],
													type = "execute",
													order = 1,
													image = "Interface\\AddOns\\Nidhaus_Plates\\Theme\\Widgets\\EliteArtWidget\\" .. db.settings.eliteicon.theme
												},
												Style = {
													type = "select",
													order = 2,
													name = L["Elite Icon Style"],
													values = {
														default = "Default",
														skullandcross = "Skull and Crossbones"
													},
													get = GetValue,
													set = function(info, val)
														local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
														db[a][b][c] = val
														for i = 1, #themeList do
															NidhausPlatesThemeList["Nidhaus Plates"][themeList[i]][b]["texture"] = "Interface\\AddOns\\Nidhaus_Plates\\Theme\\Widgets\\EliteArtWidget\\" .. val
														end
														options.args.NameplateSettings.args.EliteIcon.args.Options.args.Texture.args.Preview.image = "Interface\\AddOns\\Nidhaus_Plates\\Theme\\Widgets\\EliteArtWidget\\" .. val
														Update()
													end,
													arg = {"settings", "eliteicon", "theme"}
												},
												Header1 = {
													type = "header",
													order = 3,
													name = ""
												},
												Size = {
													name = L["Size"],
													type = "range",
													width = "double",
													order = 4,
													get = GetValue,
													set = function(info, val)
														local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
														db[a][b][c] = val
														for i = 1, #themeList do
															NidhausPlatesThemeList["Nidhaus Plates"][themeList[i]]["eliteicon"]["width"] = val
															NidhausPlatesThemeList["Nidhaus Plates"][themeList[i]]["eliteicon"]["height"] = val
														end
														Update()
													end,
													arg = {"settings", "eliteicon", "scale"},
													max = 64,
													min = 6,
													step = 1,
													isPercent = false
												}
											}
										},
										Placement = {
											name = L["Placement"],
											order = 3,
											type = "group",
											inline = true,
											args = {
												X = {
													name = L["X"],
													type = "range",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "eliteicon", "x"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Y = {
													name = L["Y"],
													type = "range",
													order = 2,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "eliteicon", "y"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Anchor = {
													name = L["Anchor"],
													type = "select",
													width = "double",
													order = 3,
													values = FullAlign,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "eliteicon", "anchor"}
												}
											}
										}
									}
								}
							}
						},
						SkullIcon = {
							name = L["Skull Icon"],
							type = "group",
							order = 110,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable Skull Icon"],
											type = "toggle",
											desc = L["Enables the showing of the skull icon on nameplates."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "skullicon", "show"}
										}
									}
								},
								Options = {
									name = L["Options"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function()
										return not db.settings.skullicon.show
									end,
									args = {
										Texture = {
											name = L["Texture"],
											type = "group",
											inline = true,
											order = 1,
											args = {
												Size = {
													name = L["Size"],
													type = "range",
													width = "double",
													order = 4,
													get = GetValue,
													set = function(info, val)
														local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
														db[a][b][c] = val
														for i = 1, #themeList do
															NidhausPlatesThemeList["Nidhaus Plates"][themeList[i]]["skullicon"]["width"] = val
															NidhausPlatesThemeList["Nidhaus Plates"][themeList[i]]["skullicon"]["height"] = val
														end
														Update()
													end,
													arg = {"settings", "skullicon", "scale"},
													max = 64,
													min = 6,
													step = 1,
													isPercent = false
												}
											}
										},
										Placement = {
											name = L["Placement"],
											order = 3,
											type = "group",
											inline = true,
											args = {
												X = {
													name = L["X"],
													type = "range",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "skullicon", "x"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Y = {
													name = L["Y"],
													type = "range",
													order = 2,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "skullicon", "y"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Anchor = {
													name = L["Anchor"],
													type = "select",
													width = "double",
													order = 3,
													values = FullAlign,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "skullicon", "anchor"}
												}
											}
										}
									}
								}
							}
						},
						SpellIcon = {
							name = L["Spell Icon"],
							type = "group",
							order = 120,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable Spell Icon"],
											type = "toggle",
											desc = L["Enables the showing of the spell icon on nameplates."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "spellicon", "show"}
										}
									}
								},
								Options = {
									name = L["Options"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function()
										return not db.settings.spellicon.show
									end,
									args = {
										Texture = {
											name = L["Texture"],
											type = "group",
											inline = true,
											order = 1,
											args = {
												Size = {
													name = L["Size"],
													type = "range",
													width = "double",
													order = 4,
													get = GetValue,
													set = function(info, val)
														local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
														db[a][b][c] = val
														for i = 1, #themeList do
															NidhausPlatesThemeList["Nidhaus Plates"][themeList[i]]["spellicon"]["width"] = val
															NidhausPlatesThemeList["Nidhaus Plates"][themeList[i]]["spellicon"]["height"] = val
														end
														Update()
													end,
													arg = {"settings", "spellicon", "scale"},
													max = 64,
													min = 6,
													step = 1,
													isPercent = false
												}
											}
										},
										Placement = {
											name = L["Placement"],
											order = 3,
											type = "group",
											inline = true,
											args = {
												X = {
													name = L["X"],
													type = "range",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spellicon", "x"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Y = {
													name = L["Y"],
													type = "range",
													order = 2,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spellicon", "y"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Anchor = {
													name = L["Anchor"],
													type = "select",
													width = "double",
													order = 3,
													values = FullAlign,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spellicon", "anchor"}
												}
											}
										}
									}
								}
							}
						},
						Raidmarks = {
							name = L["Raid Marks"],
							type = "group",
							order = 130,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable Raid Mark Icon"],
											type = "toggle",
											desc = L["Enables the showing of the raid mark icon on nameplates."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "raidicon", "show"}
										}
									}
								},
								Options = {
									name = L["Options"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function()
										return not db.settings.raidicon.show
									end,
									args = {
										Texture = {
											name = L["Texture"],
											type = "group",
											inline = true,
											order = 1,
											args = {
												Size = {
													name = L["Size"],
													type = "range",
													width = "double",
													order = 4,
													get = GetValue,
													set = function(info, val)
														local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
														db[a][b][c] = val
														for i = 1, #themeList do
															NidhausPlatesThemeList["Nidhaus Plates"][themeList[i]]["raidicon"]["width"] = val
															NidhausPlatesThemeList["Nidhaus Plates"][themeList[i]]["raidicon"]["height"] = val
														end
														Update()
													end,
													arg = {"settings", "raidicon", "scale"},
													max = 64,
													min = 6,
													step = 1,
													isPercent = false
												}
											}
										},
										Placement = {
											name = L["Placement"],
											order = 3,
											type = "group",
											inline = true,
											args = {
												X = {
													name = L["X"],
													type = "range",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "raidicon", "x"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Y = {
													name = L["Y"],
													type = "range",
													order = 2,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "raidicon", "y"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Anchor = {
													name = L["Anchor"],
													type = "select",
													width = "double",
													order = 3,
													values = FullAlign,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "raidicon", "anchor"}
												}
											}
										}
									}
								}
							}
						},
						BGHealers = {
							name = L["Battleground Healers"],
							type = "group",
							order = 140,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable Healer Marks"],
											type = "toggle",
											desc = L["Marks the nameplates of enemy and allied healers in battlegrounds."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetBGHflag,
											set = SetBGHflag,
											arg = "enabled"
										},

										enableInArena = {
											name = L["Also mark healers in arenas"] or "Also mark healers in arenas",
											type = "toggle",
											desc = L["In arenas only the combat log detection works, which is enough."]
												or "In arenas only the combat log detection works, which is enough.",
											descStyle = "inline",
											width = "double",
											order = 2,
											disabled = BGHoff,
											get = GetBGHflag,
											set = function(info, value)
												SetBGHflag(info, value)

												local f = _G["NidhausPlatesHealers"]
												if f and f.RefreshZoneState then f.RefreshZoneState() end
											end,
											arg = "enableInArena"
										}
									}
								},
								Detection = {
									name = L["Detection"],
									type = "group",
									order = 2,
									inline = true,
									disabled = BGHoff,
									args = {
										CLEUtracking = {
											name = L["Combat Log"],
											type = "toggle",
											desc = L["Detects a healer as soon as they cast one of about ninety telltale healing spells."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetBGHflag, set = SetBGHflag, arg = "CLEUtracking"
										},
										CLEUfix = {
											name = L["Combat Log Fix"],
											type = "toggle",
											desc = L["Keeps the combat log from going quiet during long battlegrounds."],
											descStyle = "inline",
											width = "double",
											order = 2,
											get = GetBGHflag, set = SetBGHflag, arg = "CLEUfix"
										},
										WSSFtracking = {
											name = L["Scoreboard"],
											type = "toggle",
											desc = L["Detects a healer by comparing healing against damage on the battleground scoreboard."],
											descStyle = "inline",
											width = "double",
											order = 3,
											get = GetBGHflag, set = SetBGHflag, arg = "WSSFtracking"
										},
										h2dRatio = {
											name = L["Healing to Damage Ratio"],
											type = "range",
											order = 4,
											min = 1, max = 5, step = 0.1, isPercent = false,
											disabled = function() return BGHoff() or BGHsettings.WSSFtracking ~= 1 end,
											get = GetBGH, set = SetBGH, arg = "h2dRatio"
										},
										healingThreshold = {
											name = L["Healing Threshold"],
											type = "range",
											order = 5,
											min = 10000, max = 100000, step = 5000,
											disabled = function() return BGHoff() or BGHsettings.WSSFtracking ~= 1 end,
											get = GetBGH, set = SetBGH, arg = "healingThreshold"
										}
									}
								},
								Icon = {
									name = L["Icon"],
									type = "group",
									order = 3,
									inline = true,
									disabled = BGHoff,
									args = {
										iconStyle = {
											name = L["Style"],
											type = "select",
											order = 1,
											values = { Blizzlike = L["Blizzlike"], Minimalist = L["Minimalist"] },
											get = GetBGH, set = SetBGH, arg = "iconStyle"
										},
										iconAnchor = {
											name = L["Anchor"],
											type = "select",
											order = 2,
											values = { left = L["Left"], top = L["Top"], right = L["Right"] },
											get = GetBGH, set = SetBGH, arg = "iconAnchor"
										},
										iconSize = {
											name = L["Size"],
											type = "range",
											order = 3,
											min = 20, max = 40, step = 1,
											get = GetBGH, set = SetBGH, arg = "iconSize"
										},
										iconXoffset = {
											name = L["X Offset"],
											type = "range",
											order = 4,

											min = -100, max = 100, step = 1,
											get = GetBGH, set = SetBGH, arg = "iconXoffset"
										},
										iconYoffset = {
											name = L["Y Offset"],
											type = "range",
											order = 5,
											min = -40, max = 40, step = 1,
											get = GetBGH, set = SetBGH, arg = "iconYoffset"
										},
										iconInvertColor = {
											name = L["Invert Colors"],
											type = "toggle",
											desc = L["By default enemies are red and allies are blue."],
											descStyle = "inline",
											width = "double",
											order = 6,
											get = GetBGHflag, set = SetBGHflag, arg = "iconInvertColor"
										}
									}
								}
							}
						}
					}
				},
				ThreatOptions = {
					name = L["Threat System"],
					type = "group",
					order = 30,
					args = {
						Enable = {
							name = L["Enable Threat System"],
							type = "toggle",
							order = 1,
							get = GetValue,
							set = function(info, val)
								SetValue(info, val)
								local iType = select(2, IsInInstance())
								if iType == "party" or iType == "raid" or iType == "none" then
									db.OldSetting = val
								end
							end,
							arg = {"threat", "ON"}
						},
						GeneralSettings = {
							name = L["General Settings"],
							type = "group",
							order = 0,
							disabled = ThreatDisabled,
							args = {
								AdditionalToggles = {
									name = L["Additional Toggles"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										IgnoreNonCombat = {
											type = "toggle",
											name = L["Ignore Non-Combat Threat"],
											order = 1,
											width = "double",
											desc = L["Disables threat feedback from mobs you're currently not in combat with."],
											descStyle = "inline",
											set = SetValue,
											get = GetValue,
											arg = {"threat", "nonCombat"}
										},
										Neutral = {
											type = "toggle",
											name = L["Show Neutral Threat"],
											order = 2,
											width = "double",
											desc = L["Disables threat feedback from neutral mobs regardless of boss or elite levels."],
											descStyle = "inline",
											set = SetValue,
											get = GetValue,
											arg = {"threat", "toggle", "Neutral"}
										},
										Normal = {
											type = "toggle",
											name = L["Show Normal Threat"],
											order = 3,
											width = "double",
											desc = L["Disables threat feedback from normal mobs."],
											descStyle = "inline",
											set = SetValue,
											get = GetValue,
											arg = {"threat", "toggle", "Normal"}
										},
										Elite = {
											type = "toggle",
											name = L["Show Elite Threat"],
											order = 4,
											width = "double",
											desc = L["Disables threat feedback from elite mobs."],
											descStyle = "inline",
											set = SetValue,
											get = GetValue,
											arg = {"threat", "toggle", "Elite"}
										},
										Boss = {
											type = "toggle",
											name = L["Show Boss Threat"],
											order = 5,
											width = "double",
											desc = L["Disables threat feedback from boss level mobs."],
											descStyle = "inline",
											set = SetValue,
											get = GetValue,
											arg = {"threat", "toggle", "Boss"}
										}
									}
								}
							}
						},
						Alpha = {
							name = L["Alpha"],
							type = "group",
							desc = L["Set alpha settings for different threat reaction types."],
							disabled = ThreatDisabled,
							get = GetValue,
							set = SetValue,
							order = 1,
							args = {
								Enable = {
									name = L["Enable Alpha Threat"],
									type = "group",
									inline = true,
									order = 0,
									args = {
										Enable = {
											type = "toggle",
											name = L["Enable"],
											desc = L["Enable nameplates to change alpha depending on the levels you set below."],
											width = "double",
											descStyle = "inline",
											order = 2,
											arg = {"threat", "useAlpha"}
										}
									}
								},
								Levels = {
									name = "Threat Levels",
									type = "group",
									inline = true,
									order = 2,
									disabled = function()
										return not db.threat.useAlpha
									end,
									args = {
										Low = {
											name = L["|cff00ff00Low threat|r"],
											type = "range",
											order = 1,
											arg = {"threat", "dps", "alpha", "LOW"},
											min = 0.01,
											max = 1,
											step = 0.01,
											isPercent = true
										},
										Med = {
											name = L["|cffffff00Medium threat|r"],
											type = "range",
											order = 2,
											arg = {"threat", "dps", "alpha", "MEDIUM"},
											min = 0.01,
											max = 1,
											step = 0.01,
											isPercent = true
										},
										High = {
											name = L["|cffff0000High threat|r"],
											type = "range",
											order = 3,
											arg = {"threat", "dps", "alpha", "HIGH"},
											min = 0.01,
											max = 1,
											step = 0.01,
											isPercent = true
										}
									}
								},
								Marked = {
									name = L["Marked Targets"],
									type = "group",
									inline = true,
									order = 3,
									disabled = function()
										return not db.threat.useAlpha
									end,
									args = {
										Toggle = {
											name = L["Ignore Marked Targets"],
											type = "toggle",
											order = 2,
											width = "double",
											desc = L["This will allow you to disabled threat alpha changes on marked targets."],
											descStyle = "inline",
											arg = {"threat", "marked", "alpha"}
										},
										Alpha = {
											name = L["Ignored Alpha"],
											order = 3,
											type = "range",
											disabled = function()
												return not (db.threat.marked.alpha and db.threat.useAlpha)
											end,
											step = 0.05,
											min = 0,
											max = 1,
											isPercent = true,
											arg = {"nameplate", "alpha", "Marked"}
										}
									}
								}
							}
						},
						Scale = {
							name = L["Scale"],
							type = "group",
							desc = L["Set scale settings for different threat reaction types."],
							disabled = ThreatDisabled,
							order = 1,
							get = GetValue,
							set = SetValue,
							args = {
								Enable = {
									name = L["Enable Scale Threat"],
									type = "group",
									inline = true,
									order = 0,
									args = {
										Enable = {
											type = "toggle",
											name = L["Enable"],
											desc = L["Enable nameplates to change scale depending on the levels you set below."],
											descStyle = "inline",
											width = "double",
											order = 2,
											arg = {"threat", "useScale"}
										}
									}
								},
								Levels = {
									name = "Threat Levels",
									type = "group",
									inline = true,
									order = 2,
									disabled = function()
										return not db.threat.useScale
									end,
									args = {
										Low = {
											name = L["|cff00ff00Low threat|r"],
											type = "range",
											order = 1,
											arg = {"threat", "dps", "scale", "LOW"},
											min = 0.01,
											max = 2,
											step = 0.01,
											isPercent = true
										},
										Med = {
											name = L["|cffffff00Medium threat|r"],
											type = "range",
											order = 2,
											arg = {"threat", "dps", "scale", "MEDIUM"},
											min = 0.01,
											max = 2,
											step = 0.01,
											isPercent = true
										},
										High = {
											name = L["|cffff0000High threat|r"],
											type = "range",
											order = 3,
											arg = {"threat", "dps", "scale", "HIGH"},
											min = 0.01,
											max = 2,
											step = 0.01,
											isPercent = true
										}
									}
								},
								Marked = {
									name = L["Marked Targets"],
									type = "group",
									inline = true,
									order = 3,
									disabled = function()
										return not db.threat.useScale
									end,
									args = {
										Toggle = {
											name = L["Ignore Marked Targets"],
											type = "toggle",
											order = 2,
											width = "double",
											desc = L["This will allow you to disabled threat scale changes on marked targets."],
											descStyle = "inline",
											arg = {"threat", "marked", "scale"}
										},
										Scale = {
											name = L["Ignored Scaling"],
											type = "range",
											order = 3,
											disabled = function()
												return not (db.threat.marked.scale and db.threat.useScale)
											end,
											step = 0.05,
											min = 0.3,
											max = 2,
											isPercent = true,
											arg = {"nameplate", "scale", "Marked"}
										}
									}
								},
								TypeSpecific = {
									name = L["Additional Adjustments"],
									type = "group",
									inline = true,
									order = 4,
									disabled = function()
										return not db.threat.useScale
									end,
									args = {
										Toggle = {
											name = L["Enable Adjustments"],
											order = 1,
											type = "toggle",
											width = "double",
											desc = L["This will allow you to add additional scaling changes to specific mob types."],
											descStyle = "inline",
											arg = {"threat", "useType"}
										},
										AdditionalSliders = {
											name = L["Additional Adjustments"],
											type = "group",
											order = 3,
											inline = true,
											disabled = function()
												return not (db.threat.useType and db.threat.useScale)
											end,
											args = {
												NormalNeutral = {
													name = PLAYER_DIFFICULTY1 .. " & " .. COMBATLOG_FILTER_STRING_NEUTRAL_UNITS,
													order = 1,
													type = "range",
													width = "double",
													arg = {"threat", "scaleType", "Normal"},
													min = -0.5,
													max = 0.5,
													step = 0.01,
													isPercent = true
												},
												Elite = {
													name = ELITE,
													order = 2,
													type = "range",
													width = "double",
													arg = {"threat", "scaleType", "Elite"},
													min = -0.5,
													max = 0.5,
													step = 0.01,
													isPercent = true
												},
												Boss = {
													name = BOSS,
													order = 3,
													type = "range",
													width = "double",
													arg = {"threat", "scaleType", "Boss"},
													min = -0.5,
													max = 0.5,
													step = 0.01,
													isPercent = true
												}
											}
										}
									}
								}
							}
						},
						Coloring = {
							name = L["Coloring"],
							type = "group",
							order = 4,
							disabled = ThreatDisabled,
							args = {
								Toggles = {
									name = L["Toggles"],
									order = 1,
									type = "group",
									inline = true,
									args = {
										UseHPColor = {
											name = L["Color HP by Threat"],
											type = "toggle",
											order = 1,
											desc = L["This allows HP color to be the same as the threat colors you set below."],
											descStyle = "inline",
											get = GetValue,
											set = SetValue,
											width = "double",
											arg = {"threat", "useHPColor"}
										}
									}
								},
								Levels = {
									name = "Threat Levels",
									type = "group",
									inline = true,
									get = GetColorAlpha,
									set = SetColorAlpha,
									order = 3,
									disabled = function()
										return not db.threat.useHPColor
									end,
									args = {
										Low = {
											name = L["|cff00ff00Low threat|r"],
											type = "color",
											order = 1,
											arg = {"settings", "dps", "threatcolor", "LOW"},
											hasAlpha = true
										},
										Med = {
											name = L["|cffffff00Medium threat|r"],
											type = "color",
											order = 2,
											arg = {"settings", "dps", "threatcolor", "MEDIUM"},
											hasAlpha = true
										},
										High = {
											name = L["|cffff0000High threat|r"],
											type = "color",
											order = 3,
											arg = {"settings", "dps", "threatcolor", "HIGH"},
											hasAlpha = true
										}
									}
								}
							}
						},
						Textures = {
							name = L["Textures"],
							type = "group",
							order = 5,
							desc = L["Set threat textures and their coloring options here."],
							disabled = ThreatDisabled,
							args = {
								ThreatArt = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable"],
											type = "toggle",
											order = 1,
											desc = L["These options are for the textures shown on nameplates at various threat levels."],
											descStyle = "inline",
											width = "double",
											get = GetValue,
											set = SetValue,
											arg = {"threat", "art", "ON"}
										}
									}
								},
								Options = {
									name = L["Art Options"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function()
										return not db.threat.art.ON
									end,
									get = GetValue,
									set = SetValue,
									args = {
										PrevLow = {
											name = L["Low Threat"],
											type = "execute",
											order = 1,
											width = "double",
											image = "Interface\\AddOns\\Nidhaus_Plates\\Theme\\Widgets\\ThreatWidget\\" .. db.threat.art.theme .. "\\" .. "HIGH",
											imageWidth = 256,
											imageHeight = 64
										},
										PrevMed = {
											name = L["Medium Threat"],
											type = "execute",
											order = 2,
											width = "double",
											image = "Interface\\AddOns\\Nidhaus_Plates\\Theme\\Widgets\\ThreatWidget\\" .. db.threat.art.theme .. "\\" .. "MEDIUM",
											imageWidth = 256,
											imageHeight = 64
										},
										PrevHigh = {
											name = L["High Threat"],
											type = "execute",
											order = 3,
											width = "double",
											image = "Interface\\AddOns\\Nidhaus_Plates\\Theme\\Widgets\\ThreatWidget\\" .. db.threat.art.theme .. "\\" .. "LOW",
											imageWidth = 256,
											imageHeight = 64
										},
										Style = {
											name = L["Style"],
											type = "group",
											order = 4,
											inline = true,
											args = {
												Dropdown = {
													name = "",
													type = "select",
													order = 1,
													set = function(info, val)
														SetValue(info, val)
														local i = options.args.ThreatOptions.args.Textures.args.Options.args
														local p = "Interface\\AddOns\\Nidhaus_Plates\\Theme\\Widgets\\ThreatWidget\\"
														i.PrevLow.image = p .. db.threat.art.theme .. "\\" .. "HIGH"
														i.PrevMed.image = p .. db.threat.art.theme .. "\\" .. "MEDIUM"
														i.PrevHigh.image = p .. db.threat.art.theme .. "\\" .. "LOW"
													end,
													values = {default = "Default", bar = "Bar Style"},
													arg = {"threat", "art", "theme"}
												}
											}
										},
										Marked = {
											name = L["Marked Targets"],
											type = "group",
											inline = true,
											order = 4,
											args = {
												Toggle = {
													name = L["Ignore Marked Targets"],
													order = 2,
													type = "toggle",
													desc = L["This will allow you to disabled threat art on marked targets."],
													descStyle = "inline",
													width = "double",
													arg = {"threat", "marked", "art"}
												}
											}
										}
									}
								}
							}
						},

					}
				},
				Widgets = {
					name = L["Widgets"],
					type = "group",
					order = 40,
					args = {
						ClassIconWidget = {
							name = L["Class Icons"],
							type = "group",
							order = 0,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									inline = true,
									order = 10,
									args = {
										Toggle = {
											name = L["Enable"],
											type = "toggle",
											order = 1,
											desc = L["This widget will display class icons on nameplate with the settings you set below."],
											descStyle = "inline",
											width = "double",
											set = SetValue,
											get = GetValue,
											arg = {"classWidget", "ON"}
										}
									}
								},
								Options = {
									name = L["Options"],
									type = "group",
									inline = true,
									order = 20,
									disabled = function()
										return not db.classWidget.ON
									end,
									args = {
										FriendlyClass = {
											name = L["Enable Friendly Icons"],
											type = "toggle",
											desc = L["Enable the showing of friendly player class icons."],
											descStyle = "inline",
											width = "double",
											get = GetValue,
											set = SetValue,
											arg = {"friendlyClassIcon"}
										},
										FriendlyCaching = {
											name = L["Friendly Caching"],
											type = "toggle",
											desc = L["This allows you to save friendly player class information between play sessions or nameplates going off the screen.|cffff0000(Uses more memory)"],
											descStyle = "inline",
											width = "double",
											disabled = function()
												return not (db.friendlyClassIcon and db.classWidget.ON)
											end,
											get = GetValue,
											set = SetValue,
											arg = {"cacheClass"}
										}
									}
								},
								Textures = {
									name = L["Textures"],
									type = "group",
									inline = true,
									order = 30,
									disabled = function()
										return not db.classWidget.ON
									end,
									args = {}
								},
								Sizing = {
									name = L["Scale"],
									type = "group",
									inline = true,
									order = 40,
									disabled = function()
										return not db.classWidget.ON
									end,
									args = {
										ScaleSlider = {
											name = "",
											type = "range",
											set = SetValue,
											get = GetValue,
											arg = {"classWidget", "scale"}
										}
									}
								},
								Placement = {
									name = L["Placement"],
									type = "group",
									inline = true,
									order = 50,
									disabled = function()
										return not db.classWidget.ON
									end,
									args = {
										X = {
											name = L["X"],
											type = "range",
											order = 1,
											set = SetValue,
											get = GetValue,
											min = -120,
											max = 120,
											step = 1,
											arg = {"classWidget", "x"}
										},
										Y = {
											name = L["Y"],
											type = "range",
											order = 1,
											set = SetValue,
											get = GetValue,
											min = -120,
											max = 120,
											step = 1,
											arg = {"classWidget", "y"}
										}
									}
								}
							}
						},
						ComboPointWidget = {
							name = L["Combo Points"],
							type = "group",
							order = 10,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									inline = true,
									order = 10,
									args = {
										Toggle = {
											name = L["Enable"],
											type = "toggle",
											order = 1,
											desc = L["This widget will display combo points on your target nameplate."],
											descStyle = "inline",
											width = "double",
											set = SetValue,
											get = GetValue,
											arg = {"comboWidget", "ON"}
										}
									}
								},
								Placement = {
									name = L["Placement"],
									type = "group",
									inline = true,
									order = 20,
									disabled = function()
										return not db.comboWidget.ON
									end,
									args = {
										X = {
											name = L["X"],
											type = "range",
											order = 1,
											set = SetValue,
											get = GetValue,
											min = -120,
											max = 120,
											step = 1,
											arg = {"comboWidget", "x"}
										},
										Y = {
											name = L["Y"],
											type = "range",
											order = 1,
											set = SetValue,
											get = GetValue,
											min = -120,
											max = 120,
											step = 1,
											arg = {"comboWidget", "y"}
										}
									}
								}
							}
						},
						DebuffWidget = {
							name = L["Debuffs"],
							type = "group",
							order = 20,
							set = SetValue,
							get = GetValue,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									inline = true,
									order = 10,
									args = {
										Toggle = {
											name = L["Enable"],
											type = "toggle",
											order = 1,
											desc = L["This widget will display debuffs that match your filtering on your target nameplate and others you recently moused over."],
											descStyle = "inline",
											width = "double",
											arg = {"debuffWidget", "ON"}
										}
									}
								},
								Sizing = {
									name = L["Sizing"],
									type = "group",
									order = 15,
									inline = true,
									disabled = function()
										return not db.debuffWidget.ON
									end,
									args = {
										Scale = {
											name = L["Scale"],
											type = "range",
											order = 1,
											width = "double",
											min = 0.6,
											max = 1.3,
											step = 0.05,
											isPercent = true,
											arg = {"debuffWidget", "scale"}
										}
									}
								},
								Placement = {
									name = L["Placement"],
									type = "group",
									inline = true,
									order = 20,
									disabled = function()
										return not db.debuffWidget.ON
									end,
									args = {
										X = {
											name = L["X"],
											type = "range",
											order = 1,
											min = -120,
											max = 120,
											step = 1,
											arg = {"debuffWidget", "x"}
										},
										Y = {
											name = L["Y"],
											type = "range",
											order = 2,
											min = -120,
											max = 120,
											step = 1,
											arg = {"debuffWidget", "y"}
										},
										Anchor = {
											name = L["Anchor"],
											type = "select",
											order = 3,
											values = FullAlign,
											arg = {"debuffWidget", "anchor"}
										}
									}
								},
								Filtering = {
									name = L["Filtering"],
									order = 30,
									type = "group",
									inline = true,
									disabled = function()
										return not db.debuffWidget.ON
									end,
									args = {
										Mode = {
											name = L["Mode"],
											type = "select",
											order = 1,
											width = "double",
											values = DebuffMode,
											arg = {"debuffWidget", "mode"}
										},
										DebuffList = {
											name = L["Filtered Debuffs"],
											type = "input",
											order = 2,
											dialogControl = "MultiLineEditBox",
											width = "double",
											get = function(info)
												local list = db.debuffWidget.filter
												return TableToString(list)
											end,
											set = function(info, v)
												v = v:trim()
												if v == "" then
													wipe(db.debuffWidget.filter)
												else
													local tbl = {strsplit("\n", v)}
													db.debuffWidget.filter = tbl
												end
											end,
											disabled = function()
												return (db.debuffWidget.mode == "all" or db.debuffWidget.mode == "allMine")
											end
										}
									}
								}
							}
						},
						SocialWidget = {
							name = L["Social Widget"],
							type = "group",
							order = 30,
							set = SetValue,
							get = GetValue,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									inline = true,
									order = 10,
									args = {
										Toggle = {
											name = L["Enable"],
											type = "toggle",
											desc = L["Enables the showing if indicator icons for friends, guildmates, and BNET Friends"],
											descStyle = "inline",
											width = "double",
											order = 1,
											arg = {"socialWidget", "ON"}
										}
									}
								},
								Sizing = {
									name = L["Scale"],
									type = "group",
									inline = true,
									order = 20,
									disabled = function()
										return not db.socialWidget.ON
									end,
									args = {
										ScaleSlider = {
											name = "",
											type = "range",
											arg = {"socialWidget", "scale"}
										}
									}
								},
								Placement = {
									name = L["Placement"],
									type = "group",
									inline = true,
									order = 30,
									disabled = function()
										return not db.socialWidget.ON
									end,
									args = {
										X = {
											name = L["X"],
											type = "range",
											order = 1,
											min = -120,
											max = 120,
											step = 1,
											arg = {"socialWidget", "x"}
										},
										Y = {
											name = L["Y"],
											type = "range",
											order = 1,
											min = -120,
											max = 120,
											step = 1,
											arg = {"socialWidget", "y"}
										}
									}
								}
							}
						},
						ArenaPartyIDWidget = {
							name = L["Arena / Party ID"],
							type = "group",
							order = 55,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Show Arena / Party ID"],
											type = "toggle",
											desc = L["Shows the arena number (1-5) or the party number (1-4) on the nameplate."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetValue, set = SetValue, arg = {"arenaPartyIDWidget", "ON"}
										},
										ShowArena = {
											name = L["Arena Opponents"],
											type = "toggle",
											width = "double",
											order = 2,
											disabled = function() return not db.arenaPartyIDWidget.ON end,
											get = GetValue, set = SetValue, arg = {"arenaPartyIDWidget", "showArena"}
										},
										ShowParty = {
											name = L["Party Members"],
											type = "toggle",
											width = "double",
											order = 3,
											disabled = function() return not db.arenaPartyIDWidget.ON end,
											get = GetValue, set = SetValue, arg = {"arenaPartyIDWidget", "showParty"}
										}
									}
								},
								Appearance = {
									name = L["Appearance"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function() return not db.arenaPartyIDWidget.ON end,
									args = {
										Font = {
											name = L["Font"],
											type = "select",
											order = 1,
											dialogControl = "LSM30_Font",
											values = AceGUIWidgetLSMlists and AceGUIWidgetLSMlists.font or {},
											get = GetValue, set = SetValue, arg = {"arenaPartyIDWidget", "font"}
										},
										Size = {
											name = L["Size"],
											type = "range",
											order = 2,
											min = 6, max = 36, step = 1,
											get = GetValue, set = SetValue, arg = {"arenaPartyIDWidget", "size"}
										},
										Outline = {
											name = L["Outline"],
											type = "select",
											order = 3,
											values = { [""] = L["None"], OUTLINE = L["Outline"], THICKOUTLINE = L["Thick Outline"] },
											get = GetValue, set = SetValue, arg = {"arenaPartyIDWidget", "outline"}
										},
										Anchor = {
											name = L["Anchor"],
											type = "select",
											order = 4,
											values = { Left = L["Left"], Center = L["Center"], Right = L["Right"], Top = L["Top"], Bottom = L["Bottom"] },
											get = GetValue, set = SetValue, arg = {"arenaPartyIDWidget", "anchor"}
										},
										OffsetX = {
											name = L["Offset X"],
											type = "range",
											order = 5,
											min = -50, max = 50, step = 1,
											get = GetValue, set = SetValue, arg = {"arenaPartyIDWidget", "x"}
										},
										OffsetY = {
											name = L["Offset Y"],
											type = "range",
											order = 6,
											min = -50, max = 50, step = 1,
											get = GetValue, set = SetValue, arg = {"arenaPartyIDWidget", "y"}
										},
										UseClassColor = {
											name = L["Use Class Color"],
											type = "toggle",
											width = "double",
											order = 7,
											get = GetValue, set = SetValue, arg = {"arenaPartyIDWidget", "useClassColor"}
										},
										Color = {
											name = L["Color"],
											type = "color",
											order = 8,
											disabled = function() return db.arenaPartyIDWidget.useClassColor end,
											get = function() local c = db.arenaPartyIDWidget.color return c.r, c.g, c.b end,
											set = function(_, r, g, b)
												local c = db.arenaPartyIDWidget.color
												c.r, c.g, c.b = r, g, b
												Update()
											end
										}
									}
								}
							}
						},
						ThreatLineWidget = {
							name = L["Threat Line"],
							type = "group",
							order = 40,
							set = SetValue,
							get = GetValue,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									inline = true,
									order = 10,
									args = {
										Toggle = {
											name = L["Enable"],
											type = "toggle",
											order = 1,
											desc = L["This widget will display a small bar that will display your current threat relative to other players on your target nameplate or recently mousedover namplates."],
											descStyle = "inline",
											width = "double",
											arg = {"threatWidget", "ON"}
										}
									}
								},
								Placement = {
									name = L["Placement"],
									type = "group",
									inline = true,
									order = 20,
									disabled = function()
										return not db.threatWidget.ON
									end,
									args = {
										X = {
											name = L["X"],
											type = "range",
											order = 1,
											min = -120,
											max = 120,
											step = 1,
											arg = {"threatWidget", "x"}
										},
										Y = {
											name = L["Y"],
											type = "range",
											order = 1,
											min = -120,
											max = 120,
											step = 1,
											arg = {"threatWidget", "y"}
										},
										Anchor = {
											name = L["Anchor"],
											type = "select",
											order = 4,
											values = FullAlign,
											arg = {"threatWidget", "anchor"}
										}
									}
								}
							}
						},
						TargetArtWidget = {
							name = L["Target Highlight"],
							type = "group",
							order = 60,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									inline = true,
									order = 10,
									args = {
										Toggle = {
											name = L["Enable"],
											type = "toggle",
											desc = L["Enables the showing of a texture on your target nameplate"],
											descStyle = "inline",
											width = "double",
											order = 1,
											set = SetValue,
											get = GetValue,
											arg = {"targetWidget", "ON"}
										}
									}
								},
								Style = {
									name = L["Style"],
									type = "group",
									inline = true,
									order = 20,
									disabled = function()
										return not db.targetWidget.ON
									end,
									args = {
										Width = {
											type = "range",
											name = L["Width"],
											order = 10,
											get = GetValue,
											set = SetValue,
											min = 10,
											max = 80,
											step = 0.1,
											bigStep = 1,
											arg = {"targetWidget", "width"}
										},
										Height = {
											type = "range",
											name = L["Height"],
											order = 20,
											get = GetValue,
											set = SetValue,
											min = 10,
											max = 80,
											step = 0.1,
											bigStep = 1,
											arg = {"targetWidget", "height"}
										},
										Color = {
											name = L["Color"],
											type = "color",
											order = 30,
											get = GetColorAlpha,
											set = SetColorAlpha,
											hasAlpha = true,
											arg = {"targetWidget"}
										},
										Invert = {
											type = "toggle",
											name = L["Invert Texture"],
											order = 40,
											get = GetValue,
											set = SetValue,
											arg = {"targetWidget", "inverted"}
										},
									}
								},
								Texture = {
									name = L["Texture"],
									type = "multiselect",
									width = "half",
									order = 30,
									disabled = function()
										return not db.targetWidget.ON
									end,
									get = function(info, key)
										return db.targetWidget.theme == key
									end,
									set = function(info, val)
										SetValue(info, val)
									end,
									arg = {"targetWidget", "theme"}
								}
							}
						}
					}
				},
				Totems = {
					name = L["Totem Nameplates"],
					type = "group",
					childGroups = "list",
					order = 50,
					args = {}
				},
				Custom = {
					name = L["Custom Nameplates"],
					type = "group",
					childGroups = "list",
					order = 60,
					args = {}
				}

			}
		}
	end
	local ClassOpts_OrderCount = 1
	local ClassOpts = {
		Style = {
			name = "Style",
			order = -1,
			type = "select",
			width = "double",
			get = GetValue,
			set = function(info, val)
				SetValue(info, val)
				for k_c, v_c in pairs(CLASS_SORT_ORDER) do
					options.args.Widgets.args.ClassIconWidget.args.Textures.args["Prev" .. k_c].image = "Interface\\AddOns\\Nidhaus_Plates\\Theme\\Widgets\\ClassIconWidget\\" .. db.classWidget.theme .. "\\" .. CLASS_SORT_ORDER[k_c]
				end
			end,

			values = {default = "Default", transparent = "Transparent", circle = "Circle"},
			arg = {"classWidget", "theme"}
		},

		Border = {
			name = L["Icon Border"],
			order = -2,
			type = "toggle",
			width = "double",
			desc = L["Draws a border around the class icon. Square on the square themes, a ring on Circle."],
			descStyle = "inline",
			get = GetValue,
			set = SetValue,
			arg = {"classWidget", "border"}
		},
		BorderThickness = {
			name = L["Border Thickness"],
			order = -3,
			type = "range",
			min = 1, max = 4, step = 0.5,
			disabled = function() return not db.classWidget.border or db.classWidget.theme == "circle" end,
			get = GetValue,
			set = SetValue,
			arg = {"classWidget", "borderThickness"}
		},
		BorderColor = {
			name = L["Border Color"],
			order = -4,
			type = "color",
			desc = L["Color of the border on units that are not your target."],
			disabled = function() return not db.classWidget.border end,
			get = function()
				local c = db.classWidget.borderColor
				return c.r, c.g, c.b
			end,
			set = function(_, r, g, b)
				local c = db.classWidget.borderColor
				c.r, c.g, c.b = r, g, b
				Update()
			end
		},
		BorderColorTarget = {
			name = L["Border Color (Target)"],
			order = -5,
			type = "color",
			desc = L["Color of the border on your current target."],
			disabled = function() return not db.classWidget.border end,
			get = function()
				local c = db.classWidget.borderColorTarget
				return c.r, c.g, c.b
			end,
			set = function(_, r, g, b)
				local c = db.classWidget.borderColorTarget
				c.r, c.g, c.b = r, g, b
				Update()
			end
		}
	}
	for k_c, v_c in pairs(CLASS_SORT_ORDER) do
		ClassOpts["Prev" .. k_c] = {
			name = CLASS_SORT_ORDER[k_c],
			type = "execute",
			order = ClassOpts_OrderCount,
			image = "Interface\\AddOns\\Nidhaus_Plates\\Theme\\Widgets\\ClassIconWidget\\" .. db.classWidget.theme .. "\\" .. CLASS_SORT_ORDER[k_c]
		}
		ClassOpts_OrderCount = ClassOpts_OrderCount + 1
	end
	options.args.Widgets.args.ClassIconWidget.args.Textures.args = ClassOpts
	local TotemOpts = {
		TotemSettings = {
			name = L["|cffffffffTotem Settings|r"],
			type = "group",
			order = 10,
			args = {
				Toggles = {
					name = L["Toggling"],
					type = "group",
					order = 1,
					inline = true,
					args = {
						HideHealth = {
							name = L["Hide Healthbars"],
							type = "toggle",
							order = 1,
							get = GetValue,
							set = SetValue,
							arg = {"totemSettings", "hideHealthbar"}
						},
						Header1 = {
							type = "header",
							order = 2,
							name = ""
						},
						ShowEnemy = {
							name = L["Show Enemy Totems"],
							type = "toggle",
							order = 3,
							get = function()
								return (GetCVar("nameplateShowEnemyTotems") == "1")
							end,
							set = function()
								SetCVar("nameplateShowEnemyTotems", abs(GetCVar("nameplateShowEnemyTotems") - 1))
							end
						},
						ShowFriend = {
							name = L["Show Friendly Totems"],
							type = "toggle",
							order = 4,
							get = function()
								return (GetCVar("nameplateShowFriendlyTotems") == "1")
							end,
							set = function()
								SetCVar("nameplateShowFriendlyTotems", abs(GetCVar("nameplateShowFriendlyTotems") - 1))
							end
						}
					}
				},
				Icon = {
					name = L["Icon"],
					type = "group",
					order = 2,
					inline = true,
					args = {
						Enable = {
							name = L["Enable"],
							type = "toggle",
							order = 1,
							set = SetValue,
							get = GetValue,
							arg = {"totemWidget", "ON"}
						},
						Options = {
							name = L["Options"],
							type = "group",
							inline = true,
							order = 2,
							disabled = function()
								return not db.totemWidget.ON
							end,
							set = SetValue,
							get = GetValue,
							args = {
								Header1 = {
									type = "header",
									order = 1,
									name = L["Placement"]
								},
								X = {
									name = L["X"],
									type = "range",
									order = 2,
									min = -120,
									max = 120,
									step = 1,
									arg = {"totemWidget", "x"}
								},
								Y = {
									name = L["Y"],
									type = "range",
									order = 3,
									min = -120,
									max = 120,
									step = 1,
									arg = {"totemWidget", "y"}
								},
								Anchor = {
									name = L["Anchor"],
									type = "select",
									order = 4,
									values = FullAlign,
									arg = {"totemWidget", "anchor"}
								},
								Header2 = {
									type = "header",
									order = 4,
									name = ""
								},
								Scale = {
									name = L["Icon Size"],
									type = "range",
									width = "double",
									order = 5,
									min = 0,
									max = 120,
									step = 1,
									arg = {"totemWidget", "scale"}
								},
								Border = {
									name = "Reaction Border",
									desc = "Green border on friendly totems, red on enemy ones.",
									type = "toggle",
									order = 6,
									arg = {"totemWidget", "border"}
								},
								TargetGlow = {
									name = "Target Glow",
									desc = "Glow around the totem icon while it is your target, in the Target Highlight color.",
									type = "toggle",
									order = 7,
									arg = {"totemWidget", "targetGlow"}
								}
							}
						}
					}
				},
				Alpha = {
					name = L["Alpha"],
					type = "group",
					order = 3,
					inline = true,
					get = GetValue,
					set = SetValue,
					args = {
						TotemAlpha = {
							name = L["Totem Alpha"],
							order = 1,
							type = "range",
							width = "double",
							arg = {"nameplate", "alpha", "Totem"},
							step = 0.05,
							min = 0,
							max = 1,
							isPercent = true
						}
					}
				},
				Scale = {
					name = L["Scale"],
					type = "group",
					order = 4,
					inline = true,
					get = GetValue,
					set = SetValue,
					args = {
						TotemAlpha = {
							name = L["Totem Scale"],
							order = 1,
							type = "range",
							width = "double",
							arg = {"nameplate", "scale", "Totem"},
							step = 0.05,
							min = 0.6,
							max = 1.3,
							isPercent = true
						}
					}
				}
			}
		}
	}
	local TotemOpts_OrderCnt = 30
	for k_c, v_c in ipairs(totemID) do
		local totemName = GetSpellInfo(totemID[k_c][1])
		TotemOpts[totemName] = {
			name = "|cff" .. totemID[k_c][3] .. totemName .. "|r",
			type = "group",
			order = TotemOpts_OrderCnt,
			args = {
				Header = {
					name = "> |cff" .. totemID[k_c][3] .. totemName .. "|r <",
					type = "header",
					order = 0
				},
				Enabled = {
					name = L["Enable"],
					type = "group",
					inline = true,
					order = 1,
					args = {
						Toggle = {
							name = L["Show Nameplate"],
							type = "toggle",
							set = SetValue,
							get = GetValue,
							arg = {"totemSettings", totemID[k_c][2], 1}
						}
					}
				},
				HealthColor = {
					name = L["Health Coloring"],
					type = "group",
					order = 2,
					inline = true,
					disabled = function()
						return not db.totemSettings[totemID[k_c][2]][1]
					end,
					args = {
						Enable = {
							name = L["Enable Custom Colors"],
							type = "toggle",
							order = 1,
							get = GetValue,
							set = SetValue,
							arg = {"totemSettings", totemID[k_c][2], 2}
						},
						Color = {
							name = L["Color"],
							type = "color",
							order = 2,
							get = GetColor,
							set = SetColor,
							disabled = function()
								return not (db.totemSettings[totemID[k_c][2]][1] and db.totemSettings[totemID[k_c][2]][2])
							end,
							arg = {"totemSettings", totemID[k_c][2], "color"}
						}
					}
				},
				Textures = {
					name = L["Textures"],
					type = "group",
					order = 3,
					inline = true,
					disabled = function()
						return not db.totemSettings[totemID[k_c][2]][1]
					end,
					args = {
						Icon = {
							name = "",
							type = "execute",
							width = "double",
							order = 0,
							image = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\TotemIconWidget\\" .. db.totemSettings[totemID[k_c][2]][7] .. "\\" .. totemID[k_c][2]
						},
						Style = {
							name = "",
							type = "select",
							order = 1,
							width = "double",
							get = GetValue,
							set = function(info, val)
								SetValue(info, val)
								options.args.Totems.args[totemName].args.Textures.args.Icon.image = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\TotemIconWidget\\" .. db.totemSettings[totemID[k_c][2]][7] .. "\\" .. totemID[k_c][2]
							end,
							values = {normal = "Normal", special = "Special"},
							arg = {"totemSettings", totemID[k_c][2], 7}
						}
					}
				}
			}
		}
		TotemOpts_OrderCnt = TotemOpts_OrderCnt + 10
	end
	options.args.Totems.args = TotemOpts
	local CustomOpts_OrderCnt = 30
	local CustomOpts = {
		GeneralSettings = {
			name = L["|cffffffffGeneral Settings|r"],
			type = "group",
			order = 10,
			args = {
				Icon = {
					name = L["Icon"],
					type = "group",
					order = 1,
					inline = true,
					args = {
						Enable = {
							name = L["Enable"],
							type = "toggle",
							desc = L["Disabling this will turn off any all icons without harming custom settings per nameplate."],
							descStyle = "inline",
							width = "double",
							order = 1,
							set = SetValue,
							get = GetValue,
							arg = {"uniqueWidget", "ON"}
						},
						Options = {
							name = L["Options"],
							type = "group",
							inline = true,
							order = 2,
							disabled = function()
								return not db.uniqueWidget.ON
							end,
							set = SetValue,
							get = GetValue,
							args = {
								Header1 = {
									type = "header",
									order = 1,
									name = L["Placement"]
								},
								X = {
									name = L["Y"],
									type = "range",
									order = 2,
									min = -120,
									max = 120,
									step = 1,
									arg = {"uniqueWidget", "x"}
								},
								Y = {
									name = L["Y"],
									type = "range",
									order = 3,
									min = -120,
									max = 120,
									step = 1,
									arg = {"uniqueWidget", "y"}
								},
								Anchor = {
									name = L["Anchor"],
									type = "select",
									order = 4,
									values = FullAlign,
									arg = {"uniqueWidget", "anchor"}
								},
								Header2 = {
									type = "header",
									order = 4,
									name = L["Sizing"]
								},
								Scale = {
									name = "",
									type = "range",
									order = 5,
									min = 0,
									max = 120,
									step = 1,
									arg = {"uniqueWidget", "scale"}
								}
							}
						}
					}
				}
			}
		}
	}
	CustomOpts_OrderCnt = 30
	local clipboard = nil
	for k_c, v_c in ipairs(db.uniqueSettings) do
		CustomOpts["#" .. k_c] = {
			name = "#" .. k_c .. ". " .. db.uniqueSettings[k_c].name,
			type = "group",
			order = CustomOpts_OrderCnt,
			args = {
				Header = {
					name = db.uniqueSettings[k_c].name,
					type = "header",
					order = 0
				},
				Name = {
					name = L["Set Name"],
					order = 1,
					type = "group",
					inline = true,
					args = {
						SetName = {
							name = db.uniqueSettings[k_c].name,
							type = "input",
							order = 1,
							width = "double",
							get = GetValue,
							set = function(info, val)
								SetValue(info, val)
								options.args.Custom.args["#" .. k_c].name = "#" .. k_c .. ". " .. val
								options.args.Custom.args["#" .. k_c].args.Header.name = val
								options.args.Custom.args["#" .. k_c].args.Name.args.SetName.name = val
								UpdateSpecial()
							end,
							arg = {"uniqueSettings", k_c, "name"}
						},
						TargetButton = {
							name = L["Use Target's Name"],
							type = "execute",
							order = 2,
							width = "single",
							func = function()
								if UnitExists("Target") then
									local target = UnitName("Target")
									db.uniqueSettings[k_c].name = target
									options.args.Custom.args["#" .. k_c].name = "#" .. k_c .. ". " .. target
									options.args.Custom.args["#" .. k_c].args.Header.name = target
									options.args.Custom.args["#" .. k_c].args.Name.args.SetName.name = target
									UpdateSpecial()
								else
									if db.verbose then
										print(NidhausPlatesTheme.DISPLAY_NAME .. ": " .. L["No target found."])
									end
								end
							end
						},
						ClearButton = {
							name = L["Clear"],
							type = "execute",
							order = 3,
							width = "single",
							func = function()
								db.uniqueSettings[k_c].name = ""
								options.args.Custom.args["#" .. k_c].name = "#" .. k_c .. ". " .. ""
								options.args.Custom.args["#" .. k_c].args.Header.name = ""
								options.args.Custom.args["#" .. k_c].args.Name.args.SetName.name = ""
								UpdateSpecial()
							end
						},
						Header1 = {
							name = "",
							order = 4,
							type = "header"
						},
						Copy = {
							name = L["Copy"],
							order = 5,
							type = "execute",
							func = function()
								clipboard = db.uniqueSettings[k_c]
								if type(clipboard) == "table" and db.verbose then
									print(NidhausPlatesTheme.DISPLAY_NAME .. ": " .. L["Copied!"])
								end
							end
						},
						Paste = {
							name = L["Paste"],
							order = 6,
							type = "execute",
							func = function()
								if type(clipboard) == "table" then
									db.uniqueSettings[k_c] = clipboard
									if db.verbose then
										print(NidhausPlatesTheme.DISPLAY_NAME .. ": " .. L["Pasted!"])
									end
								else
									if db.verbose then
										print(NidhausPlatesTheme.DISPLAY_NAME .. ": " .. L["Nothing to paste!"])
									end
								end
								options.args.Custom.args["#" .. k_c].name = "#" .. k_c .. ". " .. db.uniqueSettings[k_c].name
								options.args.Custom.args["#" .. k_c].args.Header.name = db.uniqueSettings[k_c].name
								options.args.Custom.args["#" .. k_c].args.Name.args.SetName.name = db.uniqueSettings[k_c].name
								if tonumber(db.uniqueSettings[k_c].icon) == nil then
									options.args.Custom.args["#" .. k_c].args.Icon.args.Icon.image = db.uniqueSettings[k_c].icon
								else
									local icon = select(3, GetSpellInfo(tonumber(db.uniqueSettings[k_c].icon)))
									if icon then
										options.args.Custom.args["#" .. k_c].args.Icon.args.Icon.image = icon
									else
										options.args.Custom.args["#" .. k_c].args.Icon.args.Icon.image = "Interface\\Icons\\Temp"
									end
								end
								UpdateSpecial()
								clipboard = nil
							end
						},
						Header2 = {
							name = "",
							order = 7,
							type = "header"
						},
						ResetDefault = {
							type = "execute",
							name = L["Restore Defaults"],
							order = 8,
							func = function()
								local defaults = {
									name = "",
									showNameplate = true,
									showIcon = true,
									useStyle = true,
									useColor = true,
									allowMarked = true,
									overrideScale = false,
									overrideAlpha = false,
									icon = "",
									scale = 1,
									alpha = 1,
									color = {r = 1, g = 1, b = 1}
								}
								db.uniqueSettings[k_c] = defaults
								options.args.Custom.args["#" .. k_c].name = "#" .. k_c .. ". " .. ""
								options.args.Custom.args["#" .. k_c].args.Header.name = ""
								options.args.Custom.args["#" .. k_c].args.Name.args.SetName.name = ""
								options.args.Custom.args["#" .. k_c].args.Icon.args.Icon.image = ""
								UpdateSpecial()
							end
						}
					}
				},
				Enabled = {
					name = L["Enable"],
					type = "group",
					inline = true,
					order = 2,
					args = {
						UseStyle = {
							name = L["Use Custom Settings"],
							type = "toggle",
							order = 1,
							set = SetValue,
							get = GetValue,
							arg = {"uniqueSettings", k_c, "useStyle"}
						},
						Header1 = {
							type = "header",
							order = 2,
							name = ""
						},
						Namplate = {
							name = L["Show Nameplate"],
							type = "toggle",
							disabled = function()
								return not db.uniqueSettings[k_c].useStyle
							end,
							order = 3,
							set = SetValue,
							get = GetValue,
							arg = {"uniqueSettings", k_c, "showNameplate"}
						},
						CustomSettings = {
							name = L["Custom Settings"],
							type = "group",
							inline = true,
							order = 4,
							disabled = function()
								return (not db.uniqueSettings[k_c].useStyle or not db.uniqueSettings[k_c].showNameplate)
							end,
							args = {
								AlphaSettings = {
									name = L["Alpha"],
									type = "group",
									order = 1,
									inline = true,
									set = SetValue,
									get = GetValue,
									args = {
										DisableOverride = {
											name = L["Disable Custom Alpha"],
											type = "toggle",
											desc = L["Disables the custom alpha setting for this nameplate and instead uses your normal alpha settings."],
											descStyle = "inline",
											width = "double",
											order = 1,
											arg = {"uniqueSettings", k_c, "overrideAlpha"}
										},
										AlphaSetting = {
											name = L["Custom Alpha"],
											type = "range",
											order = 2,
											disabled = function()
												return (db.uniqueSettings[k_c].overrideAlpha or not db.uniqueSettings[k_c].useStyle or not db.uniqueSettings[k_c].showNameplate)
											end,
											min = 0,
											max = 1,
											step = 0.05,
											isPercent = true,
											arg = {"uniqueSettings", k_c, "alpha"}
										}
									}
								},
								ScaleSettings = {
									name = L["Scale"],
									type = "group",
									order = 1,
									inline = true,
									set = SetValue,
									get = GetValue,
									args = {
										DisableOverride = {
											name = L["Disable Custom Scale"],
											type = "toggle",
											desc = L["Disables the custom scale setting for this nameplate and instead uses your normal scale settings."],
											descStyle = "inline",
											width = "double",
											order = 1,
											arg = {"uniqueSettings", k_c, "overrideScale"}
										},
										ScaleSetting = {
											name = L["Custom Scale"],
											type = "range",
											order = 2,
											disabled = function()
												return (db.uniqueSettings[k_c].overrideScale or not db.uniqueSettings[k_c].useStyle or not db.uniqueSettings[k_c].showNameplate)
											end,
											min = 0,
											max = 1.4,
											step = 0.05,
											isPercent = true,
											arg = {"uniqueSettings", k_c, "scale"}
										}
									}
								},
								HealthColor = {
									name = L["Health Coloring"],
									type = "group",
									order = 3,
									inline = true,
									args = {
										UseRaidMarked = {
											name = L["Allow Marked HP Coloring"],
											type = "toggle",
											desc = L["Allow raid marked hp color settings instead of a custom hp setting if the nameplate has a raid mark."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetValue,
											set = SetValue,
											arg = {"uniqueSettings", k_c, "allowMarked"}
										},
										Enable = {
											name = L["Enable Custom Colors"],
											type = "toggle",
											order = 2,
											width = "double",
											get = GetValue,
											set = SetValue,
											arg = {"uniqueSettings", k_c, "useColor"}
										},
										Color = {
											name = L["Color"],
											type = "color",
											order = 3,
											get = GetColor,
											set = SetColor,
											disabled = function()
												return (not db.uniqueSettings[k_c].useColor or not db.uniqueSettings[k_c].useStyle or not db.uniqueSettings[k_c].showNameplate)
											end,
											arg = {"uniqueSettings", k_c, "color"}
										}
									}
								}
							}
						}
					}
				},
				Icon = {
					name = L["Icon"],
					type = "group",
					order = 3,
					inline = true,
					disabled = function()
						return (not db.uniqueWidget.ON or not db.uniqueSettings[k_c].showNameplate)
					end,
					args = {
						Enable = {
							name = L["Enable"],
							type = "toggle",
							order = 1,
							desc = L["Enable the showing of the custom nameplate icon for this nameplate."],
							descStyle = "inline",
							width = "double",
							get = GetValue,
							set = SetValue,
							arg = {"uniqueSettings", k_c, "showIcon"}
						},
						Icon = {
							name = L["Preview"],
							type = "execute",
							width = "double",
							disabled = function()
								return (not db.uniqueSettings[k_c].showIcon or not db.uniqueWidget.ON or not db.uniqueSettings[k_c].showNameplate)
							end,
							order = 2,
							image = function()
								if tonumber(db.uniqueSettings[k_c].icon) == nil then
									return db.uniqueSettings[k_c].icon
								else
									return select(3, GetSpellInfo(tonumber(db.uniqueSettings[k_c].icon))) or "Interface\\Icons\\Temp"
								end
							end,
							imageWidth = 64,
							imageHeight = 64
						},
						Description = {
							type = "description",
							order = 3,
							name = L["Type direct icon texture path using '\\' to separate directory folders, or use a spellid."],
							width = "full"
						},
						SetIcon = {
							name = L["Set Icon"],
							type = "input",
							order = 4,
							disabled = function()
								return (not db.uniqueSettings[k_c].showIcon or not db.uniqueWidget.ON or not db.uniqueSettings[k_c].showNameplate)
							end,
							width = "double",
							get = GetValue,
							set = function(info, val)
								SetValue(info, val)
								if tonumber(val) == nil then
									options.args.Custom.args["#" .. k_c].args.Icon.args.Icon.image = val
								else
									local icon = select(3, GetSpellInfo(tonumber(db.uniqueSettings[k_c].icon))) or "Interface\\Icons\\Temp"
									options.args.Custom.args["#" .. k_c].args.Icon.args.Icon.image = icon
								end
								UpdateSpecial()
							end,
							arg = {"uniqueSettings", k_c, "icon"}
						}
					}
				}
			}
		}
		CustomOpts_OrderCnt = CustomOpts_OrderCnt + 10
	end
	options.args.Custom.args = CustomOpts

	do
		local arrows = {}
		options.args.Widgets.args.TargetArtWidget.args.Texture.values = arrows
		for i = 0, 72 do
			arrows["arrow" .. i] = "|TInterface\\AddOns\\Nidhaus_Plates\\Theme\\Widgets\\TargetArtWidget\\arrow" .. i .. ".tga:45:45|t"
		end
	end

	return options
end

local intoptions = nil
local function GetIntOptions()
	if not intoptions then
		intoptions = {
			name = NidhausPlatesTheme.title,
			handler = NidhausPlatesTheme,
			type = "group",
			args = {
				note = {
					type = "description",
					name = L["You can access the "] .. NidhausPlatesTheme.title .. L[" options by typing: /tptp"],
					order = 10
				},
				openoptions = {
					type = "execute",
					name = L["Open Config"],

					width = "double",
					func = function()
						NidhausPlatesTheme:OpenOptions()
					end,
					order = 20
				},

				coreheader = {
					type = "header",
					name = L["Nameplate Settings"],
					order = 30
				},
				castwatcher = {
					type = "toggle",
					name = L["Show Non-Target Casting Bars (When Possible)"],
					width = "double",
					order = 40,
					get = function() return NidhausPlates:GetCastWatcher() end,
					set = function(_, val) NidhausPlates:SetCastWatcher(val) end
				},
				minimapicon = {
					type = "toggle",
					name = L["Enable Minimap Icon"],
					width = "double",
					order = 50,
					get = function() return NidhausPlates:GetMinimapButton() end,
					set = function(_, val) NidhausPlates:SetMinimapButton(val) end
				},
				blizzoptions = {
					type = "execute",
					name = L["Blizzard Nameplate Motion & Visibility"],
					width = "double",
					order = 60,
					func = function() NidhausPlates:OpenBlizzardNameplateOptions() end
				},
				resetconfig = {
					type = "execute",
					name = L["Reset Configuration"],
					desc = L["Restores the Nidhaus Plates defaults and reloads the UI."],
					width = "double",
					order = 70,
					confirm = true,
					func = function() NidhausPlates:ResetConfiguration() end
				}
			}
		}
	end
	return intoptions
end

local SKIN_BG    = { 0.06, 0.06, 0.06, 0.85 };
local SKIN_TITLE = { 0.28, 0.28, 0.28, 1 };
local TAB_ON     = { 1, 0.82, 0 };
local TAB_OFF    = { 1, 1, 1 };

local tpTabs    = {};
local tpHeaders = {};
local tpPanes   = {};
local tpFrame;
local tpArcane;

local tpSaved = {};

local function TP_Remember(obj, kind, r, g, b, a)
	tpSaved[#tpSaved + 1] = { obj = obj, kind = kind, r = r, g = g, b = b, a = a };
end

local function TP_RestoreAll()
	for i = #tpSaved, 1, -1 do
		local s = tpSaved[i];
		if s.kind == "backdrop" then
			pcall(s.obj.SetBackdropColor, s.obj, s.r, s.g, s.b, s.a);
		elseif s.kind == "vertex" then
			pcall(s.obj.SetVertexColor, s.obj, s.r, s.g, s.b, s.a);
		elseif s.kind == "text" then
			pcall(s.obj.SetTextColor, s.obj, s.r, s.g, s.b, s.a);
		elseif s.kind == "settext" then

			s.obj.SetText = s.r;
			s.obj.nufOldSetText = nil;
		elseif s.kind == "buildtabs" then

			s.obj.BuildTabs = s.r;
			s.obj.nufOldBuildTabs = nil;
		end
		tpSaved[i] = nil;
	end
	for i = #tpTabs, 1, -1    do tpTabs[i]    = nil end
	for i = #tpHeaders, 1, -1 do tpHeaders[i] = nil end
	for i = #tpPanes, 1, -1   do tpPanes[i]   = nil end
	tpFrame  = nil;
	tpArcane = nil;
end

local function TP_TabSetText(tab, text)
	if tab.nufOldSetText then pcall(tab.nufOldSetText, tab, text); end

	if PanelTemplates_TabResize then pcall(PanelTemplates_TabResize, tab, 0); end
end

local function TP_FixTabWidth(tab)
	if tab.nufOldSetText then return end
	if type(tab.SetText) ~= "function" then return end
	tpSaved[#tpSaved + 1] = { obj = tab, kind = "settext", r = tab.SetText };
	tab.nufOldSetText = tab.SetText;
	tab.SetText = TP_TabSetText;
end

local tpW, tpRowW, tpRowE = {}, {}, {};

local function TP_Wipe(t)
	for i = #t, 1, -1 do t[i] = nil end
end

local function TP_BuildTabs(self)
	local tablist = self.tablist;
	if not tablist then return end

	local tabs     = self.tabs;
	local hastitle = (self.titletext:GetText() and self.titletext:GetText() ~= "");
	local width    = self.frame.width or self.frame:GetWidth() or 0;

	TP_Wipe(tpW); TP_Wipe(tpRowW); TP_Wipe(tpRowE);

	for i, v in ipairs(tablist) do
		local tab = tabs[i];
		if not tab then
			tab = self:CreateTab(i);
			tabs[i] = tab;
			TP_FixTabWidth(tab);
		end
		tab:Show();
		tab:SetText(v.text);
		tab:SetDisabled(v.disabled);
		tab.value = v.value;
		tpW[i] = tab:GetWidth() - 6;
	end

	for i = #tablist + 1, #tabs do
		tabs[i]:Hide();
	end

	local numtabs   = #tablist;
	local numrows   = 1;
	local usedwidth = 0;
	for i = 1, #tablist do
		if usedwidth ~= 0 and (width - usedwidth - tpW[i]) < 0 then
			tpRowW[numrows] = usedwidth + 10;
			tpRowE[numrows] = i - 1;
			numrows   = numrows + 1;
			usedwidth = 0;
		end
		usedwidth = usedwidth + tpW[i];
	end
	tpRowW[numrows] = usedwidth + 10;
	tpRowE[numrows] = #tablist;

	if numrows > 1 and tpRowE[numrows - 1] == numtabs - 1 then
		if (numrows == 2 and tpRowE[numrows - 1] > 2)
		   or (tpRowE[numrows] - tpRowE[numrows - 1] > 2) then
			if (tpRowW[numrows] + tpW[numtabs - 1]) <= width then
				tpRowE[numrows - 1] = tpRowE[numrows - 1] - 1;
				tpRowW[numrows]     = tpRowW[numrows]     + tpW[numtabs - 1];
				tpRowW[numrows - 1] = tpRowW[numrows - 1] - tpW[numtabs - 1];
			end
		end
	end

	local starttab = 1;
	for row, endtab in ipairs(tpRowE) do
		local first = true;
		for tabno = starttab, endtab do
			local tab = tabs[tabno];
			tab:ClearAllPoints();
			if first then
				tab:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0,
					-(hastitle and 14 or 7) - (row - 1) * 20);
				first = false;
			else
				tab:SetPoint("LEFT", tabs[tabno - 1], "RIGHT", -10, 0);
			end
		end

		local padding = 0;
		if not (numrows == 1 and tpRowW[1] < width * 0.75) then
			padding = (width - tpRowW[row]) / (endtab - starttab + 1);
		end

		if padding < 0 then padding = 0 end

		for i = starttab, endtab do

			if PanelTemplates_TabResize then
				pcall(PanelTemplates_TabResize, tabs[i], padding + 4);
			end
		end
		starttab = endtab + 1;
	end

	self.borderoffset = (hastitle and 17 or 10) + (numrows * 20);
	self.border:SetPoint("TOPLEFT", 1, -self.borderoffset);
end

local function TP_FixBuildTabs(obj)
	if not obj or obj.nufOldBuildTabs then return end
	if type(obj.BuildTabs) ~= "function" then return end
	tpSaved[#tpSaved + 1] = { obj = obj, kind = "buildtabs", r = obj.BuildTabs };
	obj.nufOldBuildTabs = obj.BuildTabs;
	obj.BuildTabs = TP_BuildTabs;
end

local function TP_RecolorTab(tab)
	if not tab or not tab.text then return end
	if tab.selected then
		tab.text:SetTextColor(unpack(TAB_ON))
	else
		tab.text:SetTextColor(unpack(TAB_OFF))
	end
end

local function TP_WalkTabs(f, depth)
	if not f or depth > 6 then return end
	for _, child in ipairs({ f:GetChildren() }) do
		local n = child.GetName and child:GetName()
		if n and string.find(n, "^AceGUITabGroup%d+Tab%d+$") then
			local dup = false;
			for i = 1, #tpTabs do
				if tpTabs[i] == child then dup = true; break end
			end
			if not dup then
				tpTabs[#tpTabs + 1] = child;
				if child.text then
					TP_Remember(child.text, "text", child.text:GetTextColor());
				end
				TP_FixTabWidth(child);
			end
		end
		TP_WalkTabs(child, depth + 1)
	end
end

local function TP_Collect(frame)

	TP_RestoreAll();
	tpFrame = frame
	if not frame then return end

	if frame.SetBackdropColor and frame.GetBackdropColor then
		tpPanes[#tpPanes + 1] = frame
		TP_Remember(frame, "backdrop", frame:GetBackdropColor());
	end

	for _, child in ipairs({ frame:GetChildren() }) do
		if child.GetBackdrop and child:GetBackdrop() and child.SetBackdropColor and child.GetBackdropColor then
			tpPanes[#tpPanes + 1] = child
			TP_Remember(child, "backdrop", child:GetBackdropColor());
		end
	end

	for _, r in ipairs({ frame:GetRegions() }) do
		if r.GetObjectType and r:GetObjectType() == "Texture" and r.GetTexture then
			local t = r:GetTexture()
			if type(t) == "string" and string.find(t, "UI%-DialogBox%-Header") then
				tpHeaders[#tpHeaders + 1] = r
				TP_Remember(r, "vertex", r:GetVertexColor());
			end
		end
	end

	TP_WalkTabs(frame, 0)

	local primera = tpTabs[1];
	if primera and primera.obj then
		TP_FixBuildTabs(primera.obj);
		pcall(primera.obj.BuildTabs, primera.obj);
	end
end

local function TP_Paint()
	for i = 1, #tpPanes do
		tpPanes[i]:SetBackdropColor(unpack(SKIN_BG))
	end
	for i = 1, #tpHeaders do
		tpHeaders[i]:SetVertexColor(unpack(SKIN_TITLE))
	end
	for i = 1, #tpTabs do
		TP_RecolorTab(tpTabs[i])
	end
end

local function TP_ArcaneOn()
	local p = NidhausPlatesTheme and NidhausPlatesTheme.db and NidhausPlatesTheme.db.profile
	return (p and p.arcaneSkin) and true or false
end

local function TP_CurrentFrame()
	local acd = LibStub and LibStub("AceConfigDialog-3.0", true)
	local w = acd and acd.OpenFrames and acd.OpenFrames["Nidhaus Plates"]
	return w and w.frame
end

local function TP_SkinWindow()
	local frame = TP_CurrentFrame()
	if not frame then return end
	TP_Collect(frame)
	tpArcane = TP_ArcaneOn()
	if not tpArcane then TP_Paint() end
end

local tpSkinTimer = CreateFrame("Frame")
tpSkinTimer:Hide()
tpSkinTimer:SetScript("OnUpdate", function(self)
	local frame = TP_CurrentFrame()

	if not frame or not frame:IsShown() then
		self:Hide()

		TP_RestoreAll()
		return
	end

	local arcane = TP_ArcaneOn()
	if frame ~= tpFrame or arcane ~= tpArcane then
		TP_Collect(frame)
		tpArcane = arcane
	end
	if not arcane then TP_Paint() end
end)

function NidhausPlatesTheme:OpenOptions()
	HideUIPanel(InterfaceOptionsFrame)
	HideUIPanel(GameMenuFrame)
	if not options then
		NidhausPlatesTheme:SetUpOptions()
	end
	LibStub("AceConfigDialog-3.0"):Open("Nidhaus Plates")

	TP_SkinWindow()
	tpSkinTimer:Show()
end

function NidhausPlatesTheme:ChatCommand(input)
	NidhausPlatesTheme:OpenOptions()
end

function NidhausPlatesTheme:ConfigRefresh()
	db = self.db.profile
	Update()
end

function NidhausPlatesTheme:SetUpInitialOptions()
	self:RegisterChatCommand("tptp", "ChatCommand")
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Nidhaus Plates Dialog", GetIntOptions)

	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(
		"Nidhaus Plates Dialog", NidhausPlatesTheme.DISPLAY_NAME)
end

function NidhausPlatesTheme:SetUpOptions()
	db = self.db.profile

	GetOptions()
	UpdateSpecial()

	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	options.args.profiles.order = 10000

	if LDS then LDS:EnhanceOptions(options.args.profiles, self.db) end

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Nidhaus Plates", options)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize("Nidhaus Plates", 750, 600)
end
