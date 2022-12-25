
local QBCore = exports['norskpixel-core']:GetCoreObject()

local alarmTriggered = false
local certificateAmount = 43

RegisterServerEvent('norskpixel-ifruitstore:server:LoadLocationList')
AddEventHandler('norskpixel-ifruitstore:server:LoadLocationList', function()
    local src = source 
    TriggerClientEvent("norskpixel-ifruitstore:server:LoadLocationList", src, Config.Locations)
end)

RegisterServerEvent('norskpixel-ifruitstore:server:setSpotState')
AddEventHandler('norskpixel-ifruitstore:server:setSpotState', function(stateType, state, spot)
    if stateType == "isBusy" then
        Config.Locations["takeables"][spot].isBusy = state
    elseif stateType == "isDone" then
        Config.Locations["takeables"][spot].isDone = state
    end
    TriggerClientEvent('norskpixel-ifruitstore:client:setSpotState', -1, stateType, state, spot)
end)

RegisterServerEvent('norskpixel-ifruitstore:server:SetThermiteStatus')
AddEventHandler('norskpixel-ifruitstore:server:SetThermiteStatus', function(stateType, state)
    if stateType == "isBusy" then
        Config.Locations["thermite"].isBusy = state
    elseif stateType == "isDone" then
        Config.Locations["thermite"].isDone = state
    end
    TriggerClientEvent('norskpixel-ifruitstore:client:SetThermiteStatus', -1, stateType, state)
end)

RegisterServerEvent('norskpixel-ifruitstore:server:SafeReward')
AddEventHandler('norskpixel-ifruitstore:server:SafeReward', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney('cash', math.random(1500, 2000), "robbery-ifruit")
    Player.Functions.AddItem("certificate", certificateAmount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["certificate"], "add")
    Citizen.Wait(500)
    local luck = math.random(1, 100)
    if luck <= 10 then
        Player.Functions.AddItem("goldbar", math.random(1, 2))
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["goldbar"], "add")
    end
end)

RegisterServerEvent('norskpixel-ifruitstore:server:SetSafeStatus')
AddEventHandler('norskpixel-ifruitstore:server:SetSafeStatus', function(stateType, state)
    if stateType == "isBusy" then
        Config.Locations["safe"].isBusy = state
    elseif stateType == "isDone" then
        Config.Locations["safe"].isDone = state
    end
    TriggerClientEvent('norskpixel-ifruitstore:client:SetSafeStatus', -1, stateType, state)
end)

RegisterServerEvent('norskpixel-ifruitstore:server:itemReward')
AddEventHandler('norskpixel-ifruitstore:server:itemReward', function(spot)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Config.Locations["takeables"][spot].reward

    if Player.Functions.AddItem(item.name, item.amount) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], 'add')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Du har for meget i dine lommer ..', 'error')
    end    
end)

RegisterServerEvent('norskpixel-ifruitstore:server:PoliceAlertMessage')
AddEventHandler('norskpixel-ifruitstore:server:PoliceAlertMessage', function(msg, coords, blip)
    local src = source
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police") then  
                TriggerClientEvent("norskpixel-ifruitstore:client:PoliceAlertMessage", v, msg, coords, blip) 
            end
        end
    end
end)

RegisterServerEvent('norskpixel-ifruitstore:server:callCops')
AddEventHandler('norskpixel-ifruitstore:server:callCops', function(streetLabel, coords)
    local place = "iFruit butik"
    local msg = "Alarmen blev aktiveret hos "..place.. " ved " ..streetLabel

    TriggerClientEvent("norskpixel-ifruitstore:client:robberyCall", -1, streetLabel, coords)

end)