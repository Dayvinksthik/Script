local success, result = pcall(function()
    return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://apis.roblox.com/universes/v1/places/"..game.PlaceId.."/universe"))
end)

local UniverseID = success and result.universeId or nil

if game.PlaceId == 2753915549 or UniverseID == 994732206 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Dayvinksthik/Script/refs/heads/main/BloxFruit.lua"))()
else
    warn("This game is not supported.")
end
