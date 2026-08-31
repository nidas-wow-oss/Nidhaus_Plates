-----------------------
-- Class Icon Widget --
-----------------------
local path = "Interface\\AddOns\\Nidhaus_Plates\\ThreatPlates\\Widgets\\ClassIconWidget\\"

local RING = "Interface\\AddOns\\Nidhaus_Plates\\ThreatPlates\\Media\\Artwork\\TP_ClassIconRing"

local function noop()
	return
end

-- ---------------------------------------------------------------
-- Borde del icono de clase
--
-- Dos formas, porque un marco cuadrado sobre un icono redondo queda mal:
--   * temas cuadrados (default / transparent) -> cuatro tiras de 1px
--   * tema redondo (circle)                   -> un anillo
--
-- El cuadrado se dibuja con tiras y no con una imagen de marco a proposito:
-- una textura de borde estirada se ve borrosa cuando cambias el tamano del
-- icono, y las tiras salen nitidas midan lo que midan.
-- ---------------------------------------------------------------
local function CrearBorde(frame)
	frame.BorderLines = {}
	for i = 1, 4 do
		local t = frame:CreateTexture(nil, "OVERLAY")
		t:SetTexture("Interface\\Buttons\\WHITE8X8")
		t:Hide()
		frame.BorderLines[i] = t
	end

	frame.BorderRing = frame:CreateTexture(nil, "OVERLAY")
	frame.BorderRing:SetTexture(RING)
	frame.BorderRing:Hide()
end

local function ColocarLineas(frame, grosor)
	local arriba, abajo, izq, der = unpack(frame.BorderLines)
	arriba:ClearAllPoints()
	arriba:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	arriba:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
	arriba:SetHeight(grosor)

	abajo:ClearAllPoints()
	abajo:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
	abajo:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	abajo:SetHeight(grosor)

	izq:ClearAllPoints()
	izq:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	izq:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
	izq:SetWidth(grosor)

	der:ClearAllPoints()
	der:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
	der:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	der:SetWidth(grosor)
end

local NEGRO  = {r = 0, g = 0, b = 0}
local BLANCO = {r = 1, g = 1, b = 1}

local function ActualizarBorde(frame, db, unit)
	if not frame.BorderLines then CrearBorde(frame) end

	if not db.classWidget.border then
		for i = 1, 4 do frame.BorderLines[i]:Hide() end
		frame.BorderRing:Hide()
		return
	end

	-- Dos colores: el normal y el del objetivo.
	--
	-- unit.isTarget lo mantiene el motor de TidyPlates y se refresca cuando
	-- cambias de objetivo (es lo mismo que usan el resaltado y la escala del
	-- objetivo), asi que no hace falta escuchar PLAYER_TARGET_CHANGED aqui.
	local c
	if unit and unit.isTarget then
		c = db.classWidget.borderColorTarget or BLANCO
	else
		c = db.classWidget.borderColor or NEGRO
	end
	local redondo = (db.classWidget.theme == "circle")

	if redondo then
		for i = 1, 4 do frame.BorderLines[i]:Hide() end
		-- El anillo se sale un pelo del icono para que se vea el trazo
		-- entero y no quede cortado por el borde del marco.
		frame.BorderRing:ClearAllPoints()
		frame.BorderRing:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
		frame.BorderRing:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
		frame.BorderRing:SetVertexColor(c.r, c.g, c.b, 1)
		frame.BorderRing:Show()
	else
		frame.BorderRing:Hide()
		-- El grosor se escala con el icono: 1px fijo desaparece en iconos
		-- grandes y tapa el dibujo en los pequenos.
		local grosor = (db.classWidget.borderThickness or 1)
			* math.max(1, (frame:GetWidth() or 22) / 22)
		ColocarLineas(frame, grosor)
		for i = 1, 4 do
			frame.BorderLines[i]:SetVertexColor(c.r, c.g, c.b, 1)
			frame.BorderLines[i]:Show()
		end
	end
end

local function UpdateClassIconWidget(frame, unit)
	local db = TidyPlatesThreat.db.profile
	if db.classWidget.ON then
		if unit.class and (unit.class ~= "UNKNOWN") then
			frame.Icon:SetTexture(path .. db.classWidget.theme .. "\\" .. unit.class)
			frame:Show()
		elseif db.cache[unit.name] and db.friendlyClassIcon then
			local class = db.cache[unit.name]
			frame.Icon:SetTexture(path .. db.classWidget.theme .. "\\" .. class)
			frame:Show()
		elseif unit.guid and not db.cache[unit.name] and db.friendlyClassIcon then
			local engClass = select(2, GetPlayerInfoByGUID(unit.guid))
			if engClass then
				frame.Icon:SetTexture(path .. db.classWidget.theme .. "\\" .. engClass)
				frame:Show()
			end
		else
			frame:Hide()
		end
	else
		frame:Hide()
	end

	if frame:IsShown() then
		ActualizarBorde(frame, db, unit)
	end

	-- hack to move friendly class icons above names.
	if frame:IsShown() and unit.reaction == "FRIENDLY" and unit.type == "PLAYER" then
		if db.friendlyNameOnly then
			if not frame.moved then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOM", frame:GetParent(), "BOTTOM", 0, 20)
				frame.moved = true
				frame._SetPoint = frame.SetPoint
				frame.SetPoint = noop
				frame._SetAllPoints = frame.SetAllPoints
				frame.SetAllPoints = noop
			end
		elseif frame._SetPoint and frame.moved then
			frame.SetPoint = frame._SetPoint
			frame.SetAllPoints = frame._SetAllPoints
			frame:ClearAllPoints()
			frame:SetPoint("CENTER", frame:GetParent(), "CENTER", -74, 7)
			frame.moved = nil
		end
	end
end

local function CreateClassIconWidget(parent)
	local db = TidyPlatesThreat.db.profile.classWidget
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetHeight(64)
	frame:SetWidth(64)
	frame.Icon = frame:CreateTexture(nil, "OVERLAY")
	frame.Icon:SetAllPoints(frame)
	CrearBorde(frame)
	frame:Hide()
	frame.Update = UpdateClassIconWidget
	return frame
end

ThreatPlatesWidgets.CreateClassIconWidget = CreateClassIconWidget