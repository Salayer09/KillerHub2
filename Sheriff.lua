-- ============================================================================
-- 👻 KILLER HUB | SHERIFF V7.0.0 [PURE REAL-TIME & INSTANT RESPONSE]
-- ============================================================================
if _G.KillerHubLines then
    for _, line in pairs(_G.KillerHubLines) do
        pcall(function() line:Remove() end)
    end
end
_G.KillerHubLines = {}

local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Salayer09/KillerHub/refs/heads/main/Slayer.lua"))()

local SheriffTab = KillerHub:CreateTab("Sheriff", "rbxassetid://10747373142")

local SheriffConfig = {
    SilentAim = false,
    PredictionMode = "REALTIME-ENGINE V7.0", 
    HorizontalPred = 1.0, 
    VerticalPred = 1.0,   
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
            SheriffConfig.PredictionMode = "REALTIME-ENGINE V7.0"
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
-- ⚙️ INTERFAZ GRÁFICA
-- ============================================================================
SheriffTab:CreateSection("Ajustes del Silent Aim")

SheriffTab:CreateToggle("SheriffSilent", "Activar Silent Aim Pasivo", function(estado)
    SheriffConfig.SilentAim = estado
end)

SheriffTab:CreateToggle("SheriffWallCheckToggle", "Verificar Paredes Físicas (Estricto)", function(estado)
    SheriffConfig.WallCheck = estado
end)

SheriffTab:CreateSection("Motor: REALTIME V7.0 (Respuesta Instantánea)")

SheriffTab:CreateSlider("HorizontalPredSlider", "Ajuste Fino Horizontal (%)", 50, 150, function(valor)
    SheriffConfig.HorizontalPred = valor / 100 
    saveConfig()
end)

SheriffTab:CreateSlider("VerticalPredSlider", "Ajuste Fino Vertical (%)", 50, 150, function(valor)
    SheriffConfig.VerticalPred = valor / 100
    saveConfig()
end)

SheriffTab:CreateSection("Líneas de Trayectoria (Tracers)")

SheriffTab:CreateToggle("TracerPredToggle", "Mostrar Tracer de Impacto (Rojo)", function(estado)
    SheriffConfig.PredictTracer = estado
end)

SheriffTab:CreateToggle("PingTracerToggle", "Mostrar Ping Prediction (Azul Fuerte)", function(estado)
    SheriffConfig.ShowPingTracer = estado
    saveConfig()
end)

SheriffTab:CreateToggle("LagTracerToggle", "Mostrar Lag Realtime (Morado)", function(estado)
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
    if btn then btn.BackgroundTransparency = 1 - SheriffConfig.ButtonOpacity end
end)

SheriffTab:CreateToggle("LockVoidBtn", "Bloquear Posición del Botón", function(estado)
    SheriffConfig.ButtonLocked = estado
end)

-- ============================================================================
-- 🧠 MOTOR CINEMÁTICO V7.0.0 (CÁLCULO ULTRA-RÁPIDO ESTABILIZADO)
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

local smoothedPing = 0.06
task.spawn(function()
    while task.wait(0.5) do
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
    if char and char:FindFirstChild("Gun") then return char:FindFirstChild("Gun"), char
    elseif LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Gun") then return LocalPlayer.Backpack.Gun, LocalPlayer.Backpack end
    return nil, nil
end

local function getMurderer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Parent ~= nil then
            local char = player.Character
            if (char and char:FindFirstChild("Knife")) or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife")) then return player end
        end
    end
    return nil
end

local function isPartVisible(targetPart, murdererChar)
    if not SheriffConfig.WallCheck then return true end
    if not targetPart or not murdererChar or not LocalPlayer.Character then return false end
    
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local originCFrame = hrp:FindFirstChild("GunRaycastAttachment") and hrp.GunRaycastAttachment.WorldCFrame or hrp.CFrame
    local originPos = originCFrame.Position
    
    wallcastParams.FilterDescendantsInstances = {char, murdererChar, Camera}
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
    return murdererChar:FindFirstChild("HumanoidRootPart") or murdererChar:FindFirstChild("Head") or murdererChar:FindFirstChild("UpperTorso")
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

    local clampedDT = math.min(lastDeltaTime, 0.05) 

    if lastTargetChar ~= targetChar then
        smoothedVelocity = mainPart.AssemblyLinearVelocity
        lastTargetChar = targetChar
    end

    local targetPosition = mainPart.Position
    local distance = (targetPosition - localHrp.Position).Magnitude
    
    local BULLET_SPEED = 275 
    local estimatedTimeToTarget = (distance / BULLET_SPEED) + smoothedPing

    local distanceMultiplier = 1.0
    if distance < 15 then distanceMultiplier = 0.85
    elseif distance > 45 then distanceMultiplier = 1.10 end

    local totalHorizontalTime = estimatedTimeToTarget * distanceMultiplier * SheriffConfig.HorizontalPred
    local totalVerticalTime = estimatedTimeToTarget * distanceMultiplier * SheriffConfig.VerticalPred

    local rawVelocity = mainPart.AssemblyLinearVelocity
    if rawVelocity.Magnitude > 55 then rawVelocity = rawVelocity.Unit * 16 end
    
    -- FILTRO DE ALTA RESPUESTA (-38): Ultra rápido para evitar retrasos pero elimina saltos espasmódicos
    local fpsWeight = math.clamp(1 - math.exp(-38 * clampedDT), 0.15, 1.0)
    smoothedVelocity = smoothedVelocity:Lerp(rawVelocity, fpsWeight)

    -- Zona muerta mínima para cuando está completamente inmóvil
    if smoothedVelocity.Magnitude < 0.2 then smoothedVelocity = Vector3.new(0, 0, 0) end

    local horizontalPrediction = Vector3.new(smoothedVelocity.X, 0, smoothedVelocity.Z) * totalHorizontalTime
    local basePrediction = targetPosition + horizontalPrediction

    local verticalOffset = Vector3.new(0, 0, 0)
    local serverGravity = workspace.Gravity
    
    if humanoid.FloorMaterial == Enum.Material.Air or math.abs(rawVelocity.Y) > 0.5 then
        local predictedYDisplacement = (rawVelocity.Y * totalVerticalTime) - (0.5 * serverGravity * (totalVerticalTime ^ 2))
        verticalOffset = Vector3.new(0, predictedYDisplacement, 0)
    else
        verticalOffset = Vector3.new(0, rawVelocity.Y * totalVerticalTime * 0.5, 0)
    end

    local finalPrediction = basePrediction + verticalOffset

    if rawVelocity.Y < -0.1 then
        local floorY = getFloorHeight(mainPart, targetChar)
        if floorY then
            local heightScale = humanoid:FindFirstChild("BodyHeightScale") and math.clamp(humanoid.BodyHeightScale.Value, 0.2, 1.5) or 1
            local minAllowedY = floorY + ((mainPart.Size.Y / 2) * heightScale) + 0.15
            if finalPrediction.Y < minAllowedY then finalPrediction = Vector3.new(finalPrediction.X, minAllowedY, finalPrediction.Z) end
        end
    end

    lastVelocity = rawVelocity
    return finalPrediction
end

-- ============================================================================
-- 🟦 🟣 🟥 🟩 INSTANT DRAWING (SIN RETRASO DE PANTALLA)
-- ============================================================================
local function createLine(color, thickness, zIndex)
    local line = Drawing.new("Line")
    line.Color = color
    line.Thickness = thickness
    line.Visible = false
    line.ZIndex = zIndex
    table.insert(_G.KillerHubLines, line)
    return line
end

local PredictionLine = createLine(Color3.fromRGB(255, 35, 35), 1.2, 4)
local PingLine = createLine(Color3.fromRGB(0, 85, 255), 1.0, 1)
local LagLine = createLine(Color3.fromRGB(160, 32, 240), 1.0, 2)
local LeadLine = createLine(Color3.fromRGB(103, 255, 89), 1.0, 3)

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
        local distance = (mainPart.Position - localHrp.Position).Magnitude
        local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

        -- 1. TRACER ROJO (Predicción Total: Lag + Tiempo de Vuelo de Bala)
        local predictedPos = getPredictedPosition(murderer.Character)
        if predictedPos and SheriffConfig.PredictTracer then
            local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
            if onScreen then
                PredictionLine.From = viewportCenter
                PredictionLine.To = Vector2.new(screenPos.X, screenPos.Y) -- INSTANTÁNEO
                PredictionLine.Visible = true
            else PredictionLine.Visible = false end
        else PredictionLine.Visible = false end

        -- 2. TRACER AZUL (Predicción de Ping Base)
        if SheriffConfig.ShowPingTracer then
            local pingPos = mainPart.Position + (smoothedVelocity * smoothedPing)
            local screenPos, onScreen = Camera:WorldToViewportPoint(pingPos)
            if onScreen then
                PingLine.From = viewportCenter
                PingLine.To = Vector2.new(screenPos.X, screenPos.Y) -- INSTANTÁNEO
                PingLine.Visible = true
            else PingLine.Visible = false end
        else PingLine.Visible = false end

        -- 3. TRACER MORADO (Lag Físico de Red Puro)
        if SheriffConfig.ShowLagTracer then
            local lagPos = mainPart.Position + (smoothedVelocity * (smoothedPing * 1.1))
            local screenPos, onScreen = Camera:WorldToViewportPoint(lagPos)
            if onScreen then
                LagLine.From = viewportCenter
                LagLine.To = Vector2.new(screenPos.X, screenPos.Y) -- INSTANTÁNEO
                LagLine.Visible = true
            else LagLine.Visible = false end
        else LagLine.Visible = false end

        -- 4. TRACER VERDE (Mano a Objetivo)
        local hand = localChar and (localChar:FindFirstChild("RightHand") or localChar:FindFirstChild("Right Arm"))
        if SheriffConfig.ShowLeadTracer and hand then
            local distFactor = math.clamp((distance - 4) / 16, 0, 1)
            local leadPredictedPos = mainPart.Position + (smoothedVelocity * SheriffConfig.LeadTimePred * distFactor)
            
            local handScreenPos, handOnScreen = Camera:WorldToViewportPoint(hand.Position)
            local targetScreenPos, targetOnScreen = Camera:WorldToViewportPoint(leadPredictedPos)

            if handOnScreen and targetOnScreen then
                LeadLine.From = Vector2.new(handScreenPos.X, handScreenPos.Y)
                LeadLine.To = Vector2.new(targetScreenPos.X, targetScreenPos.Y) -- INSTANTÁNEO
                LeadLine.Visible = true
            else LeadLine.Visible = false end
        else LeadLine.Visible = false end
    else
        PredictionLine.Visible = false; PingLine.Visible = false; LagLine.Visible = false; LeadLine.Visible = false
    end
end)

local function fireAtMurdererDirectly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local gun, parent = getGunLocation()
    local murderer = getMurderer()

    if gun and murderer and murderer.Character then
        local mainPart = getAbsoluteTargetPart(murderer.Character)
        if mainPart and isPartVisible(mainPart, murderer.Character) then 
            local predictedPos = getPredictedPosition(murderer.Character)
            if predictedPos then
                if parent == LocalPlayer.Backpack then 
                    humanoid:EquipTool(gun) 
                    RunService.Heartbeat:Wait() 
                end
                if gun:FindFirstChild("Shoot") then
                    local originCFrame = char.HumanoidRootPart.CFrame
                    if char.HumanoidRootPart:FindFirstChild("GunRaycastAttachment") then originCFrame = char.HumanoidRootPart.GunRaycastAttachment.WorldCFrame end
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
-- UI Y BOTÓN (ESTÉTIKA SLAYER ORIGINAL)
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
DecalTexture.Size = UDim2.new(0.39, 0, 0.39, 0)
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

local dragging, dragStart, startPos, dragInput = false, nil, nil, nil
ShootButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        TweenService:Create(GlowOverlay, TweenInfo.new(0.04), {BackgroundTransparency = 0.18}):Play()
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
        TweenService:Create(GlowOverlay, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    end
end)

ShootButton.InputChanged:Connect(function(input) if not SheriffConfig.ButtonLocked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragStart then
        local delta = input.Position - dragStart
        if not dragging and delta.Magnitude > 8 then dragging = true end
        if dragging then ShootButton.Position = UDim2.new(startPos.X.Scale + (delta.X / Camera.ViewportSize.X), 0, startPos.Y.Scale + (delta.Y / Camera.ViewportSize.Y), 0) end
    end
end)

-- ============================================================================
-- SILENT AIM HOOKS
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
