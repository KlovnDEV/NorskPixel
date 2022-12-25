
local QBCore = exports['norskpixel-core']:GetCoreObject()

RegisterNetEvent('norskpixel-casino:context:casinoChipMenu', function()
    --TriggerEvent('drawtextui:HideUI')
    --TriggerEvent('nh-context:sendMenu', {
        exports['norskpixel-menu']:openMenu({
        {
            header = "Diamond Casino",
            isMenuHeader = true,
        },
        {
            header = "Sælg alle hvide kasinochips", 
            txt = "Nuværende værdi: 1 DKK pr. chip",
            params = {
                event = "norskpixel-casino:client:WhiteSell",
                args = {

                }
            }
        },
        {
            header = "Sælg alle røde kasinochips", 
            txt = "Nuværende værdi: 5 DKK pr. chip",
            params = {
                event = "norskpixel-casino:client:RedSell",
                args = {

                }
            }
        },
        {
            header = "Sælg alle blå kasinochips", 
            txt = "Nuværende værdi: 10 DKK pr. chip",
            params = {
                event = "norskpixel-casino:client:BlueSell", 
                args = {

                }
            }
        },
        {
            header = "Sælg alle sorte kasinochips", 
            txt = "Nuværende værdi: 50 DKK pr. chip",
            params = {
                event = "norskpixel-casino:client:BlackSell",
                args = {

                }
            }
        },
        {
            header = "Sælg alle guld kasinochips", 
            txt = "Nuværende værdi: 100 DKK pr. chip",
            params = {
                event = "norskpixel-casino:client:GoldSell",
                args = {

                }
            }
        },
    })
end)