
local QBCore = exports['norskpixel-core']:GetCoreObject()

local ItemList = {
    ["cocaleaf"] = "cocaleaf"
}

local DrugList = {
    ["cokebaggy"] = "cokebaggy"
}

RegisterServerEvent('norskpixel-coke:server:grindleaves')
AddEventHandler('norskpixel-coke:server:grindleaves', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cocaleaf = Player.Functions.GetItemByName('cocaleaf')

    if Player.PlayerData.items ~= nil then
        for k, v in pairs(Player.PlayerData.items) do
            if cocaleaf ~= nil then
                if ItemList[Player.PlayerData.items[k].name] ~= nil then 
                    if Player.PlayerData.items[k].name == "cocaleaf" and Player.PlayerData.items[k].amount >= 2 then 
                        Player.Functions.RemoveItem("cocaleaf", 2)
                        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['cocaleaf'], "remove")
                        TriggerClientEvent("norskpixel-coke:client:grindleavesMinigame", src)
                    else
                        TriggerClientEvent('QBCore:Notify', src, "Du har ikke nok kokainblade", 'error')
                        break
                    end
                end
            else
                TriggerClientEvent('QBCore:Notify', src, "Du har ikke kokainblade", 'error')
                break
            end
        end
    end
end)

RegisterServerEvent('norskpixel-coke:server:processCrack')
AddEventHandler('norskpixel-coke:server:processCrack', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cokebaggy = Player.Functions.GetItemByName('cokebaggy')

    if Player.PlayerData.gang.name == "ballas" then
        if Player.PlayerData.items ~= nil then
            if cokebaggy ~= nil then 
                if cokebaggy.amount >= 2 then

                    Player.Functions.RemoveItem("cokebaggy", 2, false)
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['cokebaggy'], "remove")

                    TriggerClientEvent("norskpixel-coke:client:processCrack", src)
                else
                    TriggerClientEvent('QBCore:Notify', src, "Du har ikke de korrekte varer", 'error')
                end
            else
                TriggerClientEvent('QBCore:Notify', src, "Du har ikke de korrekte varer", 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "Du har ingenting...", "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "Du skal nok snakke med et bandemedlem...", 'error')
    end
end)

RegisterServerEvent('norskpixel-coke:server:cokesell')
AddEventHandler('norskpixel-coke:server:cokesell', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cokebaggy = Player.Functions.GetItemByName('cokebaggy')

    if Player.PlayerData.items ~= nil then 
        for k, v in pairs(Player.PlayerData.items) do 
            if cokebaggy ~= nil then
                if DrugList[Player.PlayerData.items[k].name] ~= nil then 
                    if Player.PlayerData.items[k].name == "cokebaggy" and Player.PlayerData.items[k].amount >= 1 then
                        local random = math.random(50, 65)
                        local amount = Player.PlayerData.items[k].amount * random

                        TriggerClientEvent('chatMessage', source, "Dealer Johnny", "normal", 'Yo '..Player.PlayerData.firstname..', det er ikke sådan du har '..Player.PlayerData.items[k].amount..'poser med coke?')
                        TriggerClientEvent('chatMessage', source, "Dealer Johnny", "normal", 'Jeg køber det hele for '..amount..' DKK' )

                        Player.Functions.RemoveItem("cokebaggy", Player.PlayerData.items[k].amount)
                        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['cokebaggy'], "remove")
                        Player.Functions.AddMoney("cash", amount)
                        break
                    else
                        TriggerClientEvent('QBCore:Notify', src, "Du har ingen kokain", 'error')
                        break
                    end
                end
            else
                TriggerClientEvent('QBCore:Notify', src, "Du har ingen kokain", 'error')
                break
            end
        end
    end
end)

RegisterServerEvent('norskpixel-coke:server:getleaf')
AddEventHandler('norskpixel-coke:server:getleaf', function()
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.AddItem("cocaleaf", 10)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['cocaleaf'], "add")
end)

RegisterServerEvent('norskpixel-coke:server:getcoke')
AddEventHandler('norskpixel-coke:server:getcoke', function()
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.AddItem("cokebaggy", 1)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['cokebaggy'], "add")
end)

RegisterServerEvent('norskpixel-coke:server:getcrack')
AddEventHandler('norskpixel-coke:server:getcrack', function()
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.AddItem("crack_baggy", 1)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['crack_baggy'], "add")
end)