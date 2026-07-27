repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer
repeat task.wait()
    pcall(function()
        for i, v in pairs(getconnections(game.Players.LocalPlayer.PlayerGui["Main (minimal)"].ChooseTeam.Container[(getgenv().Team or "Pirates")].Frame.TextButton.Activated)) do
            v.Function()
        end
    end)
until game:GetService("Players").LocalPlayer.Team ~= nil
repeat task.wait() until game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
repeat task.wait() until workspace:FindFirstChild("Map")
require(game:GetService("ReplicatedStorage").Reparent).Unparent = function()
    return nil
end
local uid = tostring(game.Players.LocalPlayer and game.Players.LocalPlayer.UserId or "12345")
local cr = tostring(coroutine.running() or "thread")
local FakeId = (uid:len() >= 4 and uid:sub(2, 4) or "123") .. (cr:len() >= 15 and cr:sub(11, 15) or "45678")
local start_time = tick()
local TweenTick = tick()
local BlacklistedTarget = {}
local ChestCount = 0
local Modules = {
    Players = game.Players,
    Quests = game.ReplicatedStorage:WaitForChild("Quests"),
    GuideModule = game.ReplicatedStorage:WaitForChild("GuideModule"),
    Level = game.Players.LocalPlayer.Data.Level,
    CommF_ = game.ReplicatedStorage.Remotes:WaitForChild("CommF_"),
    AllFruits = {
        ["Rocket Fruit"] = { Name = "Rocket-Rocket", Rarity = "Common", Cost = 5000 },
        ["Spin Fruit"] = { Name = "Spin-Spin", Rarity = "Common", Cost = 7500 },
        ["Blade Fruit"] = { Name = "Blade-Blade", Rarity = "Common", Cost = 30000 },
        ["Spring Fruit"] = { Name = "Spring-Spring", Rarity = "Common", Cost = 60000 },
        ["Bomb Fruit"] = { Name = "Bomb-Bomb", Rarity = "Common", Cost = 80000 },
        ["Smoke Fruit"] = { Name = "Smoke-Smoke", Rarity = "Common", Cost = 100000 },
        ["Spike Fruit"] = { Name = "Spike-Spike", Rarity = "Common", Cost = 180000 },
        ["Flame Fruit"] = { Name = "Flame-Flame", Rarity = "Uncommon", Cost = 250000 },
        ["Ice Fruit"] = { Name = "Ice-Ice", Rarity = "Uncommon", Cost = 350000 },
        ["Sand Fruit"] = { Name = "Sand-Sand", Rarity = "Uncommon", Cost = 420000 },
        ["Dark Fruit"] = { Name = "Dark-Dark", Rarity = "Uncommon", Cost = 500000 },
        ["Eagle Fruit"] = { Name = "Eagle-Eagle", Rarity = "Uncommon", Cost = 550000 },
        ["Diamond Fruit"] = { Name = "Diamond-Diamond", Rarity = "Uncommon", Cost = 600000 },
        ["Light Fruit"] = { Name = "Light-Light", Rarity = "Rare", Cost = 650000 },
        ["Rubber Fruit"] = { Name = "Rubber-Rubber", Rarity = "Rare", Cost = 750000 },
        ["Ghost Fruit"] = { Name = "Ghost-Ghost", Rarity = "Rare", Cost = 940000 },
        ["Magma Fruit"] = { Name = "Magma-Magma", Rarity = "Rare", Cost = 960000 },
        ["Quake Fruit"] = { Name = "Quake-Quake", Rarity = "Legendary", Cost = 1000000 },
        ["Buddha Fruit"] = { Name = "Buddha-Buddha", Rarity = "Legendary", Cost = 1200000 },
        ["Love Fruit"] = { Name = "Love-Love", Rarity = "Legendary", Cost = 1300000 },
        ["Creation Fruit"] = { Name = "Creation-Creation", Rarity = "Legendary", Cost = 1400000 },
        ["Spider Fruit"] = { Name = "Spider-Spider", Rarity = "Legendary", Cost = 1500000 },
        ["Sound Fruit"] = { Name = "Sound-Sound", Rarity = "Legendary", Cost = 1700000 },
        ["Phoenix Fruit"] = { Name = "Phoenix-Phoenix", Rarity = "Legendary", Cost = 1800000 },
        ["Portal Fruit"] = { Name = "Portal-Portal", Rarity = "Legendary", Cost = 1900000 },
        ["Lightning Fruit"] = { Name = "Lightning-Lightning", Rarity = "Legendary", Cost = 2100000 },
        ["Pain Fruit"] = { Name = "Pain-Pain", Rarity = "Legendary", Cost = 2300000 },
        ["Blizzard Fruit"] = { Name = "Blizzard-Blizzard", Rarity = "Legendary", Cost = 2400000 },
        ["Gravity Fruit"] = { Name = "Gravity-Gravity", Rarity = "Mythical", Cost = 2500000 },
        ["Mammoth Fruit"] = { Name = "Mammoth-Mammoth", Rarity = "Mythical", Cost = 2700000 },
        ["T-Rex Fruit"] = { Name = "TRex-TRex", Rarity = "Mythical", Cost = 2700000 },
        ["Dough Fruit"] = { Name = "Dough-Dough", Rarity = "Mythical", Cost = 2800000 },
        ["Shadow Fruit"] = { Name = "Shadow-Shadow", Rarity = "Mythical", Cost = 2900000 },
        ["Venom Fruit"] = { Name = "Venom-Venom", Rarity = "Mythical", Cost = 3000000 },
        ["Control Fruit"] = { Name = "Control-Control", Rarity = "Mythical", Cost = 3200000 },
        ["Gas Fruit"] = { Name = "Gas-Gas", Rarity = "Mythical", Cost = 3200000 },
        ["Spirit Fruit"] = { Name = "Spirit-Spirit", Rarity = "Mythical", Cost = 3400000 },
        ["Leopard Fruit"] = { Name = "Leopard-Leopard", Rarity = "Mythical", Cost = 5000000 },
        ["Yeti Fruit"] = { Name = "Yeti-Yeti", Rarity = "Mythical", Cost = 5000000 },
        ["Kitsune Fruit"] = { Name = "Kitsune-Kitsune", Rarity = "Mythical", Cost = 8000000 },
        ["Dragon Fruit"] = { Name = "Dragon-Dragon", Rarity = "Mythical", Cost = 15000000 },
    },
    AllTablet = {
        "Segment1",
        "Segment3",
        "Segment4",
        "Segment7",
        "Segment10",
    },
    AllTrophies = {
        "Trophy1",
        "Trophy2",
        "Trophy3",
        "Trophy4",
        "Trophy5"
    },
    Pipes = {
        ["Part1"] = "Really black",
        ["Part2"] = "Really black",
        ["Part3"] = "Dusty Rose",
        ["Part4"] = "Storm blue",
        ["Part5"] = "Really black",
        ["Part6"] = "Parsley green",
        ["Part7"] = "Really black",
        ["Part8"] = "Dusty Rose",
        ["Part9"] = "Really black",
        ["Part10"] = "Storm blue",
    },
    MeleeRemotes = {
        ["Black Leg"] = {"BuyBlackLeg"},
        ["Electro"] = {"BuyElectro"},
        ["Fishman Karate"] = {"BuyFishmanKarate"},
        ["Dragon Claw"] = {
            {"BlackbeardReward", "DragonClaw", "1"},
            {"BlackbeardReward", "DragonClaw", "2"}
        },
        ["Superhuman"] = {"BuySuperhuman"},
        ["Death Step"] = {"BuyDeathStep"},
        ["Electric Claw"] = {"BuyElectricClaw"},
        ["Sharkman Karate"] = {"BuySharkmanKarate"},
        ["Dragon Talon"] = {"BuyDragonTalon"},
        ["Godhuman"] = {"BuyGodhuman"},
        ["Sanguine Art"] = {
            {"BuySanguineArt", true},
            {"BuySanguineArt"}
        }
    },
    Materials = {
        ["Conjured Cocoa"] = {"Cocoa Warrior", "Chocolate Bar Battler"},
        ["Ectoplasm"] = {"Ship Deckhand", "Ship Engineer", "Ship Steward"}
    },
    MeleeList = {"Black Leg", "Electro", "Fishman Karate", "Dragon Claw", "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw", "Dragon Talon", "Godhuman", "Sanguine Art"},
    Islands = {
        ["Sea 1"] = {
            ["Pirate Starter"] = CFrame.new(889, 17, 1434),
            ["Marine Starter"] = CFrame.new(-2728, 25, 2056),
            ["Middle Town"] = CFrame.new(-688, 15, 1585),
            ["Jungle"] = CFrame.new(-1614, 37, 146),
            ["Pirate Village"] = CFrame.new(-1173, 45, 3837),
            ["Desert"] = CFrame.new(944, 21, 4373),
            ["Frozen Village"] = CFrame.new(1298, 87, -1344),
            ["Marine Fortress"] = CFrame.new(-4810, 21, 4359),
            ["Colosseum"] = CFrame.new(-1535, 7, -3014),
            ["Lower Skylands"] = CFrame.new(-4814, 718, -2551),
            ["Skylands"] = CFrame.new(-4652, 873, -1754),
            ["Upper Skylands"] = CFrame.new(-7895, 5547, -380),
            ["Prison"] = CFrame.new(4870, 6, 736),
            ["Magma Village"] = CFrame.new(-5290, 9, 8349),
            ["Underwater City"] = CFrame.new(61164, 5, 1820),
            ["Fountain City"] = CFrame.new(5287, 54, 4108),
            ["Jean-Luc Island"] = CFrame.new(-2850, 7, 5355),
        },
        ["Sea 2"] = {
            ["The Cafe"] = CFrame.new(-382, 73, 290),
            ["First Spot"] = CFrame.new(-11, 29, 2771),
            ["Dark Arena"] = CFrame.new(3494, 13, -3259),
            ["Don Swan Mansion"] = CFrame.new(-317, 331, 597),
            ["Don Swan Room"] = CFrame.new(2285, 15, 905),
            ["Green Zone"] = CFrame.new(-2258, 73, -2696),
            ["Graveyard"] = CFrame.new(-5552, 194, -776),
            ["Snow Mountain"] = CFrame.new(752, 408, -5277),
            ["Hot and Cold"] = CFrame.new(-5897, 18, -5096),
            ["Cursed Ship"] = CFrame.new(919, 125, 32869),
            ["Ice Castle"] = CFrame.new(5505, 40, -6178),
            ["Forgotten Island"] = CFrame.new(-3050, 240, -10178),
            ["Remote Island"] = CFrame.new(4816, 8, 2863),
        },
        ["Sea 3"] = {
            ["Mansion"] = CFrame.new(-12471, 374, -7551),
            ["Port Town"] = CFrame.new(-340, 21, 5524),
            ["Great Tree"] = CFrame.new(2205, 22, -6766),
            ["Castle On The Sea"] = CFrame.new(-4980, 314, -3018),
            ["Hydra Island"] = CFrame.new(5294, 1005, 391),
            ["Floating Turtle"] = CFrame.new(-12528, 332, -8658),
            ["Haunted Castle"] = CFrame.new(-9517, 142, 5528),
            ["Ice Cream Land"] = CFrame.new(-843, 66, -10944),
            ["Peanut Land"] = CFrame.new(-2082, 38, -10190),
            ["Cake Land"] = CFrame.new(-1897, 14, -11576),
            ["Candy Cane Land"] = CFrame.new(-1094, 64, -14519),
            ["Chocolate Land"] = CFrame.new(219, 127, -12604),
            ["Tiki Outpost"] = CFrame.new(-16224, 9, 439),
        }
    },
    PortalLocations = {
        Sea_1 = {
            Vector3.new(-7894.62, 5545.49, -380.25),
            Vector3.new(-4607.82, 872.54, -1667.56),
            Vector3.new(61163.85, 11.76, 1819.78),
            Vector3.new(3876.28, 35.11, -1939.32)
        },
        Sea_2 = {
            Vector3.new(-288.46, 306.13, 598),
            Vector3.new(2284.91, 15.15, 905.48),
            Vector3.new(923.21, 126.98, 32852.83),
            Vector3.new(-6508.56, 89.03, -132.84)
        },
        Sea_3 = {
            Vector3.new(-5058.77, 314.52, -3155.88),
            Vector3.new(5756.84, 610.42, -253.93),
            Vector3.new(-12463.87, 374.91, -7523.77),
            Vector3.new(28282.57, 14896.85, 105.1),
            Vector3.new(5661.5322265625, 1013.0907592773438, -334.9649963378906),
            Vector3.new(5319, 23, -93),
            Vector3.new(5651, 1018, -350),
            Vector3.new(28286, 14897, 103)
        }
    },
}

local rz_MAP = workspace:GetAttribute("MAP")
local World = (rz_MAP == "Sea1" and 1) or ((rz_MAP == "Sea2" or rz_MAP == "Dungeons") and 2) or (rz_MAP == "Sea3" and 3) or Modules.Players.LocalPlayer:Kick("YOU GOT KICKED\nREASON: Invalid World")
local rz_MeleeListIndex = (World == 1 and {1, 3}) or (World == 2 and {1, 7}) or (World == 3 and {4, #Modules.MeleeList})
Modules.RealMeleeList = {}
for i = rz_MeleeListIndex[1], rz_MeleeListIndex[2] do
    Modules.RealMeleeList[i] = Modules.MeleeList[i]
end
Modules.HighValueFruits = {}
for i,v in next, Modules.AllFruits do
    if v.Cost >= 1000000 then
        table.insert(Modules.HighValueFruits, i)
    end
end

Modules.Locations = {}
for i,v in next, workspace._WorldOrigin.Locations:GetChildren() do
    if v:IsA("Part") and not v.Name:lower():find("trial") and v.Name ~= "Sea" then
        table.insert(Modules.Locations, v.Name)
    end
end
Modules.Dungeon = {}
for i,v in next, require(game:GetService("ReplicatedStorage").Raids) do
    for i1, v1 in next, v do
        table.insert(Modules.Dungeon, v1)
    end
end

for _,v in pairs({
    "Workspace",
    "Lighting",
    "ReplicatedStorage",
    "HttpService",
    "RunService",
    "Players",
    "TeleportService",
    "CollectionService",
}) do
    Modules[v] = game:GetService(v)
end
for _,v in next, getconnections(game.Players.LocalPlayer.Idled) do
    v:Disable()
end
Modules.HomePointNPC = {}
Modules.NPCs = {}
for _, p in next, {workspace.NPCs, game.ReplicatedStorage.NPCs} do
    for i,v in next, p:GetChildren() do
        if v.Name == "Set Home Point" then
            table.insert(Modules.HomePointNPC, v.HumanoidRootPart)
        end
        local NPCPart = Instance.new("Part")
        NPCPart.Parent = workspace
        NPCPart.Name = v.Name
        NPCPart.Anchored = true
        NPCPart.CanCollide = false
        NPCPart.CFrame = v.HumanoidRootPart.CFrame
        NPCPart.Size = Vector3.new(1,1,1)
        NPCPart.Transparency = 1
        Modules.NPCs[v.Name] = NPCPart
    end
end

local Settings = {
    ["Attack No Animation"] = true,
    ["Tween Pause"] = true,
    ["Attack Mobs"] = true,
    ["Tween Speed"] = 350,
    ["Auto Buso"] = true,
    ["Bypass Teleport"] = false,
    ["Select Stats to Add"] = "Melee",
}
local CountHealthLow = 0
local TeleportTick = tick()
local CanTeleport = false
local TweenEnable = false
local TweenPause = false
local TweenIndex = 0
local LastTweenIndex = 0
local requestEntrance_tick = nil
local last_tele = nil
local bypass_chest_tick = nil
local bypass_chest_tick_2 = nil
local SkypieaPlayers = nil
local Last_Reset = nil
local waittick = nil
local InputJobId = ""
local tween = nil
local Sea1, Sea2, Sea3 = false, false, false
if game.PlaceId == 2753915549 then
    Sea1 = true
elseif game.PlaceId == 4442272183 then
    Sea2 = true
elseif game.PlaceId == 7449423635 then
    Sea3 = true
end
local Functions = {}

function Modules:AddFunction(NAME, REAL_FUNC, SEA)
    if not Functions[NAME] then
        Functions[NAME] = {
            ["Real Function"] = function()
                coroutine.wrap(function()
                    while Settings[NAME] and task.wait() do
                        if not Settings[NAME] then break end
                        local a, b = pcall(REAL_FUNC)
                        if not a then
                        end
                    end
                end)()
            end,
            ["Enable"] = SEA
        }
    end
end
function Modules:Convert_CFrame(x)
    if not x then return end
    return (typeof(x) == "Vector3" and CFrame.new(x)) or (typeof(x) == "CFrame" and x) or (typeof(x) == "Model" and x:GetPivot()) or x.CFrame
end
function Modules:GetDistance(POS_1, POS_2, NO_Y)
    if POS_1 == nil then return end
    if not self.Players.LocalPlayer.Character:FindFirstChild("Humanoid") or self.Players.LocalPlayer.Character.Humanoid.Health <= 0 then
        return 9e9
    end
    if POS_2 == nil then
        POS_2 = Modules.Players.LocalPlayer.Character.HumanoidRootPart
    end
    return (Vector3.new(self:Convert_CFrame(POS_1).X, (NO_Y and 0 or self:Convert_CFrame(POS_1).Y), self:Convert_CFrame(POS_1).Z) 
        - Vector3.new(self:Convert_CFrame(POS_2).X, (NO_Y and 0 or self:Convert_CFrame(POS_2).Y), self:Convert_CFrame(POS_2).Z)).Magnitude
end
function Modules:CheckInventory(Name)
    for i,v in next, Modules.ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory") do
        if v.Name == Name then
            return v
        end
    end
end
function Modules:GetFruitInventory(under1m)
    local max = math.huge
    local select
    for i,v in next, game.ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory") do
        if v.Type == "Blox Fruit" then
            if under1m then
                if v.Value < 1000000 and v.Value <= max then
                    max = v.Value
                    select = v.Name
                end
            else
                if v.Value >= 1000000 and v.Value <= max then
                    max = v.Value
                    select = v.Name
                end
            end
        end
    end
    return select
end
function Modules:CheckFruit(Skid)
    for i,v in next, game.Players.LocalPlayer.Backpack:GetChildren() do
        if v:IsA('Tool') and string.find(v.Name, "Fruit") and not v:GetAttribute("WeaponType") and (not Skid or table.find(self.HighValueFruits, v.Name)) then
            return v
        end
    end
    for i,v in next, game.Players.LocalPlayer.Character:GetChildren() do
        if v:IsA('Tool') and string.find(v.Name, "Fruit") and not v:GetAttribute("WeaponType") and (not Skid or table.find(self.HighValueFruits, v.Name)) then
            return v
        end
    end
end
function Modules:GetPortalTeleport(ni)
    local Portal, Select, Max, Name = {
        {
            ["Sky Arena 1"] = Vector3.new(-4654, 872, -1759),
            ["Sky Arena 2"] = Vector3.new(-7894, 5547, -380),
            ["UnderWater City 1"] = Vector3.new(3876, 35, -1939),
            ["UnderWater City 2"] = Vector3.new(61163, 11, 1819)
        },
        {
            ["Mansion"] = Vector3.new(-288, 305, 613),
            ["Swan Room"] = Vector3.new(2284, 15, 897),
            ["Out Ship"] = Vector3.new(-6518, 83, -145),
            ["In Ship"] = Vector3.new(923, 125, 32883)
        },
        {
            ["Mansion"] = Vector3.new(-12550, 337, -7476),
            ["Castle On The Sea"] = Vector3.new(-5073, 314, -3152),
            ["Hydra Island"] = Vector3.new(5681, 1013, -313),
            ["Temple Of Time"] = Vector3.new(28294, 14896, 103),
        },
    }, Vector3.new(0, 0, 0), math.huge, ""
    for _, v in next, Portal[World] do
        if v ~= Select and (v - ni.Position).Magnitude <= Max then
            Max = (v - ni.Position).Magnitude
            Select = v
            Name = _
        end
    end
    if self:InArea(ni) == self:InArea(Modules.Players.LocalPlayer.Character.PrimaryPart.Position) then
        return false
    end
    if (Sea3 and not CanTeleport) then
        return false
    end
    if self.Players.LocalPlayer.Character.PrimaryPart.CFrame.Y <= -500 or self.Players.LocalPlayer.PlayerGui.Main.TopHUDList.RaidTimer.Visible then
        return false
    end
    if (Select - ni.Position).Magnitude + 250 <= (Modules.Players.LocalPlayer.Character.PrimaryPart.Position - ni.Position).Magnitude then
        return Select, Name
    end
    return false
end
function Modules:InArea(POS)
    for i,v in next, workspace._WorldOrigin.Locations:GetChildren() do
        if (self:Convert_CFrame(POS).Position - v.Position).Magnitude <= v.Mesh.Scale.X then
            return v
        end
    end
    return {Name = ""}
end
if workspace:FindFirstChild("n_TweenPart") then
    workspace.n_TweenPart:Destroy()
end
local n_TweenPart = Instance.new("Part")
n_TweenPart.Name = "n_TweenPart"
n_TweenPart.Size = Vector3.new(1,1,1)
n_TweenPart.Transparency = 1
n_TweenPart.CanCollide = false
n_TweenPart.Anchored = true
n_TweenPart.Parent = workspace
task.spawn(function()
    repeat task.wait() until game.Players.LocalPlayer.Character.PrimaryPart
    n_TweenPart.CFrame = game.Players.LocalPlayer.Character.PrimaryPart.CFrame
    while task.wait() do
        pcall(function()
            if game.Players.LocalPlayer.Character.Head:FindFirstChild("BodyVelocity") then
                if Modules:GetDistance(n_TweenPart.Position, nil, true) <= 200 then
                    game.Players.LocalPlayer.Character.PrimaryPart.CFrame = n_TweenPart.CFrame
                else
                    n_TweenPart.CFrame = game.Players.LocalPlayer.Character.PrimaryPart.CFrame
                end
            end
        end)
    end
end)
function Modules:MiniTween(x, smartmode)
    if self.Players.LocalPlayer and self.Players.LocalPlayer.Character and self.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and self.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and self.Players.LocalPlayer.Character.Humanoid.Health > 0 then
        if smartmode then
            local RealPortal, Name = self:GetPortalTeleport(x)
            if (not requestEntrance_tick or tick() - requestEntrance_tick >= 1) and RealPortal then
                if not requestEntrance_tick then requestEntrance_tick = tick() end
                if tween then tween:Cancel() end
                self.CommF_:InvokeServer("requestEntrance", RealPortal)
                task.wait()
                requestEntrance_tick = tick()
                return
            end
            if (not requestEntrance_tick or tick() - requestEntrance_tick >= 8) and self:GetBypassCFrame(x) and self:InArea(x) ~= self:InArea(self.Players.LocalPlayer.Character.PrimaryPart.CFrame) and self:CanBypassTeleport(x) and self.Players.LocalPlayer.Character.Humanoid.Health > 0 then
                self:BypassTP(x)
                return
            end
        end
        n_TweenPart.CFrame = Modules.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        tween = game:GetService("TweenService"):Create(n_TweenPart, TweenInfo.new(
                    self:GetDistance(x) / Settings['Tween Speed'], Enum.EasingStyle.Linear
                ), {CFrame = x})
        tween:Play()
    end
end
function Modules:CheckItem(ITEM_NAME)
    for i,v in next, game.Players.LocalPlayer.Backpack:GetChildren() do
        if v:IsA('Tool') and (tostring(v) == ITEM_NAME or v.Name == ITEM_NAME or string.find(v.Name, ITEM_NAME)) then
            return v
        end
    end
    for i,v in next, game.Players.LocalPlayer.Character:GetChildren() do
        if v:IsA('Tool') and (tostring(v) == ITEM_NAME or v.Name == ITEM_NAME or string.find(v.Name, ITEM_NAME)) then
            return v
        end
    end
end
function Modules:CheckLegendaryItems()
    if self:CheckItem("God's Chalice") or self:CheckItem("Fist of Darkness") or self:CheckItem("Sweet Chalice") or self:CheckItem("Hallow Essence") or self:CheckItem("Flower1") then
        return true
    end
    return false
end
function Modules:GetSpawnPoint(x)
    for i,v in next, workspace._WorldOrigin.PlayerSpawns.Pirates:GetChildren() do
        if (v.Part.Position - x.Position).Magnitude <= 2500 then
            return v
        end
    end
end
function Modules:GetBypassCFrame(x)
    local Max = math.huge
    local Pos
    for i,v in next, workspace._WorldOrigin.PlayerSpawns.Pirates:GetChildren() do
        if (x.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude >= 3000 and self:GetSpawnPoint(v.Part) ~= self:GetSpawnPoint(game.Players.LocalPlayer.Character.HumanoidRootPart) and (v.Part.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 10000 and (v.Part.Position - x.Position).Magnitude <= Max then
            Max = (v.Part.Position - x.Position).Magnitude
            Pos = v
        end
    end
    return Pos
end
function Modules:GetGift()
    for i,v in next, workspace._WorldOrigin:GetChildren() do
        if v.Name == 'Present' and v:FindFirstChild("Box") and v.Box:FindFirstChild("ProximityPrompt") and v:FindFirstChild("Highlight") then
            return v
        end
    end
end
function Modules:GetBigPresent()
    for i,v in next, workspace:GetChildren() do
        if v.Name == 'PresentPad' and v:FindFirstChild("Box") and v.Box:FindFirstChild("ProximityPrompt") then
            return v
        end
    end
end

function Modules:CanBypassTeleport(x)
    return false
end
function Modules:BypassTP(Target)
    local LocalPlayer = self.Players.LocalPlayer
    local TargetTP
    if LocalPlayer and LocalPlayer.Character.Humanoid.Health > 0 then
        if self:CanBypassTeleport(Target) and self:GetBypassCFrame(Target) then
            TargetTP = self:GetBypassCFrame(Target)
            LocalPlayer.Character.LastSpawnPoint.Disabled = true
            self.CommF_:InvokeServer("SetLastSpawnPoint", TargetTP.Name)
            self.CommF_:InvokeServer("SetSpawnPoint")
            LocalPlayer.Character:PivotTo(TargetTP.Part.CFrame)
            LocalPlayer.Character.Humanoid:ChangeState(15)
            repeat task.wait() until LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0
        end
    end
end


function Modules:CheckCakePrinceSkill()
    for i,v in next, workspace._WorldOrigin:GetChildren() do
        if v.Name == "Ring" or v.Name == "Fist" then
            if self:GetDistance(v.Position) <= 400 then
                return true
            end
        end
    end
    return false
end
function Modules:Tweento(TARGET_CFRAME)
    if self.Players.LocalPlayer and self.Players.LocalPlayer.Character and self.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and self.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and self.Players.LocalPlayer.Character.Humanoid.Health > 0 then
        if self:GetDistance(TARGET_CFRAME) >= 3000 and self:InArea(self.Players.LocalPlayer.Character.PrimaryPart.CFrame).Name == "Submerged Island" and self:InArea(TARGET_CFRAME).Name ~= "Submerged Island" then
            if self:GetDistance(CFrame.new(11427, -2155, 9730)) <= 15 then
                task.wait(1)
                local args = {
                    "InitiateTeleport",
                    "Tiki Outpost"
                }
                game:GetService("ReplicatedStorage").Modules.Net["RF/SubmarineTransportation"]:InvokeServer(unpack(args))   
            else
                self:MiniTween(CFrame.new(11427, -2155, 9730))
            end
            return
        end
        if (self:InArea(TARGET_CFRAME).Name == "Submerged Island" and self:InArea(self.Players.LocalPlayer.Character.PrimaryPart.CFrame).Name ~= "Submerged Island") or (self:InArea(TARGET_CFRAME).Name == "Sealed Cavern" and self:InArea(self.Players.LocalPlayer.Character.PrimaryPart.CFrame).Name ~= "Sealed Cavern") then
            if self:GetDistance(CFrame.new(-16270, 25, 1379).Position) <= 30 then
                task.wait(1)
                local args = {
                    "TravelToSubmergedIsland"
                }
                self.ReplicatedStorage.Modules.Net["RF/SubmarineWorkerSpeak"]:InvokeServer(unpack(args))           
            else
                self:MiniTween(CFrame.new(-16270, 25, 1379), true)
            end
            return
        end
        if not self.Players.LocalPlayer.Character:FindFirstChild("MovementHighlight") then
            local Highlight = Instance.new("Highlight")
            Highlight.Name = "MovementHighlight"
            Highlight.Parent = game.Players.LocalPlayer.Character
            Highlight.FillColor = Color3.fromRGB(255, 0, 0)
            Highlight.FillTransparency = 0.7
        end
        local RealPortal, Name = self:GetPortalTeleport(TARGET_CFRAME)
        if self:InArea(TARGET_CFRAME) ~= self:InArea(self.Players.LocalPlayer.Character.PrimaryPart.CFrame) and RealPortal then
            if not last_tele then last_tele = tick() end
            if tween then tween:Cancel() end
            self.Players.LocalPlayer.Character.LastSpawnPoint.Disabled = true
            if self:GetSpawnPoint(TARGET_CFRAME) then
                self.CommF_:InvokeServer("SetLastSpawnPoint", self:GetSpawnPoint(TARGET_CFRAME).Name)
            end
            Modules.ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", RealPortal)
            last_tele = tick()
            task.wait()
            return
        end
        if (not last_tele or tick() - last_tele >= 8) and self:GetBypassCFrame(TARGET_CFRAME) and self:InArea(TARGET_CFRAME) ~= self:InArea(self.Players.LocalPlayer.Character.PrimaryPart.CFrame) and self:CanBypassTeleport(TARGET_CFRAME) and self.Players.LocalPlayer.Character.Humanoid.Health > 0 then
            task.wait(0.5)
            if tween then tween:Cancel() end
            self:BypassTP(TARGET_CFRAME)
            return
        end
        if Settings["Up Y When Low Health"] then
            local LamTron = (game.Players.LocalPlayer.Character.Humanoid.Health * 100) / game.Players.LocalPlayer.Character.Humanoid.MaxHealth
            if LamTron <= 30 then
                LamTron = (game.Players.LocalPlayer.Character.Humanoid.Health * 100) / game.Players.LocalPlayer.Character.Humanoid.MaxHealth
                if tween then tween:Cancel() end
                game.Players.LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(
                    Modules.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.X,
                    TARGET_CFRAME.Y + 250,
                    Modules.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Z
                )
                return
            end
        end
        TweenTick = tick()
        self.Players.LocalPlayer.Character.LastSpawnPoint.Enabled = true
        game.Players.LocalPlayer.Character.Busy.Value = false
        game.Players.LocalPlayer.Character.Stun.Value = 0
        if self:GetDistance(TARGET_CFRAME, nil, true) <= 50 then
            if tween then
                tween:Cancel()
            end
            game.Players.LocalPlayer.Character.PrimaryPart.CFrame = TARGET_CFRAME
            n_TweenPart.CFrame = TARGET_CFRAME
            return
        else
            if Settings["Same Y"] then
                local SameY = CFrame.new(Modules.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.X,TARGET_CFRAME.Y,Modules.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Z)
                n_TweenPart.CFrame = SameY
                Modules.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = SameY
            end
            if Settings["Up Y"] then
                if self:GetDistance(TARGET_CFRAME, nil, true) >= 100 then
                    local UpY = CFrame.new(Modules.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.X,TARGET_CFRAME.Y + 120, Modules.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Z)
                    n_TweenPart.CFrame = UpY
                    Modules.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = UpY
                end
            end
            local TweenTarget = CFrame.new(TARGET_CFRAME.X, (Settings["Up Y"] and TARGET_CFRAME.Y + 120 or TARGET_CFRAME.Y), TARGET_CFRAME.Z)
            tween = game:GetService("TweenService"):Create(n_TweenPart, 
            (self:GetDistance(TweenTarget, nil, true) <= 400 and TweenInfo.new(
                self:GetDistance(TweenTarget, nil, true) / Settings['Tween Speed'] / 1.5, Enum.EasingStyle.Linear
            ) or TweenInfo.new(
                self:GetDistance(TweenTarget, nil, true) / Settings['Tween Speed'], Enum.EasingStyle.Linear
            )), {CFrame = TweenTarget})
            tween:Play()
        end
    end
end
task.spawn(function()
    while task.wait() do
        pcall(function()
            if tween and tween.PlaybackState == Enum.PlaybackState.Playing then
                Modules:EnableNoClip(true)
            elseif tween and tick() - TweenTick >= 2 then
                Modules:EnableNoClip(false)
            end
        end)
    end
end)
function Modules:EnableNoClip(boolean)
    if boolean then
        for i,v in next, Modules.Players.LocalPlayer.Character:GetDescendants() do
            if v:IsA('BasePart') or v:IsA("Part") then
                v.CanCollide = false
            end
        end
        if not Modules.Players.LocalPlayer.Character.Head:FindFirstChild("BodyVelocity") then
            local BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.Parent = Modules.Players.LocalPlayer.Character.Head
            BodyVelocity.Velocity = Vector3.new(0,0,0)
            BodyVelocity.P = 1500
            BodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
        end
    else
        Modules.Players.LocalPlayer.Character.Humanoid:ChangeState()
        Modules.Players.LocalPlayer.Character.Humanoid:SetStateEnabled(5, true)
        if self.Players.LocalPlayer.Character:FindFirstChild("MovementHighlight") then
            self.Players.LocalPlayer.Character.MovementHighlight:Destroy()
        end
        if Modules.Players.LocalPlayer.Character.Head:FindFirstChild("BodyVelocity") then
            Modules.Players.LocalPlayer.Character.Head:FindFirstChild("BodyVelocity"):Destroy()
        end
    end
end
function Modules:CheckRace()
    local v1 = self.CommF_:InvokeServer("Wenlocktoad", "1")
    local v2 = self.CommF_:InvokeServer("Alchemist", "1")
    if self.Players.LocalPlayer.Character:FindFirstChild("RaceTransformed") then
        return "V4"
    end
    return (v1 == -2 and "V3") or (v2 == -2 and "V2") or "V1"
end
function Modules:GetWeaponName(TYPE)
    for i,v in next, game.Players.LocalPlayer.Backpack:GetChildren() do
        if v:IsA("Tool") and v.ToolTip == TYPE then
            return v.Name
        end
    end
    for i,v in next, game.Players.LocalPlayer.Character:GetChildren() do
        if v:IsA("Tool") and v.ToolTip == TYPE then
            return v.Name
        end
    end
end
function Modules:EquipTool(NAME)
    pcall(function()
        local MMB = Modules.Players.LocalPlayer.Backpack:FindFirstChild(NAME)
        if MMB then
            Modules.Players.LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(MMB)
        end
    end)
end
function Modules:EquipWeapon()
    pcall(function()
        local MMB = Modules.Players.LocalPlayer.Backpack:FindFirstChild(self:GetWeaponName((Settings["Select Tool"] or "Melee")))
        if MMB then 
            Modules.Players.LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(MMB)
        end
    end)
end
function Modules:GetFruit()
    for _,v in next, workspace:GetChildren() do
        if (v:IsA("Model") or v:IsA("Tool")) and string.find(v.Name, "Fruit") and v.Parent and v:FindFirstChild("Handle") then
            return v
        end
    end
end
function Modules:SendKey(Key, Hold)
    game:GetService("VirtualInputManager"):SendKeyEvent(true,Key,false,game)
    task.wait((Hold or 0.1))
    game:GetService("VirtualInputManager"):SendKeyEvent(false,Key,false,game)
end
function Modules:SpamAllSkill()
    for i,v in next, game.Players.LocalPlayer.PlayerGui.Main.Skills:GetChildren() do
        if v:IsA("Frame") and v.Name ~= "Container" then
            for i1, v1 in next, v:GetChildren() do
                if v1:IsA("Frame") and v1.Name ~= "Template" and v1.Cooldown.AbsoluteSize.X <= 5 and v1.Title.TextColor3 == Color3.fromRGB(255,255,255) then
                    self:EquipTool(v.Name)
                    task.wait()
                    self:SendKey(v1.Name)
                end
            end
        end
    end
end
function Modules:IsAlive(v)
    return v and v.Parent and not v:FindFirstChild("VehicleSeat") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart")
end
function Modules:GetBladeHits(RANGE)
    local BLADE_HITS = {}
    if Settings["Attack Mobs"] then
        for i,v in next, workspace.Enemies:GetChildren() do
            if v:IsA("Model") and self:IsAlive(v) and self:GetDistance(v.HumanoidRootPart.Position) <= (RANGE or 67) then
                BLADE_HITS[#BLADE_HITS + 1] = v
            end
        end
    end
    if Settings["Attack Players"] then
        for i,v in next, workspace.Characters:GetChildren() do
            if v.Name ~= game.Players.LocalPlayer.Name and v:IsA("Model") and self:IsAlive(v) and self:GetDistance(v.HumanoidRootPart.Position) <= (RANGE or 67) then
                BLADE_HITS[#BLADE_HITS + 1] = v
            end
        end
    end
    return BLADE_HITS
end
function Modules:GetWeaponType(ToolTip)
    for _, O in next, {game.Players.LocalPlayer.Backpack, game.Players.LocalPlayer.Character} do
        for i,v in next, O:GetChildren() do
            if v:IsA("Tool") and v.ToolTip == (ToolTip or "Melee") then
                return v
            end
        end
    end
end
function Modules:SingleAttack(mob)
    if getgenv().SingleAttack then
        local EnemyList = {}
        local CurrentTool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if not CurrentTool then return end
        if CurrentTool.ToolTip == "Blox Fruit" then
            local left = CurrentTool:FindFirstChild("LeftClickRemote")
            if left and left:IsA("RemoteEvent") then
                left:FireServer(Vector3.new(0, -500, 0), 1, true)
                task.wait(0.03)
                left:FireServer(false)
            end
        else
            table.insert(EnemyList, {mob, mob.Head})
            local EnemyHit = EnemyList[1][2]
            Modules.ReplicatedStorage.Modules.Net:WaitForChild("RE/RegisterAttack"):FireServer(0)
            Modules.ReplicatedStorage.Modules.Net:WaitForChild("RE/RegisterHit"):FireServer(EnemyHit, EnemyList, nil, FakeId)
        end
    end
end
function Modules:StartAttack()
    if getgenv().SingleAttack then return end
    local BladeHits = self:GetBladeHits()
    local EnemyList = {}
    if #BladeHits > 0 then
        local CurrentTool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if not CurrentTool then return end
        if CurrentTool.ToolTip == "Blox Fruit" then
            local left = CurrentTool:FindFirstChild("LeftClickRemote")
            if left and left:IsA("RemoteEvent") then
                left:FireServer(Vector3.new(0, -500, 0), math.random(1, 3), true)
                task.wait(0.01)
                left:FireServer(false)
            end
        else
            for i, mob in next, BladeHits do
                if mob and self:IsAlive(mob) and mob:FindFirstChild("Head") then
                    table.insert(EnemyList, {mob, mob.Head})
                end
            end
            local EnemyHit = EnemyList[1][2]
            Modules.ReplicatedStorage.Modules.Net:WaitForChild("RE/RegisterAttack"):FireServer(0)
            Modules.ReplicatedStorage.Modules.Net:WaitForChild("RE/RegisterHit"):FireServer(EnemyHit, EnemyList, nil, FakeId)
        end
    end
end
function Modules:CheckNotify(aa)
    for r, v in pairs(self.Players.LocalPlayer.PlayerGui.Notifications:GetChildren()) do
        if v and v.Parent and v:IsA("TextLabel") and v.Text and string.find(string.lower(v.Text), aa) then
            return v
        end
    end
end
function Modules:EnableBuso()
    if not Modules.Players.LocalPlayer.Character:FindFirstChild('HasBuso') then
        Modules.ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
    end
end
function Modules:SidePart(v, Ngu)
    local Distance = self:GetDistance(v.PrimaryPart.Position, nil, true)
    if v:FindFirstChild("Humanoid") then
        v.Humanoid.WalkSpeed = Distance <= 50 and 0 or 350
        v.Humanoid.JumpPower = 0
        v.Humanoid.AutoRotate = false
        v.HumanoidRootPart.CanCollide = false
        v.Head.CanCollide = false
    else
        return
    end
    for i,v in next, v:GetChildren() do
        if v.ClassName == "Shirt" or v.ClassName == "Pants" then
            v:Destroy()
        end
        if v:IsA("MeshPart") then
            v.Transparency = 1
            v.CanCollide = false
        end
        if v:IsA("Part") then
            v.CanCollide = false
        end
    end
    if v.Humanoid:FindFirstChild("Animator") then
        v.Humanoid.Animator:Destroy()
    end
    if Distance <= 50 and not v.HumanoidRootPart:FindFirstChild('Lock') then
        local Lock = Instance.new('BodyVelocity')
        Lock.Name = "Lock"
        Lock.Parent = v.HumanoidRootPart
        Lock.Velocity = Vector3.new(0,0,0)
        Lock.MaxForce = Vector3.new(10000, 10000, 10000)
    end
end
function Modules:DetectNearPlayersInCFrame(x)
    for i,v in next, workspace.Characters:GetChildren() do
        if v.Name ~= Modules.Players.LocalPlayer.Name and self:IsAlive(v) then
            if self:GetDistance(v.HumanoidRootPart.Position) <= x then
                return true
            end
        end
    end
    return false
end
function Modules:GetElite()
    for _, p in next, {workspace.Enemies, game.ReplicatedStorage} do
        for i,v in next, p:GetChildren() do
            if v and v.Parent and table.find({"Urban","Deandre","Diablo"}, v.Name) and v:IsA("Model") and self:IsAlive(v) then
                return v
            end
        end
    end
end
function Modules:CirclePos(TARGET_PRIMARYPART, RADIUS, TotalEnemy)
    if not TARGET_PRIMARYPART:FindFirstChild("Angle") then
        local Angle = Instance.new("IntValue")
        Angle.Parent = TARGET_PRIMARYPART
        Angle.Name = "Angle"
        Angle.Value = 0
    end
    TARGET_PRIMARYPART.Angle.Value = TARGET_PRIMARYPART.Angle.Value + 30 / TotalEnemy * 1.5
    local x = math.sin(math.rad(TARGET_PRIMARYPART.Angle.Value)) * RADIUS
    local z = math.cos(math.rad(TARGET_PRIMARYPART.Angle.Value)) * RADIUS
    return CFrame.new(TARGET_PRIMARYPART.Position + Vector3.new(x, 0, z) + Vector3.new(0, 0, 0))
end
function Modules:BringMob()
    local Bring_Range = 350
    if BringMobName and BringMob and BringMobName:FindFirstChild("HumanoidRootPart") then
        local Bring_Pos = BringMobName.HumanoidRootPart
        self:SidePart(BringMobName)
        local Enemies = workspace.Enemies:GetChildren()
        if #Enemies > 1 then
            for i = 1, #Enemies do
                local Mob = Enemies[i]
                if Mob and Mob.Name == BringMobName.Name and Mob ~= BringMobName and self:IsAlive(Mob) and self:GetDistance(Mob.PrimaryPart.Position) <= Bring_Range and isnetworkowner(Mob.HumanoidRootPart) and self:GetDistance(Mob.PrimaryPart.Position, nil, true) >= 5 then
                    if self:GetDistance(Mob.PrimaryPart.Position, nil, true) <= 100 then
                        Mob:SetPrimaryPartCFrame(Bring_Pos.CFrame)
                    end
                    Mob.Humanoid:MoveTo(Bring_Pos.Position)
                    self:SidePart(Mob, Bring_Pos)
                end
            end
        end
    end
end
function Modules:GetMob(NAME, FINDMORE, DISTANCE)
    local selecttarget, max = nil, math.huge
    for _,v in next, workspace.Enemies:GetChildren() do
        if ((typeof(NAME) == "table" and table.find(NAME, v.Name)) or (typeof(NAME) == "string" and v.Name == NAME)) and self:IsAlive(v) then
            if self:GetDistance(v.HumanoidRootPart.Position) <= max and self:GetDistance(v.HumanoidRootPart.Position) <= (DISTANCE or math.huge) then
                max = self:GetDistance(v.HumanoidRootPart.Position)
                selecttarget = v
            end
        end
    end
    if FINDMORE then
        for _,v in next, game.ReplicatedStorage:GetChildren() do
            if ((typeof(NAME) == "table" and table.find(NAME, v.Name)) or (typeof(NAME) == "string" and v.Name == NAME)) and self:IsAlive(v) then
                if self:GetDistance(v.HumanoidRootPart.Position) <= max and self:GetDistance(v.HumanoidRootPart.Position) <= (DISTANCE or math.huge) then
                    max = self:GetDistance(v.HumanoidRootPart.Position)
                    selecttarget = v
                end
            end
        end
    end
    return selecttarget
end
function Modules:TweenObject(object, pos,speed)
    local distance = self:GetDistance(object.Position)
    local tween1 = game:GetService("TweenService"):Create(object,TweenInfo.new(
        distance / (speed or 250), Enum.EasingStyle.Linear
    ), {CFrame = pos})
    tween1:Play()
end
function Modules:CheckSafeZone(x)
    for i,v in next, workspace._WorldOrigin.SafeZones:GetChildren() do
        if v and self:GetDistance(x.Position, v.Position) <= 1000 then
            return true
        end
    end
    return false
end
function Modules:GetMasteryCurrentTool(Type)
    for i,v in next, self.Players.LocalPlayer.Character:GetChildren() do
        if v:IsA("Tool") and v.ToolTip == Type then
            return v.Level.Value
        end
    end
    for i,v in next, self.Players.LocalPlayer.Backpack:GetChildren() do
        if v:IsA("Tool") and v.ToolTip == Type then
            return v.Level.Value
        end
    end
    return 0
end
function Modules:KillMobs(TARGET, NAME_TOGGLE, CUSTOM_POSITON)
    local v = self:GetMob((typeof(TARGET) == "Instance" and TARGET.Name or TARGET), true)
    if v and self:IsAlive(v) then
        repeat task.wait()
            if typeof(NAME_TOGGLE) == "function" and NAME_TOGGLE() == true then break end
            if (typeof(NAME_TOGGLE) == "string" and not Settings[NAME_TOGGLE]) or not v or not self:IsAlive(v) then break end
            Modules:EquipWeapon()
            Modules:EnableBuso()
            BringMobName = v
            BringMob = true
            if self:CheckCakePrinceSkill() then
                Modules:Tweento(v.HumanoidRootPart.CFrame * CFrame.new(0, 300, 0))
            else
                if Settings["Select Tool"] == "Blox Fruit" then
                    Modules:Tweento(CUSTOM_POSITON or v.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0))
                else
                    Modules:Tweento(CUSTOM_POSITON or v.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                end
            end
        until not v or not v.Parent or not Modules:IsAlive(v) or not Settings[NAME_TOGGLE] 
        BringMob = false
        BringMobName = nil
    end
end
function Modules:GetQuest()
    local Level = Modules.Players.LocalPlayer.Data.Level
    local Name, NameQuest, Id = "", "", 0
    local LevelReq = 0
    if Sea1 and Level.Value >= 700 then
        return "Galley Captain", "FountainQuest", 2
    elseif Sea2 and Level.Value >= 1500 then
        return "Water Fighter", "ForgottenQuest", 2
    else
        for i,v in next, require(Modules.Quests) do
            for ID, v1 in next, v do
                local LvReq = v1.LevelReq
                for i1,v2 in next, v1.Task do
                    if Level.Value >= LvReq and LvReq >= LevelReq and not table.find({"CitizenQuest", "BartiloQuest", "MarineQuest", "Trainees"}, i) and v1.Task[i1] >= 5 then
                        LevelReq = LvReq
                        LevelReq, Name, NameQuest, Id = LvReq, i1, i, ID
                    end
                end
            end
        end
    end
    return Name, NameQuest, Id
end
function Modules:GetCFrameQuest()
    for i,v in next, self.NPCs do
        if v.Name == require(self.GuideModule).Data.LastClosestNPC then
            return v.CFrame
        end
    end
end
function Modules:GetLastQuest()
    local QuestData
    for i,v in next, require(self.GuideModule).Data do
        if i == "QuestData" then
            QuestData = v
            break
        end
    end
    if QuestData then
        for i,v in next, QuestData.Task do
            return i
        end
    end
    return nil
end
function Modules:GetSeaBeast()
    for i,v in next, workspace.SeaBeasts:GetChildren() do
        if v.Name == "SeaBeast1" and self:GetDistance(v.HumanoidRootPart.Position) <= 2000 then
            if v:FindFirstChild("Health") and v.Health.Value > 0 then
                return v
            end
        end
    end
end
function Modules:GetYourBoat()
    for i,v in next, workspace.Boats:GetChildren() do
        if v and v.Parent and v:FindFirstChild("Humanoid") and v.Humanoid.Value > 0 and v:WaitForChild("Owner").Value == game.Players.LocalPlayer then
            return v
        end
    end
end
function Modules:GetSeaBeastPosition(x)
    if (Vector3.new(0, x.HumanoidRootPart.Position.Y, 0) - Vector3.new(0, workspace.Map["WaterBase-Plane"].Position.Y, 0)).Magnitude <= 175 then
        return x.HumanoidRootPart.CFrame * CFrame.new(0, 300, 0)
    else
        return CFrame.new(x.HumanoidRootPart.CFrame.X, workspace.Map["WaterBase-Plane"].Y + 200, x.HumanoidRootPart.CFrame.Z)
    end
end
function Modules:GetCDKProgress()
    local CDKPuzzle = {
        Evil = 0,
        Good = 0
    }
    for i,v in next, game.ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "Progress", "Good") do
        CDKPuzzle[i] = v
    end
    return CDKPuzzle
end
function Modules:GetCDKProcess()
    local CDKProgress = self:GetCDKProgress()
    local Evil, Goon = CDKProgress.Evil, CDKProgress.Good
    if Evil ~= -2 and Evil ~= 3 and Evil ~= 4 then
        if Evil == 2 or Evil == -5 then
            return "Hell Dimension Quest"
        elseif Evil == 1 or Evil == -4 then
            return "Haze Quest"
        elseif Evil == 0 or Evil == -3 then
            return "Die Quest"
        end
    else
        if Goon == 2 or Goon == -5 then
            return "Heavenly Dimension Quest"
        elseif Goon == 1 or Goon == -4 then
            return "Raid Castle Quest"
        elseif Goon == 0 or Goon == -3 then
            return "Boat Quest"
        end
    end
    return "None"
end
function Modules:GetPedestal()
    local Pedestal
    local CDKProgress = self:GetCDKProgress()
    if CDKProgress.Evil == 3 then
        Pedestal = workspace.Map.Turtle.Cursed.Pedestal2
    elseif (CDKProgress.Good == 3 or CDKProgress.Good == 4) and workspace.Map.Turtle.Cursed.Pedestal1.ProximityPrompt.Enabled then
        Pedestal = workspace.Map.Turtle.Cursed.Pedestal1
    end
    return Pedestal
end
function Modules:HazePos()
    local HazeQuestName = {}
    local Max = math.huge
    local Pos
    for i,v in next, self.Players.LocalPlayer.QuestHaze:GetChildren() do
        if v.Value > 0 then
            table.insert(HazeQuestName, v)
        end
    end
    if #HazeQuestName > 0 then
        for i,v in next, HazeQuestName do
            for _,v1 in next, workspace.NightHubCache.MobSpawns:GetChildren() do
                if v.Name == v1.Name then
                    local Distance = self:GetDistance(v1.Position)
                    if Distance <= Max then
                        Max = Distance
                        Pos = v1.Position
                    end
                end
            end
        end
    end
    return Pos
end
function Modules:HazeMobs()
    local Max = math.huge
    local Select
    for i,v in next, workspace.Enemies:GetChildren() do
        if v:IsA("Model") and self:IsAlive(v) and v:FindFirstChild('HazeESP') then
            if self:GetDistance(v.HumanoidRootPart.Position) <= Max then
                Max = self:GetDistance(v.HumanoidRootPart.Position)
                Select = v
            end
        end
    end
    for i,v in next, self.ReplicatedStorage:GetChildren() do
        if v:IsA("Model") and self:IsAlive(v) and v:FindFirstChild('HazeESP') then
            if self:GetDistance(v.HumanoidRootPart.Position) <= Max then
                Max = self:GetDistance(v.HumanoidRootPart.Position)
                Select = v
            end
        end
    end
    return Select
end
function Modules:GetMobInCFrame(Pos, Range)
    for i,v in next, workspace.Enemies:GetChildren() do
        if v:IsA("Model") and self:IsAlive(v) and self:GetDistance(v.HumanoidRootPart.Position, Pos) <= (Range or 1000) then
            return v
        end
    end
end
function Modules:GetShirneDungeon()
    for i,v in next, workspace.Map.Dungeon:GetChildren() do
        if v:IsA("Model") and v:FindFirstChild("Props") then
            for i1 ,v1 in next, v.Props:GetChildren() do
                if v1:GetAttribute("KitsuneMarkActive") == true then
                    return v1
                end
            end
        end
    end
end
function Modules:GetDungeonWorldMob()
    local maxdistance = math.huge
    local select
    for i,v in next, workspace.Enemies:GetChildren() do
        if v and v.Name ~= "Blank Buddy" and v.Parent and self:IsAlive(v) and self:GetDistance(v.PrimaryPart.Position) <= 500 and self:GetDistance(v.PrimaryPart.Position) <= maxdistance then
            maxdistance = self:GetDistance(v.PrimaryPart.Position)
            select = v
        end
    end
    return select
end
function Modules:GetDungeonWorldDoors()
    local max = -math.huge
    local select
    for i,v in next, workspace.Map.Dungeon:GetChildren() do
        if v:IsA("Model") and #v.Name <= 2 and tonumber(v.Name) >= max and self:GetDistance(v:GetPivot().Position) <= 800 then
            max = tonumber(v.Name)
            select = v
        end
    end
    return select
end
function Modules:GetZombieGuitarPuzzle()
    local AllZombie = {}
    for i,v in next, workspace.Enemies:GetChildren() do
        if v.Name == "Living Zombie" and v.Parent and self:IsAlive(v) then
            table.insert(AllZombie, v)
        end
    end
    return AllZombie
end
function Modules:DoCDKQuest()
    local Process = self:GetCDKProcess()
    if Process == "Die Quest" then
        if self:GetMob("Forest Pirate", true) then
            local v = self:GetMob("Forest Pirate", true)
            self:Tweento(v.HumanoidRootPart.CFrame)
        else
            self:Tweento(CFrame.new(-13234, 520, -6800))
        end
    elseif Process == "Haze Quest" then
        if self:HazeMobs() then
            local v = self:HazeMobs()
            repeat
                task.wait()
                if Process ~= "Haze Quest" then break end
                self:KillMobs(v, "Auto Dual Cursed Katana")
            until not v or not v.Parent or not self:IsAlive(v) or not Settings["Auto Dual Cursed Katana"] or Process ~= "Haze Quest"
        else
            self:Tweento(CFrame.new(self:HazePos()) * CFrame.new(0, 20, 0))
        end
    elseif Process == "Hell Dimension Quest" then
        local HellDismension = workspace._WorldOrigin.Locations["Hell Dimension"]
        if HellDismension and self:GetDistance(HellDismension.Position) <= 2000 then
            if workspace.Map:FindFirstChild("HellDimension") and workspace.Map:FindFirstChild("HellDimension").Exit.BrickColor == BrickColor.new("Olivine") then
                self:Tweento(workspace.Map.HellDimension.Exit.CFrame)
                return
            end
            local v = self:GetMobInCFrame(HellDismension.Position)
            if v then
                repeat
                    task.wait()
                    self:KillMobs(v, "Auto Dual Cursed Katana")
                until not v or not v.Parent or not self:IsAlive(v) or not Settings["Auto Dual Cursed Katana"] or Process ~= "Hell Dimension Quest"
            else
                if workspace.Map:FindFirstChild("HellDimension") then
                    for i,v in next, workspace.Map:FindFirstChild("HellDimension"):GetChildren() do
                        if string.find(v.Name, "Torch") then
                            if v.ProximityPrompt.Enabled then
                                if self:GetDistance(v.Position) <= 15 then
                                    fireproximityprompt(v.ProximityPrompt)
                                else
                                    self:Tweento(v.CFrame)
                                end
                            end
                        end
                    end
                end
            end
        else
            if self:GetMob("Soul Reaper", true) then
                local v = self:GetMob("Soul Reaper", true)
                repeat
                    task.wait()
                    if self:CheckNotify("loading...") then
                        break
                    end
                    Process = self:GetCDKProcess()
                    self:Tweento(v.HumanoidRootPart.CFrame)
                until not v or not v.Parent or not self:IsAlive(v) or not Settings["Auto Dual Cursed Katana"] or Process ~= "Hell Dimension Quest" or self:CheckNotify("loading...")
            else
                local _1, _2, RandomCount, TimeRandom, MaxRandom = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones", "Check")
                if RandomCount > 0 and _1 >= 50 then
                    if self:CheckItem("Hallow Essence") then
                        self:EquipTool("Hallow Essence")
                        self:Tweento(CFrame.new(-8932, 142, 6063))
                    else    
                        if self:GetDistance(CFrame.new(-8934, 142, 6036)) <= 50 then
                            self.CommF_:InvokeServer("Bones", "Buy", 1, 1)
                        else
                            self:Tweento(CFrame.new(-8934, 142, 6036))
                        end
                    end
                end
            end
        end
    elseif Process == "Boat Quest" then
        for i,v in next, workspace:GetChildren() do
            if Process ~= "Boat Quest" or not Settings["Auto Dual Cursed Katana"] then break end
            if v.Name == "Luxury Boat Dealer" and not v:GetAttribute("Dit") then
                repeat task.wait()
                    Process = self:GetCDKProcess()
                    if Process ~= "Boat Quest" or not Settings["Auto Dual Cursed Katana"] then break end
                    self:Tweento(v.CFrame)
                until v:GetAttribute("Dit") or Process ~= "Boat Quest" or self:GetDistance(v.Position) <= 15
                Process = self:GetCDKProcess() 
                self.CommF_:InvokeServer("CDKQuest","BoatQuest", workspace.NPCs:FindFirstChild("Luxury Boat Dealer"))
                self.CommF_:InvokeServer("CDKQuest","BoatQuest", workspace.NPCs:FindFirstChild("Luxury Boat Dealer"), "Check")
                task.wait(0.5)
                v:SetAttribute("Dit", true)
            end
        end
    elseif Process == "Raid Castle Quest" then
        if not self:GetMobInCFrame(CFrame.new(-5541, 314, -2961)) then
            self:Tweento(CFrame.new(-5043, 548, -3044))
        else
            local v = self:GetMobInCFrame(CFrame.new(-5541, 314, -2961))
            if v then
                repeat
                    task.wait()
                    if Process ~= "Raid Castle Quest" then break end
                    self:KillMobs(v, "Auto Dual Cursed Katana")
                until not v or not v.Parent or not self:IsAlive(v) or not Settings["Auto Dual Cursed Katana"] or Process ~= "Raid Castle Quest"
            end
        end
    elseif Process == "Heavenly Dimension Quest" then
        local HeavenlyDimension = workspace._WorldOrigin.Locations["Heavenly Dimension"]
        if HeavenlyDimension and self:GetDistance(HeavenlyDimension.Position) <= 2000 then
            if workspace.Map:FindFirstChild("HeavenlyDimension") and workspace.Map:FindFirstChild("HeavenlyDimension").Exit.BrickColor == BrickColor.new("Cloudy grey") then
                self:Tweento(workspace.Map.HeavenlyDimension.Exit.CFrame)
                return
            end
            if self:DetectNearPlayersInCFrame(1000) then
                return
            end
            local v = self:GetMobInCFrame(HeavenlyDimension.Position)
            if v then
                repeat
                    task.wait()
                    self:KillMobs(v, "Auto Dual Cursed Katana")
                until not v or not v.Parent or not self:IsAlive(v) or not Settings["Auto Dual Cursed Katana"] or Process ~= "Heavenly Dimension Quest"
            else
                if workspace.Map:FindFirstChild("HeavenlyDimension") then
                    for i,v in next, workspace.Map:FindFirstChild("HeavenlyDimension"):GetChildren() do
                        if string.find(v.Name, "Torch") then
                            if v.ProximityPrompt.Enabled then
                                if self:GetDistance(v.Position) <= 30 then
                                    fireproximityprompt(v.ProximityPrompt)
                                else
                                    self:Tweento(v.CFrame)
                                end
                            end
                        end
                    end
                end
            end
        else
            if self:GetMob("Cake Queen", true) then
                local v = self:GetMob("Cake Queen", true)
                repeat
                    task.wait()
                    if self:CheckNotify("loading...") or not self:IsAlive(v) then
                        break
                    end
                    self:KillMobs(v, "Auto Dual Cursed Katana")
                until not v or not v.Parent or not self:IsAlive(v) or not Settings["Auto Dual Cursed Katana"] or Process ~= "Heavenly Dimension Quest" or self:CheckNotify("loading...")
            elseif not self:CheckNotify("loading...") and not self:GetMob("Cake Queen", true) then
                self:Tweento(CFrame.new(-731.2034301757812, 381.5658874511719, -11198.4951171875))
            end
        end
    end
end
function Modules:GetChest()
    local distance = math.huge
    local a
    local Chest = game:GetService("CollectionService"):GetTagged("_ChestTagged")
    for i = 1, #Chest do
        local v = (Chest[i]:GetPivot().Position - self.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        if Chest[i].Parent and Chest[i]:FindFirstChild("TouchInterest") and not Chest[i]:GetAttribute("IsDisabled") and v <= distance then
            distance = v
            a = Chest[i]
        end
    end
    return a
end
function Modules:IsRaiding(x)
    for i,v in next, workspace._WorldOrigin.Locations:GetChildren() do
        if v.Name == "Island 1" and self:GetDistance(x.Position, v.Position) <= 10000 then
            return true
        end
    end
    return false
end
function Modules:CreateCacheFolder()
    local AllSpawnPoint = {}
    if not workspace:FindFirstChild("NightHubCache") then
        local Folder = Instance.new("Folder", workspace)
        Folder.Name = "NightHubCache"
    end
    repeat task.wait() until workspace:FindFirstChild("NightHubCache")
    local MobSpawns = Instance.new("Folder", workspace.NightHubCache)
    MobSpawns.Name = "MobSpawns"
    for i,v in next, workspace.NightHubCache.MobSpawns:GetChildren() do
        v:Destroy()
    end
    for i,v in next, workspace._WorldOrigin.EnemySpawns:GetChildren() do
        local clonedSpawn = v:Clone()
        clonedSpawn.Name = clonedSpawn.Name:gsub(" %pLv. %d+%p", "")
        clonedSpawn.Parent = workspace.NightHubCache.MobSpawns
    end
    local FarmLevelMob = {}
    for i,v in next, require(self.Quests) do
        for i1, v1 in next, v do
            for i2, v2 in next, v1.Task do
                if v1.Task[i2] > 1 then
                    table.insert(FarmLevelMob, i2)
                end
            end
        end
    end
    for i,v in next, game.Workspace.Enemies:GetChildren() do
        if table.find(FarmLevelMob, v.Name) then
            table.insert(AllSpawnPoint, v)
        end
    end
    for i,v in next, game.ReplicatedStorage:GetChildren() do
        if table.find(FarmLevelMob, v.Name) then
            table.insert(AllSpawnPoint, v)
        end
    end
    for i,v in next, getnilinstances() do
        pcall(function()
            if v:FindFirstChild("Humanoid") and table.find(FarmLevelMob, v.Name) then
                table.insert(AllSpawnPoint, v)
            end
        end)
    end
    for i,v in next, AllSpawnPoint do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
            local Part = Instance.new("Part", workspace.NightHubCache.MobSpawns)
            Part.Name = v.Name
            Part.CanCollide = false
            Part.Transparency = 1
            Part.Anchored = true
            Part.Size= Vector3.new(1 , 1, 1)
            Part.CFrame = v.HumanoidRootPart.CFrame
        elseif v:IsA("Part") then
            local a = v:Clone()
            a.Parent = workspace.NightHubCache.MobSpawns
        end
    end
end
Modules:CreateCacheFolder()
function Modules:TweenToMobSpawn(MobName, StopFunc)
    for i,v in next, workspace.NightHubCache.MobSpawns:GetChildren() do
        if ((typeof(MobName) == "string" and v.Name:lower() == MobName:lower()) or (typeof(MobName) == "table" and table.find(MobName, v.Name))) and self:GetDistance(v.Position) >= 50 then
            repeat task.wait()
                if not Settings[StopFunc] or self:GetMob(MobName) then
                    break
                end
                self:Tweento(v.CFrame * CFrame.new(0, 20, 0))
                task.wait(1)
            until not Settings[StopFunc] or self:GetDistance(v.Position) <= 30 or self:GetMob(MobName)
        end
    end
end
function Modules:GetBerries()
    local Berries, max, returner = game:GetService("CollectionService"):GetTagged("BerryBush"), math.huge, nil
    for i = 1,#Berries do
        for r, v in next, Berries[i]:GetAttributes() do
            if table.find({
                "Blue Icicle Berry",
                "Green Toad Berry",
                "Orange Berry",
                "Pink Pig Berry",
                "Purple Jelly Berry",
                "Red Cherry Berry",
                "White Cloud Berry",
                "Yellow Star Berry",
            }, v) then
                local a = (Berries[i].Parent:GetPivot().Position - self.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if a <= max then
                    max, returner = a, Berries[i]
                end
            end
        end
    end
    return returner
end
function Modules:GetRaidIsland()
    local select
    for i = 5, 1, -1 do
        for _,v in next, workspace._WorldOrigin.Locations:GetChildren() do
            if v.Name == "Island " .. tostring(i) and (v.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 3000 then
                select = v
                break
            end
        end
        if select then break end
    end
    return select
end
function Modules:GetBartiloPlates()
    local Plates = workspace.Map.Dressrosa.BartiloPlates:GetChildren()
    local Select
    table.sort(Plates, function(i, v)
        return tonumber(i.Name:match("%d+$")) < tonumber(v.Name:match("%d+$"))
    end)
    for i,v in next, Plates do
        if v.BrickColor == BrickColor.new("Sand yellow") then
            Select = v
            break
        end
    end
    return Select
end
function Modules:Call(x, xx)
    if x == "Elite" then
        local Elite = self:GetElite()
        if Elite then
            if self.Players.LocalPlayer.PlayerGui.Main.Quest.Visible == false or not string.find(self.Players.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, Elite.Name) then
                if self:GetDistance(workspace["Elite Hunter"].Position) <= 15 then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("EliteHunter")
                else
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest")
                    self:Tweento(workspace["Elite Hunter"].CFrame)
                end
            else
                if Elite and self:IsAlive(Elite) then
                    repeat task.wait()
                        Modules:KillMobs(Elite, xx)
                    until not Elite or not Elite.Parent or not Modules:IsAlive(Elite) or not Settings[x] 
                end
            end
        end
    end
end
function Modules:GetNpcMeleeBuy(x)
    if not x then return end
    local NpcWithMelee = {
        ["Black Leg"] = "Dark Step Teacher",
        ["Electro"] = "Mad Scientist",
        ["Fishman Karate"] = "Water Kung-fu Teacher",
        ["Dragon Claw"] = "Sabi",
        ["Superhuman"] = "Martial Arts Master",
        ["Dark Step"] = "Phoeyu, the Reformed",
        ["Sharkman Karate"] = "Sharkman Teacher",
        ["Electric Claw"] = "Previous Hero",
        ["Dragon Talon"] = "Uzoth",
        ["Godhuman"] = "Ancient Monk",
        ["Sanguine Art"] = "Shafi"
    }
    for i,v in next, NpcWithMelee do
        if i == x then
            return v
        end
    end
end
function Modules:GetNearestMobs()
    local maxdistance = math.huge
    local select
    for i,v in next, workspace.Enemies:GetChildren() do
        if v and v.Parent and self:IsAlive(v) and self:GetDistance(v.PrimaryPart.Position) <= 1000 and self:GetDistance(v.PrimaryPart.Position) <= maxdistance then
            maxdistance = self:GetDistance(v.PrimaryPart.Position)
            select = v
        end
    end
    return select
end
function Modules:LoadFunctions()
    self:AddFunction("Auto Katakuri", function()
        if Settings["Auto Summon Katakuri"] then
            self.ReplicatedStorage.Remotes.CommF_:InvokeServer("CakePrinceSpawner")
        end
        if not Modules:GetMob({"Cake Prince", "Dough King"}, true) then
            local Katakuri_Mobs = Modules:GetMob({
                "Cookie Crafter",
                "Cake Guard",
                "Baking Staff",
                "Head Baker",
            })
            if Katakuri_Mobs then
                if Modules:IsAlive(Katakuri_Mobs) then
                    repeat task.wait()
                        Modules:KillMobs(Katakuri_Mobs, "Auto Katakuri")
                    until not Katakuri_Mobs or not Katakuri_Mobs.Parent or not Modules:IsAlive(Katakuri_Mobs) or not Settings["Auto Katakuri"] 
                end
            else
                self:TweenToMobSpawn({
                    "Cookie Crafter",
                    "Cake Guard",
                    "Baking Staff",
                    "Head Baker",
                }, "Auto Katakuri")
            end
        else
            local Cake_Prince = Modules:GetMob({"Cake Prince", "Dough King"}, true)
            if Modules:IsAlive(Cake_Prince) then
                repeat task.wait()
                    Modules:KillMobs(Cake_Prince, "Auto Katakuri")
                until not Cake_Prince or not Cake_Prince.Parent or not Modules:IsAlive(Cake_Prince) or not Settings["Auto Katakuri"]
            end
        end
    end, Sea3, true)
    self:AddFunction("Auto Farm Bones", function()
        local Bones_Mob = Modules:GetMob({
            "Reborn Skeleton",
            "Living Zombie",
            "Demonic Soul",
            "Posessed Mummy"
        })
        if Bones_Mob then
            if Modules:IsAlive(Bones_Mob) then
                repeat task.wait()
                    Modules:KillMobs(Bones_Mob, "Auto Farm Bones")
                until not Bones_Mob or not Bones_Mob.Parent or not Modules:IsAlive(Bones_Mob) or not Settings["Auto Farm Bones"] 
            end
        else
            self:TweenToMobSpawn({
                "Reborn Skeleton",
                "Living Zombie",
                "Demonic Soul",
                "Posessed Mummy"
            }, "Auto Farm Bones")
        end
    end, Sea3, true)
    self:AddFunction("Auto Farm Level", function()
        if not self.Players.LocalPlayer.PlayerGui.Main.Quest.Visible then
            local Name, NameQuest, Id = self:GetQuest()
            local CFrameNPC = self:GetCFrameQuest()
            if not CFrameNPC then return end
            if self:GetDistance(CFrameNPC.Position) <= 15 then
                task.wait(1.5)
                self.ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", NameQuest, Id)
            else
                self:Tweento(CFrameNPC)
            end
        else
            local NameMob = self:GetLastQuest()
            if not NameMob then return end
            local Mob = self:GetMob(NameMob)
            if Mob and self:IsAlive(Mob) then
                repeat task.wait()
                    if not self.Players.LocalPlayer.PlayerGui.Main.Quest.Visible then break end
                    Modules:KillMobs(Mob, "Auto Farm Level")
                until not Mob or not Mob.Parent or not Modules:IsAlive(Mob) or not Settings["Auto Farm Level"]
                task.wait(0.3)
            else
                if self.Players.LocalPlayer.PlayerGui.Main.Quest.Visible then
                    self:TweenToMobSpawn(NameMob, "Auto Farm Level")
                end
            end
        end
    end, true, true)
    self:AddFunction("Auto Farm Candy (New)", function()
        local Name, NameQuest, Id = self:GetQuest()
        local Mob = self:GetMob(Name)
        if Mob and self:IsAlive(Mob) then
            repeat task.wait()
                Modules:KillMobs(Mob, "Auto Farm Candy (New)")
            until not Mob or not Mob.Parent or not Modules:IsAlive(Mob) or not Settings["Auto Farm Candy (New)"] 
        else
            self:TweenToMobSpawn(Name, "Auto Farm Candy (New)")
        end
    end, true, true)
    self:AddFunction("Auto Buso",function()
        self:EnableBuso()
    end, true)
    self:AddFunction("Auto Saber", function()
        if self:CheckItem("Saber") then return end
        if workspace.Map.Jungle.Final.Part.CanCollide then
            if game:GetService("Workspace").Map.Jungle.QuestPlates.Door.CanCollide then
                for i,v in next, workspace.Map.Jungle.QuestPlates:GetChildren() do
                    if v:FindFirstChild("Button") and v.Button:FindFirstChild("TouchInterest") then
                        firetouchinterest(v.Button, self.Players.LocalPlayer.Character.HumanoidRootPart, 0)
                        firetouchinterest(v.Button, self.Players.LocalPlayer.Character.HumanoidRootPart, 1)
                    end
                end
            else
                if workspace.Map.Desert.Burn.Part.CanCollide then
                    if not self:CheckItem("Torch") then
                        firetouchinterest(workspace.Map.Jungle.Torch, self.Players.LocalPlayer.Character.HumanoidRootPart, 0)
                        firetouchinterest(workspace.Map.Jungle.Torch, self.Players.LocalPlayer.Character.HumanoidRootPart, 1)
                    else
                        self:EquipTool("Torch")
                        firetouchinterest(
                            game.Players.LocalPlayer.Character.Torch.Handle,
                            game:GetService("Workspace").Map.Desert.Burn.Fire,
                            0
                        )
                        firetouchinterest(
                            game.Players.LocalPlayer.Character.Torch.Handle,
                            game:GetService("Workspace").Map.Desert.Burn.Fire,
                            1
                        )
                    end
                else
                    local Progress = self.CommF_:InvokeServer("ProQuestProgress", "RichSon")
                    if Progress ~= 0 and Progress ~= 1 then
                        if not self:CheckItem("Cup") then
                            firetouchinterest(workspace.Map.Desert.Cup, self.Players.LocalPlayer.Character.HumanoidRootPart, 0)
                            firetouchinterest(workspace.Map.Desert.Cup, self.Players.LocalPlayer.Character.HumanoidRootPart, 1)
                        else
                            self:EquipTool("Cup")
                            self.CommF_:InvokeServer("ProQuestProgress","FillCup", self.Players.LocalPlayer.Character:FindFirstChild("Cup"))
                            self.CommF_:InvokeServer("ProQuestProgress","SickMan")
                        end
                    elseif Progress == 0 then
                        if self:GetMob("Mob Leader", true) then
                            local v = self:GetMob("Mob Leader", true)
                            repeat task.wait()
                                Modules:KillMobs(v, "Auto Saber")
                            until not v or not v.Parent or not Modules:IsAlive(v) or not Settings["Auto Saber"] 
                        end
                    elseif Progress == 1 then
                        if not self:CheckItem("Relic") then
                            self.CommF_:InvokeServer("ProQuestProgress","RichSon")
                        else
                            self:EquipTool("Relic")
                            task.wait(0.1)
                            firetouchinterest(game.Players.LocalPlayer.Character.Relic.Handle, workspace.Map.Jungle.Final.Invis, 0)
                            firetouchinterest(game.Players.LocalPlayer.Character.Relic.Handle, workspace.Map.Jungle.Final.Invis, 1)
                        end
                    end
                end
            end
        else
            local v = self:GetMob("Saber Expert", true)
            if v then
                repeat task.wait()
                    Modules:KillMobs(v, "Auto Saber")
                until not v or not v.Parent or not Modules:IsAlive(v) or not Settings["Auto Saber"]
            end
        end
    end,Sea1)
    self:AddFunction("Auto Tyrant of the Skies", function()
        local Boss = self:GetMob("Tyrant of the Skies", true)
        if Boss and self:IsAlive(Boss) then
            repeat task.wait()
                Modules:KillMobs(Boss, "Auto Tyrant of the Skies")
            until not Boss or not Boss.Parent or not Modules:IsAlive(Boss) or not Settings["Auto Tyrant of the Skies"] 
        end
    end,Sea3, true)
    self:AddFunction("Auto Rip Indra", function()
        local Boss = self:GetMob({"rip_indra", "rip_indra True Form"}, true)
        if Boss and self:IsAlive(Boss) then
            repeat task.wait()
                Modules:KillMobs(Boss, "Auto Rip Indra")
            until not Boss or not Boss.Parent or not Modules:IsAlive(Boss) or not Settings["Auto Rip Indra"]
        end
    end,Sea3, true)
    self:AddFunction("Auto Elite Hunter", function()
        self:Call("Elite", "Auto Elite Hunter", (not self:GetElite()))
    end,Sea3, true)
    self:AddFunction("Auto Tushita", function()
        if self:CheckInventory('Tushita') or self.Level.Value < 2000 then
            return
        end
        local TushitaProgress = self.ReplicatedStorage.Remotes.CommF_:InvokeServer("TushitaProgress")
        if not TushitaProgress.OpenedDoor then
            if self:GetMob({"rip_indra", "rip_indra True Form"}, true) then
                if not self:CheckItem("Holy Torch") then
                    self:Tweento(
                        CFrame.new(
                            5717.06592,
                            18.8161335,
                            252.124573,
                            0.926925123,
                            -3.25000045e-08,
                            -0.375246346,
                            3.45466091e-08,
                            1,
                            -1.2735254e-09,
                            0.375246346,
                            -1.17830261e-08,
                            0.926925123
                        )
                    )
                else
                    self:EquipTool("Holy Torch")
                    for r = 1, 5 do
                        self.ReplicatedStorage.Remotes.CommF_:InvokeServer("TushitaProgress", "Torch", r)
                    end
                end
            end
        else
            local v = self:GetMob("Longma", true)
            if v and self:IsAlive(v) then
                repeat task.wait()
                    Modules:KillMobs(v, "Auto Tushita")
                until not v or not v.Parent or not Modules:IsAlive(v) or not Settings["Auto Tushita"]
            end
        end
    end, Sea3, true)
    self:AddFunction("Anti Ban", function()
        if self.Players.LocalPlayer:FindFirstChild("Banned") then
            self.Players.LocalPlayer.Banned:Destroy()
        end
        self.Players.LocalPlayer.ChildAdded:Connect(function(v)
            if v.Name == "Banned" then
                v:Destroy()
            end
        end)
    end, true)
    self:AddFunction("Auto Ken (Observation)", function()
        if not self.Players.LocalPlayer.Character:FindFirstChild("HasObservation") then
            self.ReplicatedStorage.Remotes.CommF_:InvokeServer("Ken")
        end
    end, true)
    self:AddFunction("Auto Farm Sword Mastery 600", function()
        if not self:GetMasteryCurrentTool("Sword") or self:GetMasteryCurrentTool("Sword") == 600 then
            for i,v in next, game.ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory") do
                if v.Type == "Sword" then
                    if v.Mastery <= 599 then
                        self.ReplicatedStorage.Remotes.CommF_:InvokeServer("LoadItem",v.Name)
                        task.wait(0.5)
                        break
                    end
                end
            end
        end
    end, true)
    self:AddFunction("Auto Chest", function()
        local Chest = self:GetChest()
        if Chest then
            repeat task.wait()
                if Settings["Auto Chest Methods"] == "Bypass (RISK)" then
                    if not bypass_chest_tick_2 then
                        bypass_chest_tick_2 = tick()
                    elseif bypass_chest_tick_2 and tick() - bypass_chest_tick_2 >= 10 then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
                        bypass_chest_tick_2 = tick()
                        task.wait(2)
                    end
                    self.Players.LocalPlayer.Character:PivotTo(Chest:GetPivot())
                else
                    self:Tweento(Chest:GetPivot())
                end
                if self:GetDistance(Chest:GetPivot()) <= 10 then
                    firetouchinterest(Chest, game.Players.LocalPlayer.Character.HumanoidRootPart, 0)
                    firetouchinterest(Chest, game.Players.LocalPlayer.Character.HumanoidRootPart, 1)
                    firesignal(Chest.Touched,game.Players.LocalPlayer.Character.HumanoidRootPart)
                end
            until not Chest or not Chest.Parent or Chest:GetAttribute("IsDisabled") or not Settings['Auto Chest'] or (Settings["Stop When Found Legendary"] and (self:CheckItem("God's Chalice") or self:CheckItem("Fist of Darkness")))
        end
    end,true, true)
    self:AddFunction("Auto Dual Cursed Katana", function()
        if self.Level.Value <= 2200 then return end
        if self:CheckInventory("Yama") and self:CheckInventory("Tushita") then
            if self:CheckInventory("Yama") and self:CheckInventory("Yama").Mastery < 350 then
                if not self:CheckItem("Yama") then
                    self.ReplicatedStorage.Remotes.CommF_:InvokeServer("LoadItem","Yama")
                end
                return
            end
            if self:CheckInventory("Tushita") and self:CheckInventory("Tushita").Mastery < 350 then
                if not self:CheckItem("Tushita") then
                    self.ReplicatedStorage.Remotes.CommF_:InvokeServer("LoadItem","Tushita")
                end
                return
            end
            pcall(function()
                if self:GetPedestal() then
                    repeat task.wait()
                        if not workspace.Map:FindFirstChild("Turtle") or not workspace.Map:FindFirstChild("Turtle"):FindFirstChild("Cursed") then
                            self:Tweento(CFrame.new(-12389, 601, -6548))
                        elseif workspace.Map:FindFirstChild("Turtle") and workspace.Map.Turtle:FindFirstChild("Cursed") then
                            if self:GetDistance(self:GetPedestal().Position) <= 10 then
                                fireproximityprompt(self:GetPedestal().ProximityPrompt)
                            else
                                self:Tweento(self:GetPedestal().CFrame)
                            end
                        end
                    until not self:GetPedestal() or not Settings["Auto Dual Cursed Katana"]
                    return
                end
                local CDKProgress = self:GetCDKProgress()
                if CDKProgress.Evil == 4 and CDKProgress.Good == 4 then
                    game:GetService("ReplicatedStorage").DialogueController._Close:Fire()
                    if not workspace.Map:FindFirstChild("Turtle") or not workspace.Map:FindFirstChild("Turtle"):FindFirstChild("Cursed") then
                        self:Tweento(CFrame.new(-12389, 601, -6548))
                    else
                        if workspace.Map.Turtle.Cursed.PlacedGem.Transparency == 0 then
                            if not self:GetMob("Cursed Skeleton Boss", true) then
                                self:Tweento(CFrame.new(-12341.66796875, 603.3455810546875, -6550.6064453125))
                            else
                                local v = self:GetMob("Cursed Skeleton Boss", true)
                                if v and self:IsAlive(v) then
                                    repeat task.wait()
                                        if not self:CheckItem("Yama") then
                                            self.ReplicatedStorage.Remotes.CommF_:InvokeServer("LoadItem","Yama")
                                        end
                                        self:KillMobs(v, "Auto Dual Cursed Katana")
                                    until not self:IsAlive(v) or not Settings["Auto Dual Cursed Katana"] or self:CheckInventory("Dual Cursed Katana")
                                end
                            end
                        else
                            if self:GetDistance(workspace.Map.Turtle.Cursed.Pedestal3.Position) <= 10 then
                                fireproximityprompt(workspace.Map.Turtle.Cursed.Pedestal3.ProximityPrompt)
                            else
                                self:Tweento(workspace.Map.Turtle.Cursed.Pedestal3.CFrame)
                            end
                        end
                    end
                    return
                end
            end)
            local CDKProgress = self:GetCDKProgress()
            if CDKProgress.Evil == -2 or CDKProgress.Evil == 4 then
                self.CommF_:InvokeServer("CDKQuest", "StartTrial", "Good")
            else
                self.CommF_:InvokeServer("CDKQuest", "StartTrial", "Evil")
            end
            self:DoCDKQuest()
        end
    end, Sea3, true)
    self:AddFunction("Auto Dough King", function()
        if self:GetMob("Dough King", true) then
            local v = self:GetMob("Dough King", true)
            if self:IsAlive(v) then
                repeat task.wait()
                    self:KillMobs(v, "Auto Dough King")
                until not self:IsAlive(v) or not Settings["Auto Dough King"] or self:CheckInventory("Dual Cursed Katana")
            end
        else
            task.task.spawn(function()
                self.ReplicatedStorage.Remotes.CommF_:InvokeServer("CakePrinceSpawner")
            end)
            if self:CheckItem("Sweet Chalice") then
                local Katakuri_Mobs = self:GetMob({
                    "Cookie Crafter",
                    "Cake Guard",
                    "Baking Staff",
                    "Head Baker",
                })
                if Katakuri_Mobs then
                    if self:IsAlive(Katakuri_Mobs) then
                        repeat task.wait()
                            self:KillMobs(Katakuri_Mobs, "Auto Dough King")
                        until not Katakuri_Mobs or not Katakuri_Mobs.Parent or not self:IsAlive(Katakuri_Mobs) or not Settings["Auto Dough King"] 
                    end
                else
                    self:Tweento(CFrame.new(-2137, 69, -12324))
                end
            else
                if self:CheckItem("God's Chalice") then
                    if self:CheckInventory("Conjured Cocoa") and self:CheckInventory("Conjured Cocoa").Count >= 10 then
                        self.CommF_:InvokeServer("SweetChaliceNpc")
                    else
                        local v = self:GetMob({
                            "Cocoa Warrior",
                            "Chocolate Bar Battler",
                        }, true)
                        if v and self:IsAlive(v) then
                            repeat task.wait()
                                self:KillMobs(v, "Auto Dough King")
                            until not self:IsAlive(v) or not Settings["Auto Dough King"] or (self:CheckInventory("Conjured Cocoa") and self:CheckInventory("Conjured Cocoa").Count >= 10)
                        elseif not v then
                            self:TweenToMobSpawn({"Cocoa Warrior", "Chocolate Bar Battler"}, "Auto Dough King")
                        end
                    end
                else
                    if Settings["Find God's Chalice Method"] == "Elite Hunter" then
                        self:Call("Elite", "Auto Dough King", (not self:CheckItem("God's Chalice")))
                    else
                        local Chest = self:GetChest()
                        if Chest then
                            repeat task.wait()
                                if self:CheckItem("God's Chalice") then break end
                                if Settings["Find God's Chalice Method"] == "Auto Chest (Bypass)" then
                                    if not bypass_chest_tick then
                                        bypass_chest_tick = tick()
                                    elseif bypass_chest_tick and tick() - bypass_chest_tick >= 10 then
                                        game.Players.LocalPlayer.Character.Humanoid.Health = 0
                                        bypass_chest_tick = tick()
                                        task.wait(1)
                                    end
                                    game.Players.LocalPlayer.Character:PivotTo(Chest:GetPivot())
                                else
                                    self:Tweento(Chest:GetPivot())
                                end
                                if self:GetDistance(Chest:GetPivot()) <= 10 then
                                    firetouchinterest(Chest, game.Players.LocalPlayer.Character.HumanoidRootPart, 0)
                                    firetouchinterest(Chest, game.Players.LocalPlayer.Character.HumanoidRootPart, 1)
                                    firesignal(Chest.Touched,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                end
                            until not Chest or Chest:GetAttribute("IsDisabled") or not Settings['Auto Dough King'] or self:CheckItem("God's Chalice")
                        end
                    end
                end
            end
        end
    end, Sea3, true)
    self:AddFunction("Auto Ghoul Race", function()
        if game.Players.LocalPlayer.Data.Race.Value == "Ghoul" then
            return
        end
        if not self:CheckItem("Hellfire Torch") then
            local v = self:GetMob("Cursed Captain", true)
            if v then
                if self:IsAlive(v) then
                    repeat task.wait()
                        self:KillMobs(v, "Auto Ghoul Race")
                    until not self:IsAlive(v) or not Settings["Auto Ghoul Race"] or self:CheckItem("Hellfire Torch")
                end
            end
        else
            self:EquipTool("Hellfire Torch")
            task.wait(0.5)
            if self:GetDistance(workspace['Experimic'].Position) <= 15 then
                local args = {[1] = "Ectoplasm", [2] = "BuyCheck", [3] = 4}
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
            else
                self:Tweento(workspace['Experimic'].CFrame)
            end
        end
    end, Sea2)
    self:AddFunction("Auto Collect Berries", function()
        if self:GetBerries() then
            local v = self:GetBerries()
            if v then
                local TweenPos = v:FindFirstChildOfClass("Model") and v:FindFirstChildOfClass("Model"):GetPivot() or v.Parent:GetPivot()
                if self:GetDistance(TweenPos.Position) <= 15 then
                    fireproximityprompt(v:FindFirstChildOfClass("Model").ProximityPrompt)
                else
                    self:Tweento(TweenPos)
                end
            end
        end
    end, true, true)
    self:AddFunction("Auto Buy Haki Color", function()
        self.ReplicatedStorage.Remotes["CommF_"]:InvokeServer("ColorsDealer", "2")
    end, true)
    self:AddFunction("Auto Random Surprises", function()
        local _1, _2, RandomCount, TimeRandom, MaxRandom = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones", "Check")
        if RandomCount > 0 then
            game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones", "Buy", 1, 1)
            task.wait()
        else
        end
    end,Sea3)
    self:AddFunction("Auto Yama", function()
        if self:CheckInventory("Yama") then return end
        if self.CommF_:InvokeServer("EliteHunter", "Progress") >= 30 then
            if not workspace.Map:FindFirstChild("Waterfall") or not workspace.Map.Waterfall:FindFirstChild("SealedKatana") then
                self:Tweento(CFrame.new(5250.71924, 19.842907, 453.177002))
            else
                if self:GetDistance(workspace.Map.Waterfall.SealedKatana.Hitbox.Position) <= 15 then
                    fireclickdetector(workspace.Map.Waterfall.SealedKatana.Hitbox.ClickDetector)
                else
                    self:Tweento(workspace.Map.Waterfall.SealedKatana.Hitbox.CFrame)
                end
            end
        end
    end,Sea3, true)
    self:AddFunction("Auto Soul Reaper", function()
        if self:GetMob("Soul Reaper", true) then
            local v = self:GetMob("Soul Reaper", true)
            repeat
                task.wait()
                self:KillMobs(v, "Auto Soul Reaper")
            until not v or not v.Parent or not self:IsAlive(v) or not Settings["Auto Soul Reaper"]
        else
            if self:CheckItem("Hallow Essence") then
                self:EquipTool("Hallow Essence")
                self:Tweento(CFrame.new(-8932, 142, 6063))
            else    
                self.CommF_:InvokeServer("Bones", "Buy", 1, 1)
            end
        end
    end, Sea3, true)
    self:AddFunction("Auto Travel Dressrosa", function()
        if self.CommF_:InvokeServer("DressrosaQuestProgress", "Dressrosa") == 0 then
            task.wait(0.5)
            self.CommF_:InvokeServer("TravelDressrosa")
            return
        end
        if workspace.Map.Ice.Door.CanCollide then
            if not self:CheckItem("Key") then
                self.CommF_:InvokeServer("DressrosaQuestProgress", "Detective")
            else
                self:EquipTool("Key")
                firetouchinterest(game.Players.LocalPlayer.Character.Key.Handle, workspace.Map.Ice.Door, 0)
                firetouchinterest(game.Players.LocalPlayer.Character.Key.Handle, workspace.Map.Ice.Door, 1)
            end
        else
            local v = self:GetMob("Ice Admiral", true)
            if v then
                repeat task.wait()
                    self:KillMobs(v, "Auto Travel Dressrosa")
                until not v or not self:IsAlive(v) or not Settings["Auto Travel Dressrosa"]
            else
                self:Tweento(CFrame.new(1345, 37, -1329))
            end
        end
    end,Sea1,true)
    self:AddFunction("Auto Bartilo Quest", function()
        local BartiloProgress = self.CommF_:InvokeServer("BartiloQuestProgress", "Bartilo")
        if BartiloProgress == 0 then
            if not self.Players.LocalPlayer.PlayerGui.Main.Quest.Visible or not string.find(self.Players.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text,"Swan Pirate") then
                if self:GetDistance(self.NPCs["Bartilo"].Position) <= 15 then
                    task.wait(1)
                    self.CommF_:InvokeServer("StartQuest", "BartiloQuest", 1)
                else
                    self:Tweento(self.NPCs["Bartilo"].CFrame)
                end
            else
                local v = self:GetMob('Swan Pirate')
                if v then
                    repeat task.wait()
                        self:KillMobs(v, "Auto Bartilo Quest")
                    until not v or not self:IsAlive(v) or not Settings["Auto Bartilo Quest"] or BartiloProgress ~= 0
                else
                    self:TweenToMobSpawn("Swan Pirate", "Auto Bartilo Quest")
                end
            end
        elseif BartiloProgress == 1 then
            local v = self:GetMob('Jeremy', true)
            if v then
                repeat task.wait()
                    self:KillMobs(v, "Auto Bartilo Quest")
                until not v or not self:IsAlive(v) or not Settings["Auto Bartilo Quest"] or BartiloProgress ~= 1
            end
        elseif BartiloProgress == 2 then
            repeat task.wait()
                if self:GetDistance(CFrame.new(-1835, 10, 1679)) <= 100 then
                    local BartiloPlates = self:GetBartiloPlates()
                    firetouchinterest(self.Players.LocalPlayer.Character.PrimaryPart, BartiloPlates, 1)
                    firetouchinterest(self.Players.LocalPlayer.Character.PrimaryPart, BartiloPlates, 0)
                    task.wait(0.1)
                else
                    self:Tweento(CFrame.new(-1835, 10, 1679))
                end
            until BartiloProgress ~= 2 or not Settings["Auto Bartilo Quest"]
        end
    end,Sea2,true)
    self:AddFunction("Auto Travel Zou", function()
        if self.Level.Value >= 1500 and self.CommF_:InvokeServer("BartiloQuestProgress", "Bartilo") == 3 then
            if self.CommF_:InvokeServer("TalkTrevor", "1") ~= 0 then
                if not self:CheckFruit(true) then
                    self.CommF_:InvokeServer("LoadFruit", self:GetFruitInventory())
                    task.wait(1)
                else
                    if self:GetDistance(self.NPCs["Trevor"].Position) <= 15 then
                        self:EquipTool(self:CheckFruit(true).Name)
                        for i = 1, 3 do
                            self.CommF_:InvokeServer("TalkTrevor", tostring(i))
                        end
                    else
                        self:Tweento(self.NPCs["Trevor"].CFrame)
                    end
                end
            elseif not self.CommF_:InvokeServer("ZQuestProgress", "Check") then
                local v = self:GetMob('Don Swan',true)
                if v then
                    repeat task.wait()
                        self:KillMobs(v, "Auto Travel Zou")
                    until not v or not self:IsAlive(v) or not Settings["Auto Travel Zou"]
                end
            elseif self.CommF_:InvokeServer("ZQuestProgress", "Check") == 0 then 
                if self:GetDistance(workspace.Map.IndraIsland.Part.Position) > 1000 then
                    if self:GetDistance(self.NPCs["King Red Head"].Position) <= 30 then
                        task.wait(.1)
                        self.CommF_:InvokeServer("ZQuestProgress", "Begin")
                    else
                        self:Tweento(self.NPCs["King Red Head"].CFrame)
                    end
                else
                    local v = self:GetMob('rip_indra',true)
                    if v then
                        repeat task.wait()
                            self.CommF_:InvokeServer("TravelZou")
                            self:KillMobs(v, "Auto Travel Zou")
                        until not v or not self:IsAlive(v) or not Settings["Auto Travel Zou"]
                    end
                end
            end
        end
    end,Sea2,true)

    self:AddFunction("Auto Soul Guitar", function()
        task.spawn(function()
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("soulGuitarBuy",true)
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("soulGuitarBuy")
        end)
        if not self.CommF_:InvokeServer("GuitarPuzzleProgress", "Check") then
            if game.Lighting.Sky.MoonTextureId == "http://www.roblox.com/asset/?id=9709149431" and (game.Lighting.ClockTime > 16 or game.Lighting.ClockTime < 5) then
                local MISCNpc = CFrame.new(-8654, 140, 6167)
                if self:GetDistance(MISCNpc) <= 30 then
                    self.CommF_:InvokeServer("gravestoneEvent", 2)
                    self.CommF_:InvokeServer("gravestoneEvent", 2, true)
                else
                    self:Tweento(MISCNpc)
                end
            end
        else
            if not self.CommF_:InvokeServer("GuitarPuzzleProgress", "Check").Swamp then
                if self:GetDistance(CFrame.new(-10171, 138, 6008)) > 100 then
                    self:Tweento(CFrame.new(-10171, 138, 6008))
                else
                    if CountHealthLow < 6 then
                        if #self:GetZombieGuitarPuzzle() >= 6 then
                            for i,v in next, self:GetZombieGuitarPuzzle() do
                                local LowHealth = v.Humanoid.Health <= v.Humanoid.MaxHealth * 25 / 100
                                if not LowHealth then
                                    repeat task.wait()
                                        if LowHealth then CountHealthLow = CountHealthLow + 1 break end
                                        self:KillMobs(v, "Auto Soul Guitar")
                                    until LowHealth or not v or not self:IsAlive(v) or Settings["Auto Soul Guitar"] == false
                                    getgenv().SingleAttack = false
                                    BringMob = false
                                end
                            end
                        end
                    else
                        getgenv().SingleAttack = false
                        for i,v in next, self:GetZombieGuitarPuzzle() do
                            self:Tweento(CFrame.new(-10171, 150, 6008))
                            v.HumanoidRootPart.CFrame = CFrame.new(-10171, 138, 6008)
                        end
                    end
                end
            elseif not self.CommF_:InvokeServer("GuitarPuzzleProgress", "Check").Gravestones then
                local ClickSigns = {
                    game.workspace.Map["Haunted Castle"].Placard1.Right.ClickDetector,
                    game.workspace.Map["Haunted Castle"].Placard2.Right.ClickDetector,
                    game.workspace.Map["Haunted Castle"].Placard3.Left.ClickDetector,
                    game.workspace.Map["Haunted Castle"].Placard4.Right.ClickDetector,
                    game.workspace.Map["Haunted Castle"].Placard5.Left.ClickDetector,
                    game.workspace.Map["Haunted Castle"].Placard6.Left.ClickDetector,
                    game.workspace.Map["Haunted Castle"].Placard7.Left.ClickDetector
                }
                for i, v in pairs(ClickSigns) do
                    fireclickdetector(v)
                end
            elseif not self.CommF_:InvokeServer("GuitarPuzzleProgress", "Check").Ghost then
                self.CommF_:InvokeServer("GuitarPuzzleProgress", "Ghost")
            elseif not self.CommF_:InvokeServer("GuitarPuzzleProgress", "Check").Trophies then
                local TabletFolder = workspace.Map["Haunted Castle"].Tablet
                local TrophyFolder = workspace.Map["Haunted Castle"].Trophies.Quest
                for i, tabletName in ipairs(self.AllTablet) do
                    local tablet = TabletFolder[tabletName]
                    local trophy = TrophyFolder[self.AllTrophies[i]]
                    if tablet and trophy then
                        local a = tostring(trophy.Handle.CFrame):split(", ")[4]
                        local haiz = (a == "1" or a == "-1") and "90" or "180"
                        if not string.find(tostring(tablet.Line.Rotation.Z), haiz) then
                            repeat task.wait()
                                fireclickdetector(tablet.ClickDetector)
                            until string.find(tostring(tablet.Line.Rotation.Z), haiz)
                        end
                    end
                end
                for _, v in next, TabletFolder:GetChildren() do
                    if not table.find(self.AllTablet, v.Name) then
                        if v.Line.Rotation.Z ~= 0 then
                            repeat task.wait(0.2)
                                fireclickdetector(v.ClickDetector)
                            until v.Line.Rotation.Z == 0
                        end
                    end
                end
            elseif not self.CommF_:InvokeServer("GuitarPuzzleProgress", "Check").Pipes then
                for i, v in pairs(self.Pipes) do
                    local x = game.workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model[i]
                    if x.BrickColor.Name ~= v then
                        repeat task.wait()
                            fireclickdetector(x.ClickDetector)
                        until x.BrickColor.Name == v
                    end
                end
            end
        end
    end,Sea3)
    self:AddFunction("Auto Add Stats", function()
        if game.Players.LocalPlayer.Data.Points.Value > 0 then
            local selected = Settings["Select Stats to Add"]
            if typeof(selected) == "table" then
                for statName, enabled in pairs(selected) do
                    if enabled and game.Players.LocalPlayer.Data.Points.Value > 0 then
                        if game:GetService("Players").LocalPlayer.Data.Stats:FindFirstChild(statName) and game:GetService("Players").LocalPlayer.Data.Stats[statName].Level.Value < 2800 then
                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddPoint", statName, 1)
                        end
                    end
                end
            elseif typeof(selected) == "string" and selected ~= "" then
                if game:GetService("Players").LocalPlayer.Data.Stats:FindFirstChild(selected) and game:GetService("Players").LocalPlayer.Data.Stats[selected].Level.Value < 2800 then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddPoint", selected, 9999)
                end
            end
        end
    end,true)
    self:AddFunction("Auto Buy Melee Select", function()
        for i, v in pairs(self.MeleeRemotes) do
            if i == Settings["Select Melee"] then
                if typeof(v) == "table" then
                    self.CommF_:InvokeServer(unpack(v))
                else
                    self.CommF_:InvokeServer(v)
                end
                task.wait(0.5)
            end
        end
    end, true)
    self:AddFunction("Auto Race V2 - V3", function()
        local RaceV = self:CheckRace()
        if RaceV == "V1" then
            for i = 1, 2 do
                self.CommF_:InvokeServer("Alchemist", tostring(i))
            end
            if self:CheckItem("Flower 1") and self:CheckItem("Flower 2") and self:CheckItem("Flower 3") then
                self.CommF_:InvokeServer("Alchemist", "3")
            else
                if not self:CheckItem("Flower 1") then
                    self:Tweento(workspace.Flower1.CFrame)
                elseif not self:CheckItem("Flower 2") then
                    self:Tweento(workspace.Flower2.CFrame)
                elseif not self:CheckItem("Flower 3") then
                    local v = self:GetMob("Swan Pirate")
                    if v then
                        repeat task.wait()
                            self:KillMobs(v, "Auto Race V2 - V3")
                        until not v or not self:IsAlive(v) or Settings["Auto Race V2 - V3"] == false or self:CheckItem("Flower 3")
                    else
                        self:TweenToMobSpawn("Swan Pirate", "Auto Race V2 - V3")
                    end
                end
            end
        elseif RaceV == "V2" then
            task.spawn(function()
                if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "1") == 0 then
                    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "2")
                end
                game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "3")
            end)
            local Race = self.Players.LocalPlayer.Data.Race.Value
            if Race == "Skypiea" then
                if not SkypieaPlayers then
                    SkypieaPlayers = {}
                end
                for _,v in next, game.Players:GetPlayers() do
                    if v and v.Parent and v.Name ~= self.Players.LocalPlayer.Name and v:FindFirstChild("Data") and v.Data:FindFirstChild("Race") and v.Data.Race.Value == "Skypiea" and not self:CheckSafeZone(v.Character.HumanoidRootPart) and not self:IsRaiding(v.Character.HumanoidRootPart) then
                        table.insert(SkypieaPlayers, v.Character)
                    end
                end
                if #SkypieaPlayers > 0 then
                    for i,v in next, SkypieaPlayers do
                        if self:IsAlive(v) then
                            repeat task.wait()
                                if self:CheckNotify("died") then
                                    table.remove(SkypieaPlayers, i)
                                    break
                                end
                                self:EnableBuso()
                                self:EquipWeapon()
                                self:Tweento(v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5))
                            until not v or not v.Parent or not self:IsAlive(v) or Settings["Auto Race V2 - V3"] == false or Race ~= "Skypiea" or RaceV ~= "V2" or self:CheckNotify("died") or self:CheckNotify("players")
                        end
                    end
                end
            elseif Race == "Mink" then
                local Chest = self:GetChest()
                if Chest then
                    repeat task.wait()
                        if not Last_Reset then
                            Last_Reset = tick()
                        end
                        if tick() - Last_Reset >= 10 then
                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
                            Chest:SetAttribute("IsDisabled", true)
                            Last_Reset = tick()
                        end
                        if RaceV ~= "V2" or Race ~= "Mink" then break end
                        game.Players.LocalPlayer.Character:PivotTo(Chest:GetPivot())
                        if self:GetDistance(Chest:GetPivot()) <= 30 then
                            ChestCount += 1
                            firetouchinterest(Chest, game.Players.LocalPlayer.Character.HumanoidRootPart, 0)
                            firetouchinterest(Chest, game.Players.LocalPlayer.Character.HumanoidRootPart, 1)
                            firesignal(Chest.Touched,game.Players.LocalPlayer.Character.HumanoidRootPart)
                        end
                    until not Chest or Chest:GetAttribute("IsDisabled") or not Settings['Auto Race V2 - V3'] or RaceV ~= "V2" or Race ~= "Mink"
                end
            elseif Race == "Ghoul" then
                for i,v in next, game.Workspace.Characters:GetChildren() do
                    if v and not table.find(BlacklistedTarget, v.Name) and v ~= self.Players.LocalPlayer and self:IsAlive(v) and not self:CheckSafeZone(v.HumanoidRootPart) and not self:IsRaiding(v.HumanoidRootPart) then
                        repeat task.wait()
                            if (self:CheckNotify("died") or self:CheckNotify("players") or self:CheckSafeZone(v.HumanoidRootPart)) and self:GetDistance(v.HumanoidRootPart.Position) <= 50 then
                                table.insert(BlacklistedTarget, v.Name)
                                if self:CheckNotify("died") then
                                    self:CheckNotify("died"):Destroy()
                                end
                                if self:CheckNotify("players") then
                                    self:CheckNotify("players"):Destroy()
                                end
                                break
                            end
                            self:EnableBuso()
                            self:EquipWeapon()
                            self:Tweento(v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5))
                        until not v or not v.Parent or not self:IsAlive(v) or Settings["Auto Race V2 - V3"] == false or Race ~= "Ghoul" or RaceV ~= "V2"
                    end
                end
            elseif Race == "Fishman" then
                if not self:GetSeaBeast() then
                    if not self:GetYourBoat() then
                        if self:GetDistance(Vector3.new(-5334, 5, -695)) <= 15 then
                            self.CommF_:InvokeServer("BuyBoat", "Guardian")
                            task.wait(0.5)
                        else
                            self:Tweento(CFrame.new(-5334, 5, -695))
                        end
                    else
                        local WaitSeaBeastPosition = Vector3.new(-4327.17529, 18.9998722, 768.410522)
                        repeat task.wait()
                            self:SpamAllSkill()
                            if game.Players.LocalPlayer.Character.Humanoid.Sit == false then
                                self:Tweento(self:GetYourBoat().VehicleSeat.CFrame*CFrame.new(0,2,0))
                            else
                                self:TweenObject(self:GetYourBoat().VehicleSeat, CFrame.new(WaitSeaBeastPosition))
                            end
                        until not self:GetYourBoat() or self:GetDistance(WaitSeaBeastPosition, nil, true) <= 200 or Settings["Auto Race V2 - V3"] == false or self:GetSeaBeast()
                    end
                else
                    repeat task.wait()
                        self:Tweento(self:GetSeaBeastPosition(self:GetSeaBeast()))
                    until not self:GetSeaBeast() or Settings["Auto Race V2 - V3"] == false
                end
            elseif Race == "Cyborg" then
                if not self:CheckFruit() then
                    self.CommF_:InvokeServer("LoadFruit", self:GetFruitInventory(true))
                    task.wait(0.5)
                else
                    self:EquipTool(self:CheckFruit().Name)
                end
            end
        end
    end,Sea2,true)
    self:AddFunction("Start Material Farm", function()
        if self.Materials[Settings["Select Materials"]] then
            local mobs = self.Materials[Settings["Select Materials"]]
            local v = self:GetMob(mobs)
            if v then
                repeat task.wait()
                    self:KillMobs(v, "Start Material Farm")
                until not v or not self:IsAlive(v) or not Settings["Start Material Farm"]
            else
                self:TweenToMobSpawn(mobs, "Start Material Farm")
            end
        end
    end, true)
    self:AddFunction("Auto Cyborg", function()
        if game.Players.LocalPlayer.Data.Race.Value == "Cyborg" then
            return
        end
        if not Settings["Inputed Key Cyborg"] then
            fireclickdetector(workspace.Map.CircleIsland.RaidSummon.Button.Main.ClickDetector)
            task.wait()
        else
            if workspace.Map.CircleIsland:FindFirstChild("BlockPart") then
                if self:CheckItem("Core Brain") then
                    fireclickdetector(game:GetService("Workspace").Map.CircleIsland.RaidSummon.Button.Main.ClickDetector)
                    task.wait()
                else
                    local v = self:GetMob("Order")
                    if v then
                        repeat
                            task.wait()
                            self:KillMobs(v, "Auto Cyborg")
                        until Settings["Auto Cyborg"] == false or not v or not v.Parent or not self:IsAlive(v)
                    else
                        if self:CheckItem("Microchip") then
                            fireclickdetector(game:GetService("Workspace").Map.CircleIsland.RaidSummon.Button.Main.ClickDetector)
                            task.wait()
                        else
                            game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Microchip", "2")
                            task.wait()
                        end
                    end
                end
            else
                game.ReplicatedStorage.Remotes.CommF_:InvokeServer("CyborgTrainer", "Buy")
            end
        end
    end, Sea2)
    self:AddFunction("Auto Turn Race V4", function()
        if game.Players.LocalPlayer.Character:FindFirstChild("RaceEnergy") and game.Players.LocalPlayer.Character.RaceEnergy.Value >= 1 and not game.Players.LocalPlayer.Character.RaceTransformed.Value then
            game:GetService("ReplicatedStorage").Events.ActivateRaceV4:Fire()
        end
    end,true)
    self:AddFunction("Auto Turn Race V3", function()
        game.ReplicatedStorage.Remotes.CommE:FireServer("ActivateAbility")
        task.wait(1)
    end,true)
    self:AddFunction("Auto Buy Gears", function()
        game.ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeRace", "Buy")
        task.wait(1)
    end,true)
    self:AddFunction("Auto Random DF", function()
        game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
        task.wait(1)
    end,true)
    self:AddFunction("Auto Store Fruits", function()
        if self:CheckFruit() then
            local Fruit = self:CheckFruit()
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("StoreFruit", Fruit:GetAttribute("OriginalName"), Fruit)
            task.wait(0.5)
        end
    end,true)
    self:AddFunction("Auto Bring Fruits", function()
        if self:GetFruit() then
            local v = self:GetFruit()
            if v.Name == "Fruit " then
                self.Players.LocalPlayer.Character:PivotTo(v.Handle.CFrame)
            else
                firetouchinterest(v.Handle, self.Players.LocalPlayer.Character.PrimaryPart, 1)
                firetouchinterest(v.Handle, self.Players.LocalPlayer.Character.PrimaryPart, 0)
            end
        end
    end,true)
    self:AddFunction("Teleport To Fruit Spawn", function()
        if self:GetFruit() then
            self:Tweento(self:GetFruit().Handle.CFrame)
        end
    end,true)
    self:AddFunction("Auto Farm Nearest", function()
        local Mob = self:GetNearestMobs()
        if Mob then
            repeat
                task.wait()
                self:KillMobs(Mob, "Auto Farm Nearest")
            until Settings["Auto Farm Nearest"] == false or not Mob or not Mob.Parent or not self:IsAlive(Mob)
        end
    end,true,true)
    self:AddFunction('Teleport To Island', function()
        local targetCF
        for _, sea in pairs(Modules.Islands) do
            if sea[Settings["Select Islands"]] then
                targetCF = sea[Settings["Select Islands"]]
                break
            end
        end
        if not targetCF then return end
        self:MiniTween(targetCF, true)
    end,true,true)
    self:AddFunction('Auto Buy Chip', function()
        if self:CheckNotify("loading map...") or self:GetRaidIsland() then return end
        if not self:CheckItem("Special Microchip") then
            if Settings["Auto Get Min Value Fruit To Raid"] then
                if not self:CheckFruit() then
                    self.CommF_:InvokeServer("LoadFruit", self:GetFruitInventory(true))
                    task.wait(0.1)
                else
                    self.CommF_:InvokeServer("RaidsNpc", "Select", Settings["Select Raid"])
                end
            else
                self.CommF_:InvokeServer("RaidsNpc", "Select", Settings["Select Raid"])
            end
        end
    end,true)
    self:AddFunction('Auto Start Raid', function()
        if self:CheckNotify("loading map...") or self:GetRaidIsland() then return end
        if self:CheckItem("Special Microchip") then
            if Sea2 then
            elseif Sea3 then
                self.Players.LocalPlayer.Character:PivotTo(CFrame.new(-5069, 314, -2987))
            end
            fireclickdetector((Sea2 and workspace.Map.CircleIsland.RaidSummon2.Button.Main.ClickDetector or workspace.Map["Boat Castle"].RaidSummon2.Button.Main.ClickDetector))
        end
    end,true)
    self:AddFunction("Auto Claim Gift", function()
        local Time = workspace.Countdown.SurfaceGui.TextLabel.Text
        local Seconds = tonumber(Time:split(":")[3])
        local Minutes = tonumber(Time:split(":")[2])
        local Hours = tonumber(Time:split(":")[1])
        if self:GetGift() then
            self:Tweento(self:GetGift().Box.CFrame)
            if self:GetDistance(self:GetGift().Box.Position) <= 10 then
                fireproximityprompt(self:GetGift().Box.ProximityPrompt)
            end
        else
            if self:GetBigPresent() then
                if self:GetDistance(self:GetBigPresent().Box.Position) <= 10 then
                    fireproximityprompt(self:GetBigPresent().Box.ProximityPrompt)
                else
                    self:Tweento(self:GetBigPresent().Box.CFrame)
                end
            else
                if Hours == 0 and Minutes <= 5 then
                    self:Tweento(workspace.Countdown.CFrame * CFrame.new(0, -60, 0))
                end
            end
        end
    end,true,true)
    self:AddFunction('Auto Next Island & Kill Mobs', function()
        if self.Players.LocalPlayer.PlayerGui.Main.TopHUDList.RaidTimer.Visible then
            local Mob = self:GetNearestMobs()
            if Mob then
                repeat
                    task.wait()
                    if table.find({"Island 1", "Island 2", "Island 3"}, self:GetRaidIsland().Name) then
                        self:KillMobs(Mob, "Auto Next Island & Kill Mobs")
                    else
                        Mob.Humanoid:ChangeState(15)
                        Mob.Head:Destroy()
                        sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                    end
                until Settings["Auto Next Island & Kill Mobs"] == false or not Mob or not Mob.Parent or not self:IsAlive(Mob)
            else
                self:Tweento(self:GetRaidIsland().CFrame * CFrame.new(0, 30, 0))
            end
        end
    end,true,true)
    self:AddFunction('Auto Dungeon World', function()
        if self:GetShirneDungeon() then
            self:Tweento(self:GetShirneDungeon():GetPivot())
            self:SpamAllSkill()
        else
            if self:GetDungeonWorldMob() then
                local Mob = self:GetDungeonWorldMob()
                repeat
                    task.wait()
                    if self:GetShirneDungeon() then break end
                    self:KillMobs(Mob, function()
                        return not Settings["Auto Dungeon World"] or self:GetShirneDungeon()
                    end)
                until Settings["Auto Dungeon World"] == false or not Mob or not Mob.Parent or not self:IsAlive(Mob) or self:GetShirneDungeon() or self:GetDistance(Mob.PrimaryPart.Position) >= 501 
            else
                local DungeonDoor = self:GetDungeonWorldDoors()
                if DungeonDoor then
                    self:Tweento(DungeonDoor.ExitTeleporter.Root.CFrame)
                end
            end
        end
    end,Sea2, true)
end

Modules:LoadFunctions()
task.spawn(function()
    while task.wait() do
        local dex, ngu = pcall(function()
            if BringMob then
                sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", 3150)
                Modules:BringMob()
            end
            Modules:StartAttack()
        end)
        if not dex then
            warn(ngu)
        end
    end
end)

--  CIRCULAR HIDE / UNHIDE UI BUTTON
pcall(function()
    local CoreGui = game:GetService("CoreGui")
    local parentGui = (gethui and gethui()) or CoreGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    if parentGui:FindFirstChild("KoalaHub_ToggleUI") then
        parentGui.KoalaHub_ToggleUI:Destroy()
    end

    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "KoalaHub_ToggleUI"
    ToggleGui.ResetOnSpawn = false
    ToggleGui.Parent = parentGui

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleButton"
    ToggleBtn.Parent = ToggleGui
    ToggleBtn.Size = UDim2.fromOffset(45, 45)
    ToggleBtn.Position = UDim2.new(0, 15, 0.5, -22)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    ToggleBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
    ToggleBtn.Text = "🐨"
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 14
    ToggleBtn.Active = true
    ToggleBtn.Draggable = true

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = ToggleBtn

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(0, 170, 255)
    UIStroke.Thickness = 2
    UIStroke.Parent = ToggleBtn

    ToggleBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local VIM = game:GetService("VirtualInputManager")
            VIM:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
            task.wait(0.02)
            VIM:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
        end)
    end)
end)

--  FLUENT UI INTERFACE
local Fluent           = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager      = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Koala Hub v2.1 | Blox Fruits",
    SubTitle = "discord.gg/KoalaHub",
    TabWidth = 160,
    Size = UDim2.fromOffset(550, 350),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main     = Window:AddTab({ Title = "Main", Icon = "home" }),
    Shop     = Window:AddTab({ Title = "Shop Tab", Icon = "shopping-cart" }),
    Config   = Window:AddTab({ Title = "Config Farm", Icon = "settings" }),
    Stack    = Window:AddTab({ Title = "Stack Farming", Icon = "layers" }),
    Stats    = Window:AddTab({ Title = "Stats", Icon = "bar-chart-2" }),
    Item     = Window:AddTab({ Title = "Item Farming", Icon = "package" }),
    Local    = Window:AddTab({ Title = "LocalPlayer", Icon = "user" }),
    Fruits   = Window:AddTab({ Title = "Fruits & Dungeon", Icon = "cherry" }),
    Race     = Window:AddTab({ Title = "Upgrade Race", Icon = "trophy" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "sliders" }),
}

local function toggleHelper(name, val)
    Settings[name] = val
    if Functions[name] and Functions[name].Enable then
        Functions[name]["Real Function"]()
    end
end

-- MAIN TAB
local LevelFarmSection = Tabs.Main:AddSection("Level Farming")

LevelFarmSection:AddToggle("AutoFarmLevel", {
    Title = "Auto Farm Level",
    Default = Settings["Auto Farm Level"] or false,
    Callback = function(Value)
        toggleHelper("Auto Farm Level", Value)
    end
})

LevelFarmSection:AddToggle("AutoFarmCandy", {
    Title = "Auto Farm Candy (New)",
    Default = Settings["Auto Farm Candy (New)"] or false,
    Callback = function(Value)
        toggleHelper("Auto Farm Candy (New)", Value)
    end
})

local NearestFarmSection = Tabs.Main:AddSection("Nearest Farm")

NearestFarmSection:AddToggle("AutoFarmNearest", {
    Title = "Auto Farm Nearest",
    Default = Settings["Auto Farm Nearest"] or false,
    Callback = function(Value)
        toggleHelper("Auto Farm Nearest", Value)
    end
})

local BonesFarmSection = Tabs.Main:AddSection("Bones Farming")

BonesFarmSection:AddToggle("AutoFarmBones", {
    Title = "Auto Farm Bones",
    Default = Settings["Auto Farm Bones"] or false,
    Callback = function(Value)
        toggleHelper("Auto Farm Bones", Value)
    end
})

local CakePrinceSection = Tabs.Main:AddSection("Cake Prince Farming")

local CakePrinceStatus = CakePrinceSection:AddParagraph({
    Title = "Cake Prince Status",
    Content = "no explain"
})

CakePrinceSection:AddToggle("AutoKatakuri", {
    Title = "Auto Katakuri",
    Default = Settings["Auto Katakuri"] or false,
    Callback = function(Value)
        toggleHelper("Auto Katakuri", Value)
    end
})

CakePrinceSection:AddToggle("AutoSummonKatakuri", {
    Title = "Auto Summon Katakuri",
    Default = Settings["Auto Summon Katakuri"] or false,
    Callback = function(Value)
        Settings["Auto Summon Katakuri"] = Value
    end
})

local SwordMasterySection = Tabs.Main:AddSection("Sword Mastery Farming")

SwordMasterySection:AddToggle("AutoFarmSwordMastery600", {
    Title = "Auto Farm Sword Mastery 600",
    Default = Settings["Auto Farm Sword Mastery 600"] or false,
    Callback = function(Value)
        toggleHelper("Auto Farm Sword Mastery 600", Value)
    end
})

local ChestFarmSection = Tabs.Main:AddSection("Chest Farming")

ChestFarmSection:AddToggle("AutoChest", {
    Title = "Auto Chest",
    Default = Settings["Auto Chest"] or false,
    Callback = function(Value)
        toggleHelper("Auto Chest", Value)
    end
})

ChestFarmSection:AddDropdown("AutoChestMethods", {
    Title = "Auto Chest Methods",
    Values = {"Tween", "Bypass (RISK)"},
    Default = Settings["Auto Chest Methods"] or "Tween",
    Callback = function(Value)
        Settings["Auto Chest Methods"] = Value
    end
})

ChestFarmSection:AddToggle("StopWhenFoundLegendary", {
    Title = "Stop When Found Legendary",
    Default = Settings["Stop When Found Legendary"] or false,
    Callback = function(Value)
        Settings["Stop When Found Legendary"] = Value
    end
})

-- SHOP TAB
local CodesSection = Tabs.Shop:AddSection("Codes")

CodesSection:AddButton({
    Title = "Redeem All Codes",
    Callback = function()
        for _, v in pairs({
            "LIGHTNINGABUSE","fudd10","fudd10_V2","Chandler","BIGNEWS",
            "KITT_RESET","Sub2UncleKizaru","SUB2GAMERROBOT_RESET1","Sub2Fer999",
            "Enyu_is_Pro","JCWK","StarcodeHEO","MagicBUS","KittGaming",
            "Sub2CaptainMaui","Sub2OfficialNoobie","TheGreatAce","Sub2NoobMaster123",
            "Sub2Daigrock","Axiore","StrawHatMaine","TantaiGaming","Bluxxy",
            "SUB2GAMERROBOT_EXP1"
        }) do
            Modules.ReplicatedStorage.Remotes.Redeem:InvokeServer(v)
        end
    end
})

local MeleeBuySection = Tabs.Shop:AddSection("Melee Buy")

MeleeBuySection:AddDropdown("SelectMelee", {
    Title = "Select Melee",
    Values = Modules.RealMeleeList,
    Default = Modules.RealMeleeList[1] or "",
    Callback = function(Value)
        Settings["Select Melee"] = Value
    end
})

MeleeBuySection:AddToggle("AutoBuyMeleeSelect", {
    Title = "Auto Buy Melee Select",
    Default = Settings["Auto Buy Melee Select"] or false,
    Callback = function(Value)
        toggleHelper("Auto Buy Melee Select", Value)
    end
})

local TravelSection = Tabs.Shop:AddSection("Travel Teleport")

TravelSection:AddButton({
    Title = "Teleport To Travel Main",
    Callback = function()
        Modules.ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelMain")
    end
})

TravelSection:AddButton({
    Title = "Teleport To Travel Dressrosa",
    Callback = function()
        Modules.ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")
    end
})

TravelSection:AddButton({
    Title = "Teleport To Travel Zou",
    Callback = function()
        Modules.ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelZou")
    end
})

TravelSection:AddButton({
    Title = "Teleport To Dungeon World",
    Callback = function()
        Modules.ReplicatedStorage.Modules.Net["RF/DungeonNPCNetworkFunction"]:InvokeServer("TeleportToDungeonHub", false)
    end
})

local HakiSection = Tabs.Shop:AddSection("Haki")

HakiSection:AddButton({
    Title = "Buy Buso (25,000$)",
    Callback = function()
        Modules.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Buso")
    end
})

HakiSection:AddButton({
    Title = "Buy Geppo (10,000$)",
    Callback = function()
        Modules.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Geppo")
    end
})

HakiSection:AddButton({
    Title = "Buy Soru (100,000$)",
    Callback = function()
        Modules.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Soru")
    end
})

HakiSection:AddButton({
    Title = "Buy Observation - Ken Haki (700,000$)",
    Callback = function()
        if Modules:CheckInventory("Saber") then
            Modules.ReplicatedStorage.Remotes.CommF_:InvokeServer("KenTalk", "Buy")
        else
            Fluent:Notify({
                Title = "Buy Failed",
                Content = "You need the Saber sword first!",
                Duration = 5
            })
        end
    end
})

local ShopOthersSection = Tabs.Shop:AddSection("Others")

ShopOthersSection:AddToggle("AutoBuyHakiColor", {
    Title = "Auto Buy Haki Color",
    Default = Settings["Auto Buy Haki Color"] or false,
    Callback = function(Value)
        toggleHelper("Auto Buy Haki Color", Value)
    end
})

ShopOthersSection:AddToggle("AutoRandomSurprises", {
    Title = "Auto Random Surprises",
    Default = Settings["Auto Random Surprises"] or false,
    Callback = function(Value)
        toggleHelper("Auto Random Surprises", Value)
    end
})

ShopOthersSection:AddToggle("AutoBuyGears", {
    Title = "Auto Buy Gears",
    Default = Settings["Auto Buy Gears"] or false,
    Callback = function(Value)
        toggleHelper("Auto Buy Gears", Value)
    end
})

-- CONFIG FARM TAB
local GeneralConfigSection = Tabs.Config:AddSection("General")

GeneralConfigSection:AddToggle("AntiBan", {
    Title = "Anti Ban",
    Default = Settings["Anti Ban"] or false,
    Callback = function(Value)
        toggleHelper("Anti Ban", Value)
    end
})

GeneralConfigSection:AddDropdown("SelectTool", {
    Title = "Select Tool",
    Values = {"Melee", "Sword", "Blox Fruit"},
    Default = Settings["Select Tool"] or "Melee",
    Callback = function(Value)
        Settings["Select Tool"] = Value
    end
})

GeneralConfigSection:AddToggle("AutoBuso", {
    Title = "Auto Buso",
    Default = Settings["Auto Buso"] or false,
    Callback = function(Value)
        toggleHelper("Auto Buso", Value)
    end
})

GeneralConfigSection:AddToggle("AutoKenObservation", {
    Title = "Auto Ken (Observation)",
    Default = Settings["Auto Ken (Observation)"] or false,
    Callback = function(Value)
        toggleHelper("Auto Ken (Observation)", Value)
    end
})

GeneralConfigSection:AddToggle("AutoTurnRaceV4", {
    Title = "Auto Turn Race V4",
    Default = Settings["Auto Turn Race V4"] or false,
    Callback = function(Value)
        toggleHelper("Auto Turn Race V4", Value)
    end
})

GeneralConfigSection:AddToggle("AutoTurnRaceV3", {
    Title = "Auto Turn Race V3",
    Default = Settings["Auto Turn Race V3"] or false,
    Callback = function(Value)
        toggleHelper("Auto Turn Race V3", Value)
    end
})

local TweenSection = Tabs.Config:AddSection("Tween Settings")

TweenSection:AddToggle("UpYWhenLowHealth", {
    Title = "Up Y When Low Health",
    Default = Settings["Up Y When Low Health"] or false,
    Callback = function(Value)
        Settings["Up Y When Low Health"] = Value
    end
})

TweenSection:AddToggle("SameY", {
    Title = "Same Y",
    Default = Settings["Same Y"] or false,
    Callback = function(Value)
        Settings["Same Y"] = Value
    end
})

TweenSection:AddToggle("UpY", {
    Title = "Up Y",
    Default = Settings["Up Y"] or false,
    Callback = function(Value)
        Settings["Up Y"] = Value
    end
})

TweenSection:AddSlider("TweenSpeed", {
    Title = "Tween Speed",
    Min = 100,
    Max = 500,
    Default = Settings["Tween Speed"] or 350,
    Rounding = 0,
    Callback = function(Value)
        Settings["Tween Speed"] = Value
    end
})

TweenSection:AddToggle("TweenPause", {
    Title = "Tween Pause",
    Default = Settings["Tween Pause"] or false,
    Callback = function(Value)
        Settings["Tween Pause"] = Value
    end
})



local FastAttackSection = Tabs.Config:AddSection("Fast Attack Settings")

FastAttackSection:AddToggle("AttackPlayers", {
    Title = "Attack Players",
    Default = Settings["Attack Players"] or false,
    Callback = function(Value)
        Settings["Attack Players"] = Value
    end
})

FastAttackSection:AddToggle("AttackMobs", {
    Title = "Attack Mobs",
    Default = Settings["Attack Mobs"] or false,
    Callback = function(Value)
        Settings["Attack Mobs"] = Value
    end
})

-- STACK FARMING TAB
local AllSeaSection = Tabs.Stack:AddSection("All Sea Function")

AllSeaSection:AddToggle("AutoCollectBerries", {
    Title = "Auto Collect Berries",
    Default = Settings["Auto Collect Berries"] or false,
    Callback = function(Value)
        toggleHelper("Auto Collect Berries", Value)
    end
})

local MaterialsSection = Tabs.Stack:AddSection("Materials Farm")

MaterialsSection:AddDropdown("SelectMaterials", {
    Title = "Select Materials",
    Values = {"Ectoplasm", "Conjured Cocoa"},
    Default = Settings["Select Materials"] or "Ectoplasm",
    Callback = function(Value)
        Settings["Select Materials"] = Value
    end
})

MaterialsSection:AddToggle("StartMaterialFarm", {
    Title = "Start Material Farm",
    Default = Settings["Start Material Farm"] or false,
    Callback = function(Value)
        toggleHelper("Start Material Farm", Value)
    end
})

local Sea2Section = Tabs.Stack:AddSection("Sea 2 Functions")

Sea2Section:AddToggle("AutoTravelDressrosa", {
    Title = "Auto Travel Dressrosa",
    Default = Settings["Auto Travel Dressrosa"] or false,
    Callback = function(Value)
        toggleHelper("Auto Travel Dressrosa", Value)
    end
})

Sea2Section:AddToggle("AutoBartiloQuest", {
    Title = "Auto Bartilo Quest",
    Default = Settings["Auto Bartilo Quest"] or false,
    Callback = function(Value)
        toggleHelper("Auto Bartilo Quest", Value)
    end
})

Sea2Section:AddToggle("AutoTravelZou", {
    Title = "Auto Travel Zou",
    Default = Settings["Auto Travel Zou"] or false,
    Callback = function(Value)
        toggleHelper("Auto Travel Zou", Value)
    end
})

local TyrantSection = Tabs.Stack:AddSection("Tyrant Of The Skies")

TyrantSection:AddParagraph({
    Title = "Tyrant of the Skies",
    Content = "Not enough eyes"
})

TyrantSection:AddToggle("AutoTyrantOfTheSkies", {
    Title = "Auto Tyrant of the Skies",
    Default = Settings["Auto Tyrant of the Skies"] or false,
    Callback = function(Value)
        toggleHelper("Auto Tyrant of the Skies", Value)
    end
})

local RipIndraSection = Tabs.Stack:AddSection("Rip Indra")

RipIndraSection:AddToggle("AutoRipIndra", {
    Title = "Auto Rip Indra",
    Default = Settings["Auto Rip Indra"] or false,
    Callback = function(Value)
        toggleHelper("Auto Rip Indra", Value)
    end
})

local EliteSection = Tabs.Stack:AddSection("Elite Hunter")

local EliteStatus = EliteSection:AddParagraph({
    Title = "Elite Hunter Status",
    Content = "Status: idk | Progress: 0"
})

EliteSection:AddToggle("AutoEliteHunter", {
    Title = "Auto Elite Hunter",
    Default = Settings["Auto Elite Hunter"] or false,
    Callback = function(Value)
        toggleHelper("Auto Elite Hunter", Value)
    end
})

local DoughKingSection = Tabs.Stack:AddSection("Dough King")

DoughKingSection:AddToggle("AutoDoughKing", {
    Title = "Auto Dough King",
    Default = Settings["Auto Dough King"] or false,
    Callback = function(Value)
        toggleHelper("Auto Dough King", Value)
    end
})

DoughKingSection:AddDropdown("FindGodsChaliceMethod", {
    Title = "Find God's Chalice Method",
    Values = {"Elite Hunter", "Auto Chest", "Auto Chest (Bypass)"},
    Default = Settings["Find God's Chalice Method"] or "Elite Hunter",
    Callback = function(Value)
        Settings["Find God's Chalice Method"] = Value
    end
})

local SoulReaperSection = Tabs.Stack:AddSection("Soul Reaper")

SoulReaperSection:AddToggle("AutoSoulReaper", {
    Title = "Auto Soul Reaper",
    Default = Settings["Auto Soul Reaper"] or false,
    Callback = function(Value)
        toggleHelper("Auto Soul Reaper", Value)
    end
})

local GhoulCyborgSection = Tabs.Stack:AddSection("Ghoul & Cyborg")

GhoulCyborgSection:AddToggle("AutoGhoulRace", {
    Title = "Auto Ghoul Race",
    Default = Settings["Auto Ghoul Race"] or false,
    Callback = function(Value)
        toggleHelper("Auto Ghoul Race", Value)
    end
})

GhoulCyborgSection:AddToggle("AutoCyborg", {
    Title = "Auto Cyborg",
    Default = Settings["Auto Cyborg"] or false,
    Callback = function(Value)
        toggleHelper("Auto Cyborg", Value)
    end
})

-- STATS TAB
local StatsSection = Tabs.Stats:AddSection("Stats Points Allocator")

StatsSection:AddDropdown("SelectStatsToAdd", {
    Title = "Select Stats to Add",
    Values = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"},
    Multi = true,
    Default = { Melee = true },
    Callback = function(Value)
        Settings["Select Stats to Add"] = Value
    end
})

StatsSection:AddToggle("AutoAddStats", {
    Title = "Auto Add Stats",
    Default = Settings["Auto Add Stats"] or false,
    Callback = function(Value)
        toggleHelper("Auto Add Stats", Value)
    end
})

-- ITEM FARMING TAB
local SaberSection = Tabs.Item:AddSection("Saber")

SaberSection:AddToggle("AutoSaber", {
    Title = "Auto Saber",
    Default = Settings["Auto Saber"] or false,
    Callback = function(Value)
        toggleHelper("Auto Saber", Value)
    end
})

local KatanaSection = Tabs.Item:AddSection("Yama & Tushita & Dual Cursed Katana")

KatanaSection:AddToggle("AutoTushita", {
    Title = "Auto Tushita",
    Default = Settings["Auto Tushita"] or false,
    Callback = function(Value)
        toggleHelper("Auto Tushita", Value)
    end
})

KatanaSection:AddToggle("AutoYama", {
    Title = "Auto Yama",
    Default = Settings["Auto Yama"] or false,
    Callback = function(Value)
        toggleHelper("Auto Yama", Value)
    end
})

KatanaSection:AddToggle("AutoDualCursedKatana", {
    Title = "Auto Dual Cursed Katana",
    Default = Settings["Auto Dual Cursed Katana"] or false,
    Callback = function(Value)
        toggleHelper("Auto Dual Cursed Katana", Value)
    end
})

KatanaSection:AddButton({
    Title = "Delete Haze Lighting",
    Callback = function()
        if game:GetService("Lighting").LightingLayers:FindFirstChild("Haze") then
            game:GetService("Lighting").LightingLayers.Haze:Destroy()
        end
    end
})

local SoulGuitarSection = Tabs.Item:AddSection("Soul Guitar")

SoulGuitarSection:AddToggle("AutoSoulGuitar", {
    Title = "Auto Soul Guitar",
    Default = Settings["Auto Soul Guitar"] or false,
    Callback = function(Value)
        toggleHelper("Auto Soul Guitar", Value)
    end
})

-- LOCALPLAYER TAB
local IslandTeleportSection = Tabs.Local:AddSection("Teleport Island")

local IslandList = {}
local currentSea = (Sea1 and "Sea 1") or (Sea2 and "Sea 2") or (Sea3 and "Sea 3")
if currentSea and Modules.Islands[currentSea] then
    for name, _ in pairs(Modules.Islands[currentSea]) do
        table.insert(IslandList, name)
    end
    table.sort(IslandList)
end

IslandTeleportSection:AddDropdown("SelectIslands", {
    Title = "Select Islands",
    Values = IslandList,
    Default = IslandList[1] or "",
    Callback = function(Value)
        Settings["Select Islands"] = Value
    end
})

IslandTeleportSection:AddToggle("TeleportToIsland", {
    Title = "Teleport To Island",
    Default = Settings["Teleport To Island"] or false,
    Callback = function(Value)
        toggleHelper("Teleport To Island", Value)
    end
})

-- FRUITS & DUNGEON TAB
local FruitsSection = Tabs.Fruits:AddSection("Fruits")

FruitsSection:AddToggle("AutoRandomDF", {
    Title = "Auto Random DF",
    Default = Settings["Auto Random DF"] or false,
    Callback = function(Value)
        toggleHelper("Auto Random DF", Value)
    end
})

FruitsSection:AddToggle("AutoStoreFruits", {
    Title = "Auto Store Fruits",
    Default = Settings["Auto Store Fruits"] or false,
    Callback = function(Value)
        toggleHelper("Auto Store Fruits", Value)
    end
})

FruitsSection:AddToggle("AutoBringFruits", {
    Title = "Auto Bring Fruits",
    Default = Settings["Auto Bring Fruits"] or false,
    Callback = function(Value)
        toggleHelper("Auto Bring Fruits", Value)
    end
})

FruitsSection:AddToggle("TeleportToFruitSpawn", {
    Title = "Teleport To Fruit Spawn",
    Default = Settings["Teleport To Fruit Spawn"] or false,
    Callback = function(Value)
        toggleHelper("Teleport To Fruit Spawn", Value)
    end
})

local DungeonWorldSection = Tabs.Fruits:AddSection("Dungeons World")

DungeonWorldSection:AddToggle("AutoDungeonWorld", {
    Title = "Auto Dungeon World",
    Default = Settings["Auto Dungeon World"] or false,
    Callback = function(Value)
        toggleHelper("Auto Dungeon World", Value)
    end
})

local DungeonSection = Tabs.Fruits:AddSection("Dungeon")

DungeonSection:AddDropdown("SelectRaid", {
    Title = "Select Raid",
    Values = Modules.Dungeon,
    Default = Modules.Dungeon[1] or "",
    Callback = function(Value)
        Settings["Select Raid"] = Value
    end
})

DungeonSection:AddToggle("AutoBuyChip", {
    Title = "Auto Buy Chip",
    Default = Settings["Auto Buy Chip"] or false,
    Callback = function(Value)
        toggleHelper("Auto Buy Chip", Value)
    end
})

DungeonSection:AddToggle("AutoGetMinValueFruitToRaid", {
    Title = "Auto Get Min Value Fruit To Raid",
    Default = Settings["Auto Get Min Value Fruit To Raid"] or false,
    Callback = function(Value)
        Settings["Auto Get Min Value Fruit To Raid"] = Value
    end
})

DungeonSection:AddToggle("AutoStartRaid", {
    Title = "Auto Start Raid",
    Default = Settings["Auto Start Raid"] or false,
    Callback = function(Value)
        toggleHelper("Auto Start Raid", Value)
    end
})

DungeonSection:AddToggle("AutoNextIslandKillMobs", {
    Title = "Auto Next Island & Kill Mobs",
    Default = Settings["Auto Next Island & Kill Mobs"] or false,
    Callback = function(Value)
        toggleHelper("Auto Next Island & Kill Mobs", Value)
    end
})

-- UPGRADE RACE TAB
local RaceSection = Tabs.Race:AddSection("Upgraded Race")

RaceSection:AddToggle("AutoRaceV2V3", {
    Title = "Auto Race V2 - V3",
    Default = Settings["Auto Race V2 - V3"] or false,
    Callback = function(Value)
        toggleHelper("Auto Race V2 - V3", Value)
    end
})

-- SETTINGS TAB
local ServerSection = Tabs.Settings:AddSection("Server Job Id")

ServerSection:AddInput("InputServerJobId", {
    Title = "Input Server Job Id",
    Default = "",
    Placeholder = "Enter Job ID...",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        InputJobId = Value
    end
})

ServerSection:AddButton({
    Title = "Join Server Job Id",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(
            game.PlaceId,
            InputJobId,
            game.Players.LocalPlayer
        )
    end
})

-- DYNAMIC PARAGRAPH UPDATER & SAVE MANAGER
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local eliteProgress = Modules.CommF_:InvokeServer("EliteHunter", "Progress")
            local eliteText = "Status: " .. (Modules:GetElite() and "Spawned ✔" or "Not Spawned ✘") .. " | Process: " .. tostring(eliteProgress or "?")
            EliteStatus:SetTitle("Elite Hunter Status")
            EliteStatus:SetDesc(eliteText)

            local rawCake = Modules.ReplicatedStorage.Remotes.CommF_:InvokeServer("CakePrinceSpawner", true)
            local cakeCount = rawCake and string.gsub(tostring(rawCake), "%D", "") or "?"
            local cakeText = Modules:GetMob("Cake Prince", true) and "Spawned ✔" or ("Kill: " .. tostring(cakeCount) .. " Mobs")
            CakePrinceStatus:SetTitle("Cake Prince Status")
            CakePrinceStatus:SetDesc(cakeText)
        end)
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("KoalaHub")
SaveManager:SetFolder("KoalaHub/blox-fruits")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Koala Hub v2.1",
    Content = "Script loaded successfully with Fluent UI!",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
