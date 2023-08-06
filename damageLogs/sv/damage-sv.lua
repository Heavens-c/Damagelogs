function LogDamage(playerId, damage)
    -- Get the player's identifiers
    local identifiers = GetPlayerIdentifiers(playerId)
    local steamIdentifier, playerIP, discordIdentifier, xblIdentifier, license2Identifier

    for _, identifier in ipairs(identifiers) do
        if string.match(identifier, "steam") then
            steamIdentifier = identifier
        elseif string.match(identifier, "ip") then
            playerIP = identifier
        elseif string.match(identifier, "license") then
            licenseIdentifier = identifier
        elseif string.match(identifier, "discord") then
            discordIdentifier = identifier
        elseif string.match(identifier, "xbl") then
            xblIdentifier = identifier
        elseif string.match(identifier, "license2") then
            license2Identifier = identifier
        end
    end

    local discordLogImage = "your discord images :)"
    local logInfo = {
        color = "66666", 
        author = {
            name = "Damage Logs!",
            icon_url = discordLogImage
        },
        type = "rich", 
        title = "Damage Logs", 
        description = damage .. "\n **IP : **" .. playerIP .. "\n **SteamID: **" .. steamIdentifier .. "\n **DiscordID: **" .. discordIdentifier .. "\n **Xbox Live ID: **" .. xblIdentifier .. "\n **License2: **" .. license2Identifier,
        footer = { 
            text = "Damage Logs!!  |  " .. os.date("%m/%d/%Y") 
        }
    }

    PerformHttpRequest(Sky.Webhook.damage, function(err, text, headers) 
        if err then
            print("[Damage logs] Error sending message to webhook: "..err)
        end
    end, "POST", json.encode({username = "Heavens!", avatar_url = avatar_url, embeds = {logInfo}}), {["Content-Type"] = "application/json"})
end
