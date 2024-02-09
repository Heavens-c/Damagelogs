local webhook = "Webhook" -- Define your webhook URL here
local webhook2 = "Webhook" -- Define your webhook URL here2
local discordLogImage = "https://cdn.discordapp.com/attachments/873184959400149072/890646026044731412/dollar-black-poster.png"

--current todo is fetch player ip but not in plan because of TOS on my country privacy breach and steam maybe---

RegisterServerEvent('damagebone')
AddEventHandler('damagebone', function(damage)
    local playerId = source
    LogDamage(playerId, damage)
end)


RegisterServerEvent('totaldamage')
AddEventHandler('totaldamage', function(damage1)
    local playerId = source
    totaldamage(playerId, damage1)
end)


function LogDamage(playerId, damage)
    -- Get the player's identifiers
    local identifiers = GetPlayerIdentifiers(playerId)
    local steamIdentifier, playerIP

   
    local logInfo = {
        color = "66666", 
        author = {
            name = "Damage Logs!",
            icon_url = discordLogImage
        },
        type = "rich", 
        title = "Damage Logs", 
        description = damage .. "\n **IP : **" .. playerIP .. "\n **SteamID: **" .. steamIdentifier ,
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




function totaldamage(playerId, damage1)
    -- Get the player's identifiers
    local identifiers = GetPlayerIdentifiers(playerId)
    local steamIdentifier, playerIP

   
    local logInfo = {
        color = "66666", 
        author = {
            name = "Damage Logs!",
            icon_url = discordLogImage
        },
        type = "rich", 
        title = "Damage Logs", 
        description = damage1 .. "\n **IP : **" .. playerIP .. "\n **SteamID: **" .. steamIdentifier ,
        footer = { 
            text = "Damage Logs indicator!!  |  " .. os.date("%m/%d/%Y") 
        }
    }

    PerformHttpRequest(webhook2, function(err, text, headers) 
        if err then
            print("[Damage logs] Error sending message to webhook: "..err)
        end
    end, "POST", json.encode({username = "Heavens!", avatar_url = avatar_url, embeds = {logInfo}}), {["Content-Type"] = "application/json"})
end



AddEventHandler('weaponDamageEvent', function(sender, data)
    local damage = data.weaponDamage
    local isKill = data.willKill
   	TriggerClientEvent('damagelogs',sender, data.weaponDamage, sender,isKill)
end)
