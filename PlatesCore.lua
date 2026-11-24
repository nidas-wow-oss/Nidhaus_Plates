local addonName, NidhausPlates = ...
_G.NidhausPlates = NidhausPlates

NidhausPlates.callbacks = NidhausPlates.callbacks or LibStub("CallbackHandler-1.0"):New(NidhausPlates)

local _
local numChildren = -1
local activetheme = {}

local weaktable = {__mode = "k"}

local massQueue = setmetatable({}, weaktable)
local functionQueue = setmetatable({}, weaktable)
local targetQueue = setmetatable({}, weaktable)

local ForEachPlate
local EMPTY_TEXTURE = "Interface\\Addons\\Nidhaus_Plates\\Media\\Empty"

local ART = "Interface\\AddOns\\Nidhaus_Plates\\Theme\\Media\\Artwork\\"

NidhausPlates_RoundHealth = false
NidhausPlates_HealthBorder = "thin"
NidhausPlates_TargetStyle = "line"
NidhausPlates_MouseStyle  = "line"
NidhausPlates_CastGlow    = true
NidhausPlates_HealthGlow  = "soft"

function NidhausPlates_RefreshLightBorder()
	local t = _G.NidhausPlatesTheme
	local prof = t and t.db and t.db.profile

	local hb = prof and prof.healthBorder
	if not hb then
		local s = prof and prof.settings and prof.settings.healthborder
		hb = (s and s.show == false) and "none" or "thin"
	end
	NidhausPlates_HealthBorder = hb

	local st = prof and prof.settings
	local ts = prof and prof.targetStyle
	if not ts then
		ts = (st and st.target and st.target.texture == "Empty") and "none" or "line"
	end
	NidhausPlates_TargetStyle = ts
	local ms = prof and prof.mouseStyle
	if not ms then
		ms = (st and st.highlight and st.highlight.texture == "Empty") and "none" or "line"
	end
	NidhausPlates_MouseStyle = ms

	NidhausPlates_CastGlow    = not (prof and prof.castGlow == false)
	NidhausPlates_RoundHealth = (prof and prof.roundHealth) and true or false
	NidhausPlates_HealthGlow  = (prof and prof.healthGlow) or "soft"
end

local bordeCache = {}
local function GetBorderBackdrop(file, size)
	local key = file .. size
	local bd = bordeCache[key]
	if not bd then
		bd = { edgeFile = file, edgeSize = size }
		bordeCache[key] = bd
	end
	return bd
end

local function ApplyBorder(f)
	local w, h = f:GetWidth() or 0, f:GetHeight() or 0
	local m = (w < h) and w or h
	local size = 8
	if m > 0 then
		size = math.floor(m / 2)
		if size > 8 then size = 8 elseif size < 2 then size = 2 end
	end
	if f.bdSize == size and f.bdFile == f.wantFile then return end

	local r, g, b, a = 1, 1, 1, 1
	if f.bdSize then r, g, b, a = f:GetBackdropBorderColor() end
	f:SetBackdrop(GetBorderBackdrop(f.wantFile, size))
	f:SetBackdropBorderColor(r, g, b, a)
	f.bdSize, f.bdFile = size, f.wantFile
end

local function SetBorderFile(f, file)
	f.wantFile = file
	ApplyBorder(f)
end

local function SetBorderShape(f, round)
	f.isRound = round and true or false
	SetBorderFile(f, ART .. (round and "Border_Rounded" or "Border_Light"))
end

local function HealthBorderFile(round, mode)
	return ART .. "Border_" .. (round and "Round" or "Square")
		.. "_" .. (mode == "thick" and "Thick" or "Thin")
end

local function CreateLightBorder(parent, target, pad, round)
	local f = CreateFrame("Frame", nil, parent)
	f:SetFrameLevel(parent:GetFrameLevel() + 1)
	f:SetPoint("TOPLEFT", target, "TOPLEFT", -pad, pad)
	f:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT", pad, -pad)
	f:SetScript("OnSizeChanged", ApplyBorder)
	SetBorderShape(f, round)
	f:Hide()
	return f
end

local GLOW_TEX  = ART .. "Cast_Glow"

local GLOW_TEX_SQ = ART .. "Cast_Glow_Square"

local GLOW_TEX_RING = ART .. "Cast_Glow_Ring"
local GLOW_SIZE = 7

local function LayoutGlow(f)
	local h = f:GetHeight() or 0
	local round = f.round and not f.cuadrado and h > 0
	local r, S = 0, GLOW_SIZE
	if round then
		r = h * 0.25
		S = r * 2.8
	end
	local key = (round and "r" or "s") .. S
	if f.layoutKey == key then return end
	f.layoutKey = key
	local p = f.p
	local C = S + r
	local esquina = round and GLOW_TEX_RING or GLOW_TEX_SQ
	local lado = round and GLOW_TEX or GLOW_TEX_SQ
	for _, n in ipairs({"tl", "tr", "bl", "br"}) do
		p[n]:SetTexture(esquina)
		p[n]:SetWidth(C)
		p[n]:SetHeight(C)
		p[n]:ClearAllPoints()
	end
	for _, n in ipairs({"top", "bottom", "left", "right"}) do
		p[n]:SetTexture(lado)
		p[n]:ClearAllPoints()
	end
	p.tl:SetPoint("BOTTOMRIGHT", f, "TOPLEFT", r, -r)
	p.tr:SetPoint("BOTTOMLEFT", f, "TOPRIGHT", -r, -r)
	p.bl:SetPoint("TOPRIGHT", f, "BOTTOMLEFT", r, r)
	p.br:SetPoint("TOPLEFT", f, "BOTTOMRIGHT", -r, r)
	p.top:SetPoint("BOTTOMLEFT", f, "TOPLEFT", r, 0)
	p.top:SetPoint("TOPRIGHT", f, "TOPRIGHT", -r, S)
	p.bottom:SetPoint("TOPLEFT", f, "BOTTOMLEFT", r, 0)
	p.bottom:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -r, -S)
	p.left:SetPoint("TOPRIGHT", f, "TOPLEFT", 0, -r)
	p.left:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", -S, r)
	p.right:SetPoint("TOPLEFT", f, "TOPRIGHT", 0, -r)
	p.right:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", S, r)
end

local function CreateCastGlow(castbar, target, cuadrado)
	local f = CreateFrame("Frame", nil, castbar)
	f:SetAllPoints(target or castbar)
	local piezas, p = {}, {}
	local function Pieza(n, l, r, t, b)
		local tx = f:CreateTexture(nil, "BACKGROUND")
		tx:SetTexCoord(l, r, t, b)
		tx:SetBlendMode("ADD")
		piezas[#piezas + 1] = tx
		p[n] = tx
	end
	Pieza("tl", 0, .5, 0, .5)
	Pieza("tr", .5, 1, 0, .5)
	Pieza("bl", 0, .5, .5, 1)
	Pieza("br", .5, 1, .5, 1)
	Pieza("top", .5, .5, 0, .5)
	Pieza("bottom", .5, .5, .5, 1)
	Pieza("left", 0, .5, .5, .5)
	Pieza("right", .5, 1, .5, .5)
	f.piezas, f.p = piezas, p
	f.cuadrado = cuadrado
	f.round = false
	LayoutGlow(f)

	f:SetScript("OnSizeChanged", LayoutGlow)
	f:Hide()
	return f
end

local function SetGlowShape(f, round)
	if not f then return end
	f.round = round and true or false
	LayoutGlow(f)
end

local function ColorGlow(f, r, g, b, a)
	for _, tx in ipairs(f.piezas) do
		tx:SetVertexColor(r, g, b, a)
	end
end

local function IsEmptyTexture(tex)
	return tex and string.find(tex, "Empty$") and true or false
end

local function HasVisibleBar(barstyle)
	return barstyle and not IsEmptyTexture(barstyle.texture)
end

local select, pairs, tostring = select, pairs, tostring
local CreateNidhausPlatesStatusbar = CreateNidhausPlatesStatusbar

local Plates = setmetatable({}, weaktable)
local PlatesVisible = setmetatable({}, weaktable)
local PlatesFading = setmetatable({}, weaktable)
local GUID = setmetatable({}, weaktable)

local nameplate, extended, bars, regions, visual
local unit, unitcache, style, stylename, unitchanged
local currentTarget
local extendedSetAlpha, HighlightIsShown, HighlightSetAlpha
local PlateSetAlpha, PlateGetAlpha
local InCombat, HasTarget = false, false
NidhausPlates.InCombat = InCombat

local function ClearIndices(t)
	if t then
		for i, v in pairs(t) do
			t[i] = nil
		end
		return t
	end
end
local function IsPlateShown(plate)
	return plate and plate:IsShown()
end
local function SetTargetQueue(plate, func)
	if func then
		targetQueue[plate] = func
	end
end
local function SetMassQueue(func)
	if func then
		massQueue[func] = true
	end
end
local function SetFunctionQueue(func)
	if func then
		functionQueue[func] = true
	end
end

local UpdateIndicator_CustomScaleText, UpdateIndicator_Standard, UpdateIndicator_CustomAlpha
local UpdateIndicator_Level, UpdateIndicator_ThreatGlow, UpdateIndicator_Target, UpdateIndicator_RaidIcon, UpdateIndicator_EliteIcon, UpdateIndicator_UnitColor, UpdateIndicator_Name
local UpdateIndicator_HealthBar, UpdateHitboxShape

local OnNewNameplate, OnShowNameplate, OnHideNameplate, OnUpdateNameplate, OnResetNameplate, OnEchoNewNameplate
local OnUpdateHealth, OnUpdateLevel, OnUpdateThreatSituation, OnUpdateRaidIcon, OnUpdateHealthRange
local OnMouseoverNameplate, OnRequestWidgetUpdate, OnRequestDelegateUpdate
local OnShowCastbar, OnHideCastbar, OnValueChangedCastbar

local StartCastAnimation, StopCastAnimation, OnUpdateTargetCastbar

local OnUpdate
local ApplyPlateExtension

local function SetObjectShape(object, width, height)
	object:SetWidth(width)
	object:SetHeight(height)
end
local function SetObjectFont(object, font, size, flags)
	object:SetFont(font, size, flags)
end
local function SetObjectJustify(object, horz, vert)
	object:SetJustifyH(horz)
	object:SetJustifyV(vert)
end
local function SetObjectShadow(object, shadow)
	if shadow then
		object:SetShadowColor(0, 0, 0, tonumber(shadow) or 1)
		object:SetShadowOffset(.5, -.5)
	else
		object:SetShadowColor(0, 0, 0, 0)
	end
end
local function SetObjectAnchor(object, anchor, anchorTo, x, y)
	object:ClearAllPoints()
	object:SetPoint(anchor, anchorTo, anchor, x, y)
end
local function SetObjectTexture(object, texture)
	object:SetTexture(texture)
	object:SetTexCoord(0, 1, 0, 1)
end
local function SetObjectBartexture(obj, tex, ori, crop)
	obj:SetStatusBarTexture(tex)
	obj:SetOrientation(ori)
end

local function SetFontGroupObject(object, objectstyle)
	SetObjectFont(object, objectstyle.typeface, objectstyle.size, objectstyle.flags)
	SetObjectJustify(object, objectstyle.align, objectstyle.vertical)
	SetObjectShadow(object, objectstyle.shadow)
end

local function SetAnchorGroupObject(object, objectstyle, anchorTo)
	SetObjectShape(object, objectstyle.width, objectstyle.height)
	SetObjectAnchor(object, objectstyle.anchor, anchorTo, objectstyle.x, objectstyle.y)
end

local backdropTable = {}
local function SetBarGroupObject(object, objectstyle, anchorTo)
	SetObjectShape(object, objectstyle.width, objectstyle.height)
	SetObjectAnchor(object, objectstyle.anchor, anchorTo, objectstyle.x, objectstyle.y)
	SetObjectBartexture(object, objectstyle.texture, objectstyle.orientation, objectstyle.texcoord)
	backdropTable.bgFile = objectstyle.backdrop
	object:SetBackdrop(backdropTable)
	if objectstyle.backdropcolor then
		object:SetBackdropColor(unpack(objectstyle.backdropcolor))
	end
end
local function MatchTextWidth()
	local stringwidth = visual.name:GetStringWidth() or 100
	bars.healthbar:SetWidth(stringwidth + style.healthbar.width)
	visual.healthborder:SetWidth(stringwidth + style.healthborder.width)
	visual.target:SetWidth(stringwidth + style.target.width)
	extended:SetWidth(stringwidth + style.frame.width)
end

local UpdateStyle
do

	local fontgroup = {"name", "level", "spelltext", "customtext"}
	local anchorgroup = {"healthborder", "threatborder", "castborder", "castnostop", "name", "spelltext", "customtext", "level", "customart", "spellicon", "raidicon", "skullicon", "eliteicon", "target"}
	local bargroup = {"castbar", "healthbar"}
	local texturegroup = {"castborder", "castnostop", "healthborder", "threatborder", "eliteicon", "skullicon", "highlight", "target"}

	function UpdateStyle()

		SetAnchorGroupObject(extended, style.frame, nameplate)

		for index = 1, #anchorgroup do
			local objectname = anchorgroup[index]
			SetAnchorGroupObject(visual[objectname], style[objectname], extended)
			if style[objectname].show then
				visual[objectname]:Show()
			else
				visual[objectname]:Hide()
			end
		end

		for index = 1, #bargroup do
			local objectname = bargroup[index]
			SetBarGroupObject(bars[objectname], style[objectname], extended)
		end

		for index = 1, #texturegroup do
			local objectname = texturegroup[index]
			SetObjectTexture(visual[objectname], style[objectname].texture)
		end

		for index = 1, #fontgroup do
			local objectname = fontgroup[index]
			SetFontGroupObject(visual[objectname], style[objectname])
		end

		if unit.isElite then
			visual.eliteicon:Hide()
		else
			visual.eliteicon:Hide()
		end
		if unit.isBoss then
			visual.level:Hide()
		else
			visual.skullicon:Hide()
		end

		visual.target:Hide()
		visual.highlight:Hide()
		if not unit.isTarget then
			if visual.roundTarget then visual.roundTarget:Hide() end
			if visual.targetGlow then visual.targetGlow:Hide() end
		end
		if not unit.isMarked then
			visual.raidicon:Hide()
		end
		if activetheme.SetStatusbarWidthMatching then
			MatchTextWidth()
		end

		local mode = NidhausPlates_HealthBorder
		local round = NidhausPlates_RoundHealth
		local file = HealthBorderFile(round, mode)
		visual.healthborder:Hide()

		visual.threatborder:SetAlpha(0)
		visual.castborder:Hide()
		visual.castnostop:Hide()
		local function Borde(f, mostrar)
			if not f then return end
			if mode ~= "none" and mostrar then
				SetBorderFile(f, file)
				f:Show()
			else
				f:Hide()
			end
		end

		bars.healthbar:SetRound(round)
		bars.castbar:SetRound(round)
		Borde(visual.lightHealth, HasVisibleBar(style.healthbar))
		Borde(visual.lightCast, HasVisibleBar(style.castbar))
		Borde(visual.lightIcon, HasVisibleBar(style.castbar) and style.spellicon.show)

		if visual.roundTarget then SetBorderFile(visual.roundTarget, HealthBorderFile(round, "thick")) end
		if visual.roundHighlight then SetBorderFile(visual.roundHighlight, HealthBorderFile(round, "thin")) end
		SetGlowShape(visual.castGlow, round)
		SetGlowShape(visual.iconGlow, round)
		SetGlowShape(visual.healthGlow, round)
		SetGlowShape(visual.targetGlow, round)
		SetGlowShape(visual.mouseGlow, round)
	end
end

do
	local color = {}
	local threatborder, alpha, forcealpha, scale

	function UpdateIndicator_HealthBar()
		bars.healthbar:SetMinMaxValues(bars.health:GetMinMaxValues())
		bars.healthbar:SetValue(bars.health:GetValue())
	end

	function UpdateIndicator_Name()
		visual.name:SetText(unit.name)

		if activetheme.SetNameColor then
			visual.name:SetTextColor(activetheme.SetNameColor(unit))
		else
			visual.name:SetTextColor(1, 1, 1, 1)
		end
		if activetheme.SetStatusbarWidthMatching then
			MatchTextWidth()
		end
	end

	function UpdateIndicator_Level()
		visual.level:SetText(unit.level)
		local tr, tg, tb = regions.level:GetTextColor()
		visual.level:SetTextColor(tr, tg, tb)
	end

	function UpdateIndicator_ThreatGlow()
		local glow = visual.healthGlow
		if not style.threatborder.show then
			if glow then glow:Hide() end
			return
		end
		threatborder = visual.threatborder
		local r, g, b, a = 0, 0, 0, 0
		if activetheme.SetThreatColor then
			r, g, b, a = activetheme.SetThreatColor(unit)
			threatborder:SetVertexColor(r, g, b, a)
		else
			if InCombat and unit.reaction ~= "FRIENDLY" and unit.type == "NPC" then
				color.r = style.threatcolor[unit.threatSituation].r
				color.g = style.threatcolor[unit.threatSituation].g
				color.b = style.threatcolor[unit.threatSituation].b
				color.a = style.threatcolor[unit.threatSituation].a
				r, g, b, a = color.r, color.g, color.b, (color.a or 1)
				threatborder:Show()
				threatborder:SetVertexColor(r, g, b, a)
			else
				threatborder:Hide()
			end
		end

		if not (InCombat and unit.type == "NPC" and unit.reaction ~= "FRIENDLY") then
			a = 0
		end
		local mode = NidhausPlates_HealthGlow
		threatborder:SetAlpha((mode == "classic" and (a or 0) > 0) and 1 or 0)
		if glow then
			if mode == "soft" and threatborder:IsShown() and (a or 0) > 0 then
				for _, tx in ipairs(glow.piezas) do
					tx:SetVertexColor(r, g, b, a)
				end
				glow:Show()
			else
				glow:Hide()
			end
		end
	end

	function UpdateIndicator_Target()

		local ts = NidhausPlates_TargetStyle
		local on = unit.isTarget and style.target.show and HasVisibleBar(style.healthbar)
		visual.target:Hide()

		local tr, tg, tb = 1, 1, 1
		local th = _G.NidhausPlatesTheme
		local tw = th and th.db and th.db.profile and th.db.profile.targetWidget
		if tw then tr, tg, tb = tw.r or 1, tw.g or 1, tw.b or 1 end
		if visual.roundTarget then
			if on and (ts == "line" or ts == "both") then
				visual.roundTarget:SetBackdropBorderColor(tr, tg, tb, 1)
				visual.roundTarget:Show()
			else
				visual.roundTarget:Hide()
			end
		end
		if visual.targetGlow then
			if on and (ts == "glow" or ts == "both") then
				ColorGlow(visual.targetGlow, tr, tg, tb, 0.9)
				visual.targetGlow:Show()
			else
				visual.targetGlow:Hide()
			end
		end
	end

	function UpdateIndicator_RaidIcon()
		if unit.isMarked and style.raidicon.show then
			visual.raidicon:Show()
			visual.raidicon:SetTexCoord(regions.raidicon:GetTexCoord())
		else
			visual.raidicon:Hide()
		end
	end

	function UpdateIndicator_EliteIcon()
		threatborder = visual.threatborder
		if unit.isElite and style.eliteicon.show then
			visual.eliteicon:Show()
		else
			visual.eliteicon:Hide()
		end
	end

	function UpdateIndicator_UnitColor()

		if activetheme.SetHealthbarColor then

			bars.healthbar:SetStatusBarSmartGradient(activetheme.SetHealthbarColor(unit))
		else
			bars.healthbar:SetForegroundColor(bars.health:GetStatusBarColor())
		end

		if activetheme.SetNameColor then
			visual.name:SetTextColor(activetheme.SetNameColor(unit))
		else
			visual.name:SetTextColor(1, 1, 1, 1)
		end
	end

	function UpdateIndicator_Standard()
		if IsPlateShown(nameplate) then
			if unitcache.name ~= unit.name then
				UpdateIndicator_Name()
			end
			if unitcache.level ~= unit.level then
				UpdateIndicator_Level()
			end
			UpdateIndicator_RaidIcon()
			if unitcache.isElite ~= unit.isElite then
				UpdateIndicator_EliteIcon()
			end
		end
	end

	function UpdateIndicator_CustomAlpha()
		if activetheme.SetAlpha then
			local previousAlpha = extended.requestedAlpha
			extended.requestedAlpha = activetheme.SetAlpha(unit) or previousAlpha or unit.alpha or 1
		else
			extended.requestedAlpha = unit.alpha or 1
		end

		if not PlatesFading[nameplate] then
			extended:SetAlpha(extended.requestedAlpha)
		end
	end

	function UpdateIndicator_CustomScaleText()
		threatborder = visual.threatborder

		if unit.health and (extended.requestedAlpha > 0) then

			if activetheme.SetScale then
				scale = activetheme.SetScale(unit)
				if scale then
					extended:SetScale(math.max(0.0001, scale))
					UpdateHitboxShape()
				end
			end

			if style.customtext.show then
				if activetheme.SetCustomText then
					local text, r, g, b, a = activetheme.SetCustomText(unit)
					visual.customtext:SetText(text or "")
					visual.customtext:SetTextColor(r or 1, g or 1, b or 1, a or 1)
				else
					visual.customtext:SetText("")
				end
			end
			if style.customart.show then
				if activetheme.SetCustomArt then
					visual.customart:SetTexture(activetheme.SetCustomArt(unit))
				else
					visual.customart:SetTexture(EMPTY_TEXTURE)
				end
			end
			UpdateIndicator_UnitColor()
		end
	end

	function UpdateHitboxShape()

		if InCombatLockdown() then return end
		local box, hb, fr = style.hitbox, style.healthbar, style.frame
		local pw, ph = box.width, box.height
		local s = extended:GetScale() or 1

		local w, h = pw, ph
		local cx, cy = (fr.x or 0), (fr.y or 0)

		local ow, oh
		if activetheme.HitboxOverride then
			ow, oh = activetheme.HitboxOverride(unit, extended.stylename)
		end
		if ow and oh then
			w, h = ow, oh
		elseif hb and hb.show ~= false then

			w, h = bars.healthbar:GetWidth(), bars.healthbar:GetHeight()
			cx, cy = cx + (hb.x or 0), cy + (hb.y or 0)
		end
		w, h, cx, cy = w * s, h * s, cx * s, cy * s

		if nameplate.hitPW == pw and nameplate.hitPH == ph and nameplate.hitW == w
			and nameplate.hitH == h and nameplate.hitCX == cx and nameplate.hitCY == cy then
			return
		end
		nameplate.hitPW, nameplate.hitPH, nameplate.hitW, nameplate.hitH = pw, ph, w, h
		nameplate.hitCX, nameplate.hitCY = cx, cy

		SetObjectShape(nameplate, pw, ph)

		nameplate:SetHitRectInsets(
			cx - w / 2 + pw / 2,
			pw / 2 - cx - w / 2,
			ph / 2 - cy - h / 2,
			cy - h / 2 + ph / 2
		)
	end
end

local UpdateReferences
do

	local function UpdateUnitCache()
		for key, value in pairs(unit) do
			unitcache[key] = value
		end
	end

	function UpdateReferences(plate)
		nameplate = plate
		extended = plate.extended
		bars = extended.bars
		regions = extended.regions
		unit = extended.unit
		unitcache = extended.unitcache
		visual = extended.visual
		style = extended.style
	end

	local ClassReference = {}

	local function ColorToString(r, g, b)
		return "C" .. math.floor((100 * r) + 0.5) .. math.floor((100 * g) + 0.5) .. math.floor((100 * b) + 0.5)
	end

	local function GetUnitCombatStatus(r, g, b)
		return (r > .5 and g < .5)
	end

	local GetUnitAggroStatus
	do
		local shown
		local red, green, blue
		function GetUnitAggroStatus(region)

			shown = region:IsShown()
			if not shown then
				return "LOW", 0
			end
			red, green, blue = region:GetVertexColor()
			if red > 0 then
				if green > 0 then
					if blue > 0 then
						return "MEDIUM", 1
					end
					return "MEDIUM", 2
				end
				return "HIGH", 3
			end
		end
	end

	local function GetUnitReaction(red, green, blue)
		if red < .01 and blue < .01 and green > .99 then
			return "FRIENDLY", "NPC"
		elseif red < .01 and blue > .99 and green < .01 then
			return "FRIENDLY", "PLAYER"
		elseif red > .99 and blue < .01 and green > .99 then
			return "NEUTRAL", "NPC"
		elseif red > .99 and blue < .01 and green < .01 then
			return "HOSTILE", "NPC"
		else
			return "HOSTILE", "PLAYER"
		end
	end

	local ux, uy
	local RaidIconCoordinate = {

		[0] = {[0] = "STAR", [0.25] = "MOON"},
		[0.25] = {[0] = "CIRCLE", [0.25] = "SQUARE"},
		[0.5] = {[0] = "DIAMOND", [0.25] = "CROSS"},
		[0.75] = {[0] = "TRIANGLE", [0.25] = "SKULL"}
	}

	for classname, color in pairs(RAID_CLASS_COLORS) do
		ClassReference[ColorToString(color.r, color.g, color.b)] = classname
	end

	local function GatherData_Alpha(plate)
		if HasTarget then
			unit.alpha = plate.alpha
		else
			unit.alpha = 1
		end

		unit.isTarget = HasTarget and unit.alpha == 1
		unit.isMouseover = regions.highlight:IsShown()

		if unit.isTarget then
			currentTarget = plate
			OnUpdateTargetCastbar(plate)
			if not unit.guid then

				unit.guid = UnitGUID("target")
				if unit.guid then
					GUID[unit.guid] = plate
				end
			end
			extended:SetFrameLevel(127)
		else
			extended:SetFrameLevel(extended.frameLevel)
		end

		UpdateIndicator_Target()
		if activetheme.OnContextUpdate then
			activetheme.OnContextUpdate(extended, unit)
		end
	end

	local function GatherData_BasicInfo()
		unit.name = regions.name:GetText()
		unit.isBoss = regions.skullicon:IsShown()
		unit.isDangerous = unit.isBoss
		unit.isElite = (regions.eliteicon:IsShown() or 0) == 1

		if unit.isBoss then
			unit.level = "??"
		else
			unit.level = regions.level:GetText()
		end
		unit.health = bars.health:GetValue() or 0
		_, unit.healthmax = bars.health:GetMinMaxValues()

		if InCombat then
			unit.threatSituation, unit.threatValue = GetUnitAggroStatus(regions.threatglow)
		else
			unit.threatSituation = "LOW"
			unit.threatValue = 0
		end

		unit.isMarked = regions.raidicon:IsShown() or false

		unit.isInCombat = GetUnitCombatStatus(regions.name:GetTextColor())
		unit.red, unit.green, unit.blue = bars.health:GetStatusBarColor()
		unit.levelcolorRed, unit.levelcolorGreen, unit.levelcolorBlue = regions.level:GetTextColor()
		unit.reaction, unit.type = GetUnitReaction(unit.red, unit.green, unit.blue)
		unit.class = ClassReference[ColorToString(unit.red, unit.green, unit.blue)] or "UNKNOWN"
		unit.InCombatLockdown = InCombat

		if unit.isMarked then
			ux, uy = regions.raidicon:GetTexCoord()
			unit.raidIcon = RaidIconCoordinate[ux][uy]
		else
			unit.raidIcon = nil
		end
	end

	local function CheckNameplateStyle()
		if activetheme.SetStyle then
			stylename = activetheme.SetStyle(unit)
			extended.style = activetheme[stylename]
		else
			extended.style = activetheme
			stylename = tostring(activetheme)
		end
		style = extended.style
		if extended.stylename ~= stylename then
			UpdateStyle()
			extended.stylename = stylename
			unit.style = stylename
		end
		UpdateHitboxShape()
	end

	local function ProcessUnitChanges()

		unitchanged = false
		for key, value in pairs(unit) do
			if unitcache[key] ~= value then
				unitchanged = true
			end
		end

		if unitchanged then
			CheckNameplateStyle()
			UpdateIndicator_Standard()
			UpdateIndicator_HealthBar()
		end

		if activetheme.OnUpdate then
			activetheme.OnUpdate(extended, unit)
		end

		UpdateIndicator_Target()
		UpdateIndicator_ThreatGlow()
		UpdateIndicator_CustomAlpha()
		UpdateIndicator_CustomScaleText()

		UpdateUnitCache()
	end

	local function PrepareNameplate(plate)
		GatherData_BasicInfo()
		unit.frame = extended
		unit.alpha = 1
		unit.isTarget = false
		unit.isMouseover = false
		extended.unitcache = ClearIndices(extended.unitcache)
		extended.stylename = ""

		PlatesFading[plate] = true
		extended.requestedAlpha = 0
		extended.visibleAlpha = 0
		extended:SetAlpha(0)

		unit.isCasting = false
		bars.castbar:Hide()
		visual.highlight:Hide()
		if visual.roundHighlight then visual.roundHighlight:Hide() end
		if visual.mouseGlow then visual.mouseGlow:Hide() end
		regions.highlight:Hide()

		if activetheme.OnInitialize then
			activetheme.OnInitialize(extended)
		end
	end

	function OnHideNameplate(source)
		local plate = source.parentPlate
		UpdateReferences(plate)
		if unit.guid then
			GUID[unit.guid] = nil
		end

		bars.castbar:SetScript("OnUpdate", nil)
		bars.castbar:Hide()
		unit.isCasting = false

		PlatesVisible[plate] = nil
		extended.unit = ClearIndices(extended.unit)
		extended.unitcache = ClearIndices(extended.unitcache)
		for widgetname, widget in pairs(extended.widgets) do
			widget:Hide()
		end
		if plate == currentTarget then
			currentTarget = nil
		end
	end

	function OnEchoNewNameplate(plate)
		if not plate:IsShown() then
			return
		end

		UpdateReferences(plate)
		GatherData_Alpha(plate)
		ProcessUnitChanges()
	end

	function OnNewNameplate(plate)
		local health, cast = plate:GetChildren()
		UpdateReferences(plate)
		PrepareNameplate(plate)
		GatherData_BasicInfo()

		CheckNameplateStyle()
		UpdateIndicator_CustomAlpha()

		health:HookScript("OnShow", OnShowNameplate)
		health:HookScript("OnHide", OnHideNameplate)
		health:HookScript("OnValueChanged", OnUpdateHealth)
		health:HookScript("OnMinMaxChanged", OnUpdateHealthRange)

		cast:HookScript("OnShow", OnShowCastbar)
		cast:HookScript("OnHide", OnHideCastbar)
		cast:HookScript("OnValueChanged", OnValueChangedCastbar)

		PlatesVisible[plate] = true
		SetTargetQueue(plate, OnEchoNewNameplate)
	end

	function OnShowNameplate(source)
		local plate = source.parentPlate

		PlatesVisible[plate] = true
		UpdateReferences(plate)
		PrepareNameplate(plate)
		GatherData_BasicInfo()

		CheckNameplateStyle()
		UpdateIndicator_CustomAlpha()
		UpdateHitboxShape()

		SetTargetQueue(plate, OnUpdateNameplate)
	end

	function OnShowCastbar(cast)
		cast.castbar:SetMinMaxValues(cast:GetMinMaxValues())
	end

	function OnHideCastbar(cast)
		StopCastAnimation(cast.parentPlate)
	end

	function OnValueChangedCastbar(cast, value)
		cast.castbar:SetValue(value)
	end

	function OnUpdateNameplate(plate)
		if not plate:IsShown() then
			return
		end

		UpdateReferences(plate)
		GatherData_Alpha(plate)
		GatherData_BasicInfo()
		ProcessUnitChanges()
	end

	function OnUpdateLevel(plate)
		if not IsPlateShown(plate) then
			return
		end
		UpdateReferences(plate)
		if unit.isBoss then
			unit.level = "??"
		else
			unit.level = regions.level:GetText()
		end
		UpdateIndicator_Level()
	end

	function OnUpdateThreatSituation(plate)
		if not IsPlateShown(plate) then
			return
		end
		UpdateReferences(plate)

		if InCombat then
			unit.threatSituation, unit.threatValue = GetUnitAggroStatus(regions.threatglow)
		else
			unit.threatSituation = "LOW"
			unit.threatValue = 0
		end
		unit.isInCombat = GetUnitCombatStatus(regions.name:GetTextColor())

		CheckNameplateStyle()
		UpdateIndicator_ThreatGlow()
		UpdateIndicator_CustomAlpha()
		UpdateIndicator_CustomScaleText()
	end

	function OnUpdateRaidIcon(plate)
		if not IsPlateShown(plate) then
			return
		end
		UpdateReferences(plate)
		unit.isMarked = regions.raidicon:IsShown() or false
		if unit.isMarked then
			ux, uy = regions.raidicon:GetTexCoord()
			unit.raidIcon = RaidIconCoordinate[ux][uy]
		else
			unit.raidIcon = nil
		end
		UpdateIndicator_RaidIcon()
		UpdateIndicator_UnitColor()
	end

	function OnUpdateReaction(plate)
		if not IsPlateShown(plate) then
			return
		end
		UpdateReferences(plate)
		unit.red, unit.green, unit.blue = bars.health:GetStatusBarColor()
		unit.reaction, unit.type = GetUnitReaction(unit.red, unit.green, unit.blue)
		unit.class = ClassReference[ColorToString(unit.red, unit.green, unit.blue)] or "UNKNOWN"
		UpdateIndicator_CustomScaleText()
	end

	function OnMouseoverNameplate(plate)
		if not IsPlateShown(plate) then
			return
		end
		UpdateReferences(plate)
		unit.isMouseover = regions.highlight:IsShown()

		if unit.isMouseover then

			local ms = NidhausPlates_MouseStyle
			local bar = HasVisibleBar(style.healthbar)
			visual.highlight:Hide()
			if visual.roundHighlight then
				if bar and ms == "line" then visual.roundHighlight:Show() else visual.roundHighlight:Hide() end
			end
			if visual.mouseGlow then
				if bar and ms == "glow" then
					ColorGlow(visual.mouseGlow, 1, 1, 1, 0.5)
					visual.mouseGlow:Show()
				else
					visual.mouseGlow:Hide()
				end
			end
			if (not unit.guid) then
				unit.guid = UnitGUID("mouseover")
				if unit.guid then
					GUID[unit.guid] = plate
				end
			end
		else
			visual.highlight:Hide()
			if visual.roundHighlight then visual.roundHighlight:Hide() end
			if visual.mouseGlow then visual.mouseGlow:Hide() end
		end

		OnUpdateThreatSituation(plate)
		if activetheme.OnContextUpdate then
			activetheme.OnContextUpdate(extended, unit)
		end
		if activetheme.OnUpdate then
			activetheme.OnUpdate(extended, unit)
		end
	end

	function OnRequestWidgetUpdate(plate)
		if not IsPlateShown(plate) then
			return
		end
		UpdateReferences(plate)
		if activetheme.OnContextUpdate then
			activetheme.OnContextUpdate(extended, unit)
		end
		if activetheme.OnUpdate then
			activetheme.OnUpdate(extended, unit)
		end
	end

	function OnRequestDelegateUpdate(plate)
		if not IsPlateShown(plate) then
			return
		end
		UpdateReferences(plate)
		UpdateIndicator_ThreatGlow()
		UpdateIndicator_CustomAlpha()
		UpdateIndicator_CustomScaleText()
	end

	function OnUpdateHealth(source)
		local plate = source.parentPlate
		if not IsPlateShown(plate) then
			return
		end
		UpdateReferences(plate)
		unit.health = bars.health:GetValue() or 0
		_, unit.healthmax = bars.health:GetMinMaxValues()
		UpdateIndicator_HealthBar()
		UpdateIndicator_CustomAlpha()
		UpdateIndicator_CustomScaleText()
	end

	function OnUpdateHealthRange(source)
		local plate = source.parentPlate
		OnUpdateNameplate(plate)
	end

	local function OnUpdateTimedCast(castbar)
		local minval, maxval = castbar:GetMinMaxValues()
		local now = GetTime()
		if not maxval or now >= maxval then
			StopCastAnimation(castbar.parentPlate)
			return
		end

		if castbar.timedChannel then
			castbar:SetValue(minval + maxval - now)
		else
			castbar:SetValue(now)
		end
	end

	function StartCastAnimation(plate, spell, spellid, icon, notInterruptible, channel, startMS, endMS)
		UpdateReferences(plate)
		if (tonumber(GetCVar("showVKeyCastbar")) == 1) and spell then
			local castbar = bars.castbar
			local minval, maxval
			if startMS and endMS and endMS > startMS then
				minval, maxval = startMS / 1000, endMS / 1000
				castbar.timedChannel = channel and true or false
				castbar:SetScript("OnUpdate", OnUpdateTimedCast)
			else
				castbar:SetScript("OnUpdate", nil)
				minval, maxval = castbar.cast:GetMinMaxValues()
			end
			if not (minval or maxval) or maxval == 0 or minval == maxval then
				StopCastAnimation(plate)
				return
			end

			local r, g, b, a = 1, .8, 0, 1
			unit.isCasting = true
			unit.spellName = spell
			unit.spellID = spellid
			unit.spellIsShielded = notInterruptible
			unit.spellInterruptible = not notInterruptible

			if activetheme.SetCastbarColor then
				r, g, b, a = activetheme.SetCastbarColor(unit)
				if not (r and g and b) then
					return
				end
			end

			castbar:SetMinMaxValues(minval, maxval)
			castbar:SetForegroundColor(r, g, b, a or 1)

			if visual.castGlow then
				if NidhausPlates_CastGlow then
					for _, tx in ipairs(visual.castGlow.piezas) do
						tx:SetVertexColor(r, g, b, 0.9)
					end
					visual.castGlow:Show()
				else
					visual.castGlow:Hide()
				end
			end

			if visual.iconGlow then
				if NidhausPlates_CastGlow and style.spellicon.show then
					for _, tx in ipairs(visual.iconGlow.piezas) do
						tx:SetVertexColor(r, g, b, 0.9)
					end
					visual.iconGlow:Show()
				else
					visual.iconGlow:Hide()
				end
			end
			visual.spelltext:SetText(spell)

			visual.spellicon:SetTexture(icon)

			visual.castnostop:Hide()
			visual.castborder:Hide()
			if visual.lightCast then
				if notInterruptible then
					visual.lightCast:SetBackdropBorderColor(1, 0.25, 0.25, 1)
				else
					visual.lightCast:SetBackdropBorderColor(1, 1, 1, 1)
				end
			end

			castbar:Show()

			UpdateIndicator_CustomScaleText()
			UpdateIndicator_CustomAlpha()
		end
	end

	function StopCastAnimation(plate)
		UpdateReferences(plate)
		bars.castbar:SetScript("OnUpdate", nil)
		bars.castbar:Hide()
		unit.isCasting = false
		UpdateIndicator_CustomScaleText()
		UpdateIndicator_CustomAlpha()
	end

	function OnUpdateTargetCastbar(source)
		if not source then
			return
		end
		local plate
		if PlatesVisible[source] then
			plate = source
		else
			plate = source.parentPlate
		end

		if plate and plate.extended.unit.isTarget then

			local spell, icon, nonInt, channel, spellid

			spell, _, _, icon, _, _, _, spellid, nonInt = UnitCastingInfo("target")

			if not spell then
				spell, _, _, icon, _, _, spellid, nonInt = UnitChannelInfo("target")
				channel = true
			end

			if spell then
				StartCastAnimation(plate, spell, spellid, icon, nonInt, channel)
			else
				StopCastAnimation(plate)
			end
		end
	end

	function OnResetNameplate(plate)
		local extended = plate.extended
		extended.unitcache = ClearIndices(extended.unitcache)
		extended.stylename = ""
		OnShowNameplate(extended)
	end
end

do

	local castbar, healthbar, region
	local platelevels = 125

	local function GetNameplateRegions(plate, regions, cast)
		regions.threatglow, regions.healthborder, regions.castborder, regions.castnostop, regions.spellicon, regions.highlight, regions.name, regions.level, regions.skullicon, regions.raidicon, regions.eliteicon = plate:GetRegions()
	end

	function ApplyPlateExtension(plate)
		Plates[plate] = true
		plate.extended = CreateFrame("Frame", nil, plate)
		local extended = plate.extended
		platelevels = platelevels - 1
		if platelevels < 1 then
			platelevels = 1
		end
		extended.frameLevel = platelevels
		extended:SetFrameLevel(platelevels)

		extended.style, extended.unit, extended.unitcache, extended.stylecache, extended.widgets = {}, {}, {}, {}, {}

		extended.regions, extended.bars, extended.visual = {}, {}, {}
		regions = extended.regions
		bars = extended.bars
		bars.health, bars.cast = plate:GetChildren()
		extended.stylename = ""

		GetNameplateRegions(plate, regions, bars.cast)

		regions.threatglow:SetTexCoord(0, 0, 0, 0)
		regions.healthborder:SetTexCoord(0, 0, 0, 0)
		regions.castborder:SetTexCoord(0, 0, 0, 0)
		regions.castnostop:SetTexCoord(0, 0, 0, 0)
		regions.skullicon:SetTexCoord(0, 0, 0, 0)
		regions.eliteicon:SetTexCoord(0, 0, 0, 0)
		regions.name:SetWidth(000.1)
		regions.level:SetWidth(000.1)
		regions.spellicon:SetTexCoord(0, 0, 0, 0)
		regions.spellicon:SetWidth(.001)
		regions.raidicon:SetAlpha(0)
		regions.highlight:SetTexture(EMPTY_TEXTURE)
		bars.health:SetStatusBarTexture(EMPTY_TEXTURE)
		bars.cast:SetStatusBarTexture(EMPTY_TEXTURE)

		bars.healthbar = CreateNidhausPlatesStatusbar(extended)
		bars.castbar = CreateNidhausPlatesStatusbar(extended)
		local health, cast, healthbar, castbar = bars.health, bars.cast, bars.healthbar, bars.castbar
		extended.parentPlate = plate
		health.parentPlate = plate
		cast.parentPlate = plate
		castbar.parentPlate = plate

		cast.castbar = castbar
		castbar.cast = cast

		healthbar:SetFrameLevel(platelevels - 1)
		castbar:Hide()
		castbar:SetFrameLevel(platelevels)
		castbar:SetForegroundColor(1, .8, 0)

		visual = extended.visual
		visual.customart = extended:CreateTexture(nil, "OVERLAY")
		visual.target = extended:CreateTexture(nil, "ARTWORK")
		visual.raidicon = extended:CreateTexture(nil, "OVERLAY")
		visual.raidicon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
		visual.eliteicon = extended:CreateTexture(nil, "OVERLAY")
		visual.healthborder = healthbar:CreateTexture(nil, "ARTWORK")
		visual.threatborder = healthbar:CreateTexture(nil, "ARTWORK")
		visual.skullicon = healthbar:CreateTexture(nil, "OVERLAY")
		visual.highlight = healthbar:CreateTexture(nil, "OVERLAY")
		visual.highlight:SetAllPoints(visual.healthborder)
		visual.highlight:SetBlendMode("ADD")
		visual.castborder = castbar:CreateTexture(nil, "ARTWORK")
		visual.castnostop = castbar:CreateTexture(nil, "ARTWORK")
		visual.spellicon = castbar:CreateTexture(nil, "OVERLAY")

		for i, v in pairs(visual) do
			v:SetNonBlocking(true)
		end

		visual.lightHealth = CreateLightBorder(healthbar, healthbar, 2)
		visual.lightCast   = CreateLightBorder(castbar, castbar, 2)
		visual.lightIcon   = CreateLightBorder(castbar, visual.spellicon, 2)
		visual.castGlow    = CreateCastGlow(castbar)
		visual.healthGlow  = CreateCastGlow(healthbar)
		visual.iconGlow    = CreateCastGlow(castbar, visual.spellicon, true)
		visual.targetGlow  = CreateCastGlow(healthbar)
		visual.mouseGlow   = CreateCastGlow(healthbar)

		visual.roundTarget = CreateLightBorder(healthbar, healthbar, 3, true)

		visual.roundHighlight = CreateLightBorder(healthbar, healthbar, 3, true)
		visual.roundHighlight:SetBackdropBorderColor(1, 1, 1, 0.55)

		visual.customtext = extended:CreateFontString(nil, "OVERLAY")
		visual.name = extended:CreateFontString(nil, "OVERLAY")
		visual.level = extended:CreateFontString(nil, "OVERLAY")
		visual.spelltext = castbar:CreateFontString(nil, "OVERLAY")

		if not extendedSetAlpha then
			PlateSetAlpha = plate.SetAlpha
			PlateGetAlpha = plate.GetAlpha
			extendedSetAlpha = plate.extended.SetAlpha
			HighlightIsShown = plate.extended.visual.highlight.IsShown
		end

		OnNewNameplate(plate)
	end
end

do
	local plate, curChildren
	local WorldGetNumChildren, WorldGetChildren = WorldFrame.GetNumChildren, WorldFrame.GetChildren

	local function IsFrameNameplate(frame)
		local threatRegion, borderRegion = frame:GetRegions()
		return borderRegion and borderRegion:GetObjectType() == "Texture" and
			borderRegion:GetTexture() == "Interface\\Tooltips\\Nameplate-Border"
	end

	local function OnWorldFrameChange(...)
		for index = 1, select("#", ...) do
			plate = select(index, ...)
			if not Plates[plate] and IsFrameNameplate(plate) then
				ApplyPlateExtension(plate)
			end
		end
	end

	function ForEachPlate(functionToRun, ...)
		for plate in pairs(PlatesVisible) do
			if plate.extended:IsShown() then
				functionToRun(plate, ...)
			end
		end
	end

	local visibleAlpha, requestedAlpha
	local fadeInRate, fadeOutRate = .07, .2
	local function UpdateNameplateFade(plate)
		extended = plate.extended

		visibleAlpha = extended.visibleAlpha
		requestedAlpha = extended.requestedAlpha
		if visibleAlpha < requestedAlpha then
			visibleAlpha = visibleAlpha + fadeInRate
			extended.visibleAlpha = visibleAlpha
			extendedSetAlpha(extended, visibleAlpha)
		else
			extended.visibleAlpha = requestedAlpha
			extendedSetAlpha(extended, visibleAlpha)
			PlatesFading[plate] = nil
		end

	end

	local queuedFunction
	local HasMouseover, LastMouseover, CurrentMouseover
	local PollTime, PollIndex = 0, 0

	function OnUpdate(self)
		HasMouseover = false

		for plate in pairs(PlatesVisible) do

			if (HasTarget) then
				plate.alpha = PlateGetAlpha(plate)
				PlateSetAlpha(plate, 1)
			end

			highlightRegion = plate.extended.regions.highlight
			if HighlightIsShown(highlightRegion) then
				HasMouseover = true
				CurrentMouseover = plate
			end
		end

		for plate in pairs(PlatesFading) do
			UpdateNameplateFade(plate)
		end

		if massQueue[OnResetNameplate] then
			ForEachPlate(OnResetNameplate)
			for queuedFunction in pairs(massQueue) do
				massQueue[queuedFunction] = nil
			end
		else

			for queuedFunction, run in pairs(functionQueue) do
				queuedFunction()
				functionQueue[queuedFunction] = nil
			end

			if massQueue[OnUpdateNameplate] then
				for queuedFunction in pairs(massQueue) do
					massQueue[queuedFunction] = nil
				end
				ForEachPlate(OnUpdateNameplate)
			else
				for queuedFunction in pairs(massQueue) do
					massQueue[queuedFunction] = nil
					ForEachPlate(queuedFunction)
				end
			end

			for plate, queuedFunction in pairs(targetQueue) do
				targetQueue[plate] = nil
				queuedFunction(plate)
			end
		end

		if HasMouseover then
			if LastMouseover ~= CurrentMouseover then
				if LastMouseover then
					OnMouseoverNameplate(LastMouseover)
				end
				OnMouseoverNameplate(CurrentMouseover)
				LastMouseover = CurrentMouseover
			end
		elseif LastMouseover then
			OnMouseoverNameplate(LastMouseover)
			LastMouseover = nil
		end

		curChildren = WorldGetNumChildren(WorldFrame)
		if (curChildren ~= numChildren) then
			numChildren = curChildren
			OnWorldFrameChange(WorldGetChildren(WorldFrame))
		end
	end
end

do
	local events = {}
	local function EventHandler(self, event, ...)
		events[event](event, ...)
	end
	local PlateHandler = CreateFrame("Frame", nil, WorldFrame)
	PlateHandler:SetFrameStrata("TOOLTIP")
	PlateHandler:SetScript("OnEvent", EventHandler)

	function events:PLAYER_ENTERING_WORLD()
		PlateHandler:SetScript("OnUpdate", OnUpdate)
	end
	function events:PLAYER_REGEN_ENABLED()
		InCombat = false
		SetMassQueue(OnUpdateNameplate)
	end
	function events:PLAYER_REGEN_DISABLED()
		InCombat = true
		SetMassQueue(OnUpdateNameplate)
	end

	function events:PLAYER_TARGET_CHANGED()
		HasTarget = UnitExists("target") == 1
		if (not HasTarget) then
			currentTarget = nil
		end
		SetMassQueue(OnUpdateNameplate)
	end

	function events:RAID_TARGET_UPDATE()
		SetMassQueue(OnUpdateNameplate)
	end
	function events:UNIT_THREAT_SITUATION_UPDATE()
		SetMassQueue(OnUpdateThreatSituation)
	end
	function events:UNIT_LEVEL()
		ForEachPlate(OnUpdateLevel)
	end
	function events:PLAYER_CONTROL_LOST()
		ForEachPlate(OnUpdateReaction)
	end
	events.PLAYER_CONTROL_GAINED = events.PLAYER_CONTROL_LOST
	events.UNIT_FACTION = events.PLAYER_CONTROL_LOST

	function events:UNIT_SPELLCAST_START(unitid, spell, ...)
		if unitid == "target" and currentTarget then
			OnUpdateTargetCastbar(currentTarget)
		end
	end
	events.UNIT_SPELLCAST_STOP = events.UNIT_SPELLCAST_START
	events.UNIT_SPELLCAST_INTERRUPTED = events.UNIT_SPELLCAST_START
	events.UNIT_SPELLCAST_FAILED = events.UNIT_SPELLCAST_START
	events.UNIT_SPELLCAST_DELAYED = events.UNIT_SPELLCAST_START
	events.UNIT_SPELLCAST_CHANNEL_START = events.UNIT_SPELLCAST_START
	events.UNIT_SPELLCAST_NOT_INTERRUPTIBLE = events.UNIT_SPELLCAST_START
	events.UNIT_SPELLCAST_INTERRUPTIBLE = events.UNIT_SPELLCAST_START
	events.UNIT_SPELLCAST_CHANNEL_STOP = events.UNIT_SPELLCAST_START
	events.UNIT_SPELLCAST_FAILED_QUIET = events.UNIT_SPELLCAST_START

	for eventname in pairs(events) do
		PlateHandler:RegisterEvent(eventname)
	end
end

function NidhausPlates:ForceUpdate()
	SetMassQueue(OnResetNameplate)
end
function NidhausPlates:Update()
	SetMassQueue(OnUpdateNameplate)
end
function NidhausPlates:RequestWidgetUpdate()
	SetMassQueue(OnRequestWidgetUpdate)
end
function NidhausPlates:RequestDelegateUpdate()
	SetMassQueue(OnRequestDelegateUpdate)
end
function NidhausPlates:ActivateTheme(theme)
	if theme and type(theme) == "table" then
		NidhausPlates.ActiveThemeTable, activetheme = theme, theme
		SetMassQueue(OnResetNameplate)
	end
end

NidhausPlates.StartCastAnimationOnNameplate = StartCastAnimation
NidhausPlates.StopCastAnimationOnNameplate = StopCastAnimation
NidhausPlates.NameplatesByGUID, NidhausPlates.NameplatesAll, NidhausPlates.NameplatesByVisible = GUID, Plates, PlatesVisible
NidhausPlates.OnNewNameplate = OnNewNameplate
NidhausPlates.OnShowNameplate = OnShowNameplate
NidhausPlates.OnHideNameplate = OnHideNameplate
NidhausPlates.OnUpdateNameplate = OnUpdateNameplate
NidhausPlates.OnResetNameplate = OnResetNameplate
NidhausPlates.OnEchoNewNameplate = OnEchoNewNameplate
NidhausPlates.OnUpdateHealth = OnUpdateHealth
NidhausPlates.OnUpdateLevel = OnUpdateLevel
NidhausPlates.OnUpdateThreatSituation = OnUpdateThreatSituation
NidhausPlates.OnUpdateRaidIcon = OnUpdateRaidIcon
NidhausPlates.OnUpdateHealthRange = OnUpdateHealthRange
NidhausPlates.OnMouseoverNameplate = OnMouseoverNameplate
NidhausPlates.OnRequestWidgetUpdate = OnRequestWidgetUpdate
NidhausPlates.OnRequestDelegateUpdate = OnRequestDelegateUpdate
