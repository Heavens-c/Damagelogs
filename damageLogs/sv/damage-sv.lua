local avatar_url = "https://media.discordapp.net/attachments/770200295489667082/919300666999046214/Asset_20.png?width=671&height=670"


Sky = {
	Webhook = {
		damage = "YOURWEBHOOKSHITDISCORDAPIWEBHOOK"
	},

	KickPlayer = false 
}

RegisterServerEvent('asd')
AddEventHandler('asd', function(x)
    local playerId = source
    eSkaylogs(playerId, x)
end)


eSkaylogs = function(playerId, dam)
    -- Get the player's identifiers
    local identifiers = GetPlayerIdentifiers(playerId)

    local steamIdentifier, playerIP

    for _, identifier in ipairs(identifiers) do
        if string.match(identifier, "steam") then
          steamIdentifier = identifier
        elseif string.match(identifier, "ip") then
          playerIP = identifier
        end
    end

    local discordlogimage = "https://cdn.discordapp.com/attachments/873184959400149072/890646026044731412/dollar-black-poster.png"
    local loginfo = {
        ["color"] = "66666", 
        ["author"] = {
            name = "$ky Damage Logs!",
            icon_url = "https://cdn.discordapp.com/attachments/873184959400149072/890646026044731412/dollar-black-poster.png"
        },
        ["type"] = "rich", 
        ["title"] = "Damage Logs", 
        ["description"] =  " ".. dam ..  "\n **IP : **" ..playerIP.. "\n **SteamID: **" ..steamIdentifier ,
        ["footer"] = { 
            ["text"] = "$ky Damage Logs!!  |  " ..os.date("%m/%d/%Y") 
        }
    }
    PerformHttpRequest(Sky.Webhook.damage, function(err, text, headers) 
        if err then
            print("[eSkaylogs] Error sending message to webhook: "..err)
        end
    end, "POST", json.encode({username = "Heavens!", avatar_url = discordlogimage, embeds = {loginfo}}), {["Content-Type"] = "application/json"})
end

