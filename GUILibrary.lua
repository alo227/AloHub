return function()

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local Library = {}
Library.__index = Library

-- DEFAULT KEY
local toggleKey = Enum.KeyCode.RightShift

-- CREATE WINDOW
function Library:CreateWindow(title)

	local gui = Instance.new("ScreenGui", player.PlayerGui)
	gui.Name = "HubUI"

	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0,500,0,350)
	main.Position = UDim2.new(0.5,-250,0.5,-175)
	main.BackgroundColor3 = Color3.fromRGB(20,20,25)
	main.BorderSizePixel = 0

	Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

	-- TOP BAR
	local top = Instance.new("Frame", main)
	top.Size = UDim2.new(1,0,0,40)
	top.BackgroundTransparency = 1

	local titleLabel = Instance.new("TextLabel", top)
	titleLabel.Text = title
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 18
	titleLabel.TextColor3 = Color3.new(1,1,1)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.new(0,10,0,0)
	titleLabel.Size = UDim2.new(1,-100,1,0)

	-- MINIMIZE BUTTON
	local minimize = Instance.new("TextButton", top)
	minimize.Size = UDim2.new(0,30,0,30)
	minimize.Position = UDim2.new(1,-35,0.5,-15)
	minimize.Text = "-"
	minimize.Font = Enum.Font.GothamBold

	local minimized = false

	minimize.MouseButton1Click:Connect(function()
		minimized = not minimized

		local goal = minimized and UDim2.new(0,500,0,40) or UDim2.new(0,500,0,350)

		TweenService:Create(main, TweenInfo.new(0.25), {
			Size = goal
		}):Play()
	end)

	-- DRAGGING
	local dragging, dragStart, startPos

	top.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart

			main.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	-- TABS
	local tabButtons = Instance.new("Frame", main)
	tabButtons.Size = UDim2.new(1,0,0,35)
	tabButtons.Position = UDim2.new(0,0,0,40)
	tabButtons.BackgroundTransparency = 1

	local pages = Instance.new("Frame", main)
	pages.Size = UDim2.new(1,0,1,-75)
	pages.Position = UDim2.new(0,0,0,75)
	pages.BackgroundTransparency = 1

	local currentPage

	local window = {}

	function window:CreateTab(name)

		local button = Instance.new("TextButton", tabButtons)
		button.Size = UDim2.new(0,100,1,0)
		button.Text = name
		button.Font = Enum.Font.Gotham
		button.TextSize = 14

		local page = Instance.new("Frame", pages)
		page.Size = UDim2.new(1,0,1,0)
		page.Visible = false

		local layout = Instance.new("UIListLayout", page)
		layout.Padding = UDim.new(0,6)

		button.MouseButton1Click:Connect(function()
			if currentPage then currentPage.Visible = false end
			page.Visible = true
			currentPage = page
		end)

		local tab = {}

		function tab:AddButton(text, callback)

			local btn = Instance.new("TextButton", page)
			btn.Size = UDim2.new(1,-10,0,30)
			btn.Text = text
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 14

			btn.MouseButton1Click:Connect(callback)

		end

		return tab
	end

	-- SETTINGS TAB (built-in)
	local settingsTab = window:CreateTab("Settings")

	settingsTab:AddButton("Set Toggle Key", function()
		print("Press a key...")

		local conn
		conn = UIS.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				toggleKey = input.KeyCode
				print("New Key:", toggleKey.Name)
				conn:Disconnect()
			end
		end)
	end)

	-- TOGGLE UI
	UIS.InputBegan:Connect(function(input, gpe)
		if gpe then return end

		if input.KeyCode == toggleKey then
			gui.Enabled = not gui.Enabled
		end
	end)

	return window
end

return setmetatable({}, Library)

end