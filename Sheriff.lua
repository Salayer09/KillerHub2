-- ============================================================================
-- 👻 KILLER HUB | SHERIFF V6.2.6 [ANTI-JITTER FAST STABILIZATION]
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
    PredictionMode = "Predictiva 2.0 (Aceleración)",
    HorizontalPred = 0.145, 
    VerticalPred = 0.035,   
    WallCheck = true,       
    PredictTracer = false,
    ShowPingTracer = false,    
    ShowLagTracer = false,     
    ShowLeadTracer = true,     
    TracerSmoothness = 0.60, -- Por defecto ahora es más reactivo y firme
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
            ShowLagTracer = SheriffConfig.ShowLagTracer,
            TracerSmoothness = SheriffConfig.TracerSmoothness
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
            SheriffConfig.TracerSmoothness = data.TracerSmoothness or SheriffConfig.TracerSmoothness
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

SheriffTab:CreateDropdown("PredMode", "Modo de Predicción:", {"Predictiva 2.0 (Aceleración)", "Predictivo Adaptativo", "Lineal Estable"}, function(seleccionado)
    SheriffConfig.PredictionMode = seleccionado
    saveConfig()
end)

SheriffTab:CreateSlider("HorizontalPredSlider", "Predicción Horizontal", 0, 300, function(valor)
    SheriffConfig.HorizontalPred = valor / 1000 
end)

SheriffTab:CreateSlider("VerticalPredSlider", "Predicción Vertical (Suave)", 0, 120, function(valor)
    SheriffConfig.VerticalPred = valor / 1000
end)

-- SECCIÓN DE TRACERS OPTIMIZADA (ANTI-TEMBLOR)
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

-- SLIDER REDISEÑADO: ESTABILIZADOR EN LUGAR DE SUAVIZADO LENTO
SheriffTab:CreateSlider("TracerSmoothSlider", "Estabilizador Anti-Temblor (1 = Instantáneo)", 1, 100, function(valor)
    if valor == 1 then
        SheriffConfig.TracerSmoothness = 1 -- Instantáneo puro (puede verse tembloroso si hay lag)
    else
        -- Nueva matemática: Escala de forma fluida entre 0.95 (casi instantáneo) y 0.15 (máxima estabilidad sin perder velocidad)
        SheriffConfig.TracerSmoothness = 0.95 - ((valor - 2) / 98) * 0.80
    end
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
-- 🧠 MOTOR CINEMÁTICO INTEGRADO CON ESTABILIZACIÓN DE RED AVANZADA
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

local pingHistory = {}
local maxPingHistorySize = 12
local cachedPingValue = 0.06

local function getSmoothedPing(rawPing)
    table.insert(pingHistory, rawPing)
    if #pingHistory > maxPingHistorySize then table.remove(pingHistory, 1) end
    
    local sum = 0
    local maxRecentPing = 0
    for _, p in ipairs(pingHistory) do
        sum = sum + p
        if p > maxRecentPing then maxRecentPing = p end
    end
    local averagePing = sum / #pingHistory
    return (averagePing * 0.65) + (maxRecentPing * 0.35)
end

task.spawn(function()
    while task.wait(0.3) do
        if Stats and Stats:FindFirstChild("Network") and Stats.Network:FindFirstChild("ServerToClientPing") then
            local currentRaw = Stats.Network.ServerToClientPing:GetValue() / 1000
            cachedPingValue = getSmoothedPing(currentRaw)
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

local function isTargetVisible(targetPart, murdererChar)
    if not SheriffConfig.WallCheck then return true end
    if not targetPart or not murdererChar or not LocalPlayer.Character then return false end
    
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local gun = char:FindFirstChild("Gun")
    local originPos = (gun and gun:FindFirstChild("Handle")) and gun.Handle.Position or hrp.Position
    local targetPos = targetPart.Position
    
    local ignoreList = {char, murdererChar, Camera}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p ~= murdererChar then table.insert(ignoreList, p.Character) end
    end
    wallcastParams.FilterDescendantsInstances = ignoreList
    
    local clipCheck = workspace:Raycast(hrp.Position, originPos - hrp.Position, wallcastParams)
    if clipCheck then return false end
    
    local pathCheck = workspace:Raycast(originPos, targetPos - originPos, wallcastParams)
    if not pathCheck then return true end 
    
    local instance = pathCheck.Instance
    if instance.CanCollide == true then return false end
    if instance.Transparency < 0.75 then return false end
    
    local mat = instance.Material
    if mat == Enum.Material.Glass or mat == Enum.Material.SmoothPlastic or mat == Enum.Material.Brick or mat == Enum.Material.Wood or mat == Enum.Material.Concrete or mat == Enum.Material.Metal then
        return false
    end
    
    return false
end

local function getBestTargetPart(murdererChar)
    if not murdererChar then return nil end
    local hrp = murdererChar:FindFirstChild("HumanoidRootPart")
    local head = murdererChar:FindFirstChild("Head")
    
    if hrp and isTargetVisible(hrp, murdererChar) then
        return hrp
    elseif head and isTargetVisible(head, murdererChar) then
        return head
    end
    return nil 
end

local function getFloorHeight(targetHrp, targetChar)
    floorCastParams.FilterDescendantsInstances = {targetChar, LocalPlayer.Character, Camera}
    local ray = workspace:Raycast(targetHrp.Position, Vector3.new(0, -25, 0), floorCastParams)
    return ray and ray.Position.Y or nil
end

local function getPredictedPosition(targetChar, targetPart)
    if not targetChar or not targetPart then return nil end
    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not hrp or not humanoid or humanoid.Health <= 0 or not localHrp then return nil end

    if lastTargetChar ~= targetChar then
        smoothedVelocity = hrp.AssemblyLinearVelocity
        previousTargetVelocity = smoothedVelocity
        lastTargetChar = targetChar
    end

    local targetPosition = targetPart.Position
    local distance = (targetPosition - localHrp.Position).Magnitude

    local proximityFactor = 1
    if distance < 14 then
        proximityFactor = math.clamp((distance - 2) / 12, 0.35, 1)
    end

    local rawVelocity = hrp.AssemblyLinearVelocity
    if rawVelocity.Magnitude > 55 then rawVelocity = rawVelocity.Unit * 16 end

    local dotProduct = 1
    if previousTargetVelocity.Magnitude > 0.5 and rawVelocity.Magnitude > 0.5 then
        dotProduct = rawVelocity.Unit:Dot(previousTargetVelocity.Unit)
    end

    if dotProduct < 0.3 then rawVelocity = rawVelocity * math.clamp(dotProduct, 0.1, 0.5) end
    if rawVelocity.Magnitude < previousTargetVelocity.Magnitude * 0.4 then rawVelocity = rawVelocity * 0.15 end

    local clampedDT = math.min(lastDeltaTime, 0.05) 
    local isLowFPS = lastDeltaTime > 0.033 

    local adaptiveWeight = isLowFPS and 0.4 or math.clamp(1 - math.exp(-20 * clampedDT), 0.02, 0.8)
    smoothedVelocity = smoothedVelocity:Lerp(rawVelocity, math.clamp(adaptiveWeight, 0.02, 0.95))
    
    if smoothedVelocity.Magnitude < 0.05 then 
        previousTargetVelocity = smoothedVelocity
        return targetPosition 
    end

    local currentSpeed = smoothedVelocity.Magnitude
    local speedFactor = math.clamp(currentSpeed / 16, 0, 1.2)

    local fpsBuffer = isLowFPS and 0.045 or 0.033
    local ping = math.clamp(cachedPingValue, 0.01, 0.5) + fpsBuffer
    
    local distanceFactor = math.clamp(distance / 22, 0.05, 1.1) * proximityFactor

    local hFactor = (SheriffConfig.HorizontalPred * 1.15) * speedFactor
    local timeFrame = (hFactor + ping) * distanceFactor

    local verticalOffset = Vector3.new(0, 0, 0)
    if humanoid.FloorMaterial == Enum.Material.Air or smoothedVelocity.Y > 0.5 or smoothedVelocity.Y < -0.5 then
        local gravity = 196.2 
        local verticalTime = ping * SheriffConfig.VerticalPred * proximityFactor
        local pY = (smoothedVelocity.Y * verticalTime) - (0.5 * gravity * (verticalTime ^ 2))
        if distance < 10 then pY = pY * 0.2 end
        verticalOffset = Vector3.new(0, pY, 0)
    end

    local finalPrediction = targetPosition

    if SheriffConfig.PredictionMode == "Predictiva 2.0 (Aceleración)" then
        local rawAcceleration = (smoothedVelocity - previousTargetVelocity) / math.max(clampedDT, 0.001)
        if dotProduct < 0.5 then rawAcceleration = rawAcceleration * 0.05 end 
        if rawAcceleration.Magnitude > 120 then rawAcceleration = rawAcceleration.Unit * 12 end
        
        local accAmortiguacion = isLowFPS and 0.02 or 0.08
        local stableAcceleration = Vector3.new(rawAcceleration.X, rawAcceleration.Y * accAmortiguacion, rawAcceleration.Z)
        local horizontalPrediction = (smoothedVelocity * timeFrame) + (0.5 * stableAcceleration * (timeFrame ^ 2))
        
        if ping > 0.22 then horizontalPrediction = horizontalPrediction * 0.80 end
        finalPrediction = targetPosition + Vector3.new(horizontalPrediction.X, 0, horizontalPrediction.Z) + verticalOffset

    elseif SheriffConfig.PredictionMode == "Predictivo Adaptativo" then
        local dynamicH = timeFrame
        if dotProduct < 0.85 then dynamicH = dynamicH * math.clamp(dotProduct, 0.2, 1.0) end
        local horizontalOffset = Vector3.new(smoothedVelocity.X, 0, smoothedVelocity.Z) * dynamicH
        finalPrediction = targetPosition + horizontalOffset + verticalOffset

    elseif SheriffConfig.PredictionMode == "Lineal Estable" then
        local stableTime = timeFrame * (isLowFPS and 0.85 or 0.95)
        local horizontalOffset = Vector3.new(smoothedVelocity.X * stableTime, 0, smoothedVelocity.Z * stableTime)
        finalPrediction = targetPosition + horizontalOffset + verticalOffset
    end

    if smoothedVelocity.Y < -0.1 then
        local floorY = getFloorHeight(hrp, targetChar)
        if floorY then
            local heightScale = humanoid:FindFirstChild("BodyHeightScale") and math.clamp(humanoid.BodyHeightScale.Value, 0.2, 1.5) or 1
            local minAllowedY = floorY + ((hrp.Size.Y / 2) * heightScale) + 0.2
            if finalPrediction.Y < minAllowedY then
                finalPrediction = Vector3.new(finalPrediction.X, minAllowedY, finalPrediction.Z)
            end
        end
    end

    previousTargetVelocity = smoothedVelocity
    lastVelocity = smoothedVelocity

    return finalPrediction
end

-- ============================================================================
-- 🟩 MOTOR DE TRACERS INTERPOLADO EFICIENTE
-- ============================================================================
local PingLine = Drawing.new("Line")
PingLine.Color = Color3.fromRGB(0, 45, 167) 
PingLine.Thickness = 1.0
PingLine.Visible = false
table.insert(_G.KillerHubLines, PingLine)

local LagLine = Drawing.new("Line")
LagLine.Color = Color3.fromRGB(114, 39, 214) 
LagLine.Thickness = 1.0
LagLine.Visible = false
table.insert(_G.KillerHubLines, LagLine)

local LeadLine = Drawing.new("Line")
LeadLine.Color = Color3.fromRGB(103, 255, 89) 
LeadLine.Thickness = 1.0
LeadLine.Visible = false
table.insert(_G.KillerHubLines, LeadLine)

local PredictionLine = Drawing.new("Line")
PredictionLine.Color = Color3.fromRGB(255, 35, 35)
PredictionLine.Thickness = 1.2 
PredictionLine.Visible = false
table.insert(_G.KillerHubLines, PredictionLine)

local currentScreenPred = Vector2.new(0,0)
local currentScreenPing = Vector2.new(0,0)
local currentScreenLag = Vector2.new(0,0)
local currentScreenLead = Vector2.new(0,0)
local firstFrame = true

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
        firstFrame = true
        return
    end

    local targetChar = murderer.Character
    local bestPart = getBestTargetPart(targetChar) or targetChar:FindFirstChild("HumanoidRootPart") 
    local localChar = LocalPlayer.Character
    local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")

    if bestPart and localHrp then
        local distance = (bestPart.Position - localHrp.Position).Magnitude
        local distFactor = math.clamp((distance - 4) / 16, 0, 1)
        local ping = math.clamp(cachedPingValue, 0.01, 0.4)
      
        local speedFactor = math.clamp(smoothedVelocity.Magnitude / 16, 0, 1)
        local hFactor = SheriffConfig.HorizontalPred * speedFactor
        local vFactor = SheriffConfig.VerticalPred * speedFactor
        
        local tSmooth = SheriffConfig.TracerSmoothness

        -- 1. TRACER DE IMPACTO (ROJO)
        local predictedPos = getPredictedPosition(targetChar, bestPart)
        if predictedPos and SheriffConfig.PredictTracer then
            local screenPos, onScreen = worldToViewport(Camera, predictedPos)
            if onScreen then
                local target2D = vec2New(screenPos.X, screenPos.Y)
                currentScreenPred = (firstFrame or tSmooth == 1) and target2D or currentScreenPred:Lerp(target2D, tSmooth)
                
                PredictionLine.From = vec2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                PredictionLine.To = currentScreenPred
                PredictionLine.Visible = true
            else PredictionLine.Visible = false end
        else PredictionLine.Visible = false end

        -- 2. TRACER DE PING (AZUL)
        if SheriffConfig.ShowPingTracer then
            local pingPos = bestPart.Position + (smoothedVelocity * ping * distFactor)
            local screenPos, onScreen = worldToViewport(Camera, pingPos)
            if onScreen then
                local target2D = vec2New(screenPos.X, screenPos.Y)
                currentScreenPing = (firstFrame or tSmooth == 1) and target2D or currentScreenPing:Lerp(target2D, tSmooth)
                
                PingLine.From = vec2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                PingLine.To = currentScreenPing
                PingLine.Visible = true
            else PingLine.Visible = false end
        else PingLine.Visible = false end

        -- 3. TRACER DE LAG (VIOLETA)
        if SheriffConfig.ShowLagTracer then
            local lagPos = bestPart.Position + (vec3New(smoothedVelocity.X * hFactor, smoothedVelocity.Y * vFactor, smoothedVelocity.Z * hFactor) * distFactor)
            local screenPos, onScreen = worldToViewport(Camera, lagPos)
            if onScreen then
                local target2D = vec2New(screenPos.X, screenPos.Y)
                currentScreenLag = (firstFrame or tSmooth == 1) and target2D or currentScreenLag:Lerp(target2D, tSmooth)
                
                LagLine.From = vec2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                LagLine.To = currentScreenLag
                LagLine.Visible = true
            else LagLine.Visible = false end
        else LagLine.Visible = false end

        -- 4. LEAD TRACER (VERDE NEÓN)
        local hand = localChar and (localChar:FindFirstChild("RightHand") or localChar:FindFirstChild("Right Arm"))
        if SheriffConfig.ShowLeadTracer and hand then
            local balancedVelocity = vec3New(smoothedVelocity.X, smoothedVelocity.Y * 0.5, smoothedVelocity.Z)
            local leadPredictedPos = bestPart.Position + (balancedVelocity * SheriffConfig.LeadTimePred * distFactor)
            
            if smoothedVelocity.Y < -0.5 then
                local floorY = getFloorHeight(bestPart, targetChar)
                if floorY and leadPredictedPos.Y < (floorY + 1) then
                    leadPredictedPos = vec3New(leadPredictedPos.X, floorY + 1, leadPredictedPos.Z)
                end
            end

            local handScreenPos, handOnScreen = worldToViewport(Camera, hand.Position)
            local targetScreenPos, targetOnScreen = worldToViewport(Camera, leadPredictedPos)

            if handOnScreen and targetOnScreen then
                local target2D = vec2New(targetScreenPos.X, targetScreenPos.Y)
                currentScreenLead = (firstFrame or tSmooth == 1) and target2D or currentScreenLead:Lerp(target2D, tSmooth)
                
                LeadLine.From = vec2New(handScreenPos.X, handScreenPos.Y)
                LeadLine.To = currentScreenLead
                LeadLine.Visible = true
            else LeadLine.Visible = false end
        else LeadLine.Visible = false end
        
        firstFrame = false
    else
        PredictionLine.Visible = false; PingLine.Visible = false; LagLine.Visible = false; LeadLine.Visible = false
        firstFrame = true
    end
end)

local function fireAtMurdererDirectly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local gun, parent = getGunLocation()
    local murderer = getMurderer()

    if gun and murderer and murderer.Character then
        local targetChar = murderer.Character
        local bestPart = getBestTargetPart(targetChar) 
        
        if bestPart then 
            local predictedPos = getPredictedPosition(targetChar, bestPart)
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
-- 🌌 INTERFAZ V3.4 (BOTÓN SHOOT FLUIDO)
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
DecalTexture.Size = UDim2.new(0.38, 0, 0.38, 0)
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
    TweenService:Create(GlowOverlay, TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.27}):Play()
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
-- ⚡ REMOTOS MODIFICADOS
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
                local targetChar = murderer.Character
                local bestPart = getBestTargetPart(targetChar) 
                
                if bestPart then
                    local predictedPos = getPredictedPosition(targetChar, bestPart)
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
