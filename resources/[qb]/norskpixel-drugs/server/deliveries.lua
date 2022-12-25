
local QBCore = exports['norskpixel-core']:GetCoreObject()

RegisterServerEvent('norskpixel-drugs:server:updateDealerItems')
AddEventHandler('norskpixel-drugs:server:updateDealerItems', function(itemData, amount, dealer)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Config.Dealers[dealer]["products"][itemData.slot].amount - 1 >= 0 then
        Config.Dealers[dealer]["products"][itemData.slot].amount =
            Config.Dealers[dealer]["products"][itemData.slot].amount - amount
        TriggerClientEvent('norskpixel-drugs:client:setDealerItems', -1, itemData, amount, dealer)
    else
        Player.Functions.RemoveItem(itemData.name, amount)
        Player.Functions.AddMoney('cash', amount * Config.Dealers[dealer]["products"][itemData.slot].price)

        TriggerClientEvent("QBCore:Notify", src, "Denne genstand er ikke ledigt.. Du har fået en refundering.", "error")
    end
end)

RegisterServerEvent('norskpixel-drugs:server:giveDeliveryItems')
AddEventHandler('norskpixel-drugs:server:giveDeliveryItems', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    Player.Functions.AddItem('weed_brick', amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["weed_brick"], "add")
end)

QBCore.Functions.CreateCallback('norskpixel-drugs:server:RequestConfig', function(source, cb)
    cb(Config.Dealers)
end)

RegisterServerEvent('norskpixel-drugs:server:succesDelivery')
AddEventHandler('norskpixel-drugs:server:succesDelivery', function(deliveryData, inTime)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local curRep = Player.PlayerData.metadata["dealerrep"]

    if inTime then
        if Player.Functions.GetItemByName('weed_brick') ~= nil and Player.Functions.GetItemByName('weed_brick').amount >=
            deliveryData["amount"] then
            Player.Functions.RemoveItem('weed_brick', deliveryData["amount"])
            local price = 3000
            if CurrentCops == 1 then
                price = 4000
            elseif CurrentCops == 2 then
                price = 5000
            elseif CurrentCops >= 3 then
                price = 6000
            end
            if curRep < 10 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 8), "dilvery-drugs")
            elseif curRep >= 10 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 10), "dilvery-drugs")
            elseif curRep >= 20 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 12), "dilvery-drugs")
            elseif curRep >= 30 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 15), "dilvery-drugs")
            elseif curRep >= 40 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 18), "dilvery-drugs")
            end

            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["weed_brick"], "remove")
            TriggerClientEvent('QBCore:Notify', src, 'Din ordre er blevet afleveret korrekt', 'success')

            SetTimeout(math.random(5000, 10000), function()
                TriggerClientEvent('norskpixel-drugs:client:sendDeliveryMail', src, 'perfect', deliveryData)

                Player.Functions.SetMetaData('dealerrep', (curRep + 1))
            end)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Du har ikke det korrekte med', 'error')

            if Player.Functions.GetItemByName('weed_brick').amount ~= nil then
                Player.Functions.RemoveItem('weed_brick', Player.Functions.GetItemByName('weed_brick').amount)
                Player.Functions
                    .AddMoney('cash', (Player.Functions.GetItemByName('weed_brick').amount * 6000 / 100 * 5))
            end

            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["weed_brick"], "remove")

            SetTimeout(math.random(5000, 10000), function()
                TriggerClientEvent('norskpixel-drugs:client:sendDeliveryMail', src, 'bad', deliveryData)

                if curRep - 1 > 0 then
                    Player.Functions.SetMetaData('dealerrep', (curRep - 1))
                else
                    Player.Functions.SetMetaData('dealerrep', 0)
                end
            end)
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Du kommer for sent...', 'error')

        Player.Functions.RemoveItem('weed_brick', deliveryData["amount"])
        Player.Functions.AddMoney('cash', (deliveryData["amount"] * 6000 / 100 * 4), "dilvery-drugs-too-late")

        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["weed_brick"], "remove")

        SetTimeout(math.random(5000, 10000), function()
            TriggerClientEvent('norskpixel-drugs:client:sendDeliveryMail', src, 'late', deliveryData)

            if curRep - 1 > 0 then
                Player.Functions.SetMetaData('dealerrep', (curRep - 1))
            else
                Player.Functions.SetMetaData('dealerrep', 0)
            end
        end)
    end
end)

RegisterServerEvent('norskpixel-drugs:server:callCops')
AddEventHandler('norskpixel-drugs:server:callCops', function(streetLabel, coords)
    local msg = "Mistænkelig adfærd finder sted ved " .. streetLabel .. ", mulig narko salg."
    local alertData = {
        title = "Narko salg",
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        description = msg
    }
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                TriggerClientEvent("norskpixel-drugs:client:robberyCall", Player.PlayerData.source, msg, streetLabel, coords)
                TriggerClientEvent("norskpixel-phone:client:addPoliceAlert", Player.PlayerData.source, alertData)
            end
        end
    end
end)

QBCore.Commands.Add("newdealer", "Placer en dealer (Kun Admin)", {{
    name = "name",
    help = "Dealer navn"
}, {
    name = "min",
    help = "Minimum tid"
}, {
    name = "max",
    help = "Maximum tid"
}}, true, function(source, args)
    local dealerName = args[1]
    local mintime = tonumber(args[2])
    local maxtime = tonumber(args[3])

    TriggerClientEvent('norskpixel-drugs:client:CreateDealer', source, dealerName, mintime, maxtime)
end, "admin")

QBCore.Commands.Add("deletedealer", "Fjern dealer (Kun Admin)", {{
    name = "name",
    help = "Navnet på Dealer"
}}, true, function(source, args)
    local dealerName = args[1]
    local result = exports.oxmysql:executeSync('SELECT * FROM dealers WHERE name = ?', {dealerName})
    if result then
        exports.oxmysql:execute('DELETE FROM dealers WHERE name = ?', {dealerName})
        Config.Dealers[dealerName] = nil
        TriggerClientEvent('norskpixel-drugs:client:RefreshDealers', -1, Config.Dealers)
        TriggerClientEvent('QBCore:Notify', source, "Dealer: " .. dealerName .. " Blev slettet", "success")
    else
        TriggerClientEvent('QBCore:Notify', source, "Dealer: " .. dealerName .. " Eksistere ikke", "error")
    end
end, "admin")

QBCore.Commands.Add("dealers", "Vis alle dealere (Kun Admin)", {}, false, function(source, args)
    local DealersText = ""
    if Config.Dealers ~= nil and next(Config.Dealers) ~= nil then
        for k, v in pairs(Config.Dealers) do
            DealersText = DealersText .. "Navn: " .. v["name"] .. "<br>"
        end
        TriggerClientEvent('chat:addMessage', source, {
            template = '<div class="chat-message advert"><div class="chat-message-body"><strong>Liste over dealere: </strong><br><br> ' ..
                DealersText .. '</div></div>',
            args = {}
        })
    else
        TriggerClientEvent('QBCore:Notify', source, 'Ingen dealere er blevet placeret.', 'error')
    end
end, "admin")

QBCore.Commands.Add("dealergoto", "Teleport til dealer (Kun Admin)", {{
    name = "name",
    help = "Dealer navn"
}}, true, function(source, args)
    local DealerName = tostring(args[1])

    if Config.Dealers[DealerName] ~= nil then
        TriggerClientEvent('norskpixel-drugs:client:GotoDealer', source, Config.Dealers[DealerName])
    else
        TriggerClientEvent('QBCore:Notify', source, 'Denne dealer eksistere ikke.', 'error')
    end
end, "admin")

CreateThread(function()
    Wait(500)
    local dealers = exports.oxmysql:executeSync('SELECT * FROM dealers', {})
    if dealers[1] ~= nil then
        for k, v in pairs(dealers) do
            local coords = json.decode(v.coords)
            local time = json.decode(v.time)

            Config.Dealers[v.name] = {
                ["name"] = v.name,
                ["coords"] = {
                    ["x"] = coords.x,
                    ["y"] = coords.y,
                    ["z"] = coords.z
                },
                ["time"] = {
                    ["min"] = time.min,
                    ["max"] = time.max
                },
                ["products"] = Config.Products
            }
        end
    end
    TriggerClientEvent('norskpixel-drugs:client:RefreshDealers', -1, Config.Dealers)
end)

RegisterServerEvent('norskpixel-drugs:server:CreateDealer')
AddEventHandler('norskpixel-drugs:server:CreateDealer', function(DealerData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local result = exports.oxmysql:executeSync('SELECT * FROM dealers WHERE name = ?', {DealerData.name})
    if result[1] ~= nil then
        TriggerClientEvent('QBCore:Notify', src, "En dealer har allerede samme navn..", "error")
    else
        exports.oxmysql:insert('INSERT INTO dealers (name, coords, time, createdby) VALUES (?, ?, ?, ?)', {DealerData.name,
                                                                                                  json.encode(
            DealerData.pos), json.encode(DealerData.time), Player.PlayerData.citizenid}, function()
            Config.Dealers[DealerData.name] = {
                ["name"] = DealerData.name,
                ["coords"] = {
                    ["x"] = DealerData.pos.x,
                    ["y"] = DealerData.pos.y,
                    ["z"] = DealerData.pos.z
                },
                ["time"] = {
                    ["min"] = DealerData.time.min,
                    ["max"] = DealerData.time.max
                },
                ["products"] = Config.Products
            }

            TriggerClientEvent('norskpixel-drugs:client:RefreshDealers', -1, Config.Dealers)
        end)
    end
end)

function GetDealers()
    return Config.Dealers
end
