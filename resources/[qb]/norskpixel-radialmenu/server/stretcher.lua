
RegisterServerEvent('norskpixel-radialmenu:server:RemoveStretcher')
AddEventHandler('norskpixel-radialmenu:server:RemoveStretcher', function(PlayerPos, StretcherObject)
    TriggerClientEvent('norskpixel-radialmenu:client:RemoveStretcherFromArea', -1, PlayerPos, StretcherObject)
end)

RegisterServerEvent('norskpixel-radialmenu:Stretcher:BusyCheck')
AddEventHandler('norskpixel-radialmenu:Stretcher:BusyCheck', function(id, type)
    local MyId = source
    TriggerClientEvent('norskpixel-radialmenu:Stretcher:client:BusyCheck', id, MyId, type)
end)

RegisterServerEvent('norskpixel-radialmenu:server:BusyResult')
AddEventHandler('norskpixel-radialmenu:server:BusyResult', function(IsBusy, OtherId, type)
    TriggerClientEvent('norskpixel-radialmenu:client:Result', OtherId, IsBusy, type)
end)
