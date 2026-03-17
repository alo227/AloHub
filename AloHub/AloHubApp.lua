return (function()
    local GUILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/alo227/AloHub/refs/heads/main/AloHub/GUILibrary.lua"))()
    local LoadingOverlay = loadstring(game:HttpGet("https://raw.githubusercontent.com/alo227/AloHub/refs/heads/main/AloHub/Components/LoadingOverlay.lua"))()
    local SettingsTabFactory = loadstring(game:HttpGet("https://raw.githubusercontent.com/alo227/AloHub/refs/heads/main/AloHub/Tabs/SettingsTab.lua"))()
    local LoginTabFactory = loadstring(game:HttpGet("https://raw.githubusercontent.com/alo227/AloHub/refs/heads/main/AloHub/Tabs/LoginTab.lua"))()
    local MainTabFactory = loadstring(game:HttpGet("https://raw.githubusercontent.com/alo227/AloHub/refs/heads/main/AloHub/Tabs/MainTab.lua"))()
    local WorldZeroFactory = loadstring(game:HttpGet("https://raw.githubusercontent.com/alo227/AloHub/refs/heads/main/AloHub/Games/WorldZero.lua"))() 

    local HttpService = game:GetService("HttpService")

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

            RememberMe = false,
            SavedUsername = "",
            SavedPassword = "",
        }

        self.Window = GUILibrary:CreateWindow("Alo Hub")
        self.Loading = LoadingOverlay.new(self.Window.PageHolder.Parent.Parent)
        self.RegisteredTabs = {}

        self.GameModules = {
            [985731078] = WorldZeroFactory,
        }

        self.ConfigFolder = "AloHub"
        self.ConfigPath = self.ConfigFolder .. "/config.json"

        return self
    end

    function AloHubApp:EnsureConfigFolder()
        if makefolder and isfolder then
            if not isfolder(self.ConfigFolder) then
                makefolder(self.ConfigFolder)
            end
        end
    end

    function AloHubApp:LoadConfig()
        local defaultConfig = {
            username = "",
            password = "",
            rememberMe = false,
        }

        if not (isfile and readfile) then
            return defaultConfig
        end

        self:EnsureConfigFolder()

        if not isfile(self.ConfigPath) then
            return defaultConfig
        end

        local ok, decoded = pcall(function()
            local raw = readfile(self.ConfigPath)
            return HttpService:JSONDecode(raw)
        end)

        if not ok or type(decoded) ~= "table" then
            return defaultConfig
        end

        return {
            username = tostring(decoded.username or ""),
            password = tostring(decoded.password or ""),
            rememberMe = decoded.rememberMe == true,
        }
    end

    function AloHubApp:SaveConfig(username, password, rememberMe)
        if not writefile then
            return
        end

        self:EnsureConfigFolder()

        local data = {
            username = tostring(username or ""),
            password = tostring(password or ""),
            rememberMe = rememberMe == true,
        }

        local ok, encoded = pcall(function()
            return HttpService:JSONEncode(data)
        end)

        if ok and encoded then
            writefile(self.ConfigPath, encoded)
        end
    end

    function AloHubApp:ApplySavedConfig()
        local cfg = self:LoadConfig()

        self.State.SavedUsername = cfg.username
        self.State.SavedPassword = cfg.password
        self.State.RememberMe = cfg.rememberMe
    end

    function AloHubApp:TryLogin(username, password)
        if username == "Alo" and password == "Alo" then
            self.State.IsAuthenticated = true
            self.State.AccountName = "Alo"
            self.State.LicenseStatus = "Premium"
            self.State.LicenseDays = 30
            return true
        end

        return false
    end

    function AloHubApp:Logout()
        self.State.IsAuthenticated = false
        self.State.AccountName = nil
        self.State.LicenseStatus = "Free"
        self.State.LicenseDays = 0
        self:Refresh()
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

        self:ApplySavedConfig()

        if self.State.RememberMe then
            local ok = self:TryLogin(self.State.SavedUsername, self.State.SavedPassword)
            if ok then
                task.delay(0.2, function()
                    self:Refresh()
                end)
                return
            end
        end

        task.delay(0.5, function()
            self:Refresh()
        end)
    end

    return AloHubApp
end)()