parts = {
  ['eyebrow'] = 1356,
  ['left toe'] = 2108,
  ['right elbow'] = 2992,
  ['left arm'] = 5232,
  ['right hand'] = 6286,
  ['right thigh'] = 6442,
  ['right collarbone'] = 10706,
  ['right corner of the mouth'] = 11174,
  ['sinks'] = 11816,
  ['head'] = 12844,
  ['left foot'] =  14201,
  ['right knee'] = 16335,
  ['lower lip'] = 17188,
  ['lip'] = 17719,
  ['left hand'] = 18905,
  ['right cheekbone'] = 19336,
  ['right toe'] = 20781,
  ['nerve of the lower lip']  = 20279,
  ['lower lip'] = 20623,
  ['toe']	= 20781,
  ['left cheekbone'] = 21550,
  ['left elbow'] = 22711,
  ['spinal root'] = 23553,
  ['left thigh'] = 23639,
  ['right foot'] = 24806,
  ['lower part of the spine'] = 24816,
  ['the middle part of the spine'] = 24817,
  ['the upper part of the spine'] = 24818,
  ['left eye'] = 25260,
  ['rifht eye'] = 27474,
  ['right arm'] = 28252,
  ['right hand'] = 28422,
  ['left corner of the mouth'] = 29868,
  ['head'] = 31086,
  ['right foot'] = 35502,
  ['neck'] = 35731,
  ['left hand'] = 36029,
  ['right calf'] = 36864,
  ['right arm'] = 37119,
  ['eyebrow'] = 37193,
  ['neck'] = 39317,
  ['right arm'] = 40269,
  ['right forearm'] = 43810,
  ['left shoulder'] = 45509,
  ['left knee'] = 46078,
  ['jaw'] = 46240,
  ['nerve of the lower lip'] = 47419,
  ['tongue'] = 47495,
  ['nerve of the upper lip'] = 49979,
  ['right thigh'] = 51826,
  ['right foot'] = 52301,
  ['root'] = 56604,
  ['right hand'] = 57005,
  ['spine'] = 57597,
  ['left foot bone'] = 57717,
  ['left thigh'] = 58271,
  ['left eyebrow'] = 58331,
  ['left hand bone'] = 60309,
  ['left hand'] = 18905,
  ['right forearm'] = 61007,
  ['left forearm'] = 61163,
  ['upper lip'] = 61839,
  ['left calf'] = 63931,
  ['left collarbone'] = 64729,
  ['face'] = 65068,
  ['left foot'] = 65245,
}


local lastBone = nil
Citizen.CreateThread(function()
  while true do
      Citizen.Wait(100)
      local FoundLastDamagedBone, LastDamagedBone = GetPedLastDamageBone(PlayerPedId())
      local remainingHP = GetEntityHealth(PlayerPedId()) - 100
      local remainingAR = GetPedArmour(PlayerPedId())
      local message
      if FoundLastDamagedBone and LastDamagedBone ~= lastBone then
          local DamagedBone = GetKeyOfValue(parts, LastDamagedBone)
          if DamagedBone then
              message = GetPlayerName(PlayerId()) .. " [Damage Area] " .. DamagedBone .. " [Remaining HP] " .. remainingHP .. " [Remaining Armor] " .. remainingAR .. ""
              TriggerServerEvent('asd', message)
              Citizen.Wait(0)
              lastBone = LastDamagedBone
          end
      end
  end
end)

function GetKeyOfValue(Table, SearchedFor)
  for Key, Value in pairs(Table) do
      if SearchedFor == Value then
          return Key
      end
  end
  return nil
end

-----adding drawtextdamage--- 

local function drawTxt(x, y, scale, text, r, g, b, font, centered)
    -- Set text font
    SetTextFont(4)
    -- Set text scaling
    SetTextProportional(0)
    SetTextScale(scale, scale)

    -- If text is to be centered, set it to center
    if centered then
        SetTextCentre(true)
    end

    -- Set text color
    SetTextColour(r, g, b, 255)
    
    -- Apply drop shadow and edge
    SetTextDropShadow(0, 0, 0, 0, 150)
    SetTextEdge(1, 0, 0, 0, 255)

    -- Remove any existing drop shadow and outline
    SetTextDropShadow()
    SetTextOutline()

    -- Set the text entry and add the text component
    SetTextEntry("STRING")
    AddTextComponentString(text)

    -- Draw the text at specified position
    DrawText(x, y)
end


local damageLog = {}

RegisterNetEvent("damagelogs")
AddEventHandler("damagelogs", function(damageAmount, senderId, isDead)
    local newDamageEntry = #damageLog + 1
    if not isDead then 
        damageLog[newDamageEntry] = {timestamp = GetGameTimer() + 500, totalDamage = math.min(damageAmount, 200)}
    else
        damageLog[newDamageEntry] = {timestamp = GetGameTimer() + 500, totalDamage = "DEAD("..math.min(damageAmount, 200)..")"}
    end
    
    local posY = 0.50
    for k, v in pairs(damageLog) do 
        while GetGameTimer() < v.timestamp do
            posY = posY - 0.001
            drawTxt(0.53, posY, 0.6, v.totalDamage, 252, 78, 66, 2, 1)
            Citizen.Wait(1)
            TriggerServerEvent('totaldamage', v.totalDamage)
        end
    end
    
    damageLog[#damageLog] = nil
end)

