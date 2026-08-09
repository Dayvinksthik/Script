local success, result = pcall(function()
    return game:GetService("HttpService"):JSONDecode(
        game:HttpGet("https://apis.roblox.com/universes/v1/places/" .. game.PlaceId .. "/universe")
    )
end)

local UniverseID = success and result.universeId or nil

if game.PlaceId == 7449423635 or
   game.PlaceId == 2753915549 or
   game.PlaceId == 4442272183 or
   game.PlaceId == 122478697296975 or
   UniverseID == 994732206 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Dayvinksthik/Script/refs/heads/main/Games/BloxFruit.lua"))()
else
    warn("This game is not supported.")
end
