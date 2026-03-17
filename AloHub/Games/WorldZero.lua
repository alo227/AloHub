return function(app)
    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local player = Players.LocalPlayer
    local autoMove = false
    local autoAttack = false
    local currentTween = nil

    local moveMode = "Tween"
    local tweenSpeed = 60
    local offsetMode = "Above"
    local offsetDistance = 3
    local attackSpeed = 3

    local AttackRemote = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Combat"):WaitForChild("Attack")

    local function getCharacter()
        return player.Character or player.CharacterAdded:Wait()
    end

    local function getRoot()
        local char = getCharacter()
        return char:WaitForChild("HumanoidRootPart")
    end

    local function getHumanoid()
        local char = getCharacter()
        return char:FindFirstChildOfClass("Humanoid")
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

    local function isMobAlive(mob)
        if not mob then
            return false
        end

        local healthProperties = mob:FindFirstChild("HealthProperties")
        if not healthProperties then
            return false
        end

        local health = healthProperties:FindFirstChild("Health")
        if not health then
            return false
        end

        local value = health.Value
        return typeof(value) == "number" and value > 0
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
            if isMobAlive(mob) then
                local pos = getMobPos(mob)
                if pos then
                    local dist = (pos - root.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestMob = mob
                    end
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

    local function moveToMob(mob)
        if not isMobAlive(mob) then
            return
        end

        local root = getRoot()
        local humanoid = getHumanoid()
        local mobCF = getMobCF(mob)
        if not mobCF then
            return
        end

        local targetPos = mobCF.Position + getOffsetFromTarget(mobCF, offsetMode, offsetDistance)
        local targetCF = CFrame.new(targetPos, mobCF.Position)

        if currentTween then
            currentTween:Cancel()
            currentTween = nil
        end

        if moveMode == "Teleport" then
            root.CFrame = targetCF
            return
        end

        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        end

        local distance = (targetPos - root.Position).Magnitude
        local duration = math.max(distance / math.max(tweenSpeed, 1), 0.05)

        currentTween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            CFrame = targetCF
        })

        currentTween:Play()
    end

    local function attackMob(mob)
        if not AttackRemote then
            warn("AttackRemote not found")
            return
        end

        if not isMobAlive(mob) then
            return
        end

        local root = getRoot()
        local mobPos = getMobPos(mob)
        if not mobPos then
            return
        end

        local delta = mobPos - root.Position
        local magnitude = delta.Magnitude
        if magnitude <= 0.001 then
            return
        end

        local dir = delta.Unit
        local pos = root.Position + dir * 5

        AttackRemote:FireServer("Berserker" .. tostring(math.random(1, 5)), pos, dir, 67)

        print("⚔️ Attack sent to", mob.Name)
    end

    local tab = app.Window:CreateTab("World//Zero", "🌍")

    tab:AddSection("Auto Farm")

    tab:AddToggle("Auto Move", false, function(state)
        autoMove = state
        print("Auto Move:", state)

        if not state and currentTween then
            currentTween:Cancel()
            currentTween = nil
        end
    end)

    tab:AddDropdown("Mode", {"Tween", "Teleport"}, function(selected)
        moveMode = selected
        print("Move Mode:", selected)
    end)

    tab:AddSlider("Tween Speed", 10, 300, tweenSpeed, function(value)
        tweenSpeed = value
        print("Tween Speed:", value)
    end)

    tab:AddDropdown("Tween Position", {"Front", "Behind", "Above", "Left", "Right"}, function(selected)
        offsetMode = selected
        print("Tween Position:", selected)
    end)

    tab:AddSlider("Tween Distance", 1, 25, offsetDistance, function(value)
        offsetDistance = value
        print("Tween Distance:", value)
    end)

    tab:AddSection("Combat")

    tab:AddToggle("Auto Attack", false, function(state)
        autoAttack = state
        print("Auto Attack:", state)
    end)

    tab:AddSlider("Attack Speed", 1, 10, attackSpeed, function(value)
        attackSpeed = value
        print("Attack Speed:", value, "per second")
    end)

    task.spawn(function()
        while true do
            if autoMove then
                local mob = getNearestMob()
                if mob then
                    moveToMob(mob)
                end
            end
            task.wait(0.05)
        end
    end)

    task.spawn(function()
        while true do
            if autoAttack then
                local mob = getNearestMob()
                if mob then
                    attackMob(mob)
                end
            end
            task.wait(1 / math.max(attackSpeed, 1))
        end
    end)

    return tab
end