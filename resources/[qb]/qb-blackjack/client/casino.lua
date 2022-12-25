
local QBCore = exports['norskpixel-core']:GetCoreObject()

local isLoggedIn = false 

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
end)

RegisterNetEvent('norskpixel-casino:client:RedSell')
AddEventHandler('norskpixel-casino:client:RedSell', function()
    TriggerServerEvent('norskpixel-casino:server:RedSell')
end)

RegisterNetEvent('norskpixel-casino:client:WhiteSell')
AddEventHandler('norskpixel-casino:client:WhiteSell', function()
    TriggerServerEvent('norskpixel-casino:server:WhiteSell')
end)

RegisterNetEvent('norskpixel-casino:client:BlueSell')
AddEventHandler('norskpixel-casino:client:BlueSell', function()
    TriggerServerEvent('norskpixel-casino:server:BlueSell')
end)

RegisterNetEvent('norskpixel-casino:client:BlackSell')
AddEventHandler('norskpixel-casino:client:BlackSell', function()
    TriggerServerEvent('norskpixel-casino:server:BlackSell')
end)

RegisterNetEvent('norskpixel-casino:client:GoldSell')
AddEventHandler('norskpixel-casino:client:GoldSell', function()
    TriggerServerEvent('norskpixel-casino:server:GoldSell')
end)

Citizen.CreateThread(function()
    local alreadyEnteredZone = false
    local text = nil
    while true do
        wait = 5
        local ped = PlayerPedId()
        local inZone = false
        local dist = #(GetEntityCoords(ped)-vector3(948.237, 34.287, 71.839))
        if dist <= 3.0 then
            wait = 5
            inZone  = true
            text = '<b>Diamond Casino</b></p>Shop'

        else
            wait = 2000
        end

        if inZone and not alreadyEnteredZone then
            alreadyEnteredZone = true
            TriggerEvent('drawtextui:ShowUI', 'show', text)
        end

        if not inZone and alreadyEnteredZone then
            alreadyEnteredZone = false
            TriggerEvent('drawtextui:HideUI')
        end
        Citizen.Wait(wait)
    end
end)