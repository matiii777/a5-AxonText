local QBCore = exports['qb-core']:GetCoreObject()
local PlayerJob = QBCore.Functions.GetPlayerData().job
local toghud = true


local function formatTime(data)
	for i=1, #data do
		local v = data[i]
		if v <= 9 then
			data[i] = "0"..v
		end
	end
	return data
end

local function GetPoliceData()
	local PlayerData = QBCore.Functions.GetPlayerData()
	local first = string.sub(PlayerData.charinfo.firstname, 1, 1)
	local second = PlayerData.charinfo.lastname
	local badge = PlayerData.metadata["callsign"]
	return string.upper(first.."."..second.."  	"..badge)
end

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
	toghud = false
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
	
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
	toghud = true
end)


RegisterNetEvent('a5-AxonText:client:ToggleAxon', function() -- you can use this trigger to enable or disable the text (for example in HUD cinema mode)
    if toghud == true then
        toghud = false
    else
        toghud = true
    end
end)

--Threads
Citizen.CreateThread(function()
	while true do
		local sleep = 30000
		if LocalPlayer.state.isLoggedIn then
			if (PlayerJob) and (PlayerJob.name == "police" and PlayerJob.onduty) and toghud then
				local data = GetPoliceData()
				Wait(250)
				SendNUIMessage({
					action  = 'changeJob',
					data = data
				})
			else
				SendNUIMessage({
					action  = 'changeJob',
					data = 'none'
				})
			end	
		end
		Wait(sleep)
	end
end)

Citizen.CreateThread(function()
	while true do
		local sleep = 5000
		if LocalPlayer.state.isLoggedIn then
			if (PlayerJob) and (PlayerJob.name == 'police') then
				sleep = 1000
				local hour = GetClockHours()
				local minute = GetClockMinutes()
				local month = GetClockMonth() + 1
				local dayOfMonth = GetClockDayOfMonth()	  
				local AP = 'AM'

				if hour == 0 or hour == 24 then
				hour = 12
				AP = 'AM'
				elseif hour >= 13 then
				hour = hour - 12
				AP = 'PM'
				end
				minute, month, dayOfMonth, hour = table.unpack(formatTime({minute, month, dayOfMonth, hour}))
				local formatted = "AXON BODYCAM "..dayOfMonth..':'..month..' T:'..hour..':'..minute..AP

				SendNUIMessage({
					action  = 'changeTime',
					data = formatted
				})
			end
		end
		Wait(sleep)
	end
end)

