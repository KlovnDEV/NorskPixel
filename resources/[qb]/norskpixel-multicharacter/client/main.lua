
local charPed = nil
local QBCore = exports['norskpixel-core']:GetCoreObject()

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if NetworkIsSessionStarted() then
			TriggerEvent('norskpixel-multicharacter:client:chooseChar')
			return
		end
	end
end)

Config = {
    PedCoords = vector4(-813.97, 176.22, 76.74, -7.5),
    HiddenCoords = vector4(-812.23, 182.54, 76.74, 156.5),
    CamCoords = vector4(-813.46, 178.95, 76.85, 174.5)
}

--- CODE

local choosingCharacter = false
local cam = nil

function openCharMenu(bool)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = "ui",
        toggle = bool,
    })
    choosingCharacter = bool
    skyCam(bool)
end

RegisterNUICallback('closeUI', function()
    openCharMenu(false)
end)

RegisterNUICallback('disconnectButton', function()
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    TriggerServerEvent('norskpixel-multicharacter:server:disconnect')
end)

RegisterNUICallback('selectCharacter', function(data)
    local cData = data.cData
    DoScreenFadeOut(10)
    TriggerServerEvent('norskpixel-multicharacter:server:loadUserData', cData)
    openCharMenu(false)
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
end)

RegisterNetEvent('norskpixel-multicharacter:client:closeNUI')
AddEventHandler('norskpixel-multicharacter:client:closeNUI', function()
    SetNuiFocus(false, false)
end)

local Countdown = 1

RegisterNetEvent('norskpixel-multicharacter:client:chooseChar')
AddEventHandler('norskpixel-multicharacter:client:chooseChar', function()
    SetNuiFocus(false, false)
    DoScreenFadeOut(10)
    Citizen.Wait(1000)
    local interior = GetInteriorAtCoords(-814.89, 181.95, 76.85 - 18.9)
    LoadInterior(interior)
    while not IsInteriorReady(interior) do
        Citizen.Wait(1000)
    end
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityCoords(PlayerPedId(), Config.HiddenCoords.x, Config.HiddenCoords.y, Config.HiddenCoords.z)
    Citizen.Wait(1500)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    openCharMenu(true)
end)

function selectChar()
    openCharMenu(true)
end

RegisterNUICallback('cDataPed', function(data)
    local cData = data.cData  
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)

    if cData ~= nil then
        QBCore.Functions.TriggerCallback('norskpixel-multicharacter:server:getSkin', function(model, data)
            model = model ~= nil and tonumber(model) or false
            if model ~= nil then
                Citizen.CreateThread(function()
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Citizen.Wait(0)
                    end
                    charPed = CreatePed(2, model, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 0.98, Config.PedCoords.w, false, true)
                    SetPedComponentVariation(charPed, 0, 0, 0, 2)
                    FreezeEntityPosition(charPed, false)
                    SetEntityInvincible(charPed, true)
                    PlaceObjectOnGroundProperly(charPed)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                    data = json.decode(data)
                    TriggerEvent('norskpixel-clothing:client:loadPlayerClothing', data, charPed)
                end)
            else
                Citizen.CreateThread(function()
                    local randommodels = {
                        "mp_m_freemode_01",
                        "mp_f_freemode_01",
                    }
                    local model = GetHashKey(randommodels[math.random(1, #randommodels)])
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Citizen.Wait(0)
                    end
                    charPed = CreatePed(2, model, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 0.98, Config.PedCoords.w, false, true)
                    SetPedComponentVariation(charPed, 0, 0, 0, 2)
                    FreezeEntityPosition(charPed, false)
                    SetEntityInvincible(charPed, true)
                    PlaceObjectOnGroundProperly(charPed)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                end)
            end
        end, cData.citizenid)
    else
        Citizen.CreateThread(function()
            local randommodels = {
                "mp_m_freemode_01",
                "mp_f_freemode_01",
            }
            local model = GetHashKey(randommodels[math.random(1, #randommodels)])
            RequestModel(model)
            while not HasModelLoaded(model) do
                Citizen.Wait(0)
            end
            charPed = CreatePed(2, model, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 0.98, Config.PedCoords.w, false, true)
            SetPedComponentVariation(charPed, 0, 0, 0, 2)
            FreezeEntityPosition(charPed, false)
            SetEntityInvincible(charPed, true)
            PlaceObjectOnGroundProperly(charPed)
            SetBlockingOfNonTemporaryEvents(charPed, true)
        end)
    end
end)

RegisterNUICallback('setupCharacters', function()
    QBCore.Functions.TriggerCallback("norskpixel-multicharacter:server:setupCharacters", function(result)
        SendNUIMessage({
            action = "setupCharacters",
            characters = result
        })
    end)
end)

RegisterNUICallback('removeBlur', function()
    SetTimecycleModifier('default')
end)

RegisterNUICallback('createNewCharacter', function(data)
    local cData = data
    DoScreenFadeOut(150)
    if cData.gender == "Male" then
        cData.gender = 0
    elseif cData.gender == "Female" then
        cData.gender = 1
    end

    TriggerServerEvent('norskpixel-multicharacter:server:createCharacter', cData)
    Citizen.Wait(500)
end)

RegisterNUICallback('removeCharacter', function(data)
    TriggerServerEvent('norskpixel-multicharacter:server:deleteCharacter', data.citizenid)
    TriggerEvent('norskpixel-multicharacter:client:chooseChar')
end)

function skyCam(bool)
    SetRainLevel(0.0)
    TriggerEvent('norskpixel-weathersync:client:DisableSync')
    SetWeatherTypePersist('EXTRASUNNY')
    SetWeatherTypeNow('EXTRASUNNY')
    SetWeatherTypeNowPersist('EXTRASUNNY')
    NetworkOverrideClockTime(12, 0, 0)

    if bool then
        DoScreenFadeIn(1000)
        SetTimecycleModifier('hud_def_blur')
        SetTimecycleModifierStrength(1.0)
        FreezeEntityPosition(PlayerPedId(), false)
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", -813.46, 178.95, 76.85, 0.0 ,0.0, 174.5, 60.00, false, 0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
    else
        SetTimecycleModifier('default')
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)
    end
end
