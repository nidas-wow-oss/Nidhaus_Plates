---------------
-- Unique Icon Widget
---------------
local db
local function UpdateUniqueIconWidget(self, unit)
	db = TidyPlatesThreat.db.profile

	-- OCULTAR ES OCULTAR.
	--
	-- Si el usuario tildo "Hide Mirror Images" (o las serpientes), SetStyle
	-- devuelve el estilo vacio y la placa no se dibuja. Pero los widgets no
	-- miran que estilo salio: este seguia pintando su icono sobre una placa
	-- invisible, y quedaba el iconito flotando solo en el aire.
	--
	-- La regla es una sola y vive en Core (IsNameHidden); aca solo se
	-- consulta. El "if" de existencia es porque este archivo tambien se
	-- carga en versiones donde esa funcion todavia no estaba.
	if TidyPlatesThreat.IsNameHidden
		and TidyPlatesThreat.IsNameHidden(unit.name, unit.reaction, unit.type) then
		self:Hide()
		return
	end

	local T, custom = TidyPlatesThreat.UnitType(unit)

	if db.uniqueWidget.ON then
		if tContains(db.uniqueSettings.list, unit.name) or (custom and tContains(db.uniqueSettings.list, "GROUP")) then
			for k_c, k_v in pairs(db.uniqueSettings.list) do
				if k_v == unit.name or (custom and k_v == "GROUP") then
					if db.uniqueSettings[k_c].icon and db.uniqueSettings[k_c].showIcon then
						if tonumber(db.uniqueSettings[k_c].icon) == nil then
							self.Icon:SetTexture(db.uniqueSettings[k_c].icon)
						else
							local icon = select(3, GetSpellInfo(tonumber(db.uniqueSettings[k_c].icon)))
							self.Icon:SetTexture(icon or "Interface\\Icons\\Temp")
						end
						self:Show()
					else
						self:Hide()
					end
				end
			end
		else
			self:Hide()
		end
	else
		self:Hide()
	end
end

local function CreateUniqueIconWidget(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetWidth(64)
	frame:SetHeight(64)
	frame.Icon = frame:CreateTexture(nil, "OVERLAY")
	frame.Icon:SetPoint("CENTER", frame)
	frame.Icon:SetAllPoints(frame)
	frame:Hide()
	frame.Update = UpdateUniqueIconWidget
	return frame
end

ThreatPlatesWidgets.CreateUniqueIconWidget = CreateUniqueIconWidget