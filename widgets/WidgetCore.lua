NidhausPlatesWidgets = {}

do
	local Framelist = {}
	local Watcherframe = CreateFrame("Frame")
	local WatcherframeActive = false
	local select = select
	local timeToUpdate = 0

	local function CheckFramelist(self)
		local curTime = GetTime()
		if curTime < timeToUpdate then
			return
		end
		local framecount = 0
		timeToUpdate = curTime + 1

		for frame, expiration in pairs(Framelist) do
			if expiration < curTime then
				frame:Hide()
				Framelist[frame] = nil
			else
				framecount = framecount + 1
			end
		end

		if framecount == 0 then
			Watcherframe:SetScript("OnUpdate", nil)
		end
	end

	function NidhausPlatesWidgets:HideIn(frame, expiration)

		Framelist[frame] = expiration

		if not WatcherframeActive then
			Watcherframe:SetScript("OnUpdate", CheckFramelist)
			WatcherframeActive = true
		end
	end
end

do
	local PolledHideIn
	local Framelist = {}
	local Watcherframe = CreateFrame("Frame")
	local WatcherframeActive = false
	local select = select
	local timeToUpdate = 0

	local function CheckFramelist(self)
		local curTime = GetTime()
		if curTime < timeToUpdate then
			return
		end
		local framecount = 0
		timeToUpdate = curTime + 1

		for frame, expiration in pairs(Framelist) do

			if expiration < curTime then

				frame:Hide()
				Framelist[frame] = nil
				NidhausPlates:RequestDelegateUpdate()
			else

				if frame.Poll then
					frame:Poll(expiration)
				end
				framecount = framecount + 1
			end
		end

		if framecount == 0 then
			Watcherframe:SetScript("OnUpdate", nil)
			WatcherframeActive = false
		end
	end

	function PolledHideIn(frame, expiration)
		if expiration == 0 then
			frame:Hide()
			Framelist[frame] = nil
		else

			Framelist[frame] = expiration
			frame:Show()

			if not WatcherframeActive then
				Watcherframe:SetScript("OnUpdate", CheckFramelist)
				WatcherframeActive = true
			end
		end
	end

	NidhausPlatesWidgets.PolledHideIn = PolledHideIn
end

do
	local Plate, plateIndex, WorldFrameChildren, WidgetChildren, widgetIndex
	local function ResetWidgets()
		WorldFrameChildren = {WorldFrame:GetChildren()}
		for plateIndex = 1, #WorldFrameChildren do
			Plate = WorldFrameChildren[plateIndex]
			if Plate.extended and Plate.extended.widgets then
				for widgetIndex, widget in pairs(Plate.extended.widgets) do
					widget:Hide()
					Plate.extended.widgets[widgetIndex] = nil
				end
			end
		end
	end
	NidhausPlatesWidgets.ResetWidgets = ResetWidgets
end
