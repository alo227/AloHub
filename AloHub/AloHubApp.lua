local GUILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/alo227/AloHub/refs/heads/main/AloHub/GUILibrary.lua"))()
local LoadingOverlay = loadstring(game:HttpGet("https://raw.githubusercontent.com/alo227/AloHub/refs/heads/main/AloHub/Components/LoadingOverlay.lua"))()

local SettingsTabFactory = loadstring(game:HttpGet("https://raw.githubusercontent.com/alo227/AloHub/refs/heads/main/AloHub/Tabs/SettingsTab.lua"))()
local LoginTabFactory = loadstring(game:HttpGet("https://raw.githubusercontent.com/alo227/AloHub/refs/heads/main/AloHub/Tabs/LoginTab.lua"))()
local MainTabFactory = loadstring(game:HttpGet("https://raw.githubusercontent.com/alo227/AloHub/refs/heads/main/AloHub/Tabs/MainTab.lua"))()
local WorldZeroFactory = loadstring(game:HttpGet("https://raw.githubusercontent.com/alo227/AloHub/refs/heads/main/AloHub/Games/WorldZero.lua"))()

local AloHubApp = {}
AloHubApp.__index = AloHubApp

function AloHubApp.new()
	local self = setmetatable({}, AloHubApp)

	self.State = {
		IsAuthenticated = false,
		AccountName = nil,
		LicenseDays = 0,
		LicenseStatus = "Free",
		NotificationsEnabled = true,
		ThemeName = "Default",
	}

	self.Window = GUILibrary:CreateWindow("Alo Hub")
	self.Loading = LoadingOverlay.new(self.Window.PageHolder.Parent.Parent)

	self.RegisteredTabs = {}
	self.GameModules = {
		[2727067538] = WorldZeroFactory, -- Beispiel-PlaceId
	}

	return self
end

function AloHubApp:ClearDynamicTabs()
	for name, tab in pairs(self.RegisteredTabs) do
		if name ~= "Settings" then
			tab:Destroy()
			self.RegisteredTabs[name] = nil
		end
	end
end

function AloHubApp:LoadPersistentTabs()
	if not self.RegisteredTabs.Settings then
		self.RegisteredTabs.Settings = SettingsTabFactory(self)
	end
end

function AloHubApp:LoadSessionTabs()
	if self.State.IsAuthenticated then
		if self.RegisteredTabs.Login then
			self.RegisteredTabs.Login:Destroy()
			self.RegisteredTabs.Login = nil
		end

		if not self.RegisteredTabs.Main then
			self.RegisteredTabs.Main = MainTabFactory(self)
		end
	else
		if self.RegisteredTabs.Main then
			self.RegisteredTabs.Main:Destroy()
			self.RegisteredTabs.Main = nil
		end

		if not self.RegisteredTabs.Login then
			self.RegisteredTabs.Login = LoginTabFactory(self)
			self.RegisteredTabs.Login:Show()
		end
	end
end

function AloHubApp:LoadGameTab()
	if not self.State.IsAuthenticated then
		if self.RegisteredTabs.Game then
			self.RegisteredTabs.Game:Destroy()
			self.RegisteredTabs.Game = nil
		end
		return
	end

	local factory = self.GameModules[game.GameId]

	if self.RegisteredTabs.Game then
		self.RegisteredTabs.Game:Destroy()
		self.RegisteredTabs.Game = nil
	end

	if factory then
		self.RegisteredTabs.Game = factory(self)
	end
end

function AloHubApp:Refresh()
	self:LoadPersistentTabs()
	self:LoadSessionTabs()
	self:LoadGameTab()

	if self.State.IsAuthenticated and self.RegisteredTabs.Main then
		self.RegisteredTabs.Main:Show()
	elseif self.RegisteredTabs.Login then
		self.RegisteredTabs.Login:Show()
	end

	task.delay(0.2, function()
		self.Loading:Hide()
	end)
end

function AloHubApp:Start()
	self.Loading:Show("Initializing", "Building interface...")
	task.delay(0.5, function()
		self:Refresh()
	end)
end

return AloHubApp