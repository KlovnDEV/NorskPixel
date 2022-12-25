
local QBCore = exports['norskpixel-core']:GetCoreObject()

QBCore.Functions.CreateCallback('norskpixel-builderjob:server:GetCurrentProject', function(source, cb)
    local CurProject = nil
    for k, v in pairs(Config.Projects) do
        if v.IsActive then
            CurProject = k
            break
        end
    end

    if CurProject == nil then
        CurProject = math.random(1, #Config.Projects)
        Config.Projects[CurProject].IsActive = true
        Config.CurrentProject = CurProject
    end
    cb(Config)
end)

RegisterServerEvent('norskpixel-builderjob:server:SetTaskState')
AddEventHandler('norskpixel-builderjob:server:SetTaskState', function(Task, IsBusy, IsCompleted)
    Config.Projects[Config.CurrentProject].ProjectLocations["tasks"][Task].IsBusy = IsBusy
    Config.Projects[Config.CurrentProject].ProjectLocations["tasks"][Task].completed = IsCompleted
    TriggerClientEvent('norskpixel-builderjob:client:SetTaskState', -1, Task, IsBusy, IsCompleted)
end)

RegisterServerEvent('norskpixel-builderjob:server:FinishProject')
AddEventHandler('norskpixel-builderjob:server:FinishProject', function()
    Config.Projects[Config.CurrentProject].IsActive = false
    for k, v in pairs(Config.Projects[Config.CurrentProject].ProjectLocations["tasks"]) do
        v.completed = false
        v.IsBusy = false
    end
    local NewProject = math.random(1, #Config.Projects)
    Config.CurrentProject = NewProject
    Config.Projects[NewProject].IsActive = true
    TriggerClientEvent('norskpixel-builderjob:client:FinishProject', -1, Config)
end)