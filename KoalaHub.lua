-- Koala Hub | SlimeRNG
-- Discord: https://discord.gg/ytYpVQHvab

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

local Fluent = nil
local function tryLoad(url)
    local status, lib = pcall(function()
        local raw = game:HttpGet(url, true)
        return loadstring(raw)()
    end)
    if status and lib then
        Fluent = lib
        return true
    end
    return false
end

local urls = {
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua",
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/refs/heads/main/main.lua"
}

for _, url in ipairs(urls) do
    if tryLoad(url) then break end
    task.wait(0.5)
end

if not Fluent then
    local stub = {}
    stub.CreateWindow = function() return { AddTab = function() return { AddToggle = function() end, AddSlider = function() end, AddButton = function() end, AddLabel = function() end, AddInput = function() end, AddParagraph = function() end, AddDropdown = function() end } end } end
    stub.Notify = function() end
    stub:Destroy = function() end
    Fluent = stub
end

local SaveManager = nil
pcall(function()
    SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
end)
if not SaveManager then
    SaveManager = { SetLibrary = function() end, BuildConfigTab = function() end }
end

-- ================== GLOBAL STATE ==================
local Toggles = {
    AutoMob = false, AutoLoot = false, AutoRecipe = false, AutoCraft = false, AutoBoost = false, AutoIndex = false,
    Rebirth = false, Zones = false, Equip = false, Roll = false, AutoUpgrade = false,
    Noclip = false, InfiniteJump = false, AntiRagdoll = false, AutoArea = false, AutoFeed = false,
    DisableAutoRejoin = false, AntiAFK = true, BlackScreen = false
}
local Settings = { TweenSpeed = 75, WalkSpeed = 16, JumpPower = 50, WebhookURL = "" }
local pauseMobTweenUntil = 0
local FeedEquippedIndex = 1
local LastHatchedText = "None"

-- ================== ANTI-AFK ==================
local function setupAntiAFK()
    pcall(function()
        for _, conn in pairs(getconnections(LocalPlayer.Idled)) do conn:Disable() end
    end)
    LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end
setupAntiAFK()

-- ================== BLACK SCREEN ==================
local blackScreenGui = Instance.new("ScreenGui")
blackScreenGui.Name = "KoalaBlackScreen"
blackScreenGui.IgnoreGuiInset = true
blackScreenGui.DisplayOrder = 9999
blackScreenGui.Enabled = false
blackScreenGui.Parent = CoreGui
local blackFrame = Instance.new("Frame", blackScreenGui)
blackFrame.Size = UDim2.new(1, 0, 1, 0)
blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
local afkText = Instance.new("TextLabel", blackFrame)
afkText.Size = UDim2.new(1, 0, 1, 0)
afkText.BackgroundTransparency = 1
afkText.Text = "KOALA HUB AFK MODE ACTIVE\n\n(Screen is black to save power & reduce lag)"
afkText.TextColor3 = Color3.fromRGB(150, 150, 150)
afkText.Font = Enum.Font.GothamBold
afkText.TextSize = 24

-- ================== UTILITY FUNCTIONS ==================
local function formatNumber(value)
    value = tonumber(value) or 0
    if value >= 1e12 then return string.format("%.2fT", value / 1e12)
    elseif value >= 1e9 then return string.format("%.2fB", value / 1e9)
    elseif value >= 1e6 then return string.format("%.2fM", value / 1e6)
    elseif value >= 1e3 then return string.format("%.2fK", value / 1e3)
    end
    return tostring(math.floor(value))
end

local function RejoinServer()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end

local function ServerHop()
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if not req then return end
    local res = req({Url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"})
    if res and res.StatusCode == 200 then
        local body = HttpService:JSONDecode(res.Body)
        if body and body.data then
            local servers = {}
            for _, v in pairs(body.data) do
                if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(servers, v.id)
                end
            end
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
            else RejoinServer() end
        end
    end
end

local function sendWebhook(message)
    if Settings.WebhookURL == "" then return end
    local req = (syn and syn.request) or http_request or request
    if not req then return end
    local data = {["content"] = message}
    pcall(function()
        req({
            Url = Settings.WebhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end

local Window = Fluent:CreateWindow({
    Title = "Koala Hub",
    SubTitle = "discord.gg/ytYpVQHvab",
    TabWidth = 160,
    Size = UDim2.fromOffset(620, 480),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main     = Window:AddTab({ Title = "Main",     Icon = "home" }),
    Farming  = Window:AddTab({ Title = "Farming",  Icon = "zap" }),
    Shop     = Window:AddTab({ Title = "Shop",     Icon = "shopping-cart" }),
    Misc     = Window:AddTab({ Title = "Misc",     Icon = "more-horizontal" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- ================== MAIN TAB ==================
Tabs.Main:AddParagraph({ Title = "Koala Hub", Content = "Free, safe, and powerful script for SlimeRNG.\nDiscord: discord.gg/ytYpVQHvab" })
local ProgressionLabel = Tabs.Main:AddLabel("📊 Loading stats... (game data may take a moment)")
Tabs.Main:AddButton({ Title = "Copy Discord Invite", Callback = function()
    pcall(function() setclipboard("https://discord.gg/ytYpVQHvab") end)
    Fluent:Notify({ Title = "Copied!", Content = "Invite copied to clipboard.", Duration = 3 })
end })

-- ================== FARMING TAB ==================
Tabs.Farming:AddToggle({ Title = "Auto Tween to Mobs (Lowest HP)", Default = false, Callback = function(v) Toggles.AutoMob = v end })
Tabs.Farming:AddSlider({ Title = "Tween Speed", Default = 75, Min = 10, Max = 300, Rounding = 0, Callback = function(v) Settings.TweenSpeed = v end })
Tabs.Farming:AddToggle({ Title = "Auto Roll", Default = false, Callback = function(v) Toggles.Roll = v end })
Tabs.Farming:AddToggle({ Title = "Auto Rebirth", Default = false, Callback = function(v) Toggles.Rebirth = v end })
Tabs.Farming:AddToggle({ Title = "Auto Equip Best", Default = false, Callback = function(v) Toggles.Equip = v end })
Tabs.Farming:AddToggle({ Title = "Auto Feed Equipped", Default = false, Callback = function(v) Toggles.AutoFeed = v end })
Tabs.Farming:AddToggle({ Title = "Auto Teleport to Max Zone", Default = false, Callback = function(v) Toggles.AutoArea = v end })
Tabs.Farming:AddToggle({ Title = "Auto Collect Drops", Default = false, Callback = function(v) Toggles.AutoLoot = v end })

-- ================== SHOP TAB ==================
Tabs.Shop:AddToggle({ Title = "Auto Buy Zones", Default = false, Callback = function(v) Toggles.Zones = v end })
Tabs.Shop:AddToggle({ Title = "Smart Auto Upgrade", Default = false, Callback = function(v) Toggles.AutoUpgrade = v end })
Tabs.Shop:AddToggle({ Title = "Auto Use Boosts", Default = false, Callback = function(v) Toggles.AutoBoost = v end })
Tabs.Shop:AddToggle({ Title = "Smart Auto Craft", Default = false, Callback = function(v) Toggles.AutoCraft = v end })
Tabs.Shop:AddToggle({ Title = "Auto Claim Recipes", Default = false, Callback = function(v) Toggles.AutoRecipe = v end })
Tabs.Shop:AddToggle({ Title = "Auto Claim Index Rewards", Default = false, Callback = function(v) Toggles.AutoIndex = v end })

-- ================== MISC TAB ==================
Tabs.Misc:AddToggle({ Title = "Anti-AFK", Default = true, Callback = function(v) Toggles.AntiAFK = v end })
Tabs.Misc:AddToggle({ Title = "Black Screen (Anti-Lag)", Default = false, Callback = function(v) Toggles.BlackScreen = v; blackScreenGui.Enabled = v; pcall(function() RunService:Set3dRenderingEnabled(not v) end) end })
Tabs.Misc:AddToggle({ Title = "Disable Auto-Rejoin", Default = false, Callback = function(v) Toggles.DisableAutoRejoin = v; if not v then pcall(function() Modules and Modules.AutoRejoinServiceClient and Modules.AutoRejoinServiceClient:enable() end) end })
Tabs.Misc:AddToggle({ Title = "Noclip", Default = false, Callback = function(v) Toggles.Noclip = v end })
Tabs.Misc:AddToggle({ Title = "Infinite Jump", Default = false, Callback = function(v) Toggles.InfiniteJump = v end })
Tabs.Misc:AddToggle({ Title = "Anti Ragdoll", Default = false, Callback = function(v) Toggles.AntiRagdoll = v end })
Tabs.Misc:AddSlider({ Title = "Walk Speed", Default = 16, Min = 16, Max = 250, Rounding = 0, Callback = function(v) Settings.WalkSpeed = v end })
Tabs.Misc:AddSlider({ Title = "Jump Power", Default = 50, Min = 50, Max = 500, Rounding = 0, Callback = function(v) Settings.JumpPower = v end })
Tabs.Misc:AddButton({ Title = "Server Hop", Callback = function() ServerHop() end })
Tabs.Misc:AddButton({ Title = "Rejoin Server", Callback = function() RejoinServer() end })
Tabs.Misc:AddButton({ Title = "Reset Character", Callback = function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end })
Tabs.Misc:AddButton({ Title = "Unload UI", Callback = function()
    blackScreenGui:Destroy()
    pcall(function() RunService:Set3dRenderingEnabled(true) end)
    Fluent:Destroy()
end })

-- ================== SETTINGS TAB ==================
Tabs.Settings:AddInput({
    Title = "Webhook URL",
    Description = "Discord webhook for event logs.",
    Default = "",
    Callback = function(v) Settings.WebhookURL = v end
})
Tabs.Settings:AddButton({ Title = "Test Webhook", Callback = function()
    sendWebhook("✅ Koala Hub webhook test successful!")
    Fluent:Notify({ Title = "Webhook", Content = "Test message sent.", Duration = 3 })
end })
SaveManager:SetLibrary(Fluent)
SaveManager:BuildConfigTab(Tabs.Settings)

-- ================== PLAYER MODS LOOP ==================
task.spawn(function()
    while true do
        local char = LocalPlayer.Character
        if char then
            if Toggles.Noclip then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
            if Toggles.InfiniteJump then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = Settings.JumpPower > 0 and Settings.JumpPower or 50; hum.Jump = true end
            end
            if Toggles.AntiRagdoll then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
            end
            if Settings.WalkSpeed then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = Settings.WalkSpeed end
            end
        end
        task.wait(0.2)
    end
end)

-- ================== GAME-DEPENDENT PART ==================
task.spawn(function()
    local success = pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Packages = ReplicatedStorage:WaitForChild("Packages")
        local Source = ReplicatedStorage:WaitForChild("Source")
        local Features = Source:WaitForChild("Features")
        local Assets = ReplicatedStorage:WaitForChild("Assets")
        local GameItems = Source:WaitForChild("Game"):WaitForChild("Items")

        local rPath = Packages:WaitForChild("_Index"):WaitForChild("leifstout_networker@0.3.1"):WaitForChild("networker"):WaitForChild("_remotes")
        local function getRemote(s) return rPath:WaitForChild(s):WaitForChild("RemoteFunction") end

        local Remotes = {
            Rebirth = getRemote("RebirthService"),
            Zones = getRemote("ZonesService"),
            Inventory = getRemote("InventoryService"),
            Roll = getRemote("RollService"),
            Loot = getRemote("LootService"),
            Crafting = getRemote("CraftingService"),
            Boost = getRemote("BoostService"),
            Index = getRemote("IndexService"),
            Upgrade = getRemote("UpgradeService"),
        }

        local Modules = {
            DataServiceClient = require(Packages:WaitForChild("DataService")).client,
            UpgradeTree = require(Features:WaitForChild("Upgrades"):WaitForChild("UpgradeTree")),
            UpgradeCounterUtils = require(Features:WaitForChild("Upgrades"):WaitForChild("UpgradeCounterUtils")),
            BoostServiceUtils = require(Features:WaitForChild("Boosts"):WaitForChild("BoostServiceUtils")),
            CraftingServiceUtils = require(Features:WaitForChild("Crafting"):WaitForChild("CraftingServiceUtils")),
            InventoryItemUtils = require(Features:WaitForChild("Inventory"):WaitForChild("InventoryItemUtils")),
            RebirthServiceUtils = require(Features:WaitForChild("Rebirth"):WaitForChild("RebirthServiceUtils")),
            AutoRejoinServiceClient = require(Features:WaitForChild("AutoRejoin"):WaitForChild("AutoRejoinServiceClient")),
            Zones = require(GameItems:WaitForChild("Zones")),
            Slimes = require(GameItems:WaitForChild("Slimes"))
        }

        -- ================== UPGRADE QUEUE ==================
        local UpgradeQueue = {}
        for _, tree in pairs(Modules.UpgradeTree) do
            for _, upgradeData in pairs(tree) do
                if type(upgradeData) == "table" and upgradeData.id and upgradeData.cost then
                    table.insert(UpgradeQueue, upgradeData)
                end
            end
        end
        table.sort(UpgradeQueue, function(a, b)
            local aLayers, bLayers = a.layers or 0, b.layers or 0
            if aLayers ~= bLayers then return aLayers < bLayers end
            local aCost, bCost = a.cost and a.cost.amount or math.huge, b.cost and b.cost.amount or math.huge
            if aCost ~= bCost then return aCost < bCost end
            return tostring(a.id) < tostring(b.id)
        end)

        local SlimeNames = {}
        for _, slimeData in ipairs(Modules.Slimes.getSortedSlimes()) do
            if type(slimeData) == "table" and slimeData.id then
                SlimeNames[slimeData.id] = slimeData.name or normalizeDisplayName(slimeData.id)
            end
        end

        -- ================== HELPER: Normalize name ==================
        local function normalizeDisplayName(text)
            text = tostring(text or "")
            text = text:gsub("_", " "):gsub("-", " ")
            text = text:gsub("(%l)(%u)", "%1 %2")
            text = text:gsub("^%s+", ""):gsub("%s+$", "")
            return text:gsub("(%S)(%S*)", function(first, rest) return first:upper() .. rest:lower() end)
        end

        -- ================== MOB/ENEMY HELPERS ==================
        local cachedEnemyFolder, lastFolderSearch = nil, 0
        local function getEnemyFolder()
            if cachedEnemyFolder and cachedEnemyFolder.Parent then return cachedEnemyFolder end
            if tick() - lastFolderSearch < 3 then return nil end
            lastFolderSearch = tick()
            local gp = workspace:FindFirstChild("Gameplay101")
            if gp and gp:FindFirstChild("Enemies") then cachedEnemyFolder = gp.Enemies; return cachedEnemyFolder end
            for _, obj in ipairs(workspace:GetDescendants()) do
                if (obj:IsA("Folder") or obj:IsA("Model")) and table.find({"Enemies","Mobs","Monsters","Live","NPCs"}, obj.Name) then
                    cachedEnemyFolder = obj; return cachedEnemyFolder
                end
            end
        end

        local function getBestMob()
            local folder = getEnemyFolder()
            if not folder then return nil end
            local best, lowestHP = nil, math.huge
            for _, mob in ipairs(folder:GetChildren()) do
                local rp = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart or mob:FindFirstChildWhichIsA("BasePart")
                if rp then
                    local hp, alive = 0, false
                    local hum = mob:FindFirstChildOfClass("Humanoid")
                    if hum then hp = hum.Health; alive = hum.Health > 0
                    else
                        local hv = mob:FindFirstChild("Health") or mob:FindFirstChild("HP")
                        if hv and (hv:IsA("NumberValue") or hv:IsA("IntValue")) then alive = hv.Value > 0; hp = hv.Value
                        else alive = true; hp = 1 end
                    end
                    if alive and hp < lowestHP then lowestHP = hp; best = rp end
                end
            end
            return best
        end

        local function tweenTo(cf)
            local c = LocalPlayer.Character
            if not c or not c:FindFirstChild("HumanoidRootPart") then return end
            local hrp = c.HumanoidRootPart
            local dist = (hrp.Position - cf.Position).Magnitude
            if dist < 3 then return end
            local tw = TweenService:Create(hrp, TweenInfo.new(math.max(dist / Settings.TweenSpeed, 0.1), Enum.EasingStyle.Linear), {CFrame = cf})
            tw:Play()
            while tw.PlaybackState == Enum.PlaybackState.Playing do
                if not Toggles.AutoMob or tick() < pauseMobTweenUntil then tw:Cancel() break end
                task.wait(0.1)
            end
        end

        -- ================== ZONE HELPERS ==================
        local cachedZoneCFrames = {}
        local function getZoneCFrame(zoneNum)
            if cachedZoneCFrames[zoneNum] then return cachedZoneCFrames[zoneNum] end
            local zones = workspace:FindFirstChild("Zones") or workspace:FindFirstChild("Areas")
            if not zones then return nil end
            local zone = zones:FindFirstChild(tostring(zoneNum))
            if not zone then return nil end
            local poi = zone:FindFirstChild("POI")
            if poi and poi:FindFirstChildWhichIsA("BasePart", true) then
                cachedZoneCFrames[zoneNum] = poi:FindFirstChildWhichIsA("BasePart", true).CFrame + Vector3.new(0, 6, 0)
                return cachedZoneCFrames[zoneNum]
            end
            local bigPart, bigSize = nil, 0
            for _, p in ipairs(zone:GetDescendants()) do
                if p:IsA("BasePart") and not p.Name:lower():find("hitbox") then
                    local vol = p.Size.X * p.Size.Z
                    if vol > bigSize then bigSize = vol; bigPart = p end
                end
            end
            if bigPart then
                cachedZoneCFrames[zoneNum] = bigPart.CFrame + Vector3.new(0, 6, 0)
                return cachedZoneCFrames[zoneNum]
            end
            return nil
        end

        local function getHighestUnlockedZone()
            local zones = workspace:FindFirstChild("Zones") or workspace:FindFirstChild("Areas")
            if not zones then return nil end
            local highest = 0
            for _, zone in ipairs(zones:GetChildren()) do
                local zoneNum = tonumber(zone.Name)
                if zoneNum then
                    local gate = zone:FindFirstChild("Gate")
                    if gate and gate:FindFirstChild("Back") and not gate.Back.CanCollide then
                        if zoneNum > highest then highest = zoneNum end
                    end
                end
            end
            local target = highest + 1
            if zones:FindFirstChild(tostring(target)) then return target end
            return highest > 0 and highest or nil
        end

        -- ================== LOOPS ==================
        local function loop(key, fn, delay)
            task.spawn(function()
                while true do
                    if Toggles[key] then pcall(fn) end
                    task.wait(delay)
                end
            end)
        end

        loop("DisableAutoRejoin", function() Modules.AutoRejoinServiceClient:disable() end, 5)
        loop("Rebirth", function()
            Remotes.Rebirth:InvokeServer("requestRebirth")
            sendWebhook("♻️ Auto Rebirth triggered!")
        end, 1)
        loop("Zones", function()
            Remotes.Zones:InvokeServer("requestPurchaseZone")
            local coins = Modules.DataServiceClient:get("coins") or 0
            sendWebhook("🗺️ Auto Buy Zone | Coins: " .. formatNumber(coins))
        end, 0.5)
        loop("Equip", function() Remotes.Inventory:InvokeServer("requestEquipBest") end, 2)
        loop("Roll", function()
            local ok, results = pcall(function() return Remotes.Roll:InvokeServer("requestRoll") end)
            if ok and type(results) == "table" then
                local hatched = {}
                for _, column in ipairs(results) do
                    if type(column) == "table" then
                        for i = #column, 1, -1 do
                            local rollEntry = column[i]
                            if type(rollEntry) == "table" and rollEntry.id then
                                table.insert(hatched, SlimeNames[rollEntry.id] or normalizeDisplayName(rollEntry.id))
                                break
                            end
                        end
                    end
                end
                if #hatched > 0 then LastHatchedText = table.concat(hatched, ", ") end
            end
        end, 0.2)
        loop("AutoUpgrade", function()
            local ownedUpgrades = Modules.DataServiceClient:get("upgrades") or {}
            local function getCurrency(curr) return tonumber(Modules.DataServiceClient:get(curr)) or 0 end
            for _, upgradeData in ipairs(UpgradeQueue) do
                if Modules.UpgradeCounterUtils.canPurchase(upgradeData, ownedUpgrades, getCurrency) then
                    pcall(function() Remotes.Upgrade:InvokeServer("requestUnlock", upgradeData.id) end)
                    task.wait(0.1)
                    break
                end
            end
        end, 0.35)

        local function getInventoryData() return Modules.DataServiceClient:get("inventory") or {} end
        loop("AutoCraft", function()
            local inventory = getInventoryData()
            local craftingRecipes = Modules.DataServiceClient:get("craftingRecipes") or {}
            local unlocks = Modules.DataServiceClient:get("unlocks") or {}
            if Modules.CraftingServiceUtils.isMachineUnlocked(unlocks) then
                for _, recipe in ipairs(Modules.CraftingServiceUtils.getRecipes()) do
                    if Modules.CraftingServiceUtils.isRecipeOwned(craftingRecipes, recipe.id) then
                        local selectedSlimes, usedAmounts = {}, {}
                        local valid = true
                        for _, ingredient in ipairs(recipe.inputs) do
                            local entries = Modules.CraftingServiceUtils.getIngredientInventoryEntries(ingredient, inventory)
                            local selectedUniqueId = nil
                            for _, entry in ipairs(entries or {}) do
                                if entry.uniqueId and (tonumber(entry.ownedAmount) or 0) - (usedAmounts[entry.uniqueId] or 0) > 0 then
                                    selectedUniqueId = entry.uniqueId
                                    break
                                end
                            end
                            if not selectedUniqueId then valid = false break end
                            usedAmounts[selectedUniqueId] = (usedAmounts[selectedUniqueId] or 0) + 1
                            table.insert(selectedSlimes, selectedUniqueId)
                        end
                        if valid then
                            pcall(function() Remotes.Crafting:InvokeServer("requestCraftRecipe", recipe.id, selectedSlimes, 1) end)
                            task.wait(0.15)
                        end
                    end
                end
            end
        end, 1)
        loop("AutoFeed", function()
            local equipped = Modules.DataServiceClient:get("equippedSlimes") or Modules.DataServiceClient:get("equipped") or getInventoryData().equippedSlimes or {}
            local list = {}
            for _, uniqueId in pairs(equipped) do if uniqueId then table.insert(list, uniqueId) end end
            if #list <= 0 then return end
            local boosts = Modules.BoostServiceUtils.reconcileBoosts(Modules.DataServiceClient:get("boosts"))
            local items = Modules.DataServiceClient:get("items") or getInventoryData().items or {}
            local consumables = Modules.InventoryItemUtils.getConsumableEntries(boosts, items)
            local bestFoodId, bestAmount = nil, 0
            for itemId, entry in pairs(consumables) do
                if type(entry.definition) == "table" and entry.definition.kind == "food" and (tonumber(entry.amountOwned) or 0) > bestAmount then
                    bestFoodId = itemId
                    bestAmount = tonumber(entry.amountOwned)
                end
            end
            if bestFoodId and bestAmount > 0 then
                local index = ((FeedEquippedIndex - 1) % #list) + 1
                local success = pcall(function() Remotes.Inventory:InvokeServer("requestUseFood", bestFoodId, list[index], 1) end)
                if success then FeedEquippedIndex = (index % #list) + 1; task.wait(0.08) end
            end
        end, 1)
        loop("AutoBoost", function()
            for _, b in ipairs({"rollSpeed", "luck", "ultraLuck", "coins"}) do
                Remotes.Boost:InvokeServer("requestUseBoost", b)
                task.wait(0.1)
            end
        end, 5)
        loop("AutoLoot", function()
            for _, name in ipairs({"Drops","Loot","Coins","Collectibles"}) do
                local f = workspace:FindFirstChild(name)
                if f then for _, d in ipairs(f:GetChildren()) do Remotes.Loot:InvokeServer("requestCollect", d.Name) end break end
            end
        end, 0.5)
        loop("AutoRecipe", function()
            local zf = workspace:FindFirstChild("Zones") or workspace:FindFirstChild("Areas")
            if not zf and workspace:FindFirstChild("Gameplay101") then zf = workspace.Gameplay101:FindFirstChild("Zones") end
            if zf then
                for _, z in ipairs(zf:GetChildren()) do
                    local r = z:FindFirstChild("Recipe")
                    if r then Remotes.Crafting:InvokeServer("requestClaimRecipe", "crafty", r) end
                end
            end
        end, 3)
        loop("AutoIndex", function()
            for _, rewardType in ipairs({"basic", "shiny", "big", "huge", "inverted"}) do
                Remotes.Index:InvokeServer("requestClaimReward", rewardType)
                task.wait(0.2)
            end
        end, 5)
        loop("AutoArea", function()
            local zoneNum = getHighestUnlockedZone()
            if zoneNum then
                local cf = getZoneCFrame(zoneNum)
                if cf then
                    local c = LocalPlayer.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then
                        local hrp = c.HumanoidRootPart
                        local dist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(cf.Position.X, 0, cf.Position.Z)).Magnitude
                        if dist > 100 then hrp.CFrame = cf; pauseMobTweenUntil = tick() + 3 end
                    end
                end
            end
        end, 3)
        loop("AutoMob", function()
            if tick() >= pauseMobTweenUntil then
                local t = getBestMob()
                if t then tweenTo(t.CFrame * CFrame.new(0, 3, 0)) end
            end
        end, 0.2)

        -- Live stats update
        task.spawn(function()
            while true do
                pcall(function()
                    local coins = tonumber(Modules.DataServiceClient:get("coins")) or 0
                    local goop = tonumber(Modules.DataServiceClient:get("goop")) or 0
                    local rebirths = tonumber(Modules.DataServiceClient:get("rebirths")) or 0
                    local maxZone = tonumber(Modules.DataServiceClient:get("maxZone")) or 1
                    local nextZoneId = maxZone + 1
                    local nextZoneData = Modules.Zones.hasZone(nextZoneId) and Modules.Zones.getZone(nextZoneId)
                    local zoneCostText = nextZoneData and formatNumber(nextZoneData.price) or "Maxed"
                    local rebirthCostText = formatNumber(Modules.RebirthServiceUtils.getCost(rebirths))
                    ProgressionLabel:Set(string.format("💰 Coins: %s / %s (Next Zone) | 🧪 Goop: %s / %s (Rebirth) | ♻️ Rebirths: %s | 🗺️ Max Zone: %s",
                        formatNumber(coins), zoneCostText, formatNumber(goop), rebirthCostText, formatNumber(rebirths), maxZone))
                end)
                task.wait(1)
            end
        end)
    end)

    if not success then
        ProgressionLabel:Set("⚠️ Game modules failed to load. Some features disabled.")
        Fluent:Notify({ Title = "Warning", Content = "Couldn't load game data; check console.", Duration = 5 })
    end
end)

Fluent:Notify({ Title = "Koala Hub", Content = "Script loaded. Tabs always visible!", Duration = 5 })