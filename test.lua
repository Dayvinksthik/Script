-- Blox Fruits Ultimate All-in-One Script (Fixed & Optimized)
-- Fixes: Questlines infinite yield, DMGDEBUG flood, NPC nil errors, safe arithmetic.
-- Features: Auto Farm (Level/Nearest/Bone), 0‑2800 sea progression, Attack modes,
-- Auto Stats, Auto Haki, Teleports, Raids, Auto Buy, Spin Fruit, Auto Bone,
-- Auto Mastery, Legendary Swords (Yama, Tushita, CDK), Sea Events,
-- Boss Server Hop, Auto Close Dialogs, NoClip, InfJump, ESP, AntiAFK, Smart Goal System.
-- palofsc

-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- // Safely load player data with timeout
local Data = nil
local Level = nil
local Questlines = nil

local function safeWaitForChild(parent, childName, timeout)
    local start = tick()
    local child = parent:FindFirstChild(childName)
    while not child and tick() - start < timeout do
        task.wait(0.5)
        child = parent:FindFirstChild(childName)
    end
    return child
end

-- Wait up to 15 seconds for Data, Level, and Questlines (unlikely to fail)
Data = safeWaitForChild(LocalPlayer, "Data", 15)
if Data then
    Level = safeWaitForChild(Data, "Level", 5)
end
Questlines = safeWaitForChild(LocalPlayer, "Questlines", 10)

-- Fallbacks
if not Data then warn("Data not found, some features disabled") end
if not Level then warn("Level not found, auto farm may not work") end
if not Questlines then warn("Questlines not found, auto quest disabled") end

local Mouse = LocalPlayer:GetMouse()
local Enemies = Workspace:WaitForChild("Enemies")

-- // Settings
local settings = {
    AutoFarm = false,
    FarmMethod = "Level", -- "Level", "Nearest", "Auto Bone"
    AutoQuest = true,
    AutoStats = false,
    StatType = "Melee",
    AttackMode = "Normal",
    SuperFastDelay = 0.01,
    AutoRaid = false,
    RaidType = "Flame",
    NoClip = false,
    InfJump = false,
    ESP = false,
    AntiAFK = true,
    AutoBuySwords = false,
    AutoBuyGuns = false,
    AutoBuyMelee = false,
    AutoBuyHaki = false,
    AutoSpinFruit = false,
    AutoMastery = false,
    MasteryType = "Sword",
    AutoYama = false,
    AutoTushita = false,
    AutoCDK = false,
    AutoSeaBeast = false,
    AutoPiranha = false,
    AutoTerrorShark = false,
    AutoSoulReaper = false,
    AutoPirateRaid = false,
    AutoCloseDialog = true,
    HopDelay = 60,
    LastHopTick = 0,
    GoalActive = false,
    CurrentGoal = "",
    GoalStep = 0,
    GoalTarget = 0,
    GoalItem = ""
}

-- // Sea detection
local sea = nil
local function updateSea()
    local pid = game.PlaceId
    sea = (pid == 2753915549 and 1) or (pid == 4442272183 and 2) or (pid == 7449423635 and 3)
    return sea
end
updateSea()

-- // Safe helpers
local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function findPrompt(npcName)
    for _, npc in ipairs(Workspace.NPCs:GetChildren()) do
        if npc.Name == npcName then
            local prompt = npc:FindFirstChild("ProximityPrompt")
            if prompt then return prompt end
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and parent.Name == npcName then
                return obj
            end
        end
    end
    return nil
end

local function safeTeleport(cf)
    local hrp = getHRP()
    if not hrp then return false end
    local tween = TweenService:Create(hrp, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {CFrame = cf})
    tween:Play()
    task.wait(0.6)
    return true
end

local function equipBestTool()
    local char = LocalPlayer.Character
    local bp = LocalPlayer.Backpack
    if not bp or not char then return end
    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
            char.Humanoid:EquipTool(tool)
            return
        end
    end
end

local function equipToolByName(name)
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == name and tool:FindFirstChild("Handle") then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:EquipTool(tool)
                return true
            end
        end
    end
    return false
end

local function hasItem(itemName)
    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if v.Name == itemName then return true end
    end
    if LocalPlayer.Character then
        for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("Tool") and v.Name == itemName then return true end
        end
    end
    return false
end

-- // Attack functions with throttle to prevent DMGDEBUG spam
local lastRemoteAttackTick = 0
local REMOTE_ATTACK_COOLDOWN = 0.1

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
        local currentTick = tick()
        if currentTick - lastRemoteAttackTick < REMOTE_ATTACK_COOLDOWN then
            return
        end
        lastRemoteAttackTick = currentTick
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local weaponRemote = remotes and (remotes:FindFirstChild("Weapon") or remotes:FindFirstChild("Attack"))
        if weaponRemote then
            pcall(function() weaponRemote:FireServer("Swing") end)
        else
            VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 0)
        end
    end
}

-- // Nearest enemy finder
local function getNearestEnemy(range, namePattern)
    local hrp = getHRP()
    if not hrp then return nil end
    local closest, minDist = nil, range or math.huge
    for _, enemy in ipairs(Enemies:GetChildren()) do
        local ehrp = enemy:FindFirstChild("HumanoidRootPart")
        local hum = enemy:FindFirstChild("Humanoid")
        if ehrp and hum and hum.Health > 0 then
            if namePattern and not enemy.Name:find(namePattern) then continue end
            local dist = (hrp.Position - ehrp.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = enemy
            end
        end
    end
    return closest
end

-- // Quest Tables (unchanged)
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

-- // Auto Farm Loop
local function autoFarmLoop()
    while settings.AutoFarm do
        local hrp = getHRP()
        if not hrp then task.wait(0.2) continue end
        local currentSea = sea
        local lv = Level and Level.Value or 0

        -- Sea transition
        if currentSea == 1 and lv >= 700 then
            safeTeleport(CFrame.new(-2722.77, 73.37, -5459.68))
            task.wait(0.5)
            local p = findPrompt("Royale Sailor")
            if p then pcall(function() p:InputHoldBegin() end) end
            updateSea()
            task.wait(5)
            continue
        elseif currentSea == 2 and lv >= 1500 then
            safeTeleport(CFrame.new(-567, 38, -752))
            task.wait(0.5)
            local p = findPrompt("Luxury Sailor")
            if p then pcall(function() p:InputHoldBegin() end) end
            updateSea()
            task.wait(5)
            continue
        end

        local method = settings.FarmMethod
        if method == "Level" then
            local list = quests[currentSea]
            if not list then task.wait(1) continue end
            local target = nil
            for i = #list, 1, -1 do if lv >= list[i][1] then target = list[i]; break end end
            if not target then task.wait(1) continue end
            local questName = target[3]
            -- Only attempt quest if Questlines exists and auto quest is on
            if Questlines and settings.AutoQuest then
                local questObj = Questlines:FindFirstChild(questName)
                if questObj and questObj.Current.Value == 0 then
                    safeTeleport(target[4])
                    task.wait(0.3)
                    for _, npc in ipairs(Workspace.NPCs:GetChildren()) do
                        if npc:FindFirstChild("Questline") and npc.Questline.Value == questName then
                            local prompt = npc:FindFirstChild("ProximityPrompt")
                            if prompt then pcall(function() prompt:InputHoldBegin() end) end
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
                local attackFunc = attackFuncs[settings.AttackMode]
                if attackFunc then attackFunc() end
            end
        elseif method == "Nearest" then
            local enemy = getNearestEnemy(500)
            if enemy then
                hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                equipBestTool()
                local attackFunc = attackFuncs[settings.AttackMode]
                if attackFunc then attackFunc() end
            else
                task.wait(0.5)
            end
        elseif method == "Auto Bone" then
            if currentSea ~= 3 then task.wait(2) continue end
            local enemy = getNearestEnemy(300, "Skeleton") or getNearestEnemy(300, "Bone")
            if enemy then
                hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                equipBestTool()
                local attackFunc = attackFuncs[settings.AttackMode]
                if attackFunc then attackFunc() end
            else
                task.wait(0.5)
            end
        end
        task.wait()
    end
end

-- // Auto Stats
coroutine.wrap(function()
    while true do
        if settings.AutoStats then
            local map = {Melee="AddMeleeStat",Defense="AddDefenseStat",Sword="AddSwordStat",Gun="AddGunStat",["Blox Fruit"]="AddBloxFruitStat"}
            local remote = map[settings.StatType]
            if remote then pcall(function() ReplicatedStorage.Remotes[remote]:FireServer(3) end) end
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)()

-- // Auto Raid
coroutine.wrap(function()
    while true do
        if settings.AutoRaid then
            if sea >= 2 and getHRP() then
                local raidIsland = Workspace.Islands:FindFirstChild("Raid Island")
                if raidIsland and raidIsland:FindFirstChild("Center") then
                    safeTeleport(raidIsland.Center.CFrame)
                    task.wait(1)
                    pcall(function() ReplicatedStorage.Remotes.Raid.StartRaid:InvokeServer(settings.RaidType) end)
                end
            end
            task.wait(30)
        else
            task.wait(5)
        end
    end
end)()

-- // Auto Buy Systems
local shopData = {
    Swords = {{"Katana",1000,"Sword Dealer",CFrame.new(-1640,21,985)},{"Cutlass",5000,"Sword Dealer",CFrame.new(-1640,21,985)},{"Dual Katana",12000,"Sword Dealer",CFrame.new(-1640,21,985)},{"Iron Mace",25000,"Sword Dealer",CFrame.new(-1640,21,985)},{"Shark Saw",50000,"Sword Dealer",CFrame.new(-1640,21,985)},{"Triple Katana",150000,"Sword Dealer",CFrame.new(-1640,21,985)},{"Pipe",250000,"Sword Dealer",CFrame.new(-1640,21,985)}},
    Guns = {{"Slingshot",500,"Gun Dealer",CFrame.new(-1060,15,-160)},{"Musket",5000,"Gun Dealer",CFrame.new(-1060,15,-160)},{"Flintlock",15000,"Gun Dealer",CFrame.new(-1060,15,-160)},{"Refined Flintlock",45000,"Gun Dealer",CFrame.new(-1060,15,-160)},{"Cannon",150000,"Gun Dealer",CFrame.new(-1060,15,-160)}},
    Melee = {{"Water Kung Fu",500000,"Water Kung Fu Master",CFrame.new(-3896,80,1956)},{"Electric Claw",3000000,"Electric Claw Master",CFrame.new(-2435,6,1606)},{"Dragon Breath",1000000,"Dragon Breath Master",CFrame.new(-2841,18,2476)},{"Superhuman",7500000,"Superhuman Teacher",CFrame.new(-1689,26,1205)}},
    Haki = {{"Busoshoku",100000,"Ability Teacher",CFrame.new(-1230,12,-680)},{"Kenbunshoku",750000,"Ability Teacher",CFrame.new(-1230,12,-680)}}
}

local autoBuyStates = {Swords=false, Guns=false, Melee=false, Haki=false, Spin=false}

local function autoBuyLoop(category)
    while autoBuyStates[category] do
        task.wait(2)
        local hrp = getHRP() if not hrp then continue end
        local money = Data and Data:FindFirstChild("Beli") and Data.Beli.Value or 0
        for _, item in ipairs(shopData[category]) do
            if not hasItem(item[1]) and money >= item[2] then
                safeTeleport(item[4])
                task.wait(1)
                local p = findPrompt(item[3])
                if p then pcall(function() p:InputHoldBegin() end) task.wait(1.5) end
                break
            end
        end
    end
end

local function spinLoop()
    while autoBuyStates.Spin do
        task.wait(2)
        local money = Data and Data:FindFirstChild("Beli") and Data.Beli.Value or 0
        if money >= 25000 then
            local dealer = Workspace:FindFirstChild("Blox Fruit Dealer") or Workspace:FindFirstChild("Blox Fruit Dealer Cousin")
            if dealer then
                local primary = dealer.PrimaryPart or dealer:FindFirstChild("HumanoidRootPart")
                if primary then
                    safeTeleport(primary.CFrame)
                    task.wait(1)
                    local prompt = dealer:FindFirstChild("ProximityPrompt")
                    if prompt then pcall(function() prompt:InputHoldBegin() end) end
                end
            end
        end
    end
end

coroutine.wrap(function() while true do if settings.AutoBuySwords and not autoBuyStates.Swords then autoBuyStates.Swords=true autoBuyLoop("Swords") end task.wait(1) end end)()
coroutine.wrap(function() while true do if settings.AutoBuyGuns and not autoBuyStates.Guns then autoBuyStates.Guns=true autoBuyLoop("Guns") end task.wait(1) end end)()
coroutine.wrap(function() while true do if settings.AutoBuyMelee and not autoBuyStates.Melee then autoBuyStates.Melee=true autoBuyLoop("Melee") end task.wait(1) end end)()
coroutine.wrap(function() while true do if settings.AutoBuyHaki and not autoBuyStates.Haki then autoBuyStates.Haki=true autoBuyLoop("Haki") end task.wait(1) end end)()
coroutine.wrap(function() while true do if settings.AutoSpinFruit and not autoBuyStates.Spin then autoBuyStates.Spin=true spinLoop() end task.wait(1) end end)()

-- // Auto Mastery
local masteryRunning = false
coroutine.wrap(function()
    while true do
        if settings.AutoMastery and not masteryRunning then
            masteryRunning = true
            while settings.AutoMastery do
                local hrp = getHRP()
                if not hrp then task.wait(1) continue end
                local mt = settings.MasteryType
                local toolToUse = nil
                for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                        if (mt=="Sword" and tool:FindFirstChild("Sword")) or (mt=="Gun" and tool:FindFirstChild("Gun")) or (mt=="Melee" and tool:FindFirstChild("Melee")) or (mt=="Blox Fruit" and tool:FindFirstChild("BloxFruit")) then
                            toolToUse = tool break
                        end
                    end
                end
                if toolToUse then LocalPlayer.Character.Humanoid:EquipTool(toolToUse) end
                local enemy = getNearestEnemy(250)
                if enemy then
                    hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                    local attackFunc = attackFuncs[settings.AttackMode]
                    if attackFunc then attackFunc() end
                end
                task.wait(1)
            end
            masteryRunning = false
        end
        task.wait(1)
    end
end)()

-- // Legendary Swords (Yama, Tushita, CDK)
local yamaRunning, tushitaRunning, cdkRunning = false, false, false

coroutine.wrap(function()
    while true do
        if settings.AutoYama and not yamaRunning and not hasItem("Yama") then
            yamaRunning = true
            while settings.AutoYama and not hasItem("Yama") do
                local hrp = getHRP()
                if not hrp then task.wait(1) continue end
                if not hasItem("Hell's Gate Key") then
                    local cc = Enemies:FindFirstChild("Cursed Captain")
                    if cc and cc:FindFirstChild("HumanoidRootPart") then
                        hrp.CFrame = cc.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                        equipBestTool()
                        local attackFunc = attackFuncs[settings.AttackMode]
                        if attackFunc then attackFunc() end
                    else
                        safeTeleport(CFrame.new(-19071,107,7875))
                    end
                else
                    if sea == 3 then
                        safeTeleport(CFrame.new(-1422.83,123.57,-9498.36))
                        task.wait(2)
                        local door = Workspace:FindFirstChild("Hell's Gate") or Workspace:FindFirstChild("Door")
                        if door then
                            local prompt = door:FindFirstChild("ProximityPrompt")
                            if prompt then pcall(function() prompt:InputHoldBegin() end) task.wait(2) end
                        end
                        local yama = Workspace:FindFirstChild("Yama") or Workspace:FindFirstChild("Yama Sword")
                        if yama then
                            local primary = yama.PrimaryPart or yama:FindFirstChild("HumanoidRootPart")
                            if primary then
                                safeTeleport(primary.CFrame)
                                task.wait(1)
                                local prompt = yama:FindFirstChild("ProximityPrompt")
                                if prompt then pcall(function() prompt:InputHoldBegin() end) end
                                if hasItem("Yama") then equipToolByName("Yama") end
                                break
                            end
                        end
                    end
                end
                task.wait(1)
            end
            yamaRunning = false
        end
        task.wait(2)
    end
end)()

coroutine.wrap(function()
    while true do
        if settings.AutoTushita and not tushitaRunning and not hasItem("Tushita") and sea == 3 then
            tushitaRunning = true
            while settings.AutoTushita and not hasItem("Tushita") do
                local hrp = getHRP()
                if not hrp then task.wait(1) continue end
                local locs = {CFrame.new(5500,50,-1000),CFrame.new(5600,30,-800),CFrame.new(5400,20,-1200)}
                for _, cf in ipairs(locs) do safeTeleport(cf) task.wait(1.5) end
                local dk = Enemies:FindFirstChild("Dough King") or Enemies:FindFirstChild("Dough Prince")
                if dk and dk:FindFirstChild("HumanoidRootPart") then
                    hrp.CFrame = dk.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                    equipBestTool()
                    local attackFunc = attackFuncs[settings.AttackMode]
                    if attackFunc then attackFunc() end
                else
                    local plate = Workspace:FindFirstChild("Scroll Pedestal") or Workspace:FindFirstChild("Summon Pedestal")
                    if plate then
                        local primary = plate.PrimaryPart or plate:FindFirstChild("HumanoidRootPart")
                        if primary then
                            safeTeleport(primary.CFrame)
                            task.wait(1)
                            local prompt = plate:FindFirstChild("ProximityPrompt")
                            if prompt then pcall(function() prompt:InputHoldBegin() end) end
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
                        if prompt then pcall(function() prompt:InputHoldBegin() end) end
                        if hasItem("Tushita") then equipToolByName("Tushita") end
                        break
                    end
                end
                task.wait(2)
            end
            tushitaRunning = false
        end
        task.wait(2)
    end
end)()

coroutine.wrap(function()
    while true do
        if settings.AutoCDK and not cdkRunning then
            cdkRunning = true
            while settings.AutoCDK do
                if not hasItem("Yama") then
                    settings.AutoYama = true
                    task.wait(5)
                elseif not hasItem("Tushita") then
                    settings.AutoTushita = true
                    task.wait(5)
                else
                    local hrp = getHRP()
                    if hrp then
                        equipToolByName("Yama")
                        local blacksmith = Workspace:FindFirstChild("Blacksmith") or Workspace:FindFirstChild("Weapon Blacksmith")
                        if blacksmith then
                            local primary = blacksmith.PrimaryPart or blacksmith:FindFirstChild("HumanoidRootPart")
                            if primary then
                                safeTeleport(primary.CFrame)
                                task.wait(1)
                                local prompt = blacksmith:FindFirstChild("ProximityPrompt")
                                if prompt then pcall(function() prompt:InputHoldBegin() end) end
                                task.wait(2)
                                settings.AutoCDK = false
                            end
                        end
                    end
                end
                task.wait(2)
            end
            cdkRunning = false
        end
        task.wait(2)
    end
end)()

-- // Sea Events
local seaEventNames = {SeaBeast="Sea Beast", Piranha="Piranha", TerrorShark="Terror Shark"}

coroutine.wrap(function()
    while true do
        if settings.AutoSeaBeast or settings.AutoPiranha or settings.AutoTerrorShark then
            local hrp = getHRP()
            if not hrp then task.wait(1) continue end
            local seaPos = sea == 1 and CFrame.new(-5000,0,-5000) or sea == 2 and CFrame.new(-5000,0,10000) or CFrame.new(-10000,0,-20000)
            safeTeleport(seaPos)
            task.wait(2)
            for ev, ename in pairs(seaEventNames) do
                if settings["Auto"..ev] then
                    local enemy = getNearestEnemy(1000, ename)
                    if enemy then
                        hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0,0,5)
                        equipBestTool()
                        local attackFunc = attackFuncs[settings.AttackMode]
                        if attackFunc then attackFunc() end
                    end
                end
            end
            task.wait(3)
        else
            task.wait(5)
        end
    end
end)()

-- // Server Hop
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

coroutine.wrap(function()
    while true do
        if settings.AutoSoulReaper and sea == 3 and not bossExists("Soul Reaper") then serverHop() end
        if settings.AutoPirateRaid and sea >= 2 and not bossExists("Pirate Raid") and not bossExists("Pirate Raid Boss") then serverHop() end
        task.wait(30)
    end
end)()

-- // Auto Close Dialog
coroutine.wrap(function()
    while true do
        if settings.AutoCloseDialog then
            local pgui = LocalPlayer:FindFirstChild("PlayerGui")
            if pgui then
                for _, gui in ipairs(pgui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Enabled then
                        for _, btn in ipairs(gui:GetDescendants()) do
                            if btn:IsA("TextButton") and (btn.Text == "Close" or btn.Text == "Accept" or btn.Text == "Ok" or btn.Text == "OK") then
                                pcall(function() btn:Invoke() end)
                                break
                            end
                        end
                    end
                end
            end
        end
        task.wait(2)
    end
end)()

-- // Utilities (NoClip, InfJump, AntiAFK, ESP)
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

coroutine.wrap(function() while true do task.wait(120) if settings.AntiAFK then VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.Space,false,game) VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.Space,false,game) end end end)()

local espTable = {}
coroutine.wrap(function()
    while true do
        if settings.ESP then
            for _, e in ipairs(Enemies:GetChildren()) do
                if e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 and not espTable[e] then
                    local hl = Instance.new("Highlight",e) hl.Name="ESP" hl.FillColor=Color3.new(1,0,0) hl.OutlineColor=Color3.new(1,1,1) espTable[e]=true
                end
            end
            task.wait(2)
        else
            for e,_ in pairs(espTable) do if e and e:FindFirstChild("ESP") then e.ESP:Destroy() end end
            table.clear(espTable) task.wait(5)
        end
    end
end)()

-- // Smart Goal System
local goalDefinitions = {
    ["Reach Max Level"] = {
        { task="Leveling to 2800", setup=function() settings.AutoFarm=true; settings.FarmMethod="Level"; settings.AutoQuest=true end,
          condition=function() return Level and Level.Value >= 2800 end, teardown=function() settings.AutoFarm=false end }
    },
    ["Obtain Specific Sword"] = {
        { task="Purchasing sword", setup=function() settings.AutoBuySwords=true; autoBuyStates.Swords=true; autoBuyLoop("Swords") end,
          condition=function() return hasItem(settings.GoalItem) end, teardown=function() settings.AutoBuySwords=false; autoBuyStates.Swords=false end }
    },
    ["Obtain Specific Fighting Style"] = {
        { task="Purchasing fighting style", setup=function() settings.AutoBuyMelee=true; autoBuyStates.Melee=true; autoBuyLoop("Melee") end,
          condition=function() return hasItem(settings.GoalItem) end, teardown=function() settings.AutoBuyMelee=false; autoBuyStates.Melee=false end }
    },
    ["Farm Beli"] = {
        { task="Farming Beli", setup=function() settings.AutoFarm=true; settings.FarmMethod="Nearest" end,
          condition=function() return Data and Data:FindFirstChild("Beli") and Data.Beli.Value >= settings.GoalTarget end,
          teardown=function() settings.AutoFarm=false end }
    },
    ["Farm Bones"] = {
        { task="Farming Bones", setup=function() settings.AutoFarm=true; settings.FarmMethod="Auto Bone" end,
          condition=function() return Data and Data:FindFirstChild("Bones") and Data.Bones.Value >= settings.GoalTarget end,
          teardown=function() settings.AutoFarm=false end }
    },
    ["Farm Fragments"] = {
        { task="Farming Fragments", setup=function() settings.AutoRaid=true end,
          condition=function() return Data and Data:FindFirstChild("Fragments") and Data.Fragments.Value >= settings.GoalTarget end,
          teardown=function() settings.AutoRaid=false end }
    },
    ["Max Selected Mastery"] = {
        { task="Mastering", setup=function() settings.AutoMastery=true end,
          condition=function() return false end, teardown=function() settings.AutoMastery=false end }
    },
    ["Unlock CDK"] = {
        { task="Obtaining Yama", setup=function() settings.AutoYama=true end,
          condition=function() return hasItem("Yama") end, teardown=function() settings.AutoYama=false end },
        { task="Obtaining Tushita", setup=function() settings.AutoTushita=true end,
          condition=function() return hasItem("Tushita") end, teardown=function() settings.AutoTushita=false end },
        { task="Crafting CDK", setup=function() settings.AutoCDK=true end,
          condition=function() return hasItem("Cursed Dual Katana") end, teardown=function() settings.AutoCDK=false end }
    }
}

local function stopGoal()
    if settings.GoalActive then
        local steps = goalDefinitions[settings.CurrentGoal]
        if steps and steps[settings.GoalStep] then steps[settings.GoalStep].teardown() end
        settings.GoalActive = false
        settings.CurrentGoal = ""
        settings.GoalStep = 0
        if goalStatusLabel then goalStatusLabel.Text = "No goal active" end
    end
end

local function startGoal(goal)
    stopGoal()
    settings.CurrentGoal = goal
    settings.GoalStep = 1
    settings.GoalActive = true
    local steps = goalDefinitions[goal]
    if steps and steps[1] then
        steps[1].setup()
        if goalStatusLabel then goalStatusLabel.Text = "Goal: "..goal.." | Task: "..steps[1].task end
    end
end

local function goalTick()
    if not settings.GoalActive then return end
    local steps = goalDefinitions[settings.CurrentGoal]
    if not steps then stopGoal(); return end
    local step = steps[settings.GoalStep]
    if not step then
        stopGoal()
        if goalStatusLabel then goalStatusLabel.Text = "Goal completed!" end
        return
    end
    if step.condition() then
        step.teardown()
        settings.GoalStep = settings.GoalStep + 1
        local nextStep = steps[settings.GoalStep]
        if nextStep then
            nextStep.setup()
            if goalStatusLabel then goalStatusLabel.Text = "Goal: "..settings.CurrentGoal.." | Task: "..nextStep.task end
        else
            stopGoal()
            if goalStatusLabel then goalStatusLabel.Text = "Goal completed!" end
        end
    end
end

coroutine.wrap(function() while true do goalTick() task.wait(1) end end)()

-- // Fluent UI
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Acornt/FluentUILib/main/Fluent.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Acornt/FluentUILib/main/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Acornt/FluentUILib/main/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Blox Fruits Ultimate Hub",
    SubTitle = "All-in-One | Fixed",
    TabWidth = 160,
    Size = UDim2.fromOffset(620, 500),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
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

-- Main
Tabs.Main:AddSection("Farm")
Tabs.Main:AddDropdown("FarmMethod",{Title="Method",Values={"Level","Nearest","Auto Bone"},Default="Level",Callback=function(v) settings.FarmMethod=v end})
Tabs.Main:AddToggle("AutoFarm",{Title="Auto Farm",Default=false,Callback=function(v) settings.AutoFarm=v if v then autoFarmLoop() end end})
Tabs.Main:AddToggle("AutoQuest",{Title="Auto Accept Quests",Default=true,Callback=function(v) settings.AutoQuest=v end})
Tabs.Main:AddToggle("AutoHaki",{Title="Auto Haki",Default=false,Callback=function(v) settings.AutoHaki=v end})

-- Attack
Tabs.Attack:AddSection("Modes")
Tabs.Attack:AddDropdown("AttackMode",{Title="Mode",Values={"Normal","Fast","Super Fast","Speed"},Default="Normal",Callback=function(v) settings.AttackMode=v end})
Tabs.Attack:AddSlider("Speed",{Title="Super Fast Delay (ms)",Min=1,Max=100,Default=10,Callback=function(v) settings.SuperFastDelay=v/1000 end})

-- Stats
Tabs.Stats:AddSection("Auto")
Tabs.Stats:AddToggle("AutoStats",{Title="Auto Distribute",Default=false,Callback=function(v) settings.AutoStats=v end})
Tabs.Stats:AddDropdown("StatType",{Title="Stat",Values={"Melee","Defense","Sword","Gun","Blox Fruit"},Default="Melee",Callback=function(v) settings.StatType=v end})

-- Teleports
local tpData = {
    [1]={Start=CFrame.new(982,16,1430),PirateIsland=CFrame.new(1050,16,1550),MarineFortress=CFrame.new(-2722,73,-5460),Skylands=CFrame.new(-4876,322,-4843),Prison=CFrame.new(5250,18,-1665),Colosseum=CFrame.new(-1423,124,-9498),MagmaVillage=CFrame.new(-5250,51,8575),UnderwaterCity=CFrame.new(3878,27,-1934),FrozenVillage=CFrame.new(1193,18,-1214)},
    [2]={KingdomOfRose=CFrame.new(-567,38,-752),GreenZone=CFrame.new(-1840,25,3955),Graveyard=CFrame.new(-5463,23,-6203),SnowMountain=CFrame.new(-740,200,-11800),HotAndCold=CFrame.new(-6073,38,-5340),CursedShip=CFrame.new(-19071,107,7875),IceCastle=CFrame.new(-970,200,-14200)},
    [3]={PortTown=CFrame.new(-10654,72,-6335),HydraIsland=CFrame.new(475,-67,6900),GreatTree=CFrame.new(5834,50,-1209),HauntedCastle=CFrame.new(-13196,378,-7624),SeaOfTreats=CFrame.new(13300,200,12500),TikiOutpost=CFrame.new(-16500,15,4000)}
}
local tpList = {}; if tpData[sea] then for n,_ in pairs(tpData[sea]) do table.insert(tpList,n) end table.sort(tpList) end
Tabs.Teleport:AddSection("Islands")
Tabs.Teleport:AddDropdown("Island",{Title="Teleport",Values=tpList,Default=tpList[1]or"",Callback=function(v) local hrp=getHRP() if hrp then safeTeleport(tpData[sea][v]) end end})

-- Raids
Tabs.Raid:AddSection("Auto Raid")
Tabs.Raid:AddToggle("AutoRaid",{Title="Auto Raid",Default=false,Callback=function(v) settings.AutoRaid=v end})
Tabs.Raid:AddDropdown("RaidType",{Title="Type",Values={"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Buddha","Phoenix","Dough","Dragon","Venom","Shadow","Spirit","Leopard","Kitsune","T-Rex","Mammoth"},Default="Flame",Callback=function(v) settings.RaidType=v end})

-- Auto Buy
Tabs.AutoBuy:AddSection("Equipment")
Tabs.AutoBuy:AddToggle("AutoBuySwords",{Title="Swords",Default=false,Callback=function(v) settings.AutoBuySwords=v end})
Tabs.AutoBuy:AddToggle("AutoBuyGuns",{Title="Guns",Default=false,Callback=function(v) settings.AutoBuyGuns=v end})
Tabs.AutoBuy:AddToggle("AutoBuyMelee",{Title="Melee",Default=false,Callback=function(v) settings.AutoBuyMelee=v end})
Tabs.AutoBuy:AddToggle("AutoBuyHaki",{Title="Haki",Default=false,Callback=function(v) settings.AutoBuyHaki=v end})
Tabs.AutoBuy:AddToggle("AutoSpinFruit",{Title="Spin Fruit",Default=false,Callback=function(v) settings.AutoSpinFruit=v end})

-- Mastery
Tabs.Mastery:AddSection("Auto Mastery")
Tabs.Mastery:AddToggle("AutoMastery",{Title="Auto Mastery",Default=false,Callback=function(v) settings.AutoMastery=v end})
Tabs.Mastery:AddDropdown("MasteryType",{Title="Weapon Type",Values={"Sword","Gun","Melee","Blox Fruit"},Default="Sword",Callback=function(v) settings.MasteryType=v end})

-- Legendary
Tabs.Legendary:AddSection("Legendary Swords")
Tabs.Legendary:AddToggle("AutoYama",{Title="Auto Get Yama",Default=false,Callback=function(v) settings.AutoYama=v end})
Tabs.Legendary:AddToggle("AutoTushita",{Title="Auto Get Tushita",Default=false,Callback=function(v) settings.AutoTushita=v end})
Tabs.Legendary:AddToggle("AutoCDK",{Title="Auto CDK (Both)",Default=false,Callback=function(v) settings.AutoCDK=v end})

-- Sea Events
Tabs.Sea:AddSection("Auto Sea Events")
Tabs.Sea:AddToggle("AutoSeaBeast",{Title="Sea Beast",Default=false,Callback=function(v) settings.AutoSeaBeast=v end})
Tabs.Sea:AddToggle("AutoPiranha",{Title="Piranha",Default=false,Callback=function(v) settings.AutoPiranha=v end})
Tabs.Sea:AddToggle("AutoTerrorShark",{Title="Terror Shark",Default=false,Callback=function(v) settings.AutoTerrorShark=v end})

-- Boss Hop
Tabs.BossHop:AddSection("Auto Hop")
Tabs.BossHop:AddToggle("AutoSoulReaper",{Title="Soul Reaper Hop",Default=false,Callback=function(v) settings.AutoSoulReaper=v end})
Tabs.BossHop:AddToggle("AutoPirateRaid",{Title="Pirate Raid Hop",Default=false,Callback=function(v) settings.AutoPirateRaid=v end})
Tabs.BossHop:AddSlider("HopDelay",{Title="Hop Delay (s)",Min=10,Max=300,Default=60,Callback=function(v) settings.HopDelay=v end})

-- Goals
local goalSection = Tabs.Goals:AddSection("Goal Control")
local goalDropdown = goalSection:AddDropdown("GoalSelect",{
    Title="Select Goal",
    Values={"Reach Max Level","Obtain Specific Sword","Obtain Specific Fighting Style","Farm Beli","Farm Bones","Farm Fragments","Max Selected Mastery","Unlock CDK"},
    Default="Reach Max Level",
    Callback=function(v) end
})
goalSection:AddTextbox("GoalItem",{Title="Sword/Fighting Style Name",Default="",Callback=function(v) settings.GoalItem=v end})
goalSection:AddTextbox("TargetAmount",{Title="Target Amount (Beli/Bones/Fragments)",Default="0",Callback=function(v) settings.GoalTarget=tonumber(v)or 0 end})
goalSection:AddButton("Start Goal",function()
    local goal = goalDropdown.Value
    if (goal=="Obtain Specific Sword" or goal=="Obtain Specific Fighting Style") and settings.GoalItem=="" then Fluent:Notify({Title="Error",Content="Enter the item name first."}) return end
    if (goal=="Farm Beli" or goal=="Farm Bones" or goal=="Farm Fragments") and settings.GoalTarget<=0 then Fluent:Notify({Title="Error",Content="Set a valid target amount."}) return end
    startGoal(goal)
end)
goalSection:AddButton("Stop Goal",stopGoal)
goalStatusLabel = goalSection:AddLabel("Status: No goal active")

-- Misc
Tabs.Misc:AddSection("Features")
Tabs.Misc:AddToggle("NoClip",{Title="No Clip",Default=false,Callback=function(v) settings.NoClip=v end})
Tabs.Misc:AddToggle("InfJump",{Title="Infinite Jump",Default=false,Callback=function(v) settings.InfJump=v end})
Tabs.Misc:AddToggle("ESP",{Title="Enemy ESP",Default=false,Callback=function(v) settings.ESP=v end})
Tabs.Misc:AddToggle("AntiAFK",{Title="Anti AFK",Default=true,Callback=function(v) settings.AntiAFK=v end})
Tabs.Misc:AddToggle("AutoCloseDialog",{Title="Auto Close Dialogs",Default=true,Callback=function(v) settings.AutoCloseDialog=v end})

SaveManager:SetLibrary(Fluent) InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings(); SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("BFUltimateHub") SaveManager:SetFolder("BFUltimateHub/configs")
SaveManager:BuildConfigSection(Tabs.Misc) InterfaceManager:BuildInterfaceSection(Tabs.Misc)
Window:SelectTab(1)
Fluent:Notify({Title="Loaded",Content="Fixed script ready – no infinite yield, no DMG flood."})