local PrefixList = {
	["ALL"] = 1, ["All"] = 1, ["all"] = 1,
	["MY"] = 2, ["My"] = 2, ["my"] = 2,
	["NO"] = 3, ["No"] = 3, ["no"] = 3,
	["CC"] = 4, ["cc"] = 4,
	["OTHER"] = 5, ["Other"] = 5, ["other"] = 5
}

local playerGUID
local function PlayerGUID()
	if not playerGUID then
		playerGUID = UnitGUID("player")
	end
	return playerGUID
end

local CCSpells = NidhausPlatesWidgets and NidhausPlatesWidgets.CCSpells

local DebuffPrefixModes = {
	function(debuff) return true end,
	function(debuff) return (debuff.caster == PlayerGUID()) or nil end,
	function(debuff) return nil end,
	function(debuff) return CCSpells and CCSpells[debuff.name] or nil end,
	function(debuff) return (debuff.caster ~= PlayerGUID()) end
}

NidhausPlatesDebuffHelpers = {
	PrefixList = PrefixList,
	PlayerGUID = PlayerGUID,
	DebuffPrefixModes = DebuffPrefixModes,
}
