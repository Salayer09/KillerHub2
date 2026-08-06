-- ============================================================================
-- 👾 KILLER HUB | ENGINE V11.4 - SHERIFF SUITE (TOUCH FIX & UNIVERSAL AIM)
-- ============================================================================
local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Salayer09/KillerHub/refs/heads/main/Slayer.lua"))()

-- Prevent double execution
if getgenv().__KillerHubSheriff_Loaded then
    KillerHub:NotifyWarn("Already Loaded", "Sheriff script is already running.", 4)
    return
end
getgenv().__KillerHubSheriff_Loaded = true

-- Flag reader helper
local function Flag(name, default)
    local f = KillerHub.Flags[name]
    if f == nil or f.CurrentValue == nil then return default end
    return f.CurrentValue
end

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService") 
local Stats = game:GetService("Stats") 
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera

-- Math & Constructor Optimizations
local math_clamp = math.clamp
local math_abs = math.abs
local math_pow = math.pow
local math_min = math.min
local vec2New = Vector2.new
local vec3New = Vector3.new
local udim2New = UDim2.new
local cframeNew = CFrame.new
local color3RGB = Color3.fromRGB
local os_clock = os.clock

local workspace_Gravity = workspace.Gravity
local VECTOR_ZERO = vec3New(0, 0, 0)
local PREDICTION_BOOST = 1.10 -- 10% Stronger Prediction Multiplier

-- Preventative cleanup
if _G.KillerHubLines then
    for _, line in pairs(_G.KillerHubLines) do pcall(function() line:Remove() end) end
end
_G.KillerHubLines = {}

local oldGui = game:GetService("CoreGui"):FindFirstChild("KillerHub_SheriffGui")
if oldGui then oldGui:Destroy() end

-- ============================================================================
-- REAL-TIME PING READER
-- ============================================================================
local cachedPingValue = 0.05

local pingTask = task.spawn(function()
    while task.wait(0.2) do
        local currentPing = nil
        pcall(function()
            if Stats and Stats.Network and Stats.Network:FindFirstChild("ServerStatsItem") then
                local dataPing = Stats.Network.ServerStatsItem:FindFirstChild("Data Ping")
                if dataPing then
                    currentPing = dataPing:GetValue() / 1000
                end
            end
        end)

        if not currentPing or currentPing <= 0 then
            pcall(function()
                if LocalPlayer and LocalPlayer.GetNetworkPing then
                    currentPing = LocalPlayer:GetNetworkPing()
                end
            end)
        end

        if currentPing and currentPing > 0 then
            cachedPingValue = currentPing
        end
    end
end)
KillerHub:AddTask(pingTask)

-- ============================================================================
-- USER INTERFACE (CLEAN & SIMPLE ENGLISH)
-- ============================================================================
local TabSheriff = KillerHub:CreateTab("Sheriff", "rbxassetid://15286655815")

TabSheriff:CreateSection("Silent Aim")
TabSheriff:CreateToggle("Sheriff_SilentAim", "Silent Aim", function() end)
TabSheriff:CreateDropdown("Sheriff_ShotType", "Shot Type", {"Normal", "Piercing"}, function() end)
TabSheriff:CreateKeybind("Sheriff_ShootKey", "Shoot Key", Enum.KeyCode.F, function() end)
TabSheriff:CreateToggle("Sheriff_JumpPred", "Jump Prediction", function() end)
TabSheriff:CreateToggle("Sheriff_WallCheck", "Wall Check", function() end)

TabSheriff:CreateSection("Prediction")
TabSheriff:CreateSlider("Sheriff_HScale", "Horizontal Prediction", 0, 300, function() end)
TabSheriff:CreateSlider("Sheriff_VScale", "Vertical Prediction", 0, 300, function() end)

local sliderPing = TabSheriff:CreateSlider("Sheriff_PingComp", "Ping Compensation", 0, 300, function() end)

local pingLoopThread
TabSheriff:CreateToggle("Sheriff_PrioritizePing", "Prioritize Ping", function(estado)
    if pingLoopThread then task.cancel(pingLoopThread) pingLoopThread = nil end
    if estado then
        pingLoopThread = task.spawn(function()
            while Flag("Sheriff_PrioritizePing", false) do
                local currentMS = math.floor(cachedPingValue * 1000)
                if sliderPing and sliderPing.Set then
                    sliderPing:Set(currentMS)
                end
                task.wait(0.3)
            end
        end)
    end
end)

TabSheriff:CreateSlider("Sheriff_CloseRange", "Close Range Zone", 0, 20, function() end)

TabSheriff:CreateSection("Visuals")
TabSheriff:CreateMultiDropdown("Sheriff_Tracers", "Tracers", {"Tracer Prediction", "Min Tracer Prediction", "Lead Time"}, function() end)

local cachedShootButton, cachedScreenGui

TabSheriff:CreateSlider("Sheriff_BtnSize", "Button Size", 50, 200, function(val)
    if cachedShootButton then
        cachedShootButton.Size = udim2New(0, val, 0, val)
    end
end)

TabSheriff:CreateSection("Stabilizers")
TabSheriff:CreateToggle("Sheriff_InertialStab", "Inertial Stabilizer", function() end)

local checkWeaponVisibility

TabSheriff:CreateSection("Interface")
TabSheriff:CreateToggle("Sheriff_WeaponDetect", "Weapon Detector", function() if checkWeaponVisibility then checkWeaponVisibility() end end)
TabSheriff:CreateToggle("Sheriff_ShowButton", "Show Button", function() if checkWeaponVisibility then checkWeaponVisibility() end end)
TabSheriff:CreateToggle("Sheriff_LockBtnPos", "Lock Button Position", function() end)

-- ============================================================================
-- WEAPON & ROLE DETECTION
-- ============================================================================
local function isRangedWeapon(tool)
    if not tool or not tool:IsA("Tool") then return false end
    return (tool:FindFirstChild("Shoot") or tool.Name == "Gun" or tool.Name == "Revolver")
end

local function isMeleeWeapon(tool)
    if not tool or not tool:IsA("Tool") then return false end
    return (tool:FindFirstChild("Stab") or tool.Name == "Knife")
end

checkWeaponVisibility = function()
    if not cachedScreenGui then return end
    local showBtn = Flag("Sheriff_ShowButton", false)
    local useDetect = Flag("Sheriff_WeaponDetect", false)
    
    if not showBtn then
        cachedScreenGui.Enabled = false
        return
    end

    if useDetect then
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        local hasGun = false
        if char then
            for _, item in pairs(char:GetChildren()) do
                if isRangedWeapon(item) then hasGun = true break end
            end
        end
        if not hasGun and backpack then
            for _, item in pairs(backpack:GetChildren()) do
                if isRangedWeapon(item) then hasGun = true break end
            end
        end
        cachedScreenGui.Enabled = hasGun
    else
        cachedScreenGui.Enabled = true
    end
end

local visTask = task.spawn(function()
    while task.wait(0.3) do pcall(checkWeaponVisibility) end
end)
KillerHub:AddTask(visTask)

local MurdererDetectado = nil
local smoothedVelocity = VECTOR_ZERO
local lastTargetChar = nil
local emaDeltaTime = 0.016 
local playerRoles = {}
local playerDeadStatus = {}
local currentTarget = nil
local lastPositions = {} 
local handLineIsBlocked = false 
local lastScanTime = 0

local function setTarget(nt) currentTarget = nt end
local function parsePlayerData(t)
    if type(t) == "table" then
        for name, data in pairs(t) do
            if type(data) == "table" then
                if data.Role then playerRoles[name] = data.Role end
                if data.Dead ~= nil then playerDeadStatus[name] = data.Dead end
            end
        end
    end
end

local PlayerDataChanged = ReplicatedStorage:FindFirstChild("PlayerDataChanged", true)
if PlayerDataChanged and PlayerDataChanged:IsA("RemoteEvent") then 
    KillerHub:AddTask(PlayerDataChanged.OnClientEvent:Connect(parsePlayerData)) 
end

local RoundStart = ReplicatedStorage:FindFirstChild("RoundStart", true)
if RoundStart and RoundStart:IsA("RemoteEvent") then
    KillerHub:AddTask(RoundStart.OnClientEvent:Connect(function(a1, a2)
        table.clear(playerRoles) 
        table.clear(playerDeadStatus) 
        table.clear(lastPositions)
        MurdererDetectado = nil 
        parsePlayerData(a2) 
        parsePlayerData(a1)
    end))
end

local floorCastParams = RaycastParams.new()
floorCastParams.FilterType = Enum.RaycastFilterType.Exclude

local function autoEquipWeapon()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if character and character:FindFirstChild("Humanoid") and backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if isRangedWeapon(item) then 
                character.Humanoid:EquipTool(item) 
                break 
            end
        end
    end
end

local function getGunLocation()
    local char = LocalPlayer.Character
    if char then for _, item in pairs(char:GetChildren()) do if isRangedWeapon(item) then return item, char end end end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then for _, item in pairs(bp:GetChildren()) do if isRangedWeapon(item) then return item, bp end end end
    return nil, nil
end

local function getMurderer()
    if MurdererDetectado and MurdererDetectado.Parent and MurdererDetectado.Character then
        local name = MurdererDetectado.Name
        local char = MurdererDetectado.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not ((hum and hum.Health <= 0) or (playerDeadStatus[name] == true)) and (playerRoles[name] == "Murderer") then
            setTarget(MurdererDetectado) 
            return MurdererDetectado
        else 
            MurdererDetectado = nil 
        end
    end

    for name, role in pairs(playerRoles) do
        if role == "Murderer" then
            local pl = Players:FindFirstChild(name)
            if pl and pl.Character and pl ~= LocalPlayer then
                local hum = pl.Character:FindFirstChildOfClass("Humanoid")
                if not ((hum and hum.Health <= 0) or (playerDeadStatus[name] == true)) then
                    MurdererDetectado = pl 
                    setTarget(pl) 
                    return pl
                end
            end
        end
    end

    local now = os_clock()
    if now - lastScanTime > 0.4 then
        lastScanTime = now
        local potentialMurderer = nil
        local allPlayers = Players:GetPlayers()
        for i = 1, #allPlayers do
            local player = allPlayers[i]
            if player ~= LocalPlayer and player.Parent ~= nil and player.Character then
                local name = player.Name
                local char = player.Character
                local hasKnife = false
                for _, item in pairs(char:GetChildren()) do if isMeleeWeapon(item) then hasKnife = true break end end
                if not hasKnife and player:FindFirstChild("Backpack") then
                    for _, item in pairs(player.Backpack:GetChildren()) do if isMeleeWeapon(item) then hasKnife = true break end end
                end
                if hasKnife then
                    playerRoles[name] = "Murderer"
                    if not ((char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health <= 0) or (playerDeadStatus[name] == true)) then
                        potentialMurderer = player 
                        break
                    end
                end
            end
        end
        if potentialMurderer then MurdererDetectado = potentialMurderer else setTarget(nil) end
    end

    return currentTarget
end

local mapCastParams = RaycastParams.new()
mapCastParams.FilterType = Enum.RaycastFilterType.Exclude
local ignoreListCache = {} 

local function getSmartTargetPart(targetChar)
    if not targetChar then return nil, true end
    local hrp = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("UpperTorso")
    if not hrp then return nil, true end
    
    local wallCheck = Flag("Sheriff_WallCheck", true)
    local shotType = Flag("Sheriff_ShotType", "Normal")

    if not wallCheck or shotType == "Piercing" then 
        return hrp, false 
    end
    
    local origin = Camera.CFrame.Position
    table.clear(ignoreListCache)
    table.insert(ignoreListCache, LocalPlayer.Character)
    table.insert(ignoreListCache, Camera)
    
    local allPlayers = Players:GetPlayers()
    for i = 1, #allPlayers do 
        if allPlayers[i].Character then table.insert(ignoreListCache, allPlayers[i].Character) end 
    end

    local partsToScan = {
        hrp,
        targetChar:FindFirstChild("Head"),
        targetChar:FindFirstChild("LeftHand") or targetChar:FindFirstChild("Left Arm"),
        targetChar:FindFirstChild("RightHand") or targetChar:FindFirstChild("Right Arm")
    }
    
    for i = 1, #partsToScan do
        local part = partsToScan[i]
        if part then
            local targetPos = part.Position
            local currentOrigin = origin
            local direction = targetPos - currentOrigin
            local blocked = false

            while direction.Magnitude > 0.1 do
                mapCastParams.FilterDescendantsInstances = ignoreListCache
                local ray = workspace:Raycast(currentOrigin, direction, mapCastParams)
                if not ray then break end

                local hitInst = ray.Instance
                if hitInst and (hitInst.CanCollide == true and hitInst.Transparency < 0.8) then
                    blocked = true
                    break 
                else
                    table.insert(ignoreListCache, hitInst)
                    currentOrigin = ray.Position + (direction.Unit * 0.05)
                    direction = targetPos - currentOrigin
                end
            end

            if not blocked then 
                return part, false
            end
        end
    end
    return hrp, true
end

local function getFloorHeight(targetHrp, targetChar)
    if not targetHrp then return nil end
    floorCastParams.FilterDescendantsInstances = {targetChar, LocalPlayer.Character, Camera}
    local ray = workspace:Raycast(targetHrp.Position, vec3New(0, -25, 0), floorCastParams)
    return ray and ray.Position.Y or nil
end

-- ============================================================================
-- PREDICTION ENGINE
-- ============================================================================
local function getPredictedPosition(targetChar, targetPart, customDelta)
    if not targetChar or not targetPart then return nil, nil, nil end
    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not humanoid or humanoid.Health <= 0 or not localHrp then return nil, nil, nil end

    local activeDT = customDelta or emaDeltaTime
    local targetPosition = targetPart.Position
    local distance = (targetPosition - localHrp.Position).Magnitude

    local moveMag = humanoid.MoveDirection.Magnitude
    local rawPhysicsVel = hrp.AssemblyLinearVelocity
    local walkSpeed = humanoid.WalkSpeed > 0 and humanoid.WalkSpeed or 16
    
    local intendedVel = vec3New(humanoid.MoveDirection.X * walkSpeed, 0, humanoid.MoveDirection.Z * walkSpeed)
    local actualPhysicsH = vec3New(rawPhysicsVel.X, 0, rawPhysicsVel.Z)
    local rawVelocity = actualPhysicsH:Lerp(intendedVel, math_clamp(moveMag, 0, 1))

    local calculatedVelY = rawPhysicsVel.Y

    if lastPositions[targetChar] then
        local dtPrev = os_clock() - lastPositions[targetChar].Time
        if dtPrev > 0.008 then
            local realYVel = (hrp.Position.Y - lastPositions[targetChar].Pos.Y) / dtPrev
            if math_abs(realYVel) > 0.5 then
                calculatedVelY = realYVel
            end
        end
    end
    lastPositions[targetChar] = {Pos = hrp.Position, Time = os_clock()}

    local closeZone = Flag("Sheriff_CloseRange", 6)
    local predictionWeight = distance <= closeZone and 0 or 1

    if lastTargetChar ~= targetChar then
        smoothedVelocity = rawVelocity 
        lastTargetChar = targetChar
    end

    local isStopping = (moveMag < 0.1 and rawVelocity.Magnitude < 2)
    local isStarting = (moveMag > 0.1 and smoothedVelocity.Magnitude < 2)

    local vSmoothAlpha = 0.35
    if isStopping then
        vSmoothAlpha = 0.80
    elseif isStarting then
        vSmoothAlpha = 0.20
    elseif Flag("Sheriff_InertialStab", true) then
        vSmoothAlpha = math_clamp(14 * activeDT, 0.18, 0.50)
    end
    
    smoothedVelocity = smoothedVelocity:Lerp(rawVelocity, vSmoothAlpha)
    if isStopping and smoothedVelocity.Magnitude < 0.3 then smoothedVelocity = VECTOR_ZERO end

    local horizontalShift = VECTOR_ZERO
    local verticalShift = VECTOR_ZERO

    local prioritizePing = Flag("Sheriff_PrioritizePing", false)
    local vScale = Flag("Sheriff_VScale", 100)

    local effectiveHLatency = 0
    local effectiveVLatency = 0

    if prioritizePing then
        local rawMS = cachedPingValue * 1000
        local autoScale = 90 + (rawMS * 0.6)
        autoScale = math_min(autoScale, 170)

        effectiveHLatency = (autoScale / 1000) * PREDICTION_BOOST

        -- Tope estricto de máximo 80 en la escala vertical para evitar sobrepredicción por pings altos
        local autoVScale = math_min(autoScale, 80)
        effectiveVLatency = (autoVScale / 1000) * PREDICTION_BOOST
    else
        local hScale = Flag("Sheriff_HScale", 100)
        effectiveHLatency = (hScale / 1000) * PREDICTION_BOOST

        local cappedVScale = math_min(vScale, 80)
        effectiveVLatency = (cappedVScale / 1000) * PREDICTION_BOOST
    end

    horizontalShift = vec3New(smoothedVelocity.X, 0, smoothedVelocity.Z) * effectiveHLatency * predictionWeight

    -- Cálculo de predicción vertical dependiente de Vertical Prediction (limitado a máx 80)
    if vScale > 0 then
        local isAir = (humanoid.FloorMaterial == Enum.Material.Air)
        local isStairMovement = (not isAir and math_abs(calculatedVelY) > 0.8)

        if isAir or isStairMovement then
            local adaptiveYFactor = math_clamp((distance - closeZone) / 12, 0, 1)
            local vFactor = effectiveVLatency * adaptiveYFactor

            if isAir then
                local gravityEffect = 0.5 * workspace_Gravity * math_pow(vFactor, 2)
                local pY = (calculatedVelY * vFactor) - gravityEffect
                verticalShift = vec3New(0, pY, 0)
            elseif isStairMovement then
                local pY = calculatedVelY * vFactor
                verticalShift = vec3New(0, pY, 0)
            end
        end
    end

    if horizontalShift.Magnitude > 8.5 then horizontalShift = horizontalShift.Unit * 8.5 end
    if verticalShift.Magnitude > 6.0 then verticalShift = verticalShift.Unit * 6.0 end

    local finalPredNoY = vec3New(targetPosition.X + horizontalShift.X, targetPosition.Y, targetPosition.Z + horizontalShift.Z)
    local minPredNoY = vec3New(targetPosition.X + (horizontalShift.X * 0.4), targetPosition.Y, targetPosition.Z + (horizontalShift.Z * 0.4))

    local finalPredWithY = targetPosition + horizontalShift + verticalShift
    local floorY = getFloorHeight(hrp, targetChar)
    if floorY then
        local minAllowedY = floorY + (hrp.Size.Y / 2) + 0.1
        if finalPredWithY.Y < minAllowedY then finalPredWithY = vec3New(finalPredWithY.X, minAllowedY, finalPredWithY.Z) end
    end

    return finalPredWithY, finalPredNoY, minPredNoY
end

-- ============================================================================
-- TRACERS & VISUALS
-- ============================================================================
local MinPredictionLine = Drawing.new("Line")
MinPredictionLine.Color = color3RGB(4, 0, 220)
MinPredictionLine.Thickness = 2.0
MinPredictionLine.Transparency = 1.0  
MinPredictionLine.ZIndex = 5          

local PredictionLine = Drawing.new("Line")
PredictionLine.Color = color3RGB(255, 35, 35)
PredictionLine.Thickness = 2.0
PredictionLine.Transparency = 1.0  
PredictionLine.ZIndex = 10         

local LeadTimeLine = Drawing.new("Line")
LeadTimeLine.Color = color3RGB(35, 255, 35)
LeadTimeLine.Thickness = 1.8
LeadTimeLine.Transparency = 1.0  
LeadTimeLine.ZIndex = 7

table.insert(_G.KillerHubLines, MinPredictionLine)
table.insert(_G.KillerHubLines, PredictionLine)
table.insert(_G.KillerHubLines, LeadTimeLine)

local worldToViewport = Camera.WorldToViewportPoint

local renderConn = RunService.RenderStepped:Connect(function(dt)
    emaDeltaTime = emaDeltaTime + 0.2 * (dt - emaDeltaTime) 

    local murderer = getMurderer()
    if not murderer or not murderer.Character then
        PredictionLine.Visible = false; MinPredictionLine.Visible = false; LeadTimeLine.Visible = false;
        return
    end

    local targetChar = murderer.Character
    local visualPart, isBlocked = getSmartTargetPart(targetChar) 
    handLineIsBlocked = isBlocked

    local myChar = LocalPlayer.Character
    local rightHand = myChar and (myChar:FindFirstChild("RightHand") or myChar:FindFirstChild("Right Arm"))

    local tracersTable = Flag("Sheriff_Tracers", {})
    local showRed = tracersTable["Tracer Prediction"] == true
    local showBlue = tracersTable["Min Tracer Prediction"] == true
    local showGreen = tracersTable["Lead Time"] == true

    if visualPart then
        local _, predNoY, minPredNoY = getPredictedPosition(targetChar, visualPart, dt)
        local currentViewportSize = Camera.ViewportSize
        local screenOrigin = vec2New(currentViewportSize.X / 2, currentViewportSize.Y)

        if predNoY and minPredNoY then
            if showBlue then
                local screenPos, onScreen = worldToViewport(Camera, minPredNoY)
                if onScreen then
                    MinPredictionLine.From = screenOrigin 
                    MinPredictionLine.To = vec2New(screenPos.X, screenPos.Y) 
                    MinPredictionLine.Visible = true
                else MinPredictionLine.Visible = false end
            else MinPredictionLine.Visible = false end

            if showRed then
                local screenPos, onScreen = worldToViewport(Camera, predNoY)
                if onScreen then
                    PredictionLine.From = screenOrigin 
                    PredictionLine.To = vec2New(screenPos.X, screenPos.Y) 
                    PredictionLine.Visible = true
                else PredictionLine.Visible = false end
            else PredictionLine.Visible = false end

            if rightHand and showGreen then
                local handScreenPos, handOnScreen = worldToViewport(Camera, rightHand.Position)
                local predScreenPos, predOnScreen = worldToViewport(Camera, predNoY)

                if handOnScreen and predOnScreen then
                    local shotType = Flag("Sheriff_ShotType", "Normal")
                    LeadTimeLine.Color = (handLineIsBlocked and shotType ~= "Piercing") and color3RGB(255, 255, 255) or color3RGB(35, 255, 35)
                    LeadTimeLine.From = vec2New(handScreenPos.X, handScreenPos.Y)
                    LeadTimeLine.To = vec2New(predScreenPos.X, predScreenPos.Y)
                    LeadTimeLine.Visible = true
                else LeadTimeLine.Visible = false end
            else LeadTimeLine.Visible = false end
        end
    else
        PredictionLine.Visible = false; MinPredictionLine.Visible = false; LeadTimeLine.Visible = false;
    end 
end)
KillerHub:AddTask(renderConn)

-- ============================================================================
-- FIRING EXECUTION
-- ============================================================================
local function fireAtMurdererDirectly()
    local shotType = Flag("Sheriff_ShotType", "Normal")
    if handLineIsBlocked and shotType ~= "Piercing" then return end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end 

    local murderer = getMurderer()
    if murderer and murderer.Character then
        local targetChar = murderer.Character
        local bestPart, isBlocked = getSmartTargetPart(targetChar) 
        if bestPart and (not isBlocked or shotType == "Piercing") then 
            local finalPredictedPos = getPredictedPosition(targetChar, bestPart)
            if finalPredictedPos then
                autoEquipWeapon()
                local gun, _ = getGunLocation()
                if gun and gun:FindFirstChild("Shoot") then
                    local originCFrame = char.HumanoidRootPart.CFrame
                    if char.HumanoidRootPart:FindFirstChild("GunRaycastAttachment") then 
                        originCFrame = char.HumanoidRootPart.GunRaycastAttachment.WorldCFrame 
                    end

                    if shotType == "Piercing" then
                        local dir = (finalPredictedPos - char.HumanoidRootPart.Position).Unit
                        originCFrame = cframeNew(finalPredictedPos - (dir * 1.3), finalPredictedPos)
                    end

                    gun.Shoot:FireServer(originCFrame, cframeNew(finalPredictedPos))
                end
            end
        end
    end
end

-- Keybind listener
local inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local targetKey = Flag("Sheriff_ShootKey", "F")
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode.Name == targetKey or tostring(input.KeyCode) == tostring(targetKey) then
            task.spawn(fireAtMurdererDirectly)
        end
    end
end)
KillerHub:AddTask(inputConn)

-- ============================================================================
-- TOUCH SHOOT BUTTON
-- ============================================================================
local POS_FILE = "KillerHub_ButtonPos.txt"

local function loadButtonPosition()
    if isfile and readfile and isfile(POS_FILE) then
        local ok, result = pcall(function()
            return HttpService:JSONDecode(readfile(POS_FILE))
        end)
        if ok and type(result) == "table" and result.X and result.Y then
            return udim2New(result.X, 0, result.Y, 0)
        end
    end
    if getgenv().__KillerHub_ButtonPos then
        return getgenv().__KillerHub_ButtonPos
    end
    return udim2New(0.7, 0, 0.6, 0)
end

local function saveButtonPosition(pos)
    getgenv().__KillerHub_ButtonPos = pos
    if writefile then
        pcall(function()
            writefile(POS_FILE, HttpService:JSONEncode({X = pos.X.Scale, Y = pos.Y.Scale}))
        end)
    end
end

local VoidGui = Instance.new("ScreenGui")
VoidGui.Name = "KillerHub_SheriffGui"
VoidGui.ResetOnSpawn = false 
VoidGui.Parent = game:GetService("CoreGui")
KillerHub:AddTask(VoidGui)

local btnSize = Flag("Sheriff_BtnSize", 95)
local ShootButton = Instance.new("ImageButton")
ShootButton.Name = "ShootButton"
ShootButton.Size = udim2New(0, btnSize, 0, btnSize)
ShootButton.Position = loadButtonPosition()
ShootButton.BackgroundColor3 = color3RGB(15, 6, 26)
ShootButton.BackgroundTransparency = 0.05
ShootButton.BorderSizePixel = 0; ShootButton.AutoButtonColor = false; ShootButton.ClipsDescendants = true; ShootButton.Parent = VoidGui

cachedScreenGui = VoidGui
cachedShootButton = ShootButton

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0.28, 0) Corner.Parent = ShootButton

local GlowOverlay = Instance.new("Frame")
GlowOverlay.Size = udim2New(1, 0, 1, 0) 
GlowOverlay.BackgroundTransparency = 1; 
GlowOverlay.ZIndex = ShootButton.ZIndex + 1; 
GlowOverlay.Parent = ShootButton

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(0.28, 0) GlowCorner.Parent = GlowOverlay

local UiGradient = Instance.new("UIGradient")
UiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, color3RGB(24, 8, 43)), 
    ColorSequenceKeypoint.new(0.5, color3RGB(131, 46, 222)), 
    ColorSequenceKeypoint.new(1, color3RGB(24, 8, 43))
})
UiGradient.Offset = vec2New(0, 0) 
UiGradient.Rotation = 0 
UiGradient.Parent = GlowOverlay

local rotTask = task.spawn(function()
    while VoidGui.Parent do
        local tweenRot = TweenService:Create(UiGradient, TweenInfo.new(3, Enum.EasingStyle.Linear), {Rotation = UiGradient.Rotation + 360})
        tweenRot:Play()
        tweenRot.Completed:Wait()
    end
end)
KillerHub:AddTask(rotTask)

local DecalTexture = Instance.new("ImageLabel")
DecalTexture.Size = udim2New(0.37, 0, 0.37, 0) DecalTexture.AnchorPoint = vec2New(0.5, 0.5) DecalTexture.Position = udim2New(0.5, 0, 0.44, 0)
DecalTexture.BackgroundTransparency = 1; DecalTexture.Image = "rbxassetid://125754446555599"
DecalTexture.ZIndex = ShootButton.ZIndex + 2; DecalTexture.Parent = ShootButton

local animTask = task.spawn(function()
    local ti = TweenInfo.new(0.80, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local t1 = TweenService:Create(DecalTexture, ti, {Rotation = 360})
    local t2 = TweenService:Create(DecalTexture, ti, {Rotation = 0})
    KillerHub:AddTask(t1.Completed:Connect(function() task.wait(0.032) t2:Play() end))
    KillerHub:AddTask(t2.Completed:Connect(function() task.wait(0.032) t1:Play() end))
    t1:Play()
end)
KillerHub:AddTask(animTask)

local Label = Instance.new("TextLabel")
Label.Size = udim2New(1, 0, 0.2, 0) Label.Position = udim2New(0, 0, 0.75, 0) Label.BackgroundTransparency = 1
Label.Text = "SHOOT" Label.TextColor3 = color3RGB(255, 255, 255) Label.TextSize = 15 Label.Font = Enum.Font.GothamBold
Label.ZIndex = ShootButton.ZIndex + 2; Label.Parent = ShootButton

local dragging, dragInput, dragStart, startPos
KillerHub:AddTask(ShootButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        TweenService:Create(GlowOverlay, TweenInfo.new(0.01, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.02}):Play()
        task.spawn(fireAtMurdererDirectly)
        
        if not Flag("Sheriff_LockBtnPos", false) then
            dragging = true dragStart = input.Position startPos = ShootButton.Position
            local cChanged
            cChanged = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false 
                    cChanged:Disconnect()
                    saveButtonPosition(ShootButton.Position)
                end
            end)
        end
     end
end))

KillerHub:AddTask(ShootButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        TweenService:Create(GlowOverlay, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        if dragging then
            dragging = false
            saveButtonPosition(ShootButton.Position)
        end
    end
end))

KillerHub:AddTask(ShootButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end))

KillerHub:AddTask(UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging and not Flag("Sheriff_LockBtnPos", false) then
        local delta = input.Position - dragStart
        ShootButton.Position = udim2New(startPos.X.Scale + (delta.X / Camera.ViewportSize.X), 0, startPos.Y.Scale + (delta.Y / Camera.ViewportSize.Y), 0)
    end
end))

-- ============================================================================
-- SILENT AIM HOOKS (WEAPONSERVICE INTERCEPTOR)
-- ============================================================================
local WeaponService = nil
local ClientServices = ReplicatedStorage:FindFirstChild("ClientServices") or ReplicatedStorage:FindFirstChild("Services")
if ClientServices then
    local ws = ClientServices:FindFirstChild("WeaponService") or ClientServices:FindFirstChild("GunService")
    if ws and ws:IsA("ModuleScript") then pcall(function() WeaponService = require(ws) end) end
end
if not WeaponService then
    local descendants = ReplicatedStorage:GetDescendants()
    for i = 1, #descendants do
        local obj = descendants[i]
        if obj:IsA("ModuleScript") then
            local success, mod = pcall(require, obj)
            if success and type(mod) == "table" and (mod.GetTargetPosition or mod.GetMouseTargetCFrame) then WeaponService = mod break end
        end
    end
end

if WeaponService then
    local oldGetTargetPosition = WeaponService.GetTargetPosition
    local oldGetMouseTargetCFrame = WeaponService.GetMouseTargetCFrame
    local lastHookCallTime = os_clock()

    local function getPredictedTargetCFrame(customDelta)
        local silentAim = Flag("Sheriff_SilentAim", false)
        if not silentAim then return nil end

        local shotType = Flag("Sheriff_ShotType", "Normal")
        local useDetect = Flag("Sheriff_WeaponDetect", false)

        local gun, _ = getGunLocation()
        if useDetect and not gun then return nil end

        local murderer = getMurderer()
        if not murderer or not murderer.Character then return nil end

        local bestPart, isBlocked = getSmartTargetPart(murderer.Character)
        if not bestPart then return nil end
        if isBlocked and shotType ~= "Piercing" then return nil end

        local currentTime = os_clock()
        local dt = customDelta or math_clamp(currentTime - lastHookCallTime, 0.008, 0.033)
        lastHookCallTime = currentTime

        local finalPredictedPos = getPredictedPosition(murderer.Character, bestPart, dt)
        if finalPredictedPos then
            return cframeNew(finalPredictedPos)
        end
        return nil
    end

    if oldGetTargetPosition then
        WeaponService.GetTargetPosition = function(self, ...)
            local targetCF = getPredictedTargetCFrame()
            if targetCF then
                return targetCF
            end
            return oldGetTargetPosition(self, ...)
        end
    end

    if oldGetMouseTargetCFrame then
        WeaponService.GetMouseTargetCFrame = function(self, ...)
            local targetCF = getPredictedTargetCFrame()
            if targetCF then
                return targetCF
            end
            return oldGetMouseTargetCFrame(self, ...)
        end
    end
end

return KillerHub
