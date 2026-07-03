-- ============================================================================
--  KILLER HUB | SHERIFF SUITE V8.7.5 (VISUAL RECOVERY & NATIVE DISPARO)
-- ============================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService") 
local Stats = game:GetService("Stats") 
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local math_clamp = math.clamp
local math_min = math.min
local math_max = math.max
local math_abs = math.abs
local math_floor = math.floor
local vec2New = Vector2.new
local vec3New = Vector3.new
local udim2New = UDim2.new
local cframeNew = CFrame.new
local color3RGB = Color3.fromRGB

local VECTOR_ZERO = vec3New(0, 0, 0)

-- Limpieza
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

local success, KillerHubLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Salayer09/KillerHub/refs/heads/main/Slayer.lua"))()
end)

if not success or not KillerHubLib then return end
local KillerHub = KillerHubLib

local SheriffConfig = {
    SilentAim = false,
    HorizontalPred = 0.125, 
    VerticalPred = 0.025,   
    WallCheck = true,    
    PredictTracer = true,      
    ShowLeadTracer = true,    -- ¡Recuperado!
    LeadTimePred = 0.05,      -- ¡Recuperado!
    TracerSmoothness = 0.60, 
    UseWeaponDetector = false, 
    ShowShootButton = false,
    ButtonSize = 95,
    ButtonOpacity = 0.95, 
    ButtonLocked = false,
    ButtonX = 0.7, 
    ButtonY = 0.6
}

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
                HorizontalPred = SheriffConfig.HorizontalPred, 
                VerticalPred = SheriffConfig.VerticalPred,
                TracerSmoothness = SheriffConfig.TracerSmoothness,
                UseWeaponDetector = SheriffConfig.UseWeaponDetector,
                ShowShootButton = SheriffConfig.ShowShootButton,
                PredictTracer = SheriffConfig.PredictTracer,
                ShowLeadTracer = SheriffConfig.ShowLeadTracer,
                LeadTimePred = SheriffConfig.LeadTimePred
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
                SheriffConfig.HorizontalPred = data.HorizontalPred or SheriffConfig.HorizontalPred
                SheriffConfig.VerticalPred = data.VerticalPred or SheriffConfig.VerticalPred
                SheriffConfig.TracerSmoothness = data.TracerSmoothness or SheriffConfig.TracerSmoothness
                SheriffConfig.LeadTimePred = data.LeadTimePred or SheriffConfig.LeadTimePred
                if data.SilentAim ~= nil then SheriffConfig.SilentAim = data.SilentAim end
                if data.WallCheck ~= nil then SheriffConfig.WallCheck = data.WallCheck end
                if data.UseWeaponDetector ~= nil then SheriffConfig.UseWeaponDetector = data.UseWeaponDetector end
                if data.ShowShootButton ~= nil then SheriffConfig.ShowShootButton = data.ShowShootButton end
                if data.PredictTracer ~= nil then SheriffConfig.PredictTracer = data.PredictTracer end
                if data.ShowLeadTracer ~= nil then SheriffConfig.ShowLeadTracer = data.ShowLeadTracer end
            end
        end
    end)
end

loadConfig()

local function isRangedWeapon(tool)
    return tool and tool:IsA("Tool") and (tool:FindFirstChild("Shoot") or tool.Name == "Gun" or tool.Name == "Revolver")
end

local function isMeleeWeapon(tool)
    return tool and tool:IsA("Tool") and (tool:FindFirstChild("Stab") or tool.Name == "Knife")
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

SheriffTab:CreateToggle("SheriffWallCheckToggle", "Verificar Paredes (Wall Check)", function(estado)
    SheriffConfig.WallCheck = estado
    saveConfig()
end)

SheriffTab:CreateSlider("HorizontalPredSlider", "Factor Predicción Horizontal", 0, 300, function(valor)
    SheriffConfig.HorizontalPred = valor / 1000 
    saveConfig() 
end, math_floor(SheriffConfig.HorizontalPred * 1000))

SheriffTab:CreateSlider("VerticalPredSlider", "Factor Predicción Vertical", 0, 150, function(valor)
    SheriffConfig.VerticalPred = valor / 1000
    saveConfig() 
end, math_floor(SheriffConfig.VerticalPred * 1000))

SheriffTab:CreateSection("Líneas de Trayectoria")

SheriffTab:CreateToggle("PredictTracerToggle", "Mostrar Impacto Final (Rojo)", function(estado)
    SheriffConfig.PredictTracer = estado
    saveConfig()
end)

SheriffTab:CreateToggle("LeadTracerToggle", "Mostrar Tracer de Mano (Verde)", function(estado)
    SheriffConfig.ShowLeadTracer = estado
    saveConfig()
end)

SheriffTab:CreateSlider("LeadTimeSlider", "Anticipación de Mano (Lead Time)", 0, 100, function(valor)
    SheriffConfig.LeadTimePred = valor / 100
    saveConfig()
end, math_floor(SheriffConfig.LeadTimePred * 100))

SheriffTab:CreateSlider("TracerSmoothSlider", "Estabilizador Visual (1 = Instantáneo)", 1, 100, function(valor)
    if valor == 1 then SheriffConfig.TracerSmoothness = 1 else
        SheriffConfig.TracerSmoothness = 0.95 - ((valor - 2) / 98) * 0.80
    end
    saveConfig()
end, 40)

SheriffTab:CreateSection("Ajustes de Interfaz")

SheriffTab:CreateToggle("WeaponDetectToggle", "Ocultar Botón sin Arma", function(estado)
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
local playerRoles = {}
local playerDeadStatus = {}
local cachedPingValue = 0.04
local isFiringCooldown = false
local smoothedVelocity = VECTOR_ZERO

task.spawn(function()
    while task.wait(1) do
        if Stats and Stats:FindFirstChild("Network") and Stats.Network:FindFirstChild("ServerToClientPing") then
            cachedPingValue = math_clamp(Stats.Network.ServerToClientPing:GetValue() / 1000, 0.01, 0.3)
        end
    end
end)

local PlayerDataChanged = ReplicatedStorage:FindFirstChild("PlayerDataChanged", true)
if PlayerDataChanged and PlayerDataChanged:IsA("RemoteEvent") then
    local c = PlayerDataChanged.OnClientEvent:Connect(function(tabla)
        if type(tabla) == "table" then
            for name, data in pairs(tabla) do
                if type(data) == "table" then
                    if data.Role then playerRoles[name] = data.Role end
                    if data.Dead ~= nil then playerDeadStatus[name] = data.Dead end
                end
            end
        end
    end)
    table.insert(_G.KillerHubConnections, c)
end

local RoundStart = ReplicatedStorage:FindFirstChild("RoundStart", true)
if RoundStart and RoundStart:IsA("RemoteEvent") then
    local c = RoundStart.OnClientEvent:Connect(function(arg1, arg2)
        table.clear(playerRoles)
        table.clear(playerDeadStatus)
        MurdererDetectado = nil 
    end)
    table.insert(_G.KillerHubConnections, c)
end

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
        if not ((hum and hum.Health <= 0) or (playerDeadStatus[name] == true)) and (playerRoles[name] == "Murderer") then
            return MurdererDetectado
        end
    end

    for name, role in pairs(playerRoles) do
        if role == "Murderer" then
            local pl = Players:FindFirstChild(name)
            if pl and pl.Character and pl ~= LocalPlayer then
                local hum = pl.Character:FindFirstChildOfClass("Humanoid")
                if not ((hum and hum.Health <= 0) or (playerDeadStatus[name] == true)) then
                    MurdererDetectado = pl 
                    return pl
                end
            end
        end
    end

    local allPlayers = Players:GetPlayers()
    for i = 1, #allPlayers do
        local player = allPlayers[i]
        if player ~= LocalPlayer and player.Character then
            local hasKnife = false
            for _, item in pairs(player.Character:GetChildren()) do if isMeleeWeapon(item) then hasKnife = true break end end
            if not hasKnife and player:FindFirstChild("Backpack") then
                for _, item in pairs(player.Backpack:GetChildren()) do if isMeleeWeapon(item) then hasKnife = true break end end
            end
            if hasKnife then
                playerRoles[player.Name] = "Murderer"
                MurdererDetectado = player
                return player
            end
        end
    end
    return nil
end

local mapCastParams = RaycastParams.new()
mapCastParams.FilterType = Enum.RaycastFilterType.Exclude
local ignoreListCache = {}

local function getSmartTargetPart(targetChar)
    if not targetChar then return nil end
    local torso = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso")
    if not SheriffConfig.WallCheck then return torso end

    local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local origin = localHrp and localHrp.Position or Camera.CFrame.Position
    
    table.clear(ignoreListCache)
    table.insert(ignoreListCache, LocalPlayer.Character)
    table.insert(ignoreListCache, Camera)
    for _, p in pairs(Players:GetPlayers()) do if p.Character then table.insert(ignoreListCache, p.Character) end end
    
    mapCastParams.FilterDescendantsInstances = ignoreListCache
    
    if torso then
        local ray = workspace:Raycast(origin, torso.Position - origin, mapCastParams)
        if not ray or (ray.Instance.CanCollide == false or ray.Instance.Transparency >= 0.85) then
            return torso
       end
    end
    return nil 
end

local function getPredictedPosition(targetChar, targetPart)
    if not targetChar or not targetPart then return nil end
    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
    local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not localHrp then return nil end

    local targetPosition = targetPart.Position
    local velocity = hrp.AssemblyLinearVelocity
    local distance = (targetPosition - localHrp.Position).Magnitude

    if velocity.Magnitude < 1.0 then 
        smoothedVelocity = VECTOR_ZERO
        return targetPosition 
    end

    smoothedVelocity = smoothedVelocity:Lerp(velocity, 0.25)

    local timeBuffer = cachedPingValue + 0.022
    local totalWeight = distance * 0.012

    local horizontalPrediction = vec3New(smoothedVelocity.X, 0, smoothedVelocity.Z) * (SheriffConfig.HorizontalPred * timeBuffer * totalWeight * 10)
    local verticalPrediction = vec3New(0, smoothedVelocity.Y, 0) * (SheriffConfig.VerticalPred * timeBuffer * totalWeight * 10)

    return targetPosition + horizontalPrediction + verticalPrediction
end

local PredictionLine = Drawing.new("Line")
PredictionLine.Color = color3RGB(255, 35, 35) 
PredictionLine.Thickness = 1.6 
PredictionLine.ZIndex = 6  
table.insert(_G.KillerHubLines, PredictionLine)

local LeadLine = Drawing.new("Line")
LeadLine.Color = color3RGB(0, 255, 100) 
LeadLine.Thickness = 1.2
LeadLine.ZIndex = 4  
table.insert(_G.KillerHubLines, LeadLine)

local currentScreenPred = vec2New(0,0)
local currentScreenLead = vec2New(0,0)
local firstFrame = true
local fireAtMurdererDirectly

local renderConn = RunService.RenderStepped:Connect(function(dt)
    checkWeaponVisibility()
    local murderer = getMurderer()

    if not murderer or not murderer.Character then
        PredictionLine.Visible = false
        LeadLine.Visible = false
        firstFrame = true
        return
    end

    local targetChar = murderer.Character
    local localChar = LocalPlayer.Character
    local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")
    local visualPart = targetChar:FindFirstChild("HumanoidRootPart")

    if visualPart and localHrp then
        local predictedPos = getPredictedPosition(targetChar, visualPart)
        if predictedPos then
            local tSmooth = SheriffConfig.TracerSmoothness
            
            -- TRACER ROJO (IMPACTO FINAL)
            if SheriffConfig.PredictTracer then
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
                if onScreen then
                    local target2D = vec2New(screenPos.X, screenPos.Y)
                    currentScreenPred = (firstFrame or tSmooth == 1) and target2D or currentScreenPred:Lerp(target2D, tSmooth)
                    PredictionLine.From = vec2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    PredictionLine.To = currentScreenPred
                    PredictionLine.Visible = true
                else PredictionLine.Visible = false end
            else PredictionLine.Visible = false end

            -- TRACER VERDE (LEAD TIME INTERACTIVO DESDE LA MANO)
            local hand = localChar:FindFirstChild("RightHand") or localChar:FindFirstChild("Right Arm")
            if SheriffConfig.ShowLeadTracer and hand then
                local distance = (visualPart.Position - localHrp.Position).Magnitude
                local distFactor = math_clamp((distance - 4) / 16, 0, 1)
                local leadPredictedPos = visualPart.Position + (vec3New(smoothedVelocity.X, smoothedVelocity.Y * 0.5, smoothedVelocity.Z) * SheriffConfig.LeadTimePred * distFactor)
                
                local handScreen, handOnScreen = Camera:WorldToViewportPoint(hand.Position)
                local targetScreen, targetOnScreen = Camera:WorldToViewportPoint(leadPredictedPos)
                
                if handOnScreen and targetOnScreen then
                    local target2D = vec2New(targetScreen.X, targetScreen.Y)
                    currentScreenLead = (firstFrame or tSmooth == 1) and target2D or currentScreenLead:Lerp(target2D, tSmooth)
                    LeadLine.From = vec2New(handScreen.X, handScreen.Y)
                    LeadLine.To = currentScreenLead
                    LeadLine.Visible = true
                else LeadLine.Visible = false end
            else LeadLine.Visible = false end
        end

        if SheriffConfig.SilentAim then task.spawn(fireAtMurdererDirectly) end
        firstFrame = false
    else
        PredictionLine.Visible = false
        LeadLine.Visible = false
        firstFrame = true
    end 
end)
table.insert(_G.KillerHubConnections, renderConn)

function fireAtMurdererDirectly()
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
                        local attachment = hrp:FindFirstChild("GunRaycastAttachment")
                        local originCFrame = attachment and attachment.WorldCFrame or cframeNew(hrp.Position)
                        local targetCFrame = cframeNew(originCFrame.Position, predictedPos)
                        shootRemote:FireServer(originCFrame, targetCFrame)
                    end
                end
                task.wait(0.05) 
                isFiringCooldown = false
            end
        end
     end
end

-- INTERFAZ GRÁFICA DEL BOTÓN
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

-- ============================================================================
--  SISTEMA MECÁNICO DE ARRASTRE INTACTO (CORREGIDO DE ACCIDENTES)
-- ============================================================================
local dragging = false
local dragStart = VECTOR_ZERO
local startPos = udim2New(0,0,0,0)
local hasMovedSignificantly = false 

local cBegan = ShootButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragStart = input.Position
        startPos = ShootButton.Position
        hasMovedSignificantly = false 
        
        TweenService:Create(GlowOverlay, TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.35}):Play()

        if not SheriffConfig.ButtonLocked then
            dragging = true
        end
    end
end)
table.insert(_G.KillerHubConnections, cBegan)

local cChangedInput = UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        
        -- Si se desplaza más de 3 píxeles, asumimos arrastre y anulamos el disparo accidental
        if delta.Magnitude > 3 then
            hasMovedSignificantly = true
        end
        
        ShootButton.Position = udim2New(
            startPos.X.Scale + (delta.X / Camera.ViewportSize.X), 0, 
            startPos.Y.Scale + (delta.Y / Camera.ViewportSize.Y), 0
        )
    end
end)
table.insert(_G.KillerHubConnections, cChangedInput)

local cEnded = ShootButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        TweenService:Create(GlowOverlay, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        
        -- SOLO DISPARA SI EL BOTÓN FUE PRESIONADO (NO ARRASTRADO)
        if not hasMovedSignificantly then
            task.spawn(fireAtMurdererDirectly)
        else
            SheriffConfig.ButtonX = ShootButton.Position.X.Scale
            SheriffConfig.ButtonY = ShootButton.Position.Y.Scale
            saveConfig()
        end
    end
end)
table.insert(_G.KillerHubConnections, cEnded)

-- METAMÉTODO HOOK WEAPONSERVICE 
local WeaponService = nil
local ClientServices = ReplicatedStorage:FindFirstChild("ClientServices") or ReplicatedStorage:FindFirstChild("Services")
if ClientServices then
    local ws = ClientServices:FindFirstChild("WeaponService") or ClientServices:FindFirstChild("GunService")
    if ws and ws:IsA("ModuleScript") then pcall(function() WeaponService = require(ws) end) end
end

if WeaponService then
    local oldGetTargetPosition = WeaponService.GetTargetPosition
    local oldGetMouseTargetCFrame = WeaponService.GetMouseTargetCFrame

    local function getHookPrediction(returnCFrame)
        local gun, _ = getGunLocation()
        if SheriffConfig.SilentAim and (not SheriffConfig.UseWeaponDetector or (gun ~= nil)) then
            local murderer = getMurderer()
            if murderer and murderer.Character then
                local bestPart = getSmartTargetPart(murderer.Character)
                if bestPart then
                    local predictedPos = getPredictedPosition(murderer.Character, bestPart)
                    if predictedPos then
                        if returnCFrame then
                            local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local originPos = localHrp and localHrp.Position or Camera.CFrame.Position
                            return cframeNew(originPos, predictedPos)
                        else
                            return predictedPos
                        end
                    end
                end
            end
        end
        return nil
    end

    if oldGetTargetPosition then
        WeaponService.GetTargetPosition = function(self, ...)
            return getHookPrediction(false) or oldGetTargetPosition(self, ...)
        end
    end

    if oldGetMouseTargetCFrame then
        WeaponService.GetMouseTargetCFrame = function(self, ...)
            return getHookPrediction(true) or oldGetMouseTargetCFrame(self, ...)
        end
    end
end

checkWeaponVisibility()
return KillerHub
