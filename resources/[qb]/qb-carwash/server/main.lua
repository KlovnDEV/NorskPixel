
RegisterServerEvent('norskpixel-carwash:server:washCar')
AddEventHandler('norskpixel-carwash:server:washCar', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveMoney('cash', Config.DefaultPrice, "car-washed") then
        TriggerClientEvent('norskpixel-carwash:client:washCar', src)
    elseif Player.Functions.RemoveMoney('bank', Config.DefaultPrice, "car-washed") then
        TriggerClientEvent('norskpixel-carwash:client:washCar', src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Du har ikke nok penge..', 'error')
    end
end)