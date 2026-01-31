--[[
    EndardHub - Jujutsu Zero V2 (Smart Auto-Start Edition)
    Özellikler:
    1. Boss Aura & Hover (NPC üstüne 5m sabitlenme)
    2. Auto Retry (Otomatik Tekrar)
    3. Smart Auto-Start: Sunucu değişince ayarlar korunur ve script yeniden başlar.
    
    GÜNCELLEME: Saldırı hızı devasa artırıldı (No-Yield Logic).
]]

-- --- YÜKLEYİCİ AYARLARI ---
getgenv().MyScriptURL = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/ardadeska-cmyk/nbrkaconika/refs/heads/main/rrr55.lua"))()]] 

if not game:IsLoaded() then game.Loaded:Wait() end

if _G.EndardHubLoaded then 
    -- Zaten yüklüyse devam et
end
_G.EndardHubLoaded = true

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- --- DOSYA VE AYAR YÖNETİMİ ---
local FileName = "EndardHub_Config.json"
local Config = {
    Aura = true,
    Retry = true,
    AutoExecute = true
}

-- Ayarları Kaydetme Fonksiyonu
local function SaveConfig()
    if writefile then
        local json = HttpService:JSONEncode(Config)
        writefile(FileName, json)
    end
end

-- Ayarları Yükleme Fonksiyonu
local function LoadConfig()
    if readfile and isfile and isfile(FileName) then
        pcall(function()
            local decoded = HttpService:JSONDecode(readfile(FileName))
            if decoded then
                for k, v in pairs(decoded) do
                    Config[k] = v
                end
            end
        end)
    end
end

-- Başlangıçta ayarları yükle
LoadConfig()

-- --- TEMA VE RENKLER ---
local Colors = {
    Main = Color3.fromRGB(18, 18, 18),
    Accent = Color3.fromRGB(120, 80, 255),
    Enabled = Color3.fromRGB(0, 200, 100),
    Disabled = Color3.fromRGB(200, 50, 50),
    Text = Color3.fromRGB(255, 255, 255),
    Dark = Color3.fromRGB(30, 30, 30)
}

-- --- MENÜ OLUŞTURMA FONKSİYONU ---
local function CreateMenu()
    if LocalPlayer.PlayerGui:FindFirstChild("EndardHub_V2_SmartStart") then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EndardHub_V2_SmartStart"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 280)
    mainFrame.Position = UDim2.new(0.5, -150, 0.4, -140)
    mainFrame.BackgroundColor3 = Colors.Main
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Colors.Dark
    title.Text = "  EndardHub - Jujutsu Zero V2"
    title.TextColor3 = Colors.Accent
    title.TextSize = 18
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainFrame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Colors.Text
    closeBtn.BackgroundColor3 = Colors.Disabled
    closeBtn.Parent = title
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

    local function createCheckbox(labelText, pos, configKey)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 260, 0, 45)
        container.Position = pos
        container.BackgroundColor3 = Colors.Dark
        container.Parent = mainFrame
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        label.Text = labelText
        label.TextColor3 = Colors.Text
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.SourceSansSemibold
        label.TextSize = 14
        label.Parent = container

        local box = Instance.new("TextButton")
        box.Size = UDim2.new(0, 40, 0, 22)
        box.Position = UDim2.new(1, -50, 0.5, -11)
        box.BackgroundColor3 = Config[configKey] and Colors.Enabled or Colors.Disabled
        box.Text = ""
        box.Parent = container
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 11)
        
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 14, 0, 14)
        indicator.Position = Config[configKey] and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7)
        indicator.BackgroundColor3 = Colors.Text
        indicator.Parent = box
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

        box.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            box.BackgroundColor3 = Config[configKey] and Colors.Enabled or Colors.Disabled
            indicator:TweenPosition(Config[configKey] and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7), "Out", "Quad", 0.2, true)
            SaveConfig()
        end)
    end

    createCheckbox("Boss Aura (+Hover 5m)", UDim2.new(0, 20, 0, 55), "Aura")
    createCheckbox("Auto Retry Boss", UDim2.new(0, 20, 0, 110), "Retry")
    createCheckbox("Auto Execute (QueueTP)", UDim2.new(0, 20, 0, 165), "AutoExecute")

    local running = true
    closeBtn.MouseButton1Click:Connect(function()
        running = false
        _G.EndardHubLoaded = false
        screenGui:Destroy()
    end)

    UserInputService.InputBegan:Connect(function(i, g)
        if not g and i.KeyCode == Enum.KeyCode.N then mainFrame.Visible = not mainFrame.Visible end
    end)

    -- --- ANA MOTOR DÖNGÜSÜ ---
    task.spawn(function()
        local Net = ReplicatedStorage:WaitForChild("NetworkComm")
        local Combat = Net:WaitForChild("CombatService"):WaitForChild("DamageCharacter_Method")
        local Skill = Net:WaitForChild("SkillService"):WaitForChild("StartSkilll_Method")
        local Retry = Net:WaitForChild("RaidsService"):WaitForChild("RetryRaid_Method")
        local NPCs = workspace:WaitForChild("Characters"):WaitForChild("Server"):WaitForChild("NPCs")

        while running do
            if Config.Aura then
                pcall(function()
                    local pFolder = workspace.Characters.Server.Players
                    local myChar = pFolder:GetChildren()[1]
                    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                        local targets = {}
                        local targetHRP = nil 

                        for _, v in pairs(NPCs:GetChildren()) do
                            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                table.insert(targets, v)
                                if not targetHRP then
                                    targetHRP = v.HumanoidRootPart
                                end
                            end
                        end

                        -- [[ TELEPORT MANTIĞI ]]
                        if targetHRP then
                            myChar.HumanoidRootPart.CFrame = targetHRP.CFrame * CFrame.new(0, 5, 0)
                            myChar.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
                            myChar.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
                        end
                        -- [[ SON ]]

                        if #targets > 0 then
                            -- [[ HIZLANDIRILMIŞ SALDIRI BLOĞU ]]
                            -- InvokeServer'ı task.spawn içine aldık ki server yanıtını beklemeden seri atsın.
                            task.spawn(function()
                                Combat:InvokeServer(targets, true, {
                                    ["CanParry"] = true,
                                    ["OnCharacterHit"] = function() end,
                                    ["Origin"] = myChar.PrimaryPart.CFrame,
                                    ["Parries"] = {},
                                    ["WindowID"] = myChar.Name .. "_Punch",
                                    ["LocalCharacter"] = myChar,
                                    ["SkillID"] = "Punch"
                                })
                                Skill:InvokeServer("Punch", myChar, Vector3.new(0,0,0), 1, 1)
                            end)
                        end
                    end
                end)
            end

            if Config.Retry then
                if #NPCs:GetChildren() == 0 then
                    pcall(function() Retry:InvokeServer() end)
                    task.wait(2)
                end
            end
            
            -- [[ DE VASA HIZ ]]
            -- Eski değer: task.wait(0.02) -> Yeni değer: task.wait()
            -- Bu, scriptin FPS hızında (limit olmadan) çalışmasını sağlar.
            task.wait() 
        end
    end)
end

-- --- QUEUE ON TELEPORT (SMART START) ---
local queue_on_teleport = queue_on_teleport or (syn and syn.queue_on_teleport)
if queue_on_teleport then
    LocalPlayer.OnTeleport:Connect(function(State)
        if Config.AutoExecute then
            SaveConfig()
            if getgenv().MyScriptURL and #getgenv().MyScriptURL > 10 then
                queue_on_teleport(getgenv().MyScriptURL)
            else
                print("EndardHub: Loadstring tanımlı değil, ancak ayarlar kaydedildi.")
            end
        end
    end)
end

-- --- NPC KONTROLÜ VE BAŞLATICI ---
task.spawn(function()
    local NPCs = workspace:WaitForChild("Characters"):WaitForChild("Server"):WaitForChild("NPCs")
    print("EndardHub: NPC bekleniyor...")
    
    LoadConfig()

    while true do
        local currentNPCs = NPCs:GetChildren()
        if #currentNPCs > 0 then
            print("EndardHub: NPC tespit edildi, menü başlatılıyor!")
            CreateMenu()
            break 
        end
        task.wait(1) 
    end
end)
