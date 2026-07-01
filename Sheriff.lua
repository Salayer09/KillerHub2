-- ============================================================================
--  KILLER HUB | SHERIFF SUITE V8.0.0 (ADAPTADO A NUEVA API)
-- ============================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService") 
local Stats = game:GetService("Stats") 
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- LOCALIZACIÓN DE UPVALUES PARA MÁXIMO RENDIMIENTO
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
local os_clock = os_clock

local workspace = workspace
local workspace_Gravity = workspace.Gravity

local VECTOR_ZERO = vec3New(0, 0, 0)

-- LIMPIEZA DE TRAZADORES PREVIOS
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

-- 1. CARGAR TU LIBRERÍA (Estructura basada en tu nueva API)
local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Salayer09/KillerHub/refs/heads/main/Slayer.lua"))()

-- CONFIGURACIÓN INTERNA RESIDENTE
local SheriffConfig = {
    SilentAim = false,
    PredictionMode = "Híbrido Absoluto (Omni)", 
    HorizontalPredMin = 0.050, 
    HorizontalPredMax = 0.145, 
    VerticalPredMin = 0.010,   
    VerticalPredMax = 0.035,   
    WallCheck = true,    
    CloseRangeZone = 8, 
    AntiBaiting = true, 
    HitrateEnhancer = true,
    PredictTracer = true,      
    ShowMinPredictTracer = true, 
    ShowPingTracer = false,    
    ShowLagTracer = false,     
    ShowLeadTracer = true,    
    TracerSmoothness = 0.60, 
    UseWeaponDetector = false, 
    ShowShootButton = false,
    ButtonSize = 95,
    ButtonOpacity = 0.95,
    LeadTimePred = 0.05
}

-- 2. CREAR PESTAÑA PRINCIPAL (Uso correcto de CreateTab según tu ejemplo)
local SheriffTab = KillerHub:CreateTab("Sheriff", "rbxassetid://10747373142")

-- ============================================================================
-- ⚔️ ADAPTACIÓN estricta de componentes bajo las especificaciones de tu API
-- ============================================================================
SheriffTab:CreateSection("Ajustes del Silent Aim")

SheriffTab:CreateToggle("SheriffSilent", "Activar Silent Aim Pasivo", function(estado)
    SheriffConfig.SilentAim = estado
end)

SheriffTab:CreateToggle("HitrateEnhancerToggle", "Optimizar Balística Predictiva", function(estado)
    SheriffConfig.HitrateEnhancer = estado
end)

SheriffTab:CreateToggle("SheriffWallCheckToggle", "Verificar Paredes (Wall Check)", function(estado)
    SheriffConfig.WallCheck = estado
end)

SheriffTab:CreateToggle("AntiBaitingToggle", "Filtro Anti-Amague (Anti-Baiting)", function(estado)
    SheriffConfig.AntiBaiting = estado
end)

SheriffTab:CreateDropdown("PredMode", "Modo de Predicción:", {"Híbrido Absoluto (Omni)", "Predictiva 2.0 (Aceleración)", "Predictivo Adaptativo"}, function(seleccionado)
    SheriffConfig.PredictionMode = seleccionado
end)

SheriffTab:CreateSlider("HorizontalPredMinSlider", "Predicción Horizontal MÍNIMA", 0, 250, function(valor)
    SheriffConfig.HorizontalPredMin = valor / 1000 
end, math_floor(SheriffConfig.HorizontalPredMin * 1000))

SheriffTab:CreateSlider("HorizontalPredMaxSlider", "Predicción Horizontal MÁXIMA", 0, 300, function(valor)
    SheriffConfig.HorizontalPredMax = valor / 1000 
end, math_floor(SheriffConfig.HorizontalPredMax * 1000))

SheriffTab:CreateSlider("VerticalPredMinSlider", "Predicción Vertical MÍNIMA", 0, 90, function(valor)
    SheriffConfig.VerticalPredMin = valor / 1000
end, math_floor(SheriffConfig.VerticalPredMin * 1000))

SheriffTab:CreateSlider("VerticalPredMaxSlider", "Predicción Vertical MÁXIMA", 0, 120, function(valor)
    SheriffConfig.VerticalPredMax = valor / 1000
end, math_floor(SheriffConfig.VerticalPredMax * 1000))

SheriffTab:CreateSlider("CloseRangeZoneSlider", "Zona Muerta Quemarropa (Studs)", 0, 20, function(valor)
    SheriffConfig.CloseRangeZone = valor
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
end)

SheriffTab:CreateSlider("TracerSmoothSlider", "Estabilizador Anti-Temblor", 1, 100, function(valor)
    if valor == 1 then
        SheriffConfig.TracerSmoothness = 1 
    else
        SheriffConfig.TracerSmoothness = 0.95 - ((valor - 2) / 98) * 0.80
    end
end, 40)

SheriffTab:CreateSlider("LeadTimeSlider", "Anticipación de la Mano (Lead Time)", 0, 100, function(valor)
    SheriffConfig.LeadTimePred = valor / 100
end, math_floor(SheriffConfig.LeadTimePred * 100))

SheriffTab:CreateSection("Ajustes de Interfaz / Tácticas")

SheriffTab:CreateToggle("WeaponDetectToggle", "Ocultar Botón si no tengo Arma", function(estado)
    SheriffConfig.UseWeaponDetector = estado
end)

SheriffTab:CreateToggle("ShowVoidButton", "Mostrar Botón en Pantalla", function(estado)
    SheriffConfig.ShowShootButton = estado
end)

SheriffTab:CreateSlider("VoidBtnSize", "Tamaño del Botón Sheriff", 50, 200, function(valor)
    SheriffConfig.ButtonSize = valor
    if _G.CachedShootButton then 
        _G.CachedShootButton.Size = udim2New(0, valor, 0, valor) 
    end
end, SheriffConfig.ButtonSize)


-- ============================================================================
-- ⚙️ LÓGICA INTERNA DE MM2, HITBOXES PEQUEÑAS Y SISTEMA PREDICTIVO COMPLETO
-- ============================================================================

local MurdererDetectado = nil
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
    for i = 1, #pingHistory do
        local p = pingHistory[i]
        sum = sum + p
        if p > maxRecentPing then maxRecentPing = p end
    end
    return ((sum / #pingHistory) * 0.65) + (maxRecentPing * 0.35)
end

task.spawn(function()
    while task.wait(0.5) do
        if Stats and Stats:FindFirstChild("Network") and Stats.Network:FindFirstChild("ServerToClientPing") then
            cachedPingValue = getSmoothedPing(Stats.Network.ServerToClientPing:GetValue() / 1000)
        end
    end
end)

local function isRangedWeapon(tool)
    if not tool or not tool:IsA("Tool") then return false end
    return tool:FindFirstChild("Shoot") or tool.Name == "Gun" or tool.Name == "Revolver"
end

local function isMeleeWeapon(tool)
    if not tool or not tool:IsA("Tool") then return false end
    return tool:FindFirstChild("Stab") or tool.Name == "Knife"
end

local function checkWeaponVisibility()
    if not _G.CachedScreenGui then return end
    if not SheriffConfig.ShowShootButton then
        _G.CachedScreenGui.Enabled = false
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
        _G.CachedScreenGui.Enabled = hasGun
    else
        _G.CachedScreenGui.Enabled = true
    end
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
                task.wait(0.01) 
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

local function getMurderer()
    if MurdererDetectado and MurdererDetectado.Parent and MurdererDetectado.Character then
        local name = MurdererDetectado.Name
        local char = MurdererDetectado.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local isDead = (hum and hum.Health <= 0) or (playerDeadStatus[name] == true)
        local sigueSiendoMurderer = (playerRoles[name] == "Murderer")

        if not isDead and sigueSiendoMurderer then
            currentTarget = MurdererDetectado
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
                    currentTarget = pl
                    return pl
                end
            end
        end
    end

    local potentialMurderer = nil
    local allPlayers = Players:GetPlayers()
    for i = 1, #allPlayers do
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
        currentTarget = potentialMurderer
    else
        currentTarget = nil
    end
    return currentTarget
end

local mapCastParams = RaycastParams.new()
mapCastParams.FilterType = Enum.RaycastFilterType.Exclude

local function getSmartTargetPart(targetChar)
    if not targetChar then return nil end
    local torso = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso")
    if not SheriffConfig.WallCheck then return torso end

    local origin = Camera.CFrame.Position
    local ignoreList = {LocalPlayer.Character, Camera}
    
    local allPlayers = Players:GetPlayers()
    for i = 1, #allPlayers do
        local p = allPlayers[i]
        if p.Character then table.insert(ignoreList, p.Character) end
    end
    if workspace:FindFirstChild("Pets") then table.insert(ignoreList, workspace.Pets) end
    if workspace:FindFirstChild("PetFolder") then table.insert(ignoreList, workspace.PetFolder) end
    mapCastParams.FilterDescendantsInstances = ignoreList
    
    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    local customOffset = VECTOR_ZERO

    if animator then
        local activeTracks = animator:GetPlayingAnimationTracks()
        for i = 1, #activeTracks do
            local track = activeTracks[i]
            if track.IsPlaying and (track.Animation.AnimationId:match("18243") or track.Speed == 0) then
                customOffset = vec3New(0, -0.65, 0) 
                break
            end
        end
    end

    if torso then
        local targetPos = torso.Position + customOffset
        local direction = targetPos - origin
        local ray = workspace:Raycast(origin, direction, mapCastParams)
        if not ray or (ray.Instance.CanCollide == false or ray.Instance.Transparency >= 0.85) then
            return torso
       end
    end
    return torso
end

local function getFloorHeight(targetHrp, targetChar)
    if not targetHrp then return nil end
    floorCastParams.FilterDescendantsInstances = {targetChar, LocalPlayer.Character, Camera}
    local ray = workspace:Raycast(targetHrp.Position, vec3New(0, -25, 0), floorCastParams)
    return ray and ray.Position.Y or nil
end

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

    -- COMPENSACIÓN DE ESCALA REAL CONTRA AVATARES CHIQUITOS DE LA COMUNIDAD
    local heightScale = humanoid:FindFirstChild("BodyHeightScale") and humanoid.BodyHeightScale.Value or 1.0
    local widthScale = humanoid:FindFirstChild("BodyWidthScale") and humanoid.BodyWidthScale.Value or 1.0
    
    if heightScale < 0.85 or widthScale < 0.85 then
        local visualOffset = vec3New(0, (1.0 - heightScale) * 0.45, 0)
        targetPosition = targetPosition - visualOffset
    end

    local currentRawSpeed = rawVelocity.Magnitude
    if currentRawSpeed < 1.2 then
        rawVelocity = VECTOR_ZERO
        currentRawSpeed = 0
    end

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

    local maxExpectedSpeed = math_max(humanoid.WalkSpeed * 2.2, 45)
    if currentRawSpeed > maxExpectedSpeed then 
        rawVelocity = rawVelocity.Unit * maxExpectedSpeed 
    end

    local dotProduct = 1
    if lastRawVelocity.Magnitude > 0.5 and rawVelocity.Magnitude > 0.5 then
        dotProduct = rawVelocity.Unit:Dot(lastRawVelocity.Unit)
    end
    lastRawVelocity = rawVelocity 

    local baitingFactor = 1
    if dotProduct < 0.65 then
        if SheriffConfig.AntiBaiting then
            baitingFactor = math_clamp((dotProduct + 1) / 2.5, 0.0, 0.35) 
        else
            baitingFactor = math_clamp((dotProduct + 1) / 1.65, 0.15, 1.0)
        end
    end

    local clampedDT = math_min(activeDT, 0.05) 
    local isLowFPS = activeDT > 0.033
    
    local responseSpeed = (dotProduct < 0.5) and 26.5 or (isLowFPS and 16.0 or 20.5)
    local adaptiveWeight = math_clamp(1 - math_exp(-responseSpeed * clampedDT), 0.08, 0.90)
    smoothedVelocity = smoothedVelocity:Lerp(rawVelocity, adaptiveWeight)

    local currentVelocityMagnitude = smoothedVelocity.Magnitude
    local speedFactor = math_clamp(currentVelocityMagnitude / 16.5, 0, 1.5)
    
    local fpsBuffer = isLowFPS and 0.035 or 0.025
    local ping = math_clamp(cachedPingValue, 0.01, 0.5) + fpsBuffer 
    local distanceFactor = math_clamp(distance / 22, 0.05, 1.15)
    
    local hFactorMax = math_min((SheriffConfig.HorizontalPredMax * 1.12) * speedFactor, SheriffConfig.HorizontalPredMax * 1.5)
    local hFactorMin = math_min((SheriffConfig.HorizontalPredMin * 1.12) * speedFactor, SheriffConfig.HorizontalPredMin)

    -- CÁLCULO DE ACELERACIÓN INSTANTÁNEA EN EL AIRE
    local rawAcceleration = (smoothedVelocity - previousTargetVelocity) / math_max(clampedDT, 0.001)
    
    if humanoid.FloorMaterial == Enum.Material.Air then
        if rawAcceleration.Magnitude > 75 then rawAcceleration = rawAcceleration.Unit * 75 end
    else
        if dotProduct < 0.3 then 
            rawAcceleration = VECTOR_ZERO 
        elseif rawAcceleration.Magnitude > 60 then 
            rawAcceleration = rawAcceleration.Unit * 60 
        end
    end
    
    local stableAcceleration = vec3New(rawAcceleration.X, rawAcceleration.Y * (isLowFPS and 0.01 or 0.04), rawAcceleration.Z)

    local timeFrameTotal = hFactorMax * (ping * 10) * distanceFactor * predictionWeight * baitingFactor
    local timeFrameMin = hFactorMin * (ping * 10) * distanceFactor * predictionWeight * baitingFactor
    local timeFramePingOnly = cachedPingValue * distanceFactor * predictionWeight * baitingFactor
    local timeFrameLagOnly = clampedDT * distanceFactor * predictionWeight * baitingFactor

    local finalHorizontal = VECTOR_ZERO
    local minHorizontal = VECTOR_ZERO
    local pingHorizontal = VECTOR_ZERO
    local lagHorizontal = VECTOR_ZERO

    local dotClamp = math_clamp(dotProduct, 0.4, 1.0)

    if SheriffConfig.PredictionMode == "Híbrido Absoluto (Omni)" then
        finalHorizontal = (smoothedVelocity * timeFrameTotal):Lerp(smoothedVelocity * (timeFrameTotal * dotClamp), 0.3)
        minHorizontal = (smoothedVelocity * timeFrameMin):Lerp(smoothedVelocity * (timeFrameMin * dotClamp), 0.3)
        pingHorizontal = (smoothedVelocity * timeFramePingOnly):Lerp(smoothedVelocity * (timeFramePingOnly * dotClamp), 0.3)
        lagHorizontal = (smoothedVelocity * timeFrameLagOnly):Lerp(smoothedVelocity * (timeFrameLagOnly * dotClamp), 0.3)
        if distance >= 13 and currentVelocityMagnitude > 4 then 
            local extraAcc = 0.55 * stableAcceleration
            finalHorizontal = finalHorizontal + (extraAcc * (timeFrameTotal ^ 2))
            minHorizontal = minHorizontal + (extraAcc * (timeFrameMin ^ 2))
         end
    elseif SheriffConfig.PredictionMode == "Predictiva 2.0 (Aceleración)" then
        local accCalc = (currentVelocityMagnitude > 4) and (0.55 * stableAcceleration) or VECTOR_ZERO
        finalHorizontal = (smoothedVelocity * timeFrameTotal) + (accCalc * (timeFrameTotal ^ 2))
        minHorizontal = (smoothedVelocity * timeFrameMin) + (accCalc * (timeFrameMin ^ 2))
        pingHorizontal = (smoothedVelocity * timeFramePingOnly) + (accCalc * (timeFramePingOnly ^ 2))
        lagHorizontal = (smoothedVelocity * timeFrameLagOnly) + (accCalc * (timeFrameLagOnly ^ 2))
    elseif SheriffConfig.PredictionMode == "Predictivo Adaptativo" then
        local dMod = (dotProduct < 0.85 and math_clamp(dotProduct, 0.2, 1.0) or 1)
        local flatVel = vec3New(smoothedVelocity.X, 0, smoothedVelocity.Z)
        finalHorizontal = flatVel * (timeFrameTotal * dMod)
        minHorizontal = flatVel * (timeFrameMin * dMod)
        pingHorizontal = flatVel * (timeFramePingOnly * dMod)
        lagHorizontal = flatVel * (timeFrameLagOnly * dMod)
    end

    local maxHorizontalShift = 3.8
    if finalHorizontal.Magnitude > maxHorizontalShift then finalHorizontal = finalHorizontal.Unit * maxHorizontalShift end
    if minHorizontal.Magnitude > maxHorizontalShift then minHorizontal = minHorizontal.Unit * maxHorizontalShift end
    if pingHorizontal.Magnitude > maxHorizontalShift then pingHorizontal = pingHorizontal.Unit * maxHorizontalShift end
    if lagHorizontal.Magnitude > maxHorizontalShift then lagHorizontal = lagHorizontal.Unit * maxHorizontalShift end

    local verticalOffsetMax = VECTOR_ZERO
    local verticalOffsetMin = VECTOR_ZERO
    local verticalSpeed = math_abs(smoothedVelocity.Y)
    
    if humanoid.FloorMaterial == Enum.Material.Air or verticalSpeed > 0.4 then
        local vSpeedScale = math_clamp(verticalSpeed / 50, 0, 1.2)
        local finalVFactorMax = math_min(ping * SheriffConfig.VerticalPredMax * predictionWeight * vSpeedScale, ping * SheriffConfig.VerticalPredMax * predictionWeight)
        local finalVFactorMin = math_min(ping * SheriffConfig.VerticalPredMin * predictionWeight * vSpeedScale, ping * SheriffConfig.VerticalPredMin * predictionWeight)
        
        local pYMax = (smoothedVelocity.Y * finalVFactorMax) - (0.4 * workspace_Gravity * (finalVFactorMax ^ 2))
        local pYMin = (smoothedVelocity.Y * finalVFactorMin) - (0.4 * workspace_Gravity * (finalVFactorMin ^ 2))
        if smoothedVelocity.Y > 1 then
            pYMax = pYMax + (smoothedVelocity.Y * 0.0075 * predictionWeight)
            pYMin = pYMin + (smoothedVelocity.Y * 0.0075 * predictionWeight)
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
        local minAllowedY = floorY + ((hrp.Size.Y / 2) * heightScale) + 0.15
        if finalPrediction.Y < minAllowedY then finalPrediction = vec3New(finalPrediction.X, minAllowedY, finalPrediction.Z) end
        if minPrediction.Y < minAllowedY then minPrediction = vec3New(minPrediction.X, minAllowedY, minPrediction.Z) end
        if pingPrediction.Y < minAllowedY then pingPrediction = vec3New(pingPrediction.X, minAllowedY, minPrediction.Z) end
        if lagPrediction.Y < minAllowedY then lagPrediction = vec3New(lagPrediction.X, minAllowedY, minPrediction.Z) end
    end

    previousTargetVelocity = smoothedVelocity
    return finalPrediction, minPrediction, pingPrediction, lagPrediction
end

-- CONFIGURACIÓN DE TRACERS VISUALES EN MOTOR RE-RENDEREADO
local LagLine = Drawing.new("Line"); LagLine.Color = color3RGB(150, 50, 255); LagLine.Thickness = 1.1; table.insert(_G.KillerHubLines, LagLine)
local PingLine = Drawing.new("Line"); PingLine.Color = color3RGB(0, 100, 255); PingLine.Thickness = 1.1; table.insert(_G.KillerHubLines, PingLine)
local LeadLine = Drawing.new("Line"); LeadLine.Color = color3RGB(0, 255, 100); LeadLine.Thickness = 1.1; table.insert(_G.KillerHubLines, LeadLine)
local MinPredictionLine = Drawing.new("Line"); MinPredictionLine.Color = color3RGB(255, 235, 35); MinPredictionLine.Thickness = 1.3; table.insert(_G.KillerHubLines, MinPredictionLine)
local PredictionLine = Drawing.new("Line"); PredictionLine.Color = color3RGB(255, 35, 35); PredictionLine.Thickness = 1.5; table.insert(_G.KillerHubLines, PredictionLine)

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
                LagLine.From = screenOrigin; LagLine.To = currentScreenLag; LagLine.Visible = true
            else LagLine.Visible = false end
        else LagLine.Visible = false end

        if pingPos and SheriffConfig.ShowPingTracer then
            local screenPos, onScreen = Camera:WorldToViewportPoint(pingPos)
            if onScreen then
                local target2D = vec2New(screenPos.X, screenPos.Y)
                currentScreenPing = (firstFrame or tSmooth == 1) and target2D or currentScreenPing:Lerp(target2D, tSmooth)
                PingLine.From = screenOrigin; PingLine.To = currentScreenPing; PingLine.Visible = true
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
                LeadLine.From = vec2New(handScreenPos.X, handScreenPos.Y); LeadLine.To = currentScreenLead; LeadLine.Visible = true
             else LeadLine.Visible = false end
        else LeadLine.Visible = false end

        if minPredictedPos and SheriffConfig.ShowMinPredictTracer then
            local screenPos, onScreen = Camera:WorldToViewportPoint(minPredictedPos)
            if onScreen then
                local target2D = vec2New(screenPos.X, screenPos.Y)
                currentScreenMinPred = (firstFrame or tSmooth == 1) and target2D or currentScreenMinPred:Lerp(target2D, tSmooth)
                MinPredictionLine.From = screenOrigin; MinPredictionLine.To = currentScreenMinPred; MinPredictionLine.Visible = true
            else MinPredictionLine.Visible = false end
        else MinPredictionLine.Visible = false end

         if predictedPos and SheriffConfig.PredictTracer then
            local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
            if onScreen then
                local target2D = vec2New(screenPos.X, screenPos.Y)
                currentScreenPred = (firstFrame or tSmooth == 1) and target2D or currentScreenPred:Lerp(target2D, tSmooth)
                PredictionLine.From = screenOrigin; PredictionLine.To = currentScreenPred; PredictionLine.Visible = true
            else PredictionLine.Visible = false end
        else PredictionLine.Visible = false end
        
        firstFrame = false
    else
        PredictionLine.Visible = false; MinPredictionLine.Visible = false; PingLine.Visible = false; LagLine.Visible = false; LeadLine.Visible = false;
        firstFrame = true
    end 
end)
table.insert(_G.KillerHubConnections, renderConn)

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

-- CONSTRUCCIÓN DE INTERFAZ MANUAL RE-INTEGRADA (BOTÓN FLOTANTE)
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

_G.CachedScreenGui = VoidGui
_G.CachedShootButton = ShootButton

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0.28, 0)
Corner.Parent = ShootButton

local GlowOverlay = Instance.new("Frame")
GlowOverlay.Name = "GlowOverlay"
GlowOverlay.Size = udim2New(1, 0, 1, 0)
GlowOverlay.BackgroundTransparency = 1
GlowOverlay.ZIndex = ShootButton.ZIndex + 1
GlowOverlay.Parent = ShootButton

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(0.28, 0) 
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
DecalTexture.Size = udim2New(0.38, 0, 0.38, 0)
DecalTexture.AnchorPoint = vec2New(0.5, 0.5)
DecalTexture.Position = udim2New(0.5, 0, 0.44, 0)
DecalTexture.BackgroundTransparency = 1
DecalTexture.Image = "rbxassetid://125754446555599"
DecalTexture.ImageTransparency =  1 - SheriffConfig.ButtonOpacity
DecalTexture.ZIndex = ShootButton.ZIndex + 2
DecalTexture.Parent = ShootButton

task.spawn(function()
    local tIda = TweenService:Create(DecalTexture, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = 360})
    local tVuelta = TweenService:Create(DecalTexture, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = 0})
    
    local cIda = tIda.Completed:Connect(function() task.wait(0.02) tVuelta:Play() end)
    local cVuelta = tVuelta.Completed:Connect(function() task.wait(0.02) tIda:Play() end)
    
    table.insert(_G.KillerHubConnections, cIda)
    table.insert(_G.KillerHubConnections, cVuelta)
    tIda:Play()
end)

local Label = Instance.new("TextLabel")
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

local dragging, dragInput, dragStart, startPos
local cBegan = ShootButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local localX = input.Position.X - ShootButton.AbsolutePosition.X
        local relX = (localX / ShootButton.AbsoluteSize.X) - 0.5
        UiGradient.Offset = vec2New(relX * 1.5, 0)
        TweenService:Create(GlowOverlay, TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.35}):Play()
        
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
                    cChanged:Disconnect()
                end
            end)
        end
     end
end)
table.insert(_G.KillerHubConnections, cBegan)

local cEnded = ShootButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        TweenService:Create(GlowOverlay, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    end
end)
table.insert(_G.KillerHubConnections, cEnded)

local cGlobalInputChanged = UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
table.insert(_G.KillerHubConnections, cGlobalInputChanged)

local cDragUpdate = UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ShootButton.Position = udim2New(
            startPos.X.Scale + (delta.X / Camera.ViewportSize.X), 0, 
            startPos.Y.Scale + (delta.Y / Camera.ViewportSize.Y), 0
        )
    end
end)
table.insert(_G.KillerHubConnections, cDragUpdate)

checkWeaponVisibility()

-- ============================================================================
-- ⚡ ENLAZADOR / INTERCEPTOR ADAPTATIVO POR METATABLA NATIVA (SILENT AIM)
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
end

-- RETORNO DIRECTO REQUERIDO POR TU API (Importante para cadenas infinitas en GitHub)
local Killer = KillerHub
return Killer
