return function()

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local ACCENT = Color3.fromRGB(140,120,255)
local toggleKey = Enum.KeyCode.RightShift

local Library = {}

-- CREATE WINDOW
function Library:CreateWindow(title)

	local gui = Instance.new("ScreenGui", player.PlayerGui)
	gui.Name = "HubV2"

	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0,540,0,380)
	main.Position = UDim2.new(0.5,-270,0.5,-190)
	main.BackgroundColor3 = Color3.fromRGB(18,18,22)
	Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

	local stroke = Instance.new("UIStroke", main)
	stroke.Color = ACCENT
	stroke.Transparency = 0.7

	-- TOP BAR
	local top = Instance.new("Frame", main)
	top.Size = UDim2.new(1,0,0,45)
	top.BackgroundTransparency = 1

	local titleLabel = Instance.new("TextLabel", top)
	titleLabel.Text = title
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 18
	titleLabel.TextColor3 = Color3.new(1,1,1)
	titleLabel.Position = UDim2.new(0,15,0,0)
	titleLabel.Size = UDim2.new(1,-100,1,0)
	titleLabel.BackgroundTransparency = 1

	-- MINIMIZE
	local mini = Instance.new("TextButton", top)
	mini.Size = UDim2.new(0,30,0,30)
	mini.Position = UDim2.new(1,-40,0.5,-15)
	mini.Text = "-"
	mini.Font = Enum.Font.GothamBold

	local minimized = false

	mini.MouseButton1Click:Connect(function()
		minimized = not minimized

		TS:Create(main, TweenInfo.new(0.25), {
			Size = minimized and UDim2.new(0,540,0,45) or UDim2.new(0,540,0,380)
		}):Play()
	end)

	-- DRAG
	local dragging, dragStart, startPos

	top.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = i.Position
			startPos = main.Position
		end
	end)

	UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = i.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	-- TABS
	local tabBar = Instance.new("Frame", main)
	tabBar.Size = UDim2.new(1,0,0,35)
	tabBar.Position = UDim2.new(0,0,0,45)
	tabBar.BackgroundTransparency = 1

	local pages = Instance.new("Frame", main)
	pages.Size = UDim2.new(1,0,1,-80)
	pages.Position = UDim2.new(0,0,0,80)
	pages.BackgroundTransparency = 1

	local current

	local window = {}

	function window:CreateTab(name)

		local btn = Instance.new("TextButton", tabBar)
		btn.Size = UDim2.new(0,110,1,0)
		btn.Text = name
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 14
		btn.BackgroundTransparency = 1

		local page = Instance.new("Frame", pages)
		page.Size = UDim2.new(1,0,1,0)
		page.Visible = false

		local layout = Instance.new("UIListLayout", page)
		layout.Padding = UDim.new(0,8)

		btn.MouseEnter:Connect(function()
			TS:Create(btn, TweenInfo.new(0.2), {TextColor3 = ACCENT}):Play()
		end)

		btn.MouseLeave:Connect(function()
			TS:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.new(1,1,1)}):Play()
		end)

		btn.MouseButton1Click:Connect(function()
			if current then current.Visible = false end
			page.Visible = true
			current = page
		end)

		local tab = {}

		-- BUTTON
		function tab:AddButton(text, callback)
			local btn = Instance.new("TextButton", page)
			btn.Size = UDim2.new(1,-10,0,35)
			btn.Text = text
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 14
			btn.BackgroundColor3 = Color3.fromRGB(28,28,35)

			Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

			btn.MouseEnter:Connect(function()
				TS:Create(btn, TweenInfo.new(0.2), {
					BackgroundColor3 = ACCENT
				}):Play()
			end)

			btn.MouseLeave:Connect(function()
				TS:Create(btn, TweenInfo.new(0.2), {
					BackgroundColor3 = Color3.fromRGB(28,28,35)
				}):Play()
			end)

			btn.MouseButton1Click:Connect(callback)
		end

		-- TOGGLE
		function tab:AddToggle(text, callback)
			local holder = Instance.new("Frame", page)
			holder.Size = UDim2.new(1,-10,0,35)
			holder.BackgroundColor3 = Color3.fromRGB(28,28,35)
			Instance.new("UICorner", holder)

			local label = Instance.new("TextLabel", holder)
			label.Text = text
			label.Font = Enum.Font.Gotham
			label.TextSize = 14
			label.BackgroundTransparency = 1
			label.Position = UDim2.new(0,10,0,0)
			label.Size = UDim2.new(1,-60,1,0)

			local toggle = Instance.new("Frame", holder)
			toggle.Size = UDim2.new(0,40,0,20)
			toggle.Position = UDim2.new(1,-50,0.5,-10)
			toggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
			Instance.new("UICorner", toggle).CornerRadius = UDim.new(1,0)

			local dot = Instance.new("Frame", toggle)
			dot.Size = UDim2.new(0,16,0,16)
			dot.Position = UDim2.new(0,2,0.5,-8)
			dot.BackgroundColor3 = Color3.new(1,1,1)
			Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

			local state = false

			holder.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					state = not state

					TS:Create(dot, TweenInfo.new(0.2), {
						Position = state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
					}):Play()

					toggle.BackgroundColor3 = state and ACCENT or Color3.fromRGB(60,60,60)

					callback(state)
				end
			end)
		end

		return tab
	end

	-- SETTINGS
	local settings = window:CreateTab("Settings")

	settings:AddButton("Set Toggle Key", function()
		print("Press new key...")
		local c
		c = UIS.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.Keyboard then
				toggleKey = i.KeyCode
				print("New key:", toggleKey.Name)
				c:Disconnect()
			end
		end)
	end)

	UIS.InputBegan:Connect(function(i,g)
		if not g and i.KeyCode == toggleKey then
			gui.Enabled = not gui.Enabled
		end
	end)

	return window
end

return Library

end