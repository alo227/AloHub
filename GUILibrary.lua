local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local Library = {}
Library.__index = Library

local THEME = {
	Bg = Color3.fromRGB(8, 10, 18),
	Panel = Color3.fromRGB(11, 14, 24),
	Card = Color3.fromRGB(18, 22, 34),
	CardHover = Color3.fromRGB(24, 29, 44),
	StrokeDark = Color3.fromRGB(58, 66, 104),
	StrokeLight = Color3.fromRGB(92, 104, 156),
	Text = Color3.fromRGB(240, 243, 255),
	SubText = Color3.fromRGB(150, 158, 188),
	Accent = Color3.fromRGB(125, 92, 255),
	AccentSoft = Color3.fromRGB(94, 79, 170),
	ToggleOff = Color3.fromRGB(60, 65, 82),
	Green = Color3.fromRGB(70, 190, 120),
	Backplate = Color3.fromRGB(3, 4, 10),
}

local function tween(obj, time, props, style, direction)
	local info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
	local t = TS:Create(obj, info, props)
	t:Play()
	return t
end

local function create(className, props)
	local obj = Instance.new(className)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	return obj
end

local function corner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = obj
	return c
end

local function stroke(obj, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or THEME.StrokeDark
	s.Thickness = thickness or 1
	s.Transparency = transparency == nil and 0.4 or transparency
	s.Parent = obj
	return s
end

local function hoverButton(btn, normalColor, hoverColor)
	btn.MouseEnter:Connect(function()
		tween(btn, 0.18, {BackgroundColor3 = hoverColor})
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, 0.18, {BackgroundColor3 = normalColor})
	end)
end

function Library:CreateWindow(title)
	local toggleKey = Enum.KeyCode.RightShift
	local minimized = false
	local currentTab = nil
	local tabs = {}
	local waitingForKey = false

	local gui = create("ScreenGui", {
		Name = "AloHubUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = player:WaitForChild("PlayerGui"),
	})

	local backplate2 = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 10),
		Size = UDim2.new(0, 592, 0, 430),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.78,
		BorderSizePixel = 0,
		ZIndex = 0,
		Parent = gui,
	})
	corner(backplate2, 24)

	local backplate = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 6),
		Size = UDim2.new(0, 584, 0, 422),
		BackgroundColor3 = THEME.Backplate,
		BackgroundTransparency = 0.48,
		BorderSizePixel = 0,
		ZIndex = 0,
		Parent = gui,
	})
	corner(backplate, 22)

	local main = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 576, 0, 414),
		BackgroundColor3 = THEME.Bg,
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = gui,
	})
	corner(main, 20)
	local mainStroke = stroke(main, THEME.StrokeDark, 1, 0.28)

	task.spawn(function()
		while gui.Parent do
			tween(mainStroke, 1.8, {Color = THEME.StrokeLight, Transparency = 0.12}, Enum.EasingStyle.Sine)
			task.wait(1.8)
			tween(mainStroke, 1.8, {Color = THEME.StrokeDark, Transparency = 0.3}, Enum.EasingStyle.Sine)
			task.wait(1.8)
		end
	end)

	local topBar = create("Frame", {
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = main,
	})

	local logoWrap = create("Frame", {
		Position = UDim2.new(0, 14, 0.5, -18),
		Size = UDim2.new(0, 36, 0, 36),
		BackgroundColor3 = THEME.Card,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = topBar,
	})
	corner(logoWrap, 12)
	stroke(logoWrap, THEME.StrokeDark, 1, 0.5)

	local logo = create("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "A",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = THEME.Accent,
		ZIndex = 4,
		Parent = logoWrap,
	})

	local titleLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 58, 0, 10),
		Size = UDim2.new(1, -130, 0, 20),
		Text = title or "Alo Hub",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = THEME.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
		Parent = topBar,
	})

	local subLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 58, 0, 31),
		Size = UDim2.new(1, -130, 0, 14),
		Text = "Modern UI Framework",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = THEME.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
		Parent = topBar,
	})

	local miniBtn = create("TextButton", {
		Size = UDim2.new(0, 34, 0, 34),
		Position = UDim2.new(1, -48, 0.5, -17),
		BackgroundColor3 = THEME.Card,
		Text = "–",
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = THEME.Text,
		AutoButtonColor = false,
		ZIndex = 4,
		Parent = topBar,
	})
	corner(miniBtn, 10)
	stroke(miniBtn, THEME.StrokeDark, 1, 0.55)
	hoverButton(miniBtn, THEME.Card, THEME.CardHover)

	local content = create("Frame", {
		Name = "Content",
		Position = UDim2.new(0, 0, 0, 62),
		Size = UDim2.new(1, 0, 1, -62),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = main,
	})

	local tabBar = create("Frame", {
		Position = UDim2.new(0, 14, 0, 6),
		Size = UDim2.new(1, -28, 0, 40),
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
		Position = UDim2.new(0, 14, 0, 54),
		Size = UDim2.new(1, -28, 1, -68),
		BackgroundColor3 = THEME.Panel,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = content,
	})
	corner(pageHolder, 16)
	stroke(pageHolder, THEME.StrokeDark, 1, 0.72)

	local dragging = false
	local dragStart, startPos

	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			local newPos = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)

			main.Position = newPos
			backplate.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset, newPos.Y.Scale, newPos.Y.Offset + 6)
			backplate2.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset, newPos.Y.Scale, newPos.Y.Offset + 10)
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	local expandedMain = UDim2.new(0, 576, 0, 414)
	local minimizedMain = UDim2.new(0, 576, 0, 62)

	miniBtn.MouseButton1Click:Connect(function()
		minimized = not minimized

		if minimized then
			content.Visible = false
			miniBtn.Text = "+"
			tween(main, 0.25, {Size = minimizedMain})
			tween(backplate, 0.25, {Size = UDim2.new(0, 584, 0, 70)})
			tween(backplate2, 0.25, {Size = UDim2.new(0, 592, 0, 78)})
		else
			miniBtn.Text = "–"
			tween(main, 0.25, {Size = expandedMain})
			tween(backplate, 0.25, {Size = UDim2.new(0, 584, 0, 422)})
			tween(backplate2, 0.25, {Size = UDim2.new(0, 592, 0, 430)})
			task.delay(0.12, function()
				content.Visible = true
			end)
		end
	end)

	UIS.InputBegan:Connect(function(input, gpe)
		if gpe then
			return
		end
		if input.KeyCode == toggleKey and not waitingForKey then
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
			tween(tab.Button, 0.16, {BackgroundColor3 = THEME.Card})
			tween(tab.Title, 0.16, {TextColor3 = THEME.SubText})
		end

		currentTab = tabObj
		tabObj.Page.Visible = true
		tween(tabObj.Button, 0.16, {BackgroundColor3 = Color3.fromRGB(28, 23, 44)})
		tween(tabObj.Title, 0.16, {TextColor3 = THEME.Accent})
	end

	function window:CreateTab(name)
		local btn = create("TextButton", {
			Size = UDim2.new(0, 108, 1, 0),
			BackgroundColor3 = THEME.Card,
			Text = "",
			AutoButtonColor = false,
			Parent = tabBar,
		})
		corner(btn, 10)
		stroke(btn, THEME.StrokeDark, 1, 0.78)

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
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 3,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			Parent = pageHolder,
		})

		create("UIPadding", {
			PaddingTop = UDim.new(0, 14),
			PaddingLeft = UDim.new(0, 14),
			PaddingRight = UDim.new(0, 14),
			PaddingBottom = UDim.new(0, 14),
			Parent = page,
		})

		create("UIListLayout", {
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
				tween(btn, 0.16, {BackgroundColor3 = THEME.CardHover})
				tween(btnTitle, 0.16, {TextColor3 = THEME.Text})
			end
		end)

		btn.MouseLeave:Connect(function()
			if currentTab ~= tabObj then
				tween(btn, 0.16, {BackgroundColor3 = THEME.Card})
				tween(btnTitle, 0.16, {TextColor3 = THEME.SubText})
			end
		end)

		btn.MouseButton1Click:Connect(function()
			selectTab(tabObj)
		end)

		local tab = {}

		function tab:AddSection(text)
			return create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 16),
				BackgroundTransparency = 1,
				Text = string.upper(text),
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextColor3 = THEME.SubText,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = page,
			})
		end

		function tab:AddButton(text, callback)
			local holder = create("TextButton", {
				Size = UDim2.new(1, 0, 0, 44),
				BackgroundColor3 = THEME.Card,
				Text = "",
				AutoButtonColor = false,
				Parent = page,
			})
			corner(holder, 12)
			stroke(holder, THEME.StrokeDark, 1, 0.78)

			create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(1, -40, 1, 0),
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
			corner(holder, 12)
			stroke(holder, THEME.StrokeDark, 1, 0.78)

			create("TextLabel", {
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
				BackgroundColor3 = state and THEME.AccentSoft or THEME.ToggleOff,
				Parent = holder,
			})
			corner(switch, 99)

			local knob = create("Frame", {
				Size = UDim2.new(0, 18, 0, 18),
				Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Parent = switch,
			})
			corner(knob, 99)

			holder.MouseEnter:Connect(function()
				tween(holder, 0.18, {BackgroundColor3 = THEME.CardHover})
			end)

			holder.MouseLeave:Connect(function()
				tween(holder, 0.18, {BackgroundColor3 = THEME.Card})
			end)

			local function setState(v)
				state = v
				tween(switch, 0.18, {
					BackgroundColor3 = state and THEME.AccentSoft or THEME.ToggleOff
				})
				tween(knob, 0.18, {
					Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
				})
				if callback then
					callback(state)
				end
			end

			holder.MouseButton1Click:Connect(function()
				setState(not state)
			end)

			if callback then
				callback(state)
			end

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
			corner(holder, 12)
			stroke(holder, THEME.StrokeDark, 1, 0.8)

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

		function tab:AddDropdown(text, items, callback)
			local opened = false
			items = items or {}

			local holder = create("Frame", {
				Size = UDim2.new(1, 0, 0, 44),
				BackgroundColor3 = THEME.Card,
				ClipsDescendants = true,
				Parent = page,
			})
			corner(holder, 12)
			stroke(holder, THEME.StrokeDark, 1, 0.78)

			local topButton = create("TextButton", {
				Size = UDim2.new(1, 0, 0, 44),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				Parent = holder,
			})

			create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(1, -44, 0, 44),
				Text = text,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextColor3 = THEME.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = holder,
			})

			local arrow = create("TextLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0.5, 0),
				Size = UDim2.new(0, 20, 0, 20),
				Text = "⌄",
				Font = Enum.Font.GothamBold,
				TextSize = 16,
				TextColor3 = THEME.SubText,
				Parent = holder,
			})

			local listHolder = create("Frame", {
				Position = UDim2.new(0, 10, 0, 48),
				Size = UDim2.new(1, -20, 0, 0),
				BackgroundTransparency = 1,
				Parent = holder,
			})

			local listLayout = create("UIListLayout", {
				Padding = UDim.new(0, 6),
				Parent = listHolder,
			})

			for _, item in ipairs(items) do
				local itemBtn = create("TextButton", {
					Size = UDim2.new(1, 0, 0, 34),
					BackgroundColor3 = Color3.fromRGB(22, 26, 40),
					Text = item,
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = THEME.SubText,
					AutoButtonColor = false,
					Parent = listHolder,
				})
				corner(itemBtn, 10)

				itemBtn.MouseEnter:Connect(function()
					tween(itemBtn, 0.16, {BackgroundColor3 = Color3.fromRGB(28, 34, 52)})
					tween(itemBtn, 0.16, {TextColor3 = THEME.Text})
				end)

				itemBtn.MouseLeave:Connect(function()
					tween(itemBtn, 0.16, {BackgroundColor3 = Color3.fromRGB(22, 26, 40)})
					tween(itemBtn, 0.16, {TextColor3 = THEME.SubText})
				end)

				itemBtn.MouseButton1Click:Connect(function()
					if callback then
						callback(item)
					end
				end)
			end

			local function getOpenHeight()
				return 44 + 10 + (#items * 34) + (math.max(#items - 1, 0) * 6) + 10
			end

			topButton.MouseEnter:Connect(function()
				tween(holder, 0.18, {BackgroundColor3 = THEME.CardHover})
			end)

			topButton.MouseLeave:Connect(function()
				if not opened then
					tween(holder, 0.18, {BackgroundColor3 = THEME.Card})
				end
			end)

			topButton.MouseButton1Click:Connect(function()
				opened = not opened
				tween(holder, 0.22, {
					Size = opened and UDim2.new(1, 0, 0, getOpenHeight()) or UDim2.new(1, 0, 0, 44)
				})
				tween(listHolder, 0.22, {
					Size = opened and UDim2.new(1, -20, 0, getOpenHeight() - 54) or UDim2.new(1, -20, 0, 0)
				})
				tween(arrow, 0.22, {
					Rotation = opened and 180 or 0
				})
				tween(holder, 0.18, {
					BackgroundColor3 = opened and THEME.CardHover or THEME.Card
				})
			end)

			return holder
		end

		function tab:AddKeybindRow(text, defaultKey, onChanged)
			local currentKey = defaultKey or toggleKey

			local holder = create("Frame", {
				Size = UDim2.new(1, 0, 0, 52),
				BackgroundColor3 = THEME.Card,
				Parent = page,
			})
			corner(holder, 12)
			stroke(holder, THEME.StrokeDark, 1, 0.78)

			create("TextLabel", {
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

			create("TextLabel", {
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
			corner(keyBtn, 10)
			stroke(keyBtn, THEME.StrokeDark, 1, 0.65)
			hoverButton(keyBtn, Color3.fromRGB(26, 30, 46), Color3.fromRGB(36, 41, 61))

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

			return holder
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