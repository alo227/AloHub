return function(app)
    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")

    local player = Players.LocalPlayer
    local autoMove = false
    local currentTween = nil

    local function getRoot()
        local char = player.Character or player.CharacterAdded:Wait()
        return char:WaitForChild("HumanoidRootPart")
    end

    local function getMobPos(mob)
        local ok, cf = pcall(function()
            return mob:GetPivot()
        end)
        return ok and cf and cf.Position or nil
    end

    local function getNearestMob()
        local root = getRoot()
        local mobsFolder = Workspace:FindFirstChild("Mobs")
        if not mobsFolder then
            return nil
        end

        local nearestMob = nil
        local nearestDist = math.huge

        for _, mob in ipairs(mobsFolder:GetChildren()) do
            local pos = getMobPos(mob)
            if pos then
                local dist = (pos - root.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestMob = mob
                end
            end
        end

        return nearestMob, nearestDist
    end

    local function tweenToPosition(targetPos)
        local root = getRoot()

        if currentTween then
            currentTween:Cancel()
            currentTween = nil
        end

        local distance = (targetPos - root.Position).Magnitude
        local speed = 60
        local duration = math.max(distance / speed, 0.05)

        currentTween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(targetPos)
        })

        currentTween:Play()
    end

    local tab = app.Window:CreateTab("World//Zero", "🌍")

    tab:AddSection("Game Module")
    tab:AddLabel("Detected Game: World//Zero")
    tab:AddLabel("Module Status: Loaded")

    tab:AddSection("Auto Farm")
    tab:AddToggle("Auto Move", false, function(state)
        autoMove = state
        print("Auto Move:", state)

        if not state and currentTween then
            currentTween:Cancel()
            currentTween = nil
        end
    end)

    task.spawn(function()
        while true do
            if autoMove then
                local mob = getNearestMob()
                if mob then
                    local pos = getMobPos(mob)
                    if pos then
                        tweenToPosition(pos + Vector3.new(0, 3, 0))
                    end
                end
            end
            task.wait(0.35)
        end
    end)

    tab:AddSection("Placeholders")
    tab:AddButton("World//Zero Action Placeholder", function()
        print("World//Zero action placeholder")
    end)

    tab:AddToggle("World//Zero Toggle Placeholder", false, function(state)
        print("World//Zero toggle:", state)
    end)

    tab:AddDropdown("World//Zero List Placeholder", {"Quest Placeholder", "Dungeon Placeholder", "Boss Placeholder"},
        function(selected)
            print("World//Zero selected:", selected)
        end)

    return tab
end
