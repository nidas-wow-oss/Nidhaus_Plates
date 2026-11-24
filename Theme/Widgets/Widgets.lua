local ADDON_NAME = ...

NidhausPlatesThemeWidgets = NidhausPlatesThemeWidgets or {}
local db
local _

NidhausPlatesUtility:EnableGroupWatcher()
NidhausPlatesWidgets:EnableTankWatch()

local function OnInitialize(plate)
	db = NidhausPlatesTheme.db.profile
	local w = plate.widgets

	if db.arenaPartyIDWidget and db.arenaPartyIDWidget.ON then
		if not w.ArenaPartyID then
			local widget = NidhausPlatesThemeWidgets.CreateArenaPartyIDWidget(plate)
			widget:SetFrameLevel(plate:GetFrameLevel() + 3)
			widget:SetAllPoints(plate)
			w.ArenaPartyID = widget
		end
	elseif w.ArenaPartyID then
		w.ArenaPartyID:Hide()
		w.ArenaPartyID = nil
	end

	if db.socialWidget.ON then
		if not w.SocialArt then
			local widget = NidhausPlatesThemeWidgets.CreateSocialWidget(plate)
			widget:SetFrameLevel(plate:GetFrameLevel() + 2)
			widget:SetHeight(db.socialWidget.scale)
			widget:SetWidth(db.socialWidget.scale)
			widget:SetPoint("CENTER", plate, db.socialWidget.anchor, db.socialWidget.x, db.socialWidget.y)
			w.SocialArt = widget
		end
	elseif w.SocialArt then
		w.SocialArt:Hide()
		w.SocialArt = nil
	end

	if db.totemWidget.ON then
		if not w.TotemIconWidget then
			local widget = NidhausPlatesThemeWidgets.CreateTotemIconWidget(plate)
			widget:SetHeight(db.totemWidget.scale)
			widget:SetWidth(db.totemWidget.scale)
			widget:SetFrameLevel(plate:GetFrameLevel() + 1)
			widget:SetPoint(db.totemWidget.anchor, plate, (db.totemWidget.x), (db.totemWidget.y))
			w.TotemIconWidget = widget
		end
	elseif w.TotemIconWidget then
		w.TotemIconWidget:Hide()
		w.TotemIconWidget = nil
	end

	if db.uniqueWidget.ON then
		if not w.UniqueIconWidget then
			local widget = NidhausPlatesThemeWidgets.CreateUniqueIconWidget(plate)
			widget:SetHeight(db.uniqueWidget.scale)
			widget:SetWidth(db.uniqueWidget.scale)
			widget:SetFrameLevel(plate:GetFrameLevel() + 1)
			widget:SetPoint(db.uniqueWidget.anchor, plate, (db.uniqueWidget.x), (db.uniqueWidget.y))
			w.UniqueIconWidget = widget
		end
	elseif w.UniqueIconWidget then
		w.UniqueIconWidget:Hide()
		w.UniqueIconWidget = nil
	end

	if db.targetWidget.ON then
		if not w.TargetArt then
			local widget = NidhausPlatesThemeWidgets.CreateTargetFrameArt(plate)
			widget:SetPoint("CENTER", plate, "CENTER", 0, 0)
			w.TargetArt = widget
		end
	elseif w.TargetArt then
		w.TargetArt:Hide()
		w.TargetArt = nil
	end

	if db.classWidget.ON then
		if not w.ClassIconWidget then
			local widget = NidhausPlatesThemeWidgets.CreateClassIconWidget(plate)
			widget:SetHeight(db.classWidget.scale)
			widget:SetWidth(db.classWidget.scale)
			widget:SetPoint((db.classWidget.anchor), plate, (db.classWidget.x), (db.classWidget.y))
			w.ClassIconWidget = widget
		end
	elseif w.ClassIconWidget then
		w.ClassIconWidget:Hide()
		w.ClassIconWidget = nil
	end

	if db.settings.elitehealthborder.show then
		if not w.EliteOverlay then
			local widget = NidhausPlatesThemeWidgets.CreateEliteFrameArtOverlay(plate)
			widget:SetPoint("CENTER", plate, "CENTER", 0, 0)
			w.EliteOverlay = widget
		end
	elseif w.EliteOverlay then
		w.EliteOverlay:Hide()
		w.EliteOverlay = nil
	end

	if db.threat.art.ON and db.threat.ON then
		if not w.ThreatArtWidget then
			local widget = NidhausPlatesThemeWidgets.CreateThreatArtWidget(plate)
			widget:SetPoint("CENTER", plate, "CENTER", 0, 0)
			w.ThreatArtWidget = widget
		end
	elseif w.ThreatArtWidget then
		w.ThreatArtWidget:Hide()
		w.ThreatArtWidget = nil
	end

	if db.threatWidget.ON then
		if not w.ThreatLineWidget then
			local widget = NidhausPlatesWidgets.CreateThreatLineWidget(plate)
			widget:SetPoint(db.threatWidget.anchor, plate, db.threatWidget.x, db.threatWidget.y)
			widget:SetFrameLevel(plate:GetFrameLevel() + 3)
			w.ThreatLineWidget = widget
		end
	elseif w.ThreatLineWidget then
		w.ThreatLineWidget:Hide()
		w.ThreatLineWidget = nil
	end

	if db.comboWidget.ON then
		if not w.ComboPoints then
			local widget = NidhausPlatesThemeWidgets.CreateComboPointWidget(plate)
			widget:SetPoint("CENTER", plate, (db.comboWidget.x), db.comboWidget.y)
			w.ComboPoints = widget
		end
	elseif w.ComboPoints then
		w.ComboPoints:Hide()
		w.ComboPoints = nil
	end
end

local function OnContextUpdate(plate, unit)
	db = NidhausPlatesTheme.db.profile
	local w = plate.widgets

	if db.comboWidget.ON then
		if not w.ComboPoints then
			OnInitialize(plate)
		end
		w.ComboPoints:SetPoint("CENTER", plate, (db.comboWidget.x), db.comboWidget.y)
		w.ComboPoints:UpdateContext(unit)
	end

	if db.threatWidget.ON and unit.class == "UNKNOWN" then
		if not w.ThreatLineWidget then
			OnInitialize(plate)
		end
		w.ThreatLineWidget:SetPoint("CENTER", plate, (db.threatWidget.x), db.threatWidget.y)
		w.ThreatLineWidget:UpdateContext(unit)
	end
end

local function OnUpdate(plate, unit)
	db = NidhausPlatesTheme.db.profile
	local w = plate.widgets

	if db.targetWidget.ON then
		if not w.TargetArt then
			OnInitialize(plate)
		end
		w.TargetArt:Update(unit)
	end

	if db.settings.elitehealthborder.show then
		if not w.EliteOverlay then
			OnInitialize(plate)
		end
		w.EliteOverlay:Update(unit)
	end

	if db.arenaPartyIDWidget and db.arenaPartyIDWidget.ON then
		if not w.ArenaPartyID then
			OnInitialize(plate)
		end
		w.ArenaPartyID:Update(unit)
	end

	if db.socialWidget.ON then
		if not w.SocialArt then
			OnInitialize(plate)
		end
		w.SocialArt:SetHeight(db.socialWidget.scale)
		w.SocialArt:SetWidth(db.socialWidget.scale)
		w.SocialArt:SetPoint("CENTER", plate, db.socialWidget.anchor, db.socialWidget.x, db.socialWidget.y)
		w.SocialArt:Update(unit)
	end

	if db.classWidget.ON then
		if not w.ClassIconWidget then
			OnInitialize(plate)
		end
		w.ClassIconWidget:SetHeight(db.classWidget.scale)
		w.ClassIconWidget:SetWidth(db.classWidget.scale)
		w.ClassIconWidget:SetPoint((db.classWidget.anchor), plate, (db.classWidget.x), (db.classWidget.y))
		w.ClassIconWidget:Update(unit)
	end

	if db.totemWidget.ON then
		if not w.TotemIconWidget then
			OnInitialize(plate)
		end
		w.TotemIconWidget:SetHeight(db.totemWidget.scale)
		w.TotemIconWidget:SetWidth(db.totemWidget.scale)

		w.TotemIconWidget:Update(unit)
	end

	if db.uniqueWidget.ON then
		if not w.UniqueIconWidget then
			OnInitialize(plate)
		end
		w.UniqueIconWidget:SetHeight(db.uniqueWidget.scale)
		w.UniqueIconWidget:SetWidth(db.uniqueWidget.scale)
		w.UniqueIconWidget:SetPoint(db.uniqueWidget.anchor, plate, (db.uniqueWidget.x), (db.uniqueWidget.y))
		w.UniqueIconWidget:Update(unit)
	end

	if db.threat.ON and db.threat.art.ON then
		if not w.ThreatArtWidget then
			OnInitialize(plate)
		end
		w.ThreatArtWidget:Update(unit)
	end
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		local arg1 = ...
		if arg1 == ADDON_NAME then
			NidhausPlatesThemeList["Nidhaus Plates"].OnInitialize = OnInitialize
			NidhausPlatesThemeList["Nidhaus Plates"].OnUpdate = OnUpdate
			NidhausPlatesThemeList["Nidhaus Plates"].OnContextUpdate = OnContextUpdate
		end
	end
end)
f:RegisterEvent("ADDON_LOADED")
