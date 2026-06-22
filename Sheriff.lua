-- ============================================================================
-- 👻 KILLER HUB | SHERIFF V6.8.5 [ANTI-JITTER & SCREEN-STRETCH COMPENSATOR]
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
    PredictionMode = "OMNI-ENGINE V6.8.5", 
    HorizontalPred = 1.15, -- Incrementado ligeramente para mejorar intercepciones a larga distancia
    VerticalPred = 1.05,   -- Ajuste fino para saltos a 200ms de ping
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
            ShowLagTracer = SheriffConfig.ShowLagTracer,
            HorizontalPred = SheriffConfig.HorizontalPred,
            VerticalPred = SheriffConfig.VerticalPred
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
            SheriffConfig.PredictionMode = "OMNI-ENGINE V6.8.5"
            SheriffConfig.LeadTimePred = data.LeadTimePred or SheriffConfig.LeadTimePred
            if data.UseWeaponDetector ~= nil then SheriffConfig.UseWeaponDetector = data.UseWeaponDetector end
            if data.AutoUnequip ~= nil then SheriffConfig.AutoUnequip = data.AutoUnequip end
            if data.ShowLeadTracer ~= nil then SheriffConfig.ShowLeadTracer = data.ShowLeadTracer end
            if data.ShowPingTracer ~= nil then SheriffConfig.ShowPingTracer = data.ShowPingTracer end
            if data.ShowLagTracer ~= nil then SheriffConfig.ShowLagTracer = data.ShowLagTracer end
            if data.HorizontalPred ~= nil then SheriffConfig.HorizontalPred = data.HorizontalPred end
            if data.VerticalPred ~= nil then SheriffConfig.VerticalPred = data.VerticalPred end
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

SheriffTab:CreateToggle("SheriffWallCheckToggle", "Verificar Paredes Físicas (Estricto)", function(estado)
    SheriffConfig.WallCheck = estado
end)

SheriffTab:CreateSection("Motor Activo: OMNI-ENGINE V6.8.5 (Filtro Estabilizador)")

SheriffTab:CreateSlider("HorizontalPredSlider", "Ajuste Fino Horizontal (%)", 50, 150, function(valor)
    SheriffConfig.HorizontalPred = valor / 100 
    saveConfig()
end)

SheriffTab:CreateSlider("VerticalPredSlider", "Ajuste Fino Vertical (%)", 50, 150, function(valor)
    SheriffConfig.VerticalPred = valor / 100
    saveConfig()
end)

SheriffTab:CreateSection("Líneas de Trayectoria (Tracers Anti-Jitter)")

SheriffTab:CreateToggle("TracerPredToggle", "Mostrar Tracer de Impacto (Rojo)", function(estado)
    SheriffConfig.PredictTracer = estado
end)

SheriffTab:CreateToggle("PingTracerToggle", "Mostrar Ping Prediction (Azul Fuerte)", function(estado)
    SheriffConfig.ShowPingTracer = estado
    saveConfig()
end)

SheriffTab:CreateToggle("LagTracerToggle", "Mostrar Lag de Red Puro (Violeta Elegante)", function(estado)
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

-- [Resto de la UI táctica se mantiene intacta]
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
-- 🧠 MOTOR CINEMÁTICO MATEMÁTICO AVANZADO V6.8.5
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
            smoothedPing = smoothedPing + (rawPing - smoothedPing) * 0.35
        end
    end
end)

local wallcastParams = RaycastParams.new()
wallcastParams.FilterType = Enum.RaycastFilterType.Exclude
local floorCastParams = RaycastParams.new()
floorCastParams.FilterType = Enum.RaycastFilterType.Exclude

local function getGunLocation()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Gun") then return char:FindFirstChild("Gun"), char end
    if LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Gun") then return LocalPlayer.Backpack.Gun, LocalPlayer.Backpack end
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
    local hpreal = char:FindFirstChild("HumanoidRootPart")
    if not hpreal then return false end
    
    local originPos = hpreal.Position
    local ignoreList = {char, murdererChar, Camera}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p ~= murdererChar then table.insert(ignoreList, p.Character) end
    end
    wallcastParams.FilterDescendantsInstances = ignoreList
    
    local pathCheck = workspace:Raycast(originPos, targetPart.Position - originPos, wallcastParams)
    return pathCheck == nil
end

local function getAbsoluteTargetPart(murdererChar)
    if not murdererChar then return nil end
    local priorityParts = {"HumanoidRootPart", "Head", "UpperTorso"}
    for _, name in ipairs(priorityParts) do
        local part = murdererChar:FindFirstChild(name)
        if part and isPartVisible(part, murdererChar) then return part end
    end
    return murdererChar:FindFirstChild("HumanoidRootPart")
end

local function getFloorHeight(targetHrp, targetChar)
    floorCastParams.FilterDescendantsInstances = {targetChar, LocalPlayer.Character, Camera}
    local ray = workspace:Raycast(targetHrp.Position, Vector3.new(0, -25, 0), floorCastParams)
    return ray and ray.Position.Y or nil
end

local function getPredictedPosition(targetChar)
    if not targetChar then return nil end
    local mainPart = getAbsoluteTargetPart(targetChar)
    if not mainPart then return nil end
    
    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not localHrp then return nil end

    local now = os.clock()
    local clampedDT = math.min(lastDeltaTime, 0.05) 

    if lastTargetChar ~= targetChar then
        smoothedVelocity = mainPart.AssemblyLinearVelocity
        lastTargetChar = targetChar
        positionHistory = {}
        zigZagIntensity = 0
        lastDirectionChangeTime = now
    end

    local targetPosition = mainPart.Position
    local distance = (targetPosition - localHrp.Position).Magnitude
    
    local BULLET_SPEED = 275 
    local estimatedTimeToTarget = (distance / BULLET_SPEED) + smoothedPing

    local distanceMultiplier = 1.0
    if distance < 15 then distanceMultiplier = 0.85 elseif distance > 45 then distanceMultiplier = 1.15 end

    local totalHorizontalTime = estimatedTimeToTarget * distanceMultiplier * SheriffConfig.HorizontalPred
    local totalVerticalTime = estimatedTimeToTarget * distanceMultiplier * SheriffConfig.VerticalPred

    local rawVelocity = mainPart.AssemblyLinearVelocity
    if rawVelocity.Magnitude > 55 then rawVelocity = rawVelocity.Unit * 16 end
    
    -- Filtro de paso bajo para suavizar la velocidad física transmitida por red
    local velocitySmoothingFactor = math.clamp(1 - math.exp(-18 * clampedDT), 0.01, 0.75)
    smoothedVelocity = smoothedVelocity:Lerp(rawVelocity, velocitySmoothingFactor)

    table.insert(positionHistory, 1, targetPosition)
    if #positionHistory > 10 then table.remove(positionHistory) end
    if lastVelocity.Magnitude > 0.5 and rawVelocity.Magnitude > 0.5 then
        local currentDir = Vector3.new(rawVelocity.X, 0, rawVelocity.Z).Unit
        local prevDir = Vector3.new(lastVelocity.X, 0, lastVelocity.Z).Unit
        if currentDir:Dot(prevDir) < 0.35 then 
            zigZagIntensity = math.min(zigZagIntensity + 2.5, 8.0)
            lastDirectionChangeTime = now
        end
    end
    if now - lastDirectionChangeTime > 0.25 then
        zigZagIntensity = math.max(zigZagIntensity - (clampedDT * 5.0), 0)
    end
    local zigZagDampening = math.clamp(1 - (zigZagIntensity / 8.5), 0.10, 1.0)

    local horizontalVelocity = Vector3.new(smoothedVelocity.X, 0, smoothedVelocity.Z) * zigZagDampening
    local basePrediction = targetPosition + (horizontalVelocity * totalHorizontalTime)

    local verticalOffset = Vector3.new(0, 0, 0)
    if humanoid.FloorMaterial == Enum.Material.Air or math.abs(rawVelocity.Y) > 0.7 then
        local verticalVelocity = rawVelocity.Y
        if verticalVelocity > 0.5 then verticalVelocity = verticalVelocity * 1.25 end
        local predictedYDisplacement = (verticalVelocity * totalVerticalTime) - (0.5 * workspace.Gravity * (totalVerticalTime ^ 2))
        verticalOffset = Vector3.new(0, predictedYDisplacement, 0)
    else
        verticalOffset = Vector3.new(0, rawVelocity.Y * totalVerticalTime * 0.5, 0)
    end

    local finalPrediction = basePrediction + verticalOffset

    if rawVelocity.Y < -0.1 then
        local floorY = getFloorHeight(mainPart, targetChar)
        if floorY then
            local minAllowedY = floorY + (mainPart.Size.Y / 2) + 0.2
            if finalPrediction.Y < minAllowedY then finalPrediction = Vector3.new(finalPrediction.X, minAllowedY, finalPrediction.Z) end
        end
    end

    previousTargetVelocity = smoothedVelocity
    lastVelocity = rawVelocity
    return finalPrediction
end

-- ============================================================================
-- 🟦 🟣 🟥 🟩 MOTOR DE RENDERIZADO CON FILTRO ANTI-TEMBLOR 2D
-- ============================================================================
local PingLine = Drawing.new("Line")
PingLine.Color = Color3.fromRGB(0, 85, 255) PingLine.Thickness = 1.2 PingLine.Visible = false table.insert(_G.KillerHubLines, PingLine)

local LagLine = Drawing.new("Line")
LagLine.Color = Color3.fromRGB(163, 73, 255) LagLine.Thickness = 1.2 LagLine.Visible = false table.insert(_G.KillerHubLines, LagLine)

local LeadLine = Drawing.new("Line")
LeadLine.Color = Color3.fromRGB(103, 255, 89) LeadLine.Thickness = 1.0 LeadLine.Visible = false table.insert(_G.KillerHubLines, LeadLine)

local PredictionLine = Drawing.new("Line")
PredictionLine.Color = Color3.fromRGB(255, 35, 35) PredictionLine.Thickness = 1.5 PredictionLine.Visible = false table.insert(_G.KillerHubLines, PredictionLine)

-- Vectores de almacenamiento para estabilizar la pantalla (Filtro Lerp 2D)
local sPredictTo, sPingTo, sLagTo, sLeadTo = Vector2.new(0,0), Vector2.new(0,0), Vector2.new(0,0), Vector2.new(0,0)
local vec2New, worldToViewport = Vector2.new, Camera.WorldToViewportPoint

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

    local mainPart = getAbsoluteTargetPart(murderer.Character)
    local localChar = LocalPlayer.Character
    local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")

    if mainPart and localHrp then
        local centerOrigin = vec2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        local distance = (mainPart.Position - localHrp.Position).Magnitude
        local currentPing = math.clamp(smoothedPing, 0.01, 0.4)
        
        -- Factor de suavizado para los vectores de la pantalla (Amortigua el temblor de red)
        -- Ajustado dinámicamente para responder bien incluso con resoluciones estiradas
        local lerpWeight = math.clamp(14 * dt, 0.05, 0.45)

        -- 1. TRACER ROJO (Predicción Cinemática Final)
        local predictedPos = getPredictedPosition(murderer.Character)
        if predictedPos and SheriffConfig.PredictTracer then
            local screenPos, onScreen = worldToViewport(Camera, predictedPos)
            if onScreen then
                sPredictTo = sPredictTo:Lerp(vec2New(screenPos.X, screenPos.Y), lerpWeight)
                PredictionLine.From = centerOrigin
                PredictionLine.To = sPredictTo
                PredictionLine.Visible = true
            else PredictionLine.Visible = false end
        else PredictionLine.Visible = false end

        -- 2. TRACER AZUL (Ping puro en línea recta horizontal)
        if SheriffConfig.ShowPingTracer then
            local pingPos = mainPart.Position + (Vector3.new(smoothedVelocity.X, 0, smoothedVelocity.Z) * currentPing)
            local screenPos, onScreen = worldToViewport(Camera, pingPos)
            if onScreen then
                sPingTo = sPingTo:Lerp(vec2New(screenPos.X, screenPos.Y), lerpWeight)
                PingLine.From = centerOrigin
                PingLine.To = sPingTo
                PingLine.Visible = true
            else PingLine.Visible = false end
        else PingLine.Visible = false end

        -- 3. TRACER MORADO (Lag de Red Físico Puro)
        -- [MODIFICACIÓN]: Desvinculado de la parábola roja para evitar que se encimen. Mide arrastre bruto de red.
        if SheriffConfig.ShowLagTracer then
            local lagRawPos = mainPart.Position + (smoothedVelocity * (currentPing * 1.5))
            local screenPos, onScreen = worldToViewport(Camera, lagRawPos)
            if onScreen then
                sLagTo = sLagTo:Lerp(vec2New(screenPos.X, screenPos.Y), lerpWeight)
                LagLine.From = centerOrigin
                LagLine.To = sLagTo
                LagLine.Visible = true
            else LagLine.Visible = false end
        else LagLine.Visible = false end

        -- 4. TRACER VERDE (Mano al objetivo)
        local hand = localChar and (localChar:FindFirstChild("RightHand") or localChar:FindFirstChild("Right Arm"))
        if SheriffConfig.ShowLeadTracer and hand then
            local distFactor = math.clamp((distance - 4) / 16, 0, 1)
            local leadPredictedPos = mainPart.Position + (smoothedVelocity * SheriffConfig.LeadTimePred * distFactor)
            
            local handScreenPos, handOnScreen = worldToViewport(Camera, hand.Position)
            local targetScreenPos, targetOnScreen = worldToViewport(Camera, leadPredictedPos)

            if handOnScreen and targetOnScreen then
                sLeadTo = sLeadTo:Lerp(vec2New(targetScreenPos.X, targetScreenPos.Y), lerpWeight)
                LeadLine.From = vec2New(handScreenPos.X, handScreenPos.Y)
                LeadLine.To = sLeadTo
                LeadLine.Visible = true
            else LeadLine.Visible = false end
        else LeadLine.Visible = false end
    else
        PredictionLine.Visible = false; PingLine.Visible = false; LagLine.Visible = false; LeadLine.Visible = false
    end
end)

-- ============================================================================
-- 🌌 SECCIÓN DE DISPARO AUTOMÁTICO Y EJECUCIÓN (Mantenidos intactos por seguridad)
-- ============================================================================
local function fireAtMurdererDirectly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end
    local gun, parent = getGunLocation()
    local murderer = getMurderer()

    if gun and murderer and murderer.Character then
        local mainPart = getAbsoluteTargetPart(murderer.Character)
        if mainPart and isPartVisible(mainPart, murderer.Character) then 
            local predictedPos = getPredictedPosition(murderer.Character)
            if predictedPos then
                if parent == LocalPlayer.Backpack then 
                    char:FindFirstChildOfClass("Humanoid"):EquipTool(gun) 
                    RunService.Heartbeat:Wait() 
                end
                if gun:FindFirstChild("Shoot") then
                    local originCFrame = char.HumanoidRootPart.CFrame
                    if char.HumanoidRootPart:FindFirstChild("GunRaycastAttachment") then originCFrame = char.HumanoidRootPart.GunRaycastAttachment.WorldCFrame end
                    gun.Shoot:FireServer(originCFrame, CFrame.new(predictedPos))
                end
                if SheriffConfig.AutoUnequip then task.wait(0.02) char:FindFirstChildOfClass("Humanoid"):UnequipTools() end
            end
        end
    end
end

-- [Lógica del Botón de disparo Void e interceptación de red heredada de v6.8.0]
local VoidGui = Instance.new("ScreenGui") VoidGui.Name = "KillerHub_VoidGui" VoidGui.ResetOnSpawn = false VoidGui.Parent = game:GetService("CoreGui")
local ShootButton = Instance.new("ImageButton") ShootButton.Name = "ShootButton" ShootButton.Size = UDim2.new(0, SheriffConfig.ButtonSize, 0, SheriffConfig.ButtonSize) ShootButton.Position = UDim2.new(SheriffConfig.ButtonX, 0, SheriffConfig.ButtonY, 0) ShootButton.BackgroundColor3 = Color3.fromRGB(15, 6, 26) ShootButton.BackgroundTransparency = 1 - SheriffConfig.ButtonOpacity SnippetCorner = Instance.new("UICorner") SnippetCorner.CornerRadius = UDim.new(0, math.floor(SheriffConfig.ButtonSize * 0.24)) SnippetCorner.Parent = ShootButton ShootButton.Parent = VoidGui

ShootButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        task.spawn(fireAtMurdererDirectly)
    end
end)

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
                local mainPart = getAbsoluteTargetPart(murderer.Character)
                if mainPart and isPartVisible(mainPart, murderer.Character) then
                    local predictedPos = getPredictedPosition(murderer.Character)
                    if predictedPos then return CFrame.new(predictedPos) end
                end
            end
        end
        return nil
    end
    WeaponService.GetTargetPosition = function(self, ...) return checkAndPredict() or oldGetTargetPosition(self, ...) end
    WeaponService.GetMouseTargetCFrame = function(self, ...) return checkAndPredict() or oldGetMouseTargetCFrame(self, ...) end
end

return KillerHub
