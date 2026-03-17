local UI = loadstring(game:HttpGet("YOUR_RAW_LINK"))()

local window = UI:CreateWindow("My Hub")

local main = window:CreateTab("Main")

main:AddButton("Test Button", function()
	print("Hello")
end)