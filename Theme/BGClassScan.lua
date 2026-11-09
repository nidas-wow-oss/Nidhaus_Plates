local anadidos = {}
local enBG = false
local acumulado = 0
local PERIODO = 10

local POR_NOMBRE = {}
do
	local listas = {LOCALIZED_CLASS_NAMES_MALE, LOCALIZED_CLASS_NAMES_FEMALE}
	for _, lista in ipairs(listas) do
		if type(lista) == "table" then
			for token, traducido in pairs(lista) do
				POR_NOMBRE[traducido] = token
			end
		end
	end
end

local function TokenDeClase(clase, token)
	if token and RAID_CLASS_COLORS and RAID_CLASS_COLORS[token] then
		return token
	end
	if clase and RAID_CLASS_COLORS and RAID_CLASS_COLORS[clase] then
		return clase
	end
	return POR_NOMBRE[clase]
end

local function NombreCorto(nombre)
	if not nombre then return nil end
	return nombre:match("([^%-]+).*") or nombre
end

local function Escanear()
	local db = NidhausPlatesTheme and NidhausPlatesTheme.db and NidhausPlatesTheme.db.profile
	if not db or not db.cache then return 0 end

	local nuevos = 0
	for i = 1, (GetNumBattlefieldScores() or 0) do
		local nombre, _, _, _, _, _, _, _, clase, token = GetBattlefieldScore(i)
		nombre = NombreCorto(nombre)
		if nombre and not db.cache[nombre] then
			local eng = TokenDeClase(clase, token)
			if eng then
				db.cache[nombre] = eng
				anadidos[nombre] = true
				nuevos = nuevos + 1
			end
		end
	end
	return nuevos
end

local function Limpiar()
	local db = NidhausPlatesTheme and NidhausPlatesTheme.db and NidhausPlatesTheme.db.profile
	if db and db.cache and not db.cacheClass then
		for nombre in pairs(anadidos) do
			db.cache[nombre] = nil
		end
	end
	for nombre in pairs(anadidos) do anadidos[nombre] = nil end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

f:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		local _, tipo = IsInInstance()
		if tipo == "pvp" then
			if not enBG then
				enBG = true
				acumulado = PERIODO
				self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
			end
		elseif enBG then
			enBG = false
			self:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
			Limpiar()
		end
	elseif event == "UPDATE_BATTLEFIELD_SCORE" then

		Escanear()
	end
end)

f:SetScript("OnUpdate", function(self, elapsed)
	if not enBG then return end
	acumulado = acumulado + (elapsed or 0)
	if acumulado < PERIODO then return end
	acumulado = 0
	RequestBattlefieldScoreData()
end)

SLASH_NPBGCLASES1 = "/npclases"
SlashCmdList["NPBGCLASES"] = function()
	RequestBattlefieldScoreData()
	local n = Escanear()
	local total = 0
	local db = NidhausPlatesTheme and NidhausPlatesTheme.db and NidhausPlatesTheme.db.profile
	if db and db.cache then
		for _ in pairs(db.cache) do total = total + 1 end
	end
	print(string.format("|cff4FC3F7Nidhaus_Plates:|r %d clases nuevas, %d en cache.", n, total))
end
