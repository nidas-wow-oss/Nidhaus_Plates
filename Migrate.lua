local ADDON = "Nidhaus_Plates"
local hecho = false

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

	if type(ThreatPlatesDB) == "table" then
		if type(NidhausPlatesDB) ~= "table" then
			NidhausPlatesDB = ThreatPlatesDB
			Corregir(NidhausPlatesDB, {})
		end
		ThreatPlatesDB = nil
	end

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
