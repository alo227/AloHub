return function(app)
	local tab = app.Window:CreateTab("WorldZero", "🌍")

	tab:AddSection("Game Module")
	tab:AddLabel("Detected Place: WorldZero")
	tab:AddLabel("Module Status: Loaded")

	tab:AddSection("Placeholders")
	tab:AddButton("WorldZero Action Placeholder", function()
		print("WorldZero action placeholder")
	end)

	tab:AddToggle("WorldZero Toggle Placeholder", false, function(state)
		print("WorldZero toggle:", state)
	end)

	tab:AddDropdown("WorldZero List Placeholder", {
		"Quest Placeholder",
		"Dungeon Placeholder",
		"Boss Placeholder",
	}, function(selected)
		print("WorldZero selected:", selected)
	end)

	return tab
end