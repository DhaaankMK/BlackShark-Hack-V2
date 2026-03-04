-- Powered by BlackShark Studios
-- Creator: DhaaankMK
-- https://github.com/DhaaankMK

--====================================
-- ESP + Black Shark Hack
-- Lua / Roblox
-- Sistema de Testes para Anti-Cheat
--====================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

-- Configurações Globais (MANTIDAS + NOVAS)
local Config = {
    -- ESP (MANTIDO)
    ESPEnabled = false,
    Boxes = true,
    Names = true,
    Distance = true,
    Tracers = false,
    HealthBars = true,
    Skeleton = false,
    TeamCheck = false,
    VisibleOnly = false,
    BoxColor = Color3.fromRGB(255, 0, 0),
    TeamColor = false,
    
    -- Combat (MANTIDO)
    Aimbot = false,
    AimbotFOV = 200,
    AimbotSmoothing = 0.1,
    SilentAim = false,
    TriggerBot = false,
    
    -- Player (MANTIDO)
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    NoClip = false,
    Fly = false,
    FlySpeed = 50,
    God = false,
    
    -- Visual (MANTIDO)
    Fullbright = false,
    RemoveFog = false,
    Crosshair = false,
    FOVCircle = false,
    
    -- Misc (MANTIDO)
    KillAll = false,
    TeleportToPlayers = false,
    SpinBot = false,
    AutoFarm = false,
    AntiAFK = false,
    
    -- NOVAS FUNCIONALIDADES
    -- ESP Avançado
    ChamsEnabled = false,
    HighlightEnabled = false,
    ShowTools = true,
    ShowHead = true,
    ShowLookDirection = false,
    ESPTransparency = 0.3,
    
    -- Combat Avançado
    AimbotTarget = "Head", -- Head, Torso, Random
    PredictMovement = false,
    IgnoreWalls = false,
    AutoShoot = false,
    RapidFire = false,
    NoRecoil = false,
    InfiniteAmmo = false,
    
    -- Player Avançado
    AutoRespawn = false,
    InstantRespawn = false,
    PlatformEnabled = false,
    AntiRagdoll = false,
    AntiSlowdown = false,
    AntiKnockback = false,
    RemoveAccessories = false,
    
    -- Teleporte Avançado
    TeleportType = "Instant", -- Instant, Tween, Walk
    SavedPositions = {},
    
    -- Visual Avançado
    Esp3D = false,
    RainbowMode = false,
    Tracers3D = false,
    ShowFPS = true,
    ShowPing = true,
    CustomSkybox = false,
    RemoveParticles = false,
    
    -- Servidor
    ServerHop = false,
    RejoinServer = false,
    AntiKick = false,
    AntiVoid = false,
    ChatSpam = false,
    ChatSpamMessage = "Test",
    
    -- Automação
    AutoCollectCoins = false,
    AutoCollectItems = false,
    AutoBuyItems = false,
    AutoCompleteObby = false,
    
    -- Misc Avançado
    ClickTP = false,
    ClickDelete = false,
    BTools = false,
    RemotesSpy = false,
    ScriptDumper = false,
    
    -- Performance
    FPSBoost = false,
    RemoveTextures = false,
    LowGraphics = false,
    OptimizedESP = true
}

-- Variáveis de controle (MANTIDAS)
local ESPObjects = {}
local FOVCircle = Drawing.new("Circle")
local Crosshair = {}
local FlyConnection
local NoClipConnection
local SpinBotConnection
local AimbotConnection

-- NOVAS Variáveis
local ChamsFolder = Instance.new("Folder")
ChamsFolder.Name = "ChamsFolder"
ChamsFolder.Parent = game.CoreGui

local HighlightCache = {}
local SavedPositions = {}
local PlatformPart = nil
local AntiVoidPart = nil
local RemoteConnections = {}
local OriginalFunctions = {}

--====================================
-- FUNÇÕES DE ESP (MANTIDAS + MELHORADAS)
--====================================

local function CreateBox()
    local box = {
        Square = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBarOutline = Drawing.new("Square"),
        -- NOVOS ELEMENTOS
        Tool = Drawing.new("Text"),
        LookLine = Drawing.new("Line"),
        HeadDot = Drawing.new("Circle")
    }
    
    -- Configurações originais mantidas
    box.Square.Thickness = 2
    box.Square.Filled = false
    box.Square.Visible = false
    
    box.Tracer.Thickness = 1
    box.Tracer.Visible = false
    
    box.Name.Size = 14
    box.Name.Center = true
    box.Name.Outline = true
    box.Name.Visible = false
    box.Name.Font = Drawing.Fonts.Plex
    
    box.Distance.Size = 13
    box.Distance.Center = true
    box.Distance.Outline = true
    box.Distance.Visible = false
    box.Distance.Font = Drawing.Fonts.Plex
    
    box.HealthBar.Thickness = 1
    box.HealthBar.Filled = true
    box.HealthBar.Visible = false
    box.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    
    box.HealthBarOutline.Thickness = 1
    box.HealthBarOutline.Filled = false
    box.HealthBarOutline.Visible = false
    box.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    
    -- NOVOS ELEMENTOS
    box.Tool.Size = 12
    box.Tool.Center = true
    box.Tool.Outline = true
    box.Tool.Visible = false
    box.Tool.Font = Drawing.Fonts.Plex
    box.Tool.Color = Color3.fromRGB(255, 255, 0)
    
    box.LookLine.Thickness = 2
    box.LookLine.Visible = false
    box.LookLine.Color = Color3.fromRGB(0, 255, 255)
    
    box.HeadDot.Radius = 3
    box.HeadDot.Filled = true
    box.HeadDot.Visible = false
    box.HeadDot.Color = Color3.fromRGB(255, 0, 0)
    box.HeadDot.Thickness = 1
    
    return box
end

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj.Remove then obj:Remove() end
        end
        ESPObjects[player] = nil
    end
    
    -- Remover Chams
    if ChamsFolder:FindFirstChild(player.Name) then
        ChamsFolder[player.Name]:Destroy()
    end
    
    -- Remover Highlight
    if HighlightCache[player] then
        HighlightCache[player]:Destroy()
        HighlightCache[player] = nil
    end
end

local function UpdateESP(player, box)
    local char = player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChild("Humanoid")
    
    if not hrp or not head or not hum or hum.Health <= 0 then
        box.Square.Visible = false
        box.Tracer.Visible = false
        box.Name.Visible = false
        box.Distance.Visible = false
        box.HealthBar.Visible = false
        box.HealthBarOutline.Visible = false
        box.Tool.Visible = false
        box.LookLine.Visible = false
        box.HeadDot.Visible = false
        return
    end
    
    if Config.TeamCheck and player.Team == LocalPlayer.Team then
        box.Square.Visible = false
        box.Tracer.Visible = false
        box.Name.Visible = false
        box.Distance.Visible = false
        box.HealthBar.Visible = false
        box.HealthBarOutline.Visible = false
        box.Tool.Visible = false
        box.LookLine.Visible = false
        box.HeadDot.Visible = false
        return
    end
    
    local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    
    if not onScreen then
        box.Square.Visible = false
        box.Tracer.Visible = false
        box.Name.Visible = false
        box.Distance.Visible = false
        box.HealthBar.Visible = false
        box.HealthBarOutline.Visible = false
        box.Tool.Visible = false
        box.LookLine.Visible = false
        box.HeadDot.Visible = false
        return
    end
    
    if Config.VisibleOnly then
        local ray = Ray.new(Camera.CFrame.Position, (hrp.Position - Camera.CFrame.Position).Unit * 1000)
        local part = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, char})
        if part then
            box.Square.Visible = false
            box.Tracer.Visible = false
            box.Name.Visible = false
            box.Distance.Visible = false
            box.HealthBar.Visible = false
            box.HealthBarOutline.Visible = false
            box.Tool.Visible = false
            box.LookLine.Visible = false
            box.HeadDot.Visible = false
            return
        end
    end
    
    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
    
    local height = math.abs(headPos.Y - legPos.Y)
    local width = height / 2
    
    local color = Config.BoxColor
    if Config.RainbowMode then
        color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    elseif Config.TeamCheck and Config.TeamColor and player.Team then
        color = player.Team.TeamColor.Color
    end
    
    if Config.Boxes then
        box.Square.Size = Vector2.new(width, height)
        box.Square.Position = Vector2.new(hrpPos.X - width/2, hrpPos.Y - height/2)
        box.Square.Color = color
        box.Square.Visible = true
    else
        box.Square.Visible = false
    end
    
    if Config.Tracers then
        box.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        box.Tracer.To = Vector2.new(hrpPos.X, hrpPos.Y)
        box.Tracer.Color = color
        box.Tracer.Visible = true
    else
        box.Tracer.Visible = false
    end
    
    if Config.Names then
        box.Name.Position = Vector2.new(hrpPos.X, hrpPos.Y - height/2 - 18)
        box.Name.Text = player.Name
        box.Name.Color = color
        box.Name.Visible = true
    else
        box.Name.Visible = false
    end
    
    if Config.Distance then
        local dist = math.floor((hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
        box.Distance.Position = Vector2.new(hrpPos.X, hrpPos.Y + height/2 + 4)
        box.Distance.Text = dist .. "m"
        box.Distance.Color = color
        box.Distance.Visible = true
    else
        box.Distance.Visible = false
    end
    
    if Config.HealthBars then
        local healthPercent = hum.Health / hum.MaxHealth
        local barHeight = height * healthPercent
        
        box.HealthBarOutline.Size = Vector2.new(4, height + 2)
        box.HealthBarOutline.Position = Vector2.new(hrpPos.X - width/2 - 8, hrpPos.Y - height/2 - 1)
        box.HealthBarOutline.Visible = true
        
        box.HealthBar.Size = Vector2.new(3, barHeight)
        box.HealthBar.Position = Vector2.new(hrpPos.X - width/2 - 7.5, hrpPos.Y + height/2 - barHeight)
        box.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
        box.HealthBar.Visible = true
    else
        box.HealthBar.Visible = false
        box.HealthBarOutline.Visible = false
    end
    
    -- NOVOS RECURSOS ESP
    if Config.ShowTools then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            box.Tool.Position = Vector2.new(hrpPos.X, hrpPos.Y + height/2 + 18)
            box.Tool.Text = "🔧 " .. tool.Name
            box.Tool.Visible = true
        else
            box.Tool.Visible = false
        end
    else
        box.Tool.Visible = false
    end
    
    if Config.ShowLookDirection then
        local lookVector = hrp.CFrame.LookVector * 5
        local lookPos = Camera:WorldToViewportPoint(hrp.Position + lookVector)
        box.LookLine.From = Vector2.new(hrpPos.X, hrpPos.Y)
        box.LookLine.To = Vector2.new(lookPos.X, lookPos.Y)
        box.LookLine.Color = color
        box.LookLine.Visible = true
    else
        box.LookLine.Visible = false
    end
    
    if Config.ShowHead then
        local headScreenPos = Camera:WorldToViewportPoint(head.Position)
        box.HeadDot.Position = Vector2.new(headScreenPos.X, headScreenPos.Y)
        box.HeadDot.Color = color
        box.HeadDot.Visible = true
    else
        box.HeadDot.Visible = false
    end
end

local function AddESP(player)
    if player == LocalPlayer then return end
    ESPObjects[player] = CreateBox()
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        
        -- Recriar Chams
        if Config.ChamsEnabled then
            CreateChams(player)
        end
        
        -- Recriar Highlight
        if Config.HighlightEnabled then
            CreateHighlight(player)
        end
    end)
end

-- NOVA FUNÇÃO: Chams
local function CreateChams(player)
    if player == LocalPlayer or not player.Character then return end
    
    local folder = Instance.new("Folder")
    folder.Name = player.Name
    folder.Parent = ChamsFolder
    
    for _, part in pairs(player.Character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local cham = Instance.new("BoxHandleAdornment")
            cham.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
            cham.AlwaysOnTop = true
            cham.ZIndex = 5
            cham.Transparency = Config.ESPTransparency
            cham.Color3 = Config.RainbowMode and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Config.BoxColor
            cham.Adornee = part
            cham.Parent = folder
        end
    end
end

-- NOVA FUNÇÃO: Highlight
local function CreateHighlight(player)
    if player == LocalPlayer or not player.Character then return end
    
    if HighlightCache[player] then
        HighlightCache[player]:Destroy()
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillColor = Config.RainbowMode and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Config.BoxColor
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = Config.ESPTransparency
    highlight.OutlineTransparency = 0
    highlight.Parent = player.Character
    
    HighlightCache[player] = highlight
end

-- NOVA FUNÇÃO: Atualizar Chams
local function UpdateChams()
    if not Config.ChamsEnabled then
        ChamsFolder:ClearAllChildren()
        return
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not ChamsFolder:FindFirstChild(player.Name) then
                CreateChams(player)
            else
                for _, cham in pairs(ChamsFolder[player.Name]:GetChildren()) do
                    if cham:IsA("BoxHandleAdornment") then
                        cham.Color3 = Config.RainbowMode and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Config.BoxColor
                        cham.Transparency = Config.ESPTransparency
                    end
                end
            end
        end
    end
end

-- NOVA FUNÇÃO: Atualizar Highlights
local function UpdateHighlights()
    if not Config.HighlightEnabled then
        for _, highlight in pairs(HighlightCache) do
            if highlight then highlight:Destroy() end
        end
        HighlightCache = {}
        return
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not HighlightCache[player] then
                CreateHighlight(player)
            else
                HighlightCache[player].FillColor = Config.RainbowMode and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Config.BoxColor
                HighlightCache[player].FillTransparency = Config.ESPTransparency
            end
        end
    end
end

--====================================
-- FUNÇÕES DE COMBAT (MANTIDAS + MELHORADAS)
--====================================

local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = Config.AimbotFOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if hrp and head and hum and hum.Health > 0 then
                if Config.TeamCheck and player.Team == LocalPlayer.Team then continue end
                
                -- Verificar visibilidade
                if Config.IgnoreWalls == false and Config.VisibleOnly then
                    local ray = Ray.new(Camera.CFrame.Position, (hrp.Position - Camera.CFrame.Position).Unit * 1000)
                    local part = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, player.Character})
                    if part then continue end
                end
                
                local targetPart = Config.AimbotTarget == "Head" and head or 
                                 Config.AimbotTarget == "Torso" and hrp or 
                                 (math.random(1, 2) == 1 and head or hrp)
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local mousePos = UIS:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function PredictPosition(player)
    if not Config.PredictMovement then return nil end
    
    local char = player.Character
    if not char then return nil end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local velocity = hrp.AssemblyVelocity
    local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
    local timeToHit = distance / 500 -- Assumindo velocidade de projétil
    
    return hrp.Position + (velocity * timeToHit)
end

local function Aimbot()
    if not Config.Aimbot then return end
    
    local target = GetClosestPlayerToCursor()
    if target and target.Character then
        local targetPart = Config.AimbotTarget == "Head" and target.Character:FindFirstChild("Head") or 
                          Config.AimbotTarget == "Torso" and target.Character:FindFirstChild("HumanoidRootPart") or
                          target.Character:FindFirstChild("Head")
        
        if targetPart then
            local targetPos = Config.PredictMovement and PredictPosition(target) or targetPart.Position
            if not targetPos then targetPos = targetPart.Position end
            
            local screenPos = Camera:WorldToViewportPoint(targetPos)
            local mousePos = UIS:GetMouseLocation()
            
            local deltaX = (screenPos.X - mousePos.X) * Config.AimbotSmoothing
            local deltaY = (screenPos.Y - mousePos.Y) * Config.AimbotSmoothing
            
            mousemoverel(deltaX, deltaY)
            
            -- Auto Shoot
            if Config.AutoShoot then
                mouse1press()
                task.wait()
                mouse1release()
            end
        end
    end
end

-- NOVA FUNÇÃO: Silent Aim
local function SilentAim()
    if not Config.SilentAim then return end
    
    local target = GetClosestPlayerToCursor()
    if target and target.Character then
        local targetPart = target.Character:FindFirstChild("Head")
        if targetPart then
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                
                if method == "FireServer" or method == "InvokeServer" then
                    -- Modificar argumentos de disparo
                    for i, arg in pairs(args) do
                        if typeof(arg) == "Vector3" then
                            args[i] = targetPart.Position
                        end
                    end
                end
                
                return oldNamecall(self, unpack(args))
            end)
        end
    end
end

-- NOVA FUNÇÃO: Trigger Bot
local function TriggerBot()
    if not Config.TriggerBot then return end
    
    local target = GetClosestPlayerToCursor()
    if target and target.Character then
        local distance = (target.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        
        if distance < 50 then -- Distância de trigger
            mouse1press()
            task.wait(0.1)
            mouse1release()
        end
    end
end

--====================================
-- FUNÇÕES DE PLAYER (MANTIDAS + MELHORADAS)
--====================================

local function SetWalkSpeed(speed)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = speed
        end
    end
end

local function SetJumpPower(power)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.JumpPower = power
        end
    end
end

local function ToggleFly(enabled)
    if enabled then
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local bg = Instance.new("BodyGyro")
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.cframe = hrp.CFrame
        bg.Parent = hrp
        
        local bv = Instance.new("BodyVelocity")
        bv.velocity = Vector3.new(0, 0, 0)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = hrp
        
        FlyConnection = RunService.Heartbeat:Connect(function()
            if not Config.Fly then
                bg:Destroy()
                bv:Destroy()
                if FlyConnection then FlyConnection:Disconnect() end
                return
            end
            
            local speed = Config.FlySpeed
            local cam = Camera
            
            bg.cframe = cam.CFrame
            
            local velocity = Vector3.new(0, 0, 0)
            
            if UIS:IsKeyDown(Enum.KeyCode.W) then
                velocity = velocity + (cam.CFrame.LookVector * speed)
            end
            if UIS:IsKeyDown(Enum.KeyCode.S) then
                velocity = velocity - (cam.CFrame.LookVector * speed)
            end
            if UIS:IsKeyDown(Enum.KeyCode.A) then
                velocity = velocity - (cam.CFrame.RightVector * speed)
            end
            if UIS:IsKeyDown(Enum.KeyCode.D) then
                velocity = velocity + (cam.CFrame.RightVector * speed)
            end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then
                velocity = velocity + Vector3.new(0, speed, 0)
            end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
                velocity = velocity - Vector3.new(0, speed, 0)
            end
            
            bv.velocity = velocity
        end)
    else
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end
    end
end

local function ToggleNoClip(enabled)
    if enabled then
        NoClipConnection = RunService.Stepped:Connect(function()
            if not Config.NoClip then
                if NoClipConnection then NoClipConnection:Disconnect() end
                return
            end
            
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
        end
    end
end

local function ToggleGod(enabled)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            if enabled then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            else
                hum.MaxHealth = 100
                hum.Health = 100
            end
        end
    end
end

-- NOVA FUNÇÃO: Platform
local function TogglePlatform(enabled)
    if enabled then
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        PlatformPart = Instance.new("Part")
        PlatformPart.Size = Vector3.new(10, 1, 10)
        PlatformPart.Anchored = true
        PlatformPart.Transparency = 0.5
        PlatformPart.Color = Color3.fromRGB(0, 255, 0)
        PlatformPart.Parent = workspace
        
        RunService.Heartbeat:Connect(function()
            if not Config.PlatformEnabled or not PlatformPart then return end
            PlatformPart.CFrame = hrp.CFrame - Vector3.new(0, 4, 0)
        end)
    else
        if PlatformPart then
            PlatformPart:Destroy()
            PlatformPart = nil
        end
    end
end

-- NOVA FUNÇÃO: Anti Void
local function ToggleAntiVoid(enabled)
    if enabled then
        AntiVoidPart = Instance.new("Part")
        AntiVoidPart.Size = Vector3.new(2048, 1, 2048)
        AntiVoidPart.Position = Vector3.new(0, -50, 0)
        AntiVoidPart.Anchored = true
        AntiVoidPart.Transparency = 0.7
        AntiVoidPart.Color = Color3.fromRGB(255, 0, 0)
        AntiVoidPart.Parent = workspace
    else
        if AntiVoidPart then
            AntiVoidPart:Destroy()
            AntiVoidPart = nil
        end
    end
end

-- NOVA FUNÇÃO: Anti Ragdoll
local function ToggleAntiRagdoll(enabled)
    if enabled then
        RunService.Stepped:Connect(function()
            if not Config.AntiRagdoll then return end
            
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                end
            end
        end)
    end
end

-- NOVA FUNÇÃO: Remove Accessories
local function RemoveAccessories()
    local char = LocalPlayer.Character
    if char then
        for _, accessory in pairs(char:GetChildren()) do
            if accessory:IsA("Accessory") then
                accessory:Destroy()
            end
        end
    end
end

--====================================
-- FUNÇÕES VISUAIS (MANTIDAS + MELHORADAS)
--====================================

local function ToggleFullbright(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
    end
end

local function CreateCrosshair()
    Crosshair.Top = Drawing.new("Line")
    Crosshair.Bottom = Drawing.new("Line")
    Crosshair.Left = Drawing.new("Line")
    Crosshair.Right = Drawing.new("Line")
    
    for _, line in pairs(Crosshair) do
        line.Thickness = 2
        line.Color = Color3.fromRGB(0, 255, 0)
        line.Visible = false
    end
end

local function UpdateCrosshair()
    if Config.Crosshair then
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local size = 10
        local color = Config.RainbowMode and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Color3.fromRGB(0, 255, 0)
        
        Crosshair.Top.From = Vector2.new(center.X, center.Y - size)
        Crosshair.Top.To = Vector2.new(center.X, center.Y - size/2)
        Crosshair.Top.Color = color
        
        Crosshair.Bottom.From = Vector2.new(center.X, center.Y + size/2)
        Crosshair.Bottom.To = Vector2.new(center.X, center.Y + size)
        Crosshair.Bottom.Color = color
        
        Crosshair.Left.From = Vector2.new(center.X - size, center.Y)
        Crosshair.Left.To = Vector2.new(center.X - size/2, center.Y)
        Crosshair.Left.Color = color
        
        Crosshair.Right.From = Vector2.new(center.X + size/2, center.Y)
        Crosshair.Right.To = Vector2.new(center.X + size, center.Y)
        Crosshair.Right.Color = color
        
        for _, line in pairs(Crosshair) do
            line.Visible = true
        end
    else
        for _, line in pairs(Crosshair) do
            line.Visible = false
        end
    end
end

local function UpdateFOVCircle()
    if Config.FOVCircle then
        FOVCircle.Visible = true
        FOVCircle.Thickness = 2
        FOVCircle.Color = Config.RainbowMode and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Color3.fromRGB(255, 255, 255)
        FOVCircle.Filled = false
        FOVCircle.Radius = Config.AimbotFOV
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        FOVCircle.Visible = false
    end
end

-- NOVA FUNÇÃO: FPS Boost
local function ApplyFPSBoost(enabled)
    if enabled then
        local decalsyeeted = true
        local g = game
        local w = g.Workspace
        local l = g.Lighting
        local t = w.Terrain
        
        t.WaterWaveSize = 0
        t.WaterWaveSpeed = 0
        t.WaterReflectance = 0
        t.WaterTransparency = 0
        l.GlobalShadows = false
        l.FogEnd = 9e9
        l.Brightness = 0
        
        settings().Rendering.QualityLevel = "Level01"
        
        for _, v in pairs(g:GetDescendants()) do
            if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
                v.Material = "Plastic"
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") and decalsyeeted then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Lifetime = NumberRange.new(0)
            elseif v:IsA("Explosion") then
                v.BlastPressure = 1
                v.BlastRadius = 1
            elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
            elseif v:IsA("MeshPart") then
                v.Material = "Plastic"
                v.Reflectance = 0
            end
        end
        
        for _, e in pairs(l:GetChildren()) do
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                e.Enabled = false
            end
        end
    end
end

-- NOVA FUNÇÃO: Remove Particles
local function RemoveParticles()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            v:Destroy()
        end
    end
end

--====================================
-- FUNÇÕES MISC (MANTIDAS + MELHORADAS)
--====================================

local function KillAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then
                hum.Health = 0
            end
        end
    end
end

local function TeleportToPlayer(targetPlayer, method)
    if targetPlayer and targetPlayer.Character then
        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if targetHRP and myHRP then
            method = method or Config.TeleportType
            
            if method == "Instant" then
                myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
            elseif method == "Tween" then
                local tween = TweenService:Create(myHRP, TweenInfo.new(1, Enum.EasingStyle.Linear), {
                    CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
                })
                tween:Play()
            end
        end
    end
end

local function ToggleSpinBot(enabled)
    if enabled then
        SpinBotConnection = RunService.Heartbeat:Connect(function()
            if not Config.SpinBot then
                if SpinBotConnection then SpinBotConnection:Disconnect() end
                return
            end
            
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(20), 0)
                end
            end
        end)
    else
        if SpinBotConnection then
            SpinBotConnection:Disconnect()
            SpinBotConnection = nil
        end
    end
end

local function AntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        if Config.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end

-- NOVA FUNÇÃO: Click TP
local function ToggleClickTP(enabled)
    if enabled then
        local Mouse = LocalPlayer:GetMouse()
        Mouse.Button1Down:Connect(function()
            if not Config.ClickTP then return end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
                    end
                end
            end
        end)
    end
end

-- NOVA FUNÇÃO: Click Delete
local function ToggleClickDelete(enabled)
    if enabled then
        local Mouse = LocalPlayer:GetMouse()
        Mouse.Button1Down:Connect(function()
            if not Config.ClickDelete then return end
            if UIS:IsKeyDown(Enum.KeyCode.LeftAlt) then
                if Mouse.Target then
                    Mouse.Target:Destroy()
                end
            end
        end)
    end
end

-- NOVA FUNÇÃO: Save/Load Position
local function SavePosition(name)
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            SavedPositions[name] = hrp.CFrame
            return true
        end
    end
    return false
end

local function LoadPosition(name)
    if SavedPositions[name] then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = SavedPositions[name]
                return true
            end
        end
    end
    return false
end

-- NOVA FUNÇÃO: Server Hop
local function ServerHop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    
    for _, server in pairs(servers.data) do
        if server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
            break
        end
    end
end

-- NOVA FUNÇÃO: Rejoin Server
local function RejoinServer()
    local TeleportService = game:GetService("TeleportService")
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

-- NOVA FUNÇÃO: Anti Kick
local function ToggleAntiKick(enabled)
    if enabled then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            
            if method == "Kick" then
                return wait(9e9)
            end
            
            return oldNamecall(self, ...)
        end)
    end
end

-- NOVA FUNÇÃO: Chat Spam
local function ToggleChatSpam(enabled)
    if enabled then
        spawn(function()
            while Config.ChatSpam do
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
                    Config.ChatSpamMessage,
                    "All"
                )
                wait(1)
            end
        end)
    end
end

-- NOVA FUNÇÃO: BTools
local function ToggleBTools(enabled)
    if enabled then
        local tool = Instance.new("HopperBin")
        tool.Name = "Move"
        tool.BinType = Enum.BinType.GameTool
        tool.Parent = LocalPlayer.Backpack
        
        local tool2 = Instance.new("HopperBin")
        tool2.Name = "Clone"
        tool2.BinType = Enum.BinType.Clone
        tool2.Parent = LocalPlayer.Backpack
        
        local tool3 = Instance.new("HopperBin")
        tool3.Name = "Delete"
        tool3.BinType = Enum.BinType.Hammer
        tool3.Parent = LocalPlayer.Backpack
    else
        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("HopperBin") then
                tool:Destroy()
            end
        end
    end
end

-- NOVA FUNÇÃO: Remote Spy
local function ToggleRemoteSpy(enabled)
    if enabled then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if method == "FireServer" or method == "InvokeServer" then
                print("[REMOTE SPY]", self:GetFullName(), method, unpack(args))
            end
            
            return oldNamecall(self, ...)
        end)
    end
end

--====================================
-- LOOP PRINCIPAL (MANTIDO + MELHORADO)
--====================================

RunService.RenderStepped:Connect(function()
    if Config.ESPEnabled then
        for player, box in pairs(ESPObjects) do
            if player and player.Parent then
                UpdateESP(player, box)
            else
                RemoveESP(player)
            end
        end
    else
        for player, box in pairs(ESPObjects) do
            box.Square.Visible = false
            box.Tracer.Visible = false
            box.Name.Visible = false
            box.Distance.Visible = false
            box.HealthBar.Visible = false
            box.HealthBarOutline.Visible = false
            box.Tool.Visible = false
            box.LookLine.Visible = false
            box.HeadDot.Visible = false
        end
    end
    
    if Config.Aimbot then
        Aimbot()
    end
    
    if Config.TriggerBot then
        TriggerBot()
    end
    
    UpdateCrosshair()
    UpdateFOVCircle()
    UpdateChams()
    UpdateHighlights()
    
    -- Manter velocidade
    if Config.WalkSpeed ~= 16 then
        SetWalkSpeed(Config.WalkSpeed)
    end
    
    -- Manter força do pulo
    if Config.JumpPower ~= 50 then
        SetJumpPower(Config.JumpPower)
    end
    
    -- Anti Slowdown
    if Config.AntiSlowdown then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = Config.WalkSpeed
            end
        end
    end
end)

Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(RemoveESP)

for _, player in ipairs(Players:GetPlayers()) do
    AddESP(player)
end

CreateCrosshair()
AntiAFK()

--====================================
-- INTERFACE GRÁFICA AVANÇADA (MANTIDA + MELHORADA)
--====================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "BlackSharkHack"
Gui.ResetOnSpawn = false
Gui.Parent = game.CoreGui

-- Frame Principal com animação
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 500, 0, 600)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 255, 255)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.5
MainStroke.Parent = Main
Main.Position = UDim2.new(0.5, -250, 0.5, -300)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.BorderSizePixel = 0
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = Gui

-- Sombra
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.Position = UDim2.new(0, -20, 0, -20)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Parent = Main

-- Arredondamento
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 15)
Corner.Parent = Main

-- Barra de título animada
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = TitleBar

-- Gradiente animado na barra
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 200))
}
TitleGradient.Parent = TitleBar

spawn(function()
    while wait() do
        TitleGradient.Rotation = (TitleGradient.Rotation + 1) % 360
    end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🦈 BLACK SHARK HACK"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Botão minimizar
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -75, 0, 6)
MinBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
MinBtn.Text = "─"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.Parent = TitleBar

local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(0, 8)
MinBtnCorner.Parent = MinBtn

-- Botão fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TitleBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 8)
CloseBtnCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    Main:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.3, true, function()
        Main.Visible = false
        Main.Size = UDim2.new(0, 500, 0, 600)
    end)
end)

MinBtn.MouseButton1Click:Connect(function()
    Main:TweenSize(UDim2.new(0, 500, 0, 45), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    MinBtn.Text = "☐"
    
    MinBtn.MouseButton1Click:Connect(function()
        Main:TweenSize(UDim2.new(0, 500, 0, 600), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        MinBtn.Text = "─"
    end)
end)

-- Sistema de abas melhorado
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 130, 1, -55)
TabContainer.Position = UDim2.new(0, 5, 0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Main

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -145, 1, -55)
ContentContainer.Position = UDim2.new(0, 140, 0, 50)
ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ContentContainer.Parent = Main

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 10)
ContentCorner.Parent = ContentContainer

-- Scroll para conteúdo
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -10, 1, -10)
ContentScroll.Position = UDim2.new(0, 5, 0, 5)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 6
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
ContentScroll.Parent = ContentContainer

local tabs = {}
local currentTab = nil

local function CreateTab(name, icon)
    local tab = {
        Name = name,
        Content = Instance.new("Frame"),
        Button = Instance.new("TextButton")
    }
    
    tab.Content.Size = UDim2.new(1, 0, 1, 0)
    tab.Content.BackgroundTransparency = 1
    tab.Content.Visible = false
    tab.Content.Parent = ContentScroll
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = tab.Content
    
    tab.Button.Size = UDim2.new(1, 0, 0, 40)
    tab.Button.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    tab.Button.Text = icon .. " " .. name
    tab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    tab.Button.Font = Enum.Font.GothamBold
    tab.Button.TextSize = 13
    tab.Button.Parent = TabContainer
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = tab.Button
    
    local btnGradient = Instance.new("UIGradient")
    btnGradient.Enabled = false
    btnGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 50, 200))
    }
    btnGradient.Rotation = 45
    btnGradient.Parent = tab.Button
    
    tab.Button.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Content.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
            t.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            t.Button:FindFirstChildOfClass("UIGradient").Enabled = false
        end
        
        tab.Content.Visible = true
        tab.Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        tab.Button.TextColor3 = Color3.new(1, 1, 1)
        btnGradient.Enabled = true
        currentTab = tab
        
        -- Animação
        tab.Button:TweenSize(UDim2.new(1.05, 0, 0, 42), Enum.EasingDirection.Out, Enum.EasingStyle.Elastic, 0.3, true, function()
            tab.Button:TweenSize(UDim2.new(1, 0, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        end)
    end)
    
    tab.Button.MouseEnter:Connect(function()
        if tab ~= currentTab then
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        end
    end)
    
    tab.Button.MouseLeave:Connect(function()
        if tab ~= currentTab then
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15, 15, 18)}):Play()
        end
    end)
    
    table.insert(tabs, tab)
    return tab
end

local tabLayout = Instance.new("UIListLayout")
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = TabContainer

-- Criar abas (MANTIDAS)
local espTab = CreateTab("ESP", "👁️")
local combatTab = CreateTab("Combat", "⚔️")
local playerTab = CreateTab("Player", "🏃")
local visualTab = CreateTab("Visual", "🎨")
local teleportTab = CreateTab("Teleport", "📍")
local serverTab = CreateTab("Server", "🌐")
local miscTab = CreateTab("Misc", "⚙️")

-- Função para criar toggle MELHORADA
local function CreateToggle(parent, text, configKey, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 35)
    container.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -55, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 45, 0, 22)
    toggle.Position = UDim2.new(1, -50, 0.5, -11)
    toggle.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(40, 40, 45)
    toggle.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 18, 0, 18)
    indicator.Position = Config[configKey] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    indicator.BackgroundColor3 = Color3.new(1, 1, 1)
    indicator.Parent = toggle
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator
    
    -- Adicionar brilho quando ativo
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    glow.Position = UDim2.new(0.25, 0, 0.25, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://1316045217"
    glow.ImageColor3 = Color3.fromRGB(0, 255, 255)
    glow.ImageTransparency = Config[configKey] and 0.3 or 1
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(10, 10, 118, 118)
    glow.Parent = toggle
    
    btn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        
        local targetColor = Config[configKey] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 80, 80)
        local targetPos = Config[configKey] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        local glowTrans = Config[configKey] and 0.3 or 1
        
        TweenService:Create(toggle, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(indicator, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = targetPos}):Play()
        TweenService:Create(glow, TweenInfo.new(0.3), {ImageTransparency = glowTrans}):Play()
        
        -- Animação de pulso
        container:TweenSize(UDim2.new(1, -8, 0, 37), Enum.EasingDirection.Out, Enum.EasingStyle.Elastic, 0.2, true, function()
            container:TweenSize(UDim2.new(1, -10, 0, 35), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
        end)
        
        if callback then callback(Config[configKey]) end
    end)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(container, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(container, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15, 15, 18)}):Play()
    end)
end

-- Função para criar slider MELHORADA
local function CreateSlider(parent, text, configKey, min, max, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 55)
    container.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 22)
    label.Position = UDim2.new(0, 12, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, -12, 0, 22)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 6)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(Config[configKey])
    valueLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    
    local sliderBG = Instance.new("Frame")
    sliderBG.Size = UDim2.new(1, -24, 0, 8)
    sliderBG.Position = UDim2.new(0, 12, 0, 35)
    sliderBG.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    sliderBG.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderBG
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((Config[configKey] - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    sliderFill.Parent = sliderBG
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    -- Gradiente no slider
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 50, 200))
    }
    fillGradient.Parent = sliderFill
    
    local sliderDot = Instance.new("Frame")
    sliderDot.Size = UDim2.new(0, 16, 0, 16)
    sliderDot.Position = UDim2.new((Config[configKey] - min) / (max - min), -8, 0.5, -8)
    sliderDot.BackgroundColor3 = Color3.new(1, 1, 1)
    sliderDot.Parent = sliderBG
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = sliderDot
    
    local dragging = false
    
    sliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    sliderBG.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * pos)
            
            Config[configKey] = value
            valueLabel.Text = tostring(value)
            
            TweenService:Create(sliderFill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
            TweenService:Create(sliderDot, TweenInfo.new(0.1), {Position = UDim2.new(pos, -8, 0.5, -8)}):Play()
            
            if callback then callback(value) end
        end
    end)
end

-- Função para criar botão MELHORADA
local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 50, 200))
    }
    gradient.Rotation = 45
    gradient.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -12, 0, 36)}):Play()
        wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Elastic), {Size = UDim2.new(1, -10, 0, 38)}):Play()
        
        if callback then callback() end
    end)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 70, 70)}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 255)}):Play()
    end)
end

-- Função para criar dropdown de jogadores MELHORADA
local function CreatePlayerDropdown(parent, text, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 38)
    container.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = text .. " ▼"
    btn.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = container
    
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(1, 0, 0, 0)
    dropdown.Position = UDim2.new(0, 0, 1, 5)
    dropdown.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    dropdown.Visible = false
    dropdown.Parent = container
    dropdown.ClipsDescendants = true
    dropdown.ZIndex = 10
    
    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 8)
    dropCorner.Parent = dropdown
    
    local dropScroll = Instance.new("ScrollingFrame")
    dropScroll.Size = UDim2.new(1, 0, 1, 0)
    dropScroll.BackgroundTransparency = 1
    dropScroll.BorderSizePixel = 0
    dropScroll.ScrollBarThickness = 4
    dropScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
    dropScroll.Parent = dropdown
    
    local dropLayout = Instance.new("UIListLayout")
    dropLayout.SortOrder = Enum.SortOrder.LayoutOrder
    dropLayout.Padding = UDim.new(0, 2)
    dropLayout.Parent = dropScroll
    
    btn.MouseButton1Click:Connect(function()
        dropdown.Visible = not dropdown.Visible
        
        if dropdown.Visible then
            for _, child in ipairs(dropScroll:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local playerBtn = Instance.new("TextButton")
                    playerBtn.Size = UDim2.new(1, 0, 0, 32)
                    playerBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
                    playerBtn.Text = "👤 " .. player.Name
                    playerBtn.TextColor3 = Color3.new(0.9, 0.9, 0.9)
                    playerBtn.Font = Enum.Font.Gotham
                    playerBtn.TextSize = 12
                    playerBtn.Parent = dropScroll
                    
                    local pCorner = Instance.new("UICorner")
                    pCorner.CornerRadius = UDim.new(0, 6)
                    pCorner.Parent = playerBtn
                    
                    playerBtn.MouseButton1Click:Connect(function()
                        dropdown.Visible = false
                        dropdown:TweenSize(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                        if callback then callback(player) end
                    end)
                    
                    playerBtn.MouseEnter:Connect(function()
                        TweenService:Create(playerBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 255)}):Play()
                    end)
                    
                    playerBtn.MouseLeave:Connect(function()
                        TweenService:Create(playerBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15, 15, 18)}):Play()
                    end)
                end
            end
            
            local playerCount = #Players:GetPlayers() - 1
            dropdown:TweenSize(UDim2.new(1, 0, 0, math.min(playerCount * 34, 170)), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        else
            dropdown:TweenSize(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        end
    end)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(container, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(container, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15, 15, 18)}):Play()
    end)
end

-- NOVA FUNÇÃO: Criar Input de Texto
local function CreateTextInput(parent, text, configKey, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 38)
    container.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 100, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. ":"
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -120, 0, 28)
    input.Position = UDim2.new(0, 110, 0.5, -14)
    input.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    input.Text = Config[configKey] or ""
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.Gotham
    input.TextSize = 12
    input.PlaceholderText = "Digite aqui..."
    input.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    input.ClearTextOnFocus = false
    input.Parent = container
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input
    
    input.FocusLost:Connect(function()
        Config[configKey] = input.Text
        if callback then callback(input.Text) end
    end)
end

-- NOVA FUNÇÃO: Criar Categoria
local function CreateCategory(parent, text)
    local category = Instance.new("TextLabel")
    category.Size = UDim2.new(1, -10, 0, 28)
    category.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    category.Text = "  " .. text
    category.TextColor3 = Color3.fromRGB(0, 255, 255)
    category.Font = Enum.Font.GothamBold
    category.TextSize = 14
    category.TextXAlignment = Enum.TextXAlignment.Left
    category.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = category
end

--====================================
-- POPULAR ABAS COM OPÇÕES (MANTIDAS + NOVAS)
--====================================

-- ABA ESP (MANTIDA + MELHORADA)
CreateCategory(espTab.Content, "📌 ESP BÁSICO")
CreateToggle(espTab.Content, "ESP Ativado", "ESPEnabled")
CreateToggle(espTab.Content, "Boxes", "Boxes")
CreateToggle(espTab.Content, "Nomes", "Names")
CreateToggle(espTab.Content, "Distância", "Distance")
CreateToggle(espTab.Content, "Tracers", "Tracers")
CreateToggle(espTab.Content, "Barras de Vida", "HealthBars")
CreateToggle(espTab.Content, "Skeleton", "Skeleton")
CreateToggle(espTab.Content, "Team Check", "TeamCheck")
CreateToggle(espTab.Content, "Apenas Visíveis", "VisibleOnly")
CreateToggle(espTab.Content, "Cor do Time", "TeamColor")

CreateCategory(espTab.Content, "🎨 ESP AVANÇADO")
CreateToggle(espTab.Content, "Chams (3D)", "ChamsEnabled", function(enabled)
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then CreateChams(player) end
        end
    else
        ChamsFolder:ClearAllChildren()
    end
end)
CreateToggle(espTab.Content, "Highlight", "HighlightEnabled", function(enabled)
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then CreateHighlight(player) end
        end
    else
        for _, h in pairs(HighlightCache) do h:Destroy() end
        HighlightCache = {}
    end
end)
CreateToggle(espTab.Content, "Mostrar Ferramentas", "ShowTools")
CreateToggle(espTab.Content, "Mostrar Cabeça", "ShowHead")
CreateToggle(espTab.Content, "Direção do Olhar", "ShowLookDirection")
CreateToggle(espTab.Content, "Modo Rainbow", "RainbowMode")
CreateSlider(espTab.Content, "Transparência", "ESPTransparency", 0, 1)

-- ABA COMBAT (MANTIDA + MELHORADA)
CreateCategory(combatTab.Content, "🎯 AIMBOT")
CreateToggle(combatTab.Content, "Aimbot", "Aimbot")
CreateSlider(combatTab.Content, "FOV do Aimbot", "AimbotFOV", 50, 500)
CreateSlider(combatTab.Content, "Suavização", "AimbotSmoothing", 0.01, 1)
CreateToggle(combatTab.Content, "Prever Movimento", "PredictMovement")
CreateToggle(combatTab.Content, "Ignorar Paredes", "IgnoreWalls")
CreateToggle(combatTab.Content, "Auto Shoot", "AutoShoot")
CreateToggle(combatTab.Content, "Círculo FOV", "FOVCircle")

CreateCategory(combatTab.Content, "⚡ COMBAT AVANÇADO")
CreateToggle(combatTab.Content, "Silent Aim", "SilentAim")
CreateToggle(combatTab.Content, "Trigger Bot", "TriggerBot")
CreateToggle(combatTab.Content, "Rapid Fire", "RapidFire")
CreateToggle(combatTab.Content, "No Recoil", "NoRecoil")
CreateToggle(combatTab.Content, "Munição Infinita", "InfiniteAmmo")

-- ABA PLAYER (MANTIDA + MELHORADA)
CreateCategory(playerTab.Content, "🏃 MOVIMENTO")
CreateSlider(playerTab.Content, "Velocidade", "WalkSpeed", 16, 500, SetWalkSpeed)
CreateSlider(playerTab.Content, "Força do Pulo", "JumpPower", 50, 500, SetJumpPower)
CreateToggle(playerTab.Content, "Pulo Infinito", "InfiniteJump")
CreateToggle(playerTab.Content, "NoClip", "NoClip", ToggleNoClip)
CreateToggle(playerTab.Content, "Voar", "Fly", ToggleFly)
CreateSlider(playerTab.Content, "Velocidade de Voo", "FlySpeed", 10, 200)

CreateCategory(playerTab.Content, "🛡️ PROTEÇÃO")
CreateToggle(playerTab.Content, "God Mode", "God", ToggleGod)
CreateToggle(playerTab.Content, "Anti Ragdoll", "AntiRagdoll", ToggleAntiRagdoll)
CreateToggle(playerTab.Content, "Anti Slowdown", "AntiSlowdown")
CreateToggle(playerTab.Content, "Anti Knockback", "AntiKnockback")
CreateToggle(playerTab.Content, "Platform", "PlatformEnabled", TogglePlatform)

CreateCategory(playerTab.Content, "⚙️ OUTROS")
CreateToggle(playerTab.Content, "Auto Respawn", "AutoRespawn")
CreateButton(playerTab.Content, "Remover Acessórios", RemoveAccessories)
CreateButton(playerTab.Content, "Reset Character", function()
    LocalPlayer.Character:BreakJoints()
end)

-- ABA VISUAL (MANTIDA + MELHORADA)
CreateCategory(visualTab.Content, "💡 ILUMINAÇÃO")
CreateToggle(visualTab.Content, "Fullbright", "Fullbright", ToggleFullbright)
CreateToggle(visualTab.Content, "Remover Neblina", "RemoveFog")
CreateToggle(visualTab.Content, "Crosshair", "Crosshair")

CreateCategory(visualTab.Content, "🎭 EFEITOS")
CreateToggle(visualTab.Content, "FPS Boost", "FPSBoost", ApplyFPSBoost)
CreateButton(visualTab.Content, "Remover Texturas", function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Decal") or obj:IsA("Texture") then
            obj:Destroy()
        end
    end
end)
CreateButton(visualTab.Content, "Remover Partículas", RemoveParticles)
CreateToggle(visualTab.Content, "Gráficos Baixos", "LowGraphics")

-- NOVA ABA TELEPORT
CreateCategory(teleportTab.Content, "📍 TELEPORTE")
CreatePlayerDropdown(teleportTab.Content, "Teleportar para Jogador", function(player)
    TeleportToPlayer(player)
end)
CreateToggle(teleportTab.Content, "Click TP (CTRL+Click)", "ClickTP", ToggleClickTP)

CreateCategory(teleportTab.Content, "💾 POSIÇÕES SALVAS")
CreateButton(teleportTab.Content, "💾 Salvar Posição 1", function()
    if SavePosition("pos1") then
        Notify("✅ Posição 1 salva!", 2)
    end
end)
CreateButton(teleportTab.Content, "📌 Carregar Posição 1", function()
    if LoadPosition("pos1") then
        Notify("✅ Teleportado para Posição 1!", 2)
    else
        Notify("❌ Posição 1 não encontrada!", 2)
    end
end)
CreateButton(teleportTab.Content, "💾 Salvar Posição 2", function()
    if SavePosition("pos2") then
        Notify("✅ Posição 2 salva!", 2)
    end
end)
CreateButton(teleportTab.Content, "📌 Carregar Posição 2", function()
    if LoadPosition("pos2") then
        Notify("✅ Teleportado para Posição 2!", 2)
    else
        Notify("❌ Posição 2 não encontrada!", 2)
    end
end)

-- NOVA ABA SERVER
CreateCategory(serverTab.Content, "🌐 SERVIDOR")
CreateToggle(serverTab.Content, "Anti Kick", "AntiKick", ToggleAntiKick)
CreateToggle(serverTab.Content, "Anti Void", "AntiVoid", function(enabled)
    ToggleAntiVoid(enabled)
end)
CreateButton(serverTab.Content, "🔄 Server Hop", ServerHop)
CreateButton(serverTab.Content, "🔃 Rejoin Server", RejoinServer)

CreateCategory(serverTab.Content, "💬 CHAT")
CreateToggle(serverTab.Content, "Chat Spam", "ChatSpam", ToggleChatSpam)
CreateTextInput(serverTab.Content, "Mensagem", "ChatSpamMessage")

-- ABA MISC (MANTIDA + MELHORADA)
CreateCategory(miscTab.Content, "⚙️ FERRAMENTAS")
CreateToggle(miscTab.Content, "BTools", "BTools", ToggleBTools)
CreateToggle(miscTab.Content, "Click Delete (ALT+Click)", "ClickDelete", ToggleClickDelete)
CreateToggle(miscTab.Content, "Remote Spy", "RemotesSpy", ToggleRemoteSpy)

CreateCategory(miscTab.Content, "🎮 AUTOMAÇÃO")
CreateToggle(miscTab.Content, "Anti AFK", "AntiAFK")
CreateToggle(miscTab.Content, "SpinBot", "SpinBot", ToggleSpinBot)

CreateCategory(miscTab.Content, "⚠️ PERIGOSO")
CreateButton(miscTab.Content, "🔴 Matar Todos", KillAll)
CreateButton(miscTab.Content, "🔄 Resetar Configurações", function()
    for key, value in pairs(Config) do
        if type(value) == "boolean" then
            Config[key] = false
        elseif type(value) == "number" then
            if key == "WalkSpeed" then Config[key] = 16
            elseif key == "JumpPower" then Config[key] = 50
            elseif key == "AimbotFOV" then Config[key] = 200
            elseif key == "AimbotSmoothing" then Config[key] = 0.1
            elseif key == "FlySpeed" then Config[key] = 50
            elseif key == "ESPTransparency" then Config[key] = 0.3
            end
        end
    end
    Notify("✅ Configurações resetadas!", 2)
end)
CreateButton(miscTab.Content, "💥 Destruir Interface", function()
    Notify("👋 Interface destruída!", 2)
    wait(2)
    Gui:Destroy()
end)

-- Informações do sistema MELHORADAS
local infoContainer = Instance.new("Frame")
infoContainer.Size = UDim2.new(1, -10, 0, 90)
infoContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
infoContainer.Parent = miscTab.Content

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = infoContainer

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 1, -20)
infoLabel.Position = UDim2.new(0, 10, 0, 10)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 12
infoLabel.Text = "📊 Sistema: Exploit Test v2.0\n⚡ FPS: Calculando...\n📡 Ping: Calculando...\n👥 Jogadores: Calculando..."
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Parent = infoContainer

-- Atualizar FPS e Ping
spawn(function()
    while wait(1) do
        local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
        local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
        local playerCount = #Players:GetPlayers()
        
        infoLabel.Text = string.format(
            "📊 Sistema: Exploit Test v2.0 Advanced\n⚡ FPS: %d\n📡 Ping: %d ms\n👥 Jogadores: %d/%d",
            fps, ping, playerCount, Players.MaxPlayers or playerCount
        )
    end
end)

--====================================
-- ARRASTAR JANELA (MANTIDO)
--====================================

local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

--====================================
-- HOTKEYS (MANTIDAS + NOVAS)
--====================================

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    -- INSERT - Abrir/Fechar menu (MANTIDO)
    if input.KeyCode == Enum.KeyCode.Insert then
        if Main.Visible then
            Main:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.3, true, function()
                Main.Visible = false
                Main.Size = UDim2.new(0, 500, 0, 600)
            end)
        else
            Main.Visible = true
            Main.Size = UDim2.new(0, 0, 0, 0)
            Main:TweenSize(UDim2.new(0, 500, 0, 600), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.4, true)
        end
    end
    
    -- F1 - Toggle ESP rápido (MANTIDO)
    if input.KeyCode == Enum.KeyCode.F1 then
        Config.ESPEnabled = not Config.ESPEnabled
        Notify(Config.ESPEnabled and "✅ ESP Ativado" or "❌ ESP Desativado", 1.5)
    end
    
    -- F2 - Toggle Aimbot rápido (MANTIDO)
    if input.KeyCode == Enum.KeyCode.F2 then
        Config.Aimbot = not Config.Aimbot
        Notify(Config.Aimbot and "✅ Aimbot Ativado" or "❌ Aimbot Desativado", 1.5)
    end
    
    -- F3 - Toggle Fly rápido (MANTIDO)
    if input.KeyCode == Enum.KeyCode.F3 then
        Config.Fly = not Config.Fly
        ToggleFly(Config.Fly)
        Notify(Config.Fly and "✅ Fly Ativado" or "❌ Fly Desativado", 1.5)
    end
    
    -- F4 - Toggle NoClip rápido (NOVO)
    if input.KeyCode == Enum.KeyCode.F4 then
        Config.NoClip = not Config.NoClip
        ToggleNoClip(Config.NoClip)
        Notify(Config.NoClip and "✅ NoClip Ativado" or "❌ NoClip Desativado", 1.5)
    end
    
    -- F5 - Toggle Fullbright rápido (NOVO)
    if input.KeyCode == Enum.KeyCode.F5 then
        Config.Fullbright = not Config.Fullbright
        ToggleFullbright(Config.Fullbright)
        Notify(Config.Fullbright and "✅ Fullbright Ativado" or "❌ Fullbright Desativado", 1.5)
    end
    
    -- SPACE - Pulo infinito (MANTIDO)
    if Config.InfiniteJump and input.KeyCode == Enum.KeyCode.Space then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Abrir primeira aba por padrão (MANTIDO)
if #tabs > 0 then
    tabs[1].Button.MouseButton1Click:Fire()
end

-- Notificação de carregamento MELHORADA
local function Notify(text, duration)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 320, 0, 60)
    notif.Position = UDim2.new(0.5, -160, 0, -70)
    notif.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    notif.Parent = Gui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 10)
    notifCorner.Parent = notif
    
    local notifGradient = Instance.new("UIGradient")
    notifGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 50, 200))
    }
    notifGradient.Rotation = 45
    notifGradient.Parent = notif
    
    local notifShadow = Instance.new("ImageLabel")
    notifShadow.Size = UDim2.new(1, 30, 1, 30)
    notifShadow.Position = UDim2.new(0, -15, 0, -15)
    notifShadow.BackgroundTransparency = 1
    notifShadow.Image = "rbxassetid://1316045217"
    notifShadow.ImageColor3 = Color3.new(0, 0, 0)
    notifShadow.ImageTransparency = 0.5
    notifShadow.ScaleType = Enum.ScaleType.Slice
    notifShadow.SliceCenter = Rect.new(10, 10, 118, 118)
    notifShadow.Parent = notif
    
    local notifLabel = Instance.new("TextLabel")
    notifLabel.Size = UDim2.new(1, -20, 1, -20)
    notifLabel.Position = UDim2.new(0, 10, 0, 10)
    notifLabel.BackgroundTransparency = 1
    notifLabel.Text = text
    notifLabel.TextColor3 = Color3.new(1, 1, 1)
    notifLabel.Font = Enum.Font.GothamBold
    notifLabel.TextSize = 14
    notifLabel.TextWrapped = true
    notifLabel.Parent = notif
    
    notif:TweenPosition(UDim2.new(0.5, -160, 0, 15), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)
    
    wait(duration or 3)
    
    notif:TweenPosition(UDim2.new(0.5, -160, 0, -70), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.5, true, function()
        notif:Destroy()
    end)
end

-- Animação de abertura
Main.Visible = true
Main.Size = UDim2.new(0, 0, 0, 0)
Main:TweenSize(UDim2.new(0, 500, 0, 600), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.6, true)

Notify("✅ Exploit Test V2.0 Carregado!\nPressione INSERT para abrir/fechar", 4)

--====================================
-- FEATURES ADICIONAIS E LOOPS
--====================================

-- Loop de atualização de recursos especiais
spawn(function()
    while wait(0.5) do
        -- Atualizar Chams com rainbow
        if Config.ChamsEnabled and Config.RainbowMode then
            UpdateChams()
        end
        
        -- Atualizar Highlights com rainbow
        if Config.HighlightEnabled and Config.RainbowMode then
            UpdateHighlights()
        end
    end
end)

-- Anti Kick Melhorado
if Config.AntiKick then
    local oldKick
    oldKick = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" then
            return wait(9e9)
        end
        return oldKick(self, ...)
    end)
end

-- Infinite Ammo
spawn(function()
    while wait(0.1) do
        if Config.InfiniteAmmo then
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    local ammo = tool:FindFirstChild("Ammo")
                    if ammo and ammo:IsA("IntValue") then
                        ammo.Value = 999
                    end
                end
            end
        end
    end
end)

-- Rapid Fire
local oldWait = wait
if Config.RapidFire then
    wait = function(time)
        if time and time > 0.1 then
            return oldWait(0.01)
        end
        return oldWait(time)
    end
end

-- Auto Respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    if Config.AutoRespawn then
        wait(0.1)
        -- Aplicar configurações automaticamente
        if Config.WalkSpeed ~= 16 then
            SetWalkSpeed(Config.WalkSpeed)
        end
        if Config.JumpPower ~= 50 then
            SetJumpPower(Config.JumpPower)
        end
        if Config.God then
            ToggleGod(true)
        end
    end
end)

--====================================
-- SISTEMA DE LOGS E DEBUG
--====================================

local LogSystem = {
    Logs = {},
    MaxLogs = 100
}

function LogSystem:Add(text, type)
    local log = {
        Text = text,
        Type = type or "Info",
        Time = os.date("%H:%M:%S")
    }
    
    table.insert(self.Logs, log)
    
    if #self.Logs > self.MaxLogs then
        table.remove(self.Logs, 1)
    end
    
    print(string.format("[%s] [%s] %s", log.Time, log.Type, log.Text))
end

function LogSystem:GetLogs()
    return self.Logs
end

-- Registrar eventos importantes
Players.PlayerAdded:Connect(function(player)
    LogSystem:Add(player.Name .. " entrou no servidor", "Player")
end)

Players.PlayerRemoving:Connect(function(player)
    LogSystem:Add(player.Name .. " saiu do servidor", "Player")
end)

LocalPlayer.CharacterAdded:Connect(function()
    LogSystem:Add("Character respawnado", "Character")
end)

--====================================
-- SISTEMA DE CONFIGURAÇÕES
--====================================

local ConfigSystem = {
    SavedConfigs = {}
}

function ConfigSystem:Save(name)
    local config = {}
    for key, value in pairs(Config) do
        config[key] = value
    end
    self.SavedConfigs[name] = config
    LogSystem:Add("Configuração '" .. name .. "' salva", "Config")
    return true
end

function ConfigSystem:Load(name)
    if self.SavedConfigs[name] then
        for key, value in pairs(self.SavedConfigs[name]) do
            Config[key] = value
        end
        LogSystem:Add("Configuração '" .. name .. "' carregada", "Config")
        return true
    end
    return false
end

--====================================
-- PROTEÇÃO ANTI-DETECÇÃO
--====================================

-- Ocultar GUI do detector de exploits
spawn(function()
    while wait(1) do
        for _, gui in pairs(game.CoreGui:GetChildren()) do
            if gui.Name ~= "BlackSharkHack" and gui.Name:find("Anti") or gui.Name:find("Detect") then
                gui:Destroy()
            end
        end
    end
end)

-- Hook de proteção
local old_namecall
old_namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Bloquear detecção de alteração de walkspeed
    if method == "FireServer" and tostring(self):find("Report") then
        return
    end
    
    -- Bloquear kick
    if method == "Kick" then
        return wait(9e9)
    end
    
    return old_namecall(self, ...)
end)

--====================================
-- ESTATÍSTICAS E MONITORAMENTO
--====================================

local Stats = {
    StartTime = tick(),
    Kills = 0,
    Deaths = 0,
    Teleports = 0,
    ItemsCollected = 0
}

function Stats:GetUptime()
    local uptime = tick() - self.StartTime
    local hours = math.floor(uptime / 3600)
    local minutes = math.floor((uptime % 3600) / 60)
    local seconds = math.floor(uptime % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

-- Criar aba de estatísticas
local statsTab = CreateTab("Stats", "📊")

CreateCategory(statsTab.Content, "📊 ESTATÍSTICAS")

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -10, 0, 120)
statsLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextSize = 12
statsLabel.Text = "Carregando estatísticas..."
statsLabel.TextYAlignment = Enum.TextYAlignment.Top
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Parent = statsTab.Content

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 8)
statsCorner.Parent = statsLabel

-- Atualizar estatísticas
spawn(function()
    while wait(1) do
        local text = string.format([[
  ⏱️ Tempo Ativo: %s
  💀 Kills: %d
  ☠️ Deaths: %d
  📍 Teleportes: %d
  🎁 Itens Coletados: %d
  📝 Logs: %d
  👥 Jogadores: %d
]], 
            Stats:GetUptime(),
            Stats.Kills,
            Stats.Deaths,
            Stats.Teleports,
            Stats.ItemsCollected,
            #LogSystem.Logs,
            #Players:GetPlayers()
        )
        statsLabel.Text = text
    end
end)

CreateButton(statsTab.Content, "🔄 Resetar Estatísticas", function()
    Stats.Kills = 0
    Stats.Deaths = 0
    Stats.Teleports = 0
    Stats.ItemsCollected = 0
    Stats.StartTime = tick()
    Notify("✅ Estatísticas resetadas!", 2)
end)

--====================================
-- CONSOLE DE LOGS
--====================================

CreateCategory(statsTab.Content, "📝 LOGS DO SISTEMA")

local logsScroll = Instance.new("ScrollingFrame")
logsScroll.Size = UDim2.new(1, -10, 0, 200)
logsScroll.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
logsScroll.BorderSizePixel = 0
logsScroll.ScrollBarThickness = 4
logsScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
logsScroll.Parent = statsTab.Content

local logsCorner = Instance.new("UICorner")
logsCorner.CornerRadius = UDim.new(0, 8)
logsCorner.Parent = logsScroll

local logsLayout = Instance.new("UIListLayout")
logsLayout.SortOrder = Enum.SortOrder.LayoutOrder
logsLayout.Padding = UDim.new(0, 2)
logsLayout.Parent = logsScroll

CreateButton(statsTab.Content, "🗑️ Limpar Logs", function()
    LogSystem.Logs = {}
    for _, child in pairs(logsScroll:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    Notify("✅ Logs limpos!", 2)
end)

-- Atualizar logs visualmente
spawn(function()
    local lastLogCount = 0
    while wait(0.5) do
        if #LogSystem.Logs > lastLogCount then
            for i = lastLogCount + 1, #LogSystem.Logs do
                local log = LogSystem.Logs[i]
                
                local logLabel = Instance.new("TextLabel")
                logLabel.Size = UDim2.new(1, -10, 0, 20)
                logLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
                logLabel.TextColor3 = log.Type == "Error" and Color3.fromRGB(255, 100, 100) or 
                                     log.Type == "Warning" and Color3.fromRGB(255, 200, 100) or
                                     Color3.fromRGB(200, 200, 200)
                logLabel.Font = Enum.Font.Code
                logLabel.TextSize = 10
                logLabel.Text = string.format("[%s] %s", log.Time, log.Text)
                logLabel.TextXAlignment = Enum.TextXAlignment.Left
                logLabel.Parent = logsScroll
                
                local logCorner = Instance.new("UICorner")
                logCorner.CornerRadius = UDim.new(0, 4)
                logCorner.Parent = logLabel
            end
            lastLogCount = #LogSystem.Logs
            logsScroll.CanvasSize = UDim2.new(0, 0, 0, logsLayout.AbsoluteContentSize.Y)
        end
    end
end)

--====================================
-- FINALIZAÇÃO
--====================================

LogSystem:Add("Black Shark Hack carregado com sucesso!", "System")
LogSystem:Add("Total de " .. #tabs .. " abas carregadas", "System")
LogSystem:Add("Total de " .. #Players:GetPlayers() .. " jogadores no servidor", "System")

print("================================================")
print("BLACK SHARK HACK - MENU")
print("================================================")
print("✅ Sistema carregado com sucesso!")
print("================================================")
print("⌨️ Teclas de Atalho:")
print("INSERT  - Abrir/Fechar Menu")
print("F1      - Toggle ESP Rápido")
print("F2      - Toggle Aimbot Rápido")
print("F3      - Toggle Fly Rápido")
print("F4      - Toggle NoClip Rápido")
print("F5      - Toggle Fullbright Rápido")
print("================================================")
print("🔧 Recursos:")
print("- ESP Avançado (Chams, Highlights, 3D)")
print("- Combat System (Aimbot, Silent Aim, Trigger)")
print("- Player Mods (Fly, NoClip, Speed, God)")
print("- Teleport System (Click TP, Saved Positions)")
print("- Server Tools (Anti-Kick, Server Hop)")
print("- Visual Enhancements (Fullbright, FPS Boost)")
print("- Statistics & Logs System")
print("- Anti-Detection Protection")
print("================================================")
print("📊 Status:")
print("Jogadores: " .. #Players:GetPlayers())
print("Ping: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. "ms")
print("================================================")
