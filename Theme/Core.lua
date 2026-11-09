local ADDON_NAME = ...

NidhausPlatesTheme = LibStub("AceAddon-3.0"):NewAddon("NidhausPlatesTheme", "AceConsole-3.0", "AceEvent-3.0")

NidhausPlatesTheme.DISPLAY_NAME = "|cffffffffNidhaus|r|cff00ff00_Plates|r"
local L = LibStub("AceLocale-3.0"):GetLocale("NidhausPlatesTheme", false)
local LDS = LibStub("LibDualSpec-1.0", true)
local DB

local PlayerClass = select(2, UnitClass("player"))
local Active = function()
	return GetActiveTalentGroup()
end
local HEX_CLASS_COLOR = {
	SHAMAN = "2459FF",
	MAGE = "69CCF0",
	WARLOCK = "9482C9",
	HUNTER = "ABD473",
	ROGUE = "FFF569",
	PRIEST = "FFFFFF",
	DRUID = "FF7D0A",
	DEATHKNIGHT = "C41F3B",
	WARRIOR = "C79C6E",
	PALADIN = "F58CBA"
}

NidhausPlatesThemeList = NidhausPlatesThemeList or {}
NidhausPlatesThemeList["Nidhaus Plates"] = {}

function NidhausPlatesTheme:ProfChange()
	if NidhausPlates_RefreshLightBorder then NidhausPlates_RefreshLightBorder() end
	if NidhausPlatesTheme.ApplySimpleLayout then
		NidhausPlatesTheme.ApplySimpleLayout()
	end
	if NidhausPlatesTheme.RebuildUniqueList then
		NidhausPlatesTheme.RebuildUniqueList()
	end
	NidhausPlatesTheme:ConfigRefresh()
end

function NidhausPlatesTheme:OnInitialize()

	if NidhausPlates_Migrate then NidhausPlates_Migrate() end
	local defaults = {
		char = {
			welcome = false,
			specInfo = {
				[1] = {[1] = 0, [2] = 0, [3] = 0},
				[2] = {[1] = 0, [2] = 0, [3] = 0}
			},
			threat = {tanking = false},
			spec = {primary = false, secondary = false},
			specName = {[1] = nil, [2] = nil, [3] = nil},
			stances = {
				ON = false,
				[0] = false,
				[1] = false,
				[2] = true,
				[3] = false
			},
			shapeshifts = {
				ON = false,
				[0] = false,
				[1] = true,
				[2] = false,
				[3] = false,
				[4] = false,
				[5] = false,
				[6] = false
			},
			presences = {
				ON = false,
				[0] = false,
				[1] = true,
				[2] = false,
				[3] = false
			},
			auras = {
				ON = false,
				[0] = false,
				[1] = true,
				[2] = false,
				[3] = false,
				[4] = false,
				[5] = false
			}
		},
		profile = {
			cache = {},

			OldSetting = false,
			verbose = true,
			blizzFade = {toggle = true, amount = -0.3},
			healthColorChange = false,
			customColor = false,
			allowClass = true,
			arcaneSkin = true,
			hideSnakes = true,
			hideSnakesFriendly = true,
			hideMirrorImage = true,
			lightBorder = false,
			lightCast   = false,
			castbarCVarInit = false,
			roundTarget = false,
			friendlyClass = false,
			friendlyNameOnly = false,
			friendlyClickThrough = false,
			friendlyClassIcon = false,
			cacheClass = false,
			castbarColor = {toggle = true, r = 1, g = 0.56, b = 0.06, a = 1},
			castbarColorShield = {toggle = true, r = 1, g = 0, b = 0, a = 1},
			aHPbarColor = {r = 0, g = 1, b = 0},
			bHPbarColor = {r = 1, g = 0, b = 0},
			fHPbarColor = {r = 1, g = 1, b = 1},
			nHPbarColor = {r = 1, g = 1, b = 1},
			HPbarColor = {r = 1, g = 1, b = 1},
			tHPbarColor = {r = 0, g = 0.5, b = 1},
			totemSettings = {
				hideHealthbar = false,

				["A1"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.67, g = 1, b = 1}},
				["A2"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.67, g = 1, b = 1}},
				["A3"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.67, g = 1, b = 1}},
				["A4"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.67, g = 1, b = 1}},
				["A5"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.67, g = 1, b = 1}},
				["A6"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.67, g = 1, b = 1}},

				["E1"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.7, b = 0.12}},
				["E2"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.7, b = 0.12}},
				["E3"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.7, b = 0.12}},
				["E4"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.7, b = 0.12}},
				["E5"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.7, b = 0.12}},
				["E6"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.7, b = 0.12}},

				["F1"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.4, b = 0.4}},
				["F2"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.4, b = 0.4}},
				["F3"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.4, b = 0.4}},
				["F4"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.4, b = 0.4}},
				["F5"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.4, b = 0.4}},
				["F6"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.4, b = 0.4}},

				["W1"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.58, g = 0.72, b = 1}},
				["W2"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.58, g = 0.72, b = 1}},
				["W3"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.58, g = 0.72, b = 1}},
				["W4"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.58, g = 0.72, b = 1}},
				["W5"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.58, g = 0.72, b = 1}}
			},
			uniqueSettings = {
				list = {},
				["**"] = {
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
				},
				[1] = {
					name = L["Shadow Fiend"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U1",
					scale = 0.45,
					alpha = 1,
					color = {r = 0.61, g = 0.40, b = 0.86}
				},
				[2] = {
					name = L["Spirit Wolf"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U2",
					scale = 0.45,
					alpha = 1,
					color = {r = 0.32, g = 0.7, b = 0.89}
				},
				[3] = {
					name = L["Ebon Gargoyle"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U3",
					scale = 0.45,
					alpha = 1,
					color = {r = 1, g = 0.71, b = 0}
				},
				[4] = {
					name = L["Water Elemental"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U4",
					scale = 0.45,
					alpha = 1,
					color = {r = 0.33, g = 0.72, b = 0.44}
				},
				[5] = {
					name = L["Treant"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U5",
					scale = 0.45,
					alpha = 1,
					color = {r = 1, g = 0.71, b = 0}
				},
				[6] = {
					name = L["Viper"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U6",
					scale = 0.45,
					alpha = 1,
					color = {
						r = 0.39,
						g = 1,
						b = 0.11
					}
				},
				[7] = {
					name = L["Venomous Snake"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U6",
					scale = 0.45,
					alpha = 1,
					color = {r = 0.75, g = 0, b = 0.02}
				},
				[8] = {
					name = L["Army of the Dead Ghoul"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U7",
					scale = 0.45,
					alpha = 1,
					color = {r = 0.87, g = 0.78, b = 0.88}
				},
				[9] = {
					name = L["Shadowy Apparition"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U8",
					scale = 1,
					alpha = 1,
					color = {r = 0.62, g = 0.19, b = 1}
				},
				[10] = {
					name = L["Shambling Horror"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U9",
					scale = 1,
					alpha = 1,
					color = {r = 0.69, g = 0.26, b = 0.25}
				},
				[11] = {
					name = L["Web Wrap"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U10",
					scale = 0.75,
					alpha = 1,
					color = {r = 1, g = 0.39, b = 0.96}
				},
				[12] = {
					name = L["Immortal Guardian"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U11",
					scale = 1,
					alpha = 1,
					color = {r = 0.33, g = 0.33, b = 0.33}
				},
				[13] = {
					name = L["Marked Immortal Guardian"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U12",
					scale = 1,
					alpha = 1,
					color = {r = 0.75, g = 0, b = 0.02}
				},
				[14] = {
					name = L["Empowered Adherent"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U13",
					scale = 1,
					alpha = 1,
					color = {r = 0.29, g = 0.11, b = 1}
				},
				[15] = {
					name = L["Deformed Fanatic"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U14",
					scale = 1,
					alpha = 1,
					color = {r = 0.55, g = 0.7, b = 0.29}
				},
				[16] = {
					name = L["Reanimated Adherent"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U15",
					scale = 1,
					alpha = 1,
					color = {r = 1, g = 0.88, b = 0.61}
				},
				[17] = {
					name = L["Reanimated Fanatic"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U15",
					scale = 1,
					alpha = 1,
					color = {r = 1, g = 0.88, b = 0.61}
				},
				[18] = {
					name = L["Bone Spike"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U16",
					scale = 1,
					alpha = 1,
					color = {r = 1, g = 1, b = 1}
				},
				[19] = {
					name = L["Onyxian Whelp"],
					showNameplate = false,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U17",
					scale = 1,
					alpha = 1,
					color = {r = 0.33, g = 0.28, b = 0.71}
				},
				[20] = {
					name = L["Gas Cloud"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U18",
					scale = 1,
					alpha = 1,
					color = {r = 0.96, g = 0.56, b = 0.07}
				},
				[21] = {
					name = L["Volatile Ooze"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U19",
					scale = 1,
					alpha = 1,
					color = {r = 0.36, g = 0.95, b = 0.33}
				},
				[22] = {
					name = L["Darnavan"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U20",
					scale = 1,
					alpha = 1,
					color = {r = 0.78, g = 0.61, b = 0.43}
				},
				[23] = {
					name = L["Val'kyr Shadowguard"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U21",
					scale = 1,
					alpha = 1,
					color = {r = 0.47, g = 0.89, b = 1}
				},
				[24] = {
					name = L["Kinetic Bomb"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U22",
					scale = 1,
					alpha = 1,
					color = {r = 0.91, g = 0.71, b = 0.1}
				},
				[25] = {
					name = L["Lich King"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U23",
					scale = 1,
					alpha = 1,
					color = {r = 0.77, g = 0.12, b = 0.23}
				},
				[26] = {
					name = L["Raging Spirit"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U24",
					scale = 1,
					alpha = 1,
					color = {r = 0.77, g = 0.27, b = 0}
				},
				[27] = {
					name = L["Drudge Ghoul"],
					showNameplate = true,
					showIcon = false,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U25",
					scale = 0.85,
					alpha = 1,
					color = {r = 0.43, g = 0.43, b = 0.43}
				},
				[28] = {
					name = L["Living Inferno"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U27",
					scale = 1,
					alpha = 1,
					color = {r = 0, g = 1, b = 0}
				},
				[29] = {
					name = L["Living Ember"],
					showNameplate = true,
					showIcon = false,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\UniqueIconWidget\\U28",
					scale = 0.60,
					alpha = 0.75,
					color = {r = 0.25, g = 0.25, b = 0.25}
				},
				[30] = {
					name = L["Fanged Pit Viper"],
					showNameplate = false,
					showIcon = false,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "",
					scale = 0,
					alpha = 0,
					color = {r = 1, g = 1, b = 1}
				},

				[31] = {
					name = L["Mirror Image"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Icons\\Spell_Magic_LesserInvisibilty",
					scale = 0.45,
					alpha = 1,
					color = {r = 0.41, g = 0.80, b = 0.94}
				},
				[32] = {},
				[33] = {},
				[34] = {},
				[35] = {},
				[36] = {},
				[37] = {},
				[38] = {},
				[39] = {},
				[40] = {},
				[41] = {},
				[42] = {},
				[43] = {},
				[44] = {},
				[45] = {},
				[46] = {},
				[47] = {},
				[48] = {},
				[49] = {},
				[50] = {}
			},
			text = {
				amount = true,
				percent = true,
				full = false,
				max = false,
				deficit = false,
				truncate = true
			},
			totemWidget = {
				ON = true,
				scale = 35,
				x = 0,
				y = 35,
				level = 1,
				anchor = "CENTER",
				border = true,
				targetGlow = true,
			},
			debuffWidget = {
				ON = true,
				x = 18,
				y = 32,
				mode = "whitelist",
				scale = 1,
				anchor = "CENTER",
				filter = {}
			},
			uniqueWidget = {
				ON = true,
				scale = 35,
				x = 0,
				y = 35,
				level = 1,
				anchor = "CENTER"
			},
			classWidget = {
				ON = true,
				scale = 15,
				x = -59,
				y = 0,
				theme = "default",
				anchor = "CENTER",

				border = true,
				borderThickness = 1,

				borderColor = {r = 0, g = 0, b = 0},
				borderColorTarget = {r = 1, g = 1, b = 1}
			},
			targetWidget = {
				ON = true,
				theme = "default",
				width = 30,
				height = 30,
				r = 1,
				g = 1,
				b = 1,
				a = 1
			},
			threatWidget = {
				ON = false,
				x = 0,
				y = 26,
				anchor = "CENTER"
			},
			tankedWidget = {
				ON = false,
				scale = 16,
				x = 65,
				y = 6,
				anchor = "CENTER"
			},
			comboWidget = {
				ON = false,
				scale = 64,
				x = 0,
				y = -8
			},
			eliteWidget = {
				ON = true,
				theme = "default",
				scale = 15,
				x = 64,
				y = 9,
				anchor = "CENTER"
			},
			socialWidget = {
				ON = false,
				scale = 16,
				x = 65,
				y = 6,
				anchor = "CENTER"
			},

			arenaPartyIDWidget = {
				ON = false,
				showArena = true,
				showParty = true,
				font = "Arial Narrow",
				size = 12,
				outline = "OUTLINE",
				anchor = "Right",
				x = 0,
				y = 0,
				useClassColor = false,
				color = {r = 1, g = 0.82, b = 0}
			},
			clickthrough = {
				friendly = false,
				enemy = false,
			},
			settings = {
				frame = {
					y = 15
				},
				highlight = {
					texture = "TP_HealthBarHighlight"
				},
				target = {
					texture = "TP_HealthBarHighlight"
				},
				elitehealthborder = {
					texture = "TP_HealthBarEliteOverlay",
					show = true
				},
				healthborder = {
					texture = "TP_HealthBarOverlayThin",
					backdrop = "",
					show = true
				},
				threatborder = {
					show = false
				},
				healthbar = {
					texture = "NidhausPlatesBar",
					width = 100,
					height = 10
				},
				castnostop = {
					texture = "TP_CastBarLock",
					x = 0,
					y = -15,
					show = true
				},
				castborder = {
					texture = "TP_CastBarOverlay",
					x = 0,
					y = -15,
					show = true
				},
				castbar = {
					texture = "NidhausPlatesBar",
					x = 0,
					y = -15,
					show = true
				},
				name = {
					typeface = "Accidental Presidency",
					width = 116,
					height = 14,
					size = 14,
					x = 0,
					y = 13,
					align = "CENTER",
					vertical = "CENTER",
					shadow = true,
					flags = "NONE",
					color = {
						r = 1,
						g = 1,
						b = 1
					},
					show = true
				},
				level = {
					typeface = "Accidental Presidency",
					size = 12,
					width = 20,
					height = 14,
					x = 50,
					y = 0,
					align = "RIGHT",
					vertical = "TOP",
					shadow = true,
					flags = "NONE",
					show = false
				},
				eliteicon = {
					show = true,
					theme = "default",
					scale = 15,
					x = 64,
					y = 9,
					level = 22,
					anchor = "CENTER"
				},
				customtext = {
					typeface = "Accidental Presidency",
					size = 12,
					width = 110,
					height = 14,
					x = 0,
					y = 1,
					align = "CENTER",
					vertical = "CENTER",
					shadow = true,
					flags = "NONE",
					show = false
				},
				spelltext = {
					typeface = "Accidental Presidency",
					size = 12,
					width = 110,
					height = 14,
					x = 0,
					y = -13,
					align = "CENTER",
					vertical = "CENTER",
					shadow = true,
					flags = "NONE",
					show = true
				},
				raidicon = {
					scale = 20,
					x = 0,
					y = 27,
					anchor = "CENTER",
					hpColor = false,
					show = true,
					hpMarked = {
						STAR = {r = 0.85, g = 0.81, b = 0.27},
						MOON = {r = 0.60, g = 0.75, b = 0.85},
						CIRCLE = {r = 0.93, g = 0.51, b = 0.06},
						SQUARE = {r = 0, g = 0.64, b = 1},
						DIAMOND = {r = 0.7, g = 0.06, b = 0.84},
						CROSS = {r = 0.82, g = 0.18, b = 0.18},
						TRIANGLE = {r = 0.14, g = 0.66, b = 0.14},
						SKULL = {r = 0.89, g = 0.83, b = 0.74}
					}
				},
				spellicon = {
					scale = 20,
					x = 75,
					y = -7,
					anchor = "CENTER",
					show = true
				},
				customart = {
					scale = 22,
					x = -74,
					y = -7,
					anchor = "CENTER",
					show = true
				},
				skullicon = {
					scale = 16,
					x = 55,
					y = 0,
					anchor = "CENTER",
					show = true
				},
				unique = {
					threatcolor = {
						LOW = {r = 0, g = 0, b = 0, a = 0},
						MEDIUM = {r = 0, g = 0, b = 0, a = 0},
						HIGH = {r = 0, g = 0, b = 0, a = 0}
					}
				},
				totem = {
					threatcolor = {
						LOW = {r = 0, g = 0, b = 0, a = 0},
						MEDIUM = {r = 0, g = 0, b = 0, a = 0},
						HIGH = {r = 0, g = 0, b = 0, a = 0}
					}
				},
				normal = {
					threatcolor = {
						LOW = {r = 1, g = 1, b = 1, a = 1},
						MEDIUM = {r = 1, g = 1, b = 0, a = 1},
						HIGH = {r = 1, g = 0, b = 0, a = 1}
					}
				},
				dps = {
					threatcolor = {
						LOW = {r = 0, g = 1, b = 0, a = 1},
						MEDIUM = {r = 1, g = 1, b = 0, a = 1},
						HIGH = {r = 1, g = 0, b = 0, a = 1}
					}
				},
				tank = {
					threatcolor = {
						LOW = {r = 1, g = 0, b = 0, a = 1},
						MEDIUM = {r = 1, g = 1, b = 0, a = 1},
						HIGH = {r = 0, g = 1, b = 0, a = 1}
					}
				}
			},
			threat = {

				ON = false,
				nonCombat = true,
				hideNonCombat = false,
				useType = true,
				useScale = true,
				useAlpha = true,
				useHPColor = true,
				art = {
					ON = true,
					theme = "default"
				},
				scaleType = {
					["Normal"] = -0.2,
					["Elite"] = 0,
					["Boss"] = 0.2
				},
				toggle = {
					["Boss"] = true,
					["Elite"] = true,
					["Normal"] = true,
					["Neutral"] = true
				},
				dps = {
					scale = {
						LOW = 0.8,
						MEDIUM = 0.9,
						HIGH = 1.25
					},
					alpha = {
						LOW = 1,
						MEDIUM = 1,
						HIGH = 1
					}
				},
				tank = {
					scale = {
						LOW = 1.25,
						MEDIUM = 0.9,
						HIGH = 0.8
					},
					alpha = {
						LOW = 1,
						MEDIUM = 0.85,
						HIGH = 0.75
					}
				},
				marked = {
					alpha = false,
					art = false,
					scale = false
				}
			},
			nameplate = {
				toggle = {
					["Boss"] = true,
					["Elite"] = true,
					["Normal"] = true,
					["Neutral"] = true
				},
				scale = {
					["Totem"] = 0.75,
					["Boss"] = 1.1,
					["Elite"] = 1.04,
					["Normal"] = 1,
					["Target"] = 1.1,
					["Neutral"] = 0.9,
					["Marked"] = 1
				},
				alpha = {
					["Totem"] = 1,
					["Boss"] = 1,
					["Elite"] = 1,
					["Normal"] = 1,
					["Neutral"] = 1,
					["Marked"] = 1
				}
			}
		}
	}
	local db = LibStub("AceDB-3.0"):New("NidhausPlatesDB", defaults, "Default")
	self.db = db

	local SIMPLE_LAYOUT_VERSION = 6
	NidhausPlatesTheme.ApplySimpleLayout = function()
		local p = NidhausPlatesTheme.db and NidhausPlatesTheme.db.profile
		if not p or p.simpleLayout == SIMPLE_LAYOUT_VERSION then return end
		p.simpleLayout = SIMPLE_LAYOUT_VERSION
		p.settings.healthbar.width = 100
		p.settings.frame.y = 15
		p.settings.level.show = false
		p.settings.customtext.show = false
		p.settings.raidicon.hpColor = false
		p.settings.healthborder.texture = "TP_HealthBarOverlayThin"
		p.settings.threatborder.show = false
		p.customColor = false
		p.allowClass = true
		p.nameplate.scale["Target"] = 1.1
		p.hideSnakes         = true
		p.hideSnakesFriendly = true
		p.hideMirrorImage    = true

		if p.threat then p.threat.ON = false end
		p.OldSetting = false

		local c = NidhausPlatesTheme.db.char
		if c then
			c.spec.primary = false
			c.spec.secondary = false
			c.threat.tanking = false
			for _, k in ipairs({"auras", "stances", "shapeshifts", "presences"}) do
				if c[k] then c[k].ON = false end
			end
		end
	end
	NidhausPlatesTheme.ApplySimpleLayout()

	NidhausPlatesTheme.RebuildUniqueList = function()
		local p = NidhausPlatesTheme.db and NidhausPlatesTheme.db.profile
		if not p or not p.uniqueSettings then return end
		p.uniqueSettings.list = {}
		for k, v in pairs(p.uniqueSettings) do
			if k ~= "list" and type(v) == "table" and type(v.name) == "string" then
				p.uniqueSettings.list[k] = v.name
			end
		end
	end
	NidhausPlatesTheme.RebuildUniqueList()

	if LDS then LDS:EnhanceDatabase(self.db, "Nidhaus Plates") end

	local RegisterCallback = db.RegisterCallback

	RegisterCallback(self, "OnProfileChanged", "ProfChange")
	RegisterCallback(self, "OnProfileCopied", "ProfChange")
	RegisterCallback(self, "OnProfileReset", "ProfChange")

	local function FrozenCopy(src, seen)
		if type(src) ~= "table" then return src end
		seen = seen or {}
		if seen[src] then return seen[src] end
		local out = {}
		seen[src] = out
		for k, v in pairs(src) do out[k] = FrozenCopy(v, seen) end
		local mt = getmetatable(src)
		if mt then setmetatable(out, mt) end
		return out
	end
	RegisterCallback("NidhausPlates_Shutdown", "OnDatabaseShutdown", function(_, which)
		if which and which ~= db then return end

		if db.profile then db.profile.cache = {} end
		NidhausPlatesTheme.db = {
			profile = FrozenCopy(db.profile),
			char    = FrozenCopy(db.char),
		}
	end)

	self:SetUpInitialOptions()
end

local UnitInGroup = NidhausPlatesUtility.UnitInGroup
local TotemNameFallback = NidhausPlatesUtility.TotemNameFallback

function NidhausPlatesTheme.UnitType(unit)
	DB = NidhausPlatesTheme.db.profile
	local totem = TPtotemList[unit.name] or TPtotemList[TotemNameFallback(unit.name)]

	if totem then
		return "Totem"
	end

	local unique = tContains(DB.uniqueSettings.list, unit.name)
	if unique then
		for k_c, k_v in pairs(DB.uniqueSettings.list) do
			if k_v == unit.name then
				if DB.uniqueSettings[k_c].useStyle then
					return "Unique"
				else
					if (unit.isDangerous and (unit.reaction == "FRIENDLY" or unit.reaction == "HOSTILE")) then
						return "Boss"
					elseif (unit.isElite and not unit.isDangerous and (unit.reaction == "FRIENDLY" or unit.reaction == "HOSTILE")) then
						return "Elite"
					elseif (not unit.isElite and not unit.isDangerous and (unit.reaction == "FRIENDLY" or unit.reaction == "HOSTILE")) then
						return "Normal"
					elseif unit.reaction == "NEUTRAL" then
						return "Neutral"
					end
				end
			end
		end
	end

	if (tContains(DB.uniqueSettings.list, "GROUP") and unit.name and UnitInGroup(unit.name)) then
		if DB.friendlyNameOnly then
			return "Normal", true
		end
		for k_c, k_v in pairs(DB.uniqueSettings.list) do
			if k_v == "GROUP" then
				if DB.uniqueSettings[k_c].useStyle then
					return "Unique", true
				else
					return "Normal", true
				end
			end
		end
	end

	if (unit.isDangerous and (unit.reaction == "FRIENDLY" or unit.reaction == "HOSTILE")) then
		return "Boss"
	end

	if (unit.isElite and not unit.isDangerous and (unit.reaction == "FRIENDLY" or unit.reaction == "HOSTILE")) then
		return "Elite"
	end

	if (not unit.isElite and not unit.isDangerous and (unit.reaction == "FRIENDLY" or unit.reaction == "HOSTILE")) then
		return "Normal"
	end

	if unit.reaction == "NEUTRAL" then
		return "Neutral"
	end

	return "Normal"
end

local ACCENTS = {
	["á"]="a", ["à"]="a", ["ä"]="a", ["â"]="a", ["ã"]="a",
	["é"]="e", ["è"]="e", ["ë"]="e", ["ê"]="e",
	["í"]="i", ["ì"]="i", ["ï"]="i", ["î"]="i",
	["ó"]="o", ["ò"]="o", ["ö"]="o", ["ô"]="o", ["õ"]="o",
	["ú"]="u", ["ù"]="u", ["ü"]="u", ["û"]="u",
	["ñ"]="n", ["ç"]="c",
	["Á"]="a", ["À"]="a", ["Ä"]="a", ["Â"]="a", ["Ã"]="a",
	["É"]="e", ["È"]="e", ["Ë"]="e", ["Ê"]="e",
	["Í"]="i", ["Ì"]="i", ["Ï"]="i", ["Î"]="i",
	["Ó"]="o", ["Ò"]="o", ["Ö"]="o", ["Ô"]="o", ["Õ"]="o",
	["Ú"]="u", ["Ù"]="u", ["Ü"]="u", ["Û"]="u",
	["Ñ"]="n", ["Ç"]="c",
}

local function Normalize(name)
	if type(name) ~= "string" then return nil end
	name = string.gsub(name, "[\194-\244][\128-\191]", function(ch)
		return ACCENTS[ch] or ch
	end)
	return string.lower(name)
end

local HIDE_SNAKES = {}
local HIDE_MIRROR = {}

local function AddNames(t, ...)
	for i = 1, select("#", ...) do
		local n = Normalize((select(i, ...)))
		if n then t[n] = true end
	end
end

AddNames(HIDE_SNAKES,
	"Viper",  "Venomous Snake",
	"Vibora", "Culebra venenosa",
	"Serpiente venenosa",
	"Vipere", "Serpent venimeux",
	"Giftschlange",
	"Cobra venenosa")

AddNames(HIDE_MIRROR,
	"Mirror Image",
	"Imagen especular",
	"Image miroir",
	"Spiegelbild")

do
	local n = GetSpellInfo(55342)
	if n then AddNames(HIDE_MIRROR, n) end
end

local MIRROR_IMAGE_SPELLID = 55342
local MIRROR_WINDOW        = 35
local PLAYER_SEEN_WINDOW   = 30

local cloneOwners = {}

local function NoteName(name, ttl)
	local n = Normalize(name)
	if not n then return false end
	local expires = GetTime() + ttl
	if (cloneOwners[n] or 0) >= expires then return false end
	local isNew = (cloneOwners[n] == nil)
	cloneOwners[n] = expires
	return isNew
end

local function IsCloneOwner(name)
	local n = Normalize(name)
	if not n then return false end
	local t = cloneOwners[n]
	if not t then return false end
	if GetTime() > t then
		cloneOwners[n] = nil
		return false
	end
	return true
end

local mirrorWatch = CreateFrame("Frame")
mirrorWatch:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
mirrorWatch:SetScript("OnEvent", function(self, event, timestamp, subEvent,
		srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId)
	if subEvent ~= "SPELL_CAST_SUCCESS" and subEvent ~= "SPELL_SUMMON" then return end
	if tonumber(spellId) ~= MIRROR_IMAGE_SPELLID then return end
	local db = NidhausPlatesTheme.db and NidhausPlatesTheme.db.profile
	if not db or not db.hideMirrorImage then return end
	if NoteName(srcName, MIRROR_WINDOW) then

		if NidhausPlates and NidhausPlates.ForceUpdate then
			pcall(NidhausPlates.ForceUpdate, NidhausPlates)
		end
	end
end)

local ROSTER_UNITS = {
	"arena1", "arena2", "arena3", "arena4", "arena5",
	"target", "focus", "mouseover",
	"party1", "party2", "party3", "party4",
}
local rosterStamp = 0

local function RefreshRosterNames()
	local now = GetTime()
	if now - rosterStamp < 1 then return end
	rosterStamp = now
	for i = 1, #ROSTER_UNITS do
		local u = ROSTER_UNITS[i]

		if UnitExists(u) and UnitIsPlayer(u) then
			local n = UnitName(u)
			if n then NoteName(n, PLAYER_SEEN_WINDOW) end
		end
	end
end

local nameKind = {}
local function KindOf(name)
	local kind = nameKind[name]
	if kind == nil then
		local n = Normalize(name)
		kind = (n and ((HIDE_SNAKES[n] and "snake") or (HIDE_MIRROR[n] and "mirror"))) or false
		nameKind[name] = kind
	end
	return kind
end

function NidhausPlatesTheme.IsNameHidden(name, reaction, unitType)
	if not name then return false end
	local db = NidhausPlatesTheme.db and NidhausPlatesTheme.db.profile
	if not db then return false end

	local kind = KindOf(name)

	if not kind and db.hideMirrorImage and unitType == "NPC"
		and IsCloneOwner(name) then
		return true
	end

	if not kind then return false end
	if kind == "snake" then

		if reaction == "FRIENDLY" then
			return db.hideSnakesFriendly and true or false
		end
		return db.hideSnakes and true or false
	end
	if kind == "mirror" then
		return db.hideMirrorImage and true or false
	end
	return false
end

function NidhausPlatesTheme.SetStyle(unit)
	DB = NidhausPlatesTheme.db.profile

	if unit.type == "PLAYER" and unit.name then
		NoteName(unit.name, PLAYER_SEEN_WINDOW)
	end
	RefreshRosterNames()

	if NidhausPlatesTheme.IsNameHidden(unit.name, unit.reaction, unit.type) then
		return "empty"
	end

	local T, custom = NidhausPlatesTheme.UnitType(unit)
	if T == "Totem" then
		local tS = DB.totemSettings[TPtotemList[unit.name] or TPtotemList[TotemNameFallback(unit.name)]]
		if tS[1] then
			if DB.totemSettings.hideHealthbar then
				return "etotem"
			else
				return "totem"
			end
		else
			return "empty"
		end
	elseif T == "Unique" then
		for k_c, k_v in pairs(DB.uniqueSettings.list) do
			if custom and k_v == "GROUP" then
				if DB.friendlyNameOnly then
					return "text"
				elseif DB.uniqueSettings[k_c].showNameplate then
					return "unique", true
				else
					return "empty", true
				end
			elseif k_v == unit.name then
				if DB.uniqueSettings[k_c].showNameplate then
					return "unique"
				else
					return "empty"
				end
			end
		end
	elseif T then
		if unit.reaction == "HOSTILE" or unit.reaction == "NEUTRAL" then
			if DB.nameplate.toggle[T] then
				if DB.threat.toggle[T] and DB.threat.ON and unit.class == "UNKNOWN" and InCombatLockdown() then
					if DB.threat.nonCombat then
						if unit.isInCombat or (unit.health < unit.healthmax) then
							if NidhausPlatesTheme.db.char.threat.tanking then
								return "tank"
							else
								return "dps"
							end
						else
							if not DB.threat.hideNonCombat then
								return "normal"
							else
								return "empty"
							end
						end
					else
						if NidhausPlatesTheme.db.char.threat.tanking then
							return "tank"
						else
							return "dps"
						end
					end
				else
					return "normal"
				end
			else
				return "empty"
			end
		elseif unit.reaction == "FRIENDLY" then
			if DB.friendlyNameOnly then
				return "text"
			elseif DB.nameplate.toggle[T] then
				return "normal"
			else
				return "empty"
			end
		else
			return "empty"
		end
	else
		return "empty"
	end
end

function NidhausPlatesTheme.HitboxOverride(unit, stylename)
	if stylename ~= "etotem" then return end
	local p = NidhausPlatesTheme.db and NidhausPlatesTheme.db.profile
	local tw = p and p.totemWidget
	if not (tw and tw.ON) then return end
	local lado = (tw.scale or 35) * 1.2
	return lado, lado
end

local function ShowConfigPanel()
	NidhausPlatesTheme:OpenOptions()
end

function NidhausPlatesTheme:StartUp()
	if not self.db.char.welcome then
		self.db.char.welcome = true

		if not NidhausPlatesTheme.db.profile.castbarCVarInit then
			NidhausPlatesTheme.db.profile.castbarCVarInit = true
			if GetCVar("ShowVKeyCastbar") ~= "1" then
				SetCVar("ShowVKeyCastbar", "1")
			end
		end

		if GetCVar("ShowVKeyCastbar") == "1" then
			NidhausPlatesTheme.db.profile.settings.castbar.show = true
		else
			NidhausPlatesTheme.db.profile.settings.castbar.show = false
		end
	end
end

local f = CreateFrame("Frame")
local function EventHandler(self, event, ...)
	DB = NidhausPlatesTheme.db.profile
	local CharDB = NidhausPlatesTheme.db.char
	local arg1, arg2 = ...
	if event == "ADDON_LOADED" then
		if arg1 == ADDON_NAME then
			local setup = {
				SetStyle = NidhausPlatesTheme.SetStyle,
				SetScale = NidhausPlatesTheme.SetScale,
				SetAlpha = NidhausPlatesTheme.SetAlpha,
				SetCustomText = NidhausPlatesTheme.SetCustomText,
				SetNameColor = NidhausPlatesTheme.SetNameColor,
				SetThreatColor = NidhausPlatesTheme.SetThreatColor,
				SetCastbarColor = NidhausPlatesTheme.SetCastbarColor,
				SetHealthbarColor = NidhausPlatesTheme.SetHealthbarColor,
				HitboxOverride = NidhausPlatesTheme.HitboxOverride,
				ShowConfigPanel = ShowConfigPanel
			}
			NidhausPlatesThemeList["Nidhaus Plates"] = setup
		end
		f:UnregisterEvent("ADDON_LOADED")
	elseif event == "PLAYER_LOGIN" then
		NidhausPlatesTheme:StartUp()
		CharDB.threat.tanking = false
		if GetCVar("nameplateShowEnemyTotems") == "1" then
			DB.nameplate.toggle["Totem"] = true
		else
			DB.nameplate.toggle["Totem"] = false
		end
		SetCVar("ShowClassColorInNameplate", 1)

		if CharDB.welcome and ((NidhausPlatesOptions.primary == "Nidhaus Plates") or (NidhausPlatesOptions.secondary == "Nidhaus Plates")) and DB.verbose then
			print(L["|cff89f559Nidhaus Plates:|r Welcome back |cff"] .. HEX_CLASS_COLOR[PlayerClass] .. UnitName("player") .. "|r!!")
		end

	elseif event == "PLAYER_ENTERING_WORLD" then
		local iType = select(2, IsInInstance())
		if iType == "arena" or iType == "pvp" then
			DB.threat.ON = false
		elseif iType == "party" or iType == "raid" or iType == "none" then
			DB.threat.ON = DB.OldSetting
		end
		DB.cache = {}
	elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
		if DB.threat.ON and (GetCVar("threatWarning") ~= 3) then
			SetCVar("threatWarning", 3)
		elseif not DB.threat.ON and (GetCVar("threatWarning") ~= 0) then
			SetCVar("threatWarning", 0)
		end
	elseif event == "PLAYER_LOGOUT" then
		DB.cache = {}
	elseif event == "RAID_TARGET_UPDATE" then
		NidhausPlates:Update()
	end
end
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LOGOUT")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("RAID_TARGET_UPDATE")
f:SetScript("OnEvent", EventHandler)
