-- ============================================================================
-- 👾 KILLER HUB | ENGINE V10.8 - SILENT AIM & TARGETING SUITE
-- ============================================================================
getgenv().KillerHub = {
    Config = {
        Volume = 0.5,                  
        ToggleKey = "RightControl",    
        ShowWatermark = true           
    },
    Flags = {} 
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService") 
local Stats = game:GetService("Stats") 
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local math_clamp = math.clamp
local math_min = math_min
local math_max = math_max
local math_abs = math.abs
local math_pow = math.pow
local vec2New = Vector2.new
local vec3New = Vector3.new
local udim2New = UDim2.new
local cframeNew = CFrame.new
local color3RGB = Color3.fromRGB
local os_clock = os.clock

local workspace = workspace
local workspace_Gravity = workspace.Gravity
local VECTOR_ZERO = vec3New(0, 0, 0)

if _G.KillerHubLines then
    for _, line in pairs(_G.KillerHubLines) do pcall(function() line:Remove() end) end
end
_G.KillerHubLines = {}

if _G.KillerHubConnections then
    for _, conn in pairs(_G.KillerHubConnections) do pcall(function() conn:Disconnect() end) end
end
_G.KillerHubConnections = {}

local oldGui = game:GetService("CoreGui"):FindFirstChild("KillerHub_SheriffGui")
if oldGui then oldGui:Destroy() end

local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Salayer09/KillerHub/refs/heads/main/Slayer.lua"))()

local SheriffConfig = {
    SilentAim = false,
    JumpPrediction = true, 
    PredictionMode = "PREDICTION PRO", 
    HorizontalScale = 100,  
    VerticalScale = 100,    
    PingCompensation = 100, 
    CloseRangeZone = 6, 
    WallCheck = true,    
    AntiJukeFilter = true,
    ShowRedTracer = true,      
    ShowBlueTracer = true, 
    ShowGreenTracer = true,
    UseWeaponDetector = false, 
    ShowShootButton = false,
    ButtonSize = 95,
    ButtonOpacity = 0.95, 
    ButtonX = 0.7, 
    ButtonY = 0.6,
    ShootKey = Enum.KeyCode.E
}

local HttpService = game:GetService("HttpService")
local CONFIG_FILE = "KillerHub_SheriffSuite_v108.txt"

local function saveConfig()
    pcall(function() if writefile then writefile(CONFIG_FILE, HttpService:JSONEncode(SheriffConfig)) end end)
end

local function loadConfig()
    pcall(function()
        if isfile and isfile(CONFIG_FILE) then
            local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
            if data then for k, v in pairs(data) do if SheriffConfig[k] ~= nil then SheriffConfig[k] = v end end end
        end
    end)
end
loadConfig()

local function isRangedWeapon(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if tool:FindFirstChild("Shoot") or tool.Name == "Gun" or tool.Name == "Revolver" then return true end
    return false
end

local function isMeleeWeapon(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if tool:FindFirstChild("Stab") or tool.Name == "Knife" or tool.Name == "Slash" then return true end
    return false
end

local cachedScreenGui, cachedShootButton

local function checkWeaponVisibility()
    if not cachedScreenGui then return end
    if not SheriffConfig.ShowShootButton then cachedScreenGui.Enabled = false return end
    if SheriffConfig.UseWeaponDetector then
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        local hasGun = false
        if char then for _, item in pairs(char:GetChildren()) do if isRangedWeapon(item) then hasGun = true break end end end
        if not hasGun and backpack then for _, item in pairs(backpack:GetChildren()) do if isRangedWeapon(item) then hasGun = true break end end end
        cachedScreenGui.Enabled = hasGun
    else cachedScreenGui.Enabled = true end
end

-- UI MENU
local SheriffTab = KillerHub:CreateTab("Sheriff", "rbxassetid://10747373142")

SheriffTab:CreateSection("Silent Aim Settings")
SheriffTab:CreateToggle("SheriffSilent", "Silent Aim", function(estado) SheriffConfig.SilentAim = estado saveConfig() end)
SheriffTab:CreateToggle("JumpPredToggle", "Jump Prediction", function(estado) SheriffConfig.JumpPrediction = estado saveConfig() end, SheriffConfig.JumpPrediction)
SheriffTab:CreateToggle("SheriffWallCheckToggle", "Wall Check", function(estado) SheriffConfig.WallCheck = estado saveConfig() end)
SheriffTab:CreateDropdown("PredMode", "Prediction Mode:", {"PREDICTION PRO", "PREDICTION SIMPLE"}, function(sel) SheriffConfig.PredictionMode = sel saveConfig() end)

SheriffTab:CreateSection("Controls & Keybinds")
SheriffTab:CreateKeybind("ShootKeybind", "Shoot Keybind (PC)", SheriffConfig.ShootKey or Enum.KeyCode.E, function(key)
    SheriffConfig.ShootKey = key
    saveConfig()
end)

SheriffTab:CreateSection("Prediction Calibration")
SheriffTab:CreateSlider("HorizontalScaleSlider", "Horizontal Prediction", 0, 300, function(v) SheriffConfig.HorizontalScale = v saveConfig() end, SheriffConfig.HorizontalScale)
SheriffTab:CreateSlider("VerticalScaleSlider", "Vertical Prediction", 0, 300, function(v) SheriffConfig.VerticalScale = v saveConfig() end, SheriffConfig.VerticalScale)
SheriffTab:CreateSlider("PingCompSlider", "Ping Compensation (%)", 0, 200, function(v) SheriffConfig.PingCompensation = v saveConfig() end, SheriffConfig.PingCompensation)
SheriffTab:CreateSlider("CloseRangeZoneSlider", "Close-Range Deadzone", 0, 20, function(v) SheriffConfig.CloseRangeZone = v saveConfig() end, SheriffConfig.CloseRangeZone)

SheriffTab:CreateSection("Visual Settings")
SheriffTab:CreateMultiDropdown("ActiveTracers", "Tracer Predictions:", {"Horizontal Tracer Prediction", "Minimum Tracer Prediction", "Lead Time Tracer Prediction"}, function(tablaFlags)
    SheriffConfig.ShowRedTracer = tablaFlags["Horizontal Tracer Prediction"] or false
    SheriffConfig.ShowBlueTracer = tablaFlags["Minimum Tracer Prediction"] or false 
    SheriffConfig.ShowGreenTracer = tablaFlags["Lead Time Tracer Prediction"] or false
    saveConfig()
end)

SheriffTab:CreateSlider("VoidBtnSize", "Shoot Button Size", 50, 200, function(valor)
    SheriffConfig.ButtonSize = valor
    if cachedShootButton then cachedShootButton.Size = udim2New(0, valor, 0, valor) end
    saveConfig()
end, SheriffConfig.ButtonSize)

SheriffTab:CreateSection("Movement Filters")
SheriffTab:CreateToggle("AntiJukeToggle", "Anti-Juke Lag Filter", function(estado) SheriffConfig.AntiJukeFilter = estado saveConfig() end)

SheriffTab:CreateSection("UI Settings")
SheriffTab:CreateToggle("WeaponDetectToggle", "Hide Without Weapon", function(estado) SheriffConfig.UseWeaponDetector = estado saveConfig() checkWeaponVisibility() end)
SheriffTab:CreateToggle("ShowVoidButton", "Show Shoot Button", function(estado) SheriffConfig.ShowShootButton = estado saveConfig() checkWeaponVisibility() end)

local MurdererDetectado = nil
local smoothedVelocity = VECTOR_ZERO
local lastTargetChar = nil
local emaDeltaTime = 0.016 
local cachedPingValue = 0.06
local pingHistory = {} 
local playerRoles = {}
local playerDeadStatus = {}
local currentTarget = nil
local isFiringCooldown = false
local positionHistory = {}
local lastPositions = {} 
local MAX_HISTORY_FRAMES = 4 
local handLineIsBlocked = false 

local lastWorldPredNoY = nil
local lastWorldMinPredNoY = nil

task.spawn(function()
    while task.wait(0.25) do
        if Stats and Stats:FindFirstChild("Network") and Stats.Network:FindFirstChild("ServerToClientPing") then
            local rawPing = Stats.Network.ServerToClientPing:GetValue() / 1000
            table.insert(pingHistory, rawPing)
            if #pingHistory > 5 then table.remove(pingHistory, 1) end
            local sortPing = {unpack(pingHistory)}
            table.sort(sortPing)
            cachedPingValue = sortPing[math.ceil(#sortPing / 2)] or rawPing
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do pcall(checkWeaponVisibility) end
end)

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
if PlayerDataChanged and PlayerDataChanged:IsA("RemoteEvent") then table.insert(_G.KillerHubConnections, PlayerDataChanged.OnClientEvent:Connect(parsePlayerData)) end

local RoundStart = ReplicatedStorage:FindFirstChild("RoundStart", true)
if RoundStart and RoundStart:IsA("RemoteEvent") then
    table.insert(_G.KillerHubConnections, RoundStart.OnClientEvent:Connect(function(a1, a2)
        table.clear(playerRoles) table.clear(playerDeadStatus) table.clear(positionHistory) table.clear(lastPositions)
        MurdererDetectado = nil parsePlayerData(a2) parsePlayerData(a1)
        lastWorldPredNoY = nil lastWorldMinPredNoY = nil
    end))
end

local floorCastParams = RaycastParams.new()
floorCastParams.FilterType = Enum.RaycastFilterType.Exclude

local function autoEquipWeapon()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if character and character:FindFirstChild("Humanoid") and backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if isRangedWeapon(item) then character.Humanoid:EquipTool(item) task.wait(0.01) break end
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
            setTarget(MurdererDetectado) return MurdererDetectado
        else MurdererDetectado = nil end
    end
    for name, role in pairs(playerRoles) do
        if role == "Murderer" then
            local pl = Players:FindFirstChild(name)
            if pl and pl.Character and pl ~= LocalPlayer then
                local hum = pl.Character:FindFirstChildOfClass("Humanoid")
                if not ((hum and hum.Health <= 0) or (playerDeadStatus[name] == true)) then
                    MurdererDetectado = pl setTarget(pl) return pl
                end
            end
        end
    end
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
                    potentialMurderer = player break
                end
            end
        end
    end
    if potentialMurderer then MurdererDetectado = potentialMurderer else setTarget(nil) end
    return currentTarget
end

local mapCastParams = RaycastParams.new()
mapCastParams.FilterType = Enum.RaycastFilterType.Exclude
local ignoreListCache = {} 

local function getSmartTargetPart(targetChar)
    if not targetChar then return nil, true end
    local hrp = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("UpperTorso")
    if not hrp then return nil, true end
    if not SheriffConfig.WallCheck then return hrp, false end
    
    local origin = Camera.CFrame.Position
    table.clear(ignoreListCache)
    table.insert(ignoreListCache, LocalPlayer.Character)
    table.insert(ignoreListCache, Camera)
    
    local allPlayers = Players:GetPlayers()
    for i = 1, #allPlayers do if allPlayers[i].Character then table.insert(ignoreListCache, allPlayers[i].Character) end end
    mapCastParams.FilterDescendantsInstances = ignoreListCache
    
    local partsToScan = {
        hrp,
        targetChar:FindFirstChild("Head"),
        targetChar:FindFirstChild("LeftHand") or targetChar:FindFirstChild("Left Arm"),
        targetChar:FindFirstChild("RightHand") or targetChar:FindFirstChild("Right Arm")
    }
    
    for i = 1, #partsToScan do
        local part = partsToScan[i]
        if part then
            local ray = workspace:Raycast(origin, part.Position - origin, mapCastParams)
            if not ray or (ray.Instance.CanCollide == false or ray.Instance.Transparency >= 0.8) then 
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

local function getPredictedPosition(targetChar, targetPart, customDelta)
    if not targetChar or not targetPart then return nil, nil, nil end
    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not humanoid or humanoid.Health <= 0 or not localHrp then return nil, nil, nil end

    local activeDT = customDelta or emaDeltaTime
    local targetPosition = targetPart.Position
    local distance = (targetPosition - localHrp.Position).Magnitude

    local rawVelocity = hrp.AssemblyLinearVelocity
    if humanoid.FloorMaterial ~= Enum.Material.Air and humanoid.MoveDirection.Magnitude > 0 then
        local walkSpeed = humanoid.WalkSpeed > 0 and humanoid.WalkSpeed or 16
        rawVelocity = vec3New(humanoid.MoveDirection.X * walkSpeed, rawVelocity.Y, humanoid.MoveDirection.Z * walkSpeed)
    else
        if lastPositions[targetChar] then
            local datosPrevios = lastPositions[targetChar]
            local tiempoTranscurrido = os_clock() - datosPrevios.Time
            if tiempoTranscurrido > 0.01 then
                local calculatedVel = (hrp.Position - datosPrevios.Pos) / tiempoTranscurrido
                if calculatedVel.Magnitude > 0.5 and calculatedVel.Magnitude < 100 then
                    rawVelocity = calculatedVel
                end
            end
        end
    end
    lastPositions[targetChar] = {Pos = hrp.Position, Time = os_clock()}

    if not positionHistory[targetChar] then positionHistory[targetChar] = {} end
    local history = positionHistory[targetChar]
    table.insert(history, 1, hrp.Position)
    if #history > MAX_HISTORY_FRAMES then table.remove(history, #history) end

    -- Anti-Juke & Directional Lag Filter
    if SheriffConfig.AntiJukeFilter and #history >= 3 then
        local dir1 = (history[1] - history[2])
        local dir2 = (history[2] - history[3])
        if dir1.Magnitude > 0.05 and dir2.Magnitude > 0.05 then
            local dot = dir1.Unit:Dot(dir2.Unit)
            if dot < 0.4 then
                local smoothedDir = (dir1.Unit + dir2.Unit).Unit
                local hSpeed = Vector2.new(rawVelocity.X, rawVelocity.Z).Magnitude
                rawVelocity = vec3New(smoothedDir.X * hSpeed * 0.6, rawVelocity.Y, smoothedDir.Z * hSpeed * 0.6)
            end
        end
    end

    local hMultiplier = (SheriffConfig.HorizontalScale / 100)
    local vMultiplier = (SheriffConfig.VerticalScale / 100)
    local pComp = (SheriffConfig.PingCompensation / 100)
    
    local totalLatency = (cachedPingValue * pComp) + activeDT + 0.015 
    local predictionWeight = 1
    if distance <= SheriffConfig.CloseRangeZone then predictionWeight = 0 end

    if lastTargetChar ~= targetChar then
        smoothedVelocity = rawVelocity lastTargetChar = targetChar
    end

    local vSmoothAlpha = math_clamp(15 * activeDT, 0, 1)
    smoothedVelocity = smoothedVelocity:Lerp(rawVelocity, vSmoothAlpha)

    local horizontalShift = vec3New(smoothedVelocity.X, 0, smoothedVelocity.Z) * totalLatency * hMultiplier * predictionWeight
    if horizontalShift.Magnitude > 6.5 then horizontalShift = horizontalShift.Unit * 6.5 end

    local finalPredNoY = vec3New(targetPosition.X + horizontalShift.X, targetPosition.Y, targetPosition.Z + horizontalShift.Z)
    local minPredNoY = vec3New(targetPosition.X + (horizontalShift.X * 0.4), targetPosition.Y, targetPosition.Z + (horizontalShift.Z * 0.4))

    local verticalShift = VECTOR_ZERO
    if SheriffConfig.JumpPrediction and (humanoid.FloorMaterial == Enum.Material.Air or math_abs(smoothedVelocity.Y) > 0.1) then
        local adaptiveYFactor = math_clamp((distance - SheriffConfig.CloseRangeZone) / 12, 0, 1)
        local finalVScale = vMultiplier * adaptiveYFactor
        local verticalVelocity = smoothedVelocity.Y
        if verticalVelocity < 0 then verticalVelocity = verticalVelocity * 0.25 end
        
        local pY = (verticalVelocity * totalLatency * finalVScale) - (0.15 * workspace_Gravity * math_pow(totalLatency, 2))
        verticalShift = vec3New(0, pY, 0)
    end
    if verticalShift.Magnitude > 5.0 then verticalShift = verticalShift.Unit * 5.0 end

    local finalPredWithY = targetPosition + horizontalShift + verticalShift
    local floorY = getFloorHeight(hrp, targetChar)
    if floorY then
        local minAllowedY = floorY + (hrp.Size.Y / 2) + 0.1
        if finalPredWithY.Y < minAllowedY then finalPredWithY = vec3New(finalPredWithY.X, minAllowedY, finalPredWithY.Z) end
    end

    return finalPredWithY, finalPredNoY, minPredNoY
end

-- TRACERS
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
        lastWorldPredNoY = nil lastWorldMinPredNoY = nil
        return
    end

    local targetChar = murderer.Character
    local visualPart, isBlocked = getSmartTargetPart(targetChar) 
    handLineIsBlocked = isBlocked

    local myChar = LocalPlayer.Character
    local rightHand = myChar and (myChar:FindFirstChild("RightHand") or myChar:FindFirstChild("Right Arm"))

    if visualPart then
        local _, predNoY, minPredNoY = getPredictedPosition(targetChar, visualPart, dt)
        local currentViewportSize = Camera.ViewportSize
        local screenOrigin = vec2New(currentViewportSize.X / 2, currentViewportSize.Y)

        if predNoY and minPredNoY then
            if not lastWorldPredNoY or lastTargetChar ~= targetChar then
                lastWorldPredNoY = predNoY
                lastWorldMinPredNoY = minPredNoY
            else
                lastWorldPredNoY = lastWorldPredNoY:Lerp(predNoY, 0.9)
                lastWorldMinPredNoY = lastWorldMinPredNoY:Lerp(minPredNoY, 0.9)
            end

            -- Minimum Tracer Prediction
            if SheriffConfig.ShowBlueTracer then
                local screenPos, onScreen = worldToViewport(Camera, lastWorldMinPredNoY)
                if onScreen then
                    MinPredictionLine.From = screenOrigin 
                    MinPredictionLine.To = vec2New(screenPos.X, screenPos.Y) 
                    MinPredictionLine.Visible = true
                else MinPredictionLine.Visible = false end
            else MinPredictionLine.Visible = false end

            -- Horizontal Tracer Prediction
            if SheriffConfig.ShowRedTracer then
                local screenPos, onScreen = worldToViewport(Camera, lastWorldPredNoY)
                if onScreen then
                    PredictionLine.From = screenOrigin 
                    PredictionLine.To = vec2New(screenPos.X, screenPos.Y) 
                    PredictionLine.Visible = true
                else PredictionLine.Visible = false end
            else PredictionLine.Visible = false end

            -- Lead Time Tracer Prediction
            if rightHand and SheriffConfig.ShowGreenTracer then
                local handScreenPos, handOnScreen = worldToViewport(Camera, rightHand.Position)
                local predScreenPos, predOnScreen = worldToViewport(Camera, lastWorldPredNoY)

                if handOnScreen and predOnScreen then
                    LeadTimeLine.Color = handLineIsBlocked and color3RGB(255, 255, 255) or color3RGB(35, 255, 35)
                    LeadTimeLine.From = vec2New(handScreenPos.X, handScreenPos.Y)
                    LeadTimeLine.To = vec2New(predScreenPos.X, predScreenPos.Y)
                    LeadTimeLine.Visible = true
                else LeadTimeLine.Visible = false end
            else LeadTimeLine.Visible = false end
        end
    else
        PredictionLine.Visible = false; MinPredictionLine.Visible = false; LeadTimeLine.Visible = false;
        lastWorldPredNoY = nil lastWorldMinPredNoY = nil
    end 
end)
table.insert(_G.KillerHubConnections, renderConn)

local function fireAtMurdererDirectly()
    if isFiringCooldown then return end 
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end 

    local murderer = getMurderer()
    if murderer and murderer.Character then
        local targetChar = murderer.Character
        local bestPart, isBlocked = getSmartTargetPart(targetChar) 
        if bestPart and (not SheriffConfig.WallCheck or not isBlocked) then 
            local finalPredictedPos = getPredictedPosition(targetChar, bestPart)
            if finalPredictedPos then
                isFiringCooldown = true autoEquipWeapon()
                local gun, _ = getGunLocation()
                if gun and gun:FindFirstChild("Shoot") then
                    local originCFrame = char.HumanoidRootPart.CFrame
                    if char.HumanoidRootPart:FindFirstChild("GunRaycastAttachment") then originCFrame = char.HumanoidRootPart.GunRaycastAttachment.WorldCFrame end
                    gun.Shoot:FireServer(originCFrame, cframeNew(finalPredictedPos))
                end
                task.wait(0.04) isFiringCooldown = false
            end
        end
     end
end

-- LISTEN PC KEYBIND FOR DIRECT SHOOT
table.insert(_G.KillerHubConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local boundKey = SheriffConfig.ShootKey or Enum.KeyCode.E
        if input.KeyCode == boundKey then
            fireAtMurdererDirectly()
        end
    end
end))

-- SHOOT BUTTON UI
local VoidGui = Instance.new("ScreenGui")
VoidGui.Name = "KillerHub_SheriffGui"
VoidGui.ResetOnSpawn = false VoidGui.Parent = game:GetService("CoreGui")

local ShootButton = Instance.new("ImageButton")
ShootButton.Name = "ShootButton"
ShootButton.Size = udim2New(0, SheriffConfig.ButtonSize, 0, SheriffConfig.ButtonSize)
ShootButton.Position = udim2New(SheriffConfig.ButtonX, 0, SheriffConfig.ButtonY, 0)
ShootButton.BackgroundColor3 = color3RGB(15, 6, 26)
ShootButton.BackgroundTransparency = 1 - SheriffConfig.ButtonOpacity
ShootButton.BorderSizePixel = 0; ShootButton.AutoButtonColor = false; ShootButton.ClipsDescendants = true; ShootButton.Parent = VoidGui

cachedScreenGui = VoidGui cachedShootButton = ShootButton

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0.28, 0) Corner.Parent = ShootButton

local GlowOverlay = Instance.new("Frame")
GlowOverlay.Size = udim2New(1, 0, 1, 0) GlowOverlay.BackgroundTransparency = 1; GlowOverlay.ZIndex = ShootButton.ZIndex + 1; GlowOverlay.Parent = ShootButton

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(0.28, 0) GlowCorner.Parent = GlowOverlay

local UiGradient = Instance.new("UIGradient")
UiGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color3RGB(24, 8, 43)), ColorSequenceKeypoint.new(0.5, color3RGB(131, 46, 222)), ColorSequenceKeypoint.new(1, color3RGB(24, 8, 43))})
UiGradient.Rotation = 45 UiGradient.Parent = GlowOverlay

local DecalTexture = Instance.new("ImageLabel")
DecalTexture.Size = udim2New(0.37, 0, 0.37, 0) DecalTexture.AnchorPoint = vec2New(0.5, 0.5) DecalTexture.Position = udim2New(0.5, 0, 0.44, 0)
DecalTexture.BackgroundTransparency = 1; DecalTexture.Image = "rbxassetid://125754446555599"
DecalTexture.ImageTransparency =  1 - SheriffConfig.ButtonOpacity; DecalTexture.ZIndex = ShootButton.ZIndex + 2; DecalTexture.Parent = ShootButton

task.spawn(function()
    local ti = TweenInfo.new(0.80, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local t1 = TweenService:Create(DecalTexture, ti, {Rotation = 360})
    local t2 = TweenService:Create(DecalTexture, ti, {Rotation = 0})
    table.insert(_G.KillerHubConnections, t1.Completed:Connect(function() task.wait(0.032) t2:Play() end))
    table.insert(_G.KillerHubConnections, t2.Completed:Connect(function() task.wait(0.032) t1:Play() end))
    t1:Play()
end)

local Label = Instance.new("TextLabel")
Label.Size = udim2New(1, 0, 0.2, 0) Label.Position = udim2New(0, 0, 0.75, 0) Label.BackgroundTransparency = 1
Label.Text = "SHOOT" Label.TextColor3 = color3RGB(255, 255, 255) Label.TextSize = 15 Label.Font = Enum.Font.GothamBold
Label.TextTransparency = 1 - SheriffConfig.ButtonOpacity; Label.ZIndex = ShootButton.ZIndex + 2; Label.Parent = ShootButton

local dragging, dragInput, dragStart, startPos
table.insert(_G.KillerHubConnections, ShootButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local bPos = ShootButton.AbsolutePosition local bSize = ShootButton.AbsoluteSize
        UiGradient.Offset = vec2New(((input.Position.X - bPos.X) / bSize.X - 0.5) * 1.5, 0)
        TweenService:Create(GlowOverlay, TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.55}):Play()
        task.spawn(fireAtMurdererDirectly)
        
        dragging = true dragStart = input.Position startPos = ShootButton.Position
        local cChanged
        cChanged = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false 
                SheriffConfig.ButtonX = ShootButton.Position.X.Scale
                SheriffConfig.ButtonY = ShootButton.Position.Y.Scale
                saveConfig() 
                cChanged:Disconnect()
            end
        end)
     end
end))

table.insert(_G.KillerHubConnections, ShootButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        TweenService:Create(GlowOverlay, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    end
end))

table.insert(_G.KillerHubConnections, ShootButton.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end))
table.insert(_G.KillerHubConnections, UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ShootButton.Position = udim2New(startPos.X.Scale + (delta.X / Camera.ViewportSize.X), 0, startPos.Y.Scale + (delta.Y / Camera.ViewportSize.Y), 0)
    end
end))

-- HOOKS DE WEAPON SERVICE (FIX PARA SILENT AIM EN TAP DE PANTALLA)
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

    local function checkAndPredict(returnCFrame)
        if not SheriffConfig.SilentAim then return nil end

        local gun, _ = getGunLocation()
        if SheriffConfig.UseWeaponDetector and not gun then return nil end

        local murderer = getMurderer()
        if not murderer or not murderer.Character then return nil end

        local bestPart, isBlocked = getSmartTargetPart(murderer.Character)
        if not bestPart then return nil end
        if SheriffConfig.WallCheck and isBlocked then return nil end

        local currentTime = os_clock()
        local structuralDelta = math_clamp(currentTime - lastHookCallTime, 0.008, 0.033)
        lastHookCallTime = currentTime

        local finalPredictedPos = getPredictedPosition(murderer.Character, bestPart, structuralDelta)
        if finalPredictedPos then
            return returnCFrame and cframeNew(finalPredictedPos) or finalPredictedPos
        end
        return nil
    end

    if oldGetTargetPosition then
        WeaponService.GetTargetPosition = function(self, ...)
            local override = checkAndPredict(false)
            if override then return override end
            return oldGetTargetPosition(self, ...)
        end
    end

    if oldGetMouseTargetCFrame then
        WeaponService.GetMouseTargetCFrame = function(self, ...)
            local override = checkAndPredict(true)
            if override then return override end
            return oldGetMouseTargetCFrame(self, ...)
        end
    end
end

return KillerHub
