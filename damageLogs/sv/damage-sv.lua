local avatar_url = "https://media.discordapp.net/attachments/770200295489667082/919300666999046214/Asset_20.png?width=671&height=670"

RegisterServerEvent('asd')
AddEventHandler('asd', function(x)
    eSkaylogs(x)
end)


eSkaylogs = function(dam)
    -- Get the player's identifiers
    local identifiers = GetPlayerIdentifiers(playerId)

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
    PerformHttpRequest("https://discord.com/api/webhooks/1002565439714496532/yE2WSWUpfioOprWo8ZQLIZ87c833kx_zhk_R69MFvZ3dvPlTUTJoVQt1WmhAFsdT6f79", function(err, text, headers) end, "POST", json.encode({username = "Heavens!", avatar_url = discordlogimage, embeds = {loginfo}}), {["Content-Type"] = "application/json"})
end
