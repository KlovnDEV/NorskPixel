
local QBCore = exports['norskpixel-core']:GetCoreObject()

QBCore.Commands.Add("binds", "Open commandbinding menu", {}, false, function(source, args)
  local Player = QBCore.Functions.GetPlayer(source)
	  TriggerClientEvent("norskpixel-commandbinding:client:openUI", source)
end)

RegisterServerEvent('norskpixel-commandbinding:server:setKeyMeta', function(keyMeta)
    local src = source
    local ply = QBCore.Functions.GetPlayer(src)

    ply.Functions.SetMetaData("commandbinds", keyMeta)
end)