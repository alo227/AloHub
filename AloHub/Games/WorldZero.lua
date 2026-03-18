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
    local attackSpeed = 3

    local offsetX = 0
    local offsetY = 3
    local offsetZ = 0

    local yLockEnabled = false
    local lockedY = nil

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

    local function clearVerticalVelocity(root)
        local vel = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
    end

    local function setLockedHeight(value)
        lockedY = value
        yLockEnabled = value ~= nil
    end

    local function stopHeightLock()
        yLockEnabled = false
        lockedY = nil
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
        if not mob or not mob.Parent then
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

    local function stopCurrentTween()
        if currentTween then
            currentTween:Cancel()
            currentTween = nil
        end
    end

    local function isNearTarget(root, targetPos, threshold)
        return (targetPos - root.Position).Magnitude <= (threshold or 1.25)
    end

    local function getOffsetPosition(targetCF)
        return targetCF.Position
            + targetCF.RightVector * offsetX
            + Vector3.new(0, offsetY, 0)
            + targetCF.LookVector * offsetZ
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

        local targetPos = getOffsetPosition(mobCF)
        local targetCF = CFrame.new(targetPos, mobCF.Position)

        stopCurrentTween()

        if math.abs(offsetY) > 0.05 then
            setLockedHeight(targetPos.Y)
        else
            stopHeightLock()
        end

        if moveMode == "Teleport" then
            clearVerticalVelocity(root)
            root.CFrame = targetCF
            clearVerticalVelocity(root)
            return
        end

        if isNearTarget(root, targetPos, 1.25) then
            clearVerticalVelocity(root)
            return
        end

        if moveMode == "Tween" then
            if humanoid and math.abs(offsetY) > 0.05 then
                humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
            end

            clearVerticalVelocity(root)

            local distance = (targetPos - root.Position).Magnitude
            local duration = math.max(distance / math.max(tweenSpeed, 1), 0.05)

            currentTween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                CFrame = targetCF
            })

            currentTween:Play()

            currentTween.Completed:Connect(function()
                if root and root.Parent then
                    clearVerticalVelocity(root)
                end
            end)
        end
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
    end

    local tab = app.Window:CreateTab("World//Zero", "🌍")

    tab:AddSection("Auto Farm")

    tab:AddToggle("Auto Move", false, function(state)
        autoMove = state
        print("Auto Move:", state)

        if not state then
            stopCurrentTween()
            stopHeightLock()
        end
    end)

    tab:AddDropdown("Mode", {"Tween", "Teleport"}, function(selected)
        moveMode = selected
        stopCurrentTween()
        print("Move Mode:", selected)
    end)

    tab:AddSlider("Tween Speed", 10, 300, tweenSpeed, function(value)
        tweenSpeed = value
        print("Tween Speed:", value)
    end)

    tab:AddSlider("Offset X", -25, 25, offsetX, function(value)
        offsetX = value
        print("Offset X:", value)
    end)

    tab:AddSlider("Offset Y", -25, 25, offsetY, function(value)
        offsetY = value

        if math.abs(value) <= 0.05 then
            stopHeightLock()
        end

        print("Offset Y:", value)
    end)

    tab:AddSlider("Offset Z", -25, 25, offsetZ, function(value)
        offsetZ = value
        print("Offset Z:", value)
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
            if yLockEnabled and autoMove and moveMode == "Tween" and lockedY then
                local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local pos = root.Position
                    root.CFrame = CFrame.new(pos.X, lockedY, pos.Z) * (root.CFrame - root.CFrame.Position)
                    clearVerticalVelocity(root)
                end
            end
            task.wait(0.03)
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