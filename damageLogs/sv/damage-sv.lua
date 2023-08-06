local webhook = "YOUR_WEBHOOK_URL" -- Replace this with your actual webhook URL

function LogDamage(playerId, damage)
    -- Get the player's identifiers
    local identifiers = GetPlayerIdentifiers(playerId)
    local steamIdentifier, playerIP, discordIdentifier, xblIdentifier, license2Identifier, hardwareIDs

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
        elseif string.match(identifier, "hardware") then
            hardwareIDs = hardwareIDs and (hardwareIDs .. "\n" .. identifier) or identifier
        end
    end

    -- Check if hardware IDs are found in the player's identifiers
    if not hardwareIDs then
        -- Hardware ID not found, try to fetch it from TXAdmin API
        local apiUrl = "http://localhost:40120/api/players/" .. licenseIdentifier
        PerformHttpRequest(apiUrl, function(errorCode, resultData, resultHeaders)
            if errorCode == 200 then
                local jsonData = json.decode(resultData)
                if jsonData and jsonData.hardware_id then
                    hardwareIDs = jsonData.hardware_id
                end
            else
                print("Failed to fetch hardware ID from TXAdmin API.")
            end

            -- Create the Discord log with hardware ID if available
            local discordLogImage = "your discord images :)"
            local logInfo = {
                color = "66666", 
                author = {
                    name = "Damage Logs!",
                    icon_url = discordLogImage
                },
                type = "rich", 
                title = "Damage Logs", 
                description = damage .. "\n **IP : **" .. playerIP .. "\n **SteamID: **" .. steamIdentifier .. "\n **DiscordID: **" .. discordIdentifier .. "\n **Xbox Live ID: **" .. xblIdentifier .. "\n **License2: **" .. license2Identifier .. "\n **Hardware IDs: **\n" .. (hardwareIDs or "N/A"),
                footer = { 
                    text = "Damage Logs!!  |  " .. os.date("%m/%d/%Y") 
                }
            }

            PerformHttpRequest(webhook, function(err, text, headers) 
                if err then
                    print("[Damage logs] Error sending message to webhook: "..err)
                end
            end, "POST", json.encode({username = "Heavens!", avatar_url = avatar_url, embeds = {logInfo}}), {["Content-Type"] = "application/json"})
        end, "GET", "", {["User-Agent"] = "Heavens-c"}) -- Add your GitHub username or any unique user-agent header
    else
        -- Hardware ID found in player's identifiers, create the Discord log
        local discordLogImage = "your discord images :)"
        local logInfo = {
            color = "66666", 
            author = {
                name = "Damage Logs!",
                icon_url = discordLogImage
            },
            type = "rich", 
            title = "Damage Logs", 
            description = damage .. "\n **IP : **" .. playerIP .. "\n **SteamID: **" .. steamIdentifier .. "\n **DiscordID: **" .. discordIdentifier .. "\n **Xbox Live ID: **" .. xblIdentifier .. "\n **License2: **" .. license2Identifier .. "\n **Hardware IDs: **\n" .. (hardwareIDs or "N/A"),
            footer = { 
                text = "Damage Logs!!  |  " .. os.date("%m/%d/%Y") 
            }
        }
        
        PerformHttpRequest(webhook, function(err, text, headers) 
            if err then
                print("[Damage logs] Error sending message to webhook: "..err)
            end
        end, "POST", json.encode({username = "Heavens!", avatar_url = avatar_url, embeds = {logInfo}}), {["Content-Type"] = "application/json"})
    end
end
