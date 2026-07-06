-- ============================================================================
--  KILLER HUB | SHERIFF V7.7.5 ULTRA-PREMIUM [🔥 TOTAL PRECISION & GC FIX]
-- ============================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService") 
local Stats = game:GetService("Stats") 
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- ⚡ LOCALIZACIÓN DE GLOBALES PARA MÁXIMO RENDIMIENTO (UPVALUES)
local math_clamp = math.clamp
local math_min = math.min
local math_max = math.max
local math_abs = math.abs
local math_exp = math.exp
local math_floor = math.floor
local vec2New = Vector2.new
local vec3New = Vector3.new
local udim2New = UDim2.new
local cframeNew = CFrame.new
local color3RGB = Color3.fromRGB
local os_clock = os.clock

local workspace = workspace
local workspace_Gravity = workspace.Gravity

-- Variables vectoriales estáticas para evitar recolección de basura (Garbage Collection)
local VECTOR_ZERO = vec3New(0, 0, 0)
local VECTOR_UP = vec3New(0, 1, 0)

-- Contenedores estáticos para reciclaje de memoria
local ignoreList = {}

-- 1. LIMPIEZA TOTAL DE MEMORIA
if _G.KillerHubLines then
    for _, line in pairs(_G.KillerHubLines) do
        pcall(function() line:Remove() end)
    end
end
_G.KillerHubLines = {}

if _G.KillerHubConnections then
    for _, conn in pairs(_G.KillerHubConnections) do
        pcall(function() conn:Disconnect() end)
    end
end
_G.KillerHubConnections = {}

local oldGui = game:GetService("CoreGui"):FindFirstChild("KillerHub_SheriffGui")
if oldGui then oldGui:Destroy() end

-- 2. CARGA SEGURA DE LIBRERÍA EXTERNA
local success, KillerHubLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Salayer09/KillerHub/refs/heads/main/Slayer.lua"))()
end)

if not success or not KillerHubLib then
    warn("⚠️ KillerHub Crítico: No se pudo cargar la interfaz de GitHub.")
    return
end
local KillerHub = KillerHubLib

-- 3. CONFIGURACIÓN PREDETERMINADA OPTIMIZADA
local SheriffConfig = {
    SilentAim = false,
    PredictionMode = "Híbrido Absoluto (Omni)", 
    HorizontalPredMin = 0.045, 
    HorizontalPredMax = 0.135, 
    VerticalPredMin = 0.008,   
    VerticalPredMax = 0.030,   
    WallCheck = true,    
    CloseRangeZone = 6, 
    AntiBaiting = true, 
    HitrateEnhancer = true,
    PredictTracer = true,      
    ShowMinPredictTracer = true, 
    ShowPingTracer = false,    
    ShowLagTracer = false,     
    ShowLeadTracer = true,    
    TracerSmoothness = 0.45, 
    UseWeaponDetector = false, 
    ShowShootButton = false,
    ButtonSize = 95,
    ButtonOpacity = 0.95, 
    ButtonLocked = false,
    ButtonX = 0.7, 
    ButtonY = 0.6,
    LeadTimePred = 0.05
}

-- 4. SISTEMA DE ARCHIVOS Y AUTO-GUARDADO
local HttpService = game:GetService("HttpService")
local CONFIG_FILE = "KillerHub_SheriffSuite.txt"

local function saveConfig()
    pcall(function()
        if writefile then
            local data = {
                SilentAim = SheriffConfig.SilentAim,
                WallCheck = SheriffConfig.WallCheck,
                ButtonX = SheriffConfig.ButtonX,
                ButtonY = SheriffConfig.ButtonY,
                PredictionMode = SheriffConfig.PredictionMode,
                HorizontalPredMin = SheriffConfig.HorizontalPredMin, 
                HorizontalPredMax = SheriffConfig.HorizontalPredMax,     
                VerticalPredMin = SheriffConfig.VerticalPredMin,
                VerticalPredMax = SheriffConfig.VerticalPredMax,
                LeadTimePred = SheriffConfig.LeadTimePred,
                TracerSmoothness = SheriffConfig.TracerSmoothness,
                UseWeaponDetector = SheriffConfig.UseWeaponDetector,
                ShowShootButton = SheriffConfig.ShowShootButton,
                PredictTracer = SheriffConfig.PredictTracer,
                ShowMinPredictTracer = SheriffConfig.ShowMinPredictTracer,
                ShowPingTracer = SheriffConfig.ShowPingTracer,
                ShowLagTracer = SheriffConfig.ShowLagTracer,
                ShowLeadTracer = SheriffConfig.ShowLeadTracer,
                CloseRangeZone = SheriffConfig.CloseRangeZone,
                AntiBaiting = SheriffConfig.AntiBaiting,
                HitrateEnhancer = SheriffConfig.HitrateEnhancer
            }
            writefile(CONFIG_FILE, HttpService:JSONEncode(data))
        end
    end)
end

local function loadConfig()
    pcall(function()
        if isfile and isfile(CONFIG_FILE) then
            local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
            if data then
                SheriffConfig.ButtonX = data.ButtonX or SheriffConfig.ButtonX
                SheriffConfig.ButtonY = data.ButtonY or SheriffConfig.ButtonY
                SheriffConfig.PredictionMode = data.PredictionMode or SheriffConfig.PredictionMode
                SheriffConfig.HorizontalPredMin = data.HorizontalPredMin or SheriffConfig.HorizontalPredMin
                SheriffConfig.HorizontalPredMax = data.HorizontalPredMax or SheriffConfig.HorizontalPredMax
                SheriffConfig.VerticalPredMin = data.VerticalPredMin or SheriffConfig.VerticalPredMin
                SheriffConfig.VerticalPredMax = data.VerticalPredMax or SheriffConfig.VerticalPredMax
                SheriffConfig.LeadTimePred = data.LeadTimePred or SheriffConfig.LeadTimePred
                SheriffConfig.TracerSmoothness = data.TracerSmoothness or SheriffConfig.TracerSmoothness
                SheriffConfig.CloseRangeZone = data.CloseRangeZone or SheriffConfig.CloseRangeZone
                if data.SilentAim ~= nil then SheriffConfig.SilentAim = data.SilentAim end
                if data.WallCheck ~= nil then SheriffConfig.WallCheck = data.WallCheck end
                if data.UseWeaponDetector ~= nil then SheriffConfig.UseWeaponDetector = data.UseWeaponDetector end
                if data.ShowShootButton ~= nil then SheriffConfig.ShowShootButton = data.ShowShootButton end
                if data.PredictTracer ~= nil then SheriffConfig.PredictTracer = data.PredictTracer end
                if data.ShowMinPredictTracer ~= nil then SheriffConfig.ShowMinPredictTracer = data.ShowMinPredictTracer end
                if data.ShowLeadTracer ~= nil then SheriffConfig.ShowLeadTracer = data.ShowLeadTracer end
                if data.ShowPingTracer ~= nil then SheriffConfig.ShowPingTracer = data.ShowPingTracer end
                if data.ShowLagTracer ~= nil then SheriffConfig.ShowLagTracer = data.ShowLagTracer end
                if data.AntiBaiting ~= nil then SheriffConfig.AntiBaiting = data.AntiBaiting end
                if data.HitrateEnhancer ~= nil then SheriffConfig.HitrateEnhancer = data.HitrateEnhancer end
            end
        end
    end)
end

loadConfig()

-- 🔍 DETECTOR DINÁMICO DE ARMAS
local function isRangedWeapon(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if tool:FindFirstChild("Shoot") or tool.Name == "Gun" or tool.Name == "Revolver" then
        return true
    end
    return false
end

local function isMeleeWeapon(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if tool:FindFirstChild("Stab") or tool.Name == "Knife" then
        return true
    end
    return false
end

local cachedScreenGui
local cachedShootButton

local function checkWeaponVisibility()
    if not cachedScreenGui then return end
    if not SheriffConfig.ShowShootButton then
        cachedScreenGui.Enabled = false
        return
    end
    if SheriffConfig.UseWeaponDetector then
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

-- 5. CONSTRUCCIÓN DE INTERFAZ GRÁFICA
local SheriffTab = KillerHub:CreateTab("Sheriff", "rbxassetid://10747373142")

SheriffTab:CreateSection("Ajustes del Silent Aim")

SheriffTab:CreateToggle("SheriffSilent", "Activar Silent Aim Pasivo", function(estado)
    SheriffConfig.SilentAim = estado
    saveConfig()
end)

SheriffTab:CreateToggle("HitrateEnhancerToggle", "Optimizar Balística Predictiva", function(estado)
    SheriffConfig.HitrateEnhancer = estado
    saveConfig()
end)

SheriffTab:CreateToggle("SheriffWallCheckToggle", "Verificar Paredes (Wall Check Inteligente)", function(estado)
    SheriffConfig.WallCheck = estado
    saveConfig()
end)

SheriffTab:CreateToggle("AntiBaitingToggle", "Filtro Anti-Amague (Anti-Baiting)", function(estado)
    SheriffConfig.AntiBaiting = estado
    saveConfig()
end)

SheriffTab:CreateDropdown("PredMode", "Modo de Predicción:", {"Híbrido Absoluto (Omni)", "Predictiva 2.0 (Aceleración)", "Predictivo Adaptativo"}, function(seleccionado)
    SheriffConfig.PredictionMode = seleccionado
    saveConfig()
end)

SheriffTab:CreateSlider("HorizontalPredMinSlider", "Predicción Horizontal MÍNIMA", 0, 250, function(valor)
    SheriffConfig.HorizontalPredMin = valor / 1000 
    saveConfig() 
end, math_floor(SheriffConfig.HorizontalPredMin * 1000))

SheriffTab:CreateSlider("HorizontalPredMaxSlider", "Predicción Horizontal MÁXIMA", 0, 300, function(valor)
    SheriffConfig.HorizontalPredMax = valor / 1000 
    saveConfig() 
end, math_floor(SheriffConfig.HorizontalPredMax * 1000))

SheriffTab:CreateSlider("VerticalPredMinSlider", "Predicción Vertical MÍNIMA", 0, 90, function(valor)
    SheriffConfig.VerticalPredMin = valor / 1000
    saveConfig() 
end, math_floor(SheriffConfig.VerticalPredMin * 1000))

SheriffTab:CreateSlider("VerticalPredMaxSlider", "Predicción Vertical MÁXIMA", 0, 120, function(valor)
    SheriffConfig.VerticalPredMax = valor / 1000
    saveConfig() 
end, math_floor(SheriffConfig.VerticalPredMax * 1000))

SheriffTab:CreateSlider("CloseRangeZoneSlider", "Zona Muerta Quemarropa (Studs)", 0, 20, function(valor)
    SheriffConfig.CloseRangeZone = valor
    saveConfig()
end, SheriffConfig.CloseRangeZone)

SheriffTab:CreateSection("Líneas de Trayectoria")

SheriffTab:CreateMultiDropdown("ActiveTracers", "Seleccionar Tracers Activos:", {
    "Impacto Final (Rojo)", 
    "Predicción Mínima (Amarillo)",
    "Ping (Azul)", 
    "Lag (Violeta)", 
    "Lead (Verde)"
}, function(tablaFlags)
    SheriffConfig.PredictTracer = tablaFlags["Impacto Final (Rojo)"]
    SheriffConfig.ShowMinPredictTracer = tablaFlags["Predicción Mínima (Amarillo)"]
    SheriffConfig.ShowPingTracer = tablaFlags["Ping (Azul)"]
    SheriffConfig.ShowLagTracer = tablaFlags["Lag (Violeta)"]
    SheriffConfig.ShowLeadTracer = tablaFlags["Lead (Verde)"]
    saveConfig()
end)

SheriffTab:CreateSlider("TracerSmoothSlider", "Estabilizador Anti-Temblor (1 = Instantáneo)", 1, 100, function(valor)
    if valor == 1 then
        SheriffConfig.TracerSmoothness = 1 
    else
        SheriffConfig.TracerSmoothness = 0.95 - ((valor - 2) / 98) * 0.80
    end
    saveConfig()
end, 40)

SheriffTab:CreateSlider("LeadTimeSlider", "Anticipación de la Mano (Lead Time)", 0, 100, function(valor)
    SheriffConfig.LeadTimePred = valor / 100
    saveConfig()
end, math_floor(SheriffConfig.LeadTimePred * 100))

SheriffTab:CreateSection("Ajustes de Interfaz / Tácticas")

SheriffTab:CreateToggle("WeaponDetectToggle", "Ocultar Botón si no tengo Arma en Inventario", function(estado)
    SheriffConfig.UseWeaponDetector = estado
    saveConfig()
    checkWeaponVisibility()
end)

SheriffTab:CreateToggle("ShowVoidButton", "Mostrar Botón en Pantalla", function(estado)
    SheriffConfig.ShowShootButton = estado
    saveConfig()
    checkWeaponVisibility()
end)

SheriffTab:CreateSlider("VoidBtnSize", "Tamaño del Botón Sheriff", 50, 200, function(valor)
    SheriffConfig.ButtonSize = valor
    if cachedShootButton then 
        cachedShootButton.Size = udim2New(0, valor, 0, valor) 
        if cachedShootButton:FindFirstChild("UICorner") then 
            cachedShootButton.UICorner.CornerRadius = UDim.new(0, math_floor(valor * 0.28)) 
        end
    end
end, SheriffConfig.ButtonSize)

-- ============================================================================
-- 🧠 HISTORIAL DE DATOS Y ENLACES DE RED
-- ============================================================================
local MurdererDetectado = nil
local lastMurdererCheckTime = 0 -- Control de throttling para CPU

local previousTargetVelocity = VECTOR_ZERO 
local smoothedVelocity = VECTOR_ZERO
local lastRawVelocity = VECTOR_ZERO 
local lastTargetChar = nil
local lastDeltaTime = 0.016
local emaDeltaTime = 0.016 

local pingHistory = {}
local maxPingHistorySize = 12
local cachedPingValue = 0.06

local playerRoles = {}
local playerDeadStatus = {}

local currentTarget = nil
local isFiringCooldown = false

local function getSmoothedPing(rawPing)
    table.insert(pingHistory, rawPing)
    if #pingHistory > maxPingHistorySize then table.remove(pingHistory, 1) end
    local sum = 0
    local maxRecentPing = 0
    local size = #pingHistory
    for i = 1, size do
        local p = pingHistory[i]
        sum = sum + p
        if p > maxRecentPing then maxRecentPing = p end
    end
    return ( (sum / size) * 0.65 ) + (maxRecentPing * 0.35)
end

task.spawn(function()
    while task.wait(0.5) do
        if Stats and Stats:FindFirstChild("Network") and Stats.Network:FindFirstChild("ServerToClientPing") then
            cachedPingValue = getSmoothedPing(Stats.Network.ServerToClientPing:GetValue() / 1000)
        end
    end
end)

local function setTarget(newTarget)
    currentTarget = newTarget
end

local function parsePlayerData(tabla)
    if type(tabla) == "table" then
        for name, data in pairs(tabla) do
            if type(data) == "table" then
                if data.Role then playerRoles[name] = data.Role end
                if data.Dead ~= nil then playerDeadStatus[name] = data.Dead end
            end
        end
    end
end

local PlayerDataChanged = ReplicatedStorage:FindFirstChild("PlayerDataChanged", true)
if PlayerDataChanged and PlayerDataChanged:IsA("RemoteEvent") then
    local c = PlayerDataChanged.OnClientEvent:Connect(parsePlayerData)
    table.insert(_G.KillerHubConnections, c)
end

local RoundStart = ReplicatedStorage:FindFirstChild("RoundStart", true)
if RoundStart and RoundStart:IsA("RemoteEvent") then
    local c = RoundStart.OnClientEvent:Connect(function(arg1, arg2)
        table.clear(playerRoles)
        table.clear(playerDeadStatus)
        MurdererDetectado = nil 
        parsePlayerData(arg2)
        parsePlayerData(arg1)
    end)
    table.insert(_G.KillerHubConnections, c)
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
    if char then
        for _, item in pairs(char:GetChildren()) do
            if isRangedWeapon(item) then return item, char end
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, item in pairs(bp:GetChildren()) do
            if isRangedWeapon(item) then return item, bp end
        end
    end
    return nil, nil
end

-- 👑 FUNCIÓN GETMURDERER TOTALMENTE OPTIMIZADA (THROTTLED)
local function getMurderer()
    local currentTime = os_clock()
    
    -- Si ya tenemos un Murderer válido detectado, validamos su estado sin volver a escanear a todo el servidor
    if MurdererDetectado and MurdererDetectado.Parent and MurdererDetectado.Character then
        local name = MurdererDetectado.Name
        local char = MurdererDetectado.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local isDead = (hum and hum.Health <= 0) or (playerDeadStatus[name] == true)
        
        if not isDead and playerRoles[name] == "Murderer" then
            setTarget(MurdererDetectado)
            return MurdererDetectado
        else
            MurdererDetectado = nil 
        end
    end

    -- Control de tiempo: Solo escanea la lista completa de jugadores cada 0.1 segundos (Saves 90% CPU)
    if currentTime - lastMurdererCheckTime < 0.10 then
        return currentTarget
    end
    lastMurdererCheckTime = currentTime

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

    local potentialMurderer = nil
    local allPlayers = Players:GetPlayers()
    local playerSize = #allPlayers
    
    for i = 1, playerSize do
        local player = allPlayers[i]
        if player ~= LocalPlayer and player.Parent ~= nil then
            local name = player.Name
            local char = player.Character
            if char then
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
    end

    if potentialMurderer then
        MurdererDetectado = potentialMurderer 
        setTarget(potentialMurderer)
    else
        setTarget(nil)
    end
    return currentTarget
end

local mapCastParams = RaycastParams.new()
mapCastParams.FilterType = Enum.RaycastFilterType.Exclude

-- RECOLECTOR DE BASURA SOLUCIONADO: Reutilización de ignoreList
local function getSmartTargetPart(targetChar)
    if not targetChar then return nil end
    local torso = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso")
    if not SheriffConfig.WallCheck then return torso end

    local origin = Camera.CFrame.Position
    
    table.clear(ignoreList)
    table.insert(ignoreList, LocalPlayer.Character)
    table.insert(ignoreList, Camera)
    
    local allPlayers = Players:GetPlayers()
    local size = #allPlayers
    for i = 1, size do
        local p = allPlayers[i]
        if p.Character then table.insert(ignoreList, p.Character) end
    end
    
    local pets = workspace:FindFirstChild("Pets") or workspace:FindFirstChild("PetFolder")
    if pets then table.insert(ignoreList, pets) end
    
    mapCastParams.FilterDescendantsInstances = ignoreList
    
    if torso then
        local direction = torso.Position - origin
        local ray = workspace:Raycast(origin, direction, mapCastParams)
        if not ray or (ray.Instance.CanCollide == false or ray.Instance.Transparency >= 0.85) then
            return torso
       end
    end
    local head = targetChar:FindFirstChild("Head")
    if head then
        local direction = head.Position - origin
        local ray = workspace:Raycast(origin, direction, mapCastParams)
        if not ray or (ray.Instance.CanCollide == false or ray.Instance.Transparency >= 0.85) then
            return head
        end
    end
    return nil 
end

local function getFloorHeight(targetHrp, targetChar)
    if not targetHrp then return nil end
    floorCastParams.FilterDescendantsInstances = {targetChar, LocalPlayer.Character, Camera}
    local ray = workspace:Raycast(targetHrp.Position, vec3New(0, -25, 0), floorCastParams)
    return ray and ray.Position.Y or nil
end

-- ============================================================================
-- 📈 MOTOR DE BALÍSTICA ADAPTATIVA ANTIOVERSHOOT (PERFECT PRECISION)
-- ============================================================================
local function getPredictedPosition(targetChar, targetPart, customDelta)
    if not targetChar or not targetPart then return nil, nil, nil, nil end
    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not humanoid or humanoid.Health <= 0 or not localHrp then return nil, nil, nil, nil end

    local activeDT = customDelta or emaDeltaTime
    local targetPosition = targetPart.Position
    local rawVelocity = hrp.AssemblyLinearVelocity
    local distance = (targetPosition - localHrp.Position).Magnitude

    local currentRawSpeed = rawVelocity.Magnitude
    if currentRawSpeed < 0.6 then -- Si apenas se mueve, matamos la predicción por completo para que no tironee
        rawVelocity = VECTOR_ZERO
        currentRawSpeed = 0
    end

    local predictionWeight = 1
    local minZone = SheriffConfig.CloseRangeZone
    local maxZone = minZone + 12
    if distance <= minZone then
        predictionWeight = 0 
    elseif distance < maxZone and minZone ~= maxZone then
        predictionWeight = (distance - minZone) / (maxZone - minZone) 
    end

    if lastTargetChar ~= targetChar then
        smoothedVelocity = rawVelocity
        previousTargetVelocity = smoothedVelocity
        lastRawVelocity = rawVelocity
        lastTargetChar = targetChar
    end

    local maxExpectedSpeed = math_max(humanoid.WalkSpeed * 2.0, 36)
    if currentRawSpeed > maxExpectedSpeed then 
        rawVelocity = rawVelocity.Unit * maxExpectedSpeed 
    end

    local dotProduct = 1
    if lastRawVelocity.Magnitude > 0.5 and rawVelocity.Magnitude > 0.5 then
        dotProduct = rawVelocity.Unit:Dot(lastRawVelocity.Unit)
    end
    lastRawVelocity = rawVelocity 

    -- ⚡ FILTRO ANTI-AMAGUE TOTAL: Evita que la mira se desfase cuando el jugador frena o cambia de dirección
    local baitingFactor = 1
    local stableAcceleration = VECTOR_ZERO
    
    local clampedDT = math_min(activeDT, 0.05) 
    local isLowFPS = activeDT > 0.033
    
    if dotProduct < 0.70 then
        -- Si cambió radicalmente de dirección (giro brusco), destruimos la aceleración residual y bajamos la velocidad base
        stableAcceleration = VECTOR_ZERO
        if SheriffConfig.AntiBaiting then
            baitingFactor = math_clamp((dotProduct + 1) / 3.0, 0.0, 0.20) -- Reducción masiva para evitar sobre-predicción
        end
    else
        local rawAcceleration = (rawVelocity - previousTargetVelocity) / math_max(clampedDT, 0.001)
        if rawAcceleration.Magnitude > 45 then rawAcceleration = rawAcceleration.Unit * 45 end
        stableAcceleration = vec3New(rawAcceleration.X, rawAcceleration.Y * (isLowFPS and 0.01 or 0.03), rawAcceleration.Z)
    end

    local responseSpeed = isLowFPS and 12.0 or 16.5
    local adaptiveWeight = math_clamp(1 - math_exp(-responseSpeed * clampedDT), 0.10, 0.85)
    smoothedVelocity = smoothedVelocity:Lerp(rawVelocity * baitingFactor, adaptiveWeight)

    local currentVelocityMagnitude = smoothedVelocity.Magnitude
    local speedFactor = math_clamp(currentVelocityMagnitude / 16.0, 0, 1.3)
    
    local fpsBuffer = isLowFPS and 0.028 or 0.018
    local ping = math_clamp(cachedPingValue, 0.01, 0.4) + fpsBuffer 
    local distanceFactor = math_clamp(distance / 24, 0.05, 1.10)
    
    local hFactorMax = math_min((SheriffConfig.HorizontalPredMax * 1.05) * speedFactor, SheriffConfig.HorizontalPredMax * 1.3)
    local hFactorMin = math_min((SheriffConfig.HorizontalPredMin * 1.05) * speedFactor, SheriffConfig.HorizontalPredMin)

    local timeFrameTotal = hFactorMax * (ping * 9.5) * distanceFactor * predictionWeight
    local timeFrameMin = hFactorMin * (ping * 9.5) * distanceFactor * predictionWeight
    local timeFramePingOnly = cachedPingValue * distanceFactor * predictionWeight
    local timeFrameLagOnly = clampedDT * distanceFactor * predictionWeight

    local finalHorizontal = VECTOR_ZERO
    local minHorizontal = VECTOR_ZERO
    local pingHorizontal = VECTOR_ZERO
    local lagHorizontal = VECTOR_ZERO

    local dotClamp = math_clamp(dotProduct, 0.5, 1.0)

    if SheriffConfig.PredictionMode == "Híbrido Absoluto (Omni)" then
        finalHorizontal = (smoothedVelocity * timeFrameTotal):Lerp(smoothedVelocity * (timeFrameTotal * dotClamp), 0.25)
        minHorizontal = (smoothedVelocity * timeFrameMin):Lerp(smoothedVelocity * (timeFrameMin * dotClamp), 0.25)
        pingHorizontal = (smoothedVelocity * timeFramePingOnly):Lerp(smoothedVelocity * (timeFramePingOnly * dotClamp), 0.25)
        lagHorizontal = (smoothedVelocity * timeFrameLagOnly):Lerp(smoothedVelocity * (timeFrameLagOnly * dotClamp), 0.25)
        
        if distance >= 12 and dotProduct >= 0.80 and currentVelocityMagnitude > 5 and stableAcceleration.Magnitude > 0 then 
            local extraAcc = 0.45 * stableAcceleration
            finalHorizontal = finalHorizontal + (extraAcc * (timeFrameTotal ^ 2))
            minHorizontal = minHorizontal + (extraAcc * (timeFrameMin ^ 2))
         end
    elseif SheriffConfig.PredictionMode == "Predictiva 2.0 (Aceleración)" then
        local accCalc = (dotProduct >= 0.80 and currentVelocityMagnitude > 5) and (0.45 * stableAcceleration) or VECTOR_ZERO
        finalHorizontal = (smoothedVelocity * timeFrameTotal) + (accCalc * (timeFrameTotal ^ 2))
        minHorizontal = (smoothedVelocity * timeFrameMin) + (accCalc * (timeFrameMin ^ 2))
        pingHorizontal = (smoothedVelocity * timeFramePingOnly) + (accCalc * (timeFramePingOnly ^ 2))
        lagHorizontal = (smoothedVelocity * timeFrameLagOnly) + (accCalc * (timeFrameLagOnly ^ 2))
    elseif SheriffConfig.PredictionMode == "Predictivo Adaptativo" then
        local dMod = (dotProduct < 0.85 and math_clamp(dotProduct, 0.3, 1.0) or 1)
        local flatVel = vec3New(smoothedVelocity.X, 0, smoothedVelocity.Z)
        finalHorizontal = flatVel * (timeFrameTotal * dMod)
        minHorizontal = flatVel * (timeFrameMin * dMod)
        pingHorizontal = flatVel * (timeFramePingOnly * dMod)
        lagHorizontal = flatVel * (timeFrameLagOnly * dMod)
    end

    local maxHorizontalShift = 3.5 -- Cap estricto en studs para que jamás se descuadre de más
    if finalHorizontal.Magnitude > maxHorizontalShift then finalHorizontal = finalHorizontal.Unit * maxHorizontalShift end
    if minHorizontal.Magnitude > maxHorizontalShift then minHorizontal = minHorizontal.Unit * maxHorizontalShift end
    
    local verticalOffsetMax = VECTOR_ZERO
    local verticalOffsetMin = VECTOR_ZERO
    local verticalSpeed = math_abs(smoothedVelocity.Y)
    
    if humanoid.FloorMaterial == Enum.Material.Air or verticalSpeed > 0.4 then
        local vSpeedScale = math_clamp(verticalSpeed / 45, 0, 1.1)
        local finalVFactorMax = math_min(ping * SheriffConfig.VerticalPredMax * predictionWeight * vSpeedScale, ping * SheriffConfig.VerticalPredMax * predictionWeight)
        local finalVFactorMin = math_min(ping * SheriffConfig.VerticalPredMin * predictionWeight * vSpeedScale, ping * SheriffConfig.VerticalPredMin * predictionWeight)
        
        local pYMax = (smoothedVelocity.Y * finalVFactorMax) - (0.5 * workspace_Gravity * (finalVFactorMax ^ 2))
        local pYMin = (smoothedVelocity.Y * finalVFactorMin) - (0.5 * workspace_Gravity * (finalVFactorMin ^ 2))
        if smoothedVelocity.Y > 1 then
            local jumpBonus = smoothedVelocity.Y * 0.006 * predictionWeight
            pYMax = pYMax + jumpBonus
            pYMin = pYMin + jumpBonus
         end
        verticalOffsetMax = vec3New(0, pYMax, 0)
        verticalOffsetMin = vec3New(0, pYMin, 0)
    end

    local finalPrediction = targetPosition + vec3New(finalHorizontal.X, 0, finalHorizontal.Z) + verticalOffsetMax
    local minPrediction = targetPosition + vec3New(minHorizontal.X, 0, minHorizontal.Z) + verticalOffsetMin
    local pingPrediction = targetPosition + vec3New(pingHorizontal.X, 0, pingHorizontal.Z) + verticalOffsetMax
    local lagPrediction = targetPosition + vec3New(lagHorizontal.X, 0, lagHorizontal.Z) + verticalOffsetMax

    local floorY = getFloorHeight(hrp, targetChar)
    if floorY then
        local bodyScale = humanoid:FindFirstChild("BodyHeightScale") and math_clamp(humanoid.BodyHeightScale.Value, 0.2, 1.5) or 1
        local minAllowedY = floorY + ((hrp.Size.Y / 2) * bodyScale) + 0.15
        if finalPrediction.Y < minAllowedY then finalPrediction = vec3New(finalPrediction.X, minAllowedY, finalPrediction.Z) end
        if minPrediction.Y < minAllowedY then minPrediction = vec3New(minPrediction.X, minAllowedY, minPrediction.Z) end
    end

    previousTargetVelocity = rawVelocity
    return finalPrediction, minPrediction, pingPrediction, lagPrediction
end

-- ============================================================================
-- 🌌 GESTIÓN Y RENDERIZADO DE TRACERS
-- ============================================================================
local LagLine = Drawing.new("Line") 
LagLine.Color = color3RGB(150, 50, 255) 
LagLine.Thickness = 1.1
LagLine.ZIndex = 2  
table.insert(_G.KillerHubLines, LagLine)

local PingLine = Drawing.new("Line")
PingLine.Color = color3RGB(0, 100, 255) 
PingLine.Thickness = 1.1
PingLine.ZIndex = 3  
table.insert(_G.KillerHubLines, PingLine)

local LeadLine = Drawing.new("Line")
LeadLine.Color = color3RGB(0, 255, 100) 
LeadLine.Thickness = 1.1
LeadLine.ZIndex = 4  
table.insert(_G.KillerHubLines, LeadLine)

local MinPredictionLine = Drawing.new("Line")
MinPredictionLine.Color = color3RGB(255, 235, 35) 
MinPredictionLine.Thickness = 1.3 
MinPredictionLine.ZIndex = 5  
table.insert(_G.KillerHubLines, MinPredictionLine)

local PredictionLine = Drawing.new("Line")
PredictionLine.Color = color3RGB(255, 35, 35) 
PredictionLine.Thickness = 1.5 
PredictionLine.ZIndex = 6  
table.insert(_G.KillerHubLines, PredictionLine)

local currentScreenPred = vec2New(0,0)
local currentScreenMinPred = vec2New(0,0)
local currentScreenPing = vec2New(0,0)
local currentScreenLag = vec2New(0,0)
local currentScreenLead = vec2New(0,0)
local firstFrame = true

local renderConn = RunService.RenderStepped:Connect(function(dt)
    lastDeltaTime = dt 
    emaDeltaTime = emaDeltaTime + 0.2 * (dt - emaDeltaTime) 
    
    checkWeaponVisibility()

    local murderer = getMurderer()

    if not murderer or not murderer.Character then
        PredictionLine.Visible = false; MinPredictionLine.Visible = false; PingLine.Visible = false; LagLine.Visible = false; LeadLine.Visible = false;
        firstFrame = true
        return
    end

    local targetChar = murderer.Character
    local localChar = LocalPlayer.Character
    local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")
    local visualPart = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head")

    if visualPart and localHrp then
        local distance = (visualPart.Position - localHrp.Position).Magnitude
        local distFactor = math_clamp((distance - 4) / 16, 0, 1)
        local tSmooth = SheriffConfig.TracerSmoothness
     
        local predictedPos, minPredictedPos, pingPos, lagPos = getPredictedPosition(targetChar, visualPart)
        local screenOrigin = vec2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

        if lagPos and SheriffConfig.ShowLagTracer then
            local screenPos, onScreen = Camera:WorldToViewportPoint(lagPos)
            if onScreen then
                local target2D = vec2New(screenPos.X, screenPos.Y)
                 currentScreenLag = (firstFrame or tSmooth == 1) and target2D or currentScreenLag:Lerp(target2D, tSmooth)
                LagLine.From = screenOrigin
                LagLine.To = currentScreenLag
                LagLine.Visible = true
            else LagLine.Visible = false end
        else LagLine.Visible = false end

        if pingPos and SheriffConfig.ShowPingTracer then
            local screenPos, onScreen = Camera:WorldToViewportPoint(pingPos)
            if onScreen then
                local target2D = vec2New(screenPos.X, screenPos.Y)
                currentScreenPing = (firstFrame or tSmooth == 1) and target2D or currentScreenPing:Lerp(target2D, tSmooth)
                 PingLine.From = screenOrigin
                PingLine.To = currentScreenPing
                PingLine.Visible = true
            else PingLine.Visible = false end
        else PingLine.Visible = false end

        local hand = localChar and (localChar:FindFirstChild("RightHand") or localChar:FindFirstChild("Right Arm"))
        if SheriffConfig.ShowLeadTracer and hand then
            local balancedVelocity = vec3New(smoothedVelocity.X, smoothedVelocity.Y * 0.5, smoothedVelocity.Z)
            local leadPredictedPos = visualPart.Position + (balancedVelocity * SheriffConfig.LeadTimePred * distFactor)
            local handScreenPos, handOnScreen = Camera:WorldToViewportPoint(hand.Position)
            local targetScreenPos, targetOnScreen = Camera:WorldToViewportPoint(leadPredictedPos)
            if handOnScreen and targetOnScreen then
                 local target2D = vec2New(targetScreenPos.X, targetScreenPos.Y)
                currentScreenLead = (firstFrame or tSmooth == 1) and target2D or currentScreenLead:Lerp(target2D, tSmooth)
                LeadLine.From = vec2New(handScreenPos.X, handScreenPos.Y)
                LeadLine.To = currentScreenLead
                LeadLine.Visible = true
             else LeadLine.Visible = false end
        else LeadLine.Visible = false end

        if minPredictedPos and SheriffConfig.ShowMinPredictTracer then
            local screenPos, onScreen = Camera:WorldToViewportPoint(minPredictedPos)
            if onScreen then
                local target2D = vec2New(screenPos.X, screenPos.Y)
                 currentScreenMinPred = (firstFrame or tSmooth == 1) and target2D or currentScreenMinPred:Lerp(target2D, tSmooth)
                MinPredictionLine.From = screenOrigin
                MinPredictionLine.To = currentScreenMinPred
                MinPredictionLine.Visible = true
            else MinPredictionLine.Visible = false end
        else MinPredictionLine.Visible = false end

         if predictedPos and SheriffConfig.PredictTracer then
            local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
            if onScreen then
                local target2D = vec2New(screenPos.X, screenPos.Y)
                currentScreenPred = (firstFrame or tSmooth == 1) and target2D or currentScreenPred:Lerp(target2D, tSmooth)
                PredictionLine.From = screenOrigin
                PredictionLine.To = currentScreenPred
                PredictionLine.Visible = true
            else PredictionLine.Visible = false end
        else PredictionLine.Visible = false end
        
        firstFrame = false
    else
        PredictionLine.Visible = false; MinPredictionLine.Visible = false; PingLine.Visible = false; LagLine.Visible = false; LeadLine.Visible = false;
        firstFrame = true
    end 
end)
table.insert(_G.KillerHubConnections, renderConn)

-- ============================================================================
-- ⚡ EJECUCIÓN MANUAL DISPARO DISPARADOR (BOTÓN)
-- ============================================================================
local function fireAtMurdererDirectly()
    if isFiringCooldown then return end 
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not hrp then return end 

    local murderer = getMurderer()
    if murderer and murderer.Character then
        local targetChar = murderer.Character
        local bestPart = getSmartTargetPart(targetChar) 
        if bestPart then 
            local predictedPos = getPredictedPosition(targetChar, bestPart)
            if predictedPos then
                isFiringCooldown = true 
                autoEquipWeapon()
                local gun, _ = getGunLocation()
                if gun then
                    local shootRemote = gun:FindFirstChild("Shoot")
                    if shootRemote then
                        local originCFrame = hrp.CFrame
                        if hrp:FindFirstChild("GunRaycastAttachment") then 
                            originCFrame = hrp.GunRaycastAttachment.WorldCFrame 
                        end
                        shootRemote:FireServer(originCFrame, cframeNew(predictedPos))
                    end
                end
                task.wait(0.04) 
                isFiringCooldown = false
            end
        end
     end
end

-- ============================================================================
-- 🌌 CREACIÓN DEL INTERRUPTOR FLOTANTE (BOTÓN SHOOT)
-- ============================================================================
local VoidGui = Instance.new("ScreenGui")
VoidGui.Name = "KillerHub_SheriffGui"
VoidGui.ResetOnSpawn = false
VoidGui.Parent = game:GetService("CoreGui")

local ShootButton = Instance.new("ImageButton")
ShootButton.Name = "ShootButton"
ShootButton.Size = udim2New(0, SheriffConfig.ButtonSize, 0, SheriffConfig.ButtonSize)
ShootButton.Position = udim2New(SheriffConfig.ButtonX, 0, SheriffConfig.ButtonY, 0)
ShootButton.BackgroundColor3 = color3RGB(15, 6, 26)
ShootButton.BackgroundTransparency = 1 - SheriffConfig.ButtonOpacity
ShootButton.BorderSizePixel = 0  
ShootButton.AutoButtonColor = false 
ShootButton.ClipsDescendants = true 
ShootButton.Parent = VoidGui

cachedScreenGui = VoidGui
cachedShootButton = ShootButton

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, math_floor(SheriffConfig.ButtonSize * 0.28))
Corner.Parent = ShootButton

local GlowOverlay = Instance.new("Frame")
GlowOverlay.Name = "GlowOverlay"
GlowOverlay.Size = udim2New(1, 0, 1, 0)
GlowOverlay.Position = udim2New(0, 0, 0, 0)
GlowOverlay.BackgroundTransparency = 1
GlowOverlay.ZIndex = ShootButton.ZIndex + 1
GlowOverlay.Parent = ShootButton

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = Corner.CornerRadius
GlowCorner.Parent = GlowOverlay

local UiGradient = Instance.new("UIGradient")
UiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, color3RGB(24, 8, 43)),    
    ColorSequenceKeypoint.new(0.5, color3RGB(131, 46, 222)),  
    ColorSequenceKeypoint.new(1, color3RGB(24, 8, 43))
})
UiGradient.Rotation = 45 
UiGradient.Parent = GlowOverlay

local DecalTexture = Instance.new("ImageLabel")
DecalTexture.Name = "DecalTexture"
DecalTexture.Size = udim2New(0.38, 0, 0.38, 0)
DecalTexture.AnchorPoint = vec2New(0.5, 0.5)
DecalTexture.Position = udim2New(0.5, 0, 0.44, 0)
DecalTexture.BackgroundTransparency = 1
DecalTexture.Image = "rbxassetid://125754446555599"
DecalTexture.ImageTransparency =  1 - SheriffConfig.ButtonOpacity
DecalTexture.ZIndex = ShootButton.ZIndex + 2
DecalTexture.Parent = ShootButton

local function iniciarAnimacionIcono(decalTexture)
    if not decalTexture then return end
    local tiempoGiro = 0.8025     
    local tiempoQuieto = 0.0289 
     
    local infoGiro = TweenInfo.new(tiempoGiro, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tweenIda = TweenService:Create(decalTexture, infoGiro, {Rotation = 360})
    local tweenVuelta = TweenService:Create(decalTexture, infoGiro, {Rotation = 0})

    local cIda = tweenIda.Completed:Connect(function()
        task.wait(tiempoQuieto)
        tweenVuelta:Play()
    end)
    local cVuelta = tweenVuelta.Completed:Connect(function()
        task.wait(tiempoQuieto)
        tweenIda:Play()
    end)
    table.insert(_G.KillerHubConnections, cIda)
    table.insert(_G.KillerHubConnections, cVuelta)
      
    tweenIda:Play()
end

iniciarAnimacionIcono(DecalTexture)

local Label = Instance.new("TextLabel")
Label.Name = "Label"
Label.Size = udim2New(1, 0, 0.2, 0)
Label.Position = udim2New(0, 0, 0.75, 0)
Label.BackgroundTransparency = 1
Label.Text = "SHOOT"
Label.TextColor3 = color3RGB(255, 255, 255)
Label.TextSize = 15
Label.Font = Enum.Font.GothamBold
Label.TextTransparency = 1 - SheriffConfig.ButtonOpacity
Label.ZIndex = ShootButton.ZIndex + 2
Label.Parent = ShootButton

local function processGlowAtCoordinates(inputPosition)
    local buttonAbsolutePos = ShootButton.AbsolutePosition
    local buttonSize = ShootButton.AbsoluteSize
    local localX =  inputPosition.X - buttonAbsolutePos.X
    local relX = (localX / buttonSize.X) - 0.5
    UiGradient.Offset = vec2New(relX * 1.5, 0)
    TweenService:Create(GlowOverlay, TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.35}):Play()
end

local function fadeGlowReflection()
    TweenService:Create(GlowOverlay, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
end

local dragging, dragInput, dragStart, startPos
local cBegan = ShootButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        processGlowAtCoordinates(input.Position)
        task.spawn(fireAtMurdererDirectly)
        
        if not SheriffConfig.ButtonLocked then
            dragging = true
            dragStart = input.Position
             startPos = ShootButton.Position
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
     end
end)
table.insert(_G.KillerHubConnections, cBegan)

local cEnded = ShootButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fadeGlowReflection()
    end
end)
table.insert(_G.KillerHubConnections, cEnded)

local cChangedInput = ShootButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
table.insert(_G.KillerHubConnections, cChangedInput)

local cGlobalInputChanged = UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ShootButton.Position = udim2New(
              startPos.X.Scale + (delta.X / Camera.ViewportSize.X), 0, 
            startPos.Y.Scale + (delta.Y / Camera.ViewportSize.Y), 0
        )
    end
end)
table.insert(_G.KillerHubConnections, cGlobalInputChanged)

checkWeaponVisibility()

-- ============================================================================
-- ⚡ INTERCEPCIÓN HOOK DE ARMAS (SISTEMA ADAPTATIVO MODDED RECURSIVO)
-- ============================================================================
local WeaponService = nil

local ClientServices = ReplicatedStorage:FindFirstChild("ClientServices") or ReplicatedStorage:FindFirstChild("Services")
if ClientServices then
    local ws = ClientServices:FindFirstChild("WeaponService") or ClientServices:FindFirstChild("GunService")
    if ws and ws:IsA("ModuleScript") then
        pcall(function() WeaponService = require(ws) end)
    end
end

if not WeaponService then
    local descendants = ReplicatedStorage:GetDescendants()
    local descSize = #descendants
    for i = 1, descSize do
        local obj = descendants[i]
        if obj:IsA("ModuleScript") then
            local success, mod = pcall(require, obj)
            if success and type(mod) == "table" and (mod.GetTargetPosition or mod.GetMouseTargetCFrame) then
                WeaponService = mod
                break
            end
        end
    end
end

if WeaponService then
    local oldGetTargetPosition = WeaponService.GetTargetPosition
    local oldGetMouseTargetCFrame = WeaponService.GetMouseTargetCFrame
    local lastHookCallTime = os_clock()

    local function checkAndPredict(returnCFrame)
        local currentTime = os_clock()
        local hookDelta = currentTime - lastHookCallTime
        lastHookCallTime = currentTime
        local structuralDelta = math_clamp(hookDelta, 0.008, 0.033)

        local gun, _ = getGunLocation()
        if SheriffConfig.SilentAim and (not SheriffConfig.UseWeaponDetector or (gun ~= nil)) then
            local murderer = getMurderer()
            if murderer and murderer.Character then
                local targetChar = murderer.Character
                local bestPart = getSmartTargetPart(targetChar)
                if bestPart then
                    local predictedPos = getPredictedPosition(targetChar, bestPart, structuralDelta)
                     if predictedPos then 
                        return returnCFrame and cframeNew(predictedPos) or predictedPos 
                    end
                end
            end
        end
        return nil
    end

    if oldGetTargetPosition then
        WeaponService.GetTargetPosition = function(self, ...)
            local prediction = checkAndPredict(false) 
            return prediction or oldGetTargetPosition(self, ...)
        end
    end

    if oldGetMouseTargetCFrame then
        WeaponService.GetMouseTargetCFrame = function(self, ...)
            local prediction = checkAndPredict(true) 
            return prediction or oldGetMouseTargetCFrame(self, ...)
        end
    end
else
    warn("⚠️ KillerHub Crítico: No se pudo enlazar el Hook de Armas.")
end

return KillerHub
