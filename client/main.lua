
ESX = nil

local binselected = false
local completepaytable = nil
local tableupdate = false
local temppaytable =  nil
local totalbagpay = 0
local lastpickup = nil
local platenumb = nil
local paused = false
local iscurrentboss = false
local work_truck = nil
local truckdeposit = false
local trashcollection = false
local trashcollectionpos = nil
local bagsoftrash = nil
local currentbag = nil
local namezone = "Delivery"
local namezonenum = 0
local namezoneregion = 0
local MissionRegion = 0
local viemaxvehicule = 1000
local argentretire = 0
local livraisonTotalPaye = 0
local livraisonnombre = 0
local MissionRetourCamion = false
local MissionNum = 0
local MissionLivraison = false
local isInService = false
local PlayerData              = nil
local GUI                     = {}
GUI.Time                      = 0
local hasAlreadyEnteredMarker = false
local lastZone                = nil
local Blips                   = {}
local plaquevehicule = ""
local plaquevehiculeactuel = ""
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local jobveh = nil
--------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
	TriggerServerEvent('eotix_garbagejob:DawayNasam')
end)

RegisterNetEvent('eotix_garbagejob:PratiTuka')
AddEventHandler('eotix_garbagejob:PratiTuka', function(trucknumber)
	Config.TruckPlateNumb = trucknumber
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('eotix_garbagejob:PusniKofa')
AddEventHandler('eotix_garbagejob:PusniKofa', function(binpos, platenumber,  bags)
	if isInService then
		if GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)) == platenumber then
			iscurrentboss = false
			platenumb = platenumber
			trashcollectionpos = binpos
			bagsoftrash = bags
			currentbag = bagsoftrash
			MissionLivraison = false
			trashcollection = true
			paused = true
			CurrentActionMsg = ''
			CollectionAction = 'collection'
			work_truck = GetVehiclePedIsIn(PlayerPedId(), false)
			binselected = true
		end
	end
end)

RegisterNetEvent('eotix_garbagejob:addbags')
AddEventHandler('eotix_garbagejob:addbags', function(platenumber, bags, crewmember)
	if isInService then
		if platenumb == platenumber then
			if iscurrentboss then
				totalbagpay = totalbagpay + bags
				addcremember = true
				if temppaytable == nil then 
					temppaytable = {}
				end

				for i, v in pairs(temppaytable) do
					
					if temppaytable[i] == crewmember then
						addcremember = false
					end
				end
				if addcremember then
					table.insert(temppaytable, crewmember)
				end
			end
		end
	end
end)

RegisterNetEvent('eotix_garbagejob:startpayrequest')
AddEventHandler('eotix_garbagejob:startpayrequest', function(platenumber, amount)
	if isInService then
		if platenumb == platenumber then
			TriggerServerEvent('eotix_garbagejob:pay', amount)
			platenumb = nil
		end
	end
end)

RegisterNetEvent('eotix_garbagejob:removedbag')
AddEventHandler('eotix_garbagejob:removedbag', function(platenumber)
	if isInService then
		if platenumb == platenumber then
			currentbag = currentbag - 1
		end
	end
end)

RegisterNetEvent('eotix_garbagejob:countbagtotal')
AddEventHandler('eotix_garbagejob:countbagtotal', function(platenumber)
	if isInService then
		if platenumb == platenumber then
			if not iscurrentboss then
			TriggerServerEvent('eotix_garbagejob:bagsdone', platenumb, totalbagpay)
			totalbagpay = 0
			end
		end
	end
end)

RegisterNetEvent('eotix_garbagejob:clearjob')
AddEventHandler('eotix_garbagejob:clearjob', function(platenumber)
	if platenumb == platenumber then
		trashcollectionpos = nil
		bagsoftrash = nil
		work_truck = nil
		trashcollection = false
		truckdeposit = false
		CurrentAction = nil
		CollectionAction = nil
		paused = false
	end
end)

-- MENUS
function MenuCloakRoom()
	TriggerEvent('nh-context:sendMenu', {
        {
            id = 1,
            header = "Чистене на отпадъци",
            txt = "Главно меню"
        },
        {
            id = 2,
            header = "Започни Работа",
            txt = "",
            params = {
                event = "eotix_garbagejob:JobEvent",
                args = true
            }
        },
		{
            id = 3,
            header = "Прекрати Работа",
            txt = "",
            params = {
                event = "eotix_garbagejob:JobEvent",
                args = false
            }
        },
    })
end

RegisterNetEvent('eotix_garbagejob:JobEvent')
AddEventHandler('eotix_garbagejob:JobEvent', function(a)
	isInService = a
	if a then
		ESX.Game.SpawnVehicle('trash', Config.Zones.VehicleSpawnPoint.Pos, 270.0, function(vehicle)
			jobveh = vehicle
			local trucknumber = Config.TruckPlateNumb + 1
			if trucknumber <=9 then
				SetVehicleNumberPlateText(vehicle, 'TCREW00'..trucknumber)
				plaquevehicule =   'TCREW00'..trucknumber 
			elseif trucknumber <=99 then
				SetVehicleNumberPlateText(vehicle, 'TCREW0'..trucknumber)
				plaquevehicule =   'TCREW0'..trucknumber 
			else
				SetVehicleNumberPlateText(vehicle, 'TCREW'..trucknumber)
				plaquevehicule =   'TCREW'..trucknumber 
			end
		
			TriggerServerEvent('eotix_garbagejob:movetruckcount')   
			MissionLivraisonSelect()
			local plate = GetVehicleNumberPlateText(vehicle)
			-- TriggerServerEvent('garage:addKeys', plate)
			-- exports["eotix_fuel"]:SetFuel(vehicle, 100)		-- ТУК ДОБАВЕТЕ ВАШИЯ ЕКСПОРТ ЗА FUEL СИСТЕМАТА ВИ
			TriggerEvent('DoLongHudText', 'Качи се в камиона')
		end)
	elseif not a then
		if Blips['delivery'] ~= nil then
			RemoveBlip(Blips['delivery'])
			Blips['delivery'] = nil
		end
				
		MissionLivraison = false
		livraisonnombre = 0
		MissionRegion = 0
		iscurrentboss = false
		binselected = false
		donnerlapaye()
	end
end)


function IsATruck()
	local isATruck = false
	local playerPed = PlayerPedId()
	for i=1, #Config.Trucks, 1 do
		if IsVehicleModel(GetVehiclePedIsUsing(playerPed), Config.Trucks[i]) then
			isATruck = true
			break
		end
	end
	return isATruck
end

function IsJobgarbage()
	-- if PlayerData ~= nil then
	-- 	local isJobgarbage = false
	-- 	if PlayerData.job.name ~= nil and PlayerData.job.name == 'garbage' then
	-- 		isJobgarbage = true
	-- 	end
	-- 	return isJobgarbage
	-- end -- ЗА СЕГА Е БЕЗ ДЖОБ АКО ИСКАШ ДЖОБ ОТВОРИ ТУК
	return true -- И КОМЕНТИРАЙ ТУК
end

AddEventHandler('eotix_garbagejob:hasEnteredMarker', function(zone)

	local playerPed = PlayerPedId()

	if zone == 'CloakRoom' then
		CurrentAction = 'CloakRoom'
		Triggerevent('cd_drawtextui:ShowUI', 'show', '[E] Започни/Спри работа')
	end

	if zone == namezone then
		if isInService and MissionLivraison and MissionNum == namezonenum and MissionRegion == namezoneregion and IsJobgarbage() then
			if IsPedSittingInAnyVehicle(playerPed) and IsATruck() then
				VerifPlaqueVehiculeActuel()
				
				if plaquevehicule == plaquevehiculeactuel then
					if Blips['delivery'] ~= nil then
						RemoveBlip(Blips['delivery'])
						Blips['delivery'] = nil
					end
					CurrentAction     = 'delivery'
					TriggerEvent('DoLongHudText', 'Натисни [E], за да започнеш.', 1)
				else
					TriggerEvent('DoLongHudText', 'Това не е камионът който ти предоставихме!', 2)
				end
			else
				TriggerEvent('DoLongHudText', 'Трябва да си в камиона, който ти е предоставен!', 2)
			end
		end
	end

	if zone == 'RetourCamion' then
		if isInService and MissionRetourCamion and IsJobgarbage() then
			if IsPedSittingInAnyVehicle(playerPed) and IsATruck() then
				VerifPlaqueVehiculeActuel()

				if plaquevehicule == plaquevehiculeactuel then
                    CurrentAction     = 'retourcamion'
				else
                    CurrentAction     = 'retourcamionannulermission'
                    TriggerEvent('DoLongHudText', 'Това не е камионът който ти предоставихме!', 2)
				end
			else
                CurrentAction     = 'retourcamionperdu'
			end
		end
	end
end)

AddEventHandler('eotix_garbagejob:hasExitedMarker', function(zone)
    CurrentAction = nil
	CurrentActionMsg = ''
	TriggerEvent('cd_drawtextui:HideUI')
end) 

function nouvelledestination()
	livraisonnombre = livraisonnombre+1
	local count = 0
	local multibagpay = 0
		for i, v in pairs(temppaytable) do 
		count = count + 1 
	end

	if Config.MulitplyBags then 
	multibagpay = totalbagpay * (count + 1)
	else
	multibagpay = totalbagpay
	end
	local temppayamount =  (destination.Paye + multibagpay) / (count + 1)
	TriggerServerEvent('eotix_garbagejob:requestpay', platenumb,  temppayamount)
	TriggerServerEvent('eotix_garbagejob:endcollection', platenumb)
	livraisonTotalPaye = 0
	totalbagpay = 0
	temppayamount = 0
	temppaytable = nil
	multibagpay = 0
	iscurrentboss = false
	binselected = false
	if livraisonnombre >= Config.MaxDelivery then
		MissionLivraisonStopRetourDepot()
	else

		livraisonsuite = math.random(0, 100)
		
		if livraisonsuite <= 10 then
			MissionLivraisonStopRetourDepot()
		elseif livraisonsuite <= 99 then
			MissionLivraisonSelect()
		elseif livraisonsuite <= 100 then
			if MissionRegion == 1 then
				MissionRegion = 2
			elseif MissionRegion == 2 then
				MissionRegion = 1
			end
			MissionLivraisonSelect()	
		end
	end
end

function round(num, numDecimalPlaces)
    local mult = 5^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function donnerlapaye()
	ped = PlayerPedId()
	vehicle = jobveh
	vievehicule = GetVehicleEngineHealth(vehicle)
	calculargentretire = round(viemaxvehicule-vievehicule)
	
	if calculargentretire <= 0 then
		argentretire = 0
	else
		argentretire = calculargentretire
	end

    ESX.Game.DeleteVehicle(vehicle)
	jobveh = nil

	local amount = livraisonTotalPaye-argentretire
	
	if vievehicule >= 1 then
		if livraisonTotalPaye == 0 then
			livraisonTotalPaye = 0
		else
			if argentretire <= 0 then

				livraisonTotalPaye = 0
			else

				livraisonTotalPaye = 0
			end
		end
	else
		if livraisonTotalPaye ~= 0 and amount <= 0 then

			livraisonTotalPaye = 0
		else
			if argentretire <= 0 then

				livraisonTotalPaye = 0
			else


				livraisonTotalPaye = 0
			end
		end
	end
end

function donnerlapayesanscamion()
	ped = PlayerPedId()
	argentretire = Config.TruckPrice
	
	-- donne paye
	local amount = livraisonTotalPaye-argentretire
	
	if livraisonTotalPaye == 0 then

		livraisonTotalPaye = 0
	else
		if amount >= 1 then

			livraisonTotalPaye = 0
		else

			livraisonTotalPaye = 0
		end
	end
end

function SelectBinandCrew()
	work_truck = GetVehiclePedIsIn(PlayerPedId(), true)
	bagsoftrash = math.random(4, 10)
	local NewBin, NewBinDistance = ESX.Game.GetClosestObject(Config.DumpstersAvaialbe)
	trashcollectionpos = GetEntityCoords(NewBin)
	platenumb = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), true))
	TriggerServerEvent("eotix_garbagejob:binselect", trashcollectionpos, platenumb, bagsoftrash)
end


-- Key Controls
Citizen.CreateThread(function()
    while true do

		Citizen.Wait(0)
		plyCoords = GetEntityCoords(PlayerPedId(), false)
		if CurrentAction ~= nil or CollectionAction ~= nil then
			if IsControlJustReleased(0, 38) then

				if CollectionAction == 'collection' then
					if not HasAnimDictLoaded("anim@heists@narcotics@trash") then
					RequestAnimDict("anim@heists@narcotics@trash") 
					end
					while not HasAnimDictLoaded("anim@heists@narcotics@trash") do 
					Citizen.Wait(0)
					end
					plyCoords = GetEntityCoords(PlayerPedId(), false)
					dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, trashcollectionpos.x, trashcollectionpos.y, trashcollectionpos.z)
					if dist <= 3.5 then
						shownchisti = false
						TriggerEvent('cd_drawtextui:HideUI')
						if currentbag > 0 then
							TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
							TriggerServerEvent('eotix_garbagejob:bagremoval', platenumb)
							trashcollection = false
							Citizen.Wait(4000)
							ClearPedTasks(PlayerPedId())
							local randombag = math.random(0,2)
							if randombag == 0 then
								garbagebag = CreateObject(GetHashKey("prop_cs_street_binbag_01"), 0, 0, 0, true, true, true) -- creates object
								AttachEntityToEntity(garbagebag, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true) -- object is attached to right hand    
							elseif randombag == 1 then
								garbagebag = CreateObject(GetHashKey("bkr_prop_fakeid_binbag_01"), 0, 0, 0, true, true, true) -- creates object
								AttachEntityToEntity(garbagebag, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), .65, 0, -.1, 0, 270.0, 60.0, true, true, false, true, 1, true) -- object is attached to right hand    
							elseif randombag == 2 then
								garbagebag = CreateObject(GetHashKey("hei_prop_heist_binbag"), 0, 0, 0, true, true, true) -- creates object
								AttachEntityToEntity(garbagebag, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.12, 0.0, 0.00, 25.0, 270.0, 180.0, true, true, false, true, 1, true) -- object is attached to right hand    
							end   
							TaskPlayAnim(PlayerPedId(-1), 'anim@heists@narcotics@trash', 'walk', 1.0, -1.0,-1,49,0,0, 0,0)
							truckdeposit = true
							CollectionAction = 'deposit'
						else
							if iscurrentboss then
								local cSCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
								local vassouspawn = CreateObject(GetHashKey("prop_tool_broom"), cSCoords.x, cSCoords.y, cSCoords.z, 1, 1, 1)
								ESX.Streaming.RequestAnimDict("amb@world_human_janitor@male@idle_a", function()
									TaskPlayAnim(PlayerPedId(), "amb@world_human_janitor@male@idle_a", "idle_a", 8.0, -8.0, -1, 0, 0, false, false, false)
									AttachEntityToEntity(vassouspawn, GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),-0.005,0.0,0.0,360.0,360.0,0.0,1,1,0,1,0,1)
								end)
								if temppaytable == nil then
									temppaytable = {}
								end
								TriggerServerEvent('eotix_garbagejob:reportbags', platenumb)
								Citizen.Wait(8000)
								ClearPedTasks(PlayerPedId())
								DetachEntity(vassouspawn, 1, 1)
								DeleteEntity(vassouspawn)
								setring = false
								bagsoftrash = math.random(2,10)
								currentbag = bagsoftrash 
								CurrentAction = nil
								trashcollection = false
								truckdeposit = false
								TriggerEvent('DoLongHudText', 'Събирането приключи върни се в камиона!', 1)
								while not IsPedInVehicle(PlayerPedId(), work_truck, false) do
									Citizen.Wait(0)
								end
								TriggerServerEvent('eotix_garbagejob:endcollection', platenumb)
								SetVehicleDoorShut(work_truck,5,false)
								Citizen.Wait(2000)
								nouvelledestination()
							end
						end
					end
				
				elseif CollectionAction == 'deposit'  then
					local trunk = GetWorldPositionOfEntityBone(work_truck, GetEntityBoneIndexByName(work_truck, "platelight"))
					plyCoords = GetEntityCoords(PlayerPedId(), false)
					dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, trunk.x, trunk.y, trunk.z)
					shownmetni = false 
					TriggerEvent('cd_drawtextui:HideUI')
					if dist <= 2.0 then
						Citizen.Wait(5)
						ClearPedTasksImmediately(PlayerPedId())
						TaskPlayAnim(PlayerPedId(), 'anim@heists@narcotics@trash', 'throw_b', 1.0, -1.0,-1,2,0,0, 0,0)
						Citizen.Wait(800)
						local garbagebagdelete = DeleteEntity(garbagebag)
						totalbagpay = totalbagpay+Config.BagPay
						Citizen.Wait(100)
						ClearPedTasksImmediately(PlayerPedId())
						CollectionAction = 'collection'
						truckdeposit = false
						trashcollection = true
					end
				end  		

				if CurrentAction == 'delivery' then
					SelectBinandCrew()
					while not binselected do
						Citizen.Wait(100)
					end
					while not iscurrentboss do
					Citizen.Wait(250)
					iscurrentboss = true
					end
					SetVehicleDoorOpen(work_truck,5,false, false)
                end

                if CurrentAction == 'retourcamion' then
                    retourcamion_oui()
                end

                if CurrentAction == 'retourcamionperdu' then
                    retourcamionperdu_oui()
                end
				if CurrentAction == 'CloakRoom' then
					MenuCloakRoom()
				end
                CurrentAction = nil
            end
        end
    end
end)

-- DISPLAY MISSION MARKERS AND MARKERS
local shownmetni = false
local shownchisti = false
Citizen.CreateThread(function()
	while true do
		Wait(0)

		if truckdeposit then
			local trunk = GetWorldPositionOfEntityBone(work_truck, GetEntityBoneIndexByName(work_truck, "platelight"))
			plyCoords = GetEntityCoords(PlayerPedId(), false)
			DrawMarker(27, trunk.x , trunk.y, trunk.z, 0, 0, 0, 0, 0, 0, 1.25, 1.25, 1.0001, 0, 128, 0, 200, 0, 0, 0, 0)
			dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, trunk.x , trunk.y, trunk.z)
			if dist <= 2.0 then
				if not shownmetni then
					shownmetni = true
					Triggerevent('cd_drawtextui:ShowUI', 'show', '[E] Метни чувала в камиона')
				end
				else
					if shownmetni then
						shownmetni = false 
						TriggerEvent('cd_drawtextui:HideUI')
					end
			end
		end

		if trashcollection then
			DrawMarker(1, trashcollectionpos.x, trashcollectionpos.y, trashcollectionpos.z, 0, 0, 0, 0, 0, 0, 3.001, 3.0001, 1.0001, 255, 0, 0, 200, 0, 0, 0, 0)
			plyCoords = GetEntityCoords(PlayerPedId(), false)
			dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, trashcollectionpos.x, trashcollectionpos.y, trashcollectionpos.z)
			if dist <= 2.0 then
				if currentbag <= 0 then
					if iscurrentboss then
						if not shownchisti then
							shownchisti = true
							Triggerevent('cd_drawtextui:ShowUI', 'show', '[E] Изчисти зоната')
						end
					else
						if not shownchisti then
							shownchisti = true
							Triggerevent('cd_drawtextui:ShowUI', 'show', 'Събирането приключи.. Изчакай в камиона..')
						end
					end
				else
					if not shownchisti then
						shownchisti = true
						Triggerevent('cd_drawtextui:ShowUI', 'show', "[E] Вземи чувала от кофата ["..currentbag.."/"..bagsoftrash.."]")
					end
				end
			else
				if shownchisti then
					shownchisti = false
					TriggerEvent('cd_drawtextui:HideUI')
				end
			end
		end
		if MissionLivraison then
			DrawMarker(destination.Type, destination.Pos.x, destination.Pos.y, destination.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, destination.Size.x, destination.Size.y, destination.Size.z, destination.Color.r, destination.Color.g, destination.Color.b, 100, false, true, 2, false, false, false, false)
		elseif MissionRetourCamion then
			DrawMarker(destination.Type, destination.Pos.x, destination.Pos.y, destination.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, destination.Size.x, destination.Size.y, destination.Size.z, destination.Color.r, destination.Color.g, destination.Color.b, 100, false, true, 2, false, false, false, false)
		end

		local coords = GetEntityCoords(PlayerPedId())
		
		for k,v in pairs(Config.Zones) do

			if isInService and (IsJobgarbage() and v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
			end
		end

		for k,v in pairs(Config.Cloakroom) do
			-- print('asdasdasd')
			if(IsJobgarbage() and v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
			end
		end
		
	end
end)

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
	while true do
		
		Wait(0)

		if not paused then 

			if IsJobgarbage() then

				local coords      = GetEntityCoords(PlayerPedId())
				local isInMarker  = false
				local currentZone = nil

				for k,v in pairs(Config.Zones) do
					if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
						isInMarker  = true
						currentZone = k
					end
				end
				
				for k,v in pairs(Config.Cloakroom) do
					if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
						isInMarker  = true
						currentZone = k
					end
				end
			
				for k,v in pairs(Config.Livraison) do
					if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
						isInMarker  = true
						currentZone = k
					end
				end

				if isInMarker and not hasAlreadyEnteredMarker then
					hasAlreadyEnteredMarker = true
					lastZone                = currentZone
					TriggerEvent('eotix_garbagejob:hasEnteredMarker', currentZone)
				end

				if not isInMarker and hasAlreadyEnteredMarker then
					hasAlreadyEnteredMarker = false
					TriggerEvent('eotix_garbagejob:hasExitedMarker', lastZone)
				end
			end
		end

	end  
end)

-- CREATE BLIPS
Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Cloakroom.CloakRoom.Pos.x, Config.Cloakroom.CloakRoom.Pos.y, Config.Cloakroom.CloakRoom.Pos.z)

	SetBlipSprite (blip, 318)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, 0.7)
	SetBlipColour (blip, 45)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Чистене на отпадъци')
	EndTextCommandSetBlipName(blip)
end)

-------------------------------------------------
-- Fonctions
-------------------------------------------------
-- Fonction selection nouvelle mission livraison
function MissionLivraisonSelect()
	if MissionRegion == 0 then
		MissionRegion = math.random(1,2)
	end
	
	if MissionRegion == 1 then -- Los santos
		MissionNum = math.random(1, 7)
		while lastpickup == MissionNum do
			Citizen.Wait(50)
			MissionNum = math.random(1, 7)
		end
		if MissionNum == 1 then destination = Config.Livraison.Delivery1LS namezone = "Delivery1LS" namezonenum = 1 namezoneregion = 1
		elseif MissionNum == 2 then destination = Config.Livraison.Delivery2LS namezone = "Delivery2LS" namezonenum = 2 namezoneregion = 1
		elseif MissionNum == 3 then destination = Config.Livraison.Delivery3LS namezone = "Delivery3LS" namezonenum = 3 namezoneregion = 1
		elseif MissionNum == 4 then destination = Config.Livraison.Delivery4LS namezone = "Delivery4LS" namezonenum = 4 namezoneregion = 1
		elseif MissionNum == 5 then destination = Config.Livraison.Delivery5LS namezone = "Delivery5LS" namezonenum = 5 namezoneregion = 1
		elseif MissionNum == 6 then destination = Config.Livraison.Delivery6LS namezone = "Delivery6LS" namezonenum = 6 namezoneregion = 1
		elseif MissionNum == 7 then destination = Config.Livraison.Delivery7LS namezone = "Delivery7LS" namezonenum = 7 namezoneregion = 1
		end
		
	elseif MissionRegion == 2 then -- Blaine County
		MissionNum = math.random(1, 3)
		while lastpickup == MissionNum do
			Citizen.Wait(50)
			MissionNum = math.random(1, 3)
		end
		if MissionNum == 1 then destination = Config.Livraison.Delivery1BC namezone = "Delivery1BC" namezonenum = 1 namezoneregion = 2
		elseif MissionNum == 2 then destination = Config.Livraison.Delivery2BC namezone = "Delivery2BC" namezonenum = 2 namezoneregion = 2
		elseif MissionNum == 3 then destination = Config.Livraison.Delivery3BC namezone = "Delivery3BC" namezonenum = 3 namezoneregion = 2
		end
		
	end
	lastpickup = MissionNum
	MissionLivraisonLetsGo()
end

-- Fonction active mission livraison
function MissionLivraisonLetsGo()
	if Blips['delivery'] ~= nil then
		RemoveBlip(Blips['delivery'])
		Blips['delivery'] = nil
	end
	
	Blips['delivery'] = AddBlipForCoord(destination.Pos.x,  destination.Pos.y,  destination.Pos.z)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Локация")
	SetBlipColour(Blips['delivery'], 1)
	SetBlipRoute(Blips['delivery'], true)
	SetBlipRouteColour(Blips['delivery'], 1)
	EndTextCommandSetBlipName(Blips['delivery'])
	

	if MissionRegion == 1 then -- Los santos
		TriggerEvent('DoLongHudText', 'Отидете до отбелязаната локация!', 1)
	elseif MissionRegion == 2 then -- Blaine County
		TriggerEvent('DoLongHudText', 'Отидете до отбелязаната локация!', 1)
	elseif MissionRegion == 0 then -- au cas ou
		TriggerEvent('DoLongHudText', 'Отидете до отбелязаната локация!', 1)
	end

	MissionLivraison = true
end

--Fonction retour au depot
function MissionLivraisonStopRetourDepot()
	destination = Config.Livraison.RetourCamion
	
	Blips['delivery'] = AddBlipForCoord(destination.Pos.x,  destination.Pos.y,  destination.Pos.z)
	SetBlipRoute(Blips['delivery'], true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Локация")
	EndTextCommandSetBlipName(Blips['delivery'])

	TriggerEvent('DoLongHudText', 'Отидете до отбелязаната локация!', 1)
	
	MissionRegion = 0
	MissionLivraison = false
	MissionNum = 0
	MissionRetourCamion = true
end

function VerifPlaqueVehiculeActuel() 
	plaquevehiculeactuel = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false))
end