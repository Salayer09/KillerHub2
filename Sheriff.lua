-- ============================================================================
-- 👻 KILLER HUB | SHERIFF V4.9.0 [CQC proximity & ADVANCED GLOW UPDATE]
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
    PredictionMode = "Predictivo Adaptativo",
    HorizontalPred = 0.130, 
    VerticalPred = 0.035,    
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
            SheriffConfig.PredictionMode = data.PredictionMode or SheriffConfig.PredictionMode
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

SheriffTab:CreateToggle("SheriffWallCheckToggle", "Verificar Paredes (Wall Check)", function(estado)
    SheriffConfig.WallCheck = estado
end)

SheriffTab:CreateDropdown("PredMode", "Modo de Predicción:", {"Predictivo Adaptativo", "Predictiva 2.0 (Aceleración)", "Lineal Estable"}, function(seleccionado)
    SheriffConfig.PredictionMode = seleccionado
    saveConfig()
end)

SheriffTab:CreateSlider("HorizontalPredSlider", "Pred. Horizontal (130 = 1.3x de tu Ping)", 0, 300, function(valor)
    SheriffConfig.HorizontalPred = valor / 1000 
end)

SheriffTab:CreateSlider("VerticalPredSlider", "Pred. Vertical (35 = Multiplicador Vertical)", 0, 120, function(valor)
    SheriffConfig.VerticalPred = valor / 1000
end)

SheriffTab:CreateSection("Líneas de Trayectoria (Tracers)")

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
    end
end)

SheriffTab:CreateSlider("VoidBtnOpacity", "Opacidad del Botón", 10, 100, function(valor)
    SheriffConfig.ButtonOpacity = valor / 100
    local btn = game:GetService("CoreGui"):FindFirstChild("KillerHub_VoidGui") and game:GetService("CoreGui").KillerHub_VoidGui:FindFirstChild("ShootButton")
    if btn then
        btn.BackgroundTransparency = 1 - SheriffConfig.ButtonOpacity
    end
end)

SheriffTab:CreateToggle("LockVoidBtn", "Bloquear Posición del Botón", function(estado)
    SheriffConfig.ButtonLocked = estado
end)

-- ============================================================================
-- 🧠 VARIABLES DE ENTORNO FÍSICO
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
local lastTargetPosition = Vector3.new(0,0,0)
local lastTargetChar = nil
local stuckCounter = 0
local lastDeltaTime = 0.016

local cachedPingValue = 0.06
task.spawn(function()
    while task.wait(0.4) do
        if Stats and Stats:FindFirstChild("Network") and Stats.Network:FindFirstChild("ServerToClientPing") then
            cachedPingValue = Stats.Network.ServerToClientPing:GetValue() / 1000
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

local function isTargetVisible(murdererChar)
    if not SheriffConfig.WallCheck then return true end
    local localChar = LocalPlayer.Character
    if not murdererChar or not localChar or not localChar:FindFirstChild("HumanoidRootPart") then 
        return false 
    end
    
    local hrp = murdererChar:FindFirstChild("HumanoidRootPart")
    local head = murdererChar:FindFirstChild("Head")
    if not hrp then return false end
    
    local origin = localChar.HumanoidRootPart.Position
    local ignoreList = {localChar, murdererChar, Camera}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then table.insert(ignoreList, p.Character) end
    end
    
    wallcastParams.FilterDescendantsInstances = ignoreList
    
    local rayHrp = workspace:Raycast(origin, hrp.Position - origin, wallcastParams)
    local hrpVisible = true
    if rayHrp and rayHrp.Instance.Transparency <= 0.7 then
        hrpVisible = false 
    end
    if hrpVisible then return true end
    
    if head then
        local rayHead = workspace:Raycast(origin, head.Position - origin, wallcastParams)
        if not rayHead or rayHead.Instance.Transparency > 0.7 then
            return true 
        end
    end
    
    return false
end

local function getFloorHeight(targetHrp, targetChar)
    floorCastParams.FilterDescendantsInstances = {targetChar, LocalPlayer.Character, Camera}
    local ray = workspace:Raycast(targetHrp.Position, Vector3.new(0, -25, 0), floorCastParams)
    return ray and ray.Position.Y or nil
end

-- ============================================================================
-- 🧠 MOTOR CINEMÁTICO V4.9.0 (CON ADAPTACIÓN DE PROXIMIDAD EXTREMA - CQC)
-- ============================================================================
local function getPredictedPosition(targetChar)
    if not targetChar then return nil end
    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not hrp or not humanoid or humanoid.Health <= 0 or not localHrp then return nil end

    if lastTargetChar ~= targetChar then
        smoothedVelocity = hrp.AssemblyLinearVelocity
        lastTargetChar = targetChar
    end

    local targetPosition = hrp.Position
    local heightScale = humanoid:FindFirstChild("BodyHeightScale") and math.clamp(humanoid.BodyHeightScale.Value, 0.2, 1.5) or 1
    
    if heightScale < 0.85 then
        targetPosition = targetPosition - Vector3.new(0, (1 - heightScale) * 1.2, 0)
    end

    local rawVelocity = hrp.AssemblyLinearVelocity
    -- OPTIMIZACIÓN ANTI-LAGSPIKES: Ningún jugador en MM2 pasa de 23 studs/s de forma legítima
    if rawVelocity.Magnitude > 23 then rawVelocity = rawVelocity.Unit * 16 end

    local clampedDT = math.min(lastDeltaTime, 0.05) 
    smoothedVelocity = smoothedVelocity:Lerp(rawVelocity, 0.3)
    
    if stuckCounter > 4 then smoothedVelocity = Vector3.new(0, 0, 0) end
    if smoothedVelocity.Magnitude < 0.05 then return targetPosition end

    local ping = math.clamp(cachedPingValue, 0.005, 0.25)
    
    -- SISTEMA DE PROXIMIDAD: Reduce la predicción de forma dinámica si está muy cerca de ti
    local currentDistance = (hrp.Position - localHrp.Position).Magnitude
    local proximityScale = math.clamp(currentDistance / 14, 0.12, 1.0)

    -- Aplicación del modificador de proximidad inteligente
    local timeFrame = ping * (SheriffConfig.HorizontalPred * 10) * proximityScale
    local verticalTimeFrame = ping * (SheriffConfig.VerticalPred * 10) * proximityScale

    local finalPrediction = targetPosition
    local serverGravity = workspace.Gravity

    -- CONTROL VERTICAL DINÁMICO
    local verticalOffset = Vector3.new(0, 0, 0)
    if humanoid.FloorMaterial == Enum.Material.Air then
        verticalOffset = Vector3.new(0, (smoothedVelocity.Y * verticalTimeFrame) - (0.5 * serverGravity * (verticalTimeFrame ^ 2)), 0)
    else
        if math.abs(smoothedVelocity.Y) > 0.5 then
            verticalOffset = Vector3.new(0, smoothedVelocity.Y * verticalTimeFrame * 0.3, 0)
        else
            verticalOffset = Vector3.new(0, 0, 0)
        end
    end

    -- MODOS DE PREDICCIÓN CORREGIDOS
    if SheriffConfig.PredictionMode == "Predictiva 2.0 (Aceleración)" then
        local rawAcceleration = (smoothedVelocity - previousTargetVelocity) / math.max(clampedDT, 0.001)
        if rawAcceleration.Magnitude > 100 then rawAcceleration = rawAcceleration.Unit * 10 end
        local stableAcceleration = Vector3.new(rawAcceleration.X, rawAcceleration.Y * 0.05, rawAcceleration.Z)
        
        local horizontalPrediction = (smoothedVelocity * timeFrame) + (0.5 * stableAcceleration * (timeFrame ^ 2))
        finalPrediction = targetPosition + Vector3.new(horizontalPrediction.X, 0, horizontalPrediction.Z) + verticalOffset

    elseif SheriffConfig.PredictionMode == "Predictivo Adaptativo" then
        local dynamicH = timeFrame
        if lastVelocity.Magnitude > 1 and smoothedVelocity.Magnitude > 1 then
            local dotProduct = smoothedVelocity.Unit:Dot(lastVelocity.Unit)
            if dotProduct < 0.30 then 
                dynamicH = dynamicH * math.clamp(dotProduct, 0.50, 1.0) 
            end
        end

        local horizontalOffset = Vector3.new(smoothedVelocity.X, 0, smoothedVelocity.Z) * dynamicH
        finalPrediction = targetPosition + horizontalOffset + verticalOffset

    elseif SheriffConfig.PredictionMode == "Lineal Estable" then
        local horizontalOffset = Vector3.new(smoothedVelocity.X * timeFrame, 0, smoothedVelocity.Z * timeFrame)
        finalPrediction = targetPosition + horizontalOffset + verticalOffset
    end

    -- CAP DE SEGURIDAD ABSOLUTO (Máximo adelantamiento permitido dinámico)
    local maxAllowedLead = 2.2 * proximityScale
    local horizontalDist = (Vector3.new(finalPrediction.X, 0, finalPrediction.Z) - Vector3.new(targetPosition.X, 0, targetPosition.Z)).Magnitude
    if horizontalDist > maxAllowedLead then
        local direction = (finalPrediction - targetPosition).Unit
        finalPrediction = targetPosition + (direction * maxAllowedLead)
    end

    -- COMPROBACIÓN FINAL ANTI-ENTERRADO
    if smoothedVelocity.Y < -0.1 or humanoid.FloorMaterial ~= Enum.Material.Air then
        local floorY = getFloorHeight(hrp, targetChar)
        if floorY then
            local minAllowedY = floorY + ((hrp.Size.Y / 2) * heightScale) + 0.1
            if finalPrediction.Y < minAllowedY then
                finalPrediction = Vector3.new(finalPrediction.X, minAllowedY, finalPrediction.Z)
            end
        end
    end

    return finalPrediction
end

-- ============================================================================
-- ⚙️ RELOJ DE SUB-FOTOGRAMAS (HEARTBEAT LOOP)
-- ============================================================================
RunService.Heartbeat:Connect(function(dt)
    lastDeltaTime = dt 
    local mud = getMurderer()
    if mud and mud.Character and mud.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = mud.Character.HumanoidRootPart
        previousTargetVelocity = lastVelocity
        lastVelocity = hrp.AssemblyLinearVelocity
        if lastTargetPosition ~= Vector3.new(0, 0, 0) then
            local actualDisplacement = (hrp.Position - lastTargetPosition).Magnitude
            if hrp.AssemblyLinearVelocity.Magnitude > 1.5 and actualDisplacement < 0.01 then
                stuckCounter = math.min(stuckCounter + 1, 20)
            else stuckCounter = math.max(stuckCounter - 1, 0) end
        end
        lastTargetPosition = hrp.Position
    else
        stuckCounter = 0
        lastTargetPosition = Vector3.new(0, 0, 0)
    end
end)

-- ============================================================================
-- 🟦 🟣 🟥 🟩 MOTOR DE TRACERS COMPLETO
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

RunService.RenderStepped:Connect(function()
    local gun, _ = getGunLocation()
    local hasGun = not SheriffConfig.UseWeaponDetector or (gun ~= nil)
    local murderer = getMurderer()
    local screenGui = game:GetService("CoreGui"):FindFirstChild("KillerHub_VoidGui")
    if screenGui then screenGui.Enabled = SheriffConfig.ShowShootButton and hasGun end

    if not hasGun or not murderer or not murderer.Character then
        PredictionLine.Visible = false; PingLine.Visible = false; LagLine.Visible = false; LeadLine.Visible = false
        return
    end

    local targetHrp = murderer.Character:FindFirstChild("HumanoidRootPart")
    local localChar = LocalPlayer.Character
    local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")

    if targetHrp and localHrp then
        local ping = math.clamp(cachedPingValue, 0.01, 0.4)
        local speedFactor = math.clamp(smoothedVelocity.Magnitude / 16, 0, 1)
        local hFactor = SheriffConfig.HorizontalPred * speedFactor
        local vFactor = SheriffConfig.VerticalPred * speedFactor

        local predictedPos = getPredictedPosition(murderer.Character)
        if predictedPos and SheriffConfig.PredictTracer then
            local screenPos, onScreen = worldToViewport(Camera, predictedPos)
            if onScreen then
                PredictionLine.From = vec2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                PredictionLine.To = vec2New(screenPos.X, screenPos.Y)
                PredictionLine.Visible = true
            else PredictionLine.Visible = false end
        else PredictionLine.Visible = false end

        if SheriffConfig.ShowPingTracer then
            local pingPos = targetHrp.Position + (smoothedVelocity * ping)
            local screenPos, onScreen = worldToViewport(Camera, pingPos)
            if onScreen then
                PingLine.From = vec2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                PingLine.To = vec2New(screenPos.X, screenPos.Y)
                PingLine.Visible = true
            else PingLine.Visible = false end
        else PingLine.Visible = false end

        if SheriffConfig.ShowLagTracer then
            local lagPos = targetHrp.Position + (vec3New(smoothedVelocity.X * hFactor, smoothedVelocity.Y * vFactor, smoothedVelocity.Z * hFactor))
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
            local leadPredictedPos = targetHrp.Position + (balancedVelocity * SheriffConfig.LeadTimePred)
            
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
        if isTargetVisible(murderer.Character) then 
            local predictedPos = getPredictedPosition(murderer.Character)
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
-- 🌌 INTERFAZ V3.5 (BOTÓN CON DESTELLO DE EXPANSIÓN MEJORADO)
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
ShootButton.ClipsDescendants = false -- Desactivado para permitir que la expansión del destello sobresalga limpiamente
ShootButton.Parent = VoidGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, math.floor(SheriffConfig.ButtonSize * 0.24)) 
Corner.Parent = ShootButton

local GlowOverlay = Instance.new("Frame")
GlowOverlay.Name = "GlowOverlay"
GlowOverlay.Size = UDim2.new(1, 0, 1, 0)
GlowOverlay.Position = UDim2.new(0, 0, 0, 0)
GlowOverlay.BackgroundTransparency = 1 
GlowOverlay.ZIndex = ShootButton.ZIndex - 1 -- Colocado detrás para crear un aura/destello exterior expansivo
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
UiGradient.Rotation = 90 
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

local SIDE_ANGLES = {90, 270}

local function processGlowAtCoordinates(inputPosition)
    local buttonAbsolutePos = ShootButton.AbsolutePosition
    local buttonSize = ShootButton.AbsoluteSize
    local localY = inputPosition.Y - buttonAbsolutePos.Y
    local relY = (localY / buttonSize.Y) - 0.5
    
    UiGradient.Offset = Vector2.new(0, relY * 1.5) 
    UiGradient.Rotation = SIDE_ANGLES[math.random(1, #SIDE_ANGLES)]
    
    -- AUMENTO DE DESTELLO POR EXPANSIÓN ÓPTICA (Sin alterar claridad ni el color base)
    TweenService:Create(GlowOverlay, TweenInfo.new(0.08, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(1.32, 0, 1.32, 0),
        Position = UDim2.new(-0.16, 0, -0.16, 0),
        BackgroundTransparency = 0.25
    }):Play()
end

local function fadeGlowReflection()
    -- Regresa al tamaño original ocultando el destello suavemente
    TweenService:Create(GlowOverlay, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
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
                if isTargetVisible(murderer.Character) then
                    local predictedPos = getPredictedPosition(murderer.Character)
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
