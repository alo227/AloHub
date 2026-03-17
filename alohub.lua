local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/alo227/AloHub/main/GUILibrary.lua"))()

local window = UI:CreateWindow("Alo Hub")

local main = window:CreateTab("Main")

main:AddButton("Test Button", function()
	print("Hello from AloHub 😏")
end)

main:AddToggle("Example Toggle", function(state)
	print("Toggle:", state)
end)