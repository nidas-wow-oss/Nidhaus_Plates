local addonName = "TidyPlatesIcon"

local LibStub = LibStub
local LibIcon, LibDataBroker
if LibStub then
	LibIcon = LibStub("LibDBIcon-1.0", true)
	LibDataBroker = LibStub("LibDataBroker-1.1", true)
end

----------------------------------------------------------------------------------------
-- Simplified build: left-click opens the addon options. No quick menu, no middle/right click.
----------------------------------------------------------------------------------------

local L = TidyPlates.L
local ButtonTexture = "Interface\\Addons\\Nidhaus_Plates\\media\\TidyPlatesIcon"

local function OpenAddonOptions()
	local theme = TidyPlatesThemeList and TidyPlatesThemeList["Threat Plates"]
	if theme and type(theme.ShowConfigPanel) == "function" then
		theme.ShowConfigPanel()
	end
end

----------------------------------------------------------------------------------------
-- Standalone Button Creation
----------------------------------------------------------------------------------------

local function CreateStandaloneIcon()
	local ButtonFrame = CreateFrame("Button", "TidyPlatesIconFrame", UIParent)

	ButtonFrame:SetWidth(31)
	ButtonFrame:SetHeight(31)
	ButtonFrame:SetFrameStrata("LOW")
	ButtonFrame:SetToplevel(1)
	ButtonFrame:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	ButtonFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT")

	local ButtonIcon = ButtonFrame:CreateTexture("TidyPlatesButtonIcon", "BACKGROUND")
	ButtonIcon:SetTexture(ButtonTexture)
	ButtonIcon:SetWidth(25)
	ButtonIcon:SetHeight(25)
	ButtonIcon:SetPoint("TOPLEFT", ButtonFrame, "TOPLEFT", 4, -3)

	local ButtonBorder = ButtonFrame:CreateTexture("TidyPlatesButtonBorder", "OVERLAY")
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
		GameTooltip:AddLine(TidyPlatesThreat and TidyPlatesThreat.DISPLAY_NAME or "Nidhaus_Plates")
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

	TidyPlatesIconFrame = ButtonFrame
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
					tooltip:SetText(TidyPlatesThreat and TidyPlatesThreat.DISPLAY_NAME or "Nidhaus_Plates")
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
	TidyPlatesOptions.LDB = TidyPlatesOptions.LDB or {}
	LibIcon:Register(addonName, ButtonFrameObject, TidyPlatesOptions.LDB)
	TidyPlatesIconFrame = ButtonFrameObject
end

----------------------------------------------------------------------------------------
-- Create Button
----------------------------------------------------------------------------------------

local function CreateMinimapButton()
	if not TidyPlatesIconFrame then
		if LibDataBroker then
			CreateDataBrokerIcon()
		else
			CreateStandaloneIcon()
		end
	end
end

local function HideMinimapButton()
	if TidyPlatesIconFrame and LibIcon then
		LibIcon:Hide(addonName)
	elseif TidyPlatesIconFrame then
		TidyPlatesIconFrame:Hide()
	end
end

local function ShowMinimapButton()
	if not TidyPlatesIconFrame then
		CreateMinimapButton()
	end

	if TidyPlatesIconFrame and LibIcon then
		LibIcon:Show(addonName)
	elseif TidyPlatesIconFrame then
		TidyPlatesIconFrame:Show()
	end
end

TidyPlatesUtility.CreateMinimapButton = CreateMinimapButton
TidyPlatesUtility.HideMinimapButton = HideMinimapButton
TidyPlatesUtility.ShowMinimapButton = ShowMinimapButton