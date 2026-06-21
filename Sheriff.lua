-- ============================================================================
-- 👻 KILLER HUB | SHERIFF V7.0.0 [PVP DUELS & UNRESTRICTED TRACERS UPDATE]
-- ============================================================================
if _G.KillerHubLines then
    for _, line in pairs(_G.KillerHubLines) do
        pcall(function() line:Remove() end)
    end
end
_G.KillerHubLines = {}

if _G.KillerHubFOV then
    pcall(function() _G.KillerHubFOV:Remove() end)
end

local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Salayer09/KillerHub/refs/heads/main/Slayer.lua"))()

-- 1. PESTAÑA SHERIFF
local SheriffTab = KillerHub:CreateTab("Sheriff", "rbxassetid://10747373142")

-- 2. CONFIGURACIÓN GLOBAL AUTOMÁTICA
local SheriffConfig = {
    SilentAim = false,
    PredictionMode = "OMNI-ENGINE V6.5", 
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
    
    LeadTimePred = 0.05,
    
    -- NUEVOS AJUSTES PARA PVP MODES
    PvP_FOV_Radius = 120,
    PvP_FOV_Color = Color3.fromRGB(255, 255, 255)
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
            PvP_FOV_Radius = SheriffConfig.PvP_FOV_Radius
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
            SheriffConfig.PvP_FOV_Radius = data.PvP_FOV_Radius or SheriffConfig.PvP_FOV_Radius
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
-- ⚙️ INTERFAZ GRÁFICA CONTROLADA (CON SELECTOR DE MODOS Y FOV CONFIG)
-- ============================================================================
SheriffTab:CreateSection("Ajustes del Silent Aim")

SheriffTab:CreateToggle("SheriffSilent", "Activar Silent Aim Pasivo", function(estado)
    SheriffConfig.SilentAim = estado
end)

SheriffTab:CreateToggle("SheriffWallCheckToggle", "Verificar Paredes Físicas (Estricto)", function(estado)
    SheriffConfig.WallCheck = estado
end)

SheriffTab:CreateSection("Selección de Motor Predictivo")

-- DROPDOWN DE MODOS UNIFICADO
SheriffTab:CreateDropdown("PredictionModeDropdown", {"OMNI-ENGINE V6.5", "PvP Mode (Duels)"}, function(opcion)
    SheriffConfig.PredictionMode = opcion
    saveConfig()
end)

-- CONTROLES DEL FOV PARA DUELOS PVP (Ubicados debajo del Dropdown)
SheriffTab:CreateSlider("PvPFOVSlider", "Radio del FOV PvP", 30, 600, function(valor)
    SheriffConfig.PvP_FOV_Radius = valor
    saveConfig()
end)

SheriffTab:CreateColorPicker("PvPFOVColorPicker", SheriffConfig.PvP_FOV_Color, function(color)
    SheriffConfig.PvP_FOV_Color = color
end)

SheriffTab:CreateSection("Calibración del Motor")

SheriffTab:CreateSlider("HorizontalPredSlider", "Predicción Horizontal", 0, 300, function(valor)
    SheriffConfig.HorizontalPred = valor / 1000 
end)

SheriffTab:CreateSlider("VerticalPredSlider", "Predicción Vertical (Suave)", 0, 120, function(valor)
    SheriffConfig.VerticalPred = valor / 1000
end)

SheriffTab:CreateSection("Líneas de Trayectoria (Tracers a través de Muros)")

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
-- 🧠 SISTEMA DE SELECCIÓN DE OBJETIVOS ADAPTATIVO
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

-- ALGORITMO PVP: Filtra aliados, valida anillo FOV y encuentra al jugador más cercano en combate libre
local function getClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localHrp then return nil end
    
    local mouseLocation = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                
                -- IGNORAR COMPAÑEROS DE EQUIPO (Anti-Fuego Aliado)
                if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team and #game:GetService("Teams"):GetTeams() > 1 then
                    continue
                end
                
                local hrp = player.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    -- VALIDACIÓN DE DISTANCIA DEL ANILLO DE FOV EN PANTALLA
                    local fovDistance = (Vector2.new(screenPos.X, screenPos.Y) - mouseLocation).Magnitude
                    if fovDistance <= SheriffConfig.PvP_FOV_Radius then
                        
                        -- CRITERIO MATEMÁTICO: OBJETIVO MÁS CERCANO EN EL MUNDO 3D
                        local worldDistance = (hrp.Position - localHrp.Position).Magnitude
                        if worldDistance < shortestDistance then
                            shortestDistance = worldDistance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- ENRUTADOR DINÁMICO DE OBJETIVOS
local function getActiveTarget()
    if SheriffConfig.PredictionMode == "PvP Mode (Duels)" then
        return getClosestPlayerInFOV()
    else
        return getMurderer()
    end
end

local function isTargetVisible(targetPart, enemyChar)
    if not SheriffConfig.WallCheck then return true end
    if not targetPart or not enemyChar or not LocalPlayer.Character then return false end
    
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local originCFrame = hrp:FindFirstChild("GunRaycastAttachment") and hrp.GunRaycastAttachment.WorldCFrame or hrp.CFrame
    local originPos = originCFrame.Position
    local targetPos = targetPart.Position
    
    local ignoreList = {char, enemyChar, Camera}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p ~= enemyChar then table.insert(ignoreList, p.Character) end
    end
    wallcastParams.FilterDescendantsInstances = ignoreList
    
    local pathCheck = workspace:Raycast(originPos, targetPos - originPos, wallcastParams)
    if pathCheck then 
        return false 
    end
    return true
end

local function getFloorHeight(targetHrp, targetChar)
    floorCastParams.FilterDescendantsInstances = {targetChar, LocalPlayer.Character, Camera}
    local ray = workspace:Raycast(targetHrp.Position, Vector3.new(0, -25, 0), floorCastParams)
    return ray and ray.Position.Y or nil
end

local function getPredictedPosition(targetChar)
    if not targetChar then return nil end
    local hrp = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head")
    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not hrp or not humanoid or humanoid.Health <= 0 or not localHrp then return nil end

    local now = os.clock()
    local clampedDT = math.min(lastDeltaTime, 0.05) 
    local isLowFPS = lastDeltaTime > 0.033 

    if lastTargetChar ~= targetChar then
        smoothedVelocity = hrp.AssemblyLinearVelocity
        lastTargetChar = targetChar
        positionHistory = {}
        zigZagIntensity = 0
        lastDirectionChangeTime = now
    end

    local targetPosition = hrp.Position
    local heightScale = humanoid:FindFirstChild("BodyHeightScale") and math.clamp(humanoid.BodyHeightScale.Value, 0.2, 1.5) or 1

    local rawVelocity = hrp.AssemblyLinearVelocity
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
        
        if dotProduct < 0.15 then 
            zigZagIntensity = math.min(zigZagIntensity + 1.5, 6)
            lastDirectionChangeTime = now
        end
    end
    if now - lastDirectionChangeTime > 0.4 then
        zigZagIntensity = math.max(zigZagIntensity - (clampedDT * 3.0), 0)
    end

    local currentSpeed = smoothedVelocity.Magnitude
    local speedFactor = math.clamp(currentSpeed / 16, 0, 1.2)

    local fpsBuffer = isLowFPS and 0.045 or 0.033
    local ping = math.clamp(smoothedPing, 0.01, 0.4) + fpsBuffer
    
    local distance = (targetPosition - localHrp.Position).Magnitude
    local distanceFactor = math.clamp(distance / 20, 0.1, 1) 

    local zigZagDampening = math.clamp(1 - (zigZagIntensity / 6.5), 0.20, 1.0)
    local timeFrame = (SheriffConfig.HorizontalPred * speedFactor * zigZagDampening) + ping

    local rawAcceleration = (smoothedVelocity - previousTargetVelocity) / math.max(clampedDT, 0.001)
    if rawAcceleration.Magnitude > 45 then rawAcceleration = rawAcceleration.Unit * 45 end
    local stableAcceleration = Vector3.new(rawAcceleration.X, 0, rawAcceleration.Z)

    local horizontalPrediction = (Vector3.new(smoothedVelocity.X, 0, smoothedVelocity.Z) * timeFrame) + (0.5 * stableAcceleration * (timeFrame ^ 2))
    local basePrediction = targetPosition + (horizontalPrediction * distanceFactor)

    local serverGravity = workspace.Gravity
    local verticalOffset = Vector3.new(0, 0, 0)
    
    if humanoid.FloorMaterial == Enum.Material.Air then
        local airTime = timeFrame * distanceFactor
        local gravityInertia = 0.5 * serverGravity * (airTime ^ 2)
        if activeVerticalVelocity > 0 then
            gravityInertia = gravityInertia * 0.15
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
        local blendWeight = math.clamp(zigZagIntensity / 4.5, 0.1, 0.85)
        finalPrediction = finalPrediction:Lerp(centroid + verticalOffset, blendWeight)
    end

    if smoothedVelocity.Y < -0.1 then
        local floorY = getFloorHeight(hrp, targetChar)
        if floorY then
            local minAllowedY = floorY + ((hrp.Size.Y / 2) * heightScale) + 0.2
            if finalPrediction.Y < minAllowedY then
                finalPrediction = Vector3.new(finalPrediction.X, minAllowedY, finalPrediction.Z)
            end
        end
    end

    previousTargetVelocity = smoothedVelocity
    lastVelocity = rawVelocity
    return finalPrediction
end

-- ============================================================================
-- 🟦 🟣 🟥 🟩 MOTOR DE ELEMENTOS RENDERIZADOS (DRAWING LAYER)
-- ============================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 60
FOVCircle.Filled = false
FOVCircle.Visible = false
_G.KillerHubFOV = FOVCircle

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

local vec2New, vec3New = Vector2.new, Vector3.new
local worldToViewport = Camera.WorldToViewportPoint

RunService.RenderStepped:Connect(function(dt)
    lastDeltaTime = dt
    
    -- Manejo del Anillo de FOV en Pantalla
    if SheriffConfig.PredictionMode == "PvP Mode (Duels)" and SheriffConfig.SilentAim then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = SheriffConfig.PvP_FOV_Radius
        FOVCircle.Color = SheriffConfig.PvP_FOV_Color
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end

    local gun, _ = getGunLocation()
    local hasGun = not SheriffConfig.UseWeaponDetector or (gun ~= nil)
    local targetPlayer = getActiveTarget()
    
    local screenGui = game:GetService("CoreGui"):FindFirstChild("KillerHub_VoidGui")
    if screenGui then screenGui.Enabled = SheriffConfig.ShowShootButton and hasGun end

    -- CORRECCIÓN COMPLETA: Si no se tiene arma o no hay objetivo, se ocultan las líneas y salimos
    if not hasGun or not targetPlayer or not targetPlayer.Character then
        PredictionLine.Visible = false; PingLine.Visible = false; LagLine.Visible = false; LeadLine.Visible = false
        return
    end

    local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character:FindFirstChild("Head")
    local localChar = LocalPlayer.Character
    local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")

    -- LOS TRACERS AHORA SE DIBUJAN SIEMPRE (SIN IMPORTAR EL WALLCHECK)
    if targetHrp and localHrp then
        local distance = (targetHrp.Position - localHrp.Position).Magnitude
        local distFactor = math.clamp((distance - 4) / 16, 0, 1)
        local ping = math.clamp(smoothedPing, 0.01, 0.4)
        
        local speedFactor = math.clamp(smoothedVelocity.Magnitude / 16, 0, 1)
        local hFactor = SheriffConfig.HorizontalPred * speedFactor
        local vFactor = SheriffConfig.VerticalPred * speedFactor

        local predictedPos = getPredictedPosition(targetPlayer.Character)
        if predictedPos and SheriffConfig.PredictTracer then
            local screenPos, onScreen = worldToViewport(Camera, predictedPos)
            if onScreen then
                PredictionLine.From = vec2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                PredictionLine.To = vec2New(screenPos.X, screenPos.Y)
                PredictionLine.Visible = true
            else PredictionLine.Visible = false end
        else PredictionLine.Visible = false end

        if SheriffConfig.ShowPingTracer then
            local pingPos = targetHrp.Position + (smoothedVelocity * ping * distFactor)
            local screenPos, onScreen = worldToViewport(Camera, pingPos)
            if onScreen then
                PingLine.From = vec2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                PingLine.To = vec2New(screenPos.X, screenPos.Y)
                PingLine.Visible = true
            else PingLine.Visible = false end
        else PingLine.Visible = false end

        if SheriffConfig.ShowLagTracer then
            local lagPos = targetHrp.Position + (vec3New(smoothedVelocity.X * hFactor, smoothedVelocity.Y * vFactor, smoothedVelocity.Z * hFactor) * distFactor)
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
            local leadPredictedPos = targetHrp.Position + (balancedVelocity * SheriffConfig.LeadTimePred * distFactor)
            
            if smoothedVelocity.Y < -0.5 then
                local floorY = getFloorHeight(targetHrp, targetPlayer.Character)
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

local function fireAtTargetDirectly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local gun, parent = getGunLocation()
    local targetPlayer = getActiveTarget()

    if gun and targetPlayer and targetPlayer.Character then
        local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character:FindFirstChild("Head")
        if hrp then 
            -- EL WALLCHECK SE EJECUTA ESTRICTAMENTE AQUÍ PARA IMPEDIR TIROS DETRÁS DE MUROS
            if not SheriffConfig.WallCheck or isTargetVisible(hrp, targetPlayer.Character) then
                local predictedPos = getPredictedPosition(targetPlayer.Character)
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
end

-- ============================================================================
-- 🌌 INTERFAZ V3.4 (BOTÓN DIAGONAL FIJO)
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
ShootButton.ClipsDescendants = true 
ShootButton.Parent = VoidGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, math.floor(SheriffConfig.ButtonSize * 0.24))
Corner.Parent = ShootButton

local dragging, dragStart, startPos, dragInput = false, nil, nil, nil
local DRAG_THRESHOLD = 8

ShootButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        task.spawn(fireAtTargetDirectly)
        
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
            local targetPlayer = getActiveTarget()
            if targetPlayer and targetPlayer.Character then
                local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character:FindFirstChild("Head")
                if hrp then
                    if not SheriffConfig.WallCheck or isTargetVisible(hrp, targetPlayer.Character) then
                        local predictedPos = getPredictedPosition(targetPlayer.Character)
                        if predictedPos then return CFrame.new(predictedPos) end
                    end
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
