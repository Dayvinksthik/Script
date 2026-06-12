--[[
    KOALA HUB v5.2 – FULLY LOADED | Blox Fruits
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- // Robust loading of Data, Level, Questlines (retry until found)
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

-- ====================== SETTINGS ======================
local Config = {
    AutoFarm = false, AutoQuest = true, FarmMethod = "Level",
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

-- ====================== SEA DETECTION ======================
local function getSea()
    local pid = game.PlaceId
    if pid == 2753915549 then return 1
    elseif pid == 4442272183 then return 2
    elseif pid == 7449423635 then return 3 end
    return nil
end
local sea = getSea()

-- ====================== UTILITIES ======================
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
            task.wait(Config.SuperFastDelay)
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

-- ====================== QUESTS (FULL 0‑2800) ======================
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

-- ====================== AUTO FARM (FULL) ======================
local farmRunning = false
local function autoFarmLoop()
    if farmRunning then return end
    farmRunning = true
    while Config.AutoFarm do
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

        local method = Config.FarmMethod
        if method == "Level" then
            local list = quests[curSea]
            if not list then task.wait(1) continue end
            local target = nil
            for i = #list, 1, -1 do if lv >= list[i][1] then target = list[i] break end end
            if not target then task.wait(1) continue end
            local questName = target[3]
            if Questlines and Config.AutoQuest then
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
                attackFuncs[Config.AttackMode]()
            end
        elseif method == "Nearest" then
            local enemy = getNearestEnemy(500)
            if enemy then
                hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                equipBestTool()
                attackFuncs[Config.AttackMode]()
            else task.wait(0.5) end
        elseif method == "Auto Bone" and curSea == 3 then
            local enemy = getNearestEnemy(300, "Skeleton") or getNearestEnemy(300, "Bone")
            if enemy then
                hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                equipBestTool()
                attackFuncs[Config.AttackMode]()
            else task.wait(0.5) end
        end
        task.wait()
    end
    farmRunning = false
end

-- ====================== AUTO STATS ======================
task.spawn(function()
    while true do
        if Config.AutoStats then
            local map = {Melee="AddMeleeStat", Defense="AddDefenseStat", Sword="AddSwordStat", Gun="AddGunStat", ["Blox Fruit"]="AddBloxFruitStat"}
            local remote = map[Config.StatType]
            if remote then pcall(function() ReplicatedStorage.Remotes[remote]:FireServer(3) end) end
            task.wait(0.5)
        else task.wait(1) end
    end
end)

-- ====================== AUTO RAID ======================
task.spawn(function()
    while true do
        if Config.AutoRaid then
            local curSea = sea or getSea()
            if curSea >= 2 and getHRP() then
                local ri = Workspace.Islands:FindFirstChild("Raid Island")
                if ri and ri:FindFirstChild("Center") then
                    safeTeleport(ri.Center.CFrame)
                    task.wait(1)
                    pcall(function() ReplicatedStorage.Remotes.Raid.StartRaid:InvokeServer(Config.RaidType) end)
                end
            end
            task.wait(30)
        else task.wait(5) end
    end
end)

-- ====================== AUTO BUY ======================
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
        if Config.AutoBuySwords and not buyStates.Swords then buyStates.Swords = true; task.spawn(autoBuyLoop, "Swords") end
        if Config.AutoBuyGuns and not buyStates.Guns then buyStates.Guns = true; task.spawn(autoBuyLoop, "Guns") end
        if Config.AutoBuyMelee and not buyStates.Melee then buyStates.Melee = true; task.spawn(autoBuyLoop, "Melee") end
        if Config.AutoBuyHaki and not buyStates.Haki then buyStates.Haki = true; task.spawn(autoBuyLoop, "Haki") end
        if Config.AutoSpinFruit and not buyStates.Spin then buyStates.Spin = true; task.spawn(spinLoop) end
        task.wait(1)
    end
end)

-- ====================== AUTO MASTERY ======================
local masteryRunning = false
task.spawn(function()
    while true do
        if Config.AutoMastery and not masteryRunning then
            masteryRunning = true
            while Config.AutoMastery do
                local hrp = getHRP()
                if not hrp then task.wait(1) continue end
                local mt = Config.MasteryType
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
                    attackFuncs[Config.AttackMode]()
                end
                task.wait(1)
            end
            masteryRunning = false
        end
        task.wait(1)
    end
end)

-- ====================== LEGENDARY SWORDS ======================
local yamaR, tushitaR, cdkR = false, false, false
task.spawn(function()
    while true do
        if Config.AutoYama and not yamaR and not hasItem("Yama") then
            yamaR = true
            while Config.AutoYama and not hasItem("Yama") do
                local hrp = getHRP()
                if not hrp then task.wait(1) continue end
                if not hasItem("Hell's Gate Key") then
                    local cc = Enemies:FindFirstChild("Cursed Captain")
                    if cc and cc:FindFirstChild("HumanoidRootPart") then
                        hrp.CFrame = cc.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                        equipBestTool()
                        attackFuncs[Config.AttackMode]()
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
        if Config.AutoTushita and not tushitaR and not hasItem("Tushita") and sea == 3 then
            tushitaR = true
            while Config.AutoTushita and not hasItem("Tushita") do
                local hrp = getHRP()
                if not hrp then task.wait(1) continue end
                for _, cf in ipairs({CFrame.new(5500,50,-1000), CFrame.new(5600,30,-800), CFrame.new(5400,20,-1200)}) do safeTeleport(cf) task.wait(1.5) end
                local dk = Enemies:FindFirstChild("Dough King") or Enemies:FindFirstChild("Dough Prince")
                if dk and dk:FindFirstChild("HumanoidRootPart") then
                    hrp.CFrame = dk.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                    equipBestTool()
                    attackFuncs[Config.AttackMode]()
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
        if Config.AutoCDK and not cdkR then
            cdkR = true
            while Config.AutoCDK do
                if not hasItem("Yama") then Config.AutoYama = true; task.wait(5)
                elseif not hasItem("Tushita") then Config.AutoTushita = true; task.wait(5)
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
                                Config.AutoCDK = false
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

-- ====================== SEA EVENTS ======================
local seaEventNames = {SeaBeast="Sea Beast", Piranha="Piranha", TerrorShark="Terror Shark"}
task.spawn(function()
    while true do
        if Config.AutoSeaBeast or Config.AutoPiranha or Config.AutoTerrorShark then
            local hrp = getHRP()
            if not hrp then task.wait(1) continue end
            local curSea = sea or getSea()
            local seaPos = curSea==1 and CFrame.new(-5000,0,-5000) or curSea==2 and CFrame.new(-5000,0,10000) or CFrame.new(-10000,0,-20000)
            safeTeleport(seaPos)
            task.wait(2)
            for ev, ename in pairs(seaEventNames) do
                if Config["Auto"..ev] then
                    local enemy = getNearestEnemy(1000, ename)
                    if enemy then
                        hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0,0,5)
                        equipBestTool()
                        attackFuncs[Config.AttackMode]()
                    end
                end
            end
            task.wait(3)
        else task.wait(5) end
    end
end)

-- ====================== BOSS HOP ======================
local function bossExists(name)
    for _, e in ipairs(Enemies:GetChildren()) do
        if e.Name == name and e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 then return true end
    end
    return Workspace:FindFirstChild(name) ~= nil
end
local function serverHop()
    if os.time() - (Config.LastHopTick or 0) < Config.HopDelay then return end
    Config.LastHopTick = os.time()
    pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
end
task.spawn(function()
    while true do
        if Config.AutoSoulReaper and sea == 3 and not bossExists("Soul Reaper") then serverHop() end
        if Config.AutoPirateRaid and (sea or 0) >= 2 and not bossExists("Pirate Raid") and not bossExists("Pirate Raid Boss") then serverHop() end
        task.wait(30)
    end
end)

-- ====================== AUTO CLOSE DIALOG ======================
task.spawn(function()
    while true do
        if Config.AutoCloseDialog then
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

-- ====================== UTILITIES (NoClip, InfJump, ESP, AntiAFK) ======================
RunService.Heartbeat:Connect(function()
    if Config.NoClip and LocalPlayer.Character then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
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

-- ====================== GOAL SYSTEM ======================
local goalDefinitions = {
    ["Reach Max Level"] = {{task="Leveling to 2800", setup=function() Config.AutoFarm=true; Config.FarmMethod="Level"; Config.AutoQuest=true end, condition=function() return Level.Value>=2800 end, teardown=function() Config.AutoFarm=false end}},
    ["Obtain Specific Sword"] = {{task="Purchasing sword", setup=function() Config.AutoBuySwords=true; buyStates.Swords=true; task.spawn(autoBuyLoop,"Swords") end, condition=function() return hasItem(Config.GoalItem) end, teardown=function() Config.AutoBuySwords=false; buyStates.Swords=false end}},
    ["Obtain Specific Fighting Style"] = {{task="Purchasing fighting style", setup=function() Config.AutoBuyMelee=true; buyStates.Melee=true; task.spawn(autoBuyLoop,"Melee") end, condition=function() return hasItem(Config.GoalItem) end, teardown=function() Config.AutoBuyMelee=false; buyStates.Melee=false end}},
    ["Farm Beli"] = {{task="Farming Beli", setup=function() Config.AutoFarm=true; Config.FarmMethod="Nearest" end, condition=function() return Data.Beli.Value>=Config.GoalTarget end, teardown=function() Config.AutoFarm=false end}},
    ["Farm Bones"] = {{task="Farming Bones", setup=function() Config.AutoFarm=true; Config.FarmMethod="Auto Bone" end, condition=function() return Data:FindFirstChild("Bones") and Data.Bones.Value>=Config.GoalTarget end, teardown=function() Config.AutoFarm=false end}},
    ["Farm Fragments"] = {{task="Farming Fragments", setup=function() Config.AutoRaid=true end, condition=function() return Data:FindFirstChild("Fragments") and Data.Fragments.Value>=Config.GoalTarget end, teardown=function() Config.AutoRaid=false end}},
    ["Max Selected Mastery"] = {{task="Mastering", setup=function() Config.AutoMastery=true end, condition=function() return false end, teardown=function() Config.AutoMastery=false end}},
    ["Unlock CDK"] = {
        {task="Obtaining Yama", setup=function() Config.AutoYama=true end, condition=function() return hasItem("Yama") end, teardown=function() Config.AutoYama=false end},
        {task="Obtaining Tushita", setup=function() Config.AutoTushita=true end, condition=function() return hasItem("Tushita") end, teardown=function() Config.AutoTushita=false end},
        {task="Crafting CDK", setup=function() Config.AutoCDK=true end, condition=function() return hasItem("Cursed Dual Katana") end, teardown=function() Config.AutoCDK=false end}
    }
}
local goalStatusLabel = nil
local function stopGoal()
    if Config.GoalActive then
        local steps = goalDefinitions[Config.CurrentGoal]
        if steps and steps[Config.GoalStep] then steps[Config.GoalStep].teardown() end
        Config.GoalActive = false; Config.CurrentGoal = ""; Config.GoalStep = 0
        if goalStatusLabel then goalStatusLabel:SetText("No goal active") end
    end
end
local function startGoal(goal)
    stopGoal()
    Config.CurrentGoal = goal; Config.GoalStep = 1; Config.GoalActive = true
    local steps = goalDefinitions[goal]
    if steps and steps[1] then
        steps[1].setup()
        if goalStatusLabel then goalStatusLabel:SetText("Goal: "..goal.." | Task: "..steps[1].task) end
    end
end
local function goalTick()
    if not Config.GoalActive then return end
    local steps = goalDefinitions[Config.CurrentGoal]
    if not steps then stopGoal() return end
    local step = steps[Config.GoalStep]
    if not step then stopGoal(); if goalStatusLabel then goalStatusLabel:SetText("Goal completed!") end return end
    if step.condition() then
        step.teardown()
        Config.GoalStep = Config.GoalStep + 1
        local nextStep = steps[Config.GoalStep]
        if nextStep then
            nextStep.setup()
            if goalStatusLabel then goalStatusLabel:SetText("Goal: "..Config.CurrentGoal.." | Task: "..nextStep.task) end
        else
            stopGoal()
            if goalStatusLabel then goalStatusLabel:SetText("Goal completed!") end
        end
    end
end
task.spawn(function() while true do goalTick() task.wait(1) end end)

-- ====================== FLUENT UI (YOUR WORKING VERSION) ======================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "Koala Hub v5.2",
    SubTitle = "Blox Fruits | Fully Loaded",
    TabWidth = 160,
    Size = UDim2.fromOffset(620, 520),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({Title = "Main", Icon = "home"}),
    Farming = Window:AddTab({Title = "Farming", Icon = "leaf"}),
    StatsRaid = Window:AddTab({Title = "Stats/Raid", Icon = "chart"}),
    Shop = Window:AddTab({Title = "Shop", Icon = "shopping-cart"}),
    Mastery = Window:AddTab({Title = "Mastery", Icon = "swords"}),
    Legendary = Window:AddTab({Title = "Legendary", Icon = "sword"}),
    Sea = Window:AddTab({Title = "Sea Events", Icon = "waves"}),
    BossHop = Window:AddTab({Title = "Boss Hop", Icon = "search"}),
    Goals = Window:AddTab({Title = "Goals", Icon = "target"}),
    Misc = Window:AddTab({Title = "Misc", Icon = "settings"})
}

-- // Main Tab
Tabs.Main:AddSection("Core")
Tabs.Main:AddToggle("AutoFarm", {Title = "Auto Farm", Default = false}):OnChanged(function(v) Config.AutoFarm = v; if v then task.spawn(autoFarmLoop) end end)
Tabs.Main:AddToggle("AutoQuest", {Title = "Auto Quest", Default = true}):OnChanged(function(v) Config.AutoQuest = v end)
Tabs.Main:AddDropdown("FarmMethod", {Title = "Farm Method", Values = {"Level", "Nearest", "Auto Bone"}, Default = "Level"}):OnChanged(function(v) Config.FarmMethod = v end)

-- // Farming Tab
Tabs.Farming:AddSection("Attack")
Tabs.Farming:AddDropdown("AttackMode", {Title = "Attack Mode", Values = {"Normal", "Fast", "Super Fast", "Speed"}, Default = "Normal"}):OnChanged(function(v) Config.AttackMode = v end)
Tabs.Farming:AddSlider("SuperFastDelay", {Title = "Super Fast Delay (ms)", Min = 1, Max = 100, Default = 10}):OnChanged(function(v) Config.SuperFastDelay = v/1000 end)

-- // Stats & Raid
Tabs.StatsRaid:AddSection("Auto Stats")
Tabs.StatsRaid:AddToggle("AutoStats", {Title = "Auto Distribute", Default = false}):OnChanged(function(v) Config.AutoStats = v end)
Tabs.StatsRaid:AddDropdown("StatType", {Title = "Stat", Values = {"Melee","Defense","Sword","Gun","Blox Fruit"}, Default = "Melee"}):OnChanged(function(v) Config.StatType = v end)
Tabs.StatsRaid:AddSection("Auto Raid")
Tabs.StatsRaid:AddToggle("AutoRaid", {Title = "Auto Raid", Default = false}):OnChanged(function(v) Config.AutoRaid = v end)
Tabs.StatsRaid:AddDropdown("RaidType", {Title = "Raid Type", Values = {"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Buddha","Phoenix","Dough","Dragon","Venom","Shadow","Spirit","Leopard","Kitsune","T-Rex","Mammoth"}, Default = "Flame"}):OnChanged(function(v) Config.RaidType = v end)

-- // Shop Tab
Tabs.Shop:AddSection("Auto Buy")
Tabs.Shop:AddToggle("AutoBuySwords", {Title = "Swords", Default = false}):OnChanged(function(v) Config.AutoBuySwords = v end)
Tabs.Shop:AddToggle("AutoBuyGuns", {Title = "Guns", Default = false}):OnChanged(function(v) Config.AutoBuyGuns = v end)
Tabs.Shop:AddToggle("AutoBuyMelee", {Title = "Melee", Default = false}):OnChanged(function(v) Config.AutoBuyMelee = v end)
Tabs.Shop:AddToggle("AutoBuyHaki", {Title = "Haki", Default = false}):OnChanged(function(v) Config.AutoBuyHaki = v end)
Tabs.Shop:AddToggle("AutoSpinFruit", {Title = "Spin Fruit", Default = false}):OnChanged(function(v) Config.AutoSpinFruit = v end)

-- // Mastery Tab
Tabs.Mastery:AddSection("Auto Mastery")
Tabs.Mastery:AddToggle("AutoMastery", {Title = "Auto Mastery", Default = false}):OnChanged(function(v) Config.AutoMastery = v end)
Tabs.Mastery:AddDropdown("MasteryType", {Title = "Weapon Type", Values = {"Sword","Gun","Melee","Blox Fruit"}, Default = "Sword"}):OnChanged(function(v) Config.MasteryType = v end)

-- // Legendary Tab
Tabs.Legendary:AddSection("Legendary Swords")
Tabs.Legendary:AddToggle("AutoYama", {Title = "Auto Yama", Default = false}):OnChanged(function(v) Config.AutoYama = v end)
Tabs.Legendary:AddToggle("AutoTushita", {Title = "Auto Tushita", Default = false}):OnChanged(function(v) Config.AutoTushita = v end)
Tabs.Legendary:AddToggle("AutoCDK", {Title = "Auto CDK (Both)", Default = false}):OnChanged(function(v) Config.AutoCDK = v end)

-- // Sea Events Tab
Tabs.Sea:AddSection("Auto Sea Events")
Tabs.Sea:AddToggle("AutoSeaBeast", {Title = "Sea Beast", Default = false}):OnChanged(function(v) Config.AutoSeaBeast = v end)
Tabs.Sea:AddToggle("AutoPiranha", {Title = "Piranha", Default = false}):OnChanged(function(v) Config.AutoPiranha = v end)
Tabs.Sea:AddToggle("AutoTerrorShark", {Title = "Terror Shark", Default = false}):OnChanged(function(v) Config.AutoTerrorShark = v end)

-- // Boss Hop Tab
Tabs.BossHop:AddSection("Auto Server Hop")
Tabs.BossHop:AddToggle("AutoSoulReaper", {Title = "Soul Reaper Hop", Default = false}):OnChanged(function(v) Config.AutoSoulReaper = v end)
Tabs.BossHop:AddToggle("AutoPirateRaid", {Title = "Pirate Raid Hop", Default = false}):OnChanged(function(v) Config.AutoPirateRaid = v end)
Tabs.BossHop:AddSlider("HopDelay", {Title = "Hop Delay (s)", Min = 10, Max = 300, Default = 60}):OnChanged(function(v) Config.HopDelay = v end)

-- // Goals Tab
local goalSection = Tabs.Goals:AddSection("Goal Control")
local goalDropdown = goalSection:AddDropdown("GoalSelect", {Title = "Select Goal", Values = {"Reach Max Level","Obtain Specific Sword","Obtain Specific Fighting Style","Farm Beli","Farm Bones","Farm Fragments","Max Selected Mastery","Unlock CDK"}, Default = "Reach Max Level", Callback = function(v) end})
goalSection:AddTextbox("GoalItem", {Title = "Sword/Fighting Style Name", Default = "", Callback = function(v) Config.GoalItem = v end})
goalSection:AddTextbox("TargetAmount", {Title = "Target Amount (Beli/Bones/Fragments)", Default = "0", Callback = function(v) Config.GoalTarget = tonumber(v) or 0 end})
goalSection:AddButton("Start Goal", function()
    local goal = goalDropdown.Value
    if (goal == "Obtain Specific Sword" or goal == "Obtain Specific Fighting Style") and Config.GoalItem == "" then Fluent:Notify({Title = "Error", Content = "Enter item name"}) return end
    if (goal == "Farm Beli" or goal == "Farm Bones" or goal == "Farm Fragments") and Config.GoalTarget <= 0 then Fluent:Notify({Title = "Error", Content = "Set a valid target"}) return end
    startGoal(goal)
end)
goalSection:AddButton("Stop Goal", stopGoal)
goalStatusLabel = goalSection:AddLabel("Status: No goal active")

-- // Misc Tab
Tabs.Misc:AddSection("Utility")
Tabs.Misc:AddToggle("NoClip", {Title = "No Clip", Default = false}):OnChanged(function(v) Config.NoClip = v end)
Tabs.Misc:AddToggle("InfJump", {Title = "Infinite Jump", Default = false}):OnChanged(function(v) Config.InfJump = v end)
Tabs.Misc:AddToggle("ESP", {Title = "Enemy ESP", Default = false}):OnChanged(function(v) Config.ESP = v end)
Tabs.Misc:AddToggle("AntiAFK", {Title = "Anti AFK", Default = true}):OnChanged(function(v) Config.AntiAFK = v end)
Tabs.Misc:AddToggle("AutoCloseDialog", {Title = "Auto Close Dialogs", Default = true}):OnChanged(function(v) Config.AutoCloseDialog = v end)

-- ====================== MINIMIZE BUTTON (YOUR WORKING CODE) ======================
task.spawn(function()
    task.wait(2)
    local mainFrame = Window and Window.Main
    if mainFrame then
        local minBtn = Instance.new("TextButton")
        minBtn.Size = UDim2.new(0, 30, 0, 30)
        minBtn.Position = UDim2.new(1, -35, 0, 5)
        minBtn.Text = "▼"
        minBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
        minBtn.TextColor3 = Color3.new(1,1,1)
        minBtn.Parent = mainFrame

        local minimized = false
        minBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            mainFrame.Size = minimized and UDim2.fromOffset(620, 50) or UDim2.fromOffset(620, 520)
            minBtn.Text = minimized and "▲" or "▼"
        end)
    end
end)

-- ====================== FINAL ======================
Window:SelectTab(1)
Fluent:Notify({Title = "Koala Hub v5.2", Content = "All features loaded | Fully working", Duration = 8})
print("✅ Koala Hub v5.2 – Fully Loaded. All systems online.")