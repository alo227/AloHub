return function(app)
    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")

    local player = Players.LocalPlayer
    local autoMove = false
    local currentTween = nil

    local tweenSpeed = 60
    local offsetMode = "Above"
    local offsetDistance = 3

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

    local function getMobCF(mob)
        local ok, cf = pcall(function()
            return mob:GetPivot()
        end)
        return ok and cf or nil
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

    local function getOffsetFromTarget(targetCF, mode, distance)
        if mode == "Front" then
            return targetCF.LookVector * distance
        elseif mode == "Behind" then
            return -targetCF.LookVector * distance
        elseif mode == "Above" then
            return Vector3.new(0, distance, 0)
        elseif mode == "Left" then
            return -targetCF.RightVector * distance
        elseif mode == "Right" then
            return targetCF.RightVector * distance
        end

        return Vector3.new(0, distance, 0)
    end

    local function tweenToMob(mob)
        local root = getRoot()
        local mobCF = getMobCF(mob)
        if not mobCF then
            return
        end

        if currentTween then
            currentTween:Cancel()
            currentTween = nil
        end

        local targetPos = mobCF.Position + getOffsetFromTarget(mobCF, offsetMode, offsetDistance)
        local distance = (targetPos - root.Position).Magnitude
        local duration = math.max(distance / math.max(tweenSpeed, 1), 0.05)

        currentTween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(targetPos, mobCF.Position)
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

    tab:AddSlider("Tween Speed", 10, 300, tweenSpeed, function(value)
        tweenSpeed = value
        print("Tween Speed:", value)
    end)

    tab:AddDropdown("Tween Position", {
        "Front",
        "Behind",
        "Above",
        "Left",
        "Right"
    }, function(selected)
        offsetMode = selected
        print("Tween Position:", selected)
    end)

    tab:AddSlider("Tween Distance", 1, 25, offsetDistance, function(value)
        offsetDistance = value
        print("Tween Distance:", value)
    end)

    task.spawn(function()
        while true do
            if autoMove then
                local mob = getNearestMob()
                if mob then
                    tweenToMob(mob)
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

    tab:AddDropdown("World//Zero List Placeholder", {"Quest Placeholder", "Dungeon Placeholder", "Boss Placeholder"}, function(selected)
        print("World//Zero selected:", selected)
    end)

    return tab
end