
local QBCore = exports['norskpixel-core']:GetCoreObject()
local chicken = vehicleBaseRepairCost

RegisterNetEvent('norskpixel-customs:attemptPurchase', function(type, upgradeLevel)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local balance = nil
    if Player.PlayerData.job.name == "mechanic" then
        balance = exports['norskpixel-bossmenu']:GetAccount(Player.PlayerData.job.name)
    else
        balance = Player.Functions.GetMoney(moneyType)
    end
    if type == "repair" then
        if balance >= chicken then
            if Player.PlayerData.job.name == "mechanic" then
                TriggerEvent('norskpixel-bossmenu:server:removeAccountMoney', Player.PlayerData.job.name, chicken)
            else
                Player.Functions.RemoveMoney(moneyType, chicken, "bennys")
                print(moneyType, chicken)
            end
            TriggerClientEvent('norskpixel-customs:purchaseSuccessful', src)
        else
            TriggerClientEvent('norskpixel-customs:purchaseFailed', src)
        end
    elseif type == "performance" then
        if balance >= vehicleCustomisationPrices[type].prices[upgradeLevel] then
            TriggerClientEvent('norskpixel-customs:purchaseSuccessful', src)
            if Player.PlayerData.job.name == "mechanic" then
                TriggerEvent('norskpixel-bossmenu:server:removeAccountMoney', Player.PlayerData.job.name,
                    vehicleCustomisationPrices[type].prices[upgradeLevel])
            else
                Player.Functions.RemoveMoney(moneyType, vehicleCustomisationPrices[type].prices[upgradeLevel], "bennys")
            end
        else
            TriggerClientEvent('norskpixel-customs:purchaseFailed', src)
        end
    else
        if balance >= vehicleCustomisationPrices[type].price then
            TriggerClientEvent('norskpixel-customs:purchaseSuccessful', src)
            if Player.PlayerData.job.name == "mechanic" then
                TriggerEvent('norskpixel-bossmenu:server:removeAccountMoney', Player.PlayerData.job.name,
                    vehicleCustomisationPrices[type].price)
            else
                Player.Functions.RemoveMoney(moneyType, vehicleCustomisationPrices[type].price, "bennys")
            end
        else
            TriggerClientEvent('norskpixel-customs:purchaseFailed', src)
        end
    end
end)

RegisterNetEvent('norskpixel-customs:updateRepairCost', function(cost)
    chicken = cost
end)

RegisterNetEvent("updateVehicle", function(myCar)
    local src = source
    if IsVehicleOwned(myCar.plate) then
        exports.oxmysql:execute('UPDATE player_vehicles SET mods = ? WHERE plate = ?', {json.encode(myCar), myCar.plate})
    end
end)

function IsVehicleOwned(plate)
    local retval = false
    local result = exports.oxmysql:scalarSync('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if result then
        retval = true
    end
    return retval
end