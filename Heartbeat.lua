-- Nexora Heartbeat

-- Graphics + Sound optimization

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

local runService = game:GetService("RunService")

runService.RenderStepped:Connect(function(deltaTime)
    if math.floor(1 / deltaTime) > 30 then
        runService.RenderStepped:Wait()
    end
end)

-- Heartbeat

local Players           = game:GetService("Players")
local TeleportService   = game:GetService("TeleportService")
local player            = Players.LocalPlayer

local HEARTBEAT_FILE     = "nexora_heartbeat.txt"
local HEARTBEAT_INTERVAL = 5

local function writeHeartbeat(status)
    local username = player and player.Name or "unknown"
    pcall(writefile, HEARTBEAT_FILE,
        tostring(os.time()) .. "|" .. (status or "ingame") .. "|" .. username)
end

-- Write on load
writeHeartbeat("ingame")

-- Keep writing every 5s
task.spawn(function()
    while true do
        task.wait(HEARTBEAT_INTERVAL)
        writeHeartbeat("ingame")
    end
end)

-- Write on teleport
player.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.InProgress then
        writeHeartbeat("teleporting")
    end
end)

TeleportService.LocalPlayerArrivedFromTeleport:Connect(function()
    writeHeartbeat("ingame")
end)
