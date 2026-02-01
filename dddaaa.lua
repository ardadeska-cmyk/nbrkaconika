--[[
    EndardHub V10.5 - Final Auto-Pilot (With QueueOnTeleport)
    Link: https://raw.githubusercontent.com/ardadeska-cmyk/nbrkaconika/refs/heads/main/dddaaa.lua
]]

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local CharIDInput = Instance.new("TextBox")
local AutoFarmToggle = Instance.new("TextButton")
local MultiFarmToggle = Instance.new("TextButton")
local AutoHopToggle = Instance.new("TextButton")

local Vim = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Ayarlar
local isVisible = true
local autoFarmActive = false
local multiFarmActive = true 
local autoHopActive = false -- 15 saniye sonra TRUE olur

-- UI Kurulumu
ScreenGui.Name = "EndardHub_V10_5"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -100)
MainFrame.Size = UDim2.new(0, 260, 0, 340)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.Text = "  EndardHub V10.5"
Title.Size = UDim2.new(1, 0, 0, 45)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = Title
CloseBtn.Text = "X"
CloseBtn.Position = UDim2.new(1, -38, 0, 8)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold

CharIDInput.Name = "CharIDInput"
CharIDInput.Parent = MainFrame
CharIDInput.PlaceholderText = "Karakter ID..."
CharIDInput.Position = UDim2.new(0.05, 0, 0.16, 0)
CharIDInput.Size = UDim2.new(0.9, 0, 0, 30)
CharIDInput.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
CharIDInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CharIDInput.Font = Enum.Font.Gotham

AutoFarmToggle.Name = "AutoFarmToggle"
AutoFarmToggle.Parent = MainFrame
AutoFarmToggle.Text = "Manuel ID Farm: KAPALI"
AutoFarmToggle.Position = UDim2.new(0.05, 0, 0.30, 0)
AutoFarmToggle.Size = UDim2.new(0.9, 0, 0, 40)
AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
AutoFarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoFarmToggle.Font = Enum.Font.GothamBold

MultiFarmToggle.Name = "MultiFarmToggle"
MultiFarmToggle.Parent = MainFrame
MultiFarmToggle.Text = "TÜMÜNÜ FARM ET: AKTİF"
MultiFarmToggle.Position = UDim2.new(0.05, 0, 0.45, 0)
MultiFarmToggle.Size = UDim2.new(0.9, 0, 0, 50)
MultiFarmToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
MultiFarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MultiFarmToggle.Font = Enum.Font.GothamBold

AutoHopToggle.Name = "AutoHopToggle"
AutoHopToggle.Parent = MainFrame
AutoHopToggle.Text = "AUTO HOP: BEKLENİYOR..."
AutoHopToggle.Position = UDim2.new(0.05, 0, 0.65, 0)
AutoHopToggle.Size = UDim2.new(0.9, 0, 0, 80)
AutoHopToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
AutoHopToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoHopToggle.Font = Enum.Font.GothamBold

--- [ SİSTEMLER ] ---

-- Force Character Load (0.05ms)
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            game:GetService("ReplicatedStorage").NetworkComm.PlayerService.LoadCharacter_Signal:FireServer()
        end)
    end
end)

-- Delayed Auto-Hop Activation (15s)
task.spawn(function()
    task.wait(7)
    autoHopActive = true
    AutoHopToggle.Text = "AUTO START & HOP: AÇIK"
    AutoHopToggle.BackgroundColor3 = Color3.fromRGB(180, 100, 0)
end)

-- Start Button Handler
local function autoStartGame()
    local mainMenu = LocalPlayer.PlayerGui:FindFirstChild("MainMenu")
    if mainMenu and mainMenu.Enabled == true then
        for _, v in pairs(mainMenu:GetDescendants()) do
            if v:IsA("TextLabel") and v.Text == "Start" then
                local btn = v:FindFirstAncestorOfClass("TextButton")
                if btn then
                    pcall(function()
                        firesignal(btn.MouseButton1Click)
                        firesignal(btn.Activated)
                        local x, y = btn.AbsolutePosition.X + (btn.AbsoluteSize.X / 2), btn.AbsolutePosition.Y + (btn.AbsoluteSize.Y / 2)
                        Vim:SendMouseButtonEvent(x, y, 0, true, game, 1)
                        task.wait(0.1)
                        Vim:SendMouseButtonEvent(x, y, 0, false, game, 1)
                    end)
                end
            end
        end
    end
end

-- Advanced Server Hop with Auto-Execute
local function serverHop()
    local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local function findAndTeleport()
        local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(api)) end)
        if success and result.data then
            local servers = {}
            for _, server in pairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(servers, server.id)
                end
            end
            if #servers > 0 then
                local target = servers[math.random(1, #servers)]
                
                -- [ AUTO-EXECUTE AYARI ]
                local queue = (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or queue_on_teleport
                if queue then
                    queue([[loadstring(game:HttpGet("https://raw.githubusercontent.com/ardadeska-cmyk/nbrkaconika/refs/heads/main/dddaaa.lua"))()]])
                end

                local connection
                connection = TeleportService.TeleportInitFailed:Connect(function()
                    connection:Disconnect()
                    task.wait(2)
                    findAndTeleport()
                end)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, target)
            else
                task.wait(3)
                findAndTeleport()
            end
        end
    end
    findAndTeleport()
end

local function getPlayersFolder()
    local path = workspace:FindFirstChild("Characters")
    if path then path = path:FindFirstChild("Server") end
    if path then path = path:FindFirstChild("Players") end
    return path
end

local function runFarm(mode)
    while true do
        if mode == "manual" and not autoFarmActive then break end
        if mode == "multi" and not multiFarmActive then break end

        local folder = getPlayersFolder()
        if not folder then task.wait(1) continue end

        local crates = workspace.Map.Crates:GetChildren()
        local activeCrates = {}

        for _, crate in pairs(crates) do
            if crate:FindFirstChildWhichIsA("ProximityPrompt", true) and crate.Parent == workspace.Map.Crates then
                table.insert(activeCrates, crate)
            end
        end

        if #activeCrates > 0 then
            for _, crate in pairs(activeCrates) do
                if (mode == "manual" and not autoFarmActive) or (mode == "multi" and not multiFarmActive) then break end
                
                if mode == "manual" then
                    local target = folder:FindFirstChild(CharIDInput.Text)
                    if target and target:FindFirstChild("HumanoidRootPart") then
                        target.HumanoidRootPart.CFrame = crate.CFrame
                    end
                else
                    for _, char in pairs(folder:GetChildren()) do
                        if char:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.CFrame = crate.CFrame
                        end
                    end
                end

                local startAt = tick()
                while (tick() - startAt < 2.5) and crate.Parent == workspace.Map.Crates do
                    Vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    pcall(function()
                        game:GetService("ReplicatedStorage").NetworkComm.MapService.OpenExplorationCrate_Method:InvokeServer(tostring(crate.Name))
                    end)
                    task.wait(0.05)
                    Vim:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                end
            end
        else
            -- Sadece 15 saniye geçtiyse ve kura kalmadıysa hop yap
            if autoHopActive then
                serverHop()
                break
            end
        end
        task.wait(0.1)
    end
end

--- [ BAŞLATICILAR ] ---
task.spawn(function()
    repeat task.wait() until game:IsLoaded()
    task.wait(2) 
    autoStartGame()
    if multiFarmActive then
        runFarm("multi")
    end
end)

--- [ UI CONTROLS ] ---
AutoHopToggle.MouseButton1Click:Connect(function()
    autoHopActive = not autoHopActive
    AutoHopToggle.Text = autoHopActive and "AUTO START & HOP: AÇIK" or "AUTO HOP: KAPALI"
    AutoHopToggle.BackgroundColor3 = autoHopActive and Color3.fromRGB(180, 100, 0) or Color3.fromRGB(40, 40, 45)
end)

AutoFarmToggle.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    if autoFarmActive then
        multiFarmActive = false
        AutoFarmToggle.Text = "MANUEL: AKTİF"
        AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        task.spawn(function() runFarm("manual") end)
    else
        AutoFarmToggle.Text = "Manuel ID Farm: KAPALI"
        AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    end
end)

MultiFarmToggle.MouseButton1Click:Connect(function()
    multiFarmActive = not multiFarmActive
    if multiFarmActive then
        autoFarmActive = false
        MultiFarmToggle.Text = "TÜMÜNÜ FARM ET: AKTİF"
        MultiFarmToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        task.spawn(function() runFarm("multi") end)
    else
        MultiFarmToggle.Text = "TÜMÜNÜ FARM ET: KAPALI"
        MultiFarmToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    end
end)

UserInputService.InputBegan:Connect(function(input, chat)
    if not chat and input.KeyCode == Enum.KeyCode.N then
        isVisible = not isVisible
        MainFrame.Visible = isVisible
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    autoFarmActive = false
    multiFarmActive = false
    autoHopActive = false
    ScreenGui:Destroy()
end)
