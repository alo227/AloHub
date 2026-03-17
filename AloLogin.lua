local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/alo227/AloHub/main/GUILibrary.lua"))()

local window = UI:CreateWindow("Alo Login")

local loginTab = window:CreateTab("Login", "🔐")
loginTab:AddSection("Authentication")

local usernameInput = loginTab:AddInput("Username", "Enter username...", nil, false)
local passwordInput = loginTab:AddInput("Password", "Enter password...", nil, true)

local statusLabel = loginTab:AddLabel("Status: Waiting for login")

loginTab:AddButton("Login", function()
	local username = usernameInput:Get()
	local password = passwordInput:Get()

	if username == "Alo" and password == "Alo" then
		statusLabel:Set("Status: Login successful")
		local success, result = pcall(function()
			return loadstring(game:HttpGet("https://raw.githubusercontent.com/alo227/AloHub/main/AloHub.lua"))()
		end)

		if success then
			local pg = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
			local old = pg and pg:FindFirstChild("AloHubUI")
			if old then
				old:Destroy()
			end
		else
			statusLabel:Set("Status: Failed to load AloHub")
			warn(result)
		end
	else
		statusLabel:Set("Status: Invalid username or password")
	end
end)