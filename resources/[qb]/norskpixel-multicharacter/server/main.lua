
local QBCore = exports['norskpixel-core']:GetCoreObject()

RegisterServerEvent('norskpixel-multicharacter:server:disconnect')
AddEventHandler('norskpixel-multicharacter:server:disconnect', function()
    local src = source

    DropPlayer(src, "Du har frakoblet dig serveren")
end)

RegisterServerEvent('norskpixel-multicharacter:server:loadUserData')
AddEventHandler('norskpixel-multicharacter:server:loadUserData', function(cData)
    local src = source
    if QBCore.Player.Login(src, cData.citizenid) then
        print('^2[norskpixel-core]^7 '..GetPlayerName(src)..' (Citizen ID: '..cData.citizenid..') has succesfully loaded!')
        QBCore.Commands.Refresh(src)
        loadHouseData()
		--TriggerEvent('QBCore:Server:OnPlayerLoaded')-
        --TriggerClientEvent('QBCore:Client:OnPlayerLoaded', src)
        
        TriggerClientEvent('apartments:client:setupSpawnUI', src, cData)
        TriggerEvent("norskpixel-log:server:CreateLog", "joinleave", "Loaded", "green", "**".. GetPlayerName(src) .. "** ("..cData.citizenid.." | "..src..") loaded..")
	end
end)

RegisterServerEvent('norskpixel-multicharacter:server:createCharacter')
AddEventHandler('norskpixel-multicharacter:server:createCharacter', function(data)
    local src = source
    local newData = {}
    newData.cid = data.cid
    newData.charinfo = data
    local randbucket = (GetPlayerPed(src) .. math.random(1,999))
    SetPlayerRoutingBucket(src, randbucket)
    --QBCore.Player.CreateCharacter(src, data)
    if QBCore.Player.Login(src, false, newData) then
        print('^2[norskpixel-core]^7 '..GetPlayerName(src)..' has succesfully loaded!')
        QBCore.Commands.Refresh(src)
        loadHouseData()

        TriggerClientEvent("norskpixel-multicharacter:client:closeNUI", src)
        TriggerClientEvent('apartments:client:setupSpawnUI', src, newData)
        GiveStarterItems(src)
	end
end)

function GiveStarterItems(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    for k, v in pairs(QBCore.Shared.StarterItems) do
        local info = {}
        if v.item == "id_card" then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif v.item == "driver_license" then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = "Kørekort klasse B"
        end
        Player.Functions.AddItem(v.item, v.amount, false, info)
    end
end

RegisterServerEvent('norskpixel-multicharacter:server:deleteCharacter')
AddEventHandler('norskpixel-multicharacter:server:deleteCharacter', function(citizenid)
    local src = source
    QBCore.Player.DeleteCharacter(src, citizenid)
end)

QBCore.Functions.CreateCallback("norskpixel-multicharacter:server:GetUserCharacters", function(source, cb)
    local license = QBCore.Functions.GetIdentifier(source, 'license')

    exports.oxmysql:fetch('SELECT * FROM players WHERE license = ?', {license}, function(result)
        cb(result)
    end)
end)

QBCore.Functions.CreateCallback("norskpixel-multicharacter:server:GetServerLogs", function(source, cb)
    exports.oxmysql:fetch('SELECT * FROM server_logs', {}, function(result)
        cb(result)
    end)
end)

QBCore.Functions.CreateCallback("norskpixel-multicharacter:server:setupCharacters", function(source, cb)
    local license = QBCore.Functions.GetIdentifier(source, 'license')
    local plyChars = {}
    
    exports.oxmysql:fetch('SELECT * FROM players WHERE license = ?', {license}, function(result)
        for i = 1, (#result), 1 do
            result[i].charinfo = json.decode(result[i].charinfo)
            result[i].money = json.decode(result[i].money)
            result[i].job = json.decode(result[i].job)

            table.insert(plyChars, result[i])
        end
        cb(plyChars)
    end)
end)

QBCore.Commands.Add("logout", "Logout af karaktere (Kun Admin)", {}, false, function(source, args)
    QBCore.Player.Logout(source)
    TriggerClientEvent('norskpixel-multicharacter:client:chooseChar', source)
end, "admin")

QBCore.Commands.Add("closeNUI", "Luk Multi NUI", {}, false, function(source, args)
    TriggerClientEvent('norskpixel-multicharacter:client:closeNUI', source)
end)

QBCore.Functions.CreateCallback("norskpixel-multicharacter:server:getSkin", function(source, cb, cid)
    local src = source

    local result = exports.oxmysql:executeSync('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', {cid, 1})
    if result[1] ~= nil then
        cb(result[1].model, result[1].skin)
    else
        cb(nil)
    end
end)

function loadHouseData()
    local HouseGarages = {}
    local Houses = {}
    local result = exports.oxmysql:executeSync('SELECT * FROM houselocations', {})
    if result[1] ~= nil then
        for k, v in pairs(result) do
            local owned = false
            if tonumber(v.owned) == 1 then
                owned = true
            end
            local garage = v.garage ~= nil and json.decode(v.garage) or {}
            Houses[v.name] = {
                coords = json.decode(v.coords),
                owned = v.owned,
                price = v.price,
                locked = true,
                adress = v.label, 
                tier = v.tier,
                garage = garage,
                decorations = {},
            }
            HouseGarages[v.name] = {
                label = v.label,
                takeVehicle = garage,
            }
        end
    end
    TriggerClientEvent("norskpixel-garages:client:houseGarageConfig", -1, HouseGarages)
    TriggerClientEvent("norskpixel-houses:client:setHouseConfig", -1, Houses)
end
