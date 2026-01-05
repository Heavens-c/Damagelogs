local DAMAGE_WEBHOOK = "YOUR_WEBHOOK_HERE"
local TOTAL_DAMAGE_WEBHOOK = "YOUR_WEBHOOK_HERE"
local DISCORD_LOG_IMAGE = "https://cdn.discordapp.com/attachments/873184959400149072/890646026044731412/dollar-black-poster.png"

-- Cache to store identifiers so we don't fetch them every single hit
local playerCache = {}

-----------------------------------------
-- Helper Functions
-----------------------------------------

local function getCachedIdentifiers(playerId)
    if playerCache[playerId] then return playerCache[playerId] end

    local ids = GetPlayerIdentifiers(playerId)
    local data = { steam = "N/A", license = "N/A", discord = "N/A", ip = "N/A" }

    for _, id in ipairs(ids) do
        if id:find("steam:") then data.steam = id
        elseif id:find("license:") then data.license = id
        elseif id:find("discord:") then data.discord = id:gsub("discord:", "")
        elseif id:find("ip:") then data.ip = id:sub(4) end
    end

    playerCache[playerId] = data
    return data
end

local function sendToDiscord(webhook, title, description)
    local payload = json.encode({
        username = "Heavens Logs",
        embeds = {{
            title = title,
            description = description,
            color = 16711680, -- Red color
            author = { name = "Damage System", icon_url = DISCORD_LOG_IMAGE },
            footer = { text = "Logged at " .. os.date("%Y-%m-%d %H:%M:%S") }
        }}
    })

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', payload, { ['Content-Type'] = 'application/json' })
end

-----------------------------------------
-- Event Handlers
-----------------------------------------

-- Clean up cache when player leaves
AddEventHandler('playerDropped', function()
    playerCache[source] = nil
end)

-- Main Damage Logging Event
RegisterNetEvent('damagebone', function(message)
    local src = source
    local ids = getCachedIdentifiers(src)
    
    local logString = string.format(
        "**Action:** %s\n**Player:** %s (%s)\n**Discord:** <@%s>\n**IP:** %s\n**License:** %s",
        message, GetPlayerName(src), src, ids.discord, ids.ip, ids.license
    )
    
    sendToDiscord(DAMAGE_WEBHOOK, "🎯 Bone Damage Log", logString)
end)

-- Total Damage Logging Event
RegisterNetEvent('totaldamage', function(damage)
    local src = source
    local ids = getCachedIdentifiers(src)
    
    local logString = string.format(
        "**Total Damage:** %s\n**Player:** %s (%s)\n**Discord:** <@%s>",
        tostring(damage), GetPlayerName(src), src, ids.discord
    )
    
    sendToDiscord(TOTAL_DAMAGE_WEBHOOK, "📊 Total Damage Log", logString)
end)

-- Built-in FiveM Weapon Damage Event
AddEventHandler('weaponDamageEvent', function(sender, data)
    -- This event is high-frequency, so we only trigger client logs here
    -- to let the client-side throttling handle the heavy lifting.
    if data.weaponDamage > 0 then
        TriggerClientEvent('damagelogs', sender, data.weaponDamage, sender, data.willKill)
    end
end)
