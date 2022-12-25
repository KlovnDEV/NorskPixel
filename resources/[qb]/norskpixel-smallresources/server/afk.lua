local QBCore = exports['norskpixel-core']:GetCoreObject()

RegisterNetEvent('KickForAFK', function()
    local src = source
	DropPlayer(src, 'You Have Been Kicked For Being AFK')
end)

QBCore.Functions.CreateCallback('norskpixel-afkkick:server:GetPermissions', function(source, cb)
    local src = source
    local group = QBCore.Functions.GetPermission(src)
    cb(group)
end)