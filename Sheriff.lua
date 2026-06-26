-- ============================================================================
--  👻 KILLER HUB | SHERIFF V7.3.0 PREMIUM [👑 EDICIÓN OPTIMIZADA HÍBRIDA]
-- ============================================================================

-- 1. LIMPIEZA TOTAL DE MEMORIA (Previene congelamientos y duplicación de hilos)
if _G.KillerHubLines then
    for _, line in _G.KillerHubLines do
        pcall(function() line:Remove() end)
    end
end
_G.KillerHubLines = {}

if _G.KillerHubConnections then
    for _, conn in _G.KillerHubConnections do
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

-- 3. INTERFAZ Y CONFIGURACIÓN
local SheriffTab = KillerHub:CreateTab("Sheriff", "rbxassetid://10747373142")

local SheriffConfig = {
    SilentAim = false,
    PredictionMode = "Híbrido Absoluto (Omni)", 
    HorizontalPred = 0.145, 
    VerticalPred = 0.035,   
    WallCheck = true,    
    CloseRangeZone = 8, 
    AntiBaiting = true, 
    HitrateEnhancer = true,
    PredictTracer = true,      
    ShowPingTracer = false,    
    ShowLagTracer = false,     
    ShowLeadTracer = true,     
    TracerSmoothness = 0.60, 
    UseWeaponDetector = false, 
    ShowShootButton = false,
    ButtonSize = 95,
    ButtonOpacity = 0.95, 
    ButtonLocked = false,
    ButtonX = 0.7, 
    ButtonY = 0.6,
    LeadTimePred = 0.05,
    AutoUnequip = true -- Restaurado para soportar las mecánicas de la v6
}

local HttpService = game:GetService("HttpService")
local CONFIG_FILE = "KillerHub_SheriffSuite.txt"

local function saveConfig()
    local pcallSuccess, err = pcall(function()
        if writefile then
            local data = {
                SilentAim = SheriffConfig.SilentAim,
                WallCheck = SheriffConfig.WallCheck,
                ButtonX = SheriffConfig.ButtonX,
                ButtonY = SheriffConfig.ButtonY,
                PredictionMode = SheriffConfig.PredictionMode,
                HorizontalPred = SheriffConfig.HorizontalPred, 
                VerticalPred = SheriffConfig.VerticalPred,     
                LeadTimePred = SheriffConfig.LeadTimePred,
                TracerSmoothness = SheriffConfig.TracerSmoothness,
                UseWeaponDetector = SheriffConfig.UseWeaponDetector,
                PredictTracer = SheriffConfig.PredictTracer,
                ShowLeadTracer = SheriffConfig.ShowLeadTracer,
                ShowPingTracer = SheriffConfig.ShowPingTracer,
                ShowLagTracer = SheriffConfig.ShowLagTracer,
                CloseRangeZone = SheriffConfig.CloseRangeZone,
                AntiBaiting = SheriffConfig.AntiBaiting,
                HitrateEnhancer = SheriffConfig.HitrateEnhancer,
                AutoUnequip = SheriffConfig.AutoUnequip
            }
            writefile(CONFIG_FILE, HttpService:JSONEncode(data))
        end
    end)
    if not pcallSuccess then
        warn("⚠️ KillerHub Info: No se pudo guardar la configuración: " .. tostring(err))
    end
end

local function loadConfig()
    local pcallSuccess, result = pcall(function()
        if isfile and isfile(CONFIG_FILE) then
            local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
            if data then
                SheriffConfig.ButtonX = data.ButtonX or SheriffConfig.ButtonX
                SheriffConfig.ButtonY = data.ButtonY or SheriffConfig.ButtonY
                SheriffConfig.PredictionMode = data.PredictionMode or SheriffConfig.PredictionMode
                SheriffConfig.HorizontalPred = data.HorizontalPred or SheriffConfig.HorizontalPred
                SheriffConfig.VerticalPred = data.VerticalPred or SheriffConfig.VerticalPred
                SheriffConfig.LeadTimePred = data.LeadTimePred or SheriffConfig.LeadTimePred
                SheriffConfig.TracerSmoothness = data.TracerSmoothness or SheriffConfig.TracerSmoothness
                SheriffConfig.CloseRangeZone = data.CloseRangeZone or SheriffConfig.CloseRangeZone
                
                if data.SilentAim ~= nil then SheriffConfig.SilentAim = data.SilentAim end
                if data.WallCheck ~= nil then SheriffConfig.WallCheck = data.WallCheck end
                if data.UseWeaponDetector ~= nil then SheriffConfig.UseWeaponDetector = data.UseWeaponDetector end
                if data.PredictTracer ~= nil then SheriffConfig.PredictTracer = data.PredictTracer end
                if data.ShowLeadTracer ~= nil then SheriffConfig.ShowLeadTracer = data.ShowLeadTracer end
                if data.ShowPingTracer ~= nil then SheriffConfig.ShowPingTracer = data.ShowPingTracer end
                if data.ShowLagTracer ~= nil then SheriffConfig.ShowLagTracer = data.ShowLagTracer end
                if data.AntiBaiting ~= nil then SheriffConfig.AntiBaiting = data.AntiBaiting end
                if data.HitrateEnhancer ~= nil then SheriffConfig.HitrateEnhancer = data.HitrateEnhancer end
                if data.AutoUnequip ~= nil then SheriffConfig.AutoUnequip = data.AutoUnequip end
                return true
            end
        end
        return false
    end)
    if not pcallSuccess then
        warn("Error al cargar la configuración: " .. tostring(result))
    end
end

loadConfig()

-- ============================================================================
-- ⚙️ INTERFAZ GRÁFICA CONTROLADA
-- ============================================================================
SheriffTab:CreateSection("Ajustes del Silent Aim")

SheriffTab:CreateToggle("SheriffSilent", "Activar Silent Aim Pasivo", function(estado)
    SheriffConfig.SilentAim = estado
    saveConfig()
end)

SheriffTab:CreateToggle("HitrateEnhancerToggle", "Optimizar Balística Predictiva", function(estado)
    SheriffConfig.HitrateEnhancer = estado
    saveConfig()
end)

SheriffTab:CreateToggle("SheriffWallCheckToggle", "Verificar Paredes (Híbrido Torso/Cabeza)", function(estado)
    SheriffConfig.WallCheck = estado
    saveConfig()
end)

SheriffTab:CreateToggle("AutoUnequipToggle", "Auto-Desequipar Arma (Fast Unequip)", function(estado)
    SheriffConfig.AutoUnequip = estado
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

SheriffTab:CreateSlider("HorizontalPredSlider", "Predicción Horizontal", 0, 300, function(valor)
    SheriffConfig.HorizontalPred = valor / 1000 
    saveConfig() 
end)

SheriffTab:CreateSlider("VerticalPredSlider", "Predicción Vertical (Suave)", 0, 120, function(valor)
    SheriffConfig.VerticalPred = valor / 1000
    saveConfig() 
end)

SheriffTab:CreateSlider("CloseRangeZoneSlider", "Zona Muerta Quemarropa (Studs)", 0, 20, function(valor)
    SheriffConfig.CloseRangeZone = valor
    saveConfig()
end)

SheriffTab:CreateSection("Líneas de Trayectoria")

SheriffTab:CreateMultiDropdown("ActiveTracers", "Seleccionar Tracers Activos:", {
    "Impacto Final (Rojo)", 
    "Ping (Azul)", 
    "Lag (Violeta)", 
    "Lead (Verde)"
}, function(tablaFlags)
    SheriffConfig.PredictTracer = tablaFlags["Impacto Final (Rojo)"]
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
end)

SheriffTab:CreateSlider("LeadTimeSlider", "Anticipación de la Mano (Lead Time)", 0, 100, function(valor)
    SheriffConfig.LeadTimePred = valor / 100
    saveConfig()
end)

SheriffTab:CreateSection("Ajustes de Interfaz / Tácticas")
SheriffTab:CreateToggle("WeaponDetectToggle", "Ocultar Botón si no tengo Arma en Inventario", function(estado)
    SheriffConfig.UseWeaponDetector = estado
    saveConfig()
end)

SheriffTab:CreateToggle("ShowVoidButton", "Mostrar Botón en Pantalla", function(estado)
    SheriffConfig.ShowShootButton = estado
end)

SheriffTab:CreateSlider("VoidBtnSize", "Tamaño del Botón Sheriff", 50, 200, function(valor)
    SheriffConfig.ButtonSize = valor
    local btn = game:GetService("CoreGui"):FindFirstChild("KillerHub_SheriffGui") and game:GetService("CoreGui").KillerHub_SheriffGui:FindFirstChild("ShootButton")
    if btn then 
        btn.Size = UDim2.new(0, valor, 0, valor) 
        if btn:FindFirstChild("UICorner") then btn.UICorner.CornerRadius = UDim.new(0, math.floor(valor * 0.28)) end
    end
end)

SheriffTab:CreateSlider("VoidBtnOpacity", "Opacidad del Botón", 10, 100, function(valor)
    SheriffConfig.ButtonOpacity = valor / 100
    local btn = game:GetService("CoreGui"):FindFirstChild("KillerHub_SheriffGui") and game:GetService("CoreGui").KillerHub_SheriffGui:FindFirstChild("ShootButton")
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
-- 🧠 SERVICIOS Y MOTOR DE CONFIGURACIÓN DE ENTORNO
-- ============================================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService") 
local Stats = game:GetService("Stats") 
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

local previousTargetVelocity = Vector3.new(0,0,0) 
local smoothedVelocity = Vector3.new(0,0,0)
local lastRawVelocity = Vector3.new(0,0,0) 
local lastTargetChar = nil
local lastDeltaTime = 0.016
local emaDeltaTime = 0.016 

local pingHistory = {}
local maxPingHistorySize = 12
local cachedPingValue = 0.06

local playerRoles = {}
local playerDeadStatus = {}
local currentTarget = nil
local lastTargetTime = 0
local isFiringCooldown = false

local function getSmoothedPing(rawPing)
    table.insert(pingHistory, rawPing)
    if #pingHistory > maxPingHistorySize then table.remove(pingHistory, 1) end
    local sum = 0
    local maxRecentPing = 0
    for _, p in pingHistory do
        sum = sum + p
        if p > maxRecentPing then maxRecentPing = p end
    end
    return ( (sum / #pingHistory) * 0.65 ) + (maxRecentPing * 0.35)
end

task.spawn(function()
    while task.wait(0.5) do
        if Stats and Stats:FindFirstChild("Network") and Stats.Network:FindFirstChild("ServerToClientPing") then
            cachedPingValue = getSmoothedPing(Stats.Network.ServerToClientPing:GetValue() / 1000)
        end
    end
end)

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
        parsePlayerData(arg2)
        parsePlayerData(arg1)
    end)
    table.insert(_G.KillerHubConnections, c)
end

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
    if currentTarget and currentTarget.Parent and currentTarget.Character then
        local name = currentTarget.Name
        local char = currentTarget.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local isDead = (hum and hum.Health <= 0) or (playerDeadStatus[name] == true)
        local hasKnife = char:FindFirstChild("Knife") or (currentTarget:FindFirstChild("Backpack") and currentTarget.Backpack:FindFirstChild("Knife"))
        
        if (playerRoles[name] == "Murderer" or hasKnife) and not isDead then
            lastTargetTime = os.clock() 
            return currentTarget
        end
    end

    for name, role in pairs(playerRoles) do
        if role == "Murderer" then
            local pl = Players:FindFirstChild(name)
            if pl and pl.Character and pl ~= LocalPlayer then
                local hum = pl.Character:FindFirstChildOfClass("Humanoid")
                if not ((hum and hum.Health <= 0) or (playerDeadStatus[name] == true)) then
                    currentTarget = pl
                    lastTargetTime = os.clock()
                    return pl
                end
            end
        end
    end

    local potentialMurderer = nil
    for _, player in Players:GetPlayers() do
        if player ~= LocalPlayer and player.Parent ~= nil then
            local name = player.Name
            local char = player.Character
            if char and char:FindFirstChild("Knife") then 
                playerRoles[name] = "Murderer"
                if not ((char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health <= 0) or (playerDeadStatus[name] == true)) then
                    potentialMurderer = player
                    break
                end
            end
        end
    end

    if potentialMurderer then
        currentTarget = potentialMurderer
        lastTargetTime = os.clock()
    else
        currentTarget = nil
    end
    return currentTarget
end

-- ============================================================================
-- 🚀 WALL CHECK INTEGRADO DE V6.7.2 + EXCLUSIÓN DE ACCESORIOS/MASCOTAS MEJORADA
-- ============================================================================
local function isTargetVisible(targetPart, murdererChar)
    if not SheriffConfig.WallCheck then return true end
    if not targetPart or not murdererChar or not LocalPlayer.Character then return false end
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local gun = char:FindFirstChild("Gun")
    local originPos = (gun and gun:FindFirstChild("Handle")) and gun.Handle.Position or hrp.Position
    
    -- Modificación de v6.7.2 para ignorar de manera absoluta TODOS los personajes (evita colisiones con sombreros/ropa)
    local ignoreList = {char, murdererChar, Camera}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then table.insert(ignoreList, p.Character) end
    end
    
    -- Corrección crítica agregada para ignorar también las mascotas globales de MM2
    if workspace:FindFirstChild("Pets") then table.insert(ignoreList, workspace.Pets) end
    if workspace:FindFirstChild("PetFolder") then table.insert(ignoreList, workspace.PetFolder) end
    
    wallcastParams.FilterDescendantsInstances = ignoreList
    if workspace:Raycast(hrp.Position, originPos - hrp.Position, wallcastParams) then return false end
    local pathCheck = workspace:Raycast(originPos, targetPart.Position - originPos, wallcastParams)
    if not pathCheck then return true end 
    
    local instance = pathCheck.Instance
    if instance.CanCollide == true and instance.Transparency < 0.75 then
        local mat = instance.Material
        if mat == Enum.Material.Glass or mat == Enum.Material.SmoothPlastic or mat == Enum.Material.Brick or mat == Enum.Material.Wood or mat == Enum.Material.Concrete or mat == Enum.Material.Metal then
            return false
        end
    end
    return true
end

-- Mecánica de prioridad solicitada: Si el Torso está tapado, escanea la cabeza inmediatamente.
local function getBestTargetPart(murdererChar)
    if not murdererChar then return nil end
    local hrp = murdererChar:FindFirstChild("HumanoidRootPart") or murdererChar:FindFirstChild("Torso") or murdererChar:FindFirstChild("UpperTorso")
    local head = murdererChar:FindFirstChild("Head")
    
    -- Opción 1: Torso
    if hrp and isTargetVisible(hrp, murdererChar) then 
        return hrp
    -- Opción 2: Cabeza si el torso está tapado
    elseif head and isTargetVisible(head, murdererChar) then 
        return head 
    end
    
    -- Si el Wall Check está activo y ambos están tapados, retorna nil para el Aim, pero los Tracers seguirán apuntando al hrp por defecto
    return SheriffConfig.WallCheck and nil or (hrp or head)
end

local function getFloorHeight(targetHrp, targetChar)
    floorCastParams.FilterDescendantsInstances = {targetChar, LocalPlayer.Character, Camera}
    local ray = workspace:Raycast(targetHrp.Position, Vector3.new(0, -25, 0), floorCastParams)
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
    local rawVelocity = hrp.AssemblyLinearVelocity
    local distance = (targetPosition - localHrp.Position).Magnitude

    local predictionWeight = 1
    local minZone = SheriffConfig.CloseRangeZone
    local maxZone = minZone + 15
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

    if rawVelocity.Magnitude > 32 then 
        rawVelocity = rawVelocity.Unit * 32 
    end

    local dotProduct = 1
    if lastRawVelocity.Magnitude > 0.5 and rawVelocity.Magnitude > 0.5 then
        dotProduct = rawVelocity.Unit:Dot(lastRawVelocity.Unit)
    end
    lastRawVelocity = rawVelocity 

    local baitingFactor = 1
    if dotProduct < 0.65 then
        if SheriffConfig.AntiBaiting then
            baitingFactor = math.clamp((dotProduct + 1) / 2.5, 0.0, 0.4) 
        else
            baitingFactor = math.clamp((dotProduct + 1) / 1.65, 0.15, 1.0)
        end
    end

    local clampedDT = math.min(activeDT, 0.05) 
    local isLowFPS = activeDT > 0.033
    local responseSpeed = isLowFPS and 12.0 or 16.5
    local adaptiveWeight = math.clamp(1 - math.exp(-responseSpeed * clampedDT), 0.08, 0.88)
    smoothedVelocity = smoothedVelocity:Lerp(rawVelocity, adaptiveWeight)

    local speedFactor = math.clamp(smoothedVelocity.Magnitude / 16.705, 0, 1.2)
    local fpsBuffer = isLowFPS and 0.040 or 0.030
    local ping = math.clamp(cachedPingValue, 0.01, 0.5) + fpsBuffer 
    local distanceFactor = math.clamp(distance / 22, 0.05, 1.15)
    local hFactor = (SheriffConfig.HorizontalPred * 1.12) * speedFactor

    local rawAcceleration = (smoothedVelocity - previousTargetVelocity) / math.max(clampedDT, 0.001)
    if dotProduct < 0.5 then rawAcceleration = rawAcceleration * 0.05 end
    if rawAcceleration.Magnitude > 60 then rawAcceleration = rawAcceleration.Unit * 60 end
    local stableAcceleration = Vector3.new(rawAcceleration.X, rawAcceleration.Y * (isLowFPS and 0.02 or 0.06), rawAcceleration.Z)

    local timeFrameTotal = hFactor * (ping * 10) * distanceFactor * predictionWeight * baitingFactor
    local timeFramePingOnly = cachedPingValue * distanceFactor * predictionWeight * baitingFactor
    local timeFrameLagOnly = clampedDT * distanceFactor * predictionWeight * baitingFactor

    local finalHorizontal, pingHorizontal, lagHorizontal = Vector3.new(0,0,0), Vector3.new(0,0,0), Vector3.new(0,0,0)

    if SheriffConfig.PredictionMode == "Híbrido Absoluto (Omni)" then
        finalHorizontal = (smoothedVelocity * timeFrameTotal):Lerp(smoothedVelocity * (timeFrameTotal * math.clamp(dotProduct, 0.4, 1.0)), 0.3)
        pingHorizontal = (smoothedVelocity * timeFramePingOnly):Lerp(smoothedVelocity * (timeFramePingOnly * math.clamp(dotProduct, 0.4, 1.0)), 0.3)
        lagHorizontal = (smoothedVelocity * timeFrameLagOnly):Lerp(smoothedVelocity * (timeFrameLagOnly * math.clamp(dotProduct, 0.4, 1.0)), 0.3)
        if distance >= 13 and dotProduct >= 0.75 then 
            local extraAcc = 0.5 * stableAcceleration
            finalHorizontal = finalHorizontal + (extraAcc * (timeFrameTotal ^ 2))
            pingHorizontal = pingHorizontal + (extraAcc * (timeFramePingOnly ^ 2))
            lagHorizontal = lagHorizontal + (extraAcc * (timeFrameLagOnly ^ 2))
        end
    elseif SheriffConfig.PredictionMode == "Predictiva 2.0 (Aceleración)" then
        local accCalc = (dotProduct >= 0.75) and (0.5 * stableAcceleration) or Vector3.new(0,0,0)
        finalHorizontal = (smoothedVelocity * timeFrameTotal) + (accCalc * (timeFrameTotal ^ 2))
        pingHorizontal = (smoothedVelocity * timeFramePingOnly) + (accCalc * (timeFramePingOnly ^ 2))
        lagHorizontal = (smoothedVelocity * timeFrameLagOnly) + (accCalc * (timeFrameLagOnly ^ 2))
    elseif SheriffConfig.PredictionMode == "Predictivo Adaptativo" then
        local dH = timeFrameTotal * (dotProduct < 0.85 and math.clamp(dotProduct, 0.2, 1.0) or 1)
        finalHorizontal = Vector3.new(smoothedVelocity.X, 0, smoothedVelocity.Z) * dH
        pingHorizontal = Vector3.new(smoothedVelocity.X, 0, smoothedVelocity.Z) * (timeFramePingOnly * (dotProduct < 0.85 and math.clamp(dotProduct, 0.2, 1.0) or 1))
        lagHorizontal = Vector3.new(smoothedVelocity.X, 0, smoothedVelocity.Z) * (timeFrameLagOnly * (dotProduct < 0.85 and math.clamp(dotProduct, 0.2, 1.0) or 1))
    end

    local maxHorizontalShift = 3.8
    if finalHorizontal.Magnitude > maxHorizontalShift then finalHorizontal = finalHorizontal.Unit * maxHorizontalShift end
    if pingHorizontal.Magnitude > maxHorizontalShift then pingHorizontal = pingHorizontal.Unit * maxHorizontalShift end
    if lagHorizontal.Magnitude > maxHorizontalShift then lagHorizontal = lagHorizontal.Unit * maxHorizontalShift end

    local verticalOffset = Vector3.new(0, 0, 0)
    if humanoid.FloorMaterial == Enum.Material.Air or math.abs(smoothedVelocity.Y) > 0.1 then
        local verticalTime = ping * SheriffConfig.VerticalPred * predictionWeight
        local pY = (smoothedVelocity.Y * verticalTime) - (0.5 * workspace.Gravity * (verticalTime ^ 2))
        
        if smoothedVelocity.Y > 1 then
            pY = pY + (smoothedVelocity.Y * 0.008 * predictionWeight)
        end
        verticalOffset = Vector3.new(0, pY, 0)
    end

    local finalPrediction = targetPosition + Vector3.new(finalHorizontal.X, 0, finalHorizontal.Z) + verticalOffset
    local pingPrediction = targetPosition + Vector3.new(pingHorizontal.X, 0, pingHorizontal.Z) + verticalOffset
    local lagPrediction = targetPosition + Vector3.new(lagPrediction.X, 0, lagPrediction.Z) + verticalOffset

    local floorY = getFloorHeight(hrp, targetChar)
    if floorY then
        local bodyScale = humanoid:FindFirstChild("BodyHeightScale") and math.clamp(humanoid.BodyHeightScale.Value, 0.2, 1.5) or 1
        local minAllowedY = floorY + ((hrp.Size.Y / 2) * bodyScale) + 0.15
        if finalPrediction.Y < minAllowedY then finalPrediction = Vector3.new(finalPrediction.X, minAllowedY, finalPrediction.Z) end
        if pingPrediction.Y < minAllowedY then pingPrediction = Vector3.new(pingPrediction.X, minAllowedY, pingPrediction.Z) end
        if lagPrediction.Y < minAllowedY then lagPrediction = Vector3.new(lagPrediction.X, minAllowedY, lagPrediction.Z) end
    end

    previousTargetVelocity = smoothedVelocity
    return finalPrediction, pingPrediction, lagPrediction
end

-- ============================================================================
-- 🌌 LINEAS DE RENDERIZADO VISIBLES SIEMPRE (IGNORAN WALL CHECK)
-- ============================================================================
local LagLine = Drawing.new("Line") 
LagLine.Color = Color3.fromRGB(150, 50, 255) 
LagLine.Thickness = 1.1
LagLine.ZIndex = 2  
LagLine.Visible = false
table.insert(_G.KillerHubLines, LagLine)

local PingLine = Drawing.new("Line")
PingLine.Color = Color3.fromRGB(0, 100, 255) 
PingLine.Thickness = 1.1
PingLine.ZIndex = 3  
PingLine.Visible = false
table.insert(_G.KillerHubLines, PingLine)

local LeadLine = Drawing.new("Line")
LeadLine.Color = Color3.fromRGB(0, 255, 100) 
LeadLine.Thickness = 1.1
LeadLine.ZIndex = 4  
LeadLine.Visible = false
table.insert(_G.KillerHubLines, LeadLine)

local PredictionLine = Drawing.new("Line")
PredictionLine.Color = Color3.fromRGB(255, 35, 35) 
PredictionLine.Thickness = 1.5 
PredictionLine.ZIndex = 5  
PredictionLine.Visible = false
table.insert(_G.KillerHubLines, PredictionLine)

local currentScreenPred = Vector2.new(0,0)
local currentScreenPing = Vector2.new(0,0)
local currentScreenLag = Vector2.new(0,0)
local currentScreenLead = Vector2.new(0,0)
local firstFrame = true

local vec2New, vec3New = Vector2.new, Vector3.new
local worldToViewport = Camera.WorldToViewportPoint

local renderConn = RunService.RenderStepped:Connect(function(dt)
    lastDeltaTime = dt 
    emaDeltaTime = emaDeltaTime + 0.2 * (dt - emaDeltaTime) 
    
    local gun, _ = getGunLocation()
    local hasGun = not SheriffConfig.UseWeaponDetector or (gun ~= nil)
    local murderer = getMurderer()
    local screenGui = game:GetService("CoreGui"):FindFirstChild("KillerHub_SheriffGui")
    if screenGui then screenGui.Enabled = SheriffConfig.ShowShootButton and hasGun end

    if not hasGun or not murderer or not murderer.Character then
        PredictionLine.Visible = false; PingLine.Visible = false; LagLine.Visible = false; LeadLine.Visible = false;
        firstFrame = true
        return
    end

    local targetChar = murderer.Character
    -- Para que los Tracers sean visibles SIEMPRE (aunque esté detrás de paredes), usamos una pieza base garantizada
    local basePart = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head")

    local localChar = LocalPlayer.Character
    local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")

    if basePart and localHrp then
        local distance = (basePart.Position - localHrp.Position).Magnitude
        local distFactor = math.clamp((distance - 4) / 16, 0, 1)
        local tSmooth = SheriffConfig.TracerSmoothness
        
        local predictedPos, pingPos, lagPos = getPredictedPosition(targetChar, basePart)
        local screenOrigin = vec2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

        if lagPos and SheriffConfig.ShowLagTracer then
            local screenPos, onScreen = worldToViewport(Camera, lagPos)
            if onScreen then
                local target2D = vec2New(screenPos.X, screenPos.Y)
                currentScreenLag = (firstFrame or tSmooth == 1) and target2D or currentScreenLag:Lerp(target2D, tSmooth)
                LagLine.From = screenOrigin
                LagLine.To = currentScreenLag
                LagLine.Visible = true
            else LagLine.Visible = false end
        else LagLine.Visible = false end

        if pingPos and SheriffConfig.ShowPingTracer then
            local screenPos, onScreen = worldToViewport(Camera, pingPos)
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
            local leadPredictedPos = basePart.Position + (balancedVelocity * SheriffConfig.LeadTimePred * distFactor)
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

        if predictedPos and SheriffConfig.PredictTracer then
            local screenPos, onScreen = worldToViewport(Camera, predictedPos)
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
        PredictionLine.Visible = false; PingLine.Visible = false; LagLine.Visible = false; LeadLine.Visible = false;
        firstFrame = true
    end 
end)
table.insert(_G.KillerHubConnections, renderConn)

-- ============================================================================
-- ⚡ MOTOR DE DISPARO DIRECTO CON INTEGRACIÓN AUTO-EQUIP REAL DE V6.7.2
-- ============================================================================
local function fireAtMurdererDirectly()
    if isFiringCooldown then return end 
    
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not hrp then return end 

    local gun, parent = getGunLocation()
    local murderer = getMurderer()

    if gun and murderer and murderer.Character then
        local targetChar = murderer.Character
        local bestPart = getBestTargetPart(targetChar) -- Usa el Wallcheck Inteligente (Torso -> Cabeza)
        
        if bestPart then 
            local predictedPos = getPredictedPosition(targetChar, bestPart)
            if predictedPos then
                isFiringCooldown = true 
                
                -- FUSIÓN MECÁNICA V6: Si el arma está en la mochila (Backpack), forzar el Equipamiento Instantáneo
                if parent == LocalPlayer.Backpack then 
                    humanoid:EquipTool(gun) 
                    RunService.Heartbeat:Wait() 
                end 

                local shootRemote = gun:FindFirstChild("Shoot")
                if shootRemote then
                    local originCFrame = hrp.CFrame
                    if hrp:FindFirstChild("GunRaycastAttachment") then 
                        originCFrame = hrp.GunRaycastAttachment.WorldCFrame 
                    end
                    shootRemote:FireServer(originCFrame, CFrame.new(predictedPos))
                end
                
                -- Fast Unequip heredado opcional de la versión vieja
                if SheriffConfig.AutoUnequip then 
                    task.wait(math.clamp(cachedPingValue * 0.5, 0.015, 0.05)) 
                    humanoid:UnequipTools() 
                end 
                
                task.wait(0.05) 
                isFiringCooldown = false
            end
        end
    end
end

-- ============================================================================
-- 🌌 INTERFAZ V3.5 (BOTÓN SHOOT INTERACTIVO)
-- ============================================================================
local VoidGui = Instance.new("ScreenGui")
VoidGui.Name = "KillerHub_SheriffGui"
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
Corner.CornerRadius = UDim.new(0, math.floor(SheriffConfig.ButtonSize * 0.28))
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
DecalTexture.Position = UDim2.new(0.5, 0, 0.44, 0)
DecalTexture.BackgroundTransparency = 1
DecalTexture.Image = "rbxassetid://125754446555599"
DecalTexture.ImageTransparency = 1 - SheriffConfig.ButtonOpacity
DecalTexture.ZIndex = ShootButton.ZIndex + 2
DecalTexture.Parent = ShootButton

local function iniciarAnimacionIcono(decalTexture)
    if not decalTexture then return end
    local tiempoGiro = 0.8015     
    local tiempoQuieto = 0.0315   
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
    TweenService:Create(GlowOverlay, TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.25}):Play()
end

local function fadeGlowReflection()
    TweenService:Create(GlowOverlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
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
        ShootButton.Position = UDim2.new(
            startPos.X.Scale + (delta.X / Camera.ViewportSize.X), 0, 
            startPos.Y.Scale + (delta.Y / Camera.ViewportSize.Y), 0
        )
    end
end)
table.insert(_G.KillerHubConnections, cGlobalInputChanged)

-- ============================================================================
-- ⚡ HOOKS DE REMOTOS COMPLETAMENTE REDISEÑADOS (ADAPTACIÓN DE VARIABLES)
-- ============================================================================
local ClientServices = ReplicatedStorage:WaitForChild("ClientServices", 5)
if ClientServices then
    local WeaponService = require(ClientServices:WaitForChild("WeaponService"))
    local oldGetTargetPosition = WeaponService.GetTargetPosition
    local oldGetMouseTargetCFrame = WeaponService.GetMouseTargetCFrame

    local lastHookCallTime = os.clock()

    local function checkAndPredict(returnCFrame)
        local currentTime = os.clock()
        local hookDelta = currentTime - lastHookCallTime
        lastHookCallTime = currentTime
        
        local structuralDelta = math.clamp(hookDelta, 0.008, 0.033)

        local gun, _ = getGunLocation()
        if SheriffConfig.SilentAim and (not SheriffConfig.UseWeaponDetector or (gun ~= nil)) then
            local murderer = getMurderer()
            if murderer and murderer.Character then
                local targetChar = murderer.Character
                local bestPart = getBestTargetPart(targetChar)
                if bestPart then
                    local predictedPos = getPredictedPosition(targetChar, bestPart, structuralDelta)
                    if predictedPos then 
                        return returnCFrame and CFrame.new(predictedPos) or predictedPos 
                    end
                end
            end
        end
        return nil
    end

    WeaponService.GetTargetPosition = function(self, ...)
        local prediction = checkAndPredict(false) 
        return prediction or oldGetTargetPosition(self, ...)
    end

    WeaponService.GetMouseTargetCFrame = function(self, ...)
        local prediction = checkAndPredict(true) 
        return prediction or oldGetMouseTargetCFrame(self, ...)
    end
end

return KillerHub
