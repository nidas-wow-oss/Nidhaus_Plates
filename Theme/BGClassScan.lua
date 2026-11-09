-- =========================================================
-- BGClassScan.lua
--
-- Al entrar a un campo de batalla, lee el marcador y guarda de una vez la
-- clase de todos los participantes.
--
-- PARA QUE SIRVE (y para que NO)
-- ------------------------------
-- Solo afecta a las placas ALIADAS. La clase de un enemigo NidhausPlates ya la
-- deduce del color de su barra de vida (NidhausPlatesCore, ClassReference), asi
-- que esos iconos salen bien desde el primer fotograma sin necesitar nada.
-- Las placas aliadas son todas verdes y no llevan color de clase: ahi hay que
-- preguntarlo, y hasta ahora solo se podia cuando la placa ya estaba a la
-- vista. Con esto se sabe antes de haber visto a nadie.
--
-- NO es una mejora de rendimiento. Añade un barrido cada diez segundos
-- mientras estas en el BG; lo que gana es que el icono este bien antes, no
-- que el addon vaya mas suelto.
-- =========================================================

local anadidos = {}      -- lo que metimos nosotros, para poder limpiarlo
local enBG = false
local acumulado = 0
local PERIODO = 10       -- segundos entre peticiones; cubre a los que llegan tarde

-- El marcador devuelve la clase TRADUCIDA ("Paladín", "Cazador"...), pero la
-- cache y las texturas de icono usan el nombre ingles en mayusculas. Mismo
-- problema que tuvimos con las serpientes de la trampa: si se guarda el texto
-- tal cual llega, con el cliente en español no coincide con nada.
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

-- Devuelve el token ingles a partir de lo que entregue el marcador.
-- Se aceptan las dos vias porque el orden de los valores de
-- GetBattlefieldScore no es igual en todos los cores de 3.3.5: unos traen el
-- token en su sitio y otros dejan ahi el nombre traducido.
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

-- Al salir se borra lo que metimos nosotros, salvo que el usuario haya pedido
-- guardar clases (cacheClass). Si no, la cache del perfil crecería con
-- cuarenta nombres por cada campo de batalla y no pararía nunca.
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
				acumulado = PERIODO      -- primera peticion en el siguiente tick
				self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
			end
		elseif enBG then
			enBG = false
			self:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
			Limpiar()
		end
	elseif event == "UPDATE_BATTLEFIELD_SCORE" then
		-- Se escanea cuando llegan los datos, no tras una espera fija: al
		-- entrar el marcador esta vacio y tarda lo que tarde el servidor.
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

-- Para probarlo a mano.
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
