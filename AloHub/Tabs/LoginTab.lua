return function(app)
	local tab = app.Window:CreateTab("Login", "🔐")

	tab:AddSection("Authentication")

	local usernameInput = tab:AddInput("Username", "Enter username...", nil, false)
	local passwordInput = tab:AddInput("Password", "Enter password...", nil, true)
	local statusLabel = tab:AddLabel("Status: Waiting for login")

	tab:AddButton("Login", function()
		local username = usernameInput:Get()
		local password = passwordInput:Get()

		app.Loading:Show("Authenticating", "Verifying credentials...")

		task.delay(0.6, function()
			if username == "Alo" and password == "Alo" then
				statusLabel:Set("Status: Login successful")
				app.State.IsAuthenticated = true
				app.State.AccountName = "Alo"
				app.State.LicenseStatus = "Premium"
				app.State.LicenseDays = 30
				app:Refresh()
			else
				statusLabel:Set("Status: Invalid username or password")
				app.Loading:Hide()
			end
		end)
	end)

	return tab
end