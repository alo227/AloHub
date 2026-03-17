local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/alo227/AloHub/refs/heads/main/GUILibrary.lua?token=GHSAT0AAAAAADWYGUDLGNV27BQSSSH7MROC2NZSNDQ"))()

local window = UI:CreateWindow("My Hub")

local main = window:CreateTab("Main")

main:AddButton("Test Button", function()
	print("Hello")
end)