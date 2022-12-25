
local QBCore = exports['norskpixel-core']:GetCoreObject()

local timeOut = false
local alarmTriggered = false

RegisterServerEvent('norskpixel-jewellery:server:setVitrineState')
AddEventHandler('norskpixel-jewellery:server:setVitrineState', function(stateType, state, k)
    Config.Locations[k][stateType] = state
    TriggerClientEvent('norskpixel-jewellery:client:setVitrineState', -1, stateType, state, k)
end)

RegisterServerEvent('norskpixel-jewellery:server:vitrineReward')
AddEventHandler('norskpixel-jewellery:server:vitrineReward', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local otherchance = math.random(1, 4)
    local odd = math.random(1, 4)

    if otherchance == odd then
        local item = math.random(1, #Config.VitrineRewards)
        local amount = math.random(Config.VitrineRewards[item]["amount"]["min"], Config.VitrineRewards[item]["amount"]["max"])
        if Player.Functions.AddItem(Config.VitrineRewards[item]["item"], amount) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.VitrineRewards[item]["item"]], 'add')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Du har for meget i dine lommer', 'error')
        end
    else
        local amount = math.random(2, 4)
        if Player.Functions.AddItem("10kgoldchain", amount) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["10kgoldchain"], 'add')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Du har for meget i dine lommer..', 'error')
        end
    end
end)

RegisterServerEvent('norskpixel-jewellery:server:setTimeout')
AddEventHandler('norskpixel-jewellery:server:setTimeout', function()
    if not timeOut then
        timeOut = true
        TriggerEvent('norskpixel-scoreboard:server:SetActivityBusy', "jewellery", true)
        Citizen.CreateThread(function()
            Citizen.Wait(Config.Timeout)

            for k, v in pairs(Config.Locations) do
                Config.Locations[k]["isOpened"] = false
                TriggerClientEvent('norskpixel-jewellery:client:setVitrineState', -1, 'isOpened', false, k)
                TriggerClientEvent('norskpixel-jewellery:client:setAlertState', -1, false)
                TriggerEvent('norskpixel-scoreboard:server:SetActivityBusy', "jewellery", false)
            end
            timeOut = false
            alarmTriggered = false
        end)
    end
end)

RegisterServerEvent('norskpixel-jewellery:server:PoliceAlertMessage')
AddEventHandler('norskpixel-jewellery:server:PoliceAlertMessage', function(title, coords, blip)
    local src = source
    local alertData = {
        title = title,
        coords = {x = coords.x, y = coords.y, z = coords.z},
        description = "Muligt røveri igang hos Vangelico juvel forretning<br>Ledige kamera: 31, 32, 33, 34",
    }

    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                if blip then
                    if not alarmTriggered then
                        TriggerClientEvent("norskpixel-phone:client:addPoliceAlert", v, alertData)
                        TriggerClientEvent("norskpixel-jewellery:client:PoliceAlertMessage", v, title, coords, blip)
                        alarmTriggered = true
                    end
                else
                    TriggerClientEvent("norskpixel-phone:client:addPoliceAlert", v, alertData)
                    TriggerClientEvent("norskpixel-jewellery:client:PoliceAlertMessage", v, title, coords, blip)
                end
            end
        end
    end
end)

QBCore.Functions.CreateCallback('norskpixel-jewellery:server:getCops', function(source, cb)
	local amount = 0
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                amount = amount + 1
            end
        end
	end
	cb(amount)
end)
