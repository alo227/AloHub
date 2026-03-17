return function(app)
	local tab = app.Window:CreateTab("World//Zero", "🌍")

	tab:AddSection("Game Module")
	tab:AddLabel("Detected Game: World//Zero")
	tab:AddLabel("Module Status: Loaded")

	tab:AddSection("Placeholders")
	tab:AddButton("World//Zero Action Placeholder", function()
		print("World//Zero action placeholder")
	end)

	tab:AddToggle("World//Zero Toggle Placeholder", false, function(state)
		print("World//Zero toggle:", state)
	end)

	tab:AddDropdown("World//Zero List Placeholder", {
		"Quest Placeholder",
		"Dungeon Placeholder",
		"Boss Placeholder",
	}, function(selected)
		print("World//Zero selected:", selected)
	end)

	return tab
end