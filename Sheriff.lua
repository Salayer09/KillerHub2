-- ============================================================================
--  ghost KILLER HUB | SHERIFF V8.2.0 ULTRA-PREMIUM [👑 PERFECT HITRATE & AUTO-EQUIP]
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
    AutoUnequip = true, 
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
    local success, err = pcall(function()
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
                AutoUnequip = SheriffConfig.AutoUnequip,
                PredictTracer = SheriffConfig.PredictTracer,
                ShowLeadTracer = SheriffConfig.ShowLeadTracer,
                ShowPingTracer = SheriffConfig.ShowPingTracer,
                ShowLagTracer = SheriffConfig.ShowLagTracer,
                CloseRangeZone = SheriffConfig.CloseRangeZone,
                AntiBaiting = SheriffConfig.AntiBaiting,
                HitrateEnhancer = SheriffConfig.HitrateEnhancer
            }
            writefile(CONFIG_FILE, HttpService:JSONEncode(data))
        end
    end)
    if not success then
        warn("⚠️ KillerHub Info: No se pudo guardar la configuración: " .. tostring(err))
    end
end

local function loadConfig()
    local success, result = pcall(function()
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
                if data.AutoUnequip ~= nil then SheriffConfig.AutoUnequip = data.AutoUnequip end
                if data.PredictTracer ~= nil then SheriffConfig.PredictTracer = data.PredictTracer end
                if data.ShowLeadTracer ~= nil then SheriffConfig.ShowLeadTracer = data.ShowLeadTracer end
                if data.ShowPingTracer ~= nil then SheriffConfig.ShowPingTracer = data.ShowPingTracer end
                if data.ShowLagTracer ~= nil then SheriffConfig.ShowLagTracer = data.ShowLagTracer end
                if data.AntiBaiting ~= nil then SheriffConfig.AntiBaiting = data.AntiBaiting end
                if data.HitrateEnhancer ~= nil then SheriffConfig.HitrateEnhancer = data.HitrateEnhancer end
                return true
            end
        end
        return false
    end)
    if not success then
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

SheriffTab:CreateToggle("SheriffWallCheckToggle", "Verificar Paredes (Wall Check)", function(estado)
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

SheriffTab:CreateToggle("AutoUnequipToggle", "Auto-Desequipar Inteligente (Smart Unequip)", function(estado)
    SheriffConfig.AutoUnequip = estado
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
-- 🧠 MOTOR CINEMÁTICO ULTRA-PREMIUM V2 (MATH & HITRATE PERFECTED)
-- ============================================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService") 
local NetworkClient = game:GetService("NetworkClient")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

local previousTargetVelocity = Vector3.new(0,0,0) 
local smoothedVelocity = Vector3.new(0,0,0)
local lastRawVelocity = Vector3.new(0,0,0) 
local lastTargetChar = nil
local lastDeltaTime = 0.016
local emaDeltaTime = 0.016 

local pingHistory = {}
local maxPingHistorySize = 15
local cachedPingValue = 0.03

local function getSmoothedPing()
    local rawPing = 0.03
    local success, server = pcall(function() return NetworkClient.RemoteConnect end)
    if success and server then
        rawPing = server.Ping / 1000
    else
        local statsNet = game:GetService("Stats"):FindFirstChild("Network")
        if statsNet and statsNet:FindFirstChild("ServerToClientPing") then
            rawPing = statsNet.ServerToClientPing:GetValue() / 1000
        end
    end
    
    table.insert(pingHistory, rawPing)
    if #pingHistory > maxPingHistorySize then table.remove(pingHistory, 1) end
    
    local sum = 0
    local validCount = 0
    for _, p in ipairs(pingHistory) do
        sum = sum + p
        validCount = validCount + 1
    end
    return validCount > 0 and (sum / validCount) or 0.03
end

task.spawn(function()
    while task.wait(0.1) do 
        cachedPingValue = getSmoothedPing()
    end
end)

local playerRoles = {}
local playerDeadStatus = {}
local currentTarget = nil
local lastTargetTime = 0
local isFiringCooldown = false

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
    PlayerDataChanged.OnClientEvent:Connect(parsePlayerData)
end

local RoundStart = ReplicatedStorage:FindFirstChild("RoundStart", true)
if RoundStart and RoundStart:IsA("RemoteEvent") then
    RoundStart.OnClientEvent:Connect(function(arg1, arg2)
        table.clear(playerRoles)
        table.clear(playerDeadStatus)
        parsePlayerData(arg2)
        parsePlayerData(arg1)
    end)
end

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
    for _, player in ipairs(Players:GetPlayers()) do
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
-- 🚀 MOTOR DE WALL CHECK FIXED
-- ============================================================================
local mapCastParams = RaycastParams.new()
mapCastParams.FilterType = Enum.RaycastFilterType.Exclude

local function isTargetVisible(targetPart, murdererChar)
    if not SheriffConfig.WallCheck then return true end
    if not targetPart or not murdererChar or not LocalPlayer.Character then return false end
    
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local gun = char:FindFirstChild("Gun") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Gun"))
    local originPos = (gun and gun:FindFirstChild("Handle")) and gun.Handle.Position or hrp.Position
    
    local ignoreList = {char, murdererChar, Camera}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then table.insert(ignoreList, p.Character) end
    end
    mapCastParams.FilterDescendantsInstances = ignoreList
    
    local selfWallCheck = workspace:Raycast(hrp.Position, originPos - hrp.Position, mapCastParams)
    if selfWallCheck and selfWallCheck.Instance.CanCollide and selfWallCheck.Instance.Transparency < 0.9 then 
        return false 
    end
    
    local direction = targetPart.Position - originPos
    local pathCheck = workspace:Raycast(originPos, direction, mapCastParams)
    if pathCheck and pathCheck.Instance.CanCollide and pathCheck.Instance.Transparency < 0.9 then
        return false 
    end
    
    return true
end

local function getBestTargetPart(murdererChar)
    if not murdererChar then return nil end
    local hrp = murdererChar:FindFirstChild("HumanoidRootPart")
    local head = murdererChar:FindFirstChild("Head")
    if hrp and isTargetVisible(hrp, murdererChar) then return hrp
    elseif head and isTargetVisible(head, murdererChar) then return head end
    return nil
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

    if distance <= SheriffConfig.CloseRangeZone then
        return targetPosition, targetPosition, targetPosition
    end

    if lastTargetChar ~= targetChar then
        smoothedVelocity = rawVelocity
        previousTargetVelocity = smoothedVelocity
        lastRawVelocity = rawVelocity
        lastTargetChar = targetChar
    end

    if rawVelocity.Magnitude > 45 then rawVelocity = rawVelocity.Unit * 45 end

    local dotProduct = 1
    if lastRawVelocity.Magnitude > 0.5 and rawVelocity.Magnitude > 0.5 then
        dotProduct = rawVelocity.Unit:Dot(lastRawVelocity.Unit)
    end
    lastRawVelocity = rawVelocity 

    local clampedDT = math.min(activeDT, 0.05) 
    local responseSpeed = (dotProduct < 0.7) and 25.0 or 14.0
    local adaptiveWeight = math.clamp(1 - math.exp(-responseSpeed * clampedDT), 0.1, 0.9)
    smoothedVelocity = smoothedVelocity:Lerp(rawVelocity, adaptiveWeight)

    local networkDelay = cachedPingValue + clampedDT + 0.015
    local horizontalTime = networkDelay * (SheriffConfig.HorizontalPred * 6.8)

    if SheriffConfig.AntiBaiting and dotProduct < 0.5 then
        horizontalTime = horizontalTime * math.clamp(dotProduct + 0.3, 0.1, 0.5)
    end

    local acceleration = (smoothedVelocity - previousTargetVelocity) / math.max(clampedDT, 0.001)
    if acceleration.Magnitude > 50 then acceleration = acceleration.Unit * 50 end
    previousTargetVelocity = smoothedVelocity

    local finalHorizontal = (smoothedVelocity * horizontalTime) + (0.5 * acceleration * (horizontalTime ^ 2))
    
    local maxShift = math.clamp(distance * 0.25, 2, 5.5)
    if finalHorizontal.Magnitude > maxShift then finalHorizontal = finalHorizontal.Unit * maxShift end

    local verticalOffset = Vector3.new(0, 0, 0)
    if humanoid.FloorMaterial == Enum.Material.Air or math.abs(smoothedVelocity.Y) > 0.5 then
        local verticalTime = networkDelay * (SheriffConfig.VerticalPred * 28.5)
        local pY = (smoothedVelocity.Y * verticalTime) - (0.5 * workspace.Gravity * (verticalTime ^ 2))
        verticalOffset = Vector3.new(0, pY, 0)
    end

    local finalPrediction = targetPosition + Vector3.new(finalHorizontal.X, 0, finalHorizontal.Z) + verticalOffset

    local floorY = getFloorHeight(hrp, targetChar)
    if floorY then
        local minAllowedY = floorY + 2.0 
        if finalPrediction.Y < minAllowedY then finalPrediction = Vector3.new(finalPrediction.X, minAllowedY, finalPrediction.Z) end
    end

    local pingPrediction = targetPosition + (smoothedVelocity * cachedPingValue)
    local lagPrediction = targetPosition + (smoothedVelocity * clampedDT)

    return finalPrediction, pingPrediction, lagPrediction
end

-- ============================================================================
-- 🌌 LINEAS DE RENDERIZADO OPTIMIZADAS
-- ============================================================================
local LagLine = Drawing.new("Line") 
LagLine.Color = Color3.fromRGB(150, 50, 255) 
LagLine.Thickness = 1.1; LagLine.ZIndex = 2; LagLine.Visible = false
table.insert(_G.KillerHubLines, LagLine)

local PingLine = Drawing.new("Line")
PingLine.Color = Color3.fromRGB(0, 100, 255) 
PingLine.Thickness = 1.1; PingLine.ZIndex = 3; PingLine.Visible = false
table.insert(_G.KillerHubLines, PingLine)

local LeadLine = Drawing.new("Line")
LeadLine.Color = Color3.fromRGB(0, 255, 100) 
LeadLine.Thickness = 1.1; LeadLine.ZIndex = 4; LeadLine.Visible = false
table.insert(_G.KillerHubLines, LeadLine)

local PredictionLine = Drawing.new("Line")
PredictionLine.Color = Color3.fromRGB(255, 35, 35) 
PredictionLine.Thickness = 1.5; PredictionLine.ZIndex = 5; PredictionLine.Visible = false
table.insert(_G.KillerHubLines, PredictionLine)

local pPos, piPos, lPos, ldPos
local currentScreenPred = Vector2.new(0,0)
local currentScreenPing = Vector2.new(0,0)
local currentScreenLag = Vector2.new(0,0)
local currentScreenLead = Vector2.new(0,0)
local firstFrame = true

RunService.Heartbeat:Connect(function(dt)
    lastDeltaTime = dt 
    emaDeltaTime = emaDeltaTime + 0.2 * (dt - emaDeltaTime)
    
    local murderer = getMurderer()
    if not murderer or not murderer.Character then 
        pPos = nil; return 
    end
    
    local targetChar = murderer.Character
    local tracerPart = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head")
    local localChar = LocalPlayer.Character
    local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")
    
    if tracerPart and localHrp then
        local distance = (tracerPart.Position - localHrp.Position).Magnitude
        local distFactor = math.clamp((distance - 4) / 16, 0, 1)
        
        pPos, piPos, lPos = getPredictedPosition(targetChar, tracerPart)
        
        local hand = localChar and (localChar:FindFirstChild("RightHand") or localChar:FindFirstChild("Right Arm"))
        if hand then
            local balancedVelocity = Vector3.new(smoothedVelocity.X, smoothedVelocity.Y * 0.5, smoothedVelocity.Z)
            ldPos = tracerPart.Position + (balancedVelocity * SheriffConfig.LeadTimePred * distFactor)
        else
            ldPos = nil
        end
    else
        pPos = nil
    end
end)

RunService.RenderStepped:Connect(function()
    local gun, _ = getGunLocation()
    local hasGun = not SheriffConfig.UseWeaponDetector or (gun ~= nil)
    local screenGui = game:GetService("CoreGui"):FindFirstChild("KillerHub_SheriffGui")
    if screenGui then screenGui.Enabled = SheriffConfig.ShowShootButton and hasGun end

    if not hasGun or not pPos then
        PredictionLine.Visible = false; PingLine.Visible = false; LagLine.Visible = false; LeadLine.Visible = false;
        firstFrame = true; return
    end

    local tSmooth = SheriffConfig.TracerSmoothness
    local screenOrigin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    local localChar = LocalPlayer.Character
    local hand = localChar and (localChar:FindFirstChild("RightHand") or localChar:FindFirstChild("Right Arm"))

    if lPos and SheriffConfig.ShowLagTracer then
        local screenPos, onScreen = Camera:WorldToViewportPoint(lPos)
        if onScreen then
            local target2D = Vector2.new(screenPos.X, screenPos.Y)
            currentScreenLag = (firstFrame or tSmooth == 1) and target2D or currentScreenLag:Lerp(target2D, tSmooth)
            LagLine.From = screenOrigin; LagLine.To = currentScreenLag; LagLine.Visible = true
        else LagLine.Visible = false end
    else LagLine.Visible = false end

    if piPos and SheriffConfig.ShowPingTracer then
        local screenPos, onScreen = Camera:WorldToViewportPoint(piPos)
        if onScreen then
            local target2D = Vector2.new(screenPos.X, screenPos.Y)
            currentScreenPing = (firstFrame or tSmooth == 1) and target2D or currentScreenPing:Lerp(target2D, tSmooth)
            PingLine.From = screenOrigin; PingLine.To = currentScreenPing; PingLine.Visible = true
        else PingLine.Visible = false end
    else PingLine.Visible = false end

    if ldPos and SheriffConfig.ShowLeadTracer and hand then
        local handScreenPos, handOnScreen = Camera:WorldToViewportPoint(hand.Position)
        local targetScreenPos, targetOnScreen = Camera:WorldToViewportPoint(ldPos)
        if handOnScreen and targetOnScreen then
            local target2D = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
            currentScreenLead = (firstFrame or tSmooth == 1) and target2D or currentScreenLead:Lerp(target2D, tSmooth)
            LeadLine.From = Vector2.new(handScreenPos.X, handScreenPos.Y); LeadLine.To = currentScreenLead; LeadLine.Visible = true
        else LeadLine.Visible = false end
    else LeadLine.Visible = false end

    if pPos and SheriffConfig.PredictTracer then
        local screenPos, onScreen = Camera:WorldToViewportPoint(pPos)
        if onScreen then
            local target2D = Vector2.new(screenPos.X, screenPos.Y)
            currentScreenPred = (firstFrame or tSmooth == 1) and target2D or currentScreenPred:Lerp(target2D, tSmooth)
            PredictionLine.From = screenOrigin; PredictionLine.To = currentScreenPred; PredictionLine.Visible = true
        else PredictionLine.Visible = false end
    else PredictionLine.Visible = false end
    
    firstFrame = false
end)

-- ============================================================================
-- ⚡ MOTOR DE DISPARO DIRECTO MEJORADO (INSTANT AUTO-EQUIP)
-- ============================================================================
local function fireAtMurdererDirectly()
    if isFiringCooldown then return end 
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or humanoid.Health <= 0 then return end 

    local gun, parent = getGunLocation()
    local murderer = getMurderer()

    if gun and murderer and murderer.Character then
        local targetChar = murderer.Character
        local bestPart = getBestTargetPart(targetChar) 
        
        if bestPart and isTargetVisible(bestPart, targetChar) then 
            local predictedPos = getPredictedPosition(targetChar, bestPart)
            if predictedPos then
                isFiringCooldown = true 
                local wasInBackpack = (parent == LocalPlayer.Backpack) or (gun.Parent ~= char)

                if wasInBackpack then 
                    -- Forzar equipado inmediato
                    humanoid:EquipTool(gun)
                    
                    -- Hilo ultra veloz que monitorea el equipamiento real en el personaje
                    task.spawn(function()
                        local timeout = 0
                        while gun.Parent ~= char and timeout < 30 do
                            RunService.Heartbeat:Wait() -- Espera exacta de tasa de frames física
                            timeout = timeout + 1
                        end
                        
                        -- En cuanto se detecta en la mano, dispara sin perder milisegundos
                        if gun.Parent == char and gun:FindFirstChild("Shoot") then
                            local originCFrame = hrp.CFrame
                            if hrp:FindFirstChild("GunRaycastAttachment") then originCFrame = hrp.GunRaycastAttachment.WorldCFrame end
                            gun.Shoot:FireServer(originCFrame, CFrame.new(predictedPos))
                        end

                        if SheriffConfig.AutoUnequip then
                            task.wait(0.05)
                            if gun.Parent == char then humanoid:UnequipTools() end
                        end
                        isFiringCooldown = false
                    end)
                else
                    -- Si ya estaba en la mano, sale instantáneo
                    if gun.Parent == char and gun:FindFirstChild("Shoot") then
                        local originCFrame = hrp.CFrame
                        if hrp:FindFirstChild("GunRaycastAttachment") then originCFrame = hrp.GunRaycastAttachment.WorldCFrame end
                        gun.Shoot:FireServer(originCFrame, CFrame.new(predictedPos))
                    end 
                    
                    if SheriffConfig.AutoUnequip then 
                        task.spawn(function()
                            task.wait(0.05) 
                            if gun.Parent == char then humanoid:UnequipTools() end
                        end)
                    end 
                    task.wait(0.05)
                    isFiringCooldown = false
                end 
            end
        end
    end
end

-- ============================================================================
-- 🌌 INTERFAZ V4.0 (BOTÓN INTERACTIVO)
-- ============================================================================
local VoidGui = Instance.new("ScreenGui")
VoidGui.Name = "KillerHub_SheriffGui"; VoidGui.ResetOnSpawn = false; VoidGui.Parent = game:GetService("CoreGui")

local ShootButton = Instance.new("ImageButton")
ShootButton.Name = "ShootButton"
ShootButton.Size = UDim2.new(0, SheriffConfig.ButtonSize, 0, SheriffConfig.ButtonSize)
ShootButton.Position = UDim2.new(SheriffConfig.ButtonX, 0, SheriffConfig.ButtonY, 0)
ShootButton.BackgroundColor3 = Color3.fromRGB(15, 6, 26)
ShootButton.BackgroundTransparency = 1 - SheriffConfig.ButtonOpacity
ShootButton.BorderSizePixel = 0; ShootButton.AutoButtonColor = false; ShootButton.ClipsDescendants = true; ShootButton.Parent = VoidGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, math.floor(SheriffConfig.ButtonSize * 0.28)); Corner.Parent = ShootButton

local GlowOverlay = Instance.new("Frame")
GlowOverlay.Name = "GlowOverlay"; GlowOverlay.Size = UDim2.new(1, 0, 1, 0); GlowOverlay.Position = UDim2.new(0, 0, 0, 0)
GlowOverlay.BackgroundTransparency = 1; GlowOverlay.ZIndex = ShootButton.ZIndex + 1; GlowOverlay.Parent = ShootButton

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = Corner.CornerRadius; GlowCorner.Parent = GlowOverlay

local UiGradient = Instance.new("UIGradient")
UiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 8, 43)),    
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(131, 46, 222)),  
    ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 8, 43))
})
UiGradient.Rotation = 45; UiGradient.Parent = GlowOverlay

local DecalTexture = Instance.new("ImageLabel")
DecalTexture.Name = "DecalTexture"; DecalTexture.Size = UDim2.new(0.38, 0, 0.38, 0); DecalTexture.AnchorPoint = Vector2.new(0.5, 0.5)
DecalTexture.Position = UDim2.new(0.5, 0, 0.45, 0); DecalTexture.BackgroundTransparency = 1; DecalTexture.Image = "rbxassetid://125754446555599"
DecalTexture.ImageTransparency = 1 - SheriffConfig.ButtonOpacity; DecalTexture.ZIndex = ShootButton.ZIndex + 2; DecalTexture.Parent = ShootButton

local function iniciarAnimacionIcono(decalTexture)
    if not decalTexture then return end
    local infoGiro = TweenInfo.new(0.8020, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tweenIda = TweenService:Create(decalTexture, infoGiro, {Rotation = 360})
    local tweenVuelta = TweenService:Create(decalTexture, infoGiro, {Rotation = 0})
    tweenIda.Completed:Connect(function() task.wait(0.0295); tweenVuelta:Play() end)
    tweenVuelta.Completed:Connect(function() task.wait(0.0295); tweenIda:Play() end)
    tweenIda:Play()
end
iniciarAnimacionIcono(DecalTexture)

local Label = Instance.new("TextLabel")
Label.Name = "Label"; Label.Size = UDim2.new(1, 0, 0.2, 0); Label.Position = UDim2.new(0, 0, 0.75, 0)
Label.BackgroundTransparency = 1; Label.Text = "SHOOT"; Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.TextSize = 15; Label.Font = Enum.Font.GothamBold; Label.TextTransparency = 1 - SheriffConfig.ButtonOpacity
Label.ZIndex = ShootButton.ZIndex + 2; Label.Parent = ShootButton

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
ShootButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        processGlowAtCoordinates(input.Position)
        task.spawn(fireAtMurdererDirectly)
        
        if not SheriffConfig.ButtonLocked then
            dragging = true; dragStart = input.Position; startPos = ShootButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    SheriffConfig.ButtonX = ShootButton.Position.X.Scale
                    SheriffConfig.ButtonY = ShootButton.Position.Y.Scale
                    saveConfig()
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
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ShootButton.Position = UDim2.new(startPos.X.Scale + (delta.X / Camera.ViewportSize.X), 0, startPos.Y.Scale + (delta.Y / Camera.ViewportSize.Y), 0)
    end
end)

-- ============================================================================
-- ⚡ MEJORA HOOKS POR INTERCEPCIÓN METAMETHOD (ANTI-CHEAT PROOF)
-- ============================================================================
local ClientServices = ReplicatedStorage:WaitForChild("ClientServices", 5)
if ClientServices then
    local WeaponService = require(ClientServices:WaitForChild("WeaponService"))
    
    local function modifiqueTrayectoria(originalRet, cframeRequerido)
        local gun, _ = getGunLocation()
        if SheriffConfig.SilentAim and (not SheriffConfig.UseWeaponDetector or (gun ~= nil)) then
            local murderer = getMurderer()
            if murderer and murderer.Character then
                local targetChar = murderer.Character
                local bestPart = getBestTargetPart(targetChar)
                if bestPart then
                    local predictedPos = getPredictedPosition(targetChar, bestPart, 0.012)
                    if predictedPos then 
                        return cframeRequerido and CFrame.new(predictedPos) or predictedPos 
                    end
                end
            end
        end
        return originalRet
    end

    if hookfunction or replaceclosure then
        local targetHook = hookfunction or replaceclosure
        pcall(function()
            local oldTargetPos
            oldTargetPos = targetHook(WeaponService.GetTargetPosition, function(self, ...)
                return modifiqueTrayectoria(oldTargetPos(self, ...), false)
            end)
            
            local oldTargetCF
            oldTargetCF = targetHook(WeaponService.GetMouseTargetCFrame, function(self, ...)
                return modifiqueTrayectoria(oldTargetCF(self, ...), true)
            end)
        end)
    else
        local oldGetTargetPosition = WeaponService.GetTargetPosition
        local oldGetMouseTargetCFrame = WeaponService.GetMouseTargetCFrame
        
        WeaponService.GetTargetPosition = function(self, ...)
            return modifiqueTrayectoria(oldGetTargetPosition(self, ...), false)
        end
        WeaponService.GetMouseTargetCFrame = function(self, ...)
            return modifiqueTrayectoria(oldGetMouseTargetCFrame(self, ...), true)
        end
    end
end

-- ============================================================================
-- 💫 RETORNO INFINITO DE LIBRERÍA GITHUB
-- ============================================================================
return KillerHub
