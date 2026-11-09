local path = "Interface\\Addons\\Nidhaus_Plates\\Theme\\Widgets\\TotemIconWidget\\"
local L = NidhausPlates.L

local function TotemName(SpellID, suffix)
	local name = GetSpellInfo(SpellID)
	if suffix then name = name .. " "..suffix end
	return name
end

TPtotemList = {

	[TotemName(8177)] = "A1",
	[TotemName(10595, "I")] = "A2",
	[TotemName(10600, "II")] = "A2",
	[TotemName(10601, "III")] = "A2",
	[TotemName(25574, "IV")] = "A2",
	[TotemName(58746, "V")] = "A2",
	[TotemName(58749, "VI")] = "A2",
	[TotemName(6495)] = "A3",
	[TotemName(8512)] = "A4",
	[TotemName(3738)] = "A5",

	[TotemName(2062)] = "E1",
	[TotemName(2484)] = "E2",
	[TotemName(5730, "I")] = "E3",
	[TotemName(6390, "II")] = "E3",
	[TotemName(6391, "III")] = "E3",
	[TotemName(6392, "IV")] = "E3",
	[TotemName(10427, "V")] = "E3",
	[TotemName(10428, "VI")] = "E3",
	[TotemName(25525, "VII")] = "E3",
	[TotemName(58580, "VIII")] = "E3",
	[TotemName(58581, "IX")] = "E3",
	[TotemName(58582, "X")] = "E3",
	[TotemName(8071, "I")] = "E4",
	[TotemName(8154, "II")] = "E4",
	[TotemName(8155, "III")] = "E4",
	[TotemName(10406, "IV")] = "E4",
	[TotemName(10407, "V")] = "E4",
	[TotemName(10408, "VI")] = "E4",
	[TotemName(25508, "VII")] = "E4",
	[TotemName(25509, "VIII")] = "E4",
	[TotemName(58751, "IX")] = "E4",
	[TotemName(58753, "X")] = "E4",
	[TotemName(8075, "I")] = "E5",
	[TotemName(8160, "II")] = "E5",
	[TotemName(8161, "III")] = "E5",
	[TotemName(10442, "IV")] = "E5",
	[TotemName(25361, "V")] = "E5",
	[TotemName(25528, "VI")] = "E5",
	[TotemName(57622, "VII")] = "E5",
	[TotemName(58643, "VIII")] = "E5",
	[TotemName(8143)] = "E6",

	[TotemName(2894)] = "F1",
	[TotemName(8227, "I")] = "F2",
	[TotemName(8249, "II")] = "F2",
	[TotemName(10526, "III")] = "F2",
	[TotemName(16387, "IV")] = "F2",
	[TotemName(25557, "V")] = "F2",
	[TotemName(58649, "VI")] = "F2",
	[TotemName(58652, "VII")] = "F2",
	[TotemName(58656, "VIII")] = "F2",
	[TotemName(8181, "I")] = "F3",
	[TotemName(10478, "II")] = "F3",
	[TotemName(10479, "III")] = "F3",
	[TotemName(25560, "IV")] = "F3",
	[TotemName(58741, "V")] = "F3",
	[TotemName(58745, "VI")] = "F3",
	[TotemName(8190, "I")] = "F4",
	[TotemName(10585, "II")] = "F4",
	[TotemName(10586, "III")] = "F4",
	[TotemName(10587, "IV")] = "F4",
	[TotemName(25552, "V")] = "F4",
	[TotemName(58731, "VI")] = "F4",
	[TotemName(58734, "VII")] = "F4",
	[TotemName(3599, "I")] = "F5",
	[TotemName(6363, "II")] = "F5",
	[TotemName(6364, "III")] = "F5",
	[TotemName(6365, "IV")] = "F5",
	[TotemName(10437, "V")] = "F5",
	[TotemName(10438, "VI")] = "F5",
	[TotemName(25533, "VII")] = "F5",
	[TotemName(58699, "VIII")] = "F5",
	[TotemName(58703, "IX")] = "F5",
	[TotemName(58704, "X")] = "F5",
	[TotemName(30706, "I")] = "F6",
	[TotemName(57720, "II")] = "F6",
	[TotemName(57721, "III")] = "F6",
	[TotemName(57722, "IV")] = "F6",

	[TotemName(8170)] = "W1",
	[TotemName(8184, "I")] = "W2",
	[TotemName(10537, "II")] = "W2",
	[TotemName(10538, "III")] = "W2",
	[TotemName(25563, "IV")] = "W2",
	[TotemName(58737, "V")] = "W2",
	[TotemName(58739, "VI")] = "W2",
	[TotemName(5394, "I")] = "W3",
	[TotemName(6375, "II")] = "W3",
	[TotemName(6377, "III")] = "W3",
	[TotemName(10462, "IV")] = "W3",
	[TotemName(10463, "V")] = "W3",
	[TotemName(25567, "VI")] = "W3",
	[TotemName(58755, "VII")] = "W3",
	[TotemName(58756, "VIII")] = "W3",
	[TotemName(58757, "IX")] = "W3",
	[TotemName(5675, "I")] = "W4",
	[TotemName(10495, "II")] = "W4",
	[TotemName(10496, "III")] = "W4",
	[TotemName(10497, "IV")] = "W4",
	[TotemName(25570, "V")] = "W4",
	[TotemName(58771, "VI")] = "W4",
	[TotemName(58773, "VII")] = "W4",
	[TotemName(58774, "VIII")] = "W4",
	[TotemName(16190)] = "W5"
}

local TotemNameFallback = NidhausPlatesUtility.TotemNameFallback

local BORDE = {
	edgeFile = "Interface\\Buttons\\WHITE8X8",
	edgeSize = 2,
}

local function UpdateTotemIconWidget(self, unit)
	local totem = TPtotemList[unit.name] or TPtotemList[TotemNameFallback(unit.name)]
	local db = NidhausPlatesTheme.db.profile
	local tw = db.totemWidget
	if totem and tw.ON and db.totemSettings[totem][3] then
		self.Icon:SetTexture(path .. db.totemSettings[totem][7] .. "\\" .. totem)

		local parent = self:GetParent()
		self:ClearAllPoints()
		if parent.stylename == "etotem" then
			self:SetPoint("CENTER", parent, "CENTER", 0, 0)
		else
			self:SetPoint(tw.anchor, parent, tw.x, tw.y)
		end

		if tw.border ~= false then
			if unit.reaction == "FRIENDLY" then
				self.Border:SetBackdropBorderColor(0.2, 1, 0.2, 1)
			else
				self.Border:SetBackdropBorderColor(1, 0.15, 0.15, 1)
			end
			self.Border:Show()
		else
			self.Border:Hide()
		end

		if tw.targetGlow ~= false and unit.isTarget and UnitExists("target") then
			local t = db.targetWidget
			local lado = (self:GetWidth() or 35) * 1.8
			self.Glow:SetWidth(lado)
			self.Glow:SetHeight(lado)
			self.Glow:SetVertexColor(t.r or 1, t.g or 1, t.b or 1, 1)
			self.Glow:Show()
		else
			self.Glow:Hide()
		end

		self:Show()
	else
		self:Hide()
	end
end

local function CreateTotemIconWidget(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetWidth(64)
	frame:SetHeight(64)
	frame.Icon = frame:CreateTexture(nil, "OVERLAY")
	frame.Icon:SetPoint("CENTER", frame)
	frame.Icon:SetAllPoints(frame)

	local borde = CreateFrame("Frame", nil, frame)
	borde:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
	borde:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
	borde:SetBackdrop(BORDE)
	borde:Hide()
	frame.Border = borde

	local glow = borde:CreateTexture(nil, "OVERLAY")
	glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
	glow:SetBlendMode("ADD")
	glow:SetPoint("CENTER", frame, "CENTER", 0, 0)
	glow:Hide()
	frame.Glow = glow

	frame:Hide()
	frame.Update = UpdateTotemIconWidget
	return frame
end

NidhausPlatesThemeWidgets.CreateTotemIconWidget = CreateTotemIconWidget
