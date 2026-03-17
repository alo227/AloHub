return function(app)
	local tab = app.Window:CreateTab("Main", "⌂")

	tab:AddSection("Account")

	tab:AddLabel("Account Name: " .. (app.State.AccountName or "Unknown"))
	tab:AddLabel("License Duration: " .. tostring(app.State.LicenseDays or 0) .. " days")
	tab:AddLabel("License Status: " .. (app.State.LicenseStatus or "Free"))
	tab:AddLabel("Authenticated: " .. tostring(app.State.IsAuthenticated))

	tab:AddSection("Game Info")

	tab:AddLabel("PlaceId: " .. tostring(game.PlaceId or ""))
	tab:AddLabel("GameId: " .. tostring(game.GameId or ""))

	tab:AddSection("Actions")

	tab:AddButton("Refresh Account Placeholder", function()
		print("Refresh account placeholder")
	end)

	tab:AddDropdown("License Tier", {
		"Free",
		"Premium",
		"VIP",
		"Admin",
	}, function(selected)
		print("Selected tier:", selected)
	end)

	return tab
end