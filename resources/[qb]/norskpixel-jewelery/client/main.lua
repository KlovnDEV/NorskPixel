
local QBCore = exports['norskpixel-core']:GetCoreObject()

local robberyAlert = false
local isLoggedIn = false
local firstAlarm = false

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        inRange = false

        if QBCore ~= nil then
            if isLoggedIn then
                PlayerData = QBCore.Functions.GetPlayerData()
                for case,_ in pairs(Config.Locations) do
                    -- if PlayerData.job.name ~= "police" then
                        local dist = #(pos - vector3(Config.Locations[case]["coords"]["x"], Config.Locations[case]["coords"]["y"], Config.Locations[case]["coords"]["z"]))
                        local storeDist = #(pos - vector3(Config.JewelleryLocation["coords"]["x"], Config.JewelleryLocation["coords"]["y"], Config.JewelleryLocation["coords"]["z"]))
                        if dist < 30 then
                            inRange = true

                            if dist < 0.6 then
                                if not Config.Locations[case]["isBusy"] and not Config.Locations[case]["isOpened"] then
                                    DrawText3Ds(Config.Locations[case]["coords"]["x"], Config.Locations[case]["coords"]["y"], Config.Locations[case]["coords"]["z"], '[E] Øldelæg glasmontre')
                                    if IsControlJustPressed(0, 38) then
                                        QBCore.Functions.TriggerCallback('norskpixel-jewellery:server:getCops', function(cops)
                                            if cops >= Config.RequiredCops then
                                                if validWeapon() then
                                                    smashVitrine(case)
                                                else
                                                    QBCore.Functions.Notify('Dit våben er ikke stærk nok..', 'error')
                                                end
                                            else
                                                QBCore.Functions.Notify('Ikke nok politi, minimum '.. Config.RequiredCops ..'!', 'error')
                                            end                
                                        end)
                                    end
                                end
                            end

                            if storeDist < 2 then
                                if not firstAlarm then
                                    if validWeapon() then
                                        local data = {displayCode = '112', description = 'Mistænkelig aktivitet', isImportant = 0, recipientList = {'police'}, length = '10000', infoM = 'fa-info-circle', info = 'Vangelico juvel røveri'}
                                        local dispatchData = {dispatchData = data, caller = 'Alarm', coords = vector3(-633.9, -241.7, 38.1)}
                                        TriggerServerEvent('wf-alerts:svNotify', dispatchData)
                                        firstAlarm = true
                                    end
                                end
                            end
                        end
                    -- end
                end
            end
        end

        if not inRange then
            Citizen.Wait(2000)
        end

        Citizen.Wait(3)
    end
end)

function loadParticle()
	if not HasNamedPtfxAssetLoaded("scr_jewelheist") then
    RequestNamedPtfxAsset("scr_jewelheist")
    end
    while not HasNamedPtfxAssetLoaded("scr_jewelheist") do
    Citizen.Wait(0)
    end
    SetPtfxAssetNextCall("scr_jewelheist")
end

function loadAnimDict(dict)  
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(3)
    end
end

function validWeapon()
    local ped = PlayerPedId()
    local pedWeapon = GetSelectedPedWeapon(ped)

    for k, v in pairs(Config.WhitelistedWeapons) do
        if pedWeapon == k then
            return true
        end
    end
    return false
end

local smashing = false

function smashVitrine(k)
    local animDict = "missheist_jewel"
    local animName = "smash_case"
    local ped = PlayerPedId()
    local plyCoords = GetOffsetFromEntityInWorldCoords(ped, 0, 0.6, 0)
    local pedWeapon = GetSelectedPedWeapon(ped)

    if math.random(1, 100) <= 80 and not IsWearingHandshoes() then
        TriggerServerEvent("evidence:server:CreateFingerDrop", plyCoords)
    elseif math.random(1, 100) <= 5 and IsWearingHandshoes() then
        TriggerServerEvent("evidence:server:CreateFingerDrop", plyCoords)
        QBCore.Functions.Notify("Du har efterladt et fingeraftryk", "error")
    end

    smashing = true

    QBCore.Functions.Progressbar("smash_vitrine", "Smadre glasmontre", Config.WhitelistedWeapons[pedWeapon]["timeOut"], false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        TriggerServerEvent('norskpixel-jewellery:server:setVitrineState', "isOpened", true, k)
        TriggerServerEvent('norskpixel-jewellery:server:setVitrineState', "isBusy", false, k)
        TriggerServerEvent('norskpixel-jewellery:server:vitrineReward')
        TriggerServerEvent('norskpixel-jewellery:server:setTimeout')
        local data = {displayCode = '211A', description = 'Røveri', isImportant = 1, recipientList = {'police'}, length = '10000', infoM = 'fa-info-circle', info = 'Vangelico juvel røveri'}
        local dispatchData = {dispatchData = data, caller = 'Alarm', coords = vector3(-633.9, -241.7, 38.1)}
        TriggerServerEvent('wf-alerts:svNotify', dispatchData)
        smashing = false
        TaskPlayAnim(ped, animDict, "exit", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
    end, function() -- Cancel
        TriggerServerEvent('norskpixel-jewellery:server:setVitrineState', "isBusy", false, k)
        smashing = false
        TaskPlayAnim(ped, animDict, "exit", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
    end)
    TriggerServerEvent('norskpixel-jewellery:server:setVitrineState', "isBusy", true, k)

    Citizen.CreateThread(function()
        while smashing do
            loadAnimDict(animDict)
            TaskPlayAnim(ped, animDict, animName, 3.0, 3.0, -1, 2, 0, 0, 0, 0 )
            Citizen.Wait(500)
            TriggerServerEvent("InteractSound_SV:PlayOnSource", "breaking_vitrine_glass", 0.25)
            loadParticle()
            StartParticleFxLoopedAtCoord("scr_jewel_cab_smash", plyCoords.x, plyCoords.y, plyCoords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
            Citizen.Wait(2500)
        end
    end)
end

RegisterNetEvent('norskpixel-jewellery:client:setVitrineState')
AddEventHandler('norskpixel-jewellery:client:setVitrineState', function(stateType, state, k)
    Config.Locations[k][stateType] = state
end)

RegisterNetEvent('norskpixel-jewellery:client:setAlertState')
AddEventHandler('norskpixel-jewellery:client:setAlertState', function(bool)
    robberyAlert = bool
end)

RegisterNetEvent('norskpixel-jewellery:client:PoliceAlertMessage')
AddEventHandler('norskpixel-jewellery:client:PoliceAlertMessage', function(title, coords, blip)
    if blip then
        TriggerEvent('norskpixel-policealerts:client:AddPoliceAlert', {
            timeOut = 5000,
            alertTitle = title,
            details = {
                [1] = {
                    icon = '<i class="fas fa-gem"></i>',
                    detail = "Vangelico Jeweler",
                },
                [2] = {
                    icon = '<i class="fas fa-video"></i>',
                    detail = "31 | 32 | 33 | 34",
                },
                [3] = {
                    icon = '<i class="fas fa-globe-europe"></i>',
                    detail = "Rockford Dr",
                },
            },
            callSign = QBCore.Functions.GetPlayerData().metadata["callsign"],
        })
        PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
        Citizen.Wait(100)
        PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
        Citizen.Wait(100)
        PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
        local transG = 100
        local blip = AddBlipForRadius(coords.x, coords.y, coords.z, 100.0)
        SetBlipSprite(blip, 9)
        SetBlipColour(blip, 1)
        SetBlipAlpha(blip, transG)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("112 - Mistænkelig aktivitet ved Juvel forretningen")
        EndTextCommandSetBlipName(blip)
        while transG ~= 0 do
            Wait(180 * 4)
            transG = transG - 1
            SetBlipAlpha(blip, transG)
            if transG == 0 then
                SetBlipSprite(blip, 2)
                RemoveBlip(blip)
                return
            end
        end
    else
        if not robberyAlert then
            PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
            TriggerEvent('norskpixel-policealerts:client:AddPoliceAlert', {
                timeOut = 5000,
                alertTitle = title,
                details = {
                    [1] = {
                        icon = '<i class="fas fa-gem"></i>',
                        detail = "Vangelico juvel forretning",
                    },
                    [2] = {
                        icon = '<i class="fas fa-video"></i>',
                        detail = "31 | 32 | 33 | 34",
                    },
                    [3] = {
                        icon = '<i class="fas fa-globe-europe"></i>',
                        detail = "Rockford Dr",
                    },
                },
                callSign = QBCore.Functions.GetPlayerData().metadata["callsign"],
            })
            robberyAlert = true
        end
    end
end)

function IsWearingHandshoes()
    local armIndex = GetPedDrawableVariation(PlayerPedId(), 3)
    local model = GetEntityModel(PlayerPedId())
    local retval = true
    if model == GetHashKey("mp_m_freemode_01") then
        if Config.MaleNoHandshoes[armIndex] ~= nil and Config.MaleNoHandshoes[armIndex] then
            retval = false
        end
    else
        if Config.FemaleNoHandshoes[armIndex] ~= nil and Config.FemaleNoHandshoes[armIndex] then
            retval = false
        end
    end
    return retval
end

Citizen.CreateThread(function()
    Dealer = AddBlipForCoord(Config.JewelleryLocation["coords"]["x"], Config.JewelleryLocation["coords"]["y"], Config.JewelleryLocation["coords"]["z"])

    SetBlipSprite (Dealer, 617)
    SetBlipDisplay(Dealer, 4)
    SetBlipScale  (Dealer, 0.7)
    SetBlipAsShortRange(Dealer, true)
    SetBlipColour(Dealer, 3)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Vangelico juvel forretning")
    EndTextCommandSetBlipName(Dealer)
end)
