local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/alo227/AloHub/main/GUILibrary.lua"))()

local window = UI:CreateWindow("Alo Hub")

local main = window:CreateTab("Main")
main:AddSection("Core")
main:AddButton("Test Button", function()
	print("Hello from Alo Hub")
end)
main:AddToggle("Example Toggle", false, function(state)
	print("Example Toggle:", state)
end)
main:AddLabel("Status: Ready")
main:AddDropdown("Main Placeholder List", {
	"Example Entry 1",
	"Example Entry 2",
	"Example Entry 3",
	"Another Placeholder",
}, function(selected)
	print("Main Placeholder selected:", selected)
end)

local combat = window:CreateTab("Combat")
combat:AddSection("Placeholders")
combat:AddButton("Attack Placeholder", function()
	print("Attack placeholder clicked")
end)
combat:AddToggle("Auto Attack Placeholder", false, function(state)
	print("Auto Attack:", state)
end)
combat:AddDropdown("Mob List Placeholder", {
	"Goblin [12m]",
	"SeaSerpent [24m]",
	"Forest Golem [31m]",
	"Bandit Captain [44m]",
	"Crystal Beast [58m]",
}, function(selected)
	print("Selected Mob Placeholder:", selected)
end)
combat:AddDropdown("Skill Placeholder", {
	"Berserker1",
	"Berserker2",
	"Berserker3",
	"Berserker4",
	"Berserker5",
}, function(selected)
	print("Selected Skill Placeholder:", selected)
end)

local debug = window:CreateTab("Debug")
debug:AddSection("Remote Tools")
debug:AddButton("Open Remote Logger Placeholder", function()
	print("Remote logger placeholder")
end)
debug:AddToggle("Hook FireServer Placeholder", false, function(state)
	print("Hook FireServer:", state)
end)
debug:AddDropdown("Last Calls Placeholder", {
	"Shared.Combat.Attack",
	"Shared.Combat.Skillsets.Berserker.Primary",
	"Shared.Inventory.UseItem",
	"Shared.Player.Interact",
}, function(selected)
	print("Debug Placeholder selected:", selected)
end)