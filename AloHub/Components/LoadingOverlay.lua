local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LoadingOverlay = {}
LoadingOverlay.__index = LoadingOverlay

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
	s.Color = color
	s.Thickness = thickness or 1
	s.Transparency = transparency == nil and 0.35 or transparency
	s.Parent = obj
	return s
end

function LoadingOverlay.new(parent)
	local self = setmetatable({}, LoadingOverlay)

	self.Gui = create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(4, 6, 12),
		BackgroundTransparency = 0.18,
		Visible = false,
		ZIndex = 100,
		Parent = parent,
	})

	self.Card = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 210, 0, 120),
		BackgroundColor3 = Color3.fromRGB(15, 18, 30),
		ZIndex = 101,
		Parent = self.Gui,
	})
	corner(self.Card, 16)
	stroke(self.Card, Color3.fromRGB(90, 102, 168), 1, 0.45)

	self.Spinner = create("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 34),
		Size = UDim2.new(0, 36, 0, 36),
		BackgroundTransparency = 1,
		Text = "◌",
		Font = Enum.Font.GothamBold,
		TextSize = 26,
		TextColor3 = Color3.fromRGB(125, 92, 255),
		ZIndex = 102,
		Parent = self.Card,
	})

	self.Title = create("TextLabel", {
		Position = UDim2.new(0, 12, 0, 60),
		Size = UDim2.new(1, -24, 0, 20),
		BackgroundTransparency = 1,
		Text = "Loading...",
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = Color3.fromRGB(240, 243, 255),
		ZIndex = 102,
		Parent = self.Card,
	})

	self.Sub = create("TextLabel", {
		Position = UDim2.new(0, 12, 0, 82),
		Size = UDim2.new(1, -24, 0, 14),
		BackgroundTransparency = 1,
		Text = "Please wait",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = Color3.fromRGB(150, 158, 188),
		ZIndex = 102,
		Parent = self.Card,
	})

	self._rotationConnection = nil

	return self
end

function LoadingOverlay:Show(title, subtitle)
	self.Title.Text = title or "Loading..."
	self.Sub.Text = subtitle or "Please wait"
	self.Gui.Visible = true
	self.Gui.BackgroundTransparency = 1
	self.Card.BackgroundTransparency = 1
	self.Spinner.TextTransparency = 1
	self.Title.TextTransparency = 1
	self.Sub.TextTransparency = 1

	TweenService:Create(self.Gui, TweenInfo.new(0.18), {
		BackgroundTransparency = 0.18,
	}):Play()

	TweenService:Create(self.Card, TweenInfo.new(0.18), {
		BackgroundTransparency = 0,
	}):Play()

	TweenService:Create(self.Spinner, TweenInfo.new(0.18), {
		TextTransparency = 0,
	}):Play()

	TweenService:Create(self.Title, TweenInfo.new(0.18), {
		TextTransparency = 0,
	}):Play()

	TweenService:Create(self.Sub, TweenInfo.new(0.18), {
		TextTransparency = 0,
	}):Play()

	if self._rotationConnection then
		self._rotationConnection:Disconnect()
	end

	self._rotationConnection = RunService.RenderStepped:Connect(function(dt)
		self.Spinner.Rotation = (self.Spinner.Rotation + dt * 240) % 360
	end)
end

function LoadingOverlay:Hide()
	if self._rotationConnection then
		self._rotationConnection:Disconnect()
		self._rotationConnection = nil
	end

	local t1 = TweenService:Create(self.Gui, TweenInfo.new(0.18), {
		BackgroundTransparency = 1,
	})
	local t2 = TweenService:Create(self.Card, TweenInfo.new(0.18), {
		BackgroundTransparency = 1,
	})
	local t3 = TweenService:Create(self.Spinner, TweenInfo.new(0.18), {
		TextTransparency = 1,
	})
	local t4 = TweenService:Create(self.Title, TweenInfo.new(0.18), {
		TextTransparency = 1,
	})
	local t5 = TweenService:Create(self.Sub, TweenInfo.new(0.18), {
		TextTransparency = 1,
	})

	t1:Play()
	t2:Play()
	t3:Play()
	t4:Play()
	t5:Play()

	task.delay(0.2, function()
		if self.Gui then
			self.Gui.Visible = false
		end
	end)
end

return LoadingOverlay