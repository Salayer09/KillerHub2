-- ============================================================================
-- 👻 KILLER HUB | SHERIFF V6.8.5 [INSTANT HITSCAN & FIXED TRACERS UPDATE]
-- ============================================================================
if _G.KillerHubLines then
    for _, line in pairs(_G.KillerHubLines) do
        pcall(function() line:Remove() end)
    end
end
_G.KillerHubLines = {}

local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Salayer09/KillerHub/refs/heads/main/Slayer.lua"))()

-- 1. PESTAÑA SHERIFF
local SheriffTab = KillerHub:CreateTab("Sheriff", "rbxassetid://10747373142")

-- 2. CONFIGURACIÓN GLOBAL AUTOMÁTICA
local SheriffConfig = {
    SilentAim = false,
    PredictionMode = "HYPER-CORE V6.8.5", 
    HorizontalPred = 0.135,
    VerticalPred = 0.045,   
    WallCheck = true,      
    
    PredictTracer = false,
    ShowPingTracer = false,   
    ShowLagTracer = false,    
    ShowLeadTracer = true,    
    UseWeaponDetector = false,
    AutoUnequip = false,       
    ShowShootButton = false,
    ButtonSize = 95,
    ButtonOpacity = 0.95,
    ButtonLocked = false,
    ButtonX = 0.7,
    ButtonY = 0.6,
    
    LeadTimePred = 0.05
}

local HttpService = game:GetService("HttpService")
local CONFIG_FILE = "KillerHub_SheriffSuite.txt"

local function saveConfig()
    if writefile then
        local data = {
            ButtonX = SheriffConfig.ButtonX,
            ButtonY = SheriffConfig.ButtonY,
            PredictionMode = SheriffConfig.PredictionMode,
            LeadTimePred = SheriffConfig.LeadTimePred,
            UseWeaponDetector = SheriffConfig.UseWeaponDetector,
            AutoUnequip = SheriffConfig.AutoUnequip,
            ShowLeadTracer = SheriffConfig.ShowLeadTracer,
            ShowPingTracer = SheriffConfig.ShowPingTracer,
            ShowLagTracer = SheriffConfig.ShowLagTracer
        }
        writefile(CONFIG_FILE, HttpService:JSONEncode(data))
    end
end

local function loadConfig()
    if readfile and isfile and isfile(CONFIG_FILE) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG_FILE))
        end)
        if success and type(data) == "table" then
            SheriffConfig.ButtonX = data.ButtonX or SheriffConfig.ButtonX
            SheriffConfig.ButtonY = data.ButtonY or SheriffConfig.ButtonY
            SheriffConfig.PredictionMode = "HYPER-CORE V6.8.5"
            SheriffConfig.LeadTimePred = data.LeadTimePred or SheriffConfig.LeadTimePred
            if data.UseWeaponDetector ~= nil then SheriffConfig.UseWeaponDetector = data.UseWeaponDetector end
            if data.AutoUnequip ~= nil then SheriffConfig.AutoUnequip = data.AutoUnequip end
            if data.ShowLeadTracer ~= nil then SheriffConfig.ShowLeadTracer = data.ShowLeadTracer end
            if data.ShowPingTracer ~= nil then SheriffConfig.ShowPingTracer = data.ShowPingTracer end
            if data.ShowLagTracer ~= nil then SheriffConfig.ShowLagTracer = data.ShowLagTracer end
        end
    end
end
loadConfig()

-- ============================================================================
-- ⚙️ INTERFAZ GRÁFICA CONTROLADA
-- ============================================================================
SheriffTab:CreateSection("Ajustes del Silent Aim")

SheriffTab:CreateToggle("SheriffSilent", "Activar Silent Aim Pasivo", function(estado)
    SheriffConfig.SilentAim = estado
end)

SheriffTab:CreateToggle("SheriffWallCheckToggle", "Verificar Paredes Físicas (Hitbox)", function(estado)
    SheriffConfig.WallCheck = estado
end)

SheriffTab:CreateSection("Motor Activo: HYPER-CORE Hitscan")

SheriffTab:CreateSlider("HorizontalPredSlider", "Predicción Horizontal", 0, 300, function(valor)
    SheriffConfig.HorizontalPred = valor / 1000
end)

SheriffTab:CreateSlider("VerticalPredSlider", "Predicción Vertical (Suave)", 0, 120, function(valor)
    SheriffConfig.VerticalPred = valor / 1000
end)

SheriffTab:CreateSection("Líneas de Trayectoria (Tracers - Siempre Visibles)")

SheriffTab:CreateToggle("TracerPredToggle", "Mostrar Tracer de Impacto (Rojo)", function(estado)
    SheriffConfig.PredictTracer = estado
end)

SheriffTab:CreateToggle("PingTracerToggle", "Mostrar Ping Prediction (Azul Fuerte)", function(estado)
    SheriffConfig.ShowPingTracer = estado
    saveConfig()
end)

SheriffTab:CreateToggle("LagTracerToggle", "Mostrar Lag Prediction (Violeta Elegante)", function(estado)
    SheriffConfig.ShowLagTracer = estado
    saveConfig()
end)

SheriffTab:CreateToggle("LeadTracerToggle", "Activar Lead Tracer (Mano Verde Neón)", function(estado)
    SheriffConfig.ShowLeadTracer = estado
    saveConfig()
end)

SheriffTab:CreateSlider("LeadTimeSlider", "Ver anticipación (Mano)", 0, 100, function(valor)
    SheriffConfig.LeadTimePred = valor / 100
    saveConfig()
end)

SheriffTab:CreateSection("Condiciones de Interfaz / Tácticas")
SheriffTab:CreateToggle("WeaponDetectToggle", "Ocultar Botón si no tengo Arma en Inventario", function(estado)
    SheriffConfig.UseWeaponDetector = estado
    saveConfig()
end)

SheriffTab:CreateToggle("AutoUnequipToggle", "Auto-Desequipar Arma (Fast Unequip)", function(estado)
    SheriffConfig.AutoUnequip = estado
    saveConfig()
end)

SheriffTab:CreateToggle("ShowVoidButton", "Mostrar Botón en Pantalla", function(estado)
    SheriffConfig.ShowShootButton = estado
end)

SheriffTab:CreateSlider("VoidBtnSize", "Tamaño del Botón Void", 50, 200, function(valor)
    SheriffConfig.ButtonSize = valor
    local btn = game:GetService("CoreGui"):FindFirstChild("KillerHub_VoidGui") and game:GetService("CoreGui").KillerHub_VoidGui:FindFirstChild("ShootButton")
    if btn then
        btn.Size = UDim2.new(0, valor, 0, valor)
        if btn:FindFirstChild("UICorner") then btn.UICorner.CornerRadius = UDim.new(0, math.floor(valor * 0.24)) end
        if btn:FindFirstChild("GlowOverlay") and btn.GlowOverlay:FindFirstChild("UICorner") then
            btn.GlowOverlay.UICorner.CornerRadius = UDim.new(0, math.floor(valor * 0.24))
        end
    end
end)

SheriffTab:CreateSlider("VoidBtnOpacity", "Opacidad del Botón", 10, 100, function(valor)
    SheriffConfig.ButtonOpacity = valor / 100
    local btn = game:GetService("CoreGui"):FindFirstChild("KillerHub_VoidGui") and game:GetService("CoreGui").KillerHub_VoidGui:FindFirstChild("ShootButton")
    if btn then
        btn.BackgroundTransparency = 1 - SheriffConfig.ButtonOpacity
        if btn:FindFirstChild("DecalTexture") then btn.DecalTexture.ImageTransparency = 1 - SheriffConfig.ButtonOpacity end
        if btn:FindFirstChild("Label") then btn.Label.TextTransparency = 1 - SheriffConfig.ButtonOpacity end
    end
end)

SheriffTab:CreateToggle("LockVoidBtn", "Bloquear Posición del Botón", function(estado)
    SheriffConfig.ButtonLocked = estado
end)

-- ============================================================================
-- 🧠 MOTOR CINEMÁTICO V6.8.5 HYPER-CORE HITSCAN (DYNAMICS ENGINE)
-- ============================================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService") 
local Stats = game:GetService("Stats") 
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

local lastVelocity = Vector3.new(0,0,0)
local previousTargetVelocity = Vector3.new(0,0,0) 
local smoothedVelocity = Vector3.new(0,0,0)
local lastTargetChar = nil
local lastDeltaTime = 0.016

local positionHistory = {} 
local zigZagIntensity = 0 
local lastDirectionChangeTime = 0

local smoothedPing = 0.06
task.spawn(function()
    while task.wait(0.3) do
        if Stats and Stats:FindFirstChild("Network") and Stats.Network:FindFirstChild("ServerToClientPing") then
            local rawPing = Stats.Network.ServerToClientPing:GetValue() / 1000
            smoothedPing = smoothedPing + (rawPing - smoothedPing) * 0.3
        end
    end
end)

local wallcastParams = RaycastParams.new()
wallcastParams.FilterType = Enum.RaycastFilterType.Exclude

local floorCastParams = RaycastParams.new()
floorCastParams.FilterType = Enum.RaycastFilterType.Exclude

local function getGunLocation()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Gun") then
        return char:FindFirstChild("Gun"), char
    elseif LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Gun") then
        return LocalPlayer.Backpack.Gun, LocalPlayer.Backpack
    end
    return nil, nil
end

local function getMurderer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Parent ~= nil then
            local char = player.Character
            if (char and char:FindFirstChild("Knife")) or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife")) then
                return player
            end
        end
    end
    return nil
end

local function isPartVisible(targetPart, murdererChar)
    if not SheriffConfig.WallCheck then return true end
    if not targetPart or not murdererChar or not LocalPlayer.Character then return false end
    
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local originCFrame = hrp:FindFirstChild("GunRaycastAttachment") and hrp.GunRaycastAttachment.WorldCFrame or hrp.CFrame
    local originPos = originCFrame.Position
    local targetPos = targetPart.Position
    
    local ignoreList = {char, murdererChar, Camera}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p ~= murdererChar then table.insert(ignoreList, p.Character) end
    end
    wallcastParams.FilterDescendantsInstances = ignoreList
    
    local clipCheck = workspace:Raycast(hrp.Position, originPos - hrp.Position, wallcastParams)
    if clipCheck then return false end
    
    local pathCheck = workspace:Raycast(originPos, targetPos - originPos, wallcastParams)
    if pathCheck then return false end
    return true
end

local function getBestVisibleTarget(murdererChar)
    if not murdererChar then return nil, nil end
    
    local priorityParts = {"HumanoidRootPart", "Head", "UpperTorso", "Torso", "LowerTorso"}
    for _, partName in ipairs(priorityParts) do
        local part = murdererChar:FindFirstChild(partName)
        if part and isPartVisible(part, murdererChar) then
            return part, part.Position
        end
    end
    
    local defaultPart = murdererChar:FindFirstChild("HumanoidRootPart") or murdererChar:FindFirstChild("Head")
    return defaultPart, defaultPart and defaultPart.Position
end

local function getAnyTargetFallback(murdererChar)
    if not murdererChar then return nil, nil end
    local part = murdererChar:FindFirstChild("HumanoidRootPart") or murdererChar:FindFirstChild("Head") or murdererChar:FindFirstChild("Torso")
    return part, part and part.Position
end

local function getFloorHeight(targetHrp, targetChar)
    floorCastParams.FilterDescendantsInstances = {targetChar, LocalPlayer.Character, Camera}
    local ray = workspace:Raycast(targetHrp.Position, Vector3.new(0, -25, 0), floorCastParams)
    return ray and ray.Position.Y or nil
end

local function getPredictedPosition(targetChar, forceAbsoluteVisibility)
    if not targetChar then return nil end
    
    local bestPart, bestPartPosition
    if forceAbsoluteVisibility then
        bestPart, bestPartPosition = getAnyTargetFallback(targetChar)
    else
        bestPart, bestPartPosition = getBestVisibleTarget(targetChar)
    end
    
    if not bestPart or not bestPartPosition then return nil end
    
    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not localHrp then return nil end

    local now = os.clock()
    local clampedDT = math.min(lastDeltaTime, 0.05) 
    local isLowFPS = lastDeltaTime > 0.033 

    if lastTargetChar ~= targetChar then
        smoothedVelocity = bestPart.AssemblyLinearVelocity
        lastTargetChar = targetChar
        positionHistory = {}
        zigZagIntensity = 0
        lastDirectionChangeTime = now
    end

    local targetPosition = bestPartPosition
    local heightScale = humanoid:FindFirstChild("BodyHeightScale") and math.clamp(humanoid.BodyHeightScale.Value, 0.2, 1.5) or 1
  
    if bestPart.Name == "HumanoidRootPart" and heightScale < 0.85 then
        targetPosition = targetPosition - Vector3.new(0, (1 - heightScale) * 1.2, 0)
    end

    local rawVelocity = bestPart.AssemblyLinearVelocity
    if rawVelocity.Magnitude > 50 then rawVelocity = rawVelocity.Unit * 16 end

    local fpsWeight = isLowFPS and 0.4 or math.clamp(1 - math.exp(-18 * clampedDT), 0.02, 0.8)
    smoothedVelocity = smoothedVelocity:Lerp(rawVelocity, fpsWeight)
    
    local activeVerticalVelocity = smoothedVelocity.Y
    if humanoid.FloorMaterial == Enum.Material.Air then
        activeVerticalVelocity = rawVelocity.Y
    end

    table.insert(positionHistory, 1, targetPosition)
    if #positionHistory > 10 then table.remove(positionHistory) end

    if lastVelocity.Magnitude > 0.5 and rawVelocity.Magnitude > 0.5 then
        local currentDir = Vector3.new(rawVelocity.X, 0, rawVelocity.Z).Unit
        local prevDir = Vector3.new(lastVelocity.X, 0, lastVelocity.Z).Unit
        local dotProduct = currentDir:Dot(prevDir)
        
        if dotProduct < 0.25 then  
            zigZagIntensity = math.min(zigZagIntensity + 2.0, 7)
            lastDirectionChangeTime = now
        end
    end
    if now - lastDirectionChangeTime > 0.35 then
        zigZagIntensity = math.max(zigZagIntensity - (clampedDT * 4.0), 0)
    end

    local currentSpeed = smoothedVelocity.Magnitude
    local speedFactor = math.clamp(currentSpeed / 16, 0, 1.2)

    local fpsBuffer = isLowFPS and 0.045 or 0.033
    local ping = math.clamp(smoothedPing, 0.01, 0.4) + fpsBuffer
    
    local distance = (targetPosition - localHrp.Position).Magnitude
    
    -- 🌟 AJUSTE QUIRÚRGICO DE DISTANCIA (Optimizada para balas instantáneas Hitscan)
    local distanceFactor = 1.0
    
    if distance <= 12 then
        -- CORTA DISTANCIA: Amortiguación baja para clavar el tiro en giros cerrados
        distanceFactor = math.clamp(distance / 25, 0.15, 0.6)
    elseif distance > 12 and distance <= 40 then
        -- MEDIA DISTANCIA: Escala ideal estable 1:1
        distanceFactor = 1.0
    else
        -- LARGA DISTANCIA: Balas instantáneas. Evitamos Overprediction por completo. 
        -- Solo se aplica un microajuste fijo para balancear la actualización de red de Roblox.
        distanceFactor = 1.03
    end

    local zigZagDampening = math.clamp(1 - (zigZagIntensity / 7.0), 0.15, 1.0)
    local timeFrame = (SheriffConfig.HorizontalPred * speedFactor * zigZagDampening) + ping

    local rawAcceleration = (smoothedVelocity - previousTargetVelocity) / math.max(clampedDT, 0.001)
    if rawAcceleration.Magnitude > 55 then rawAcceleration = rawAcceleration.Unit * 55 end 
    local stableAcceleration = Vector3.new(rawAcceleration.X, 0, rawAcceleration.Z)

    local horizontalPrediction = (Vector3.new(smoothedVelocity.X, 0, smoothedVelocity.Z) * timeFrame) + (0.5 * stableAcceleration * (timeFrame ^ 2))
    local basePrediction = targetPosition + (horizontalPrediction * distanceFactor)

    local serverGravity = workspace.Gravity
    local verticalOffset = Vector3.new(0, 0, 0)
    
    if humanoid.FloorMaterial == Enum.Material.Air then
        local airTime = timeFrame * (distance <= 12 and 0.2 or distanceFactor)
        local gravityInertia = 0.5 * serverGravity * (airTime ^ 2)
        
        if activeVerticalVelocity > 0 then
            gravityInertia = gravityInertia * 0.12
        end
        verticalOffset = Vector3.new(0, (activeVerticalVelocity * airTime) - gravityInertia, 0)
    else
        verticalOffset = Vector3.new(0, activeVerticalVelocity * timeFrame * SheriffConfig.VerticalPred * speedFactor, 0)
    end

    local finalPrediction = basePrediction + verticalOffset

    if #positionHistory > 0 and zigZagIntensity > 0.5 then
        local centroid = Vector3.new(0, 0, 0)
        for _, pos in ipairs(positionHistory) do centroid = centroid + pos end
        centroid = centroid / #positionHistory
        
        local blendWeight = math.clamp(zigZagIntensity / 4.0, 0.1, 0.90)
        finalPrediction = finalPrediction:Lerp(centroid + verticalOffset, blendWeight)
    end

    if smoothedVelocity.Y < -0.1 then
        local floorY = getFloorHeight(bestPart, targetChar)
        if floorY then
            local minAllowedY = floorY + ((bestPart.Size.Y / 2) * heightScale) + 0.2
            if finalPrediction.Y < minAllowedY then
                finalPrediction = Vector3.new(finalPrediction.X, minAllowedY, finalPrediction.Z)
            end
        end
    end

    if not forceAbsoluteVisibility then
        wallcastParams.FilterDescendantsInstances = {targetChar, LocalPlayer.Character, Camera}
        local wallSnapCheck = workspace:Raycast(targetPosition, finalPrediction - targetPosition, wallcastParams)
        if wallSnapCheck and wallSnapCheck.Instance.CanCollide then
            finalPrediction = wallSnapCheck.Position - (finalPrediction - targetPosition).Unit * 0.35
        end
    end

    previousTargetVelocity = smoothedVelocity
    lastVelocity = rawVelocity
    return finalPrediction
end

-- ============================================================================
-- 🟩 🟣 🟦 🟥 MOTOR DE TRACERS COMPLETO (SIEMPRE VISIBLES DESDE CORE)
-- ============================================================================
local PingLine = Drawing.new("Line")
PingLine.Color = Color3.fromRGB(0, 45, 167) 
PingLine.Thickness = 1.0
PingLine.Visible = false
PingLine.ZIndex = 1
table.insert(_G.KillerHubLines, PingLine)

local LagLine = Drawing.new("Line")
LagLine.Color = Color3.fromRGB(114, 39, 214) 
LagLine.Thickness = 1.0
LagLine.Visible = false
LagLine.ZIndex = 2
table.insert(_G.KillerHubLines, LagLine)

local LeadLine = Drawing.new("Line")
LeadLine.Color = Color3.fromRGB(103, 255, 89) 
LeadLine.Thickness = 1.0
LeadLine.Visible = false
LeadLine.ZIndex = 3
table.insert(_G.KillerHubLines, LeadLine)

local PredictionLine = Drawing.new("Line")
PredictionLine.Color = Color3.fromRGB(255, 35, 35)
PredictionLine.Thickness = 1.2 
PredictionLine.Visible = false
PredictionLine.ZIndex = 4
table.insert(_G.KillerHubLines, PredictionLine)

local vec2New, vec3New = Vector2.new, Vector3.new
local worldToViewport = Camera.WorldToViewportPoint

RunService.RenderStepped:Connect(function(dt)
    lastDeltaTime = dt
    local gun, _ = getGunLocation()
    local hasGun = not SheriffConfig.UseWeaponDetector or (gun ~= nil)
    local murderer = getMurderer()
    local screenGui = game:GetService("CoreGui"):FindFirstChild("KillerHub_VoidGui")
    if screenGui then screenGui.Enabled = SheriffConfig.ShowShootButton and hasGun end

    if not hasGun or not murderer or not murderer.Character then
        PredictionLine.Visible = false; PingLine.Visible = false; LagLine.Visible = false; LeadLine.Visible = false
        return
    end

    -- 🌟 VISIBILIDAD INFINITA: Fallback directo que salta el filtro de obstrucción de paredes
    local bestPart, _ = getAnyTargetFallback(murderer.Character)
    local localChar = LocalPlayer.Character
    local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")

    if bestPart and localHrp then
        local distance = (bestPart.Position - localHrp.Position).Magnitude
        local distFactor = math.clamp((distance - 4) / 16, 0, 1)
        local ping = math.clamp(smoothedPing, 0.01, 0.4)
        
        local speedFactor = math.clamp(smoothedVelocity.Magnitude / 16, 0, 1)
        local hFactor = SheriffConfig.HorizontalPred * speedFactor
        local vFactor = SheriffConfig.VerticalPred * speedFactor

        local predictedPos = getPredictedPosition(murderer.Character, true)
        if predictedPos and SheriffConfig.PredictTracer then
            local screenPos, onScreen = worldToViewport(Camera, predictedPos)
            if onScreen then
                PredictionLine.From = vec2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                PredictionLine.To = vec2New(screenPos.X, screenPos.Y)
                PredictionLine.Visible = true
            else PredictionLine.Visible = false end
        else PredictionLine.Visible = false end

        if SheriffConfig.ShowPingTracer then
            local pingPos = bestPart.Position + (smoothedVelocity * ping * distFactor)
            local screenPos, onScreen = worldToViewport(Camera, pingPos)
            if onScreen then
                PingLine.From = vec2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                PingLine.To = vec2New(screenPos.X, screenPos.Y)
                PingLine.Visible = true
            else PingLine.Visible = false end
        else PingLine.Visible = false end

        if SheriffConfig.ShowLagTracer then
            local lagPos = bestPart.Position + (vec3New(smoothedVelocity.X * hFactor, smoothedVelocity.Y * vFactor, smoothedVelocity.Z * hFactor) * distFactor)
            local screenPos, onScreen = worldToViewport(Camera, lagPos)
            if onScreen then
                LagLine.From = vec2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                LagLine.To = vec2New(screenPos.X, screenPos.Y)
                LagLine.Visible = true
            else LagLine.Visible = false end
        else LagLine.Visible = false end

        local hand = localChar and (localChar:FindFirstChild("RightHand") or localChar:FindFirstChild("Right Arm"))
        if SheriffConfig.ShowLeadTracer and hand then
            local balancedVelocity = vec3New(smoothedVelocity.X, smoothedVelocity.Y * 0.5, smoothedVelocity.Z)
            local leadPredictedPos = bestPart.Position + (balancedVelocity * SheriffConfig.LeadTimePred * distFactor)
            
            if smoothedVelocity.Y < -0.5 then
                local floorY = getFloorHeight(bestPart, murderer.Character)
                if floorY and leadPredictedPos.Y < (floorY + 1) then
                    leadPredictedPos = vec3New(leadPredictedPos.X, floorY + 1, leadPredictedPos.Z)
                end
            end

            local handScreenPos, handOnScreen = worldToViewport(Camera, hand.Position)
            local targetScreenPos, targetOnScreen = worldToViewport(Camera, leadPredictedPos)

            if handOnScreen and targetOnScreen then
                LeadLine.From = vec2New(handScreenPos.X, handScreenPos.Y)
                LeadLine.To = vec2New(targetScreenPos.X, targetScreenPos.Y)
                LeadLine.Visible = true
            else LeadLine.Visible = false end
        else LeadLine.Visible = false end
    else
        PredictionLine.Visible = false; PingLine.Visible = false; LagLine.Visible = false; LeadLine.Visible = false
    end
end)

local function fireAtMurdererDirectly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local gun, parent = getGunLocation()
    local murderer = getMurderer()

    if gun and murderer and murderer.Character then
        local bestPart, _ = getBestVisibleTarget(murderer.Character)
        if bestPart then 
            local predictedPos = getPredictedPosition(murderer.Character, false)
            if predictedPos then
                local startedInBackpack = (parent == LocalPlayer.Backpack)
                if startedInBackpack then 
                    humanoid:EquipTool(gun) 
                    RunService.Heartbeat:Wait() 
                end
                if gun:FindFirstChild("Shoot") then
                    local originCFrame = char.HumanoidRootPart.CFrame
                    if char.HumanoidRootPart:FindFirstChild("GunRaycastAttachment") then
                        originCFrame = char.HumanoidRootPart.GunRaycastAttachment.WorldCFrame
                    end
                    gun.Shoot:FireServer(originCFrame, CFrame.new(predictedPos))
                end
                if SheriffConfig.AutoUnequip then 
                    task.wait(0.02) 
                    humanoid:UnequipTools() 
                end
            end
        end
    end
end

-- ============================================================================
-- 🌌 INTERFAZ V3.4 (BOTÓN DIAGONAL FIJO PERFECTO)
-- ============================================================================
local VoidGui = Instance.new("ScreenGui")
VoidGui.Name = "KillerHub_VoidGui"
VoidGui.ResetOnSpawn = false
VoidGui.Parent = game:GetService("CoreGui")

local ShootButton = Instance.new("ImageButton")
ShootButton.Name = "ShootButton"
ShootButton.Size = UDim2.new(0, SheriffConfig.ButtonSize, 0, SheriffConfig.ButtonSize)
ShootButton.Position = UDim2.new(SheriffConfig.ButtonX, 0, SheriffConfig.ButtonY, 0)
ShootButton.BackgroundColor3 = Color3.fromRGB(15, 6, 26)
ShootButton.BackgroundTransparency = 1 - SheriffConfig.ButtonOpacity
ShootButton.BorderSizePixel = 0  
ShootButton.AutoButtonColor = false 
ShootButton.ClipsDescendants = true 
ShootButton.Parent = VoidGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, math.floor(SheriffConfig.ButtonSize * 0.24))
Corner.Parent = ShootButton

local GlowOverlay = Instance.new("Frame")
GlowOverlay.Name = "GlowOverlay"
GlowOverlay.Size = UDim2.new(1, 0, 1, 0)
GlowOverlay.Position = UDim2.new(0, 0, 0, 0)
GlowOverlay.BackgroundTransparency = 1
GlowOverlay.ZIndex = ShootButton.ZIndex + 1
GlowOverlay.Parent = ShootButton

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = Corner.CornerRadius
GlowCorner.Parent = GlowOverlay

local UiGradient = Instance.new("UIGradient")
UiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 8, 43)),       
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(131, 46, 222)),  
    ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 8, 43))
})
UiGradient.Rotation = 45 
UiGradient.Parent = GlowOverlay

local DecalTexture = Instance.new("ImageLabel")
DecalTexture.Name = "DecalTexture"
DecalTexture.Size = UDim2.new(0.39, 0, 0.39, 0)
DecalTexture.AnchorPoint = Vector2.new(0.5, 0.5)
DecalTexture.Position = UDim2.new(0.5, 0, 0.43, 0)
DecalTexture.BackgroundTransparency = 1
DecalTexture.Image = "rbxassetid://125754446555599"
DecalTexture.ImageTransparency = 1 - SheriffConfig.ButtonOpacity
DecalTexture.ZIndex = ShootButton.ZIndex + 2
DecalTexture.Parent = ShootButton

TweenService:Create(DecalTexture, TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Rotation = 360}):Play()

local Label = Instance.new("TextLabel")
Label.Name = "Label"
Label.Size = UDim2.new(1, 0, 0.2, 0)
Label.Position = UDim2.new(0, 0, 0.75, 0)
Label.BackgroundTransparency = 1
Label.Text = "SHOOT"
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.TextSize = 15
Label.Font = Enum.Font.GothamBold
Label.TextTransparency = 1 - SheriffConfig.ButtonOpacity
Label.ZIndex = ShootButton.ZIndex + 2
Label.Parent = ShootButton

local function processGlowAtCoordinates(inputPosition)
    local buttonAbsolutePos = ShootButton.AbsolutePosition
    local buttonSize = ShootButton.AbsoluteSize
    
    local localX = inputPosition.X - buttonAbsolutePos.X
    local relX = (localX / buttonSize.X) - 0.5
    
    UiGradient.Offset = Vector2.new(relX * 1.5, 0)
    TweenService:Create(GlowOverlay, TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.40}):Play()
end

local function fadeGlowReflection()
    TweenService:Create(GlowOverlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
end

local dragging, dragStart, startPos, dragInput = false, nil, nil, nil
local DRAG_THRESHOLD = 8

ShootButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        processGlowAtCoordinates(input.Position)
        task.spawn(fireAtMurdererDirectly)
     
        if not SheriffConfig.ButtonLocked then
            dragStart = input.Position
            startPos = ShootButton.Position
            dragging = false
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if dragging then
                        SheriffConfig.ButtonX = ShootButton.Position.X.Scale
                        SheriffConfig.ButtonY = ShootButton.Position.Y.Scale
                        saveConfig()
                    end
                    dragStart, dragging = nil, false
                end
            end)
        end
    end
end)

ShootButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fadeGlowReflection()
    end
end)

ShootButton.InputChanged:Connect(function(input)
    if not SheriffConfig.ButtonLocked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragStart then
        local delta = input.Position - dragStart
        if not dragging and delta.Magnitude > DRAG_THRESHOLD then dragging = true end
        if dragging then
            ShootButton.Position = UDim2.new(startPos.X.Scale + (delta.X / Camera.ViewportSize.X), 0, startPos.Y.Scale + (delta.Y / Camera.ViewportSize.Y), 0)
        end
    end
end)

-- ============================================================================
-- ⚡ INTERCEPTACIÓN REMOTA (SILENT AIM SEGURO)
-- ============================================================================
local ClientServices = ReplicatedStorage:WaitForChild("ClientServices", 5)
if ClientServices then
    local WeaponService = require(ClientServices:WaitForChild("WeaponService"))
    local oldGetTargetPosition = WeaponService.GetTargetPosition
    local oldGetMouseTargetCFrame = WeaponService.GetMouseTargetCFrame

    local function checkAndPredict()
        local gun, _ = getGunLocation()
        if SheriffConfig.SilentAim and (not SheriffConfig.UseWeaponDetector or (gun ~= nil)) then
            local murderer = getMurderer()
            if murderer and murderer.Character then
                local bestPart, _ = getBestVisibleTarget(murderer.Character)
                if bestPart then
                    local predictedPos = getPredictedPosition(murderer.Character, false)
                    if predictedPos then return CFrame.new(predictedPos) end
                end
            end
        end
        return nil
    end

    WeaponService.GetTargetPosition = function(self, ...)
        local prediction = checkAndPredict()
        return prediction or oldGetTargetPosition(self, ...)
    end

    WeaponService.GetMouseTargetCFrame = function(self, ...)
        local prediction = checkAndPredict()
        return prediction or oldGetMouseTargetCFrame(self, ...)
    end
end

return KillerHub
