
RegisterServerEvent('json:dataStructure')
AddEventHandler('json:dataStructure', function(data)
    -- ??
end)

RegisterServerEvent('norskpixel-radialmenu:trunk:server:Door')
AddEventHandler('norskpixel-radialmenu:trunk:server:Door', function(open, plate, door)
    TriggerClientEvent('norskpixel-radialmenu:trunk:client:Door', -1, plate, door, open)
end)