local L = LibStub("AceLocale-3.0"):GetLocale("NidhausPlatesTheme", false)

local function TPTPOVERLAP()
	SetCVar("nameplateAllowOverlap", abs(GetCVar("nameplateAllowOverlap") - 1))

	if GetCVar("nameplateAllowOverlap") == "0" then
		print(L["-->>Nameplate Overlapping is now |cffff0000OFF!|r<<--"])
	else
		print(L["-->>Nameplate Overlapping is now |cff00ff00ON!|r<<--"])
	end
end
SLASH_TPTPOVERLAP1 = "/tptpol"
SlashCmdList["TPTPOVERLAP"] = TPTPOVERLAP

local function TPTPVERBOSE()
	NidhausPlatesTheme.db.profile.verbose = not NidhausPlatesTheme.db.profile.verbose
	if NidhausPlatesTheme.db.profile.verbose then
		print(L["-->>Nidhaus Plates verbose is now |cff00ff00ON!|r<<--"])
	else
		print(L["-->>Nidhaus Plates verbose is now |cffff0000OFF!|r<<-- shhh!!"])
	end
end
SLASH_TPTPVERBOSE1 = "/tptpverbose"
SlashCmdList["TPTPVERBOSE"] = TPTPVERBOSE
