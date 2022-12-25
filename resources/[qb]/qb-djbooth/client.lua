-- Variables

local QBCore = exports['norskpixel-core']:GetCoreObject()
local currentZone = nil
local PlayerData = {}

-- Handlers

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then return end
	PlayerData = QBCore.Functions.GetPlayerData()
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

-- Static Header

local musicHeader = {
    {
        header = 'Afspil noget musik!',
        params = {
            event = 'norskpixel-djbooth:client:playMusic'
        }
    }
}

-- Main Menu

function createMusicMenu()
    musicMenu = {
        {
            isHeader = true,
            header = '💿 | DJ Pult'
        },
        {
            header = '🎶 | Afspil en sang',
            txt = 'Indtast et YouTube link',
            params = {
                event = 'norskpixel-djbooth:client:musicMenu',
                args = {
                    zoneName = currentZone
                }
            }
        },
        {
            header = '⏸️ | Pause musikken',
            txt = 'Pause den nuværende sang',
            params = {
                isServer = true,
                event = 'norskpixel-djbooth:server:pauseMusic',
                args = {
                    zoneName = currentZone
                }
            }
        },
        {
            header = '▶️ | Genoptag sangen',
            txt = 'Genoptag sangen som blev sidst blev afspillet',
            params = {
                isServer = true,
                event = 'norskpixel-djbooth:server:resumeMusic',
                args = {
                    zoneName = currentZone
                }
            }
        },
        {
            header = '🔈 | Ændre lydstyrke',
            txt = 'Ændre lydstyrken på sangen/musikken',
            params = {
                event = 'norskpixel-djbooth:client:changeVolume',
                args = {
                    zoneName = currentZone
                }
            }
        },
        {
            header = '❌ | Sluk musikken',
            txt = 'Stop/sluk musikken, og afspil en anden',
            params = {
                isServer = true,
                event = 'norskpixel-djbooth:server:stopMusic',
                args = {
                    zoneName = currentZone
                }
            }
        }
    }
end

-- DJ Booths

local vanilla = BoxZone:Create(Config.Locations['vanilla'].coords, 1, 1, {
    name="vanilla",
    heading=0
})

vanilla:onPlayerInOut(function(isPointInside)
    if isPointInside and PlayerData.job.name == Config.Locations['vanilla'].job then
        currentZone = 'vanilla'
        exports['norskpixel-menu']:showHeader(musicHeader)
    else
        currentZone = nil
        exports['norskpixel-menu']:closeMenu()
    end
end)

-- Events

RegisterNetEvent('norskpixel-djbooth:client:playMusic', function()
    createMusicMenu()
    exports['norskpixel-menu']:openMenu(musicMenu)
end)

RegisterNetEvent('norskpixel-djbooth:client:musicMenu', function()
    local dialog = exports['norskpixel-input']:ShowInput({
        header = 'Sangvalg',
        submitText = "Indsend",
        inputs = {
            {
                type = 'text',
                isRequired = true,
                name = 'song',
                text = 'YouTube URL'
            }
        }
    })
    if dialog then
        if not dialog.song then return end
        TriggerServerEvent('norskpixel-djbooth:server:playMusic', dialog.song, currentZone)
    end
end)

RegisterNetEvent('norskpixel-djbooth:client:changeVolume', function()
    local dialog = exports['norskpixel-input']:ShowInput({
        header = 'Musik lydstryke',
        submitText = "Indsend",
        inputs = {
            {
                type = 'text', -- number doesn't accept decimals??
                isRequired = true,
                name = 'volume',
                text = 'Min: 0.01 - Maks: 1'
            }
        }
    })
    if dialog then
        if not dialog.volume then return end
        TriggerServerEvent('norskpixel-djbooth:server:changeVolume', dialog.volume, currentZone)
    end
end)