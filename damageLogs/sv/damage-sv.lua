local avatar_url = "https://media.discordapp.net/attachments/770200295489667082/919300666999046214/Asset_20.png?width=671&height=670"


local Sky = {
    Webhook = {
        damage = "YOURWEBHOOKSHITDISCORDAPIWEBHOOK"
    },
    KickPlayer = false 



RegisterServerEvent('asd')
AddEventHandler('asd', function(damage)
    local playerId = source
    LogDamage(playerId, damage)
end)


function LogDamage(playerId, damage)
    -- Get the player's identifiers
    local identifiers = GetPlayerIdentifiers(playerId)
    local steamIdentifier, playerIP


    for _, identifier in ipairs(identifiers) do
        if string.match(identifier, "steam") then
            steamIdentifier = identifier
        elseif string.match(identifier, "ip") then
            playerIP = identifier
<
        end
    end

    local discordLogImage = "https://cdn.discordapp.com/attachments/873184959400149072/890646026044731412/dollar-black-poster.png"
    local logInfo = {
        color = "66666", 
        author = {
            name = "$ky Damage Logs!",
            icon_url = discordLogImage
        },
        type = "rich", 
        title = "Damage Logs", 
        description = damage .. "\n **IP : **" .. playerIP .. "\n **SteamID: **" .. steamIdentifier ,
        footer = { 
            text = "$ky Damage Logs!!  |  " .. os.date("%m/%d/%Y") 

        }
    }

    PerformHttpRequest(Sky.Webhook.damage, function(err, text, headers) 
        if err then
            print("[Damage logs] Error sending message to webhook: "..err)
        end
    end, "POST", json.encode({username = "Heavens!", avatar_url = avatar_url, embeds = {logInfo}}), {["Content-Type"] = "application/json"})
end
