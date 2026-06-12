-- Blox Fruits Ultimate – Fluent UI Only | Fully Fixed | Lightweight & Optimized
-- No basic UI fallback. All features: Auto Farm, Stats, Raids, Buys, Mastery, Legendaries, Sea Events, Boss Hop, Goals, ESP, NoClip, Inf Jump, AntiAFK.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- // Robust Questlines loading (retry until found, no timeout)
local Data, Level, Questlines
local function waitForChildOrRetry(parent, name)
    while not parent:FindFirstChild(name) do task.wait(1) end
    return parent[name]
end

Data = waitForChildOrRetry(LocalPlayer, "Data")
Level = waitForChildOrRetry(Data, "Level")
Questlines = waitForChildOrRetry(LocalPlayer, "Questlines")

local Mouse = LocalPlayer:GetMouse()
local Enemies = Workspace:WaitForChild("Enemies")

-- // Settings
local settings = {
    AutoFarm = false, FarmMethod = "Level", AutoQuest = true,
    AutoStats = false, StatType = "Melee",
    AttackMode = "Normal", SuperFastDelay = 0.01,
    AutoRaid = false, RaidType = "Flame",
    NoClip = false, InfJump = false, ESP = false, AntiAFK = true,
    AutoBuySwords = false, AutoBuyGuns = false, AutoBuyMelee = false, AutoBuyHaki = false, AutoSpinFruit = false,
    AutoMastery = false, MasteryType = "Sword",
    AutoYama = false, AutoTushita = false, AutoCDK = false,
    AutoSeaBeast = false, AutoPiranha = false, AutoTerrorShark = false,
    AutoSoulReaper = false, AutoPirateRaid = false,
    AutoCloseDialog = true, HopDelay = 60, LastHopTick = 0,
    GoalActive = false, CurrentGoal = "", GoalStep = 0, GoalTarget = 0, GoalItem = ""
}

-- // Sea detection
local function getSea()
    local pid = game.PlaceId
    if pid == 2753915549 then return 1
    elseif pid == 4442272183 then return 2
    elseif pid == 7449423635 then return 3 end
    return nil
end
local sea = getSea()

-- // Helpers
local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function findPrompt(name)
    for _, n in ipairs(Workspace.NPCs:GetChildren()) do
        if n.Name == name then
            local p = n:FindFirstChild("ProximityPrompt")
            if p then return p end
        end
    end
    for _, o in ipairs(Workspace:GetDescendants()) do
        if o:IsA("ProximityPrompt") and o.Parent and o.Parent.Name == name then return o end
    end
end

local function safeTeleport(cf)
    local hrp = getHRP()
    if not hrp then return false end
    local tw = TweenService:Create(hrp, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {CFrame = cf})
    tw:Play()
    task.wait(0.6)
    return true
end

local function equipBestTool()
    local bp = LocalPlayer.Backpack
    local char = LocalPlayer.Character
    if not bp or not char then return end
    for _, t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") and t:FindFirstChild("Handle") then
            char.Humanoid:EquipTool(t)
            return
        end
    end
end

local function equipToolByName(name)
    for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.Name == name and t:FindFirstChild("Handle") then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum:EquipTool(t) return true end
        end
    end
    return false
end

local function hasItem(name)
    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do if v.Name == name then return true end end
    if LocalPlayer.Character then
        for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("Tool") and v.Name == name then return true end
        end
    end
    return false
end

-- // Attack functions (mouse‑only)
local attackFuncs = {
    Normal = function()
        VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 0)
        task.wait(0.15)
        VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 0)
    end,
    Fast = function()
        for _ = 1, 2 do
            VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 0)
            task.wait(0.04)
        end
    end,
    ["Super Fast"] = function()
        for _ = 1, 5 do
            VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 0)
            task.wait(settings.SuperFastDelay)
        end
    end,
    Speed = function()
        VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 0)
        task.wait(0.01)
    end
}

local function getNearestEnemy(range, pattern)
    local hrp = getHRP()
    if not hrp then return nil end
    local closest, minDist = nil, range or math.huge
    for _, e in ipairs(Enemies:GetChildren()) do
        local ehrp = e:FindFirstChild("HumanoidRootPart")
        local hum = e:FindFirstChild("Humanoid")
        if ehrp and hum and hum.Health > 0 then
            if not pattern or e.Name:find(pattern) then
                local d = (hrp.Position - ehrp.Position).Magnitude
                if d < minDist then minDist = d; closest = e end
            end
        end
    end
    return closest
end

-- // Quests (full 0-2800)
local quests = {
    [1] = {
        {0,"Bandit [Lv. 5]","BanditQuest1",CFrame.new(1059.97,16.48,1550.55)},
        {10,"Monkey [Lv. 14]","JungleQuest",CFrame.new(-1604.66,36.85,152.08)},
        {20,"Gorilla [Lv. 20]","JungleQuest",CFrame.new(-1604.66,36.85,152.08)},
        {30,"Pirate [Lv. 35]","BuggyQuest",CFrame.new(-1151.14,16.28,-711.78)},
        {40,"Brute [Lv. 45]","BuggyQuest",CFrame.new(-1151.14,16.28,-711.78)},
        {50,"Desert Bandit [Lv. 60]","SaharaQuest",CFrame.new(1075.65,13.13,1491.49)},
        {60,"Desert Officer [Lv. 70]","SaharaQuest",CFrame.new(1075.65,13.13,1491.49)},
        {70,"Snow Bandit [Lv. 90]","IceQuest",CFrame.new(1192.74,18.23,-1213.62)},
        {80,"Snowman [Lv. 100]","IceQuest",CFrame.new(1192.74,18.23,-1213.62)},
        {90,"Chief Petty Officer [Lv. 120]","MarineQuest",CFrame.new(-2722.77,73.37,-5459.68)},
        {110,"Enforcer [Lv. 150]","PirateQuest",CFrame.new(-1488.59,42.16,40.23)},
        {150,"Lab Subordinate [Lv. 180]","SkyQuest",CFrame.new(-4875.92,322.66,-4843.37)},
        {200,"Angel [Lv. 300]","SkyQuest",CFrame.new(-4875.92,322.66,-4843.37)},
        {300,"Marine Captain [Lv. 350]","MarineQuest2",CFrame.new(-2897.63,72.97,-5427.63)},
        {400,"Fishman Warrior [Lv. 425]","UnderWaterQuest",CFrame.new(3877.99,27.11,-1933.62)},
        {500,"Water Fighter [Lv. 550]","UnderWaterQuest",CFrame.new(3877.99,27.11,-1933.62)},
        {600,"Arctic Warrior [Lv. 700]","IceQuest2",CFrame.new(-1080.04,15.08,-7207.48)},
    },
    [2] = {
        {700,"Raider [Lv. 700]","PirateQuest2",CFrame.new(-1450.73,43.51,116.18)},
        {800,"Mercenary [Lv. 800]","PirateQuest2",CFrame.new(-1450.73,43.51,116.18)},
        {900,"Swan Pirate [Lv. 900]","PirateQuest2",CFrame.new(-1450.73,43.51,116.18)},
        {1000,"Factory Staff [Lv. 1000]","FactoryQuest",CFrame.new(-690.61,71.89,-1181.33)},
        {1100,"Ship Steward [Lv. 1150]","ShipQuest",CFrame.new(-1554.81,25.65,5572.48)},
        {1200,"Ship Officer [Lv. 1250]","ShipQuest",CFrame.new(-1554.81,25.65,5572.48)},
        {1300,"Marine Lieutenant [Lv. 1400]","MarineQuest3",CFrame.new(-2897.63,72.97,-5427.63)},
        {1400,"Marine Captain [Lv. 1500]","MarineQuest3",CFrame.new(-2897.63,72.97,-5427.63)},
    },
    [3] = {
        {1500,"Trainee [Lv. 1500]","PirateQuest3",CFrame.new(-10654.22,71.52,-6335.21)},
        {1600,"Pirate Hunter [Lv. 1600]","PirateQuest3",CFrame.new(-10654.22,71.52,-6335.21)},
        {1700,"Marine Recruit [Lv. 1700]","MarineQuest4",CFrame.new(-13195.81,378.42,-7623.94)},
        {1800,"Sea Soldier [Lv. 1850]","UnderWaterQuest2",CFrame.new(475.95,-66.87,6899.65)},
        {1900,"Fishman Raider [Lv. 2000]","FishmanQuest",CFrame.new(5833.92,49.82,-1209.45)},
        {2000,"Water Bodyguard [Lv. 2150]","FishmanQuest",CFrame.new(5833.92,49.82,-1209.45)},
        {2100,"Pirate Millionaire [Lv. 2250]","PirateQuest4",CFrame.new(-13195.81,378.42,-7623.94)},
        {2200,"Elite Pirate [Lv. 2400]","PirateQuest4",CFrame.new(-13195.81,378.42,-7623.94)},
        {2300,"Tyrant [Lv. 2550]","ColosseumQuest",CFrame.new(-1422.83,123.57,-9498.36)},
        {2500,"Giant [Lv. 2750]","ColosseumQuest",CFrame.new(-1422.83,123.57,-9498.36)},
        {2600,"Reindeer [Lv. 2775]","SnowQuest",CFrame.new(-970.52,195.79,-14205.32)},
        {2700,"Elf [Lv. 2800]","SnowQuest",CFrame.new(-970.52,195.79,-14205.32)},
    }
}

-- // Auto Farm (non-blocking)
local farmRunning = false
local function autoFarmLoop()
    if farmRunning then return end
    farmRunning = true
    while settings.AutoFarm do
        local hrp = getHRP()
        if not hrp then task.wait(0.2) continue end
        local curSea = sea or getSea()
        local lv = Level.Value

        -- Sea progression
        if curSea == 1 and lv >= 700 then
            safeTeleport(CFrame.new(-2722.77,73.37,-5459.68))
            task.wait(0.5)
            local p = findPrompt("Royale Sailor")
            if p then pcall(p.InputHoldBegin, p) end
            task.wait(5)
            sea = getSea()
            continue
        elseif curSea == 2 and lv >= 1500 then
            safeTeleport(CFrame.new(-567,38,-752))
            task.wait(0.5)
            local p = findPrompt("Luxury Sailor")
            if p then pcall(p.InputHoldBegin, p) end
            task.wait(5)
            sea = getSea()
            continue
        end

        local method = settings.FarmMethod
        if method == "Level" then
            local list = quests[curSea]
            if not list then task.wait(1) continue end
            local target = nil
            for i = #list, 1, -1 do if lv >= list[i][1] then target = list[i] break end end
            if not target then task.wait(1) continue end
            local questName = target[3]
            if Questlines and settings.AutoQuest then
                local qObj = Questlines:FindFirstChild(questName)
                if qObj and qObj.Current.Value == 0 then
                    safeTeleport(target[4])
                    task.wait(0.3)
                    for _, npc in ipairs(Workspace.NPCs:GetChildren()) do
                        if npc:FindFirstChild("Questline") and npc.Questline.Value == questName then
                            local prompt = npc:FindFirstChild("ProximityPrompt")
                            if prompt then pcall(prompt.InputHoldBegin, prompt) end
                            break
                        end
                    end
                    task.wait(0.3)
                end
            end
            local enemy = getNearestEnemy(250)
            if enemy then
                hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                equipBestTool()
                attackFuncs[settings.AttackMode]()
            end
        elseif method == "Nearest" then
            local enemy = getNearestEnemy(500)
            if enemy then
                hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                equipBestTool()
                attackFuncs[settings.AttackMode]()
            else task.wait(0.5) end
        elseif method == "Auto Bone" and curSea == 3 then
            local enemy = getNearestEnemy(300, "Skeleton") or getNearestEnemy(300, "Bone")
            if enemy then
                hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                equipBestTool()
                attackFuncs[settings.AttackMode]()
            else task.wait(0.5) end
        end
        task.wait()
    end
    farmRunning = false
end

-- // Auto Stats
task.spawn(function()
    while true do
        if settings.AutoStats then
            local map = {Melee="AddMeleeStat", Defense="AddDefenseStat", Sword="AddSwordStat", Gun="AddGunStat", ["Blox Fruit"]="AddBloxFruitStat"}
            local remote = map[settings.StatType]
            if remote then pcall(function() ReplicatedStorage.Remotes[remote]:FireServer(3) end) end
            task.wait(0.5)
        else task.wait(1) end
    end
end)

-- // Auto Raid
task.spawn(function()
    while true do
        if settings.AutoRaid then
            local curSea = sea or getSea()
            if curSea >= 2 and getHRP() then
                local ri = Workspace.Islands:FindFirstChild("Raid Island")
                if ri and ri:FindFirstChild("Center") then
                    safeTeleport(ri.Center.CFrame)
                    task.wait(1)
                    pcall(function() ReplicatedStorage.Remotes.Raid.StartRaid:InvokeServer(settings.RaidType) end)
                end
            end
            task.wait(30)
        else task.wait(5) end
    end
end)

-- // Auto Buy (data)
local shopData = {
    Swords = {{"Katana",1000,"Sword Dealer",CFrame.new(-1640,21,985)}, {"Cutlass",5000,"Sword Dealer",CFrame.new(-1640,21,985)}, {"Dual Katana",12000,"Sword Dealer",CFrame.new(-1640,21,985)}, {"Iron Mace",25000,"Sword Dealer",CFrame.new(-1640,21,985)}, {"Shark Saw",50000,"Sword Dealer",CFrame.new(-1640,21,985)}, {"Triple Katana",150000,"Sword Dealer",CFrame.new(-1640,21,985)}, {"Pipe",250000,"Sword Dealer",CFrame.new(-1640,21,985)}},
    Guns = {{"Slingshot",500,"Gun Dealer",CFrame.new(-1060,15,-160)}, {"Musket",5000,"Gun Dealer",CFrame.new(-1060,15,-160)}, {"Flintlock",15000,"Gun Dealer",CFrame.new(-1060,15,-160)}, {"Refined Flintlock",45000,"Gun Dealer",CFrame.new(-1060,15,-160)}, {"Cannon",150000,"Gun Dealer",CFrame.new(-1060,15,-160)}},
    Melee = {{"Water Kung Fu",500000,"Water Kung Fu Master",CFrame.new(-3896,80,1956)}, {"Electric Claw",3000000,"Electric Claw Master",CFrame.new(-2435,6,1606)}, {"Dragon Breath",1000000,"Dragon Breath Master",CFrame.new(-2841,18,2476)}, {"Superhuman",7500000,"Superhuman Teacher",CFrame.new(-1689,26,1205)}},
    Haki = {{"Busoshoku",100000,"Ability Teacher",CFrame.new(-1230,12,-680)}, {"Kenbunshoku",750000,"Ability Teacher",CFrame.new(-1230,12,-680)}}
}
local buyStates = {Swords=false, Guns=false, Melee=false, Haki=false, Spin=false}

local function autoBuyLoop(cat)
    while buyStates[cat] do
        task.wait(2)
        local hrp = getHRP()
        if not hrp then continue end
        local money = Data:FindFirstChild("Beli") and Data.Beli.Value or 0
        for _, item in ipairs(shopData[cat]) do
            if not hasItem(item[1]) and money >= item[2] then
                safeTeleport(item[4])
                task.wait(1)
                local p = findPrompt(item[3])
                if p then pcall(p.InputHoldBegin, p) task.wait(1.5) end
                break
            end
        end
    end
end

local function spinLoop()
    while buyStates.Spin do
        task.wait(2)
        local money = Data:FindFirstChild("Beli") and Data.Beli.Value or 0
        if money >= 25000 then
            local dealer = Workspace:FindFirstChild("Blox Fruit Dealer") or Workspace:FindFirstChild("Blox Fruit Dealer Cousin")
            if dealer then
                local primary = dealer.PrimaryPart or dealer:FindFirstChild("HumanoidRootPart")
                if primary then
                    safeTeleport(primary.CFrame)
                    task.wait(1)
                    local prompt = dealer:FindFirstChild("ProximityPrompt")
                    if prompt then pcall(prompt.InputHoldBegin, prompt) end
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        if settings.AutoBuySwords and not buyStates.Swords then buyStates.Swords = true; task.spawn(autoBuyLoop, "Swords") end
        if settings.AutoBuyGuns and not buyStates.Guns then buyStates.Guns = true; task.spawn(autoBuyLoop, "Guns") end
        if settings.AutoBuyMelee and not buyStates.Melee then buyStates.Melee = true; task.spawn(autoBuyLoop, "Melee") end
        if settings.AutoBuyHaki and not buyStates.Haki then buyStates.Haki = true; task.spawn(autoBuyLoop, "Haki") end
        if settings.AutoSpinFruit and not buyStates.Spin then buyStates.Spin = true; task.spawn(spinLoop) end
        task.wait(1)
    end
end)

-- // Auto Mastery
local masteryRunning = false
task.spawn(function()
    while true do
        if settings.AutoMastery and not masteryRunning then
            masteryRunning = true
            while settings.AutoMastery do
                local hrp = getHRP()
                if not hrp then task.wait(1) continue end
                local mt = settings.MasteryType
                local tool = nil
                for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t:FindFirstChild("Handle") then
                        if (mt=="Sword" and t:FindFirstChild("Sword")) or (mt=="Gun" and t:FindFirstChild("Gun")) or (mt=="Melee" and t:FindFirstChild("Melee")) or (mt=="Blox Fruit" and t:FindFirstChild("BloxFruit")) then
                            tool = t; break
                        end
                    end
                end
                if tool then LocalPlayer.Character.Humanoid:EquipTool(tool) end
                local enemy = getNearestEnemy(250)
                if enemy then
                    hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                    attackFuncs[settings.AttackMode]()
                end
                task.wait(1)
            end
            masteryRunning = false
        end
        task.wait(1)
    end
end)

-- // Legendary swords (Yama, Tushita, CDK)
local yamaR, tushitaR, cdkR = false, false, false
task.spawn(function()
    while true do
        if settings.AutoYama and not yamaR and not hasItem("Yama") then
            yamaR = true
            while settings.AutoYama and not hasItem("Yama") do
                local hrp = getHRP()
                if not hrp then task.wait(1) continue end
                if not hasItem("Hell's Gate Key") then
                    local cc = Enemies:FindFirstChild("Cursed Captain")
                    if cc and cc:FindFirstChild("HumanoidRootPart") then
                        hrp.CFrame = cc.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                        equipBestTool()
                        attackFuncs[settings.AttackMode]()
                    else safeTeleport(CFrame.new(-19071,107,7875)) end
                else
                    if sea == 3 then
                        safeTeleport(CFrame.new(-1422.83,123.57,-9498.36))
                        task.wait(2)
                        local door = Workspace:FindFirstChild("Hell's Gate") or Workspace:FindFirstChild("Door")
                        if door and door:FindFirstChild("ProximityPrompt") then
                            pcall(door.ProximityPrompt.InputHoldBegin, door.ProximityPrompt)
                            task.wait(2)
                        end
                        local yama = Workspace:FindFirstChild("Yama") or Workspace:FindFirstChild("Yama Sword")
                        if yama then
                            local primary = yama.PrimaryPart or yama:FindFirstChild("HumanoidRootPart")
                            if primary then
                                safeTeleport(primary.CFrame)
                                task.wait(1)
                                local prompt = yama:FindFirstChild("ProximityPrompt")
                                if prompt then pcall(prompt.InputHoldBegin, prompt) end
                                if hasItem("Yama") then equipToolByName("Yama") end
                                break
                            end
                        end
                    end
                end
                task.wait(1)
            end
            yamaR = false
        end
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        if settings.AutoTushita and not tushitaR and not hasItem("Tushita") and sea == 3 then
            tushitaR = true
            while settings.AutoTushita and not hasItem("Tushita") do
                local hrp = getHRP()
                if not hrp then task.wait(1) continue end
                for _, cf in ipairs({CFrame.new(5500,50,-1000), CFrame.new(5600,30,-800), CFrame.new(5400,20,-1200)}) do safeTeleport(cf) task.wait(1.5) end
                local dk = Enemies:FindFirstChild("Dough King") or Enemies:FindFirstChild("Dough Prince")
                if dk and dk:FindFirstChild("HumanoidRootPart") then
                    hrp.CFrame = dk.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                    equipBestTool()
                    attackFuncs[settings.AttackMode]()
                else
                    local plate = Workspace:FindFirstChild("Scroll Pedestal") or Workspace:FindFirstChild("Summon Pedestal")
                    if plate then
                        local primary = plate.PrimaryPart or plate:FindFirstChild("HumanoidRootPart")
                        if primary then
                            safeTeleport(primary.CFrame)
                            task.wait(1)
                            local prompt = plate:FindFirstChild("ProximityPrompt")
                            if prompt then pcall(prompt.InputHoldBegin, prompt) end
                        end
                    end
                end
                local tushita = Workspace:FindFirstChild("Tushita")
                if tushita then
                    local primary = tushita.PrimaryPart or tushita:FindFirstChild("HumanoidRootPart")
                    if primary then
                        safeTeleport(primary.CFrame)
                        task.wait(1)
                        local prompt = tushita:FindFirstChild("ProximityPrompt")
                        if prompt then pcall(prompt.InputHoldBegin, prompt) end
                        if hasItem("Tushita") then equipToolByName("Tushita") end
                        break
                    end
                end
                task.wait(2)
            end
            tushitaR = false
        end
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        if settings.AutoCDK and not cdkR then
            cdkR = true
            while settings.AutoCDK do
                if not hasItem("Yama") then settings.AutoYama = true; task.wait(5)
                elseif not hasItem("Tushita") then settings.AutoTushita = true; task.wait(5)
                else
                    local hrp = getHRP()
                    if hrp then
                        equipToolByName("Yama")
                        local bs = Workspace:FindFirstChild("Blacksmith") or Workspace:FindFirstChild("Weapon Blacksmith")
                        if bs then
                            local primary = bs.PrimaryPart or bs:FindFirstChild("HumanoidRootPart")
                            if primary then
                                safeTeleport(primary.CFrame)
                                task.wait(1)
                                local prompt = bs:FindFirstChild("ProximityPrompt")
                                if prompt then pcall(prompt.InputHoldBegin, prompt) end
                                task.wait(2)
                                settings.AutoCDK = false
                            end
                        end
                    end
                end
                task.wait(2)
            end
            cdkR = false
        end
        task.wait(2)
    end
end)

-- // Sea Events
local seaEventNames = {SeaBeast="Sea Beast", Piranha="Piranha", TerrorShark="Terror Shark"}
task.spawn(function()
    while true do
        if settings.AutoSeaBeast or settings.AutoPiranha or settings.AutoTerrorShark then
            local hrp = getHRP()
            if not hrp then task.wait(1) continue end
            local curSea = sea or getSea()
            local seaPos = curSea==1 and CFrame.new(-5000,0,-5000) or curSea==2 and CFrame.new(-5000,0,10000) or CFrame.new(-10000,0,-20000)
            safeTeleport(seaPos)
            task.wait(2)
            for ev, ename in pairs(seaEventNames) do
                if settings["Auto"..ev] then
                    local enemy = getNearestEnemy(1000, ename)
                    if enemy then
                        hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0,0,5)
                        equipBestTool()
                        attackFuncs[settings.AttackMode]()
                    end
                end
            end
            task.wait(3)
        else task.wait(5) end
    end
end)

-- // Boss Hop
local function bossExists(name)
    for _, e in ipairs(Enemies:GetChildren()) do
        if e.Name == name and e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 then return true end
    end
    return Workspace:FindFirstChild(name) ~= nil
end
local function serverHop()
    if os.time() - (settings.LastHopTick or 0) < settings.HopDelay then return end
    settings.LastHopTick = os.time()
    pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
end
task.spawn(function()
    while true do
        if settings.AutoSoulReaper and sea == 3 and not bossExists("Soul Reaper") then serverHop() end
        if settings.AutoPirateRaid and (sea or 0) >= 2 and not bossExists("Pirate Raid") and not bossExists("Pirate Raid Boss") then serverHop() end
        task.wait(30)
    end
end)

-- // Auto Close Dialog
task.spawn(function()
    while true do
        if settings.AutoCloseDialog then
            local pgui = LocalPlayer:FindFirstChild("PlayerGui")
            if pgui then
                for _, gui in ipairs(pgui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Enabled then
                        for _, btn in ipairs(gui:GetDescendants()) do
                            if btn:IsA("TextButton") and (btn.Text=="Close" or btn.Text=="Accept" or btn.Text=="Ok" or btn.Text=="OK") then
                                pcall(btn.Invoke, btn)
                                break
                            end
                        end
                    end
                end
            end
        end
        task.wait(2)
    end
end)

-- // Utilities (NoClip, InfJump, ESP, AntiAFK)
RunService.Heartbeat:Connect(function()
    if settings.NoClip and LocalPlayer.Character then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if settings.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

task.spawn(function()
    while true do
        task.wait(120)
        if settings.AntiAFK then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end
    end
end)

local espTable = {}
task.spawn(function()
    while true do
        if settings.ESP then
            for _, e in ipairs(Enemies:GetChildren()) do
                if e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 and not espTable[e] then
                    local hl = Instance.new("Highlight", e)
                    hl.Name = "ESP"; hl.FillColor = Color3.new(1,0,0); hl.OutlineColor = Color3.new(1,1,1)
                    espTable[e] = true
                end
            end
            task.wait(2)
        else
            for e, _ in pairs(espTable) do if e and e:FindFirstChild("ESP") then e.ESP:Destroy() end end
            table.clear(espTable)
            task.wait(5)
        end
    end
end)

-- // Goal System (fully functional)
local goalDefinitions = {
    ["Reach Max Level"] = {{task="Leveling to 2800", setup=function() settings.AutoFarm=true; settings.FarmMethod="Level"; settings.AutoQuest=true end, condition=function() return Level.Value>=2800 end, teardown=function() settings.AutoFarm=false end}},
    ["Obtain Specific Sword"] = {{task="Purchasing sword", setup=function() settings.AutoBuySwords=true; buyStates.Swords=true; task.spawn(autoBuyLoop,"Swords") end, condition=function() return hasItem(settings.GoalItem) end, teardown=function() settings.AutoBuySwords=false; buyStates.Swords=false end}},
    ["Obtain Specific Fighting Style"] = {{task="Purchasing fighting style", setup=function() settings.AutoBuyMelee=true; buyStates.Melee=true; task.spawn(autoBuyLoop,"Melee") end, condition=function() return hasItem(settings.GoalItem) end, teardown=function() settings.AutoBuyMelee=false; buyStates.Melee=false end}},
    ["Farm Beli"] = {{task="Farming Beli", setup=function() settings.AutoFarm=true; settings.FarmMethod="Nearest" end, condition=function() return Data.Beli.Value>=settings.GoalTarget end, teardown=function() settings.AutoFarm=false end}},
    ["Farm Bones"] = {{task="Farming Bones", setup=function() settings.AutoFarm=true; settings.FarmMethod="Auto Bone" end, condition=function() return Data:FindFirstChild("Bones") and Data.Bones.Value>=settings.GoalTarget end, teardown=function() settings.AutoFarm=false end}},
    ["Farm Fragments"] = {{task="Farming Fragments", setup=function() settings.AutoRaid=true end, condition=function() return Data:FindFirstChild("Fragments") and Data.Fragments.Value>=settings.GoalTarget end, teardown=function() settings.AutoRaid=false end}},
    ["Max Selected Mastery"] = {{task="Mastering", setup=function() settings.AutoMastery=true end, condition=function() return false end, teardown=function() settings.AutoMastery=false end}},
    ["Unlock CDK"] = {
        {task="Obtaining Yama", setup=function() settings.AutoYama=true end, condition=function() return hasItem("Yama") end, teardown=function() settings.AutoYama=false end},
        {task="Obtaining Tushita", setup=function() settings.AutoTushita=true end, condition=function() return hasItem("Tushita") end, teardown=function() settings.AutoTushita=false end},
        {task="Crafting CDK", setup=function() settings.AutoCDK=true end, condition=function() return hasItem("Cursed Dual Katana") end, teardown=function() settings.AutoCDK=false end}
    }
}
local goalStatusLabel = nil
local function stopGoal()
    if settings.GoalActive then
        local steps = goalDefinitions[settings.CurrentGoal]
        if steps and steps[settings.GoalStep] then steps[settings.GoalStep].teardown() end
        settings.GoalActive = false; settings.CurrentGoal = ""; settings.GoalStep = 0
        if goalStatusLabel then goalStatusLabel:SetText("No goal active") end
    end
end
local function startGoal(goal)
    stopGoal()
    settings.CurrentGoal = goal; settings.GoalStep = 1; settings.GoalActive = true
    local steps = goalDefinitions[goal]
    if steps and steps[1] then
        steps[1].setup()
        if goalStatusLabel then goalStatusLabel:SetText("Goal: "..goal.." | Task: "..steps[1].task) end
    end
end
local function goalTick()
    if not settings.GoalActive then return end
    local steps = goalDefinitions[settings.CurrentGoal]
    if not steps then stopGoal() return end
    local step = steps[settings.GoalStep]
    if not step then stopGoal(); if goalStatusLabel then goalStatusLabel:SetText("Goal completed!") end return end
    if step.condition() then
        step.teardown()
        settings.GoalStep = settings.GoalStep + 1
        local nextStep = steps[settings.GoalStep]
        if nextStep then
            nextStep.setup()
            if goalStatusLabel then goalStatusLabel:SetText("Goal: "..settings.CurrentGoal.." | Task: "..nextStep.task) end
        else
            stopGoal()
            if goalStatusLabel then goalStatusLabel:SetText("Goal completed!") end
        end
    end
end
task.spawn(function() while true do goalTick() task.wait(1) end end)

-- // ================== FLUENT UI (FIXED VERSION) ==================
-- Load the library using the correct, updated syntax
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- (Optional) Load addons if you need them
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Blox Fruits Ultimate Hub",
    SubTitle = "Fluent Only | Fully Fixed | Lightweight",
    TabWidth = 160, Size = UDim2.fromOffset(620, 500),
    Acrylic = false, Theme = "Dark", MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({Title="Main", Icon="home"}),
    Attack = Window:AddTab({Title="Attack", Icon="zap"}),
    Stats = Window:AddTab({Title="Stats", Icon="chart"}),
    Teleport = Window:AddTab({Title="Teleports", Icon="map-pin"}),
    Raid = Window:AddTab({Title="Raids", Icon="trophy"}),
    AutoBuy = Window:AddTab({Title="Auto Buy", Icon="shopping-cart"}),
    Mastery = Window:AddTab({Title="Mastery", Icon="swords"}),
    Legendary = Window:AddTab({Title="Legendary", Icon="sword"}),
    Sea = Window:AddTab({Title="Sea Events", Icon="waves"}),
    BossHop = Window:AddTab({Title="Boss Hop", Icon="search"}),
    Goals = Window:AddTab({Title="Goals", Icon="target"}),
    Misc = Window:AddTab({Title="Misc", Icon="settings"})
}

Tabs.Main:AddSection("Farm")
Tabs.Main:AddDropdown("FarmMethod", {Title="Method", Values={"Level","Nearest","Auto Bone"}, Default="Level", Callback=function(v) settings.FarmMethod=v end})
Tabs.Main:AddToggle("AutoFarm", {Title="Auto Farm", Default=false, Callback=function(v) settings.AutoFarm=v; if v then task.spawn(autoFarmLoop) end end})
Tabs.Main:AddToggle("AutoQuest", {Title="Auto Accept Quests", Default=true, Callback=function(v) settings.AutoQuest=v end})

Tabs.Attack:AddSection("Modes")
Tabs.Attack:AddDropdown("AttackMode", {Title="Mode", Values={"Normal","Fast","Super Fast","Speed"}, Default="Normal", Callback=function(v) settings.AttackMode=v end})
Tabs.Attack:AddSlider("Speed", {Title="Super Fast Delay (ms)", Min=1, Max=100, Default=10, Callback=function(v) settings.SuperFastDelay=v/1000 end})

Tabs.Stats:AddSection("Auto")
Tabs.Stats:AddToggle("AutoStats", {Title="Auto Distribute", Default=false, Callback=function(v) settings.AutoStats=v end})
Tabs.Stats:AddDropdown("StatType", {Title="Stat", Values={"Melee","Defense","Sword","Gun","Blox Fruit"}, Default="Melee", Callback=function(v) settings.StatType=v end})

local tpData = {
    [1] = {Start=CFrame.new(982,16,1430), PirateIsland=CFrame.new(1050,16,1550), MarineFortress=CFrame.new(-2722,73,-5460), Skylands=CFrame.new(-4876,322,-4843), Prison=CFrame.new(5250,18,-1665), Colosseum=CFrame.new(-1423,124,-9498), MagmaVillage=CFrame.new(-5250,51,8575), UnderwaterCity=CFrame.new(3878,27,-1934), FrozenVillage=CFrame.new(1193,18,-1214)},
    [2] = {KingdomOfRose=CFrame.new(-567,38,-752), GreenZone=CFrame.new(-1840,25,3955), Graveyard=CFrame.new(-5463,23,-6203), SnowMountain=CFrame.new(-740,200,-11800), HotAndCold=CFrame.new(-6073,38,-5340), CursedShip=CFrame.new(-19071,107,7875), IceCastle=CFrame.new(-970,200,-14200)},
    [3] = {PortTown=CFrame.new(-10654,72,-6335), HydraIsland=CFrame.new(475,-67,6900), GreatTree=CFrame.new(5834,50,-1209), HauntedCastle=CFrame.new(-13196,378,-7624), SeaOfTreats=CFrame.new(13300,200,12500), TikiOutpost=CFrame.new(-16500,15,4000)}
}
local tpList = {}
if tpData[sea] then for n,_ in pairs(tpData[sea]) do table.insert(tpList,n) end table.sort(tpList) end
Tabs.Teleport:AddSection("Islands")
Tabs.Teleport:AddDropdown("Island", {Title="Teleport", Values=tpList, Default=tpList[1] or "", Callback=function(v) local hrp=getHRP(); if hrp then safeTeleport(tpData[sea][v]) end end})

Tabs.Raid:AddSection("Auto Raid")
Tabs.Raid:AddToggle("AutoRaid", {Title="Auto Raid", Default=false, Callback=function(v) settings.AutoRaid=v end})
Tabs.Raid:AddDropdown("RaidType", {Title="Type", Values={"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Buddha","Phoenix","Dough","Dragon","Venom","Shadow","Spirit","Leopard","Kitsune","T-Rex","Mammoth"}, Default="Flame", Callback=function(v) settings.RaidType=v end})

Tabs.AutoBuy:AddSection("Equipment")
Tabs.AutoBuy:AddToggle("AutoBuySwords", {Title="Swords", Default=false, Callback=function(v) settings.AutoBuySwords=v end})
Tabs.AutoBuy:AddToggle("AutoBuyGuns", {Title="Guns", Default=false, Callback=function(v) settings.AutoBuyGuns=v end})
Tabs.AutoBuy:AddToggle("AutoBuyMelee", {Title="Melee", Default=false, Callback=function(v) settings.AutoBuyMelee=v end})
Tabs.AutoBuy:AddToggle("AutoBuyHaki", {Title="Haki", Default=false, Callback=function(v) settings.AutoBuyHaki=v end})
Tabs.AutoBuy:AddToggle("AutoSpinFruit", {Title="Spin Fruit", Default=false, Callback=function(v) settings.AutoSpinFruit=v end})

Tabs.Mastery:AddSection("Auto Mastery")
Tabs.Mastery:AddToggle("AutoMastery", {Title="Auto Mastery", Default=false, Callback=function(v) settings.AutoMastery=v end})
Tabs.Mastery:AddDropdown("MasteryType", {Title="Weapon Type", Values={"Sword","Gun","Melee","Blox Fruit"}, Default="Sword", Callback=function(v) settings.MasteryType=v end})

Tabs.Legendary:AddSection("Legendary Swords")
Tabs.Legendary:AddToggle("AutoYama", {Title="Auto Get Yama", Default=false, Callback=function(v) settings.AutoYama=v end})
Tabs.Legendary:AddToggle("AutoTushita", {Title="Auto Get Tushita", Default=false, Callback=function(v) settings.AutoTushita=v end})
Tabs.Legendary:AddToggle("AutoCDK", {Title="Auto CDK (Both)", Default=false, Callback=function(v) settings.AutoCDK=v end})

Tabs.Sea:AddSection("Auto Sea Events")
Tabs.Sea:AddToggle("AutoSeaBeast", {Title="Sea Beast", Default=false, Callback=function(v) settings.AutoSeaBeast=v end})
Tabs.Sea:AddToggle("AutoPiranha", {Title="Piranha", Default=false, Callback=function(v) settings.AutoPiranha=v end})
Tabs.Sea:AddToggle("AutoTerrorShark", {Title="Terror Shark", Default=false, Callback=function(v) settings.AutoTerrorShark=v end})

Tabs.BossHop:AddSection("Auto Hop")
Tabs.BossHop:AddToggle("AutoSoulReaper", {Title="Soul Reaper Hop", Default=false, Callback=function(v) settings.AutoSoulReaper=v end})
Tabs.BossHop:AddToggle("AutoPirateRaid", {Title="Pirate Raid Hop", Default=false, Callback=function(v) settings.AutoPirateRaid=v end})
Tabs.BossHop:AddSlider("HopDelay", {Title="Hop Delay (s)", Min=10, Max=300, Default=60, Callback=function(v) settings.HopDelay=v end})

local goalSection = Tabs.Goals:AddSection("Goal Control")
local goalDropdown = goalSection:AddDropdown("GoalSelect", {Title="Select Goal", Values={"Reach Max Level","Obtain Specific Sword","Obtain Specific Fighting Style","Farm Beli","Farm Bones","Farm Fragments","Max Selected Mastery","Unlock CDK"}, Default="Reach Max Level", Callback=function(v) end})
goalSection:AddTextbox("GoalItem", {Title="Sword/Fighting Style Name", Default="", Callback=function(v) settings.GoalItem=v end})
goalSection:AddTextbox("TargetAmount", {Title="Target Amount (Beli/Bones/Fragments)", Default="0", Callback=function(v) settings.GoalTarget=tonumber(v) or 0 end})
goalSection:AddButton("Start Goal", function()
    local goal = goalDropdown.Value
    if (goal=="Obtain Specific Sword" or goal=="Obtain Specific Fighting Style") and settings.GoalItem=="" then Fluent:Notify({Title="Error", Content="Enter item name"}) return end
    if (goal=="Farm Beli" or goal=="Farm Bones" or goal=="Farm Fragments") and settings.GoalTarget<=0 then Fluent:Notify({Title="Error", Content="Set a valid target"}) return end
    startGoal(goal)
end)
goalSection:AddButton("Stop Goal", stopGoal)
goalStatusLabel = goalSection:AddLabel("Status: No goal active")

Tabs.Misc:AddSection("Features")
Tabs.Misc:AddToggle("NoClip", {Title="No Clip", Default=false, Callback=function(v) settings.NoClip=v end})
Tabs.Misc:AddToggle("InfJump", {Title="Infinite Jump", Default=false, Callback=function(v) settings.InfJump=v end})
Tabs.Misc:AddToggle("ESP", {Title="Enemy ESP", Default=false, Callback=function(v) settings.ESP=v end})
Tabs.Misc:AddToggle("AntiAFK", {Title="Anti AFK", Default=true, Callback=function(v) settings.AntiAFK=v end})
Tabs.Misc:AddToggle("AutoCloseDialog", {Title="Auto Close Dialogs", Default=true, Callback=function(v) settings.AutoCloseDialog=v end})

SaveManager:SetLibrary(Fluent); InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings(); SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("BFUltimateHub"); SaveManager:SetFolder("BFUltimateHub/configs")
SaveManager:BuildConfigSection(Tabs.Misc); InterfaceManager:BuildInterfaceSection(Tabs.Misc)

Window:SelectTab(1)
Fluent:Notify({Title="Loaded", Content="Fluent UI only – all features ready."})

-- Start AutoFarm if already enabled
if settings.AutoFarm then task.spawn(autoFarmLoop) end