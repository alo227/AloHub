return function(app)
	local tab = app.Window:CreateTab("Settings", "⚙")
	tab:AddSection("Interface")
	tab:AddKeybindRow("Toggle Key", Enum.KeyCode.RightShift, function(newKey)
		app.Window:SetToggleKey(newKey)
	end)

	tab:AddSection("Preferences")
	tab:AddToggle("Notifications Placeholder", true, function(state)
		app.State.NotificationsEnabled = state
	end)

	tab:AddDropdown("Theme Placeholder", {
		"Default",
		"Dark",
		"Purple",
	}, function(selected)
		app.State.ThemeName = selected
	end)

	return tab
end