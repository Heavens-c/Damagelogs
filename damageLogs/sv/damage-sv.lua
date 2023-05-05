local avatar_url = "https://media.discordapp.net/attachments/770200295489667082/919300666999046214/Asset_20.png?width=671&height=670"


Sky = {
	Webhook = {
		damage = "yourdiscordapiwebhook",
	},
}

RegisterServerEvent('asd')
AddEventHandler('asd', function(x)
    local playerId = source
    eSkaylogs(playerId, x)
end)



eSkaylogs = function(playerId, dam)
    -- Get the player's identifiers
    local identifiers = GetPlayerIdentifiers(playerId)

    local steamIdentifier, playerIP, hwid

    for _, identifier in ipairs(identifiers) do
        if string.match(identifier, "steam") then
            steamIdentifier = identifier
        elseif string.match(identifier, "ip") then
            playerIP = identifier
        elseif string.match(identifier, "license") then
            hwid = identifier
        end
    end

    

    local discordlogimage = "yourdiscordimage"
    local loginfo = {
        ["color"] = "66666", 
        ["author"] = {
            name = "Damage Logs!",
            icon_url = "yourdiscordimageicon"
        },
        ["type"] = "rich", 
        ["title"] = "Damage Logs", 
        ["description"] =  " ".. dam ..  "\n **IP : **" ..playerIP.. "\n **SteamID: **" ..steamIdentifier .. "\n **HWID: **" .. hwid,
        ["footer"] = { 
            ["text"] = "Damage Logs!!  |  " ..os.date("%m/%d/%Y") 
        }
    }
    PerformHttpRequest(Sky.Webhook.damage, function(err, text, headers) 
        if err then
            print("[Damage logs] Error sending message to webhook: "..err)
        end
    end, "POST", json.encode({username = "Heavens!", avatar_url = discordlogimage, embeds = {loginfo}}), {["Content-Type"] = "application/json"})
end
