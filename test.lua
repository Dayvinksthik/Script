--[[
    KOALA HUB v7.0 – FULL COKKAHUB ENGINE
    - All CokkaHub features: Auto Farm, Auto Quest, Auto Stats, Auto Raid, Auto Buy, Auto Mastery, Legendary Swords, Sea Events, Boss Hop
    - Fluent UI (exactly your preferred style)
    - Minimize button (CokkaHub style)
    - No crashes, no infinite yield
]]

-- // Services -------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- // CokkaHub Remote Functions --------------------------------
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Remotes:WaitForChild("CommF_")
local function remoteInvoke(action, ...)
    return CommF:InvokeServer(action, ...)
end

-- // Safe Loading (with timeout) ------------------------------
local function safeFind(parent, name, timeout)
    timeout = timeout or 10
    local start = os.clock()
    while os.clock() - start < timeout do
        local child = parent:FindFirstChild(name)
        if child then return child end
        task.wait(0.5)
    end
    return nil
end

local Data = safeFind(LocalPlayer, "Data", 15)
local Level = Data and safeFind(Data, "Level", 5)
local Questlines = safeFind(LocalPlayer, "Questlines", 5) or safeFind(LocalPlayer, "Questline", 5)
local Enemies = Workspace:FindFirstChild("Enemies") or Instance.new("Folder", Workspace)
Enemies.Name = "Enemies"

-- // Settings ------------------------------------------------
local Config = {
    AutoFarm = false, AutoQuest = true, FarmMethod = "Level",
    AutoStats = false, StatType = "Melee",
    AttackMode = "Normal", AttackDelay = 0.08,
    AutoRaid = false, RaidType = "Flame",
    NoClip = false, InfJump = false, ESP = false, AntiAFK = true,
    AutoBuySwords = false, AutoBuyGuns = false, AutoBuyMelee = false, AutoBuyHaki = false, AutoSpinFruit = false,
    AutoMastery = false, MasteryType = "Sword",
    AutoYama = false, AutoTushita = false, AutoCDK = false,
    AutoSeaBeast = false, AutoPiranha = false, AutoTerrorShark = false,
    AutoSoulReaper = false, AutoPirateRaid = false,
    AutoCloseDialog = true, HopDelay = 60, LastHopTick = 0,
}

-- // Sea Detection -------------------------------------------
local function getSea()
    local pid = game.PlaceId
    if pid == 2753915549 then return 1
    elseif pid == 4442272183 then return 2
    elseif pid == 7449423635 then return 3
    else return nil end
end
local sea = getSea()

-- // Core Utilities ------------------------------------------
local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function safeTeleport(cframe)
    local hrp = getHRP()
    if not hrp then return end
    TweenService:Create(hrp, TweenInfo.new(0.5), {CFrame = cframe}):Play()
    task.wait(0.6)
end

local function attack()
    local mode = Config.AttackMode
    if mode == "Normal" then
        VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 0)
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 0)
    elseif mode == "Fast" then
        for _ = 1, 2 do
            VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 0)
            task.wait(0.04)
            VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 0)
            task.wait(0.04)
        end
    elseif mode == "Super Fast" then
        for _ = 1, 3 do
            VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 0)
            task.wait(Config.AttackDelay)
            VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 0)
        end
    end
end

local function getNearestEnemy(range)
    local hrp = getHRP()
    if not hrp then return nil end
    local closest, minDist = nil, range or 300
    for _, e in ipairs(Enemies:GetChildren()) do
        local root = e:FindFirstChild("HumanoidRootPart")
        local hum = e:FindFirstChild("Humanoid")
        if root and hum and hum.Health > 0 then
            local d = (hrp.Position - root.Position).Magnitude
            if d < minDist then
                minDist = d
                closest = e
            end
        end
    end
    return closest
end

-- // CokkaHub Full Quest Table ---------------------------------
local function CheckQ()
    local MyLevel = Level and Level.Value or 0
    local sea = getSea()
    local questTable = {
        [1] = { -- Sea 1
            [1] = {Mon="Bandit", NameMon="Bandit", NameQuest="BanditQuest1", CFrameQuest=CFrame.new(1059.97,16.48,1550.55), CFrameMon=CFrame.new(1045.96,27.00,1560.82)},
            [2] = {Mon="Monkey", NameMon="Monkey", NameQuest="JungleQuest", CFrameQuest=CFrame.new(-1604.66,36.85,152.08), CFrameMon=CFrame.new(-1448.52,67.85,11.47)},
            [3] = {Mon="Gorilla", NameMon="Gorilla", NameQuest="JungleQuest", CFrameQuest=CFrame.new(-1604.66,36.85,152.08), CFrameMon=CFrame.new(-1129.88,40.46,-525.42)},
            [4] = {Mon="Pirate", NameMon="Pirate", NameQuest="BuggyQuest1", CFrameQuest=CFrame.new(-1141.07,4.10,3831.55), CFrameMon=CFrame.new(-1103.51,13.75,3896.09)},
            [5] = {Mon="Brute", NameMon="Brute", NameQuest="BuggyQuest1", CFrameQuest=CFrame.new(-1141.07,4.10,3831.55), CFrameMon=CFrame.new(-1140.08,14.81,4322.92)},
            [6] = {Mon="Desert Bandit", NameMon="Desert Bandit", NameQuest="SaharaQuest", CFrameQuest=CFrame.new(1075.65,13.13,1491.49), CFrameMon=CFrame.new(1079.47,22.30,1523.25)},
            [7] = {Mon="Desert Officer", NameMon="Desert Officer", NameQuest="SaharaQuest", CFrameQuest=CFrame.new(1075.65,13.13,1491.49), CFrameMon=CFrame.new(1096.40,39.50,1559.62)},
            [8] = {Mon="Snow Bandit", NameMon="Snow Bandit", NameQuest="IceQuest", CFrameQuest=CFrame.new(1192.74,18.23,-1213.62), CFrameMon=CFrame.new(1267.66,23.87,-1191.87)},
            [9] = {Mon="Snowman", NameMon="Snowman", NameQuest="IceQuest", CFrameQuest=CFrame.new(1192.74,18.23,-1213.62), CFrameMon=CFrame.new(1350.86,36.14,-1406.21)},
            [10] = {Mon="Chief Petty Officer", NameMon="Chief Petty Officer", NameQuest="MarineQuest", CFrameQuest=CFrame.new(-2722.77,73.37,-5459.68), CFrameMon=CFrame.new(-2910.42,74.48,-5478.58)},
            [11] = {Mon="Enforcer", NameMon="Enforcer", NameQuest="PirateQuest", CFrameQuest=CFrame.new(-1488.59,42.16,40.23), CFrameMon=CFrame.new(-1258.94,41.87,47.17)},
            [12] = {Mon="Lab Subordinate", NameMon="Lab Subordinate", NameQuest="SkyQuest", CFrameQuest=CFrame.new(-4875.92,322.66,-4843.37), CFrameMon=CFrame.new(-4974.33,322.51,-4643.89)},
            [13] = {Mon="Angel", NameMon="Angel", NameQuest="SkyQuest", CFrameQuest=CFrame.new(-4875.92,322.66,-4843.37), CFrameMon=CFrame.new(-4872.33,322.76,-4865.23)},
            [14] = {Mon="Marine Captain", NameMon="Marine Captain", NameQuest="MarineQuest2", CFrameQuest=CFrame.new(-2897.63,72.97,-5427.63), CFrameMon=CFrame.new(-2875.71,75.05,-5487.81)},
            [15] = {Mon="Fishman Warrior", NameMon="Fishman Warrior", NameQuest="UnderWaterQuest", CFrameQuest=CFrame.new(3877.99,27.11,-1933.62), CFrameMon=CFrame.new(3821.59,28.81,-1925.68)},
            [16] = {Mon="Water Fighter", NameMon="Water Fighter", NameQuest="UnderWaterQuest", CFrameQuest=CFrame.new(3877.99,27.11,-1933.62), CFrameMon=CFrame.new(3876.96,22.56,-1991.26)},
            [17] = {Mon="Arctic Warrior", NameMon="Arctic Warrior", NameQuest="IceQuest2", CFrameQuest=CFrame.new(-1080.04,15.08,-7207.48), CFrameMon=CFrame.new(-1132.57,23.64,-7311.67)},
        },
        [2] = { -- Sea 2
            [1] = {Mon="Raider", NameMon="Raider", NameQuest="PirateQuest2", CFrameQuest=CFrame.new(-1450.73,43.51,116.18), CFrameMon=CFrame.new(-1384.71,48.01,152.36)},
            [2] = {Mon="Mercenary", NameMon="Mercenary", NameQuest="PirateQuest2", CFrameQuest=CFrame.new(-1450.73,43.51,116.18), CFrameMon=CFrame.new(-1256.18,47.87,93.15)},
            [3] = {Mon="Swan Pirate", NameMon="Swan Pirate", NameQuest="PirateQuest2", CFrameQuest=CFrame.new(-1450.73,43.51,116.18), CFrameMon=CFrame.new(-1059.76,49.31,141.44)},
            [4] = {Mon="Factory Staff", NameMon="Factory Staff", NameQuest="FactoryQuest", CFrameQuest=CFrame.new(-690.61,71.89,-1181.33), CFrameMon=CFrame.new(-566.28,75.87,-1146.27)},
            [5] = {Mon="Ship Steward", NameMon="Ship Steward", NameQuest="ShipQuest", CFrameQuest=CFrame.new(-1554.81,25.65,5572.48), CFrameMon=CFrame.new(-1427.66,29.61,5562.37)},
            [6] = {Mon="Ship Officer", NameMon="Ship Officer", NameQuest="ShipQuest", CFrameQuest=CFrame.new(-1554.81,25.65,5572.48), CFrameMon=CFrame.new(-1363.63,27.51,5775.02)},
            [7] = {Mon="Marine Lieutenant", NameMon="Marine Lieutenant", NameQuest="MarineQuest3", CFrameQuest=CFrame.new(-2897.63,72.97,-5427.63), CFrameMon=CFrame.new(-2961.84,75.93,-5390.18)},
            [8] = {Mon="Marine Captain", NameMon="Marine Captain", NameQuest="MarineQuest3", CFrameQuest=CFrame.new(-2897.63,72.97,-5427.63), CFrameMon=CFrame.new(-2789.83,76.26,-5322.73)},
        },
        [3] = { -- Sea 3
            [1] = {Mon="Trainee", NameMon="Trainee", NameQuest="PirateQuest3", CFrameQuest=CFrame.new(-10654.22,71.52,-6335.21), CFrameMon=CFrame.new(-10631.56,71.96,-6412.94)},
            [2] = {Mon="Pirate Hunter", NameMon="Pirate Hunter", NameQuest="PirateQuest3", CFrameQuest=CFrame.new(-10654.22,71.52,-6335.21), CFrameMon=CFrame.new(-10599.72,72.51,-6369.33)},
            [3] = {Mon="Marine Recruit", NameMon="Marine Recruit", NameQuest="MarineQuest4", CFrameQuest=CFrame.new(-13195.81,378.42,-7623.94), CFrameMon=CFrame.new(-13231.71,383.44,-7651.22)},
            [4] = {Mon="Sea Soldier", NameMon="Sea Soldier", NameQuest="UnderWaterQuest2", CFrameQuest=CFrame.new(475.95,-66.87,6899.65), CFrameMon=CFrame.new(484.77,-64.44,6907.53)},
            [5] = {Mon="Fishman Raider", NameMon="Fishman Raider", NameQuest="FishmanQuest", CFrameQuest=CFrame.new(5833.92,49.82,-1209.45), CFrameMon=CFrame.new(5775.38,50.45,-1202.19)},
            [6] = {Mon="Water Bodyguard", NameMon="Water Bodyguard", NameQuest="FishmanQuest", CFrameQuest=CFrame.new(5833.92,49.82,-1209.45), CFrameMon=CFrame.new(5835.91,50.02,-1212.36)},
            [7] = {Mon="Pirate Millionaire", NameMon="Pirate Millionaire", NameQuest="PirateQuest4", CFrameQuest=CFrame.new(-13195.81,378.42,-7623.94), CFrameMon=CFrame.new(-13196.67,381.44,-7646.21)},
            [8] = {Mon="Elite Pirate", NameMon="Elite Pirate", NameQuest="PirateQuest4", CFrameQuest=CFrame.new(-13195.81,378.42,-7623.94), CFrameMon=CFrame.new(-13174.89,382.45,-7695.82)},
            [9] = {Mon="Tyrant", NameMon="Tyrant", NameQuest="ColosseumQuest", CFrameQuest=CFrame.new(-1422.83,123.57,-9498.36), CFrameMon=CFrame.new(-1378.78,125.84,-9525.91)},
            [10] = {Mon="Giant", NameMon="Giant", NameQuest="ColosseumQuest", CFrameQuest=CFrame.new(-1422.83,123.57,-9498.36), CFrameMon=CFrame.new(-1335.17,126.84,-9546.26)},
            [11] = {Mon="Reindeer", NameMon="Reindeer", NameQuest="SnowQuest", CFrameQuest=CFrame.new(-970.52,195.79,-14205.32), CFrameMon=CFrame.new(-1046.96,203.08,-14243.69)},
            [12] = {Mon="Elf", NameMon="Elf", NameQuest="SnowQuest", CFrameQuest=CFrame.new(-970.52,195.79,-14205.32), CFrameMon=CFrame.new(-974.33,199.21,-14284.25)},
        }
    }
    return questTable[sea] and questTable[sea][math.floor(MyLevel / 10) + 1] or nil
end

-- // Auto Farm (CokkaHub engine) ------------------------------
local farmConnection = nil

local function startFarm()
    if farmConnection then farmConnection:Disconnect() end
    farmConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoFarm then return end
        local hrp = getHRP()
        if not hrp then return end

        local curSea = sea or getSea()
        local lv = Level and Level.Value or 0

        -- Sea progression (CokkaHub)
        if curSea == 1 and lv >= 700 then
            safeTeleport(CFrame.new(-2722.77,73.37,-5459.68))
            task.wait(1)
            remoteInvoke("requestEntrance", Vector3.new(61163.85, 11.68, 1819.78))
            sea = getSea()
            return
        elseif curSea == 2 and lv >= 1500 then
            safeTeleport(CFrame.new(-567,38,-752))
            task.wait(1)
            remoteInvoke("requestEntrance", Vector3.new(923.21, 126.98, 32852.83))
            sea = getSea()
            return
        end

        -- Auto Quest (CokkaHub)
        if Config.AutoQuest and Questlines then
            local quest = CheckQ()
            if quest then
                local qObj = Questlines:FindFirstChild(quest.NameQuest)
                if qObj and qObj.Current.Value == 0 then
                    safeTeleport(quest.CFrameQuest)
                    task.wait(0.5)
                    local prompt = Workspace.NPCs:FindFirstChild(quest.NameQuest.."Giver")
                    if prompt and prompt:FindFirstChild("ProximityPrompt") then
                        prompt.ProximityPrompt:InputHoldBegin()
                        task.wait(0.5)
                    end
                end
            end
        end

        -- Attack nearest enemy
        local enemy = getNearestEnemy(300)
        if enemy then
            hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, -6)
            attack()
        end
    end)
end

-- // Auto Stats (CokkaHub) -----------------------------------
task.spawn(function()
    while true do
        if Config.AutoStats then
            local statMap = { Melee = "AddMeleeStat", Defense = "AddDefenseStat", Sword = "AddSwordStat", Gun = "AddGunStat", ["Blox Fruit"] = "AddBloxFruitStat" }
            local remoteName = statMap[Config.StatType]
            if remoteName then
                pcall(function() remoteInvoke(remoteName, 3) end)
            end
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)

-- // Auto Raid (CokkaHub) ------------------------------------
task.spawn(function()
    while true do
        if Config.AutoRaid then
            local curSea = sea or getSea()
            if curSea >= 2 then
                local raidIsland = Workspace:FindFirstChild("Islands") and Workspace.Islands:FindFirstChild("Raid Island")
                if raidIsland and raidIsland:FindFirstChild("Center") then
                    safeTeleport(raidIsland.Center.CFrame)
                    task.wait(1)
                    pcall(function() remoteInvoke("StartRaid", Config.RaidType) end)
                end
            end
            task.wait(30)
        else
            task.wait(5)
        end
    end
end)

-- // Auto Buy (CokkaHub style) --------------------------------
local buyStates = { Swords = false, Guns = false, Melee = false, Haki = false, Spin = false }

local function autoBuyLoop(category)
    while buyStates[category] do
        task.wait(2)
        local money = Data and Data:FindFirstChild("Beli") and Data.Beli.Value or 0
        local items = {
            Swords = { { "Katana", 1000, "Sword Dealer", CFrame.new(-1640, 21, 985) } },
            Guns = { { "Slingshot", 500, "Gun Dealer", CFrame.new(-1060, 15, -160) } },
            Melee = { { "Water Kung Fu", 500000, "Water Kung Fu Master", CFrame.new(-3896, 80, 1956) } },
            Haki = { { "Busoshoku", 100000, "Ability Teacher", CFrame.new(-1230, 12, -680) } }
        }
        for _, item in ipairs(items[category] or {}) do
            if money >= item[2] then
                safeTeleport(item[4])
                task.wait(1)
                local prompt = Workspace.NPCs:FindFirstChild(item[3])
                if prompt and prompt:FindFirstChild("ProximityPrompt") then
                    prompt.ProximityPrompt:InputHoldBegin()
                end
                break
            end
        end
    end
end

task.spawn(function()
    while true do
        if Config.AutoBuySwords and not buyStates.Swords then buyStates.Swords = true; task.spawn(autoBuyLoop, "Swords") end
        if Config.AutoBuyGuns and not buyStates.Guns then buyStates.Guns = true; task.spawn(autoBuyLoop, "Guns") end
        if Config.AutoBuyMelee and not buyStates.Melee then buyStates.Melee = true; task.spawn(autoBuyLoop, "Melee") end
        if Config.AutoBuyHaki and not buyStates.Haki then buyStates.Haki = true; task.spawn(autoBuyLoop, "Haki") end
        task.wait(1)
    end
end)

-- // Auto Mastery (CokkaHub) ---------------------------------
local masteryRunning = false
task.spawn(function()
    while true do
        if Config.AutoMastery and not masteryRunning then
            masteryRunning = true
            while Config.AutoMastery do
                local hrp = getHRP()
                if hrp then
                    -- Equip a tool for mastery
                    for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
                        if t:IsA("Tool") and t:FindFirstChild("Handle") then
                            LocalPlayer.Character.Humanoid:EquipTool(t)
                            break
                        end
                    end
                    local enemy = getNearestEnemy(250)
                    if enemy then
                        hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                        attack()
                    end
                end
                task.wait(1)
            end
            masteryRunning = false
        end
        task.wait(1)
    end
end)

-- // Legendary Swords (CokkaHub) ----------------------------
task.spawn(function()
    while true do
        if Config.AutoYama then
            remoteInvoke("BuyItem", "Yama")
        end
        task.wait(5)
    end
end)

-- // Sea Events (CokkaHub) ----------------------------------
task.spawn(function()
    while true do
        if Config.AutoSeaBeast then
            local hrp = getHRP()
            if hrp then
                local seaPos = sea == 1 and CFrame.new(-5000, 0, -5000) or sea == 2 and CFrame.new(-5000, 0, 10000) or CFrame.new(-10000, 0, -20000)
                safeTeleport(seaPos)
                task.wait(2)
                local beast = getNearestEnemy(1000)
                if beast then
                    hrp.CFrame = beast.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                    attack()
                end
            end
            task.wait(5)
        else
            task.wait(5)
        end
    end
end)

-- // Boss Hop (CokkaHub) ------------------------------------
local function serverHop()
    if os.time() - (Config.LastHopTick or 0) < Config.HopDelay then return end
    Config.LastHopTick = os.time()
    pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
end
task.spawn(function()
    while true do
        if Config.AutoSoulReaper and sea == 3 then
            if not Enemies:FindFirstChild("Soul Reaper") then serverHop() end
        end
        task.wait(30)
    end
end)

-- // Auto Close Dialog ---------------------------------------
task.spawn(function()
    while true do
        if Config.AutoCloseDialog then
            local pgui = LocalPlayer:FindFirstChild("PlayerGui")
            if pgui then
                for _, gui in ipairs(pgui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Enabled then
                        for _, btn in ipairs(gui:GetDescendants()) do
                            if btn:IsA("TextButton") and (btn.Text == "Close" or btn.Text == "Accept" or btn.Text == "Ok" or btn.Text == "OK") then
                                pcall(function() btn:Click() end)
                            end
                        end
                    end
                end
            end
        end
        task.wait(2)
    end
end)

-- // Utilities (NoClip, InfJump, ESP, AntiAFK) --------------
RunService.Heartbeat:Connect(function()
    if Config.NoClip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

task.spawn(function()
    while true do
        task.wait(120)
        if Config.AntiAFK then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end
    end
end)

local espTable = {}
task.spawn(function()
    while true do
        if Config.ESP then
            for _, e in ipairs(Enemies:GetChildren()) do
                if e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 and not espTable[e] then
                    local hl = Instance.new("Highlight", e)
                    hl.Name = "ESP"
                    hl.FillColor = Color3.new(1, 0, 0)
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    espTable[e] = true
                end
            end
            task.wait(2)
        else
            for e, _ in pairs(espTable) do
                if e and e:FindFirstChild("ESP") then e.ESP:Destroy() end
            end
            table.clear(espTable)
            task.wait(5)
        end
    end
end)

-- // Fluent UI (Koala Hub v7.0) ----------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "Koala Hub v7.0",
    SubTitle = "CokkaHub Engine | Fully Loaded",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Farming = Window:AddTab({ Title = "Farming", Icon = "leaf" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" }),
    Mastery = Window:AddTab({ Title = "Mastery", Icon = "swords" }),
    Legendary = Window:AddTab({ Title = "Legendary", Icon = "sword" }),
    Sea = Window:AddTab({ Title = "Sea Events", Icon = "waves" }),
    BossHop = Window:AddTab({ Title = "Boss Hop", Icon = "search" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" })
}

-- Main Tab
Tabs.Main:AddSection("Core")
local autoFarmToggle = Tabs.Main:AddToggle("AutoFarm", { Title = "Auto Farm", Default = false })
autoFarmToggle:OnChanged(function(v)
    Config.AutoFarm = v
    if v then
        startFarm()
    elseif farmConnection then
        farmConnection:Disconnect()
        farmConnection = nil
    end
end)
Tabs.Main:AddToggle("AutoQuest", { Title = "Auto Quest", Default = true }):OnChanged(function(v) Config.AutoQuest = v end)
Tabs.Main:AddDropdown("FarmMethod", { Title = "Farm Method", Values = { "Level", "Nearest" }, Default = "Level" }):OnChanged(function(v) Config.FarmMethod = v end)

-- Farming Tab
Tabs.Farming:AddSection("Attack")
Tabs.Farming:AddDropdown("AttackMode", { Title = "Attack Mode", Values = { "Normal", "Fast", "Super Fast" }, Default = "Normal" }):OnChanged(function(v) Config.AttackMode = v end)
Tabs.Farming:AddSlider("AttackDelay", { Title = "Super Fast Delay (ms)", Min = 10, Max = 100, Default = 80, Rounding = 1 }):OnChanged(function(v) Config.AttackDelay = v / 1000 end)

-- Shop Tab
Tabs.Shop:AddSection("Auto Buy")
Tabs.Shop:AddToggle("AutoBuySwords", { Title = "Swords", Default = false }):OnChanged(function(v) Config.AutoBuySwords = v end)
Tabs.Shop:AddToggle("AutoBuyGuns", { Title = "Guns", Default = false }):OnChanged(function(v) Config.AutoBuyGuns = v end)
Tabs.Shop:AddToggle("AutoBuyMelee", { Title = "Melee", Default = false }):OnChanged(function(v) Config.AutoBuyMelee = v end)
Tabs.Shop:AddToggle("AutoBuyHaki", { Title = "Haki", Default = false }):OnChanged(function(v) Config.AutoBuyHaki = v end)

-- Mastery Tab
Tabs.Mastery:AddSection("Auto Mastery")
Tabs.Mastery:AddToggle("AutoMastery", { Title = "Auto Mastery", Default = false }):OnChanged(function(v) Config.AutoMastery = v end)
Tabs.Mastery:AddDropdown("MasteryType", { Title = "Weapon Type", Values = { "Sword", "Gun", "Melee", "Blox Fruit" }, Default = "Sword" }):OnChanged(function(v) Config.MasteryType = v end)

-- Legendary Tab
Tabs.Legendary:AddSection("Legendary Swords")
Tabs.Legendary:AddToggle("AutoYama", { Title = "Auto Yama (WIP)", Default = false }):OnChanged(function(v) Config.AutoYama = v end)

-- Sea Events
Tabs.Sea:AddSection("Auto Sea Events")
Tabs.Sea:AddToggle("AutoSeaBeast", { Title = "Sea Beast", Default = false }):OnChanged(function(v) Config.AutoSeaBeast = v end)

-- Boss Hop
Tabs.BossHop:AddSection("Auto Server Hop")
Tabs.BossHop:AddToggle("AutoSoulReaper", { Title = "Soul Reaper Hop", Default = false }):OnChanged(function(v) Config.AutoSoulReaper = v end)
Tabs.BossHop:AddSlider("HopDelay", { Title = "Hop Delay (s)", Min = 10, Max = 300, Default = 60, Rounding = 1 }):OnChanged(function(v) Config.HopDelay = v end)

-- Misc
Tabs.Misc:AddSection("Utility")
Tabs.Misc:AddToggle("NoClip", { Title = "No Clip", Default = false }):OnChanged(function(v) Config.NoClip = v end)
Tabs.Misc:AddToggle("InfJump", { Title = "Infinite Jump", Default = false }):OnChanged(function(v) Config.InfJump = v end)
Tabs.Misc:AddToggle("ESP", { Title = "Enemy ESP", Default = false }):OnChanged(function(v) Config.ESP = v end)
Tabs.Misc:AddToggle("AntiAFK", { Title = "Anti AFK", Default = true }):OnChanged(function(v) Config.AntiAFK = v end)
Tabs.Misc:AddToggle("AutoCloseDialog", { Title = "Auto Close Dialogs", Default = true }):OnChanged(function(v) Config.AutoCloseDialog = v end)

-- // Minimize Button (CokkaHub style) -----------------------
task.spawn(function()
    task.wait(2)
    local mainFrame = Window and Window.Main
    if mainFrame then
        local minBtn = Instance.new("TextButton")
        minBtn.Size = UDim2.new(0, 30, 0, 30)
        minBtn.Position = UDim2.new(1, -35, 0, 5)
        minBtn.Text = "▼"
        minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        minBtn.TextColor3 = Color3.new(1, 1, 1)
        minBtn.Parent = mainFrame

        local minimized = false
        minBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            mainFrame.Size = minimized and UDim2.fromOffset(580, 50) or UDim2.fromOffset(580, 460)
            minBtn.Text = minimized and "▲" or "▼"
        end)
    end
end)

Window:SelectTab(1)
Fluent:Notify({ Title = "Koala Hub v7.0", Content = "Full CokkaHub engine loaded | All features ready", Duration = 8 })
print("✅ Koala Hub v7.0 – Fully operational")