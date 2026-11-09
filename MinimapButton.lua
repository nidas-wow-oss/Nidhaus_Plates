local addonName = "NidhausPlatesIcon"

local LibStub = LibStub
local LibIcon, LibDataBroker
if LibStub then
	LibIcon = LibStub("LibDBIcon-1.0", true)
	LibDataBroker = LibStub("LibDataBroker-1.1", true)
end

----------------------------------------------------------------------------------------
-- Simplified build: left-click opens the addon options. No quick menu, no middle/right click.
----------------------------------------------------------------------------------------

local L = NidhausPlates.L
local ButtonTexture = "Interface\\Addons\\Nidhaus_Plates\\media\\NidhausPlatesIcon"

local function OpenAddonOptions()
	local theme = NidhausPlatesThemeList and NidhausPlatesThemeList["Nidhaus Plates"]
	if theme and type(theme.ShowConfigPanel) == "function" then
		theme.ShowConfigPanel()
	end
end

----------------------------------------------------------------------------------------
-- Standalone Button Creation
----------------------------------------------------------------------------------------

local function CreateStandaloneIcon()
	local ButtonFrame = CreateFrame("Button", "NidhausPlatesIconFrame", UIParent)

	ButtonFrame:SetWidth(31)
	ButtonFrame:SetHeight(31)
	ButtonFrame:SetFrameStrata("LOW")
	ButtonFrame:SetToplevel(1)
	ButtonFrame:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	ButtonFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT")

	local ButtonIcon = ButtonFrame:CreateTexture("NidhausPlatesButtonIcon", "BACKGROUND")
	ButtonIcon:SetTexture(ButtonTexture)
	ButtonIcon:SetWidth(25)
	ButtonIcon:SetHeight(25)
	ButtonIcon:SetPoint("TOPLEFT", ButtonFrame, "TOPLEFT", 4, -3)

	local ButtonBorder = ButtonFrame:CreateTexture("NidhausPlatesButtonBorder", "OVERLAY")
	ButtonBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	ButtonBorder:SetWidth(53)
	ButtonBorder:SetHeight(53)
	ButtonBorder:SetPoint("TOPLEFT", ButtonFrame, "TOPLEFT")

	local function OnMouseDown()
		ButtonIcon:SetTexCoord(-0.1, .9, -0.1, .9)
	end
	local function OnMouseUp()
		ButtonIcon:SetTexCoord(0, 1, 0, 1)
	end

	local function OnEnter()
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
		GameTooltip:AddLine(NidhausPlatesTheme and NidhausPlatesTheme.DISPLAY_NAME or "Nidhaus_Plates")
		GameTooltip:AddLine(L["Left-Click: Open Options"], .8, .8, .8, 1)
		GameTooltip:Show()
	end

	local function OnLeave()
		GameTooltip:Hide()
	end

	local function OnDragStart()
		OnMouseDown()
		ButtonFrame:StartMoving()
	end

	local function OnDragStop()
		OnMouseUp()
		ButtonFrame:StopMovingOrSizing()
	end

	local function OnClick(frame, button)
		if button ~= "LeftButton" then return end
		OpenAddonOptions()
		PlaySound("igMainMenuOptionCheckBoxOn")
	end

	ButtonFrame:EnableMouse(true)
	ButtonFrame:SetMovable(true)
	ButtonFrame:SetClampedToScreen(true)

	ButtonFrame:RegisterForClicks("LeftButtonUp")
	ButtonFrame:SetScript("OnClick", OnClick)

	ButtonFrame:SetScript("OnMouseDown", OnMouseDown)
	ButtonFrame:SetScript("OnMouseUp", OnMouseUp)
	ButtonFrame:SetScript("OnEnter", OnEnter)
	ButtonFrame:SetScript("OnLeave", OnLeave)

	ButtonFrame:RegisterForDrag("LeftButton")
	ButtonFrame:SetScript("OnDragStart", OnDragStart)
	ButtonFrame:SetScript("OnDragStop", OnDragStop)

	ButtonFrame:SetPoint("CENTER", UIParent)

	NidhausPlatesIconFrame = ButtonFrame
end

----------------------------------------------------------------------------------------
-- LDB Button Creation
----------------------------------------------------------------------------------------
local function CreateDataBrokerIcon()
	local ButtonFrameObject
	if LibDataBroker then
		ButtonFrameObject = LibDataBroker:NewDataObject(addonName, {
			type = "launcher",
			label = addonName,
			icon = ButtonTexture,
			OnClick = function(frame, button)
				GameTooltip:Hide()
				if button ~= "LeftButton" then return end
				OpenAddonOptions()
				PlaySound("igMainMenuOptionCheckBoxOn")
			end,
			OnTooltipShow = function(tooltip)
				if tooltip and tooltip.AddLine then
					tooltip:SetText(NidhausPlatesTheme and NidhausPlatesTheme.DISPLAY_NAME or "Nidhaus_Plates")
					tooltip:AddLine(L["Left-Click: Open Options"], .8, .8, .8, 1)
					tooltip:Show()
				end
			end
		})
	end

	if not LibIcon then
		return
	end

	if not ButtonFrameObject then
		return
	end
	NidhausPlatesOptions.LDB = NidhausPlatesOptions.LDB or {}
	LibIcon:Register(addonName, ButtonFrameObject, NidhausPlatesOptions.LDB)
	NidhausPlatesIconFrame = ButtonFrameObject
end

----------------------------------------------------------------------------------------
-- Create Button
----------------------------------------------------------------------------------------

local function CreateMinimapButton()
	if not NidhausPlatesIconFrame then
		if LibDataBroker then
			CreateDataBrokerIcon()
		else
			CreateStandaloneIcon()
		end
	end
end

local function HideMinimapButton()
	if NidhausPlatesIconFrame and LibIcon then
		LibIcon:Hide(addonName)
	elseif NidhausPlatesIconFrame then
		NidhausPlatesIconFrame:Hide()
	end
end

local function ShowMinimapButton()
	if not NidhausPlatesIconFrame then
		CreateMinimapButton()
	end

	if NidhausPlatesIconFrame and LibIcon then
		LibIcon:Show(addonName)
	elseif NidhausPlatesIconFrame then
		NidhausPlatesIconFrame:Show()
	end
end

NidhausPlatesUtility.CreateMinimapButton = CreateMinimapButton
NidhausPlatesUtility.HideMinimapButton = HideMinimapButton
NidhausPlatesUtility.ShowMinimapButton = ShowMinimapButton