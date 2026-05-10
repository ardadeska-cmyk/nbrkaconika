local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Executor'un Teleport fonksiyonunu tanımla
local queue_on_teleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

-- Sunucu değişimlerinde ayarları hatırlamak için Global Config oluştur
getgenv().EndwareConfig = getgenv().EndwareConfig or {
    isSpamming = false,
    isAutoFarming = false,
    isSafeFarming = false,
    isAutoReplay = false,
    isAutoExecute = false,
    hitcountValue = 2
}
local config = getgenv().EndwareConfig

local EndwareName = "Endware"
local connections = {}

-- Event'i bul
local bridgeNetEvent = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

-- Mevcut menü varsa sil
if CoreGui:FindFirstChild(EndwareName) then
    CoreGui[EndwareName]:Destroy()
end

-- GUI Oluşturma
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = EndwareName
ScreenGui.ResetOnSpawn = false

local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Modern Renk Paleti
local Colors = {
    Background = Color3.fromRGB(22, 22, 26),
    ElementBg = Color3.fromRGB(35, 35, 42),
    Accent = Color3.fromRGB(0, 170, 255),
    Text = Color3.fromRGB(240, 240, 240),
    TextMuted = Color3.fromRGB(150, 150, 150),
    Red = Color3.fromRGB(255, 65, 80)
}

local function tween(object, props, time)
    local t = TweenService:Create(object, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- Ana Çerçeve (MainFrame) - Boyutu yeni ayarlar için 500'e çıkarıldı
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 500)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -250)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(50, 50, 60)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

-- Sürükleme Mantığı
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
table.insert(connections, RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end))

-- Başlık
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = " " .. EndwareName
Title.TextColor3 = Colors.Text
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Hitcount Seçimi
local Hit2Btn = Instance.new("TextButton")
Hit2Btn.Size = UDim2.new(0.45, 0, 0, 35)
Hit2Btn.Position = UDim2.new(0, 15, 0, 50)
Hit2Btn.BackgroundColor3 = Colors.ElementBg
Hit2Btn.Text = "Hitcount 2"
Hit2Btn.TextColor3 = Colors.Text
Hit2Btn.Font = Enum.Font.GothamBold
Hit2Btn.TextSize = 14
Hit2Btn.Parent = MainFrame
Instance.new("UICorner", Hit2Btn).CornerRadius = UDim.new(0, 6)

local Hit3Btn = Instance.new("TextButton")
Hit3Btn.Size = UDim2.new(0.45, 0, 0, 35)
Hit3Btn.Position = UDim2.new(1, -15, 0, 50)
Hit3Btn.AnchorPoint = Vector2.new(1, 0)
Hit3Btn.BackgroundColor3 = Colors.ElementBg
Hit3Btn.Text = "Hitcount 3"
Hit3Btn.TextColor3 = Colors.Text
Hit3Btn.Font = Enum.Font.GothamBold
Hit3Btn.TextSize = 14
Hit3Btn.Parent = MainFrame
Instance.new("UICorner", Hit3Btn).CornerRadius = UDim.new(0, 6)

local function updateHitcountUI()
    if config.hitcountValue == 2 then
        tween(Hit2Btn, {BackgroundColor3 = Colors.Accent})
        tween(Hit3Btn, {BackgroundColor3 = Colors.ElementBg})
    else
        tween(Hit3Btn, {BackgroundColor3 = Colors.Accent})
        tween(Hit2Btn, {BackgroundColor3 = Colors.ElementBg})
    end
end
updateHitcountUI() -- İlk yüklemede rengi ayarla

Hit2Btn.MouseButton1Click:Connect(function() config.hitcountValue = 2; updateHitcountUI() end)
Hit3Btn.MouseButton1Click:Connect(function() config.hitcountValue = 3; updateHitcountUI() end)

-- Checkbox Oluşturma Fonksiyonu (Başlangıç durumunu destekler)
local function createToggle(yPos, text, initialState, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -30, 0, 45)
    Frame.Position = UDim2.new(0, 15, 0, yPos)
    Frame.BackgroundColor3 = Colors.ElementBg
    Frame.Parent = MainFrame
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Colors.Text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local CheckboxBg = Instance.new("Frame")
    CheckboxBg.Size = UDim2.new(0, 25, 0, 25)
    CheckboxBg.Position = UDim2.new(1, -10, 0.5, 0)
    CheckboxBg.AnchorPoint = Vector2.new(1, 0.5)
    CheckboxBg.BackgroundColor3 = Colors.Background
    CheckboxBg.Parent = Frame
    Instance.new("UICorner", CheckboxBg).CornerRadius = UDim.new(0, 4)

    local CheckboxFill = Instance.new("Frame")
    CheckboxFill.Size = initialState and UDim2.new(1, -4, 1, -4) or UDim2.new(0, 0, 0, 0)
    CheckboxFill.Position = UDim2.new(0.5, 0, 0.5, 0)
    CheckboxFill.AnchorPoint = Vector2.new(0.5, 0.5)
    CheckboxFill.BackgroundColor3 = Colors.Accent
    CheckboxFill.Parent = CheckboxBg
    Instance.new("UICorner", CheckboxFill).CornerRadius = UDim.new(0, 4)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.Parent = Frame

    local state = initialState
    Button.MouseButton1Click:Connect(function()
        state = not state
        tween(CheckboxFill, {Size = state and UDim2.new(1, -4, 1, -4) or UDim2.new(0, 0, 0, 0)})
        callback(state)
    end)
    
    return function(newState)
        state = newState
        tween(CheckboxFill, {Size = state and UDim2.new(1, -4, 1, -4) or UDim2.new(0, 0, 0, 0)})
        callback(state)
    end
end

-- Toggles (Global config'den alınan son durumları hatırlar)
local updateSpammer = createToggle(100, "Spammer (B Keybind)", config.isSpamming, function(state) config.isSpamming = state end)
local updateAutoFarm = createToggle(155, "Auto Farm (Stand Next To NPC)", config.isAutoFarming, function(state) config.isAutoFarming = state end)
local updateSafeFarm = createToggle(210, "Safe Farm (Circle Around 6m)", config.isSafeFarming, function(state) config.isSafeFarming = state end)
local updateAutoReplay = createToggle(265, "Auto Replay Spam", config.isAutoReplay, function(state) config.isAutoReplay = state end)
local updateAutoExecute = createToggle(320, "Auto Execute (Save States)", config.isAutoExecute, function(state) config.isAutoExecute = state end)

-- Unload Hub Butonu
local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(1, -30, 0, 40)
UnloadBtn.Position = UDim2.new(0, 15, 1, -15)
UnloadBtn.AnchorPoint = Vector2.new(0, 1)
UnloadBtn.BackgroundColor3 = Colors.Red
UnloadBtn.Text = "Unload Hub"
UnloadBtn.TextColor3 = Colors.Text
UnloadBtn.Font = Enum.Font.GothamBold
UnloadBtn.TextSize = 15
UnloadBtn.Parent = MainFrame
Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 6)

UnloadBtn.MouseButton1Click:Connect(function()
    config.isSpamming = false
    config.isAutoFarming = false
    config.isSafeFarming = false
    config.isAutoReplay = false
    config.isAutoExecute = false
    for _, conn in pairs(connections) do conn:Disconnect() end
    ScreenGui:Destroy()
end)

-- Keybind Sistemi (Insert ve B)
table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    elseif input.KeyCode == Enum.KeyCode.B then
        updateSpammer(not config.isSpamming)
    end
end))

-- En Yakın NPC'yi Bulma
local function getNearestNPC()
    local nearest = nil
    local shortestDistance = math.huge
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

    local myPos = char.HumanoidRootPart.Position
    local npcsFolder = Workspace:FindFirstChild("NPCs")
    
    if npcsFolder then
        for _, npc in ipairs(npcsFolder:GetChildren()) do
            if npc:IsA("Model") and (npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")) and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                local npcPart = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")
                local dist = (npcPart.Position - myPos).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    nearest = npc
                end
            end
        end
    end
    return nearest
end

-- Sürekli Gönderim ve Farm Döngüleri
table.insert(connections, RunService.RenderStepped:Connect(function()
    -- Normal Spammer (Hitcount)
    if config.isSpamming then
        local args = { { { state = Enum.HumanoidStateType.Running, hitcount = config.hitcountValue }, "\f" } }
        pcall(function() bridgeNetEvent:FireServer(unpack(args)) end)
    end
    
    -- Auto Replay Spammer
    if config.isAutoReplay then
        local args = { { { "Play", 2, "Default", 1, 1, true, true }, " " } }
        pcall(function() bridgeNetEvent:FireServer(unpack(args)) end)
    end
    
    -- Farming Sistemleri (Safe farm önceliklidir, ikisi birden açıksa Safe Farm çalışır)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        if config.isSafeFarming then
            local target = getNearestNPC()
            if target then
                local targetPart = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
                local radius = 6 -- 6 metre(stud) mesafe
                local speed = 15 -- Dönme hızı
                local angle = tick() * speed
                
                local offsetX = math.cos(angle) * radius
                local offsetZ = math.sin(angle) * radius
                local circlePos = targetPart.Position + Vector3.new(offsetX, 0, offsetZ)
                
                local lookAtCFrame = CFrame.new(circlePos, targetPart.Position)
                char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                char:SetPrimaryPartCFrame(lookAtCFrame)
            end
        elseif config.isAutoFarming then
            local target = getNearestNPC()
            if target then
                local targetPart = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
                local targetCFrame = targetPart.CFrame
                local sidePos = (targetCFrame * CFrame.new(4, 0, 0)).Position 
                
                local lookAtCFrame = CFrame.new(sidePos, targetPart.Position)
                char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                char:SetPrimaryPartCFrame(lookAtCFrame)
            end
        end
    end
end))

-- Sunucu Işınlanma Olayında Ayarları Kaydetme ve Enjekte Etme
table.insert(connections, LocalPlayer.OnTeleport:Connect(function(State)
    if config.isAutoExecute and queue_on_teleport then
        -- Teleport sonrası çalıştırılacak kodu hazırla (Ayarları enjekte et ve scripti yükle)
        local codeToExecute = string.format([[
            getgenv().EndwareConfig = {
                isSpamming = %s,
                isAutoFarming = %s,
                isSafeFarming = %s,
                isAutoReplay = %s,
                isAutoExecute = true,
                hitcountValue = %d
            }
            task.wait(2)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ardadeska-cmyk/nbrkaconika/refs/heads/main/animafinal.lua"))()
        ]], 
        tostring(config.isSpamming), 
        tostring(config.isAutoFarming), 
        tostring(config.isSafeFarming), 
        tostring(config.isAutoReplay), 
        config.hitcountValue)
        
        queue_on_teleport(codeToExecute)
    end
end))
