
RegisterNetEvent('norskpixel-doorlock:server:setupDoors', function()
	TriggerClientEvent("norskpixel-doorlock:client:setDoors", QB.Doors)
end)

RegisterNetEvent('norskpixel-doorlock:server:updateState', function(doorID, state)
	QB.Doors[doorID].locked = state
	TriggerClientEvent('norskpixel-doorlock:client:setState', -1, doorID, state)
end)