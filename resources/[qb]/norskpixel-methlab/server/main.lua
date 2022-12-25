
local QBCore = exports['norskpixel-core']:GetCoreObject()

Citizen.CreateThread(function()
    Config.CurrentLab = math.random(1, #Config.Locations["laboratories"])
    --print('Lab entry has been set to location: '..Config.CurrentLab)
end)

QBCore.Functions.CreateCallback('norskpixel-methlab:server:GetData', function(source, cb)
    local LabData = {
        CurrentLab = Config.CurrentLab
    }
    cb(LabData)
end)

QBCore.Functions.CreateUseableItem("labkey", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    local LabKey = item.info.lab ~= nil and item.info.lab or 1

    TriggerClientEvent('norskpixel-methlab:client:UseLabKey', source, LabKey)
end)

function GenerateRandomLab()
    local Lab = math.random(1, #Config.Locations["laboratories"])
    return Lab
end

RegisterServerEvent('norskpixel-methlab:server:loadIngredients')
AddEventHandler('norskpixel-methlab:server:loadIngredients', function()
	local Player = QBCore.Functions.GetPlayer(tonumber(source))
    local hydrochloricacid = Player.Functions.GetItemByName('hydrochloricacid')
    local ephedrine = Player.Functions.GetItemByName('ephedrine')
    local acetone = Player.Functions.GetItemByName('acetone')
	if Player.PlayerData.items ~= nil then 
        if (hydrochloricacid ~= nil and ephedrine ~= nil and acetone ~= nil) then
            if hydrochloricacid.amount >= 0 and ephedrine.amount >= 0 and acetone.amount >= 0 then 
                Player.Functions.RemoveItem("hydrochloricacid", Config.HydrochloricAcid, false)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['hydrochloricacid'], "remove")
                Player.Functions.RemoveItem("ephedrine", Config.Ephedrine, false)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['ephedrine'], "remove")
                Player.Functions.RemoveItem("acetone", Config.Acetone, false)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['acetone'], "remove")
            end
        end
	end
end)

RegisterServerEvent('norskpixel-methlab:server:CheckIngredients')
AddEventHandler('norskpixel-methlab:server:CheckIngredients', function()
	local Player = QBCore.Functions.GetPlayer(tonumber(source))
    local hydrochloricacid = Player.Functions.GetItemByName('hydrochloricacid')
    local ephedrine = Player.Functions.GetItemByName('ephedrine')
    local acetone = Player.Functions.GetItemByName('acetone')
	if Player.PlayerData.items ~= nil then 
        if (hydrochloricacid ~= nil and ephedrine ~= nil and acetone ~= nil) then 
            if hydrochloricacid.amount >= Config.HydrochloricAcid and ephedrine.amount >= Config.Ephedrine and acetone.amount >= Config.Acetone then 
                TriggerClientEvent("norskpixel-methlab:client:loadIngredients", source)
            else
                TriggerClientEvent('QBCore:Notify', source, "Du har ikke de korrekte varer", 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', source, "Du har ikke de korrekte varer", 'error')
        end
	else
		TriggerClientEvent('QBCore:Notify', source, "Du har intet...", "error")
	end
end)

RegisterServerEvent('norskpixel-methlab:server:breakMeth')
AddEventHandler('norskpixel-methlab:server:breakMeth', function()
	local Player = QBCore.Functions.GetPlayer(tonumber(source))
    local meth = Player.Functions.GetItemByName('methtray')
    local puremethtray = Player.Functions.GetItemByName('puremethtray')

	if Player.PlayerData.items ~= nil then 
        if (meth ~= nil or puremethtray ~= nil) then 
                TriggerClientEvent("norskpixel-methlab:client:breakMeth", source)
        else
            TriggerClientEvent('QBCore:Notify', source, "Du har ikke de korrekte varer", 'error')   
        end
	else
		TriggerClientEvent('QBCore:Notify', source, "Du har intet...", "error")
	end
end)

RegisterServerEvent('norskpixel-methlab:server:getmethtray')
AddEventHandler('norskpixel-methlab:server:getmethtray', function(amount)
    local Player = QBCore.Functions.GetPlayer(tonumber(source))
    
    local methtray = Player.Functions.GetItemByName('methtray')
    local puremethtray = Player.Functions.GetItemByName('puremethtray')

    if puremethtray ~= nil then 
        if puremethtray.amount >= 1 then 
            Player.Functions.AddItem("puremeth", amount, false)
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['puremeth'], "add")

            Player.Functions.RemoveItem("puremethtray", 1, false)
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['puremethtray'], "remove")
        end
    elseif methtray ~= nil then 
        if methtray.amount >= 1 then 
            Player.Functions.AddItem("meth", amount, false)
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['meth'], "add")

            Player.Functions.RemoveItem("methtray", 1, false)
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['methtray'], "remove")
        end
    else
        TriggerClientEvent('QBCore:Notify', source, "Du har ikke de korrekte varer", 'error')   
    end
end)

RegisterServerEvent('norskpixel-methlab:server:receivemethtray')
AddEventHandler('norskpixel-methlab:server:receivemethtray', function()
    local chance = math.random(1, 100)
    print(chance)
    if chance >= 90 then
        local Player = QBCore.Functions.GetPlayer(tonumber(source))
        Player.Functions.AddItem("puremethtray", 3, false)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['puremethtray'], "add")
    else
        local Player = QBCore.Functions.GetPlayer(tonumber(source))
        Player.Functions.AddItem("methtray", 3, false)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['methtray'], "add")
    end
end)