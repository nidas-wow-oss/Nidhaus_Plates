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

	-- La pestana ELEGIDA, en el dorado de NUF. Va aparte de textSel a
	-- proposito: ese mismo color lo usa el texto de los desplegables, que
	-- tiene que seguir siendo blanco para poder leerlo de un vistazo.
	tabSelText   = {1.00,  0.82,  0.00},

	-- Cabecera, igual que NUF: el titulo dorado (es el color propio de
	-- GameFontNormalLarge, que NUF usa sin pintarlo), el subtitulo gris y
	-- la version en ambar.
	titleText    = {1.00,  0.82,  0.00},
	subText      = {0.67,  0.67,  0.67},
	verText      = {1.00,  0.67,  0.00},

	-- Azul de acento de NUF. Con el se tiñen las piezas cuya FORMA hay que
	-- conservar (agarres de deslizador, flechas de desplegable), en vez de
	-- quitarles la textura como a las pestañas.
	accent       = {0.25,  0.66,  1.00},
}

local HEADER = "Interface\\DialogFrame\\UI-DialogBox-Header"

-- Subtitulo de la ventana. NUF pone "Unit Frame Customization & Arena
-- Tools" debajo del titulo; esto es el equivalente aca.
local SUBTITULO = "Nameplate Customization & Threat Tools"

-- La version sale del .toc, asi se cambia en un solo lugar. Si el .toc no
-- la trae, no se muestra nada en vez de inventar un numero.
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

-- =========================================================
-- LO QUE TOCAMOS NO ES NUESTRO: SE ANOTA Y SE DEVUELVE.
--
-- El comentario de arriba razona bien sobre no parchear AceGUI... y se le
-- escapa lo que importa: las INSTANCIAS tambien son compartidas.
--
-- AceGUI guarda un unico pool en AceGUI.objPools y LibStub carga una sola
-- copia de la libreria para todo el juego. La ventana que nos dan al abrir
-- es el mismo objeto que despues se le entrega a PlateBuffs, a BankStack o
-- a quien la pida. Y los colores de fabrica se ponen en el CONSTRUCTOR del
-- widget, no en OnAcquire -- lo verifique en AceGUIContainer-Frame.lua:
-- SetBackdropColor(0,0,0,1) y statusbg en 0.1 estan en la construccion, y
-- OnAcquire solo hace SetParent, strata, titulo, texto de estado y Show.
--
-- O sea que cada cambio nuestro era PERMANENTE y viajaba con el widget al
-- siguiente addon. Eso es lo que le pintaba de azul las opciones a medio
-- juego.
--
-- Aca se anota el valor anterior de cada cosa la PRIMERA vez que se toca, y
-- se repone entero al cerrar la ventana.
--
-- Hay dos cosas que no se pueden deshacer y se resuelven distinto:
--   * los HookScript son para siempre -> el cuerpo del hook sale temprano
--     si la ventana nuestra no esta abierta;
--   * las cajas que creamos no se destruyen -> se esconden al cerrar.
-- =========================================================
local orig     = {};   -- [objeto] = { que guardamos de el }
local origList = {};   -- el mismo conjunto, en orden, para poder recorrerlo

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
	-- El texto tambien: al titulo le sacamos los codigos de color, y el
	-- widget se lo presta despues al siguiente addon.
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

local cajas    = {};   -- lo que creamos nosotros y hay que esconder al cerrar
local marcados = {};   -- pestanas a las que les quitamos el arte
local marcos   = {};   -- marcos a los que les reemplazamos el backdrop entero

local function Restaurar()
	for i = #origList, 1, -1 do
		local o = origList[i]
		local e = orig[o]
		if e then
			-- El fondo PRIMERO: ponerlo resetea los colores, asi que los
			-- colores tienen que ir despues o se pierden.
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
			-- Solo si REALMENTE tenia un font object. Si no tenia, un
			-- SetFontObject(nil) puede dejar el texto sin fuente; se prefiere
			-- que quede con la nuestra antes que romperlo.
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

	-- Lo que creamos no se puede destruir: se esconde.
	for i = #cajas, 1, -1 do
		if cajas[i] then pcall(cajas[i].Hide, cajas[i]) end
		cajas[i] = nil
	end
	-- Y se deja marcado que hay que volver a desnudar las pestanas la
	-- proxima vez, porque acabamos de devolverles su arte.
	for i = #marcados, 1, -1 do
		if marcados[i] then marcados[i].nufStripped = nil end
		marcados[i] = nil
	end
	for i = #marcos, 1, -1 do
		if marcos[i] then marcos[i].nufBackdrop = nil end
		marcos[i] = nil
	end
end

-- La opcion del perfil.
local function EstaActivo()
	local db = TidyPlatesThreat and TidyPlatesThreat.db and TidyPlatesThreat.db.profile
	return db and db.arcaneSkin
end

-- "Nuestra ventana esta abierta AHORA". Lo usan los hooks permanentes para
-- no hacer nada cuando el widget ya es de otro addon.
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
	-- El arte se quita recordandolo: antes esto era definitivo y el
	-- boton se iba pelado al siguiente addon que lo recibiera.
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
			-- ESTE HOOK ES PARA SIEMPRE: en WoW no se puede desenganchar.
			-- Por eso lo primero que hace es comprobar que la ventana
			-- nuestra este abierta. Sin esto, el boton ya reciclado por
			-- otro addon seguiria pintandose con nuestros colores.
			if not Activa() then return end
			-- El propio click repinta con el arte de Blizzard; se corrige al
			-- vuelo en vez de esperar al repaso periodico, que se notaria.
			for _, otra in ipairs(self.nufHermanas or {}) do ColorearPestana(otra) end
			ColorearPestana(self)
		end)
	end
	-- La caja no se destruye nunca; se muestra con nosotros y se
	-- esconde al cerrar (ver Restaurar).
	tab.nufCaja:Show()
	cajas[#cajas + 1] = tab.nufCaja
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
		GuardarTextura(textura)
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
	if texto then GuardarTexto(texto); texto:SetTextColor(unpack(T.textSel)) end
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
			GuardarTextura(region)
			region:SetTexture(nil)
		end
	end
end

local function Vestir(widget)
	if not widget or not widget.frame then return end
	local frame = widget.frame

	-- El backdrop entero se reemplaza, asi que hay que quedarse con el
	-- que traia: es lo que se repone al cerrar.
	GuardarFondo(frame)
	if not frame.nufBackdrop then
		frame:SetBackdrop(BD_MARCO)
		frame.nufBackdrop = true
		marcos[#marcos + 1] = frame
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
		barra:SetPoint("TOP", frame, "TOP", 0, 12)
		-- 30 de alto y anclada dos pixeles mas arriba. Con 28 el titulo
		-- quedaba rozando el borde de la caja; asi tiene aire arriba y
		-- abajo sigue entrando el subtitulo antes de las pestanas.
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
		GuardarTexto(widget.titletext)
		widget.titletext:SetFontObject(GameFontNormalLarge)

		-- POR QUE HAY QUE LIMPIAR EL TEXTO Y NO ALCANZA CON PINTARLO.
		--
		-- El nombre del addon viene con el color metido adentro del texto:
		--     "|cffffffffNidhaus|r|cff00ff00_Plates|r"
		-- y esos codigos GANAN sobre SetTextColor. Por eso se veia blanco y
		-- verde por mas que se le pidiera dorado. Primero se le sacan los
		-- codigos, y recien ahi el color de la fuente manda.
		--
		-- El texto original queda guardado en GuardarTexto y vuelve al
		-- cerrar: el widget es del pool de AceGUI y se lo presta al proximo
		-- addon tal cual estaba.
		--
		-- El guion bajo pasa a espacio para que lea como el de NUF
		-- ("Nidhaus UnitFrames" / "Nidhaus Plates").
		local crudo  = widget.titletext:GetText() or ""
		local limpio = string.gsub(crudo, "|c%x%x%x%x%x%x%x%x", "")
		limpio = string.gsub(limpio, "|r", "")
		limpio = string.gsub(limpio, "_", " ")
		if limpio ~= "" then widget.titletext:SetText(limpio) end
		widget.titletext:SetTextColor(unpack(T.titleText))

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
		-- +2: centrado exacto lo dejaba pegado al borde de abajo, porque la
		-- fuente grande tiene mas pinta arriba que abajo.
		widget.titletext:SetPoint("CENTER", frame.nufTitleBar, "CENTER", 0, 2)

		-- El frame que sostiene el texto, por encima de la caja.
		local soporte = widget.titletext.GetParent and widget.titletext:GetParent()
		if soporte and soporte.SetFrameLevel then
			GuardarNivel(soporte)
			soporte:SetFrameLevel(nivel + 5)
		end
	end

	-- ---------------------------------------------------------
	-- Subtitulo, version y la X de cerrar: el resto de la cabecera de NUF.
	--
	-- Todo esto lo creamos NOSOTROS, asi que no hay nada que guardar ni que
	-- devolver: se esconde al cerrar junto con lo demas que creamos (la
	-- lista "cajas"). Lo del addon se toca lo menos posible; lo nuestro se
	-- agrega encima.
	-- ---------------------------------------------------------
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
	-- Y la lista de cajas tambien: Aplicar corre cada medio segundo y sin
	-- esto se iria llenando de repetidas hasta el infinito.
	for i = #cajas, 1, -1 do cajas[i] = nil end
	if frame.nufTitleBar  then cajas[#cajas + 1] = frame.nufTitleBar  end
	if frame.nufSubtitle  then cajas[#cajas + 1] = frame.nufSubtitle  end
	if frame.nufVersion   then cajas[#cajas + 1] = frame.nufVersion   end
	if frame.nufClose     then cajas[#cajas + 1] = frame.nufClose     end
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
local pendiente = false   -- "hay algo nuevo que pintar"; ver el bloque de abajo

-- EstaActivo y Activa viven arriba, junto al registro: los necesita el
-- hook de las pestanas, que se define mucho antes que esto.

local function Aplicar()
	local ACD = LibStub and LibStub("AceConfigDialog-3.0", true)
	if not ACD or not ACD.OpenFrames then return end
	local widget = ACD.OpenFrames[APP]
	if not widget then return end
	if EstaActivo() then
		Vestir(widget)
	else
		-- Apagado en caliente: se devuelve TODO lo tocado, no solo la
		-- barra. Antes se asumia que AceGUI reconstruia el fondo al sacar
		-- la ventana del pool, y no es asi: eso se hace en el constructor.
		Restaurar()
	end
end

-- =========================================================
-- EL PARPADEO DE LOS BORDES: MEDIO SEGUNDO DE ESPERA
--
-- No basta con pintar al abrir: AceGUI no dibuja la ventana entera de una.
-- Arma los controles de cada pestana la primera vez que entras, y los
-- vuelve a armar cada vez que cambias una opcion. Recien creados salen con
-- los colores de fabrica.
--
-- Con un repaso cada medio segundo, se los veia asi HASTA medio segundo.
-- Eso es el borde claro que aparecia y desaparecia solo en los
-- desplegables y en algunos fondos: no era un color mal puesto, era el
-- tiempo que tardabamos en llegar.
--
-- Bajar el repaso a cada cuadro seria recorrer el arbol de marcos sesenta
-- veces por segundo para no hacer nada el 99% de las veces. Mejor es que
-- AceGUI avise: cada vez que entrega un control se levanta una bandera, y
-- se repinta en el cuadro siguiente. Un cuadro no se ve.
--
-- El gancho es PARA SIEMPRE y la libreria es compartida con todos los
-- addons, asi que lo unico que hace es levantar la bandera -- no toca
-- nada, no mira nada. Si la ventana no es la nuestra o la piel esta
-- apagada, el repaso la baja y no pinta.
-- =========================================================
do
	local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
	if AceGUI and type(AceGUI.Create) == "function" then
		hooksecurefunc(AceGUI, "Create", function() pendiente = true end)
	end
end

-- Repaso mientras la ventana esta abierta. El medio segundo queda de red
-- por si algo cambia de color sin pasar por AceGUI:Create.
vigilante:SetScript("OnUpdate", function(self, elapsed)
	acumulado = acumulado + (elapsed or 0)
	if not pendiente and acumulado < 0.5 then return end
	acumulado = 0
	pendiente = false
	local ACD = LibStub and LibStub("AceConfigDialog-3.0", true)
	local w = ACD and ACD.OpenFrames and ACD.OpenFrames[APP]
	if not w or not w.frame or not w.frame:IsShown() then
		-- Se cerro: los widgets vuelven al pool compartido, asi que se les
		-- devuelve lo suyo ANTES de que otro addon los reciba.
		if #origList > 0 or #cajas > 0 then Restaurar() end
		return
	end
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

-- =========================================================
-- DIAGNOSTICO TEMPORAL: /nptabs
--
-- Mide las pestanas de la ventana de opciones y las compara con el ancho
-- del contenedor. AceGUI abre una fila nueva cuando la siguiente pestana no
-- entra; si cada una mide casi lo mismo que el contenedor, entra una sola
-- por fila y quedan apiladas.
--
-- Tambien informa si a cada pestana le queda textura en las piezas Left /
-- Middle / Right, porque PanelTemplates_TabResize las usa para calcular el
-- ancho y este addon se las quita.
--
-- ESTO SE SACA APENAS TENGAMOS EL NUMERO.
-- =========================================================
local function DiagAncho(o)
	if not o or not o.GetWidth then return "?" end
	local w = o:GetWidth()
	return w and string.format("%.0f", w) or "?"
end

SLASH_NPTABDIAG1 = "/nptabs"
SlashCmdList["NPTABDIAG"] = function()
	local ACD = LibStub and LibStub("AceConfigDialog-3.0", true)
	local w = ACD and ACD.OpenFrames and ACD.OpenFrames[APP]
	if not w or not w.frame then
		print("|cff33ff99nptabs|r abri primero las opciones con /tptp y volve a tirar el comando.")
		return
	end

	print("|cff33ff99nptabs|r ventana: " .. DiagAncho(w.frame)
		.. "   skin arcane: " .. tostring(EstaActivo() and true or false))

	-- Buscar las pestanas por nombre, igual que hace el skin.
	local encontradas = {}
	local function Buscar(f, prof)
		if not f or prof > 14 or not f.GetChildren then return end
		for _, hijo in ipairs({ f:GetChildren() }) do
			local n = hijo.GetName and hijo:GetName()
			if n and n:find("^AceGUITabGroup%d+Tab%d+$") then
				encontradas[#encontradas + 1] = hijo
			end
			Buscar(hijo, prof + 1)
		end
	end
	Buscar(w.frame, 0)

	if #encontradas == 0 then
		print("|cff33ff99nptabs|r no encontre ninguna pestana.")
		return
	end

	-- El contenedor real de las pestanas es el padre de la primera.
	local padre = encontradas[1]:GetParent()
	print("|cff33ff99nptabs|r contenedor de pestanas: " .. DiagAncho(padre)
		.. "   pestanas: " .. #encontradas)

	for _, tab in ipairs(encontradas) do
		local n = tab:GetName() or "?"
		local piezas = {}
		for _, suf in ipairs({ "Left", "Middle", "Right" }) do
			local r = _G[n .. suf]
			if r then
				local tex = r.GetTexture and r:GetTexture()
				piezas[#piezas + 1] = suf .. "=" .. DiagAncho(r)
					.. (tex and "" or "(sin textura)")
			end
		end
		print(string.format("   %s  ancho=%s  texto=%s  %s",
			n:gsub("^AceGUITabGroup", ""),
			DiagAncho(tab),
			(tab.GetTextWidth and string.format("%.0f", tab:GetTextWidth() or 0)) or "?",
			table.concat(piezas, " ")))
	end
end
