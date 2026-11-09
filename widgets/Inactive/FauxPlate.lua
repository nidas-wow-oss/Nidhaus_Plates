local NidhausPlates = NidhausPlates
local OnNewNameplate = NidhausPlates.OnNewNameplate
local Plates = {}

local function CreateFauxPlate(plate)
	if plate and not Plates[plate] then
		Plates[plate] = true
		plate.extended = CreateFrame("Frame", nil, plate)
		local extended = plate.extended

		extended:SetPoint("CENTER", plate)
		extended.style, extended.unit, extended.unitcache, extended.stylecache, extended.widgets = {}, {}, {}, {}, {}
		extended.regions, extended.bars, extended.visual = {}, {}, {}
		regions = extended.regions
		bars = extended.bars
		extended.stylename = ""

		local level = plate:GetFrameLevel()
		bars.healthbar = CreateNidhausPlatesStatusbar(extended)
		bars.castbar = CreateNidhausPlatesStatusbar(extended)

		local health, cast, healthbar, castbar = bars.health, bars.cast, bars.healthbar, bars.castbar
		healthbar:SetFrameLevel(level)
		castbar:Hide()
		castbar:SetFrameLevel(level)
		castbar:SetStatusBarColor(1, .8, 0)

		visual = extended.visual
		visual.threatborder = healthbar:CreateTexture(nil, "ARTWORK")
		visual.specialArt = extended:CreateTexture(nil, "OVERLAY")
		visual.specialText = healthbar:CreateFontString(nil, "OVERLAY")
		visual.specialText2 = healthbar:CreateFontString(nil, "OVERLAY")
		visual.healthborder = healthbar:CreateTexture(nil, "ARTWORK")
		visual.threatborder = healthbar:CreateTexture(nil, "OVERLAY")
		visual.castborder = castbar:CreateTexture(nil, "ARTWORK")
		visual.castnostop = castbar:CreateTexture(nil, "ARTWORK")
		visual.spellicon = castbar:CreateTexture(nil, "OVERLAY")
		visual.dangerskull = healthbar:CreateTexture(nil, "OVERLAY")
		visual.raidicon = healthbar:CreateTexture(nil, "OVERLAY")
		visual.eliteicon = healthbar:CreateTexture(nil, "OVERLAY")
		visual.name = extended:CreateFontString(nil, "ARTWORK")
		visual.level = extended:CreateFontString(nil, "OVERLAY")

		visual.highlight = regions.highlight

		visual.raidicon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
		visual.dangerskull:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")

		OnNewNameplate(plate)
	end
end
