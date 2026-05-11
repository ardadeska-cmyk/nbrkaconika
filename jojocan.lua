local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Varsa eski Endware menüsünü temizle
if CoreGui:FindFirstChild("Endware") then
    CoreGui.Endware:Destroy()
end

local connections = {}

-- Ana GUI Oluşturma
local EndwareGui = Instance.new("ScreenGui")
EndwareGui.Name = "Endware"
EndwareGui.Parent = CoreGui
EndwareGui.ResetOnSpawn = false

-- Modern Karanlık Tema Çerçevesi
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = EndwareGui
MainFrame.Active = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 70)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Başlık (Title)
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Endware"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.Parent = MainFrame

-- Başlık Altı Çizgisi
local TitleLine = Instance.new("Frame")
TitleLine.Size = UDim2.new(1, 0, 0, 1)
TitleLine.Position = UDim2.new(0, 0, 1, 0)
TitleLine.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
TitleLine.BorderSizePixel = 0
TitleLine.Parent = TitleLabel

-- Sürükleme (Drag) Mantığı
local dragging, dragInput, dragStart, startPos
table.insert(connections, MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end))

table.insert(connections, MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end))

table.insert(connections, UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end))

-- Checkbox Ayarları
local isAutoExecEnabled = true -- Varsayılan olarak AÇIK

local AutoExecContainer = Instance.new("Frame")
AutoExecContainer.Size = UDim2.new(1, -40, 0, 30)
AutoExecContainer.Position = UDim2.new(0, 20, 0, 70)
AutoExecContainer.BackgroundTransparency = 1
AutoExecContainer.Parent = MainFrame

local CheckboxButton = Instance.new("TextButton")
CheckboxButton.Size = UDim2.new(0, 24, 0, 24)
CheckboxButton.Position = UDim2.new(0, 0, 0.5, -12)
CheckboxButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255) -- Açık olduğu için varsayılan renk mavi
CheckboxButton.Text = ""
CheckboxButton.Parent = AutoExecContainer

local CheckboxCorner = Instance.new("UICorner")
CheckboxCorner.CornerRadius = UDim.new(0, 4)
CheckboxCorner.Parent = CheckboxButton

local CheckboxStroke = Instance.new("UIStroke")
CheckboxStroke.Color = Color3.fromRGB(80, 80, 95)
CheckboxStroke.Parent = CheckboxButton

local CheckboxLabel = Instance.new("TextLabel")
CheckboxLabel.Size = UDim2.new(1, -35, 1, 0)
CheckboxLabel.Position = UDim2.new(0, 35, 0, 0)
CheckboxLabel.BackgroundTransparency = 1
CheckboxLabel.Text = "Auto Execute (Queue on Teleport)"
CheckboxLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CheckboxLabel.Font = Enum.Font.Gotham
CheckboxLabel.TextSize = 14
CheckboxLabel.TextXAlignment = Enum.TextXAlignment.Left
CheckboxLabel.Parent = AutoExecContainer

-- Ortak Execute Fonksiyonu (Scriptleri task.spawn ile eşzamanlı çalıştırır)
local function ExecuteScripts()
    -- Jojocan
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ardadeska-cmyk/nbrkaconika/refs/heads/main/jojocan.lua"))()
        end)
    end)
    
    -- HubrisScript (Bizzare Lineage)
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHubris/HubrisScript/refs/heads/main/Bizzare%20Lineage"))()
        end)
    end)
end

-- Menü ilk açıldığında Auto Execute default AÇIK geldiği için direkt enjekte et
ExecuteScripts()

-- Checkbox Toggle İşlevi
table.insert(connections, CheckboxButton.MouseButton1Click:Connect(function()
    isAutoExecEnabled = not isAutoExecEnabled
    
    local targetColor = isAutoExecEnabled and Color3.fromRGB(85, 170, 255) or Color3.fromRGB(35, 35, 45)
    TweenService:Create(CheckboxButton, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()

    -- Checkbox her açıldığında scriptleri anında tekrar enjekte et
    if isAutoExecEnabled then
        ExecuteScripts()
    end
end))

-- Teleport (Queue On Teleport) Mantığı
local queue_teleport = queue_on_teleport or syn and syn.queue_on_teleport or fluxus and fluxus.queue_on_teleport

-- Teleport sonrası çalışacak raw string (Yine task.spawn bloklarıyla)
local scriptToQueue = [[
    task.spawn(function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ardadeska-cmyk/nbrkaconika/refs/heads/main/jojocan.lua"))() end)
    end)
    task.spawn(function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHubris/HubrisScript/refs/heads/main/Bizzare%20Lineage"))() end)
    end)
]]

-- Oyuncu teleport olduğunda çalışacak bağlantı
table.insert(connections, Players.LocalPlayer.OnTeleport:Connect(function(teleportState)
    if teleportState == Enum.TeleportState.InProgress and isAutoExecEnabled then
        if queue_teleport then
            queue_teleport(scriptToQueue)
        end
    end
end))

-- Unload Butonu (Her zaman en altta)
local UnloadButton = Instance.new("TextButton")
UnloadButton.Name = "UnloadButton"
UnloadButton.Size = UDim2.new(1, -40, 0, 35)
UnloadButton.Position = UDim2.new(0, 20, 1, -55)
UnloadButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
UnloadButton.Text = "Unload Hub"
UnloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadButton.Font = Enum.Font.GothamBold
UnloadButton.TextSize = 14
UnloadButton.Parent = MainFrame

local UnloadCorner = Instance.new("UICorner")
UnloadCorner.CornerRadius = UDim.new(0, 6)
UnloadCorner.Parent = UnloadButton

-- Unload İşlevi
table.insert(connections, UnloadButton.MouseButton1Click:Connect(function()
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    EndwareGui:Destroy()
end))

-- Sağ Shift ile Menüyü Gizle/Göster
table.insert(connections, UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end))
