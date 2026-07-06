-- ============================================================================
--  KILLER HUB | SHERIFF V8.0.1 [🔥 FULL MÓVIL BLINDADO & RENDIMIENTO FIJADO]
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
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Camera = workspace.CurrentCamera

-- ⚡ UPVALUES REALES (RENDIMIENTO AL MÁXIMO)
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

local VECTOR_ZERO = vec3New(0, 0, 0)
local ignoreList = {}

-- 1. LIMPIEZA TOTAL DE MEMORIA PREVIA
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

-- 2. CARGA DE LA LIBRERÍA DE INTERFAZ ORIGINAL (v3.1 UI LAYOUT)
local success, KillerHubLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Salayer09/KillerHub/refs/heads/main/Slayer.lua"))()
end)

if not success or not KillerHubLib then
    warn("⚠️ KillerHub Crítico: No se pudo cargar InterfazBase.")
    return
end
local KillerHub = KillerHubLib

-- 3. CONFIGURACIÓN PREDETERMINADA REAL
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
    PredictTracer = true,      
    ShowMinPredictTracer = true, 
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

-- 4. AUTO-GUARDADO PERSISTENTE
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
                ShowLeadTracer = SheriffConfig.ShowLeadTracer,
                CloseRangeZone = SheriffConfig.CloseRangeZone,
                AntiBaiting = SheriffConfig.AntiBaiting
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
                if data.AntiBaiting ~= nil then SheriffConfig.AntiBaiting = data.AntiBaiting end
            end
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
    if tool:FindFirstChild("Stab") or tool.Name == "Knife" then return true end
    return false
end

local cachedScreenGui, cachedShootButton

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
            for _, item in pairs(char:GetChildren()) do if isRangedWeapon(item) then hasGun = true break end end
        end
        if not hasGun and backpack then
            for _, item in pairs(backpack:GetChildren()) do if isRangedWeapon(item) then hasGun = true break end end
        end
        cachedScreenGui.Enabled = hasGun
    else
        cachedScreenGui.Enabled = true
    end
end

-- ============================================================================
-- 👁️ MENÚ DE LA UI ORIGINAL V3.1
-- ============================================================================
local SheriffTab = KillerHub:CreateTab("Sheriff", "rbxassetid://10747373142")
SheriffTab:CreateSection("Ajustes del Silent Aim")

SheriffTab:CreateToggle("SheriffSilent", "Activar Silent Aim Pasivo", function(estado)
    SheriffConfig.SilentAim = estado
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
    "Lead (Verde)"
}, function(tablaFlags)
    SheriffConfig.PredictTracer = tablaFlags["Impacto Final (Rojo)"]
    SheriffConfig.ShowMinPredictTracer = tablaFlags["Predicción Mínima (Amarillo)"]
    SheriffConfig.ShowLeadTracer = tablaFlags["Lead (Verde)"]
    saveConfig()
end)

SheriffTab:CreateSlider("TracerSmoothSlider", "Estabilizador Anti-Temblor", 1, 100, function(valor)
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
        local newRadius = UDim.new(0, math_floor(valor * 0.28))
        cachedShootButton.Size = udim2New(0, valor, 0, valor) 
        if cachedShootButton:FindFirstChild("UICorner") then cachedShootButton.UICorner.CornerRadius = newRadius end
        local glow = cachedShootButton:FindFirstChild("GlowOverlay")
        if glow and glow:FindFirstChild("GlowCorner") then glow.GlowCorner.CornerRadius = newRadius end
    end
end, SheriffConfig.ButtonSize)

-- ============================================================================
-- 🧠 CORE LOGIC MM2 (CACHING CON RESPETO DE TIEMPO EFICIENTE)
-- ============================================================================
local MurdererDetectado = nil
local lastMurdererCheckTime = 0 
local smoothedVelocity = VECTOR_ZERO
local lastTargetChar = nil
local emaDeltaTime = 0.016 

local playerRoles = {}
local playerDeadStatus = {}
local currentTarget = nil
local isFiringCooldown = false

local function setTarget(newTarget) currentTarget = newTarget end

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

local function autoEquipWeapon()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if character and character:FindFirstChild("Humanoid") and backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if isRangedWeapon(item) then character.Humanoid:EquipTool(item) break end
        end
    end
end

local function getGunLocation()
    local char = LocalPlayer.Character
    if char then
        for _, item in pairs(char:GetChildren()) do if isRangedWeapon(item) then return item, char end end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, item in pairs(bp:GetChildren()) do if isRangedWeapon(item) then return item, bp end end
    end
    return nil, nil
end

local function getMurderer()
    local currentTime = os_clock()
    if MurdererDetectado and MurdererDetectado.Parent and MurdererDetectado.Character then
        local name = MurdererDetectado.Name
        local char = MurdererDetectado.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not ((hum and hum.Health <= 0) or (playerDeadStatus[name] == true)) and playerRoles[name] == "Murderer" then
            setTarget(MurdererDetectado)
            return MurdererDetectado
        else MurdererDetectado = nil end
    end

    -- Control de tiempo estricto: no escanea a todos en cada frame de forma descontrolada
    if currentTime - lastMurdererCheckTime < 0.25 then return currentTarget end
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
                        MurdererDetectado = player
                        setTarget(player)
                        return player
                    end
                end
            end
         end
    end
    setTarget(nil)
    return nil
end

local mapCastParams = RaycastParams.new()
mapCastParams.FilterType = Enum.RaycastFilterType.Exclude

local function getSmartTargetPart(targetChar)
    if not targetChar then return nil end
    local torso = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso")
    if not SheriffConfig.WallCheck then return torso end

    local origin = Camera.CFrame.Position
    table.clear(ignoreList)
    table.insert(ignoreList, LocalPlayer.Character)
    table.insert(ignoreList, Camera)
    for _, p in pairs(Players:GetPlayers()) do if p.Character then table.insert(ignoreList, p.Character) end end
    
    local pets = workspace:FindFirstChild("Pets") or workspace:FindFirstChild("PetFolder")
    if pets then table.insert(ignoreList, pets) end
    mapCastParams.FilterDescendantsInstances = ignoreList
    
    if torso then
        local ray = workspace:Raycast(origin, torso.Position - origin, mapCastParams)
        if not ray or (ray.Instance.CanCollide == false or ray.Instance.Transparency >= 0.85) then return torso end
    end
    return torso
end

-- ============================================================================
-- 📈 MOTOR DE BALÍSTICA BLINDADO MÓVIL (SÚPER PREDICCIÓN EXCLUSIVA OMNI)
-- ============================================================================
local function getPredictedPosition(targetChar, targetPart, customDelta)
    if not targetChar or not targetPart then return nil, nil end
    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not humanoid or humanoid.Health <= 0 or not localHrp then return nil, nil end

    local activeDT = customDelta or emaDeltaTime
    local targetPosition = targetPart.Position
    local rawVelocity = hrp.AssemblyLinearVelocity
    local distance = (targetPosition - localHrp.Position).Magnitude

    -- 🔥 [MEJORA 3]: Blindado contra Glitches de Animación / Emotes en MM2
    if humanoid.MoveDirection.Magnitude == 0 and rawVelocity.Magnitude > 2 then
        rawVelocity = VECTOR_ZERO 
    elseif rawVelocity.Magnitude < 0.6 then 
        rawVelocity = VECTOR_ZERO 
    end

    local predictionWeight = 1
    if distance <= SheriffConfig.CloseRangeZone then predictionWeight = 0 end

    if lastTargetChar ~= targetChar then
        smoothedVelocity = rawVelocity
        lastTargetChar = targetChar
    end

    local maxExpectedSpeed = math_max(humanoid.WalkSpeed * 2.0, 36)
    if rawVelocity.Magnitude > maxExpectedSpeed then rawVelocity = rawVelocity.Unit * maxExpectedSpeed end

    -- Suavizado adaptativo dinámico según el modo elegido
    local responseSpeed = 16.5
    local mode = SheriffConfig.PredictionMode
    if mode == "Predictiva 2.0 (Aceleración)" then
        responseSpeed = 28.0 
    elseif mode == "Predictivo Adaptativo" then
        responseSpeed = 9.5  
    end
    
    smoothedVelocity = smoothedVelocity:Lerp(rawVelocity, math_clamp(1 - math_exp(-responseSpeed * math_min(activeDT, 0.05)), 0.10, 0.85))

    -- 🔥 [MEJORA 2]: Retorno Seguro de Ping (Pcall blindado contra errores en Móvil/PC)
    local rawPing = 0.06
    pcall(function()
        local performanceStats = Stats:FindFirstChild("Network")
        if performanceStats and performanceStats:FindFirstChild("ServerToClientPing") then
            rawPing = performanceStats.ServerToClientPing:GetValue() / 1000
        else
            rawPing = LocalPlayer:GetNetworkPitch() or 0.06
        end
    end)

    local pingCompensation = 1.0 + (rawPing * 1.85)

    -- 🔥 [MEJORA 1]: Factor de Escala por Distancia Dinámica (Dynamic Distance Scaling)
    local distanceFactor = math_clamp(22 / distance, 0.38, 1.25)

    local multiplierMax = SheriffConfig.HorizontalPredMax
    local multiplierMin = SheriffConfig.HorizontalPredMin
    
    if mode == "Predictivo Adaptativo" then
        smoothedVelocity = vec3New(smoothedVelocity.X, 0, smoothedVelocity.Z)
    end

    local timeFrameTotal = multiplierMax * 0.5 * distanceFactor * pingCompensation * predictionWeight
    local timeFrameMin = multiplierMin * 0.5 * distanceFactor * pingCompensation * predictionWeight

    local finalHorizontal = smoothedVelocity * timeFrameTotal
    local minHorizontal = smoothedVelocity * timeFrameMin

    local maxHorizontalShift = 4.2 
    if finalHorizontal.Magnitude > maxHorizontalShift then finalHorizontal = finalHorizontal.Unit * maxHorizontalShift end
    if minHorizontal.Magnitude > maxHorizontalShift then minHorizontal = minHorizontal.Unit * maxHorizontalShift end

    -- Predicción Vertical Reactiva Real (Eje Y) si salta o cae
    local verticalOffsetMax = VECTOR_ZERO
    if math_abs(smoothedVelocity.Y) > 0.5 then
        local verticalFactor = SheriffConfig.VerticalPredMax * (1 + rawPing) * predictionWeight
        verticalOffsetMax = vec3New(0, smoothedVelocity.Y * verticalFactor, 0)
    end

    return targetPosition + vec3New(finalHorizontal.X, 0, finalHorizontal.Z) + verticalOffsetMax, targetPosition + vec3New(minHorizontal.X, 0, minHorizontal.Z)
end

-- ============================================================================
-- 🌌 SECCIÓN DE RENDERS TRACERS BALÍSTICOS
-- ============================================================================
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
local currentScreenLead = vec2New(0,0)
local firstFrame = true

local renderConn = RunService.RenderStepped:Connect(function(dt)
    emaDeltaTime = emaDeltaTime + 0.2 * (dt - emaDeltaTime) 
    checkWeaponVisibility()
    local murderer = getMurderer()

    if not murderer or not murderer.Character then
        PredictionLine.Visible = false; MinPredictionLine.Visible = false; LeadLine.Visible = false;
        firstFrame = true
        return
    end

    local targetChar = murderer.Character
    local localChar = LocalPlayer.Character
    local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")
    local visualPart = targetChar:FindFirstChild("HumanoidRootPart")

    if visualPart and localHrp then
        local distance = (visualPart.Position - localHrp.Position).Magnitude
        local tSmooth = SheriffConfig.TracerSmoothness
        local predictedPos, minPredictedPos = getPredictedPosition(targetChar, visualPart)
        local screenOrigin = vec2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

        local hand = localChar and (localChar:FindFirstChild("RightHand") or localChar:FindFirstChild("Right Arm"))
        if SheriffConfig.ShowLeadTracer and hand and visualPart then
            local leadPredictedPos = visualPart.Position + (smoothedVelocity * SheriffConfig.LeadTimePred * math_clamp((distance - 4) / 16, 0, 1))
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
        PredictionLine.Visible = false; MinPredictionLine.Visible = false; LeadLine.Visible = false;
        firstFrame = true
    end 
end)
table.insert(_G.KillerHubConnections, renderConn)

-- ============================================================================
-- ⚡ DISPARADOR DE BOTÓN - ACCIÓN DIRECTA PASIVA
-- ============================================================================
local function fireAtMurdererDirectly()
    if isFiringCooldown then return end 
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end 

    local murderer = getMurderer()
    if murderer and murderer.Character then
        local bestPart = getSmartTargetPart(murderer.Character) 
        if bestPart then 
            local predictedPos = getPredictedPosition(murderer.Character, bestPart)
            if predictedPos then
                isFiringCooldown = true 
                autoEquipWeapon()
                local gun = getGunLocation()
                local shootRemote = gun and gun:FindFirstChild("Shoot")
                if shootRemote then
                    local originCFrame = char.HumanoidRootPart.CFrame
                    if char.HumanoidRootPart:FindFirstChild("GunRaycastAttachment") then originCFrame = char.HumanoidRootPart.GunRaycastAttachment.WorldCFrame end
                    shootRemote:FireServer(originCFrame, cframeNew(predictedPos))
                end
                task.wait(0.04) 
                isFiringCooldown = false
            end
        end
     end
end

-- ============================================================================
-- 🌌 ELEMENTOS VISUALES | INTERRUPTOR FLOTANTE CON CYBER-GLOW CORREGIDO
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

-- ✨ GLOW CORREGIDO Y CENTRALIZADO AL 100% (No desfasa en las esquinas al agrandarse)
local GlowOverlay = Instance.new("Frame")
GlowOverlay.Name = "GlowOverlay"
GlowOverlay.Size = udim2New(1, 0, 1, 0) 
GlowOverlay.Position = udim2New(0, 0, 0, 0)
GlowOverlay.BackgroundTransparency = 1
GlowOverlay.ZIndex = ShootButton.ZIndex + 1
GlowOverlay.Parent = ShootButton

local GlowCorner = Instance.new("UICorner")
GlowCorner.Name = "GlowCorner"
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
DecalTexture.Size = udim2New(0.37, 0, 0.37, 0)
DecalTexture.AnchorPoint = vec2New(0.5, 0.5)
DecalTexture.Position = udim2New(0.5, 0, 0.44, 0)
DecalTexture.BackgroundTransparency = 1
DecalTexture.Image = "rbxassetid://125754446555599"
DecalTexture.ImageTransparency =  1 - SheriffConfig.ButtonOpacity
DecalTexture.ZIndex = ShootButton.ZIndex + 2
DecalTexture.Parent = ShootButton

task.spawn(function()
    local infoGiro = TweenInfo.new(0.80, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tweenIda = TweenService:Create(DecalTexture, infoGiro, {Rotation = 360})
    local tweenVuelta = TweenService:Create(DecalTexture, infoGiro, {Rotation = 0})
    tweenIda.Completed:Connect(function() task.wait(0.03) tweenVuelta:Play() end)
    tweenVuelta.Completed:Connect(function() task.wait(0.03) tweenIda:Play() end)
    tweenIda:Play()
end)

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

local dragging, dragInput, dragStart, startPos
ShootButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local localX = input.Position.X - ShootButton.AbsolutePosition.X
        UiGradient.Offset = vec2New(((localX / ShootButton.AbsoluteSize.X) - 0.5) * 1.5, 0)
        TweenService:Create(GlowOverlay, TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.39}):Play()
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

ShootButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        TweenService:Create(GlowOverlay, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    end
end)

ShootButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ShootButton.Position = udim2New(startPos.X.Scale + (delta.X / Camera.ViewportSize.X), 0, startPos.Y.Scale + (delta.Y / Camera.ViewportSize.Y), 0)
    end
end)

-- ============================================================================
-- ⚡ METODOS HOOK ARMAS MODDED
-- ============================================================================
local WeaponService = nil
local ClientServices = ReplicatedStorage:FindFirstChild("ClientServices") or ReplicatedStorage:FindFirstChild("Services")
if ClientServices then
    local ws = ClientServices:FindFirstChild("WeaponService") or ClientServices:FindFirstChild("GunService")
    if ws and ws:IsA("ModuleScript") then pcall(function() WeaponService = require(ws) end) end
end

if WeaponService then
    local oldGetTargetPosition = WeaponService.GetTargetPosition
    local oldGetMouseTargetCFrame = WeaponService.GetMouseTargetCFrame
    local lastHookCallTime = os_clock()

    local function checkAndPredict(returnCFrame)
        local hookDelta = os_clock() - lastHookCallTime
        lastHookCallTime = os_clock()
        if SheriffConfig.SilentAim and (not SheriffConfig.UseWeaponDetector or (getGunLocation() ~= nil)) then
            local murderer = getMurderer()
            if murderer and murderer.Character then
                local bestPart = getSmartTargetPart(murderer.Character)
                if bestPart then
                    local predictedPos = getPredictedPosition(murderer.Character, bestPart, math_clamp(hookDelta, 0.008, 0.033))
                     if predictedPos then return returnCFrame and cframeNew(predictedPos) or predictedPos end
                end
            end
        end
        return nil
    end

    if oldGetTargetPosition then
        WeaponService.GetTargetPosition = function(self, ...)
            return checkAndPredict(false) or oldGetTargetPosition(self, ...)
        end
    end
    if oldGetMouseTargetCFrame then
        WeaponService.GetMouseTargetCFrame = function(self, ...)
            return checkAndPredict(true) or oldGetMouseTargetCFrame(self, ...)
        end
    end
end

return KillerHub
