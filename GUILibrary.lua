local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local Library = {}
Library.__index = Library

local THEME = {
	Bg = Color3.fromRGB(8, 10, 18),
	Panel = Color3.fromRGB(12, 15, 26),
	Card = Color3.fromRGB(20, 23, 36),
	CardHover = Color3.fromRGB(28, 32, 48),
	Stroke = Color3.fromRGB(72, 84, 140),
	Text = Color3.fromRGB(240, 243, 255),
	SubText = Color3.fromRGB(155, 163, 190),
	Accent = Color3.fromRGB(120, 92, 255),
	Accent2 = Color3.fromRGB(82, 132, 255),
	Green = Color3.fromRGB(70, 190, 120),
	Red = Color3.fromRGB(190, 70, 90),
}

local function tween(obj, time, props, style, dir)
	local info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
	local t = TS:Create(obj, info, props)
	t:Play()
	return t
end

local function create(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	return inst
end

local function addCorner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = obj
	return c
end

local function addStroke(obj, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or THEME.Stroke
	s.Thickness = thickness or 1
	s.Transparency = transparency == nil and 0.35 or transparency
	s.Parent = obj
	return s
end

local function makeButtonHover(btn, normal, hover)
	btn.MouseEnter:Connect(function()
		tween(btn, 0.18, {BackgroundColor3 = hover})
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, 0.18, {BackgroundColor3 = normal})
	end)
end

function Library:CreateWindow(title)
	local toggleKey = Enum.KeyCode.RightShift
	local waitingForKey = false
	local minimized = false
	local currentTab = nil
	local tabs = {}

	local gui = create("ScreenGui", {
		Name = "AloHubUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = player:WaitForChild("PlayerGui"),
	})

	local shadow = create("ImageLabel", {
		Name = "Shadow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://1316045217",
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.45,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 118, 118),
		Size = UDim2.new(0, 620, 0, 470),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		ZIndex = 0,
		Parent = gui,
	})

	local main = create("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 560, 0, 390),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = THEME.Bg,
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = gui,
	})
	addCorner(main, 18)
	addStroke(main, THEME.Stroke, 1, 0.45)

	local glow = create("Frame", {
		Name = "Glow",
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = THEME.Accent,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = main,
	})
	local glowGrad = create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, THEME.Accent),
			ColorSequenceKeypoint.new(1, THEME.Accent2),
		}),
		Parent = glow,
	})

	local top = create("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = main,
	})

	local iconWrap = create("Frame", {
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(0, 16, 0.5, -16),
		BackgroundColor3 = THEME.Card,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = top,
	})
	addCorner(iconWrap, 10)
	addStroke(iconWrap, THEME.Stroke, 1, 0.55)

	local icon = create("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "A",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = THEME.Accent,
		ZIndex = 4,
		Parent = iconWrap,
	})

	local titleLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 58, 0, 8),
		Size = UDim2.new(1, -150, 0, 22),
		Text = title or "Alo Hub",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = THEME.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
		Parent = top,
	})

	local subLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 58, 0, 29),
		Size = UDim2.new(1, -150, 0, 16),
		Text = "Modern UI Framework",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = THEME.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
		Parent = top,
	})

	local miniBtn = create("TextButton", {
		Size = UDim2.new(0, 34, 0, 34),
		Position = UDim2.new(1, -50, 0.5, -17),
		BackgroundColor3 = THEME.Card,
		Text = "–",
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = THEME.Text,
		AutoButtonColor = false,
		ZIndex = 4,
		Parent = top,
	})
	addCorner(miniBtn, 10)
	addStroke(miniBtn, THEME.Stroke, 1, 0.55)
	makeButtonHover(miniBtn, THEME.Card, THEME.CardHover)

	local content = create("Frame", {
		Name = "Content",
		Position = UDim2.new(0, 0, 0, 56),
		Size = UDim2.new(1, 0, 1, -56),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = main,
	})

	local tabBar = create("Frame", {
		Name = "TabBar",
		Position = UDim2.new(0, 14, 0, 8),
		Size = UDim2.new(1, -28, 0, 38),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = content,
	})

	local tabLayout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Padding = UDim.new(0, 8),
		Parent = tabBar,
	})

	local pageHolder = create("Frame", {
		Name = "PageHolder",
		Position = UDim2.new(0, 14, 0, 54),
		Size = UDim2.new(1, -28, 1, -64),
		BackgroundColor3 = THEME.Panel,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = content,
	})
	addCorner(pageHolder, 14)
	addStroke(pageHolder, THEME.Stroke, 1, 0.7)

	local dragging = false
	local dragStart, startPos

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
			shadow.Position = main.Position
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	local expandedSize = UDim2.new(0, 560, 0, 390)
	local minimizedSize = UDim2.new(0, 560, 0, 56)

	miniBtn.MouseButton1Click:Connect(function()
		minimized = not minimized

		if minimized then
			content.Visible = false
			miniBtn.Text = "+"
			tween(main, 0.25, {Size = minimizedSize})
			tween(shadow, 0.25, {Size = UDim2.new(0, 620, 0, 140)})
		else
			miniBtn.Text = "–"
			tween(main, 0.25, {Size = expandedSize})
			tween(shadow, 0.25, {Size = UDim2.new(0, 620, 0, 470)})
			task.delay(0.12, function()
				content.Visible = true
			end)
		end
	end)

	UIS.InputBegan:Connect(function(input, gpe)
		if gpe then
			return
		end
		if waitingForKey then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				toggleKey = input.KeyCode
				waitingForKey = false
			end
			return
		end
		if input.KeyCode == toggleKey then
			gui.Enabled = not gui.Enabled
		end
	end)

	local window = {}

	local function selectTab(tabObj)
		if currentTab == tabObj then
			return
		end

		for _, tab in ipairs(tabs) do
			tab.Page.Visible = false
			tween(tab.Button, 0.18, {
				BackgroundColor3 = THEME.Card,
			})
			tween(tab.Title, 0.18, {
				TextColor3 = THEME.SubText,
			})
		end

		currentTab = tabObj
		tabObj.Page.Visible = true
		tabObj.Page.BackgroundTransparency = 1
		tween(tabObj.Page, 0.18, {BackgroundTransparency = 0.999})

		tween(tabObj.Button, 0.18, {
			BackgroundColor3 = Color3.fromRGB(28, 23, 44),
		})
		tween(tabObj.Title, 0.18, {
			TextColor3 = THEME.Accent,
		})
	end

	function window:CreateTab(name)
		local btn = create("TextButton", {
			Size = UDim2.new(0, 110, 1, 0),
			BackgroundColor3 = THEME.Card,
			Text = "",
			AutoButtonColor = false,
			Parent = tabBar,
		})
		addCorner(btn, 10)
		addStroke(btn, THEME.Stroke, 1, 0.75)

		local btnTitle = create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Text = name,
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextColor3 = THEME.SubText,
			ZIndex = 3,
			Parent = btn,
		})

		local page = create("ScrollingFrame", {
			Name = name .. "_Page",
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			Parent = pageHolder,
		})

		local pagePadding = create("UIPadding", {
			PaddingTop = UDim.new(0, 14),
			PaddingLeft = UDim.new(0, 14),
			PaddingRight = UDim.new(0, 14),
			PaddingBottom = UDim.new(0, 14),
			Parent = page,
		})

		local pageLayout = create("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = page,
		})

		local tabObj = {
			Button = btn,
			Title = btnTitle,
			Page = page,
		}
		table.insert(tabs, tabObj)

		btn.MouseEnter:Connect(function()
			if currentTab ~= tabObj then
				tween(btn, 0.18, {BackgroundColor3 = THEME.CardHover})
				tween(btnTitle, 0.18, {TextColor3 = THEME.Text})
			end
		end)

		btn.MouseLeave:Connect(function()
			if currentTab ~= tabObj then
				tween(btn, 0.18, {BackgroundColor3 = THEME.Card})
				tween(btnTitle, 0.18, {TextColor3 = THEME.SubText})
			end
		end)

		btn.MouseButton1Click:Connect(function()
			selectTab(tabObj)
		end)

		local tab = {}

		function tab:AddSection(text)
			local label = create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 18),
				BackgroundTransparency = 1,
				Text = string.upper(text),
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextColor3 = THEME.SubText,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = page,
			})
			return label
		end

		function tab:AddButton(text, callback)
			local holder = create("TextButton", {
				Size = UDim2.new(1, 0, 0, 44),
				BackgroundColor3 = THEME.Card,
				Text = "",
				AutoButtonColor = false,
				Parent = page,
			})
			addCorner(holder, 12)
			addStroke(holder, THEME.Stroke, 1, 0.75)

			local label = create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(1, -28, 1, 0),
				Text = text,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextColor3 = THEME.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = holder,
			})

			local chevron = create("TextLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0.5, 0),
				Size = UDim2.new(0, 20, 0, 20),
				Text = "›",
				Font = Enum.Font.GothamBold,
				TextSize = 18,
				TextColor3 = THEME.SubText,
				Parent = holder,
			})

			holder.MouseEnter:Connect(function()
				tween(holder, 0.18, {BackgroundColor3 = THEME.CardHover})
				tween(chevron, 0.18, {TextColor3 = THEME.Accent})
			end)

			holder.MouseLeave:Connect(function()
				tween(holder, 0.18, {BackgroundColor3 = THEME.Card})
				tween(chevron, 0.18, {TextColor3 = THEME.SubText})
			end)

			holder.MouseButton1Down:Connect(function()
				tween(holder, 0.08, {Size = UDim2.new(1, 0, 0, 41)})
			end)

			holder.MouseButton1Up:Connect(function()
				tween(holder, 0.08, {Size = UDim2.new(1, 0, 0, 44)})
			end)

			holder.MouseButton1Click:Connect(function()
				if callback then
					callback()
				end
			end)

			return holder
		end

		function tab:AddToggle(text, default, callback)
			local state = default and true or false

			local holder = create("TextButton", {
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundColor3 = THEME.Card,
				Text = "",
				AutoButtonColor = false,
				Parent = page,
			})
			addCorner(holder, 12)
			addStroke(holder, THEME.Stroke, 1, 0.75)

			local label = create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(1, -80, 1, 0),
				Text = text,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextColor3 = THEME.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = holder,
			})

			local switch = create("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0.5, 0),
				Size = UDim2.new(0, 42, 0, 22),
				BackgroundColor3 = state and THEME.Accent or Color3.fromRGB(60, 65, 82),
				Parent = holder,
			})
			addCorner(switch, 99)

			local knob = create("Frame", {
				Size = UDim2.new(0, 18, 0, 18),
				Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Parent = switch,
			})
			addCorner(knob, 99)

			holder.MouseEnter:Connect(function()
				tween(holder, 0.18, {BackgroundColor3 = THEME.CardHover})
			end)

			holder.MouseLeave:Connect(function()
				tween(holder, 0.18, {BackgroundColor3 = THEME.Card})
			end)

			local function setState(v)
				state = v
				tween(switch, 0.18, {
					BackgroundColor3 = state and THEME.Accent or Color3.fromRGB(60, 65, 82),
				})
				tween(knob, 0.18, {
					Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
				})
				if callback then
					callback(state)
				end
			end

			holder.MouseButton1Click:Connect(function()
				setState(not state)
			end)

			setState(state)

			return {
				Set = setState,
				Get = function()
					return state
				end,
			}
		end

		function tab:AddLabel(text)
			local holder = create("Frame", {
				Size = UDim2.new(1, 0, 0, 38),
				BackgroundColor3 = THEME.Card,
				Parent = page,
			})
			addCorner(holder, 12)
			addStroke(holder, THEME.Stroke, 1, 0.8)

			local label = create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(1, -28, 1, 0),
				Text = text,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = THEME.SubText,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = holder,
			})

			return {
				Set = function(_, newText)
					label.Text = newText
				end
			}
		end

		function tab:AddKeybindRow(text, defaultKey, onChanged)
			local currentKey = defaultKey or toggleKey

			local holder = create("Frame", {
				Size = UDim2.new(1, 0, 0, 52),
				BackgroundColor3 = THEME.Card,
				Parent = page,
			})
			addCorner(holder, 12)
			addStroke(holder, THEME.Stroke, 1, 0.75)

			local leftTitle = create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 8),
				Size = UDim2.new(1, -160, 0, 16),
				Text = text,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextColor3 = THEME.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = holder,
			})

			local leftSub = create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 26),
				Size = UDim2.new(1, -160, 0, 14),
				Text = "Choose the key to show/hide the UI",
				Font = Enum.Font.Gotham,
				TextSize = 11,
				TextColor3 = THEME.SubText,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = holder,
			})

			local keyBtn = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0.5, 0),
				Size = UDim2.new(0, 120, 0, 32),
				BackgroundColor3 = Color3.fromRGB(26, 30, 46),
				Text = currentKey.Name,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextColor3 = THEME.Text,
				AutoButtonColor = false,
				Parent = holder,
			})
			addCorner(keyBtn, 10)
			addStroke(keyBtn, THEME.Stroke, 1, 0.65)
			makeButtonHover(keyBtn, Color3.fromRGB(26, 30, 46), Color3.fromRGB(36, 41, 61))

			keyBtn.MouseButton1Click:Connect(function()
				if waitingForKey then
					return
				end
				waitingForKey = true
				keyBtn.Text = "..."
				tween(keyBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(44, 35, 78)})

				local conn
				conn = UIS.InputBegan:Connect(function(input, gpe)
					if gpe then
						return
					end
					if input.UserInputType == Enum.UserInputType.Keyboard then
						currentKey = input.KeyCode
						keyBtn.Text = currentKey.Name
						waitingForKey = false
						tween(keyBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(26, 30, 46)})
						if onChanged then
							onChanged(currentKey)
						end
						conn:Disconnect()
					end
				end)
			end)

			if onChanged then
				onChanged(currentKey)
			end

			return {
				Set = function(_, newKey)
					currentKey = newKey
					keyBtn.Text = newKey.Name
					if onChanged then
						onChanged(newKey)
					end
				end
			}
		end

		if not currentTab then
			selectTab(tabObj)
		end

		return tab
	end

	local settingsTab = window:CreateTab("Settings")
	settingsTab:AddSection("Interface")
	settingsTab:AddKeybindRow("Toggle Key", toggleKey, function(newKey)
		toggleKey = newKey
	end)

	return window
end

return Library