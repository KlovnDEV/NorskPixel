local xSound = exports.xsound

RegisterNetEvent('norskpixel-djbooth:server:playMusic', function(song, zoneName)
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local boothCoords = Config.Locations[zoneName].coords
    local dist = #(coords - boothCoords)
    if dist > 3 then return end
    xSound:PlayUrlPos(-1, zoneName, song, Config.DefaultVolume, coords)
    xSound:Distance(-1, zoneName, Config.Locations[zoneName].radius)
    Config.Locations[zoneName].playing = true
    TriggerClientEvent('norskpixel-djbooth:client:playMusic', src)
end)

RegisterNetEvent('norskpixel-djbooth:server:stopMusic', function(data)
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local boothCoords = Config.Locations[data.zoneName].coords
    local dist = #(coords - boothCoords)
    if dist > 3 then return end
    if Config.Locations[data.zoneName].playing then
        Config.Locations[data.zoneName].playing = false
        xSound:Destroy(-1, data.zoneName)
    end
    TriggerClientEvent('norskpixel-djbooth:client:playMusic', src)
end)

RegisterNetEvent('norskpixel-djbooth:server:pauseMusic', function(data)
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local boothCoords = Config.Locations[data.zoneName].coords
    local dist = #(coords - boothCoords)
    if dist > 3 then return end
    if Config.Locations[data.zoneName].playing then
        Config.Locations[data.zoneName].playing = false
        xSound:Pause(-1, data.zoneName)
    end
    TriggerClientEvent('norskpixel-djbooth:client:playMusic', src)
end)

RegisterNetEvent('norskpixel-djbooth:server:resumeMusic', function(data)
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local boothCoords = Config.Locations[data.zoneName].coords
    local dist = #(coords - boothCoords)
    if dist > 3 then return end
    if not Config.Locations[data.zoneName].playing then
        Config.Locations[data.zoneName].playing = true
        xSound:Resume(-1, data.zoneName)
    end
    TriggerClientEvent('norskpixel-djbooth:client:playMusic', src)
end)

RegisterNetEvent('norskpixel-djbooth:server:changeVolume', function(volume, zoneName)
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local boothCoords = Config.Locations[zoneName].coords
    local dist = #(coords - boothCoords)
    if dist > 3 then return end
    if not tonumber(volume) then return end
    if Config.Locations[zoneName].playing then
        xSound:setVolume(-1, zoneName, volume)
    end
    TriggerClientEvent('norskpixel-djbooth:client:playMusic', src)
end)