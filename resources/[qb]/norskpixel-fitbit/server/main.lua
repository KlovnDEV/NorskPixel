
local QBCore = exports['norskpixel-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem("fitbit", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    TriggerClientEvent('norskpixel-fitbit:use', source)
end)

RegisterServerEvent('norskpixel-fitbit:server:setValue')
AddEventHandler('norskpixel-fitbit:server:setValue', function(type, value)
    local src = source
    local ply = QBCore.Functions.GetPlayer(src)
    local fitbitData = {}

    if type == "thirst" then
        local currentMeta = ply.PlayerData.metadata["fitbit"]
        fitbitData = {
            thirst = value,
            food = currentMeta.food
        }
    elseif type == "food" then
        local currentMeta = ply.PlayerData.metadata["fitbit"]
        fitbitData = {
            thirst = currentMeta.thirst,
            food = value
        }
    end

    ply.Functions.SetMetaData('fitbit', fitbitData)
end)

QBCore.Functions.CreateCallback('norskpixel-fitbit:server:HasFitbit', function(source, cb)
    local Ply = QBCore.Functions.GetPlayer(source)
    local Fitbit = Ply.Functions.GetItemByName("fitbit")

    if Fitbit ~= nil then
        cb(true)
    else
        cb(false)
    end
end)