-----------------------------------------
-- Bone IDs mapping (Server-Side)
-----------------------------------------
local boneIds = {
    [1356] = 'eyebrow', [2108] = 'left toe', [2992] = 'right elbow', [5232] = 'left arm',
    [6286] = 'right hand', [6442] = 'right thigh', [10706] = 'right collarbone',
    [11174] = 'right corner of the mouth', [11816] = 'sinks', [12844] = 'head',
    [14201] = 'left foot', [16335] = 'right knee', [17188] = 'lower lip', [17719] = 'lip',
    [18905] = 'left hand', [19336] = 'right cheekbone', [20781] = 'right toe',
    [20279] = 'nerve of the lower lip', [21550] = 'left cheekbone', [22711] = 'left elbow',
    [23553] = 'spinal root', [23639] = 'left thigh', [24806] = 'right foot',
    [24816] = 'lower part of the spine', [24817] = 'the middle part of the spine',
    [24818] = 'the upper part of the spine', [25260] = 'left eye', [27474] = 'right eye',
    [28252] = 'right arm', [29868] = 'left corner of the mouth', [35731] = 'neck',
    [36864] = 'right calf', [43810] = 'right forearm', [45509] = 'left shoulder',
    [46078] = 'left knee', [46240] = 'jaw', [47495] = 'tongue', [49979] = 'nerve of the upper lip',
    [51826] = 'right thigh', [56604] = 'root', [57597] = 'spine', [57717] = 'left foot bone',
    [58331] = 'left eyebrow', [60309] = 'left hand bone', [61163] = 'left forearm',
    [61839] = 'upper lip', [63931] = 'left calf', [64729] = 'left collarbone', [65068] = 'face'
}

local function getBoneNameById(boneId)
    return boneIds[boneId] or "Unknown Bone (" .. tostring(boneId) .. ")"
end

-----------------------------------------
-- State & Cache
-----------------------------------------
local playerCache = {}
local rateLimits = {}
local lastTotalDamageLog = {}

-----------------------------------------
-- Helper Functions
-----------------------------------------

local function getCachedIdentifiers(playerId)
    if playerCache[playerId] then return playerCache[playerId] end

    local ids = GetPlayerIdentifiers(playerId)
    local data = { steam = "N/A", license = "N/A", discord = "N/A", ip = "N/A" }

    if ids then
        for _, id in ipairs(ids) do
            if id:find("steam:") then data.steam = id
            elseif id:find("license:") then data.license = id
            elseif id:find("discord:") then data.discord = id:gsub("discord:", "")
            elseif id:find("ip:") then data.ip = id:gsub("ip:", "") end
        end
    end

    playerCache[playerId] = data
    return data
end

local function sendToDiscord(webhookType, title, description)
    if not Config.Discord.Enabled then return end

    local webhook = nil
    if webhookType == 'damage' then
        webhook = Config.Discord.DamageWebhook
    elseif webhookType == 'total' then
        webhook = Config.Discord.TotalDamageWebhook
    end

    -- Skip sending if webhook is not configured properly
    if not webhook or webhook == "" or webhook == "YOUR_WEBHOOK_HERE" or not webhook:find("https://discord.com/api/webhooks/") then
        return
    end

    local payload = json.encode({
        username = Config.Discord.Username,
        embeds = {{
            title = title,
            description = description,
            color = Config.Discord.Color,
            author = { name = "Damage System", icon_url = Config.Discord.Logo },
            footer = { text = "Logged at " .. os.date("%Y-%m-%d %H:%M:%S") }
        }}
    })

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', payload, { ['Content-Type'] = 'application/json' })
end

-- Server-Side Rate Limiter & Anti-Exploit
local function isPlayerSpamming(playerId)
    local currentTime = GetGameTimer()
    if not rateLimits[playerId] then
        rateLimits[playerId] = { lastTime = 0, warnings = 0 }
    end

    local diff = currentTime - rateLimits[playerId].lastTime
    if diff < Config.Protection.RateLimit then
        rateLimits[playerId].warnings = rateLimits[playerId].warnings + 1
        
        if Config.Protection.AlertAdminsOnExploit then
            print(string.format("^3[DamageLogs Alert] Player %s (%s) triggered events too fast! Warning %d/%d^7", 
                GetPlayerName(playerId) or "Unknown", playerId, rateLimits[playerId].warnings, Config.Protection.MaxWarnings))
        end
        
        if rateLimits[playerId].warnings >= Config.Protection.MaxWarnings then
            return true -- Drop the request
        end
    else
        -- Decay warning count for well-behaved players
        rateLimits[playerId].warnings = math.max(0, rateLimits[playerId].warnings - 1)
    end

    rateLimits[playerId].lastTime = currentTime
    return false
end

-----------------------------------------
-- Startup Checks
-----------------------------------------
Citizen.CreateThread(function()
    local function isValidWebhook(url)
        if not url or url == "" or url == "YOUR_WEBHOOK_HERE" then return false end
        return url:find("https://discord.com/api/webhooks/") ~= nil
    end

    if Config.Discord.Enabled then
        if not isValidWebhook(Config.Discord.DamageWebhook) then
            print("^3[DamageLogs Config Warning] Config.Discord.DamageWebhook is not configured. Discord logs for bone damage will be disabled.^7")
        end
        if not isValidWebhook(Config.Discord.TotalDamageWebhook) then
            print("^3[DamageLogs Config Warning] Config.Discord.TotalDamageWebhook is not configured. Discord logs for total damage will be disabled.^7")
        end
    end
end)

-----------------------------------------
-- Event Handlers
-----------------------------------------

-- Clean up player data on disconnect
AddEventHandler('playerDropped', function()
    local src = source
    playerCache[src] = nil
    rateLimits[src] = nil
    lastTotalDamageLog[src] = nil
end)

-- Secure Bone Damage Server Event
RegisterNetEvent('damageLogs:onBoneDamage', function(boneId, hp, armor)
    local src = source

    -- Strict Type Validation
    if type(boneId) ~= 'number' or type(hp) ~= 'number' or type(armor) ~= 'number' then
        if Config.Protection.AlertAdminsOnExploit then
            print(string.format("^1[DamageLogs Security] Exploit Attempt! Player %s (%s) sent invalid parameter types.^7", GetPlayerName(src) or "Unknown", src))
        end
        return
    end

    -- Rate Limit enforcement
    if isPlayerSpamming(src) then
        return
    end

    local boneName = getBoneNameById(boneId)
    local ids = getCachedIdentifiers(src)
    local playerName = GetPlayerName(src) or "Unknown Player"

    -- Construct log string safely on the server
    local logString = string.format(
        "**Player:** %s (%s)\n**Bone Hit:** %s\n**HP Remaining:** %d\n**Armor Remaining:** %d\n**Discord:** <@%s>\n**IP:** %s\n**License:** %s",
        playerName, src, boneName, hp, armor, ids.discord, ids.ip, ids.license
    )

    sendToDiscord('damage', "🎯 Bone Damage Log", logString)
end)

-- Built-in FiveM Weapon Damage Event
AddEventHandler('weaponDamageEvent', function(sender, data)
    if data.weaponDamage > 0 then
        -- Send event to the attacker client to display floating UI text
        TriggerClientEvent('damagelogs', sender, data.weaponDamage, data.willKill)

        -- Handle Discord Webhook Logging with Server-Side Throttling
        local currentTime = GetGameTimer()
        if not lastTotalDamageLog[sender] or (currentTime - lastTotalDamageLog[sender]) > Config.NetworkCooldown then
            lastTotalDamageLog[sender] = currentTime

            local ids = getCachedIdentifiers(sender)
            local attackerName = GetPlayerName(sender) or "Unknown Player"
            local displayedDamage = data.willKill and "DEAD" or tostring(math.floor(data.weaponDamage))

            local logString = string.format(
                "**Attacker:** %s (%s)\n**Total Damage Dealt:** %s\n**Discord:** <@%s>\n**License:** %s",
                attackerName, sender, displayedDamage, ids.discord, ids.license
            )

            sendToDiscord('total', "📊 Total Damage Log", logString)
        end
    end
end)
