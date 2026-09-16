-- =========================================================
-- ArcaneSkin.lua
--
-- Viste la ventana de opciones con el tema "Arcane" de Nidhaus_UnitFrames:
-- casi negro azulado, bordes azules y fondos interiores muy transparentes.
--
-- POR QUE NO SE TOCA AceGUI DIRECTAMENTE
-- --------------------------------------
-- Diez addons instalados traen su propia copia de AceGUI-3.0 (BigDebuffs,
-- Icicle, Mapster, PlateBuffs, RefinedBlizzPlates...) y WoW carga UNA sola,
-- la de version mas alta, compartida por todos. Parchear la libreria o sus
-- widgets repintaria las ventanas de TODOS esos addons, incluidos los que no
-- hay que tocar.
--
-- Por eso el tema se aplica sobre la ventana concreta que abre este addon,
-- buscandola en AceConfigDialog.OpenFrames, y baja solo por SUS hijos.
-- =========================================================

local APP = "Tidy Plates: Threat Plates"

-- Paleta del tema ArcaneBlue de NUF (ThemeManager.lua).
--
-- panelBG va casi transparente a proposito: es lo que hace que se vea el
-- juego por detras, que era la diferencia gorda con NUF. Alli las cajas
-- interiores usan negro al 35% y por eso respira; aqui estaban al 92% y
-- quedaban macizas.
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
	textOff      = {0.62,  0.76,  0.92},

	-- Azul de acento de NUF. Con el se tiñen las piezas cuya FORMA hay que
	-- conservar (agarres de deslizador, flechas de desplegable), en vez de
	-- quitarles la textura como a las pestañas.
	accent       = {0.25,  0.66,  1.00},
}

local HEADER = "Interface\\DialogFrame\\UI-DialogBox-Header"

local BD_FINO = {
	bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 12,
	insets = {left = 3, right = 3, top = 3, bottom = 3},
}

-- Backdrop del marco principal, copiado tal cual del tema Arcane de NUF.
--
-- Esto era lo que hacia que el fondo se viera distinto aunque el color fuese
-- el mismo: AceGUI usa la textura de piedra de UI-DialogBox-Background, que
-- es una imagen con dibujo, y NUF usa el fondo liso de tooltip. Con la misma
-- transparencia, la piedra se ve maciza y el liso deja pasar el juego.
local BD_MARCO = {
	bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = {left = 5, right = 5, top = 5, bottom = 5},
}

local function Pintar(frame, bg, borde)
	if not frame or not frame.GetBackdrop or not frame:GetBackdrop() then return end
	frame:SetBackdropColor(bg[1], bg[2], bg[3], bg[4] or 1)
	if frame.SetBackdropBorderColor then
		frame:SetBackdropBorderColor(borde[1], borde[2], borde[3], borde[4] or 1)
	end
end

-- ---------------------------------------------------------
-- Pestañas
--
-- Son botones con la plantilla OptionsFrameTabButtonTemplate, o sea el arte
-- dorado de Blizzard en tres trozos (izquierda, centro, derecha) mas sus
-- variantes de desactivado. Se les quita la textura y se les pone backdrop.
--
-- Quitar la textura es definitivo: PanelTemplates_SelectTab solo cambia el
-- alpha y el color del texto, nunca vuelve a asignar la imagen. Lo que si
-- pisa en cada click es el color del texto, y de eso se encarga el gancho.
-- ---------------------------------------------------------
local function ColorearPestana(tab)
	local caja = tab.nufCaja
	if not caja then return end
	if tab.selected then
		Pintar(caja, T.tabSelBG, T.tabSelBorder)
		if tab.text then tab.text:SetTextColor(unpack(T.textSel)) end
	else
		Pintar(caja, T.tabBG, T.tabBorder)
		if tab.text then tab.text:SetTextColor(unpack(T.textOff)) end
	end
end

local function VestirPestana(tab)
	if not tab.nufSkin then
		for _, region in ipairs({tab:GetRegions()}) do
			if region.GetObjectType and region:GetObjectType() == "Texture" then
				region:SetTexture(nil)
			end
		end
		if not tab.text then tab.text = _G[(tab:GetName() or "") .. "Text"] end

		-- La caja NO va sobre el boton, va metida hacia dentro y por detras.
		--
		-- AceGUI ancla cada pestaña 10px ENCIMA de la anterior, porque el
		-- arte de Blizzard trae los extremos transparentes y asi las piezas
		-- casan. Al poner un fondo macizo sobre el boton entero, ese
		-- solapamiento se veia como pestañas montadas unas sobre otras.
		-- Separando la caja 5px por lado se recupera el hueco.
		--
		-- Y cuelga del padre del boton, no del boton, con un nivel por
		-- debajo: asi no puede taparle el texto ni comerse los clicks.
		local caja = CreateFrame("Frame", nil, tab:GetParent())
		caja:SetPoint("TOPLEFT", tab, "TOPLEFT", 5, -2)
		caja:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", -5, 2)
		caja:SetBackdrop(BD_FINO)
		caja:SetFrameLevel(math.max(0, tab:GetFrameLevel() - 1))
		caja.nufTabBox = true      -- para que el recorrido no la repinte
		tab.nufCaja = caja

		tab:HookScript("OnClick", function(self)
			-- El propio click repinta con el arte de Blizzard; se corrige al
			-- vuelo en vez de esperar al repaso periodico, que se notaria.
			for _, otra in ipairs(self.nufHermanas or {}) do ColorearPestana(otra) end
			ColorearPestana(self)
		end)
		tab.nufSkin = true
	end
	ColorearPestana(tab)
end

-- ---------------------------------------------------------
-- Deslizadores y barras de desplazamiento
--
-- Los dos son objetos "Slider", pero no se tratan igual:
--   * el deslizador de un valor TRAE backdrop propio -> se recolorea
--   * la barra de desplazamiento NO -> ponerle uno le dibujaria una caja
--     alrededor que ahora no tiene. Solo se le tiñe el agarre.
-- ---------------------------------------------------------
local function Tenir(textura)
	if textura and textura.SetVertexColor then
		textura:SetVertexColor(T.accent[1], T.accent[2], T.accent[3])
	end
end

local function VestirSlider(s)
	if s.GetBackdrop and s:GetBackdrop() then
		Pintar(s, T.panelBG, T.panelBorder)
	end
	Tenir(s.GetThumbTexture and s:GetThumbTexture())
end

-- ---------------------------------------------------------
-- Desplegables
--
-- Aqui NO se quita el arte como en las pestañas: se tiñe. El marco dorado de
-- UIDropDownMenuTemplate son tres piezas con una forma concreta (extremos
-- redondeados y hueco para la flecha); sustituirlo por un backdrop cuadrado
-- descuadraria el ancho, porque el marco del widget es mas ancho que la
-- parte visible. Tiñendolo se conserva la forma y se gana el color.
-- ---------------------------------------------------------
local function VestirDesplegable(d)
	local n = d:GetName()
	for _, sufijo in ipairs({"Left", "Middle", "Right"}) do
		Tenir(_G[n .. sufijo])
	end
	local texto = _G[n .. "Text"]
	if texto then texto:SetTextColor(unpack(T.textSel)) end
	local boton = _G[n .. "Button"]
	if boton then
		Tenir(boton.GetNormalTexture and boton:GetNormalTexture())
		Tenir(boton.GetPushedTexture and boton:GetPushedTexture())
	end
end

-- ---------------------------------------------------------
-- Recorrido de la ventana
-- ---------------------------------------------------------
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

local pestanas = {}

-- El limite estaba en 7 y se quedaba corto: la ventana anida
-- Frame > content > TabGroup > TreeGroup > ScrollFrame > InlineGroup...
-- y las cajas de dentro caen sobre el nivel 10. Por eso la lista lateral y
-- los recuadros interiores seguian con el gris de AceGUI (0.1/0.1/0.1 con
-- borde 0.4/0.4/0.4) mientras lo de fuera si se pintaba.
local function Recorrer(frame, profundidad)
	if profundidad > 14 then return end
	for i = 1, frame:GetNumChildren() do
		local hijo = select(i, frame:GetChildren())
		if hijo then
			local tipo = hijo.GetObjectType and hijo:GetObjectType()
			if EsPestana(hijo) then
				pestanas[#pestanas + 1] = hijo
				VestirPestana(hijo)
			elseif EsDesplegable(hijo) then
				VestirDesplegable(hijo)
			elseif tipo == "Slider" then
				VestirSlider(hijo)
			elseif hijo.nufTabBox then
				-- Caja de pestaña: ya la pinta ColorearPestana con su propio
				-- color segun este activa o no. Si cayera aqui, el recorrido
				-- la dejaria del color de un panel y perderia el resalte.
			elseif hijo.GetBackdrop and hijo:GetBackdrop() then
				-- Lo que estaba a proposito invisible se deja invisible.
				-- El separador arrastrable entre la lista y el contenido es
				-- un frame con backdrop puesto a alpha 0; pintarlo lo
				-- convertiria en una barra vertical que ahora no existe.
				local _, _, _, alpha
				if hijo.GetBackdropColor then _, _, _, alpha = hijo:GetBackdropColor() end
				if alpha == nil or alpha > 0 then
					Pintar(hijo, T.panelBG, T.panelBorder)
				end
			end
			if hijo.GetNumChildren then Recorrer(hijo, profundidad + 1) end
		end
	end
end

-- Las tres texturas doradas de la cabecera son locales dentro del widget de
-- AceGUI, no hay referencia publica. Se localizan por su textura.
local function QuitarCabeceraDorada(frame)
	for _, region in ipairs({frame:GetRegions()}) do
		if region.GetTexture and region:GetTexture() == HEADER then
			region:SetTexture(nil)
		end
	end
end

local function Vestir(widget)
	if not widget or not widget.frame then return end
	local frame = widget.frame

	if not frame.nufBackdrop then
		frame:SetBackdrop(BD_MARCO)
		frame.nufBackdrop = true
	end
	Pintar(frame, T.frameBG, T.frameBorder)
	QuitarCabeceraDorada(frame)

	-- Caja de titulo, montada sobre el borde superior como la de NUF.
	--
	-- OJO CON EL NIVEL DE MARCO. Antes la dejaba al mismo nivel que la
	-- ventana, y el borde azul del marco pasaba POR DENTRO de la caja: se
	-- veia el titulo atravesado por una raya. Hay que subirla por encima.
	--
	-- Pero eso solo no basta: el texto del titulo no cuelga de esta caja,
	-- sino de un frame propio de AceGUI, asi que al subir la caja el fondo
	-- le taparia el texto. Se sube tambien ese frame, un nivel mas.
	local nivel = frame:GetFrameLevel()

	if not frame.nufTitleBar then
		local barra = CreateFrame("Frame", nil, frame)
		barra:SetPoint("TOP", frame, "TOP", 0, 10)
		barra:SetHeight(30)
		barra:SetBackdrop(BD_FINO)
		frame.nufTitleBar = barra
	end
	frame.nufTitleBar:SetFrameLevel(nivel + 4)
	Pintar(frame.nufTitleBar, T.titleBG, T.titleBorder)
	frame.nufTitleBar:Show()

	if widget.titletext then
		-- Fuente mas grande primero: el ancho se mide DESPUES, porque si no
		-- la caja se calcularia con el tamaño viejo y quedaria corta.
		widget.titletext:SetFontObject(GameFontNormalLarge)
		widget.titletext:SetTextColor(1, 1, 1, 1)

		-- Ancho por PROPORCION, no por el largo del texto.
		--
		-- En NUF la caja mide 500 sobre una ventana de 820, o sea un 61%, y
		-- es lo que le da ese aire de cabecera. Calcularla a partir del texto
		-- daba una pastilla estrecha que no se parecia en nada.
		local anchoMarco = (frame.GetWidth and frame:GetWidth()) or 700
		local ancho = anchoMarco * 0.61
		if ancho < 300 then ancho = 300 end
		frame.nufTitleBar:SetWidth(ancho)

		widget.titletext:ClearAllPoints()
		widget.titletext:SetPoint("CENTER", frame.nufTitleBar, "CENTER", 0, 0)

		-- El frame que sostiene el texto, por encima de la caja.
		local soporte = widget.titletext.GetParent and widget.titletext:GetParent()
		if soporte and soporte.SetFrameLevel then
			soporte:SetFrameLevel(nivel + 5)
		end
	end

	for i = #pestanas, 1, -1 do pestanas[i] = nil end
	Recorrer(frame, 1)
	-- Cada pestaña necesita conocer a las demas para poder apagarlas al ser
	-- pulsada; si no, al cambiar quedarian dos con aspecto de seleccionada.
	for _, tab in ipairs(pestanas) do tab.nufHermanas = pestanas end
end

-- ---------------------------------------------------------
-- Enganche
-- ---------------------------------------------------------
local vigilante = CreateFrame("Frame")
local acumulado = 0

local function EstaActivo()
	local db = TidyPlatesThreat and TidyPlatesThreat.db and TidyPlatesThreat.db.profile
	return db and db.arcaneSkin
end

local function Aplicar()
	local ACD = LibStub and LibStub("AceConfigDialog-3.0", true)
	if not ACD or not ACD.OpenFrames then return end
	local widget = ACD.OpenFrames[APP]
	if not widget then return end
	if EstaActivo() then
		Vestir(widget)
	elseif widget.frame and widget.frame.nufTitleBar then
		-- Apagado en caliente: se esconde la barra propia. Los colores de
		-- Blizzard vuelven al reabrir, porque AceGUI reconstruye el backdrop
		-- cada vez que saca la ventana de su reserva. Las pestañas no: su
		-- arte se quito de verdad, asi que hace falta /reload para tenerlo.
		widget.frame.nufTitleBar:Hide()
	end
end

-- Repaso periodico mientras la ventana esta abierta.
--
-- No basta con pintar al abrir: AceGUI crea los paneles de cada pestaña la
-- primera vez que entras en ella, asi que los que aun no habias visitado
-- saldrian con los colores de Blizzard. Medio segundo es imperceptible y
-- solo corre con las opciones abiertas, nunca en combate.
vigilante:SetScript("OnUpdate", function(self, elapsed)
	acumulado = acumulado + (elapsed or 0)
	if acumulado < 0.5 then return end
	acumulado = 0
	local ACD = LibStub and LibStub("AceConfigDialog-3.0", true)
	if not ACD or not ACD.OpenFrames or not ACD.OpenFrames[APP] then return end
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

-- Para que el checkbox del menu repinte al instante.
TidyPlatesThreat = TidyPlatesThreat or {}
TidyPlatesThreat.RefreshArcaneSkin = Aplicar
