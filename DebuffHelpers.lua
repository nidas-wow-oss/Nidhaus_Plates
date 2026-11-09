----------------------------------
-- Ayudantes del filtro de debuffs
--
-- Es lo unico que quedaba en uso de los paneles viejos de configuracion
-- (los "Hub" de tanque y de dano, que se cargaban ocultos sin servir para
-- nada): los prefijos de la lista de debuffs ("My", "All", "CC"...) y la
-- regla que aplica cada uno. Lo lee Theme\Widgets\Widgets.lua.
----------------------------------
local PrefixList = {
	["ALL"] = 1, ["All"] = 1, ["all"] = 1,
	["MY"] = 2, ["My"] = 2, ["my"] = 2,
	["NO"] = 3, ["No"] = 3, ["no"] = 3,
	["CC"] = 4, ["cc"] = 4,
	["OTHER"] = 5, ["Other"] = 5, ["other"] = 5
}

-- El GUID del jugador no cambia en la sesion: se pide una vez y se guarda.
local playerGUID
local function PlayerGUID()
	if not playerGUID then
		playerGUID = UnitGUID("player")
	end
	return playerGUID
end

local CCSpells = NidhausPlatesWidgets and NidhausPlatesWidgets.CCSpells

-- Mismo orden que PrefixList: 1 All, 2 My, 3 No, 4 CC, 5 Other.
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
