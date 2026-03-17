local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AloHubApp = require(ReplicatedStorage.AloHub.AloHubApp)

local app = AloHubApp.new()
app:Start()