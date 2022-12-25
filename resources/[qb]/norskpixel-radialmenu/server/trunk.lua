
local QBCore = exports['norskpixel-core']:GetCoreObject()
local trunkBusy = {}

RegisterServerEvent('norskpixel-trunk:server:setTrunkBusy')
AddEventHandler('norskpixel-trunk:server:setTrunkBusy', function(plate, busy)
    trunkBusy[plate] = busy
end)

QBCore.Functions.CreateCallback('norskpixel-trunk:server:getTrunkBusy', function(source, cb, plate)
    if trunkBusy[plate] then
        cb(true)
    end
    cb(false)
end)

RegisterServerEvent('norskpixel-trunk:server:KidnapTrunk')
AddEventHandler('norskpixel-trunk:server:KidnapTrunk', function(targetId, closestVehicle)
    TriggerClientEvent('norskpixel-trunk:client:KidnapGetIn', targetId, closestVehicle)
end)

QBCore.Commands.Add("getintrunk", "Get In Trunk", {}, false, function(source, args)
    TriggerClientEvent('norskpixel-trunk:client:GetIn', source)
end)

QBCore.Commands.Add("putintrunk", "Put Player In Trunk", {}, false, function(source, args)
    TriggerClientEvent('norskpixel-trunk:server:KidnapTrunk', source)
end)