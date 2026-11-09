local APP = "Nidhaus Plates"

local T = {
	frameBG      = {0.028, 0.048, 0.095, 0.97},
	frameBorder  = {0.22,  0.52,  0.92,  0.95},

	panelBG      = {0.00,  0.00,  0.00,  0.35},
	panelBorder  = {0.20,  0.48,  0.85,  0.55},

	titleBG      = {0.035, 0.065, 0.140, 1.00},
	titleBorder  = {0.28,  0.68,  1.00,  1.00},

	tabSelBG     = {0.075, 0.145, 0.270, 0.97},
	tabSelBorder = {0.32,  0.72,  1.00,  1.00},
	tabBG        = {0.038, 0.075, 0.145, 0.85},
	tabBorder    = {0.16,  0.38,  0.68,  0.70},

	textSel      = {1.00,  1.00,  1.00},

	textOff      = {1.00,  1.00,  1.00},

	panelBG2     = {0.00,  0.00,  0.00,  0.12},
	panelBGIn    = {0.00,  0.00,  0.00,  0.00},

	tabSelText   = {1.00,  0.82,  0.00},

	titleText    = {1.00,  0.82,  0.00},
	subText      = {0.67,  0.67,  0.67},
	verText      = {1.00,  0.67,  0.00},

	accent       = {0.25,  0.66,  1.00},
}

local HEADER = "Interface\\DialogFrame\\UI-DialogBox-Header"

local SUBTITULO = "Nameplate Customization & Threat Tools"

local function VersionTexto()
	local v = GetAddOnMetadata and GetAddOnMetadata("Nidhaus_Plates", "Version")
	if type(v) ~= "string" or v == "" then return nil end
	return "v" .. v
end

local BD_FINO = {
	bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 12,
	insets = {left = 3, right = 3, top = 3, bottom = 3},
}

local BD_MARCO_TITULO = {
	bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}

local BD_MARCO = {
	bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = {left = 5, right = 5, top = 5, bottom = 5},
}

local orig     = {};
local origList = {};

local function Rec(obj)
	local e = orig[obj]
	if not e then
		e = {}
		orig[obj] = e
		origList[#origList + 1] = obj
	end
	return e
end

local function GuardarFondo(f)
	if not f then return end
	local e = Rec(f)
	if e.fondo == nil and f.GetBackdrop then
		e.fondo = f:GetBackdrop() or false
	end
	if not e.colorFondo and f.GetBackdropColor then
		e.colorFondo = { f:GetBackdropColor() }
	end
	if not e.colorBorde and f.GetBackdropBorderColor then
		e.colorBorde = { f:GetBackdropBorderColor() }
	end
end

local function GuardarTextura(t)
	if not t then return end
	local e = Rec(t)
	if e.textura == nil and t.GetTexture then e.textura = t:GetTexture() or false end
	if not e.vertice and t.GetVertexColor then e.vertice = { t:GetVertexColor() } end
end

local function GuardarTexto(fs)
	if not fs then return end
	local e = Rec(fs)
	if not e.colorTexto and fs.GetTextColor then e.colorTexto = { fs:GetTextColor() } end

	if e.texto == nil and fs.GetText then e.texto = fs:GetText() or false end
	if e.fuente == nil and fs.GetFontObject then e.fuente = fs:GetFontObject() or false end
	if not e.puntos and fs.GetNumPoints then
		local ps = {}
		for i = 1, fs:GetNumPoints() do ps[#ps + 1] = { fs:GetPoint(i) } end
		e.puntos = ps
	end
end

local function GuardarNivel(f)
	if not f then return end
	local e = Rec(f)
	if e.nivel == nil and f.GetFrameLevel then e.nivel = f:GetFrameLevel() end
end

local cajas    = {};
local marcados = {};
local marcos   = {};
local arboles  = {};

local FUENTE_BLANCA = CreateFont("NidhausPlatesTreeFont")
FUENTE_BLANCA:SetFontObject(GameFontNormal)
FUENTE_BLANCA:SetTextColor(1, 1, 1)

local function Restaurar()
	for i = #origList, 1, -1 do
		local o = origList[i]
		local e = orig[o]
		if e then

			if e.fondo ~= nil and o.SetBackdrop then
				pcall(o.SetBackdrop, o, e.fondo or nil)
			end
			if e.colorFondo and o.SetBackdropColor then
				pcall(o.SetBackdropColor, o, unpack(e.colorFondo))
			end
			if e.colorBorde and o.SetBackdropBorderColor then
				pcall(o.SetBackdropBorderColor, o, unpack(e.colorBorde))
			end
			if e.textura ~= nil and o.SetTexture then
				pcall(o.SetTexture, o, e.textura or nil)
			end
			if e.vertice and o.SetVertexColor then
				pcall(o.SetVertexColor, o, unpack(e.vertice))
			end

			if e.fuente and o.SetFontObject then
				pcall(o.SetFontObject, o, e.fuente)
			end
			if e.colorTexto and o.SetTextColor then
				pcall(o.SetTextColor, o, unpack(e.colorTexto))
			end
			if e.texto ~= nil and o.SetText then
				pcall(o.SetText, o, e.texto or "")
			end
			if e.puntos and o.ClearAllPoints and #e.puntos > 0 then
				pcall(o.ClearAllPoints, o)
				for _, pt in ipairs(e.puntos) do pcall(o.SetPoint, o, unpack(pt)) end
			end
			if e.nivel ~= nil and o.SetFrameLevel then
				pcall(o.SetFrameLevel, o, e.nivel)
			end
		end
		orig[o] = nil
		origList[i] = nil
	end

	for i = #cajas, 1, -1 do
		if cajas[i] then pcall(cajas[i].Hide, cajas[i]) end
		cajas[i] = nil
	end

	for i = #marcados, 1, -1 do
		if marcados[i] then marcados[i].nufStripped = nil end
		marcados[i] = nil
	end
	for i = #marcos, 1, -1 do
		if marcos[i] then marcos[i].nufBackdrop = nil end
		marcos[i] = nil
	end

	for i = #arboles, 1, -1 do
		local b = arboles[i]
		if b and b.nufFuente then
			b.nufFuente = nil
			pcall(b.SetNormalFontObject, b, GameFontNormal)
		end
		arboles[i] = nil
	end
end

local function EstaActivo()
	local db = NidhausPlatesTheme and NidhausPlatesTheme.db and NidhausPlatesTheme.db.profile
	return db and db.arcaneSkin
end

local function Activa()
	if not EstaActivo() then return false end
	local ACD = LibStub and LibStub("AceConfigDialog-3.0", true)
	local w = ACD and ACD.OpenFrames and ACD.OpenFrames[APP]
	return (w and w.frame and w.frame:IsShown()) and true or false
end

local function Pintar(frame, bg, borde)
	if not frame or not frame.GetBackdrop or not frame:GetBackdrop() then return end
	GuardarFondo(frame)
	frame:SetBackdropColor(bg[1], bg[2], bg[3], bg[4] or 1)
	if frame.SetBackdropBorderColor then
		frame:SetBackdropBorderColor(borde[1], borde[2], borde[3], borde[4] or 1)
	end
end

local function ColorearPestana(tab)
	local caja = tab.nufCaja
	if not caja then return end
	if tab.text then GuardarTexto(tab.text) end
	if tab.selected then
		Pintar(caja, T.tabSelBG, T.tabSelBorder)
		if tab.text then tab.text:SetTextColor(unpack(T.tabSelText)) end
	else
		Pintar(caja, T.tabBG, T.tabBorder)
		if tab.text then tab.text:SetTextColor(unpack(T.textOff)) end
	end
end

local function VestirPestana(tab)

	if not tab.nufStripped then
		for _, region in ipairs({tab:GetRegions()}) do
			if region.GetObjectType and region:GetObjectType() == "Texture" then
				GuardarTextura(region)
				region:SetTexture(nil)
			end
		end
		tab.nufStripped = true
		marcados[#marcados + 1] = tab
	end
	if not tab.text then tab.text = _G[(tab:GetName() or "") .. "Text"] end
	if not tab.nufCaja then

		local caja = CreateFrame("Frame", nil, tab:GetParent())
		caja:SetPoint("TOPLEFT", tab, "TOPLEFT", 5, -2)
		caja:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", -5, 2)
		caja:SetBackdrop(BD_FINO)
		caja:SetFrameLevel(math.max(0, tab:GetFrameLevel() - 1))
		caja.nufTabBox = true
		tab.nufCaja = caja

		tab:HookScript("OnClick", function(self)

			if not Activa() then return end

			for _, otra in ipairs(self.nufHermanas or {}) do ColorearPestana(otra) end
			ColorearPestana(self)
		end)
	end

	tab.nufCaja:Show()
	cajas[#cajas + 1] = tab.nufCaja
	ColorearPestana(tab)
end

local function Tenir(textura)
	if textura and textura.SetVertexColor then
		GuardarTextura(textura)
		textura:SetVertexColor(T.accent[1], T.accent[2], T.accent[3])
	end
end

local function EsDorado(fs)
	local r, g, b = fs:GetTextColor()
	return r and r > 0.95 and g > 0.78 and g < 0.86 and b < 0.05
end

local function VestirSlider(s)
	if s.GetBackdrop and s:GetBackdrop() then
		Pintar(s, T.panelBG, T.panelBorder)
	end
	Tenir(s.GetThumbTexture and s:GetThumbTexture())

	local padre = s:GetParent()
	if padre and padre.GetRegions then
		for _, r in ipairs({ padre:GetRegions() }) do
			if r.GetObjectType and r:GetObjectType() == "FontString" and EsDorado(r) then
				GuardarTexto(r)
				r:SetTextColor(unpack(T.textSel))
			end
		end
	end
end

local function VestirDesplegable(d)
	local n = d:GetName()
	for _, sufijo in ipairs({"Left", "Middle", "Right"}) do
		Tenir(_G[n .. sufijo])
	end
	local texto = _G[n .. "Text"]
	if texto then GuardarTexto(texto); texto:SetTextColor(unpack(T.textSel)) end
	local boton = _G[n .. "Button"]
	if boton then
		Tenir(boton.GetNormalTexture and boton:GetNormalTexture())
		Tenir(boton.GetPushedTexture and boton:GetPushedTexture())
	end
end

local function NombreDe(f)
	return (f.GetName and f:GetName()) or nil
end

local function EsPestana(f)
	local n = NombreDe(f)
	return n and n:find("^AceGUITabGroup%d+Tab%d+$") ~= nil
end

local function EsDesplegable(f)
	local n = NombreDe(f)
	return n and n:find("^AceGUI30DropDown%d+$") ~= nil
end

local function EsBotonArbol(f)
	local n = NombreDe(f)
	return n and n:find("^AceGUI30TreeButton%d+$") ~= nil
end

local function EsNuestro(btn)
	if not Activa() then return false end
	local ACD = LibStub("AceConfigDialog-3.0", true)
	local w = ACD and ACD.OpenFrames and ACD.OpenFrames[APP]
	local raiz = w and w.frame
	local f = btn
	for _ = 1, 20 do
		f = f and f.GetParent and f:GetParent()
		if not f then return false end
		if f == raiz then return true end
	end
	return false
end

local function Blanquear(btn, seguro)
	local dorada = seguro
	if not dorada then
		if btn.GetNormalFontObject then
			dorada = (btn:GetNormalFontObject() == GameFontNormal)
		else
			local fs = btn.GetFontString and btn:GetFontString()
			dorada = fs and EsDorado(fs)
		end
	end
	if dorada then
		btn:SetNormalFontObject(FUENTE_BLANCA)
		if not btn.nufFuente then
			btn.nufFuente = true
			arboles[#arboles + 1] = btn
		end
	end
end

local function VestirBotonArbol(btn)
	if not btn.nufGancho then
		btn.nufGancho = true

		hooksecurefunc(btn, "SetNormalFontObject", function(self, fuente)
			if fuente ~= "GameFontNormal" and fuente ~= GameFontNormal then return end
			if EsNuestro(self) then Blanquear(self, true) end
		end)
	end
	Blanquear(btn)
end

local pestanas = {}

local function FondoPorNivel(cajasArriba)
	if cajasArriba <= 0 then return T.panelBG end
	if cajasArriba == 1 then return T.panelBG2 end
	return T.panelBGIn
end

local function Recorrer(frame, profundidad, cajasArriba)
	if profundidad > 14 then return end
	cajasArriba = cajasArriba or 0
	local hijos = { frame:GetChildren() }
	for i = 1, #hijos do
		local hijo = hijos[i]
		local esCaja = false
		if hijo then
			local tipo = hijo.GetObjectType and hijo:GetObjectType()
			if EsPestana(hijo) then
				pestanas[#pestanas + 1] = hijo
				VestirPestana(hijo)
			elseif EsDesplegable(hijo) then
				VestirDesplegable(hijo)
			elseif EsBotonArbol(hijo) then
				VestirBotonArbol(hijo)
			elseif tipo == "Slider" then
				VestirSlider(hijo)
			elseif hijo.nufTabBox or hijo.nufTitulo then

			elseif hijo.GetBackdrop and hijo:GetBackdrop() then

				local alpha
				local e = orig[hijo]
				if e and e.colorFondo then
					alpha = e.colorFondo[4]
				elseif hijo.GetBackdropColor then
					local _, _, _, a = hijo:GetBackdropColor()
					alpha = a
				end
				if alpha == nil or alpha > 0 then
					Pintar(hijo, FondoPorNivel(cajasArriba), T.panelBorder)
					esCaja = true
				end
			end
			if hijo.GetNumChildren then
				Recorrer(hijo, profundidad + 1, cajasArriba + (esCaja and 1 or 0))
			end
		end
	end
end

local function QuitarCabeceraDorada(frame)
	for _, region in ipairs({frame:GetRegions()}) do
		if region.GetTexture and region:GetTexture() == HEADER then
			GuardarTextura(region)
			region:SetTexture(nil)
		end
	end
end

local function Vestir(widget)
	if not widget or not widget.frame then return end
	local frame = widget.frame

	GuardarFondo(frame)
	if not frame.nufBackdrop then
		frame:SetBackdrop(BD_MARCO)
		frame.nufBackdrop = true
		marcos[#marcos + 1] = frame
	end
	Pintar(frame, T.frameBG, T.frameBorder)
	QuitarCabeceraDorada(frame)

	local nivel = frame:GetFrameLevel()

	if not frame.nufTitleBar then
		local barra = CreateFrame("Frame", nil, frame)
		barra:SetPoint("TOP", frame, "TOP", 0, 12)

		barra:SetHeight(30)

		barra:SetBackdrop(BD_MARCO_TITULO)

		barra.nufTitulo = true
		frame.nufTitleBar = barra
	end
	frame.nufTitleBar:SetFrameLevel(nivel + 4)
	Pintar(frame.nufTitleBar, T.titleBG, T.titleBorder)
	frame.nufTitleBar:Show()

	if widget.titletext then

		GuardarTexto(widget.titletext)
		widget.titletext:SetFontObject(GameFontNormalLarge)

		local crudo  = widget.titletext:GetText() or ""
		local limpio = string.gsub(crudo, "|c%x%x%x%x%x%x%x%x", "")
		limpio = string.gsub(limpio, "|r", "")
		limpio = string.gsub(limpio, "_", " ")
		if limpio ~= "" then widget.titletext:SetText(limpio) end
		widget.titletext:SetTextColor(unpack(T.titleText))

		local anchoMarco = (frame.GetWidth and frame:GetWidth()) or 700
		local ancho = anchoMarco * 0.61
		if ancho < 300 then ancho = 300 end
		frame.nufTitleBar:SetWidth(ancho)

		widget.titletext:ClearAllPoints()

		widget.titletext:SetPoint("CENTER", frame.nufTitleBar, "CENTER", 0, 2)

		local soporte = widget.titletext.GetParent and widget.titletext:GetParent()
		if soporte and soporte.SetFrameLevel then
			GuardarNivel(soporte)
			soporte:SetFrameLevel(nivel + 5)
		end
	end

	if frame.nufTitleBar then
		if not frame.nufSubtitle then
			frame.nufSubtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		end
		frame.nufSubtitle:SetText(SUBTITULO)
		frame.nufSubtitle:ClearAllPoints()
		frame.nufSubtitle:SetPoint("TOP", frame.nufTitleBar, "BOTTOM", 0, -2)
		frame.nufSubtitle:SetTextColor(unpack(T.subText))
		frame.nufSubtitle:Show()
	end

	local ver = VersionTexto()
	if ver then
		if not frame.nufVersion then
			frame.nufVersion = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		end
		frame.nufVersion:SetText(ver)
		frame.nufVersion:ClearAllPoints()
		frame.nufVersion:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -32, -14)
		frame.nufVersion:SetTextColor(unpack(T.verText))
		frame.nufVersion:Show()
	end

	if not frame.nufClose then
		local x = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
		x:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
		x:SetScript("OnClick", function()
			local ACD = LibStub and LibStub("AceConfigDialog-3.0", true)
			if ACD then ACD:Close(APP) end
		end)
		frame.nufClose = x
	end
	frame.nufClose:SetFrameLevel(nivel + 5)
	frame.nufClose:Show()

	for i = #pestanas, 1, -1 do pestanas[i] = nil end

	for i = #cajas, 1, -1 do cajas[i] = nil end
	if frame.nufTitleBar  then cajas[#cajas + 1] = frame.nufTitleBar  end
	if frame.nufSubtitle  then cajas[#cajas + 1] = frame.nufSubtitle  end
	if frame.nufVersion   then cajas[#cajas + 1] = frame.nufVersion   end
	if frame.nufClose     then cajas[#cajas + 1] = frame.nufClose     end
	Recorrer(frame, 1, 0)

	for _, tab in ipairs(pestanas) do tab.nufHermanas = pestanas end
end

local vigilante = CreateFrame("Frame")
local pendiente = false

local function Aplicar()
	local ACD = LibStub and LibStub("AceConfigDialog-3.0", true)
	if not ACD or not ACD.OpenFrames then return end
	local widget = ACD.OpenFrames[APP]
	if not widget then return end
	if EstaActivo() then
		Vestir(widget)
	else

		Restaurar()
	end
end

do
	local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
	if AceGUI and type(AceGUI.Create) == "function" then
		hooksecurefunc(AceGUI, "Create", function() pendiente = true end)
	end
end

vigilante:SetScript("OnUpdate", function(self)
	local ACD = LibStub and LibStub("AceConfigDialog-3.0", true)
	local w = ACD and ACD.OpenFrames and ACD.OpenFrames[APP]
	if not w or not w.frame or not w.frame:IsShown() then
		pendiente = false

		if #origList > 0 or #cajas > 0 or #arboles > 0 then Restaurar() end
		return
	end
	if not pendiente then return end
	pendiente = false
	Aplicar()
end)

local enganchado = false
local arranque = CreateFrame("Frame")
arranque:RegisterEvent("PLAYER_LOGIN")
arranque:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_LOGIN")
	if enganchado then return end
	local ACD = LibStub and LibStub("AceConfigDialog-3.0", true)
	if not ACD or not ACD.Open then return end
	hooksecurefunc(ACD, "Open", function(_, appName)
		if appName == APP then Aplicar() end
	end)
	enganchado = true
end)

NidhausPlatesTheme = NidhausPlatesTheme or {}
NidhausPlatesTheme.RefreshArcaneSkin = Aplicar
