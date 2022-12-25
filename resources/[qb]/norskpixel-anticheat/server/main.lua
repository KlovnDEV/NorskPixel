
local QBCore = exports['norskpixel-core']:GetCoreObject()

-- Get permissions --

QBCore.Functions.CreateCallback('norskpixel-anticheat:server:GetPermissions', function(source, cb)
    local group = QBCore.Functions.GetPermission(source)
    cb(group)
end)

-- Execute ban --

RegisterNetEvent('norskpixel-anticheat:server:banPlayer', function(reason)
    local src = source
    TriggerEvent("norskpixel-log:server:CreateLog", "anticheat", "Anti-Cheat", "white", GetPlayerName(src).." has been banned for "..reason, false)
    exports.oxmysql:insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(src),
        QBCore.Functions.GetIdentifier(src, 'license'),
        QBCore.Functions.GetIdentifier(src, 'discord'),
        QBCore.Functions.GetIdentifier(src, 'ip'),
        reason,
        2145913200,
        'Anti-Cheat'
    })
    DropPlayer(src, "You have been banned for cheating. Check our Discord for more information: " .. QBCore.Config.Server.discord)
end)

-- Fake events --
function NonRegisteredEventCalled(CalledEvent, source)
    TriggerClientEvent("norskpixel-anticheat:client:NonRegisteredEventCalled", source, "Cheating", CalledEvent)
end

for x, v in pairs(Config.BlacklistedEvents) do
    RegisterServerEvent(v)
    AddEventHandler(v, function(source)
        NonRegisteredEventCalled(v, source)
    end)
end

-- RegisterServerEvent('banking:withdraw')
-- AddEventHandler('banking:withdraw', function(source)
--     NonRegisteredEventCalled('bank:withdraw', source)
-- end)

QBCore.Functions.CreateCallback('norskpixel-anticheat:server:HasWeaponInInventory', function(source, cb, WeaponInfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerInventory = Player.PlayerData.items
    local retval = false

    for k, v in pairs(PlayerInventory) do
        if v.name == WeaponInfo["name"] then
            retval = true
        end
    end
    cb(retval)
end)