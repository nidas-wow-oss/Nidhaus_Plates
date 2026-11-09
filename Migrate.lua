-- =========================================================
-- Migrate.lua
--
-- Pasa las opciones guardadas de los nombres viejos a los nuevos:
--   ThreatPlatesDB    -> NidhausPlatesDB      (el perfil entero)
--   TidyPlatesOptions -> NidhausPlatesOptions (opciones del motor, por PJ)
--
-- Tiene que correr ANTES de que AceDB abra NidhausPlatesDB. El evento
-- ADDON_LOADED no alcanza solo: AceAddon es una libreria compartida y su
-- marco puede haberse registrado antes que el nuestro, asi que su
-- OnInitialize llegaria primero. Por eso Theme\Core.lua tambien la llama al
-- principio de OnInitialize. Es idempotente: la segunda vez no hace nada.
-- =========================================================

local ADDON = "Nidhaus_Plates"
local hecho = false

-- La textura de barra se guarda por su nombre en SharedMedia; el nombre
-- cambio, asi que se corrige donde aparezca dentro del perfil.
local RENOMBRES = {
	["ThreatPlatesBar"] = "NidhausPlatesBar",
	["Threat Plates"]   = "Nidhaus Plates",
}

local function Corregir(t, vistos)
	if type(t) ~= "table" or vistos[t] then return end
	vistos[t] = true
	for k, v in pairs(t) do
		if type(v) == "string" and RENOMBRES[v] then
			t[k] = RENOMBRES[v]
		elseif type(v) == "table" then
			Corregir(v, vistos)
		end
	end
end

function NidhausPlates_Migrate()
	if hecho then return end
	hecho = true

	-- Perfil principal: solo si todavia no hay uno con el nombre nuevo, para
	-- no pisar nunca una configuracion ya migrada.
	if type(ThreatPlatesDB) == "table" then
		if type(NidhausPlatesDB) ~= "table" then
			NidhausPlatesDB = ThreatPlatesDB
			Corregir(NidhausPlatesDB, {})
		end
		ThreatPlatesDB = nil
	end

	-- Opciones del motor. NidhausPlatesOptions ya existe con los valores de
	-- fabrica (lo crea PlatesPanel.lua al cargar); se le copian encima los
	-- guardados.
	if type(TidyPlatesOptions) == "table" then
		if type(NidhausPlatesOptions) ~= "table" then NidhausPlatesOptions = {} end
		if not NidhausPlatesOptions.migrated then
			for k, v in pairs(TidyPlatesOptions) do
				NidhausPlatesOptions[k] = v
			end
			Corregir(NidhausPlatesOptions, {})
			NidhausPlatesOptions.migrated = true
		end
		TidyPlatesOptions = nil
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, _, name)
	if name ~= ADDON then return end
	self:UnregisterEvent("ADDON_LOADED")
	NidhausPlates_Migrate()
end)
