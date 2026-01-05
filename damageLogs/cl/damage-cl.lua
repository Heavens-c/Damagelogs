-----------------------------------------
-- Bone IDs mapping
-----------------------------------------
local boneIds = {
    ['eyebrow'] = 1356, ['left toe'] = 2108, ['right elbow'] = 2992, ['left arm'] = 5232, 
    ['right hand'] = 6286, ['right thigh'] = 6442, ['right collarbone'] = 10706, 
    ['right corner of the mouth'] = 11174, ['sinks'] = 11816, ['head'] = 12844, 
    ['left foot'] = 14201, ['right knee'] = 16335, ['lower lip'] = 17188, ['lip'] = 17719, 
    ['left hand'] = 18905, ['right cheekbone'] = 19336, ['right toe'] = 20781, 
    ['nerve of the lower lip'] = 20279, ['left cheekbone'] = 21550, ['left elbow'] = 22711, 
    ['spinal root'] = 23553, ['left thigh'] = 23639, ['right foot'] = 24806, 
    ['lower part of the spine'] = 24816, ['the middle part of the spine'] = 24817, 
    ['the upper part of the spine'] = 24818, ['left eye'] = 25260, ['right eye'] = 27474, 
    ['right arm'] = 28252, ['left corner of the mouth'] = 29868, ['neck'] = 35731, 
    ['right calf'] = 36864, ['right forearm'] = 43810, ['left shoulder'] = 45509, 
    ['left knee'] = 46078, ['jaw'] = 46240, ['tongue'] = 47495, ['nerve of the upper lip'] = 49979, 
    ['right thigh'] = 51826, ['root'] = 56604, ['spine'] = 57597, ['left foot bone'] = 57717, 
    ['left eyebrow'] = 58331, ['left hand bone'] = 60309, ['left forearm'] = 61163, 
    ['upper lip'] = 61839, ['left calf'] = 63931, ['left collarbone'] = 64729, ['face'] = 65068
}

-----------------------------------------
-- Configuration & State
-----------------------------------------
local damageLogs = {}
local MAX_DAMAGE_LOGS = 5
local lastDamagedBoneId = nil
local lastEventTime = 0
local NETWORK_COOLDOWN = 300 -- (ms) Min time between sending network events

-----------------------------------------
-- Utility Functions
-----------------------------------------
local function getBoneNameById(boneId)
    for name, id in pairs(boneIds) do
        if id == boneId then return name end
    end
    return "Unknown Bone"
end

local function drawTxt(x, y, scale, text, r, g, b, font, centered)
    SetTextFont(font or 4)
    SetTextScale(scale, scale)
    if centered then SetTextCentre(true) end
    SetTextColour(r, g, b, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

local function cleanupDamageLogs()
    local currentTime = GetGameTimer()
    while #damageLogs > 0 and currentTime >= damageLogs[1].timestamp do
        table.remove(damageLogs, 1)
    end
end

-----------------------------------------
-- Threads
-----------------------------------------

-- THREAD 1: Damage Detection (Logic Optimized)
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local foundBone, currentBoneId = GetPedLastDamageBone(playerPed)
        local currentTime = GetGameTimer()

        -- Only trigger if bone is found AND it's a new bone or enough time has passed
        if foundBone and (currentBoneId ~= lastDamagedBoneId or (currentTime - lastEventTime) > NETWORK_COOLDOWN) then
            
            -- Prevent Network Overflow (Rate Limiting)
            if (currentTime - lastEventTime) > NETWORK_COOLDOWN then
                local boneName = getBoneNameById(currentBoneId)
                local remainingHP = math.max(0, GetEntityHealth(playerPed) - 100)
                local remainingArmor = GetPedArmour(playerPed)
                
                local message = string.format(
                    "%s | Bone: %s | HP: %d | Armor: %d",
                    GetPlayerName(PlayerId()), boneName, remainingHP, remainingArmor
                )

                TriggerServerEvent('damagebone', message)
                
                lastDamagedBoneId = currentBoneId
                lastEventTime = currentTime
                ClearPedLastDamageBone(playerPed) -- Reset bone state after logging
            end
            Citizen.Wait(10) -- Short wait during combat
        else
            Citizen.Wait(500) -- Long sleep when not taking damage
        end
    end
end)

-- THREAD 2: On-Screen UI (Performance Optimized)
Citizen.CreateThread(function()
    while true do
        if #damageLogs > 0 then
            cleanupDamageLogs()
            local posY = 0.50
            for i = #damageLogs, 1, -1 do -- Draw newest logs first
                local log = damageLogs[i]
                drawTxt(0.53, posY, 0.6, tostring(log.totalDamage), 252, 78, 66, 2, true)
                posY = posY - 0.03
            end
            Citizen.Wait(0)
        else
            Citizen.Wait(1000) -- Complete sleep if no logs to draw
        end
    end
end)

-----------------------------------------
-- Event Handlers
-----------------------------------------
RegisterNetEvent("damagelogs")
AddEventHandler("damagelogs", function(damageAmount, senderId, isDead)
    local displayedDamage = isDead and "DEAD" or tostring(math.floor(damageAmount))
    
    -- Limit damage logs table size
    if #damageLogs >= MAX_DAMAGE_LOGS then
        table.remove(damageLogs, 1)
    end
    
    table.insert(damageLogs, { 
        timestamp = GetGameTimer() + 3000, -- Show for 3 seconds
        totalDamage = displayedDamage 
    })

    -- Throttled Server Log
    TriggerServerEvent('totaldamage', displayedDamage)
end)
