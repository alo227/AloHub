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
    local selectionMode = "Distance"
    local tweenSpeed = 60
    local offsetMode = "Above"
    local offsetDistance = 3
    local attackSpeed = 3
    local mapDelay = 0.15
    local mapHits = 2

    local yLockEnabled = false
    local lockedY = nil

    local mapIndex = 1
    local mapCycle = {}

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

    local function getAliveMobs()
        local mobsFolder = Workspace:FindFirstChild("Mobs")
        if not mobsFolder then
            return {}
        end

        local alive = {}

        for _, mob in ipairs(mobsFolder:GetChildren()) do
            if isMobAlive(mob) and getMobPos(mob) then
                table.insert(alive, mob)
            end
        end

        return alive
    end

    local function refreshMapCycle()
        mapCycle = getAliveMobs()
        if mapIndex > #mapCycle then
            mapIndex = 1
        end
    end

    local function getNearestMob()
        local root = getRoot()
        local mobs = getAliveMobs()

        local nearestMob = nil
        local nearestDist = math.huge

        for _, mob in ipairs(mobs) do
            local pos = getMobPos(mob)
            if pos then
                local dist = (pos - root.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestMob = mob
                end
            end
        end

        return nearestMob
    end

    local function getNextMapMob()
        if #mapCycle == 0 then
            refreshMapCycle()
        end

        if #mapCycle == 0 then
            return nil
        end

        local checked = 0
        while checked < #mapCycle do
            if mapIndex > #mapCycle then
                refreshMapCycle()
                if #mapCycle == 0 then
                    return nil
                end
                mapIndex = 1
            end

            local mob = mapCycle[mapIndex]
            mapIndex += 1
            checked += 1

            if isMobAlive(mob) and getMobPos(mob) then
                return mob
            end
        end

        refreshMapCycle()
        return nil
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

    local function stopCurrentTween()
        if currentTween then
            currentTween:Cancel()
            currentTween = nil
        end
    end

    local function isNearTarget(root, targetPos, threshold)
        return (targetPos - root.Position).Magnitude <= (threshold or 1.25)
    end

    local function getTargetPosition(mobCF)
        if selectionMode == "Map" then
            local safeMode = offsetMode
            if safeMode == "Above" then
                safeMode = "Behind"
            end

            return mobCF.Position + getOffsetFromTarget(mobCF, safeMode, offsetDistance)
        else
            local targetPos = mobCF.Position + getOffsetFromTarget(mobCF, offsetMode, offsetDistance)

            if offsetMode == "Above" then
                targetPos = Vector3.new(targetPos.X, mobCF.Position.Y + offsetDistance, targetPos.Z)
            end

            return targetPos
        end
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

        local targetPos = getTargetPosition(mobCF)
        local targetCF = CFrame.new(targetPos, mobCF.Position)

        stopCurrentTween()

        if selectionMode == "Map" then
            stopHeightLock()
        else
            if offsetMode == "Above" then
                setLockedHeight(targetPos.Y)
            else
                stopHeightLock()
            end
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
            if selectionMode ~= "Map" and humanoid then
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
        if not AttackRemote or not isMobAlive(mob) then
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
        else
            refreshMapCycle()
        end
    end)

    tab:AddDropdown("Mode", {"Tween", "Teleport"}, function(selected)
        moveMode = selected
        stopCurrentTween()
        print("Move Mode:", selected)
    end)

    tab:AddDropdown("Selection", {"Distance", "Map"}, function(selected)
        selectionMode = selected
        mapIndex = 1
        refreshMapCycle()
        stopCurrentTween()
        stopHeightLock()
        print("Selection Mode:", selected)
    end)

    tab:AddSlider("Tween Speed", 10, 300, tweenSpeed, function(value)
        tweenSpeed = value
        print("Tween Speed:", value)
    end)

    tab:AddDropdown("Tween Position", {"Front", "Behind", "Above", "Left", "Right"}, function(selected)
        offsetMode = selected

        if selectionMode == "Map" or selected ~= "Above" then
            stopHeightLock()
        end

        print("Tween Position:", selected)
    end)

    tab:AddSlider("Tween Distance", 1, 25, offsetDistance, function(value)
        offsetDistance = value
        print("Tween Distance:", value)

        if selectionMode == "Map" or offsetMode ~= "Above" then
            stopHeightLock()
        end
    end)

    tab:AddSlider("Map Delay", 0.05, 1, mapDelay, function(value)
        mapDelay = value
        print("Map Delay:", value)
    end)

    tab:AddSlider("Map Hits", 1, 5, mapHits, function(value)
        mapHits = math.floor(value)
        print("Map Hits:", mapHits)
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
            if autoMove and selectionMode == "Distance" then
                local mob = getNearestMob()
                if mob then
                    moveToMob(mob)
                end
                task.wait(0.05)

            elseif autoMove and selectionMode == "Map" then
                local mob = getNextMapMob()
                if mob then
                    moveToMob(mob)

                    if moveMode == "Tween" then
                        task.wait(math.clamp(mapDelay, 0.05, 0.3))
                    else
                        task.wait(0.03)
                    end

                    if autoAttack then
                        for _ = 1, mapHits do
                            if not autoMove or selectionMode ~= "Map" or not isMobAlive(mob) then
                                break
                            end

                            attackMob(mob)
                            task.wait(0.04)
                        end
                    end
                end

                stopCurrentTween()
                task.wait(mapDelay)
            else
                task.wait(0.05)
            end
        end
    end)

    task.spawn(function()
        while true do
            if yLockEnabled
                and autoMove
                and selectionMode ~= "Map"
                and moveMode == "Tween"
                and offsetMode == "Above"
                and lockedY then

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
            if autoAttack and selectionMode == "Distance" then
                local mob = getNearestMob()
                if mob then
                    attackMob(mob)
                end
                task.wait(1 / math.max(attackSpeed, 1))
            else
                task.wait(0.05)
            end
        end
    end)

    return tab
end