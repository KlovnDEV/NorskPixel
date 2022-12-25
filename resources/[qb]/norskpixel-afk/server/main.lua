
local QBCore = exports['norskpixel-core']:GetCoreObject()

RegisterServerEvent('KickForAFK', function()
  local src = source
	  DropPlayer(src, 'Du fik et Kick, for at være AFK...')
end)

QBCore.Functions.CreateCallback('norskpixel-afkkick:server:GetPermissions', function(source, cb)
  local src = source
  local group = QBCore.Functions.GetPermission(src)
    cb(group)
end)