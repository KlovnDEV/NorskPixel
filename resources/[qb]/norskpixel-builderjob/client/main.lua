
local QBCore = exports['norskpixel-core']:GetCoreObject()

local isLoggedIn = false
local PlayerData = {}

local BuilderData = {
    ShowDetails = false,
    CurrentTask = nil,
}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerData = QBCore.Functions.GetPlayerData()
    GetCurrentProject()
end)

Citizen.CreateThread(function()
    Wait(1000)
    isLoggedIn = true
    PlayerData = QBCore.Functions.GetPlayerData()
    GetCurrentProject()
end)

function GetCurrentProject()
    QBCore.Functions.TriggerCallback('norskpixel-builderjob:server:GetCurrentProject', function(BuilderConfig)
        Config = BuilderConfig
    end)
end

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

function GetCompletedTasks()
    local retval = {
        completed = 0,
        total = #Config.Projects[Config.CurrentProject].ProjectLocations["tasks"]
    }
    for k, v in pairs(Config.Projects[Config.CurrentProject].ProjectLocations["tasks"]) do
        if v.completed then
            retval.completed = retval.completed + 1
        end
    end
    return retval
end

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local inRange = false
        local OffsetZ = 0.2
        
        if Config.CurrentProject ~= 0 then
            local data = Config.Projects[Config.CurrentProject].ProjectLocations["main"]
            local MainDistance = #(pos - vector3(data.coords.x, data.coords.y, data.coords.z))

            if MainDistance < 10 then
                inRange = true
                DrawMarker(2, data.coords.x, data.coords.y, data.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 55, 155, 255, 255, 0, 0, 0, 1, 0, 0, 0)

                if MainDistance < 2 then
                    local TaskData = GetCompletedTasks()
                    if TaskData ~= nil then
                        if not BuilderData.ShowDetails then
                            DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, '[E] Vis detaljer')
                            DrawText3Ds(data.coords.x, data.coords.y, data.coords.z + 0.2, 'Udførelser: '..TaskData.completed..' / '..TaskData.total)
                        else
                            DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, '[E] Fjern detaljer')
                            for k, v in pairs(Config.Projects[Config.CurrentProject].ProjectLocations["tasks"]) do
                                if v.completed then
                                    DrawText3Ds(data.coords.x, data.coords.y, data.coords.z + OffsetZ, v.label..': Færdigt')
                                else
                                    DrawText3Ds(data.coords.x, data.coords.y, data.coords.z + OffsetZ, v.label..': Ikke færdigt')
                                end
                                OffsetZ = OffsetZ + 0.2
                            end
                        end

                        if TaskData.completed == TaskData.total then
                            DrawText3Ds(data.coords.x, data.coords.y, data.coords.z - 0.2, '[G] Afslut projektet')
                            if IsControlJustPressed(0, 47) then
                                TriggerServerEvent('norskpixel-builderjob:server:FinishProject')
                            end
                        end

                        if IsControlJustPressed(0, 38) then
                            BuilderData.ShowDetails = not BuilderData.ShowDetails
                        end
                    end
                end
            end

            for k, v in pairs(Config.Projects[Config.CurrentProject].ProjectLocations["tasks"]) do
                if not v.completed or not v.IsBusy then
                    local TaskDistance = #(pos - vector3(v.coords.x, v.coords.y, v.coords.z))
                    if TaskDistance < 10 then
                        inRange = true
                        DrawMarker(2, v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 55, 155, 255, 255, 0, 0, 0, 1, 0, 0, 0)
                        if TaskDistance < 1.5 then
                            DrawText3Ds(v.coords.x, v.coords.y, v.coords.z + 0.25, '[E] Udfør opgave')
                            if IsControlJustPressed(0, 38) then
                                BuilderData.CurrentTask = k
                                DoTask()
                            end
                        end
                    end
                end
            end
        end

        if not inRange then
            Citizen.Wait(1000)
        end

        Citizen.Wait(3)
    end
end)

function DoTask()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local TaskData = Config.Projects[Config.CurrentProject].ProjectLocations["tasks"][BuilderData.CurrentTask]
    local CountDown = 5
    TriggerServerEvent('norskpixel-builderjob:server:SetTaskState', BuilderData.CurrentTask, true, false)

    if TaskData.type == "hammer" then
        while CountDown ~= 0 do
            CountDown = CountDown - 1
            Citizen.Wait(1000)
        end
        TriggerServerEvent('norskpixel-builderjob:server:SetTaskState', BuilderData.CurrentTask, true, true)
    end
end

RegisterNetEvent('norskpixel-builderjob:client:SetTaskState')
AddEventHandler('norskpixel-builderjob:client:SetTaskState', function(Task, IsBusy, IsCompleted)
    Config.Projects[Config.CurrentProject].ProjectLocations["tasks"][Task].IsBusy = IsBusy
    Config.Projects[Config.CurrentProject].ProjectLocations["tasks"][Task].completed = IsCompleted
end)

RegisterNetEvent('norskpixel-builderjob:client:FinishProject')
AddEventHandler('norskpixel-builderjob:client:FinishProject', function(BuilderConfig)
    Config = BuilderConfig
end)
