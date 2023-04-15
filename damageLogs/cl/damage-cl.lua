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
      local remainingHP = GetEntityHealth(PlayerPedId())
      local remainingAR = GetPedArmour(PlayerPedId())
      local message = nil
      local attacker, victim = nil, nil
      local playerId = PlayerId()

      for i=0, 255 do
          if NetworkIsPlayerActive(i) and GetPlayerPed(i) ~= PlayerPedId() then
              local ped = GetPlayerPed(i)
              local coords = GetEntityCoords(PlayerPedId())
              if #(coords - GetEntityCoords(ped)) < 5.0 then
                  local damage = GetPedLastDamageBone(ped)
                  if damage ~= -1 then
                      victim = ped
                      attacker = GetPlayerServerId(i)
                      break
                  end
              end
          end
      end

      local playerName = GetPlayerName(playerId)

      if FoundLastDamagedBone and LastDamagedBone ~= lastBone then
          local DamagedBone = GetKeyOfValue(parts, LastDamagedBone)
          if DamagedBone then
              if victim and DoesEntityExist(victim) and IsEntityAPed(victim) then
                  local victimName = GetEntityTypeName(victim)
                  message = string.format("%s [%s] `%s` [Damage Area] `%s` [Remaining HP] `%d` [Remaining Armor] `%d`", playerName, victimName, attacker, DamagedBone, remainingHP, remainingAR)
              else
                  message = string.format("%s [Damage Area] `%s` [Remaining HP] `%d` [Remaining Armor] `%d`", playerName, DamagedBone, remainingHP, remainingAR)
              end

              if remainingHP <= -100 or remainingHP == 0 then 
                  message = string.format("%s [Dead] `%s` [Remaining Armor] `%d`", playerName, DamagedBone, remainingAR)
              end

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

 --_Remove Dependency of framewrok trying to be a Standalone SHIT?
-- ESX = nil

-- Citizen.CreateThread(function()
-- 	while ESX == nil do
-- 		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
-- 		Citizen.Wait(0)
-- 	end
-- end)
    
-- Citizen.CreateThread(function()
-- 	while true do
-- 	 Citizen.Wait(0)
-- 	 if IsControlJustPressed(0, 215) then
-- 		 screenshot = true
-- 		 exports['screenshot-basic']:requestScreenshotUpload('', 'files[]', function(data) --Change Webhook
-- 			 local resp = json.decode(data)
-- 				 end)
-- 				 TriggerServerEvent('screenshot:logger')
-- 			 end
-- 		 end
-- 	 end)
	--- SCREENSHOTLOGGER EVERYTIME THEY PRESS ENTER OR BACKSPACE FORGOT THE KEYPRESS
