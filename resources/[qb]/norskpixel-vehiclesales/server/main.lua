
local QBCore = exports['norskpixel-core']:GetCoreObject()

QBCore.Functions.CreateCallback('norskpixel-occasions:server:getVehicles', function(source, cb)
    local result = exports.oxmysql:executeSync('SELECT * FROM occasion_vehicles', {})
    if result[1] ~= nil then
        cb(result)
    else
        cb(nil)
    end
end)

QBCore.Functions.CreateCallback("norskpixel-occasions:server:getSellerInformation", function(source, cb, citizenid)
    local src = source

    exports.oxmysql:fetch('SELECT * FROM players WHERE citizenid = ?', {citizenid}, function(result)
        if result[1] ~= nil then
            cb(result[1])
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('norskpixel-occasions:server:ReturnVehicle')
AddEventHandler('norskpixel-occasions:server:ReturnVehicle', function(vehicleData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local result = exports.oxmysql:executeSync('SELECT * FROM occasion_vehicles WHERE plate = ? AND occasionid = ?',
        {vehicleData['plate'], vehicleData["oid"]})
    if result[1] ~= nil then
        if result[1].seller == Player.PlayerData.citizenid then
            exports.oxmysql:insert(
                'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)',
                {Player.PlayerData.license, Player.PlayerData.citizenid, vehicleData["model"],
                 GetHashKey(vehicleData["model"]), vehicleData["mods"], vehicleData["plate"], 0})
            exports.oxmysql:execute('DELETE FROM occasion_vehicles WHERE occasionid = ? AND plate = ?',
                {vehicleData["oid"], vehicleData['plate']})
            TriggerClientEvent("norskpixel-occasions:client:ReturnOwnedVehicle", src, result[1])
            TriggerClientEvent('norskpixel-occasion:client:refreshVehicles', -1)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Dette er ikke dit køretøj', 'error', 3500)
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Køretøj eksistere ikke', 'error', 3500)
    end
end)

RegisterServerEvent('norskpixel-occasions:server:sellVehicle')
AddEventHandler('norskpixel-occasions:server:sellVehicle', function(vehiclePrice, vehicleData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    exports.oxmysql:execute('DELETE FROM player_vehicles WHERE plate = ? AND vehicle = ?',
        {vehicleData.plate, vehicleData.model})
    exports.oxmysql:insert(
        'INSERT INTO occasion_vehicles (seller, price, description, plate, model, mods, occasionid) VALUES (?, ?, ?, ?, ?, ?, ?)',
        {Player.PlayerData.citizenid, vehiclePrice, escapeSqli(vehicleData.desc), vehicleData.plate, vehicleData.model,
         json.encode(vehicleData.mods), generateOID()})
    TriggerEvent("norskpixel-log:server:sendLog", Player.PlayerData.citizenid, "vehiclesold", {
        model = vehicleData.model,
        vehiclePrice = vehiclePrice
    })
    TriggerEvent("norskpixel-log:server:CreateLog", "vehicleshop", "Vehicle for Sale", "red",
        "**" .. GetPlayerName(src) .. "** has a " .. vehicleData.model .. " priced at " .. vehiclePrice)

    TriggerClientEvent('norskpixel-occasion:client:refreshVehicles', -1)
end)

RegisterServerEvent('norskpixel-occasions:server:sellVehicleBack')
AddEventHandler('norskpixel-occasions:server:sellVehicleBack', function(vData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local price = math.floor(vData.price / 2)
    local plate = vData.plate

    Player.Functions.AddMoney('bank', price)
    TriggerClientEvent('QBCore:Notify', src, 'Du har solgt dit køretøj for ' .. price ..' DKK', 'success', 5500)
    exports.oxmysql:execute('DELETE FROM player_vehicles WHERE plate = ?', {plate})
end)

RegisterServerEvent('norskpixel-occasions:server:buyVehicle')
AddEventHandler('norskpixel-occasions:server:buyVehicle', function(vehicleData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local result = exports.oxmysql:executeSync('SELECT * FROM occasion_vehicles WHERE plate = ? AND occasionid = ?',
        {vehicleData['plate'], vehicleData["oid"]})
    if result[1] ~= nil and next(result[1]) ~= nil then
        if Player.PlayerData.money.bank >= result[1].price then
            local SellerCitizenId = result[1].seller
            local SellerData = QBCore.Functions.GetPlayerByCitizenId(SellerCitizenId)
            -- New price calculation minus tax
            local NewPrice = math.ceil((result[1].price / 100) * 77)
            Player.Functions.RemoveMoney('bank', result[1].price)
            -- Insert vehicle for buyer
            exports.oxmysql:insert(
                'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
                    Player.PlayerData.license,
                    Player.PlayerData.citizenid, result[1]["model"],
                    GetHashKey(result[1]["model"]),
                    result[1]["mods"],
                    result[1]["plate"],
                    0
                })
            -- Handle money transfer
            if SellerData ~= nil then
                -- Add money for online
                SellerData.Functions.AddMoney('bank', NewPrice)
            else
                -- Add money for offline
                local BuyerData = exports.oxmysql:executeSync('SELECT * FROM players WHERE citizenid = ?',
                    {SellerCitizenId})
                if BuyerData[1] ~= nil then
                    local BuyerMoney = json.decode(BuyerData[1].money)
                    BuyerMoney.bank = BuyerMoney.bank + NewPrice
                    exports.oxmysql:execute('UPDATE players SET money = ? WHERE citizenid = ?', {json.encode(BuyerMoney), SellerCitizenId})
                end
            end
            TriggerEvent("norskpixel-log:server:CreateLog", "vehicleshop", "bought", "green", "**" .. GetPlayerName(src) .. "** has bought for " .. result[1].price .. " (" .. result[1].plate ..") from **" .. SellerCitizenId .. "**")
            TriggerClientEvent("norskpixel-occasions:client:BuyFinished", src, result[1])
            TriggerClientEvent('norskpixel-occasion:client:refreshVehicles', -1)
            -- Delete vehicle from Occasion
            exports.oxmysql:execute('DELETE FROM occasion_vehicles WHERE plate = ? AND occasionid = ?',
                {result[1].plate, result[1].occasionid})
            -- Send selling mail to seller
            TriggerEvent('norskpixel-phone:server:sendNewMailToOffline', SellerCitizenId, {
                sender = 'Larrys RV Salg',
                subject = "Du har solgt et køretøj!",
                message = 'Du tjente '..NewPrice..' DKK fra dit salg af '..QBCore.Shared.Vehicles[result[1].model].name..''
            })
        else
            TriggerClientEvent('QBCore:Notify', src, 'Du har ikke nok penge', 'error', 3500)
        end
    end
end)

QBCore.Functions.CreateCallback("norskpixel-vehiclesales:server:CheckModelName", function(source, cb, plate)
    if plate then
        local ReturnData = exports.oxmysql:scalarSync("SELECT vehicle FROM player_vehicles WHERE plate = ?", {plate})
        cb(ReturnData)
    end
end)

function generateOID()
    local num = math.random(1, 10) .. math.random(111, 999)

    return "OC" .. num
end

function round(number)
    return number - (number % 1)
end

function escapeSqli(str)
    local replacements = {
        ['"'] = '\\"',
        ["'"] = "\\'"
    }
    return str:gsub("['\"]", replacements) -- or string.gsub( source, "['\"]", replacements )
end
