
local QBCore = exports['norskpixel-core']:GetCoreObject()

local keyPressed = false
local inKeyBinding = false
local availableKeys = {
    {289, "F2"},
    {170, "F3"},
    {166, "F5"},
    {167, "F6"},
    {168, "F7"},
    {56, "F9"},
    {57, "F10"},
}

function openBindingMenu()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local keyMeta = PlayerData.metadata["commandbinds"]
    SendNUIMessage({
        action = "openBinding",
        keyData = keyMeta
    })
    inKeyBinding = true
    SetNuiFocus(true, true)
    SetCursorLocation(0.5, 0.5)
end

function closeBindingMenu()
    inKeyBinding = false
    SetNuiFocus(false, false)
end

RegisterNUICallback('close', closeBindingMenu)

RegisterNetEvent('norskpixel-commandbinding:client:openUI')
AddEventHandler('norskpixel-commandbinding:client:openUI', function()
    openBindingMenu()
end)

for k, v in pairs(availableKeys) do
    RegisterCommand(v[1], function()
        if LocalPlayer.state.isLoggedIn and not keyPressed and GetLastInputMethod(0) then
            local keyMeta = QBCore.Functions.GetPlayerData().metadata["commandbinds"]
            local args = {}
            if next(keyMeta) ~= nil then
                if keyMeta[v[2]]["command"] ~= "" then
                    if keyMeta[v[2]]["argument"] ~= "" then args = {[1] = keyMeta[v[2]]["argument"]} else args = {[1] = nil} end
                    TriggerServerEvent('QBCore:CallCommand', keyMeta[v[2]]["command"], args)
                    keyPressed = true
                    Citizen.Wait(1000)
                    keyPressed = false
                else
                    QBCore.Functions.Notify('Der er stadig ikke bundet nogen commands ['..v[2]..'] , /binds til at bind en command', 'primary', 4000)
                end
            else
                QBCore.Functions.Notify('Du har ikke bundet nogle, /binds til at bind en command', 'primary', 4000)
            end
        end
    end, false)
    RegisterKeyMapping(v[1], 'BIND '..k, 'keyboard', v[2])
end

RegisterNUICallback('save', function(data)
    local keyData = {
        ["F2"]  = {["command"] = data.keyData["F2"][1],  ["argument"] = data.keyData["F2"][2]},
        ["F3"]  = {["command"] = data.keyData["F3"][1],  ["argument"] = data.keyData["F3"][2]},
        ["F5"]  = {["command"] = data.keyData["F5"][1],  ["argument"] = data.keyData["F5"][2]},
        ["F6"]  = {["command"] = data.keyData["F6"][1],  ["argument"] = data.keyData["F6"][2]},
        ["F7"]  = {["command"] = data.keyData["F7"][1],  ["argument"] = data.keyData["F7"][2]},
        ["F9"]  = {["command"] = data.keyData["F9"][1],  ["argument"] = data.keyData["F9"][2]},
        ["F10"] = {["command"] = data.keyData["F10"][1], ["argument"] = data.keyData["F10"][2]},
    }

    QBCore.Functions.Notify('Binds blev gemt!', 'success')

    TriggerServerEvent('norskpixel-commandbinding:server:setKeyMeta', keyData)
end)