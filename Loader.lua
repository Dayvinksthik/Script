local success, result = pcall(function()
    return game:GetService("HttpService"):JSONDecode(
        game:HttpGet("https://apis.roblox.com/universes/v1/places/" .. game.PlaceId .. "/universe")
    )
end)
local UniverseID = success and result.universeId or nil

local loaded = false

-- BloxFruit
if game.PlaceId == 7449423635 or
   game.PlaceId == 2753915549 or
   game.PlaceId == 4442272183 or
   game.PlaceId == 122478697296975 or
   UniverseID == 994732206 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Dayvinksthik/Script/refs/heads/main/Games/BloxFruit.lua"))()
    loaded = true
end

-- Finish The Word
if game.PlaceId == 91704854174760 or
   UniverseID == 91704854174760 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Dayvinksthik/Script/refs/heads/main/Games/FinishTheWord.lua"))()
    loaded = true
end

if not loaded then
    warn("This game is not supported.")
end
