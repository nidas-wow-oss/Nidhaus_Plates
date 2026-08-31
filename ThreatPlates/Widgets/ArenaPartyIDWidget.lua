-- =========================================================
-- ArenaPartyIDWidget.lua
--
-- Pinta sobre la placa el numero de la unidad:
--   * rivales de arena  -> 1 a 5   (arena1 .. arena5)
--   * miembros de grupo -> 1 a 4   (party1 .. party4)
--
-- Portado de RefinedBlizzPlates (de Khal), que resuelve esto de la forma
-- correcta para 3.3.5: no hay manera de preguntarle a una placa a que unidad
-- pertenece, asi que se construye un mapa NOMBRE -> NUMERO recorriendo las
-- unidades conocidas, y despues cada placa busca su propio nombre ahi.
--
-- El mapa se rehace solo cuando cambia el grupo o aparecen rivales, no en
-- cada refresco de placa: son como mucho nueve unidades, pero el update de
-- placas corre muchas veces por segundo y no hay por que repetirlo.
-- =========================================================

local ArenaID = {}   -- nombre -> "1".."5"
local PartyID = {}   -- nombre -> "1".."4"

local wipe, tostring = wipe, tostring
local UnitName, UnitExists = UnitName, UnitExists
local GetNumPartyMembers = GetNumPartyMembers

-- Los nombres de otros reinos llegan como "Nombre-Reino"; las placas solo
-- muestran la parte de delante, asi que se recorta para que casen.
local function ShortName(name)
	if not name then return nil end
	return name:match("([^%-]+).*") or name
end

local function UpdatePartyID()
	wipe(PartyID)
	for i = 1, (GetNumPartyMembers() or 0) do
		local name = ShortName(UnitName("party" .. i))
		if name then PartyID[name] = tostring(i) end
	end
end

local function UpdateArenaID()
	wipe(ArenaID)
	-- GetNumArenaOpponents no existe en todos los clientes 3.3.5; se recorre
	-- arena1..5 a mano, que funciona igual y no depende de esa API.
	for i = 1, 5 do
		local unidad = "arena" .. i
		if UnitExists(unidad) then
			local name = ShortName(UnitName(unidad))
			if name then ArenaID[name] = tostring(i) end
		end
	end
end

-- Expuesto para poder probarlo y para que el panel refresque al vuelo.
ThreatPlatesWidgets = ThreatPlatesWidgets or {}
ThreatPlatesWidgets.ArenaPartyID_Refresh = function()
	UpdatePartyID()
	UpdateArenaID()
end
ThreatPlatesWidgets.ArenaPartyID_Maps = function() return ArenaID, PartyID end

local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_ENTERING_WORLD")
ev:RegisterEvent("PARTY_MEMBERS_CHANGED")
ev:RegisterEvent("RAID_ROSTER_UPDATE")
ev:RegisterEvent("ARENA_OPPONENT_UPDATE")
ev:RegisterEvent("UNIT_NAME_UPDATE")
ev:SetScript("OnEvent", function(self, event)
	if event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
		UpdatePartyID()
	elseif event == "ARENA_OPPONENT_UPDATE" then
		UpdateArenaID()
	else
		UpdatePartyID()
		UpdateArenaID()
	end
end)

local ANCHORS = {
	Left   = {"RIGHT", "LEFT",  -4,  0},
	Center = {"CENTER", "CENTER", 0,  0},
	Right  = {"LEFT",  "RIGHT",   4,  0},
	Top    = {"BOTTOM", "TOP",    0,  2},
	Bottom = {"TOP",   "BOTTOM",  0, -2},
}

local function Colocar(frame, db)
	local a = ANCHORS[db.anchor] or ANCHORS.Right
	frame.Text:ClearAllPoints()
	frame.Text:SetPoint(a[1], frame:GetParent(), a[2],
		a[3] + (db.x or 0), a[4] + (db.y or 0))
end

local function AplicarFuente(frame, db)
	local fuente = "Fonts\\FRIZQT__.TTF"
	-- Si LibSharedMedia esta cargada se respeta la fuente elegida; si no,
	-- se usa la de Blizzard en vez de quedarse sin texto.
	local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
	if LSM and db.font then
		fuente = LSM:Fetch("font", db.font) or fuente
	end
	local contorno = db.outline
	if contorno == "None" or contorno == "" then contorno = nil end
	frame.Text:SetFont(fuente, db.size or 12, contorno)
end

local function UpdateArenaPartyIDWidget(frame, unit)
	local db = TidyPlatesThreat.db.profile.arenaPartyIDWidget
	if not db or not db.ON or not unit or not unit.name then
		frame:Hide()
		return
	end

	local texto
	if db.showArena and unit.reaction ~= "FRIENDLY" then
		texto = ArenaID[unit.name]
	end
	if not texto and db.showParty and unit.reaction == "FRIENDLY" then
		texto = PartyID[unit.name]
	end

	if not texto then
		frame:Hide()
		return
	end

	AplicarFuente(frame, db)
	Colocar(frame, db)
	if db.useClassColor and unit.class and RAID_CLASS_COLORS[unit.class] then
		local c = RAID_CLASS_COLORS[unit.class]
		frame.Text:SetTextColor(c.r, c.g, c.b, 1)
	else
		local c = db.color or {r = 1, g = 0.82, b = 0}
		frame.Text:SetTextColor(c.r, c.g, c.b, 1)
	end
	frame.Text:SetText(texto)
	frame:Show()
end

local function CreateArenaPartyIDWidget(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetWidth(24)
	frame:SetHeight(16)
	frame.Text = frame:CreateFontString(nil, "OVERLAY")
	frame.Text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
	frame.Text:SetJustifyH("CENTER")
	frame:Hide()
	frame.Update = UpdateArenaPartyIDWidget
	return frame
end

ThreatPlatesWidgets.CreateArenaPartyIDWidget = CreateArenaPartyIDWidget
