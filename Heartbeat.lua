-- Nexora Heartbeat

-- Graphics

pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

pcall(function()
    local GameSettings = UserSettings().GameSettings
    GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    GameSettings.GraphicsMode = Enum.GraphicsMode.Manual
end)

for _, sound in pairs(workspace:GetDescendants()) do
    if sound:IsA("Sound") then sound.Volume = 0 end
end

workspace.DescendantAdded:Connect(function(d)
    if d:IsA("Sound") then d.Volume = 0 end
end)

-- FPS cap at 30

task.spawn(function()
    while true do
        task.wait(1 / 30)
    end
end)

-- Heartbeat

local Players         = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local player          = Players.LocalPlayer

local FOLDER_NAME        = "Nexora"
local HEARTBEAT_NAME     = FOLDER_NAME .. "/heartbeat.txt"
local HEARTBEAT_INTERVAL = 5

-- Create Nexora folder if it doesn't exist
pcall(function()
    if not isfolder(FOLDER_NAME) then
        makefolder(FOLDER_NAME)
    end
end)

local function isInGame()
    local success, result = pcall(function()
        return player.Character ~= nil
            and player.Character.Parent ~= nil
            and game.PlaceId ~= 0
    end)
    return success and result
end

local function getPlaceId()
    local success, id = pcall(function() return tostring(game.PlaceId) end)
    return (success and id) or "0"
end

local function writeHeartbeat(status)
    local username = player and player.Name or "unknown"
    local placeId  = getPlaceId()

    -- Re-check folder exists before every write
    pcall(function()
        if not isfolder(FOLDER_NAME) then
            makefolder(FOLDER_NAME)
        end
    end)

    pcall(writefile, HEARTBEAT_NAME,
        tostring(os.time()) .. "|" .. (status or "ingame") .. "|" .. username .. "|" .. placeId)
end

-- Kicked detection

pcall(function()
    player.Kicked:Connect(function()
        writeHeartbeat("kicked")
    end)
end)

-- Teleport detection

pcall(function()
    player.OnTeleport:Connect(function(state)
        if state == Enum.TeleportState.InProgress then
            writeHeartbeat("teleporting")
        elseif state == Enum.TeleportState.Failed then
            writeHeartbeat("teleport_failed")
        end
    end)
end)

pcall(function()
    TeleportService.LocalPlayerArrivedFromTeleport:Connect(function()
        writeHeartbeat("ingame")
    end)
end)

-- Main heartbeat loop

local function getStatus()
    if isInGame() then
        return "ingame"
    end
    return "loading"
end

-- Write on load
writeHeartbeat(getStatus())

-- Keep writing every 5 seconds
task.spawn(function()
    while true do
        task.wait(HEARTBEAT_INTERVAL)
        writeHeartbeat(getStatus())
    end
end)
