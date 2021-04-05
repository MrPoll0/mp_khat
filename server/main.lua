ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local isProcesing = false
local city = GetConvar("city", "")

if city == "Paleto Bay" then 
proc = {x = 1790.08, y = 4602.98, z = 37.68, h = 6.25}
arbustos = {
  {x = -839.78, y = 4168.5, z = 212.16},
  {x = -830.67, y = 4164.14, z= 213.54},
  {x = -817.2, y = 4142.07, z= 210.0},
  {x = -803.44, y = 4127.85, z= 205.03},
  {x = -778.0, y = 4180.2, z= 190.0}
}
processer = {x = 1043.12, y = -3192.48,z = -37.92, h = 173.88}
tpinto = {x = 1066.28, y = -3183.36, z = -39.16}
tpout = {x = 201.72, y = 2462.34, z = 55.69}
elseif city == "Los Santos" then 
proc = {x = 666.39, y = 98.32, z = 80.75, h = 355.36}
arbustos = {
  {x = -1799.3, y = -75.61, z = 82.58},
  {x = -1757.93, y = -78.92, z= 79.87},
  {x = -1735.24, y = -68.01, z= 77.84},
  {x = -1786.29, y = -45.22, z= 77.86},
  {x = -1799.47, y = -27.91, z= 79.5}
}
processer = {x = 1043.12, y = -3192.48,z = -37.92, h = 173.88}
tpinto = {x = 1066.28, y = -3183.36, z = -39.16}
tpout = {x = -90.73, y = -67.8, z = 58.86}
end	

ESX.RegisterServerCallback('mp_khat:coords', function(source, cb)
	cb(proc, arbustos, processer, tpinto, tpout)
end)

RegisterServerEvent('mp_droga:givekhat')
AddEventHandler('mp_droga:givekhat', function(drug)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addInventoryItem('khat', 1)
end)

RegisterServerEvent('mp_droga:removekhat')
AddEventHandler('mp_droga:removekhat', function(drug)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local khat = xPlayer.getInventoryItem('khat')
	if khat.count >= 1 and isProcesing == false then
		xPlayer.removeInventoryItem('khat', khat.count)
		isProcesing = true
		TriggerClientEvent('esx:showNotification', source, "Procesando...")
		SetTimeout(10000, function()
			xPlayer.addInventoryItem('khatproc', khat.count)
			isProcesing = false
		end)
	elseif khat.count <= 0 and isProcesing == false then
		TriggerClientEvent('esx:showNotification', source, "¿Qué se supone que vas a procesar?")
	end
end)

RegisterServerEvent('mp_droga:removekhatproc')
AddEventHandler('mp_droga:removekhatproc', function(money)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local khatproc = xPlayer.getInventoryItem('khatproc')
	if khatproc.count >= 1 then
		xPlayer.removeInventoryItem('khatproc', khatproc.count)
		xPlayer.addMoney(money*khatproc.count)
		TriggerClientEvent('esx:showNotification', source, "Gracias, aquí tienes tu dinero. Si consigues más seguiré por aquí.")
	elseif khatproc.count <= 0 then
		TriggerClientEvent('esx:showNotification', source, "¿Pensabas que ibas a engañarme? Vete antes de que llame a mi mafia.")
	end
end)

