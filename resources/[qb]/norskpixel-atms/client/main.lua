
local QBCore = exports['norskpixel-core']:GetCoreObject()

-- Functions
function PlayATMAnimation(animation)
    local playerPed = PlayerPedId()
    if animation == 'enter' then
        RequestAnimDict('amb@prop_human_atm@male@enter')
        while not HasAnimDictLoaded('amb@prop_human_atm@male@enter') do
            Citizen.Wait(1)
        end
        if HasAnimDictLoaded('amb@prop_human_atm@male@enter') then 
            TaskPlayAnim(PlayerPedId(), 'amb@prop_human_atm@male@enter', "enter", 1.0,-1.0, 3000, 1, 1, true, true, true)
        end
    end
    if animation == 'exit' then
        RequestAnimDict('amb@prop_human_atm@male@exit')
        while not HasAnimDictLoaded('amb@prop_human_atm@male@exit') do
            Citizen.Wait(1)
        end
        if HasAnimDictLoaded('amb@prop_human_atm@male@exit') then 
            TaskPlayAnim(PlayerPedId(), 'amb@prop_human_atm@male@exit', "exit", 1.0,-1.0, 3000, 1, 1, true, true, true)
        end
    end
end

-- Events
RegisterNetEvent("hidemenu")
AddEventHandler("hidemenu", function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        status = "closeATM"
    })
end)

RegisterNetEvent('norskpixel-atms:client:updateBankInformation', function(banking)
    SendNUIMessage({
        status = "loadBankAccount",
        information = banking
    })
end)

RegisterNetEvent('norskpixel-atms:client:loadATM', function(cards)
    if cards ~= nil and cards[1] ~= nil then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed, true)
        for k, v in pairs(Config.ATMModels) do
            local hash = GetHashKey(v)
            local atm = IsObjectNearPoint(hash, playerCoords.x, playerCoords.y, playerCoords.z, 1.5)
            if atm then
                local obj = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 2.0, hash, false, false, false)
                local atmCoords = GetEntityCoords(obj, false)
                    PlayATMAnimation('enter')
                QBCore.Functions.Progressbar("accessing_atm", "Tilgår hæveautomaten", 1500, false, true, {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = false,
                }, {}, {}, {}, function() -- Done
                    SetNuiFocus(true, true)
                    SendNUIMessage({
                        status = "openATMFrontScreen",
                        cards = cards,
                    })
                end, function()
                    QBCore.Functions.Notify("Fejlede!", "error")
                end)
            end
        end
    else
        QBCore.Functions.Notify("Du har ikke et kreditkort at betale med, besøg venligst en bank for at få bestilt et. Eller vær sikker på at du har et på dig", "error")
    end
end)

RegisterNUICallback("NUIFocusOff", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        status = "closeATM"
    })
    PlayATMAnimation('exit')   
end)

RegisterNUICallback("playATMAnim", function(data, cb)
    local playerPed = PlayerPedId()
    local anim = 'amb@prop_human_atm@male@idle_a'
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Citizen.Wait(1)
    end

    if HasAnimDictLoaded(anim) then 
        TaskPlayAnim(PlayerPedId(), anim, "idle_a", 1.0,-1.0, 3000, 1, 1, true, true, true)
    end
end)

RegisterNUICallback("doATMWithdraw", function(data, cb)
    if data ~= nil then
        TriggerServerEvent('norskpixel-atms:server:doAccountWithdraw', data)
    end
end)

RegisterNUICallback("loadBankingAccount", function(data, cb)
    QBCore.Functions.TriggerCallback('norskpixel-atms:server:loadBankAccount', function(banking)
        if banking ~= false and type(banking) == "table" then
            SendNUIMessage({
                status = "loadBankAccount",
                information = banking
            })
        else
            SetNuiFocus(false, false)
            SendNUIMessage({
                status = "closeATM"
            })
        end
    end, data.cid, data.cardnumber)
end)

RegisterNUICallback("removeCard", function(data, cb)
    QBCore.Functions.TriggerCallback('norskpixel-debitcard:server:deleteCard', function(hasDeleted)
        if hasDeleted then
            SetNuiFocus(false, false)
            SendNUIMessage({
                status = "closeATM"
            })
            QBCore.Functions.Notify('Kortet blev fjernet.', 'success')
        else
            QBCore.Functions.Notify('Mislykkede at fjerne kortet.', 'error')
        end
    end, data)
end)