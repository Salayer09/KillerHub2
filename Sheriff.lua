-- ============================================================================
-- 👻 KILLER HUB | SHERIFF V4.0 (MINI-AVATAR ADAPTATION & LIME-NEON UPDATE)
-- ============================================================================
local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Salayer09/KillerHub/refs/heads/main/Slayer.lua"))()

-- 1. PESTAÑA SHERIFF
local SheriffTab = KillerHub:CreateTab("Sheriff", "rbxassetid://10747373142")

-- 2. CONFIGURACIÓN GLOBAL AUTOMÁTICA
local SheriffConfig = {
    SilentAim = false,
    PredictionMode = "Predictiva 2.0 (Aceleración)",
    HorizontalPred = 0.135, 
    VerticalPred = 0.045,    
    WallCheck = true,         
    
    PredictTracer = false,
    ShowLeadTracer = true,     
    UseWeaponDetector = true,  
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

-- Persistencia de Datos Estructurados JSON
local function saveConfig()
    if writefile then
        local data = {
            ButtonX = SheriffConfig.ButtonX,
            ButtonY = SheriffConfig.ButtonY,
            PredictionMode = SheriffConfig.PredictionMode,
            LeadTimePred = SheriffConfig.LeadTimePred,
            UseWeaponDetector = SheriffConfig.UseWeaponDetector,
            ShowLeadTracer = SheriffConfig.ShowLeadTracer
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
            if data.ShowLeadTracer ~= nil then SheriffConfig.ShowLeadTracer = data.ShowLeadTracer end
        end
    end
end
loadConfig()

-- ============================================================================
-- ⚙️ INTERFAZ GRÁFICA ACTUALIZADA
-- ============================================================================
SheriffTab:CreateSection("Ajustes del Silent Aim")

SheriffTab:CreateToggle("SheriffSilent", "Activar Silent Aim Pasivo", function(estado)
    SheriffConfig.SilentAim = estado
end)

SheriffTab:CreateToggle("SheriffWallCheckToggle", "Verificar Paredes (Wall Check)", function(estado)
    SheriffConfig.WallCheck = estado
end)

SheriffTab:CreateDropdown("PredMode", "Modo de Predicción:", {"Predictiva 2.0 (Aceleración)", "Predictivo Adaptativo", "Lineal Estable", "Compensación Ping"}, function(seleccionado)
    SheriffConfig.PredictionMode = seleccionado
    saveConfig()
end)

SheriffTab:CreateSlider("HorizontalPredSlider", "Predicción Horizontal", 0, 300, function(valor)
    SheriffConfig.HorizontalPred = valor / 1000 
end)

SheriffTab:CreateSlider("VerticalPredSlider", "Predicción Vertical (Suave)", 0, 120, function(valor)
    SheriffConfig.VerticalPred = valor / 1000
end)

SheriffTab:CreateSection("Líneas de Trayectoria (Tracers)")
SheriffTab:CreateToggle("TracerPredToggle", "Mostrar Tracer Matemático (Rojo)", function(estado)
    SheriffConfig.PredictTracer = estado
end)

SheriffTab:CreateToggle("LeadTracerToggle", "Activar Lead Tracer (Mano Lima-Limón)", function(estado)
    SheriffConfig.ShowLeadTracer = estado
    saveConfig()
end)

SheriffTab:CreateSlider("LeadTimeSlider", "Ver anticipación (Mano)", 0, 100, function(valor)
    SheriffConfig.LeadTimePred = valor / 100
    saveConfig()
end)

SheriffTab:CreateSection("Condiciones de Interfaz")
SheriffTab:CreateToggle("WeaponDetectToggle", "Auto-Ocultar Interfaz si no tengo Arma", function(estado)
    SheriffConfig.UseWeaponDetector = estado
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
        if btn:FindFirstChild("UICorner") then
            btn.UICorner.CornerRadius = UDim.new(0, math.floor(valor * 0.24))
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
-- 🧠 MOTOR CINEMÁTICO V4.0 (ADAPTACIÓN MINI-AVATARS + VECTOR ACELERACIÓN)
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
local previousTargetVelocity = Vector3.new(0,0,0) -- Para cálculo de aceleración 2.0
local wallcastParams = RaycastParams.new()
wallcastParams.FilterType = Enum.RaycastFilterType.Exclude

local function playerHasGun()
    local char = LocalPlayer.Character
    if char and (char:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")) then
        return true
    end
    return false
end

local function getMurderer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Parent ~= nil then
            local char = player.Character
            local backpack = player:FindFirstChild("Backpack")
            if (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife")) then
                return player
            end
        end
    end
    return nil
end

local function isTargetVisible(targetPart, murdererChar)
    if not SheriffConfig.WallCheck then return true end
    if not targetPart or not murdererChar or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return false 
    end
    
    wallcastParams.FilterDescendantsInstances = {LocalPlayer.Character, murdererChar}
    local origin = LocalPlayer.Character.HumanoidRootPart.Position
    local direction = targetPart.Position - origin
    
    local ray = workspace:Raycast(origin, direction, wallcastParams)
    return ray == nil
end

local function getPredictedPosition(targetChar)
    if not targetChar then return nil end
    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not hrp or not humanoid or humanoid.Health <= 0 or not localHrp then return nil end

    -- ADAPTACIÓN DINÁMICA DE ALTURA PARA MINI-AVATARS
    local targetPosition = hrp.Position
    local heightScale = 1
    if humanoid:FindFirstChild("BodyHeightScale") then
        heightScale = math.clamp(humanoid.BodyHeightScale.Value, 0.2, 1.5)
    end
    
    -- Si el avatar es muy pequeño, bajamos el centro de masa del tiro para evitar sobrepasar su cabeza
    if heightScale < 0.85 then
        targetPosition = targetPosition - Vector3.new(0, (1 - heightScale) * 1.2, 0)
    end

    local velocity = hrp.AssemblyLinearVelocity
    
    local rawPing = 0.06
    if Stats and Stats:FindFirstChild("Network") and Stats.Network:FindFirstChild("ServerToClientPing") then
        rawPing = Stats.Network.ServerToClientPing:GetValue() / 1000
    end
    local ping = math.clamp(rawPing, 0.01, 0.4)

    if velocity.Magnitude < 0.1 then return targetPosition end

    -- ATENUADOR MATEMÁTICO DE PROXIMIDAD
    local distance = (targetPosition - localHrp.Position).Magnitude
    local distanceFactor = math.clamp((distance - 4) / 16, 0, 1) 

    local hFactor = SheriffConfig.HorizontalPred
    local vFactor = SheriffConfig.VerticalPred

    -- MODO NUEVO: PREDICCIÓN 2.0 CON ACCEL VECTORIAL
    if SheriffConfig.PredictionMode == "Predictiva 2.0 (Aceleración)" then
        local acceleration = (velocity - previousTargetVelocity)
        local timeFrame = hFactor + ping
        
        -- Fórmula cinemática: Posición = P0 + V*t + 0.5*A*t^2
        local kinematicOffset = (velocity * timeFrame) + (0.5 * acceleration * (timeFrame ^ 2))
        local finalPrediction = targetPosition + (kinematicOffset * distanceFactor)
        
        -- Compensación vertical controlada
        if math.abs(velocity.Y) > 1 then
            finalPrediction = finalPrediction + Vector3.new(0, velocity.Y * vFactor * distanceFactor, 0)
        end
        return finalPrediction

    elseif SheriffConfig.PredictionMode == "Predictivo Adaptativo" then
        local dynamicH = hFactor
        if lastVelocity.Magnitude > 0.2 and velocity.Magnitude > 0.2 then
            local dotProduct = velocity.Unit:Dot(lastVelocity.Unit)
            if dotProduct < 0.82 then
                dynamicH = dynamicH * math.clamp(dotProduct, 0.15, 1.0)
            end
        end

        local dynamicV = vFactor
        if math.abs(velocity.Y) > 1 then
            if math.abs(velocity.Y) < 6 then
                dynamicV = dynamicV * 0.25
            else
                dynamicV = dynamicV * 1.15
            end
        end

        local horizontalOffset = Vector3.new(velocity.X, 0, velocity.Z) * (dynamicH + ping) * distanceFactor
        local verticalOffset = Vector3.new(0, velocity.Y * (dynamicV + (ping * 0.5)), 0) * distanceFactor
        return targetPosition + horizontalOffset + verticalOffset

    elseif SheriffConfig.PredictionMode == "Lineal Estable" then
        return targetPosition + (Vector3.new(velocity.X * hFactor, velocity.Y * vFactor, velocity.Z * hFactor) * distanceFactor)

    elseif SheriffConfig.PredictionMode == "Compensación Ping" then
        local scale = ping * hFactor * 8.0
        return targetPosition + (Vector3.new(velocity.X * scale, velocity.Y * (vFactor * ping * 8.0), Vector3.new(velocity.Z * scale)) * distanceFactor)
    end

    return targetPosition
end

RunService.Heartbeat:Connect(function()
    local mud = getMurderer()
    if mud and mud.Character and mud.Character:FindFirstChild("HumanoidRootPart") then
        previousTargetVelocity = lastVelocity
        lastVelocity = mud.Character.HumanoidRootPart.AssemblyLinearVelocity
    end
end)

-- ============================================================================
-- 🟥 & 🟩 MANEJO DE TRACERS OPTIMIZADOS (COLOR LIMA-LIMÓN NUEVO)
-- ============================================================================
local PredictionLine = Drawing.new("Line")
PredictionLine.Color = Color3.fromRGB(255, 35, 35)
PredictionLine.Thickness = 1.0
PredictionLine.Visible = false

local LeadLine = Drawing.new("Line")
-- NUEVO COLOR: Verde Lima Limón Neón de alta fidelidad visual
LeadLine.Color = Color3.fromRGB(145, 255, 0) 
LeadLine.Thickness = 1.0
LeadLine.Visible = false

RunService.RenderStepped:Connect(function()
    local hasGun = not SheriffConfig.UseWeaponDetector or playerHasGun()
    local murderer = getMurderer()
    
    local screenGui = game:GetService("CoreGui"):FindFirstChild("KillerHub_VoidGui")
    if screenGui then
        screenGui.Enabled = SheriffConfig.ShowShootButton and hasGun
    end

    if not hasGun or not murderer or not murderer.Character then
        PredictionLine.Visible = false
        LeadLine.Visible = false
        return
    end

    local predictedPos = getPredictedPosition(murderer.Character)
    if predictedPos then
        -- 1. Tracer del Servidor (Rojo)
        if SheriffConfig.PredictTracer then
            local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
            if onScreen then
                PredictionLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                PredictionLine.To = Vector2.new(screenPos.X, screenPos.Y)
                PredictionLine.Visible = true
            else
                PredictionLine.Visible = false
            end
        else
            PredictionLine.Visible = false
        end

        -- 2. Tracer de Mano Proporcional (Lima Limón Neón)
        local localChar = LocalPlayer.Character
        local hand = localChar and (localChar:FindFirstChild("RightHand") or localChar:FindFirstChild("Right Arm"))
        local targetHrp = murderer.Character:FindFirstChild("HumanoidRootPart")
        local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")

        if SheriffConfig.ShowLeadTracer and hand and targetHrp and localHrp then
            local distance = (targetHrp.Position - localHrp.Position).Magnitude
            local distFactor = math.clamp((distance - 4) / 16, 0, 1)

            local leadPredictedPos = targetHrp.Position + (murderer.Character.HumanoidRootPart.AssemblyLinearVelocity * SheriffConfig.LeadTimePred * distFactor)
            
            local handScreenPos, handOnScreen = Camera:WorldToViewportPoint(hand.Position)
            local targetScreenPos, targetOnScreen = Camera:WorldToViewportPoint(leadPredictedPos)

            if handOnScreen and targetOnScreen then
                LeadLine.From = Vector2.new(handScreenPos.X, handScreenPos.Y)
                LeadLine.To = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
                LeadLine.Visible = true
            else
                LeadLine.Visible = false
            end
        else
            LeadLine.Visible = false
        end
    else
        PredictionLine.Visible = false
        LeadLine.Visible = false
    end
end)

-- ============================================================================
-- 🚀 SISTEMA DE EJECUCIÓN SÍNCRONA DE DISPARO
-- ============================================================================
local function fireAtMurdererDirectly()
    local char = LocalPlayer.Character
    local gun = char and char:FindFirstChild("Gun")
    local murderer = getMurderer()

    if gun and gun:FindFirstChild("Shoot") and murderer and murderer.Character then
        local hrp = murderer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and isTargetVisible(hrp, murderer.Character) then 
            local predictedPos = getPredictedPosition(murderer.Character)
            if predictedPos then
                local originCFrame = char.HumanoidRootPart.CFrame
                if char.HumanoidRootPart:FindFirstChild("GunRaycastAttachment") then
                    originCFrame = char.HumanoidRootPart.GunRaycastAttachment.WorldCFrame
                end
                gun.Shoot:FireServer(originCFrame, CFrame.new(predictedPos))
            end
        end
    end
end

-- ============================================================================
-- 🌌 INTERFAZ MEJORADA: ABYSSAL VOID PURPLE V2
-- ============================================================================
local VoidGui = Instance.new("ScreenGui")
VoidGui.Name = "KillerHub_VoidGui"
VoidGui.ResetOnSpawn = false
VoidGui.Enabled = false 
VoidGui.Parent = game:GetService("CoreGui")

local ShootButton = Instance.new("ImageButton")
ShootButton.Name = "ShootButton"
ShootButton.Size = UDim2.new(0, SheriffConfig.ButtonSize, 0, SheriffConfig.ButtonSize)
ShootButton.Position = UDim2.new(SheriffConfig.ButtonX, 0, SheriffConfig.ButtonY, 0)
-- COLOR AJUSTADO: Aún más oscuro e imponente, estética void pura
ShootButton.BackgroundColor3 = Color3.fromRGB(13, 5, 24) 
ShootButton.BackgroundTransparency = 1 - SheriffConfig.ButtonOpacity
ShootButton.BorderSizePixel = 0  
ShootButton.AutoButtonColor = false 
ShootButton.Parent = VoidGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, math.floor(SheriffConfig.ButtonSize * 0.24)) 
Corner.Parent = ShootButton

local DecalTexture = Instance.new("ImageLabel")
DecalTexture.Name = "DecalTexture"
DecalTexture.Size = UDim2.new(0.41, 0, 0.41, 0) 
DecalTexture.AnchorPoint = Vector2.new(0.5, 0.5)
DecalTexture.Position = UDim2.new(0.5, 0, 0.43, 0) 
DecalTexture.BackgroundTransparency = 1
DecalTexture.Image = "rbxassetid://125754446555599" 
DecalTexture.ImageTransparency = 1 - SheriffConfig.ButtonOpacity
DecalTexture.Parent = ShootButton

local tweenInfo = TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local crosshairTween = TweenService:Create(DecalTexture, tweenInfo, {Rotation = 360})
crosshairTween:Play()

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
Label.Parent = ShootButton

ShootButton.Activated:Connect(function()
    fireAtMurdererDirectly()
end)

-- SISTEMA DRAGGABLE OPTIMIZADO (ANTI-ERROR DE CLIC/MOVIMIENTO)
local dragging = false
local dragStart = nil
local startPos = nil
local dragInput = nil
local DRAG_THRESHOLD = 8 -- Mínimo de píxeles para validar un arrastre en vez de un toque

ShootButton.InputBegan:Connect(function(input)
    if not SheriffConfig.ButtonLocked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragStart = input.Position
        startPos = ShootButton.Position
        dragging = false -- Inicializa apagado para priorizar clicks instantáneos
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                if dragging then
                    SheriffConfig.ButtonX = ShootButton.Position.X.Scale
                    SheriffConfig.ButtonY = ShootButton.Position.Y.Scale
                    saveConfig() 
                end
                dragStart = nil
                dragging = false
            end
        end)
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
        
        -- Si no está activado el drag, revisa si superó el umbral mínimo de píxeles
        if not dragging and delta.Magnitude > DRAG_THRESHOLD then
            dragging = true
        end
        
        -- Solo desplaza el botón si de verdad se está arrastrando de forma intencional
        if dragging then
            local screenWidth = Camera.ViewportSize.X
            local screenHeight = Camera.ViewportSize.Y
            local newX = startPos.X.Scale + (delta.X / screenWidth)
            local newY = startPos.Y.Scale + (delta.Y / screenHeight)
            ShootButton.Position = UDim2.new(newX, 0, newY, 0)
        end
    end
end)

-- ============================================================================
-- ⚡ GANCHOS (HOOKS) DE INTERCEPTACIÓN AVANZA 2.0
-- ============================================================================
local ClientServices = ReplicatedStorage:WaitForChild("ClientServices", 5)
if ClientServices then
    local WeaponService = require(ClientServices:WaitForChild("WeaponService"))
    local oldGetTargetPosition = WeaponService.GetTargetPosition
    local oldGetMouseTargetCFrame = WeaponService.GetMouseTargetCFrame

    WeaponService.GetTargetPosition = function(self, ...)
        if SheriffConfig.SilentAim and (not SheriffConfig.UseWeaponDetector or playerHasGun()) then
            local murderer = getMurderer()
            if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
                if isTargetVisible(murderer.Character.HumanoidRootPart, murderer.Character) then
                    local predictedPos = getPredictedPosition(murderer.Character)
                    if predictedPos then return CFrame.new(predictedPos) end
                end
            end
        end
        return oldGetTargetPosition(self, ...)
    end

    WeaponService.GetMouseTargetCFrame = function(self, ...)
        if SheriffConfig.SilentAim and (not SheriffConfig.UseWeaponDetector or playerHasGun()) then
            local murderer = getMurderer()
            if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
                if isTargetVisible(murderer.Character.HumanoidRootPart, murderer.Character) then
                    local predictedPos = getPredictedPosition(murderer.Character)
                    if predictedPos then return CFrame.new(predictedPos) end
                end
            end
        end
        return oldGetMouseTargetCFrame(self, ...)
    end
end

return KillerHub
