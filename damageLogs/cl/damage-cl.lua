-----------------------------------------
-- Configuration & State
-----------------------------------------
local damageLogs = {}
local lastDamagedBoneId = nil
local lastEventTime = 0
local isDrawing = false

-----------------------------------------
-- Utility Functions
-----------------------------------------
local function drawTxt(x, y, scale, text, r, g, b, font, centered)
    SetTextFont(font or 4)
    SetTextScale(scale, scale)
    if centered then SetTextCentre(true) end
    SetTextColour(r, g, b, 255)
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function cleanupDamageLogs()
    local currentTime = GetGameTimer()
    while #damageLogs > 0 and currentTime >= damageLogs[1].timestamp do
        table.remove(damageLogs, 1)
    end
end

-- Dynamic Thread for Drawing Floating UI
local function startDrawThread()
    if isDrawing then return end
    isDrawing = true
    
    Citizen.CreateThread(function()
        local ui = Config.UI
        while #damageLogs > 0 do
            cleanupDamageLogs()
            if #damageLogs > 0 then
                local posY = ui.y
                for i = #damageLogs, 1, -1 do -- Draw newest logs first
                    local log = damageLogs[i]
                    drawTxt(ui.x, posY, ui.scale, tostring(log.totalDamage), ui.color.r, ui.color.g, ui.color.b, ui.font, ui.centered)
                    posY = posY - ui.spacing
                end
                Citizen.Wait(0)
            end
        end
        isDrawing = false
    end)
end

-----------------------------------------
-- Event Handlers
-----------------------------------------

-- Modern Event-Driven Damage Detection
AddEventHandler('gameEventTriggered', function(eventName, args)
    if eventName == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        local attacker = args[2]
        
        -- Verify that the entity receiving damage is the local player ped
        if victim == PlayerPedId() then
            local foundBone, currentBoneId = GetPedLastDamageBone(victim)
            local currentTime = GetGameTimer()

            if foundBone and (currentBoneId ~= lastDamagedBoneId or (currentTime - lastEventTime) > Config.NetworkCooldown) then
                if (currentTime - lastEventTime) > Config.NetworkCooldown then
                    local remainingHP = math.max(0, GetEntityHealth(victim) - 100)
                    local remainingArmor = GetPedArmour(victim)

                    -- Send only raw integers to the server for sanitization, verification, and logging
                    TriggerServerEvent('damageLogs:onBoneDamage', currentBoneId, remainingHP, remainingArmor)

                    lastDamagedBoneId = currentBoneId
                    lastEventTime = currentTime
                    ClearPedLastDamageBone(victim) -- Reset internal state
                end
            end
        end
    end
end)

-- Receive damage log display request from server
RegisterNetEvent("damagelogs")
AddEventHandler("damagelogs", function(damageAmount, isDead)
    local displayedDamage = isDead and "DEAD" or tostring(math.floor(damageAmount))

    -- Limit damage logs table size to Config limit
    if #damageLogs >= Config.MaxDamageLogs then
        table.remove(damageLogs, 1)
    end

    table.insert(damageLogs, {
        timestamp = GetGameTimer() + Config.DisplayTime,
        totalDamage = displayedDamage
    })

    -- Ensure drawing thread is active
    startDrawThread()
end)
