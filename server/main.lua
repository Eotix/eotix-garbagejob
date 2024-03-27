ESX = nil
passanger1 = nil
passanger2 = nil
passanger3 = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('eotix_garbagejob:pay')
AddEventHandler('eotix_garbagejob:pay', function(amount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local payamount = math.ceil(amount)
	local payout = math.random(2,4)
	local matherino = math.random(0, 2)
	xPlayer.addMoney(tonumber(payamount))
	if matherino == 2 then
		TriggerClientEvent('player:receiveItem', _source, 'plastic', payout)
		TriggerClientEvent('player:receiveItem', _source, 'scrapmetal', payout) 
		-- ТУК СИ ДОБАВЕТЕ ВАШИТЕ ФУНКЦИИ ЗА ПОЛУЧАВАНЕ НА АЙТЪМИ
	end
	TriggerClientEvent('DoLongHudText', _source, 'Ти получи $'.. payamount ..' от тази локация', 1)
end)

RegisterServerEvent('eotix_garbagejob:binselect')
AddEventHandler('eotix_garbagejob:binselect', function(binpos, platenumber, bagnumb)
	TriggerClientEvent('eotix_garbagejob:PusniKofa', -1, binpos, platenumber,  bagnumb)
end)

RegisterServerEvent('eotix_garbagejob:requestpay')
AddEventHandler('eotix_garbagejob:requestpay', function(platenumber, amount)
	TriggerClientEvent('eotix_garbagejob:startpayrequest', -1, platenumber, amount)
end)

RegisterServerEvent('eotix_garbagejob:bagremoval')
AddEventHandler('eotix_garbagejob:bagremoval', function(platenumber)
	TriggerClientEvent('eotix_garbagejob:removedbag', -1, platenumber)
end)

RegisterServerEvent('eotix_garbagejob:endcollection')
AddEventHandler('eotix_garbagejob:endcollection', function(platenumber)
	TriggerClientEvent('eotix_garbagejob:clearjob', -1, platenumber)
end)

RegisterServerEvent('eotix_garbagejob:reportbags')
AddEventHandler('eotix_garbagejob:reportbags', function(platenumber)
	TriggerClientEvent('eotix_garbagejob:countbagtotal', -1, platenumber)
end)

RegisterServerEvent('eotix_garbagejob:bagsdone')
AddEventHandler('eotix_garbagejob:bagsdone', function(platenumber, bagstopay)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	TriggerClientEvent('eotix_garbagejob:addbags', -1, platenumber, bagstopay, xPlayer )
end)

RegisterServerEvent('eotix_garbagejob:DawayNasam')
AddEventHandler('eotix_garbagejob:DawayNasam', function()
	_source = source
	local currenttruckcount = Config.TruckPlateNumb
	TriggerClientEvent('eotix_garbagejob:PratiTuka', _source,  currenttruckcount)
end)

RegisterServerEvent('eotix_garbagejob:movetruckcount')
AddEventHandler('eotix_garbagejob:movetruckcount', function()
	local currenttruckcount = Config.TruckPlateNumb + 1
	if currenttruckcount == 999 then currenttruckcount = 1 end
	Config.TruckPlateNumb = currenttruckcount
end)





