
KeyMinigameCallback = {}

RegisterNetEvent('norskpixel-keyminigame:show')
AddEventHandler('norskpixel-keyminigame:show', function()
	SendNUIMessage({
        action = "ShowMinigame"
    })
	SetNuiFocus(true, false)
end)

RegisterNetEvent('norskpixel-keyminigame:start')
AddEventHandler('norskpixel-keyminigame:start', function(callback)
    KeyMinigameCallback = callback
	SendNUIMessage({
        action = "StartMinigame"
    })
end)

RegisterNUICallback('callback', function(data, cb)
	KeyMinigameCallback(data.faults)
    SendNUIMessage({
        action = "HideMinigame"
    })
	SetNuiFocus(false, false)
    cb('ok')
end)
