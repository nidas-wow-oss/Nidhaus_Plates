--[[ Comandos sueltos de Threat Plates ]] --
local L = LibStub("AceLocale-3.0"):GetLocale("TidyPlatesThreat", false)

-- =========================================================
-- Build simplificada: se quitaron /tptptank, /tptpdps y /tptptoggle.
--
-- Servian para forzar a mano el modo tanque o dps, que es lo que decide
-- si la escala de colores de amenaza va al derecho o al reves. Ya no hacen
-- falta: Core.lua detecta el rol solo a partir de los talentos y alinea
-- db.char.threat.tanking al entrar al juego y en cada cambio de spec
-- (ver currentRoleBool), y Functions.lua lo hace por forma en druidas.
-- Los comandos solo pisaban esa deteccion hasta el proximo login.
-- =========================================================

-- Alterna la CVar de Blizzard que decide si las nameplates se pueden
-- superponer. Apagada, el juego las separa y quedan corridas de la unidad;
-- prendida, cada una queda justo sobre la suya aunque se tapen entre si.
local function TPTPOVERLAP()
	SetCVar("nameplateAllowOverlap", abs(GetCVar("nameplateAllowOverlap") - 1))
	-- Es un comando que se escribe a mano, asi que siempre contesta: sin
	-- respuesta no hay forma de saber en que quedo. Antes el aviso se
	-- colaba dentro del if de verbose y, con verbose apagado, decia
	-- siempre "ON" aunque lo acabaras de apagar.
	if GetCVar("nameplateAllowOverlap") == "0" then
		print(L["-->>Nameplate Overlapping is now |cffff0000OFF!|r<<--"])
	else
		print(L["-->>Nameplate Overlapping is now |cff00ff00ON!|r<<--"])
	end
end
SLASH_TPTPOVERLAP1 = "/tptpol"
SlashCmdList["TPTPOVERLAP"] = TPTPOVERLAP

-- Prende o apaga los mensajes que el addon escribe en el chat: avisos de
-- cambio de spec, de rol detectado, etc.
local function TPTPVERBOSE()
	TidyPlatesThreat.db.profile.verbose = not TidyPlatesThreat.db.profile.verbose
	if TidyPlatesThreat.db.profile.verbose then
		print(L["-->>Threat Plates verbose is now |cff00ff00ON!|r<<--"])
	else
		print(L["-->>Threat Plates verbose is now |cffff0000OFF!|r<<-- shhh!!"])
	end
end
SLASH_TPTPVERBOSE1 = "/tptpverbose"
SlashCmdList["TPTPVERBOSE"] = TPTPVERBOSE
