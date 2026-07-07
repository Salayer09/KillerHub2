-- ============================================================================
--  KILLER HUB | SHERIFF SUITE V9.0.0 (UNIVERSAL PRED & RED RESOLVER REBOOT)
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
local os_clock = os.clock

local workspace = workspace
local workspace_Gravity = workspace.Gravity

local VECTOR_ZERO = vec3New(0, 0, 0)

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

local success, KillerHubLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Salayer09/KillerHub/refs/heads/main/Slayer.lua"))()
end)

if not success or not KillerHubLib then
    warn("Critical: GUI Library failure.")
    return
end
local KillerHub = KillerHubLib

-- CONFIGURACIÓN AJUSTADA: SLIDERS INTUITIVOS Y ADAPTATIVOS
local SheriffConfig = {
    SilentAim = false,
    PredictionMode = "Omni-Direccional Absoluto (Universal)", 
    HorizontalScale = 100,  -- 100 = Multiplicador base x1.0 (Ajustable para cada PC/Ping)
    VerticalScale = 100,    -- 100 = Multiplicador base x1.0 para saltos
    PingCompensation = 100, -- 100 = 100% del ping actual (Ajuste fino de red)
    CloseRangeZone = 6, 
    WallCheck = true,    
    FiltroCaminadora = true, 
    EstabilizadorInercial = true,
    PredictTracer = true,      -- Tracer Rojo (Impacto)
    ShowMinPredictTracer = true, -- Tracer Amarillo (Mínimo)
    TracerSmoothness = 0.85, 
    UseWeaponDetector = false, 
    ShowShootButton = false,
    ButtonSize = 95,
    ButtonOpacity = 0.95, 
    ButtonX = 0.7, 
    ButtonY = 0.6
}

local HttpService = game:GetService("HttpService")
local CONFIG_FILE = "KillerHub_SheriffSuite_v9.txt"

local function saveConfig()
    pcall(function()
        if writefile then
            writefile(CONFIG_FILE, HttpService:JSONEncode(SheriffConfig))
        end
    end)
end

local function loadConfig()
    pcall(function()
        if isfile and isfile(CONFIG_FILE) then
            local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
            if data then
                for k, v in pairs(data) do
                    if SheriffConfig[k] ~= nil then SheriffConfig[k] = v end
                end
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

SheriffTab:CreateDropdown("PredMode", "Modo de Predicción:", {"Omni-Direccional Absoluto (Universal)", "Lineal Simple"}, function(seleccionado)
    SheriffConfig.PredictionMode = seleccionado
    saveConfig()
end)

SheriffTab:CreateSection("Calibración del Entorno (Ping & FPS)")

SheriffTab:CreateSlider("HorizontalScaleSlider", "Predicción Horizontal (X/Z)", 0, 300, function(valor)
    SheriffConfig.HorizontalScale = valor
    saveConfig() 
end, SheriffConfig.HorizontalScale)

SheriffTab:CreateSlider("VerticalScaleSlider", "Predicción Vertical (Saltos/Eje Y)", 0, 300, function(valor)
    SheriffConfig.VerticalScale = valor
    saveConfig() 
end, SheriffConfig.VerticalScale)

SheriffTab:CreateSlider("PingCompSlider", "Compensador de Latencia/Ping (%)", 0, 200, function(valor)
    SheriffConfig.PingCompensation = valor
    saveConfig() 
end, SheriffConfig.PingCompensation)

SheriffTab:CreateSlider("CloseRangeZoneSlider", "Zona Muerta Quemarropa (Studs)", 0, 20, function(valor)
    SheriffConfig.CloseRangeZone = valor
    saveConfig()
end, SheriffConfig.CloseRangeZone)

SheriffTab:CreateSection("Filtros Anti-Errores Reales")

SheriffTab:CreateToggle("FiltroCaminadoraToggle", "Filtro Caminadora Invisible (Anti-Lag Extremo)", function(estado)
    SheriffConfig.FiltroCaminadora = estado
    saveConfig()
end)

SheriffTab:CreateToggle("EstabilizadorInercialToggle", "Estabilizador de Fintas (Anti-ZigZag)", function(estado)
    SheriffConfig.EstabilizadorInercial = estado
    saveConfig()
end)

SheriffTab:CreateSlider("TracerSmoothSlider", "Suavizado de Mira (1 = Reactivo/Instantáneo)", 1, 100, function(valor)
    if valor == 1 then
        SheriffConfig.TracerSmoothness = 1 
    else
        SheriffConfig.TracerSmoothness = 0.98 - ((valor - 2) / 98) * 0.85
    end
    saveConfig()
end, 85)

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
    if cachedShootButton then cachedShootButton.Size = udim2New(0, valor, 0, valor) end
end, SheriffConfig.ButtonSize)

local MurdererDetectado = nil
local smoothedVelocity = VECTOR_ZERO
local lastRawVelocity = VECTOR_ZERO 
local lastTargetChar = nil
local emaDeltaTime = 0.016 

local cachedPingValue = 0.06
local playerRoles = {}
local playerDeadStatus = {}
local currentTarget = nil
local isFiringCooldown = false
local positionHistory = {}
local MAX_HISTORY_FRAMES = 5

task.spawn(function()
    while task.wait(0.5) do
        if Stats and Stats:FindFirstChild("Network") and Stats.Network:FindFirstChild("ServerToClientPing") then
            cachedPingValue = Stats.Network.ServerToClientPing:GetValue() / 1000
        end
    end
end)

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
        table.clear(positionHistory)
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
        for _, item in pairs(char:GetChildren()) do if isRangedWeapon(item) then return item, char end end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, item in pairs(bp:GetChildren()) do if isRangedWeapon(item) then return item, bp end end
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
            setTarget(MurdererDetectado)
            return MurdererDetectado
        else MurdererDetectado = nil end
    end

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

    if potentialMurderer then MurdererDetectado = potentialMurderer else setTarget(nil) end
    return currentTarget
end

local mapCastParams = RaycastParams.new()
mapCastParams.FilterType = Enum.RaycastFilterType.Exclude
local ignoreListCache = {} 

local function getSmartTargetPart(targetChar)
    if not targetChar then return nil end
    local torso = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso")
    if not SheriffConfig.WallCheck then return torso end

    local origin = Camera.CFrame.Position
    table.clear(ignoreListCache)
    table.insert(ignoreListCache, LocalPlayer.Character)
    table.insert(ignoreListCache, Camera)
    
    local allPlayers = Players:GetPlayers()
    for i = 1, #allPlayers do
        local p = allPlayers[i]
        if p.Character then table.insert(ignoreListCache, p.Character) end
    end
    
    mapCastParams.FilterDescendantsInstances = ignoreListCache
    if torso then
        local direction = torso.Position - origin
        local ray = workspace:Raycast(origin, direction, mapCastParams)
        if not ray or (ray.Instance.CanCollide == false or ray.Instance.Transparency >= 0.85) then return torso end
    end
    return torso
end

local function getFloorHeight(targetHrp, targetChar)
    if not targetHrp then return nil end
    floorCastParams.FilterDescendantsInstances = {targetChar, LocalPlayer.Character, Camera}
    local ray = workspace:Raycast(targetHrp.Position, vec3New(0, -25, 0), floorCastParams)
    return ray and ray.Position.Y or nil
end

-- ============================================================================
--  MOTOR DE PREDICCIÓN V9.0.0 (RESOLVER INTEGRADO AUTOMÁTICO)
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

    -- REGISTRO DE HISTORIAL FÍSICO REAL (SÓLO PARA DETECTAR LAG)
    if not positionHistory[targetChar] then positionHistory[targetChar] = {} end
    local history = positionHistory[targetChar]
    table.insert(history, 1, targetPosition)
    if #history > MAX_HISTORY_FRAMES then table.remove(history, #history) end

    -- RESOLVER 1: ANTI-AVATARS ULTRA ENANOS (ESTABILIZACIÓN DE MATRIZ)
    local heightScale = humanoid:FindFirstChild("BodyHeightScale") and humanoid.BodyHeightScale.Value or 1.0
    local widthScale = humanoid:FindFirstChild("BodyWidthScale") and humanoid.BodyWidthScale.Value or 1.0
    if heightScale < 0.75 or widthScale < 0.75 then
        -- Los avatares nano desfasan las articulaciones, forzamos el anclaje central en el HRP real
        targetPosition = hrp.Position
    end

    -- RESOLVER 2: FILTRO CAMINADORA INVISIBLE (ANTI-LAG Y BLOQUEOS DE PARED)
    if SheriffConfig.FiltroCaminadora and #history >= 3 then
        local desplazamientoReal = (history[1] - history[#history]).Magnitude
        -- Si el motor dice que corre rápido pero su posición en el mapa no cambia, está bugeado o laggeado en una pared
        if rawVelocity.Magnitude > 4 and desplazamientoReal < 1.2 then
            rawVelocity = VECTOR_ZERO
        end
    end

    -- FACTORES AJUSTADOS POR SLIDERS (Dinámicos y limpios)
    local hMultiplier = (SheriffConfig.HorizontalScale / 100)
    local vMultiplier = (SheriffConfig.VerticalScale / 100)
    local pComp = (SheriffConfig.PingCompensation / 100)
    
    local totalLatency = (cachedPingValue * pComp) + activeDT
    
    -- Restricción por Zona Quemarropa (Útil)
    local predictionWeight = 1
    if distance <= SheriffConfig.CloseRangeZone then predictionWeight = 0 end

    if lastTargetChar ~= targetChar then
        smoothedVelocity = rawVelocity
        lastRawVelocity = rawVelocity
        lastTargetChar = targetChar
    end

    -- MODO DE PREDICCIÓN 1: OMNI-DIRECCIONAL ABSOLUTO (EL MEJOR - TODO TERRENO)
    if SheriffConfig.PredictionMode == "Omni-Direccional Absoluto (Universal)" then
        local dotProduct = 1
        if lastRawVelocity.Magnitude > 0.5 and rawVelocity.Magnitude > 0.5 then
            dotProduct = rawVelocity.Unit:Dot(lastRawVelocity.Unit)
        end
        lastRawVelocity = rawVelocity

        -- RESOLVER 3: ESTABILIZADOR INERCIAL PARA FINTAS, ZIG-ZAG CORTO Y LARGO
        if SheriffConfig.EstabilizadorInercial and dotProduct < 0.4 then
            -- Suavizado adaptativo de baja frecuencia (Dampening) para que la mira no sufra de latigazos bruscos
            smoothedVelocity = smoothedVelocity:Lerp(rawVelocity, 0.14)
        else
            -- Sigue el movimiento fluido si va en línea recta o curvas largas
            smoothedVelocity = smoothedVelocity:Lerp(rawVelocity, 0.48)
        end

        -- Separación estricta de ejes físicos
        local horizontalShift = vec3New(smoothedVelocity.X, 0, smoothedVelocity.Z) * totalLatency * hMultiplier * predictionWeight
        
        -- Detección exacta de fase aérea (Saltos y Spam de saltos)
        local verticalShift = VECTOR_ZERO
        if humanoid.FloorMaterial == Enum.Material.Air or math_abs(smoothedVelocity.Y) > 0.5 then
            local pY = (smoothedVelocity.Y * totalLatency * vMultiplier) - (0.5 * workspace_Gravity * (totalLatency ^ 2))
            verticalShift = vec3New(0, pY, 0)
        end

        local finalPrediction = targetPosition + horizontalShift + verticalShift
        local minPrediction = targetPosition + (horizontalShift * 0.35) + (verticalShift * 0.35) -- Visualización mínima estable

        -- Corrección de altura contra el suelo físico
        local floorY = getFloorHeight(hrp, targetChar)
        if floorY then
            local minAllowedY = floorY + (hrp.Size.Y / 2) + 0.1
            if finalPrediction.Y < minAllowedY then finalPrediction = vec3New(finalPrediction.X, minAllowedY, finalPrediction.Z) end
            if minPrediction.Y < minAllowedY then minPrediction = vec3New(minPrediction.X, minAllowedY, minPrediction.Z) end
        end

        return finalPrediction, minPrediction

    -- MODO DE PREDICCIÓN 2: LINEAL SIMPLE (PREDICCIÓN CLÁSICA DE VELOCIDAD DIRECTA)
    else
        local simpleShift = rawVelocity * totalLatency * hMultiplier * predictionWeight
        local finalPrediction = targetPosition + simpleShift
        local minPrediction = targetPosition + (simpleShift * 0.30)
        return finalPrediction, minPrediction
    end
end

-- TRACERS REQUERIDOS: ROJO Y AMARILLO EXCLUSIVAMENTE
local MinPredictionLine = Drawing.new("Line")
MinPredictionLine.Color = color3RGB(255, 235, 35) -- Amarillo (Predicción Mínima de control)
MinPredictionLine.Thickness = 1.2
MinPredictionLine.ZIndex = 5  
table.insert(_G.KillerHubLines, MinPredictionLine)

local PredictionLine = Drawing.new("Line")
PredictionLine.Color = color3RGB(255, 35, 35) -- Rojo (Impacto Final de la bala)
PredictionLine.Thickness = 1.5
PredictionLine.ZIndex = 6  
table.insert(_G.KillerHubLines, PredictionLine)

local currentScreenPred = vec2New(0,0)
local currentScreenMinPred = vec2New(0,0)
local firstFrame = true
local worldToViewport = Camera.WorldToViewportPoint

local renderConn = RunService.RenderStepped:Connect(function(dt)
    emaDeltaTime = emaDeltaTime + 0.2 * (dt - emaDeltaTime) 
    checkWeaponVisibility()

    local murderer = getMurderer()
    if not murderer or not murderer.Character then
        PredictionLine.Visible = false; MinPredictionLine.Visible = false;
        firstFrame = true
        return
    end

    local targetChar = murderer.Character
    local visualPart = targetChar:FindFirstChild("HumanoidRootPart")

    if visualPart then
        local tSmooth = SheriffConfig.TracerSmoothness
        local predictedPos, minPredictedPos = getPredictedPosition(targetChar, visualPart)
        local currentViewportSize = Camera.ViewportSize
        local screenOrigin = vec2New(currentViewportSize.X / 2, currentViewportSize.Y)

        if minPredictedPos and SheriffConfig.ShowMinPredictTracer then
            local screenPos, onScreen = worldToViewport(Camera, minPredictedPos)
            if onScreen then
                local target2D = vec2New(screenPos.X, screenPos.Y)
                currentScreenMinPred = (firstFrame or tSmooth == 1) and target2D or currentScreenMinPred:Lerp(target2D, tSmooth)
                MinPredictionLine.From = screenOrigin
                MinPredictionLine.To = currentScreenMinPred
                MinPredictionLine.Visible = true
            else MinPredictionLine.Visible = false end
        else MinPredictionLine.Visible = false end

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
        PredictionLine.Visible = false; MinPredictionLine.Visible = false;
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
                        if hrp:FindFirstChild("GunRaycastAttachment") then originCFrame = hrp.GunRaycastAttachment.WorldCFrame end
                        shootRemote:FireServer(originCFrame, cframeNew(predictedPos))
                    end
                end
                task.wait(0.04) 
                isFiringCooldown = false
            end
        end
     end
end

-- CREACIÓN DE UI MENÚ FLOTANTE
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
    local tiempoGiro = 0.80     
    local tiempoQuieto = 0.03 
    local infoGiro = TweenInfo.new(tiempoGiro, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tweenIda = TweenService:Create(decalTexture, infoGiro, {Rotation = 360})
    local tweenVuelta = TweenService:Create(decalTexture, infoGiro, {Rotation = 0})

    local cIda = tweenIda.Completed:Connect(function() task.wait(tiempoQuieto) tweenVuelta:Play() end)
    local cVuelta = tweenVuelta.Completed:Connect(function() task.wait(tiempoQuieto) tweenIda:Play() end)
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
    local localX = inputPosition.X - buttonAbsolutePos.X
    local relX = (localX / buttonSize.X) - 0.5
    UiGradient.Offset = vec2New(relX * 1.5, 0)
    TweenService:Create(GlowOverlay, TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.42}):Play()
end

local function fadeGlowReflection()
    TweenService:Create(GlowOverlay, TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
end

local dragging, dragInput, dragStart, startPos
local cBegan = ShootButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        processGlowAtCoordinates(input.Position)
        task.spawn(fireAtMurdererDirectly)
        
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
end)
table.insert(_G.KillerHubConnections, cBegan)

local cEnded = ShootButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then fadeGlowReflection() end
end)
table.insert(_G.KillerHubConnections, cEnded)

local cChangedInput = ShootButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
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
--  HOOK NATIVO ADAPTATIVO RECURSIVO DEL WEAPON SERVICE
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
                    if predictedPos then return returnCFrame and cframeNew(predictedPos) or predictedPos end
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

local Killer = KillerHub
return Killer
