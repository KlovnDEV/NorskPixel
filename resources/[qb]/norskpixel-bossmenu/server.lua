
local QBCore = exports['norskpixel-core']:GetCoreObject()

local Accounts = {}

CreateThread(function()
    Wait(500)
    local result = json.decode(LoadResourceFile(GetCurrentResourceName(), "./accounts.json"))
    if not result then
        return
    end
    for k,v in pairs(result) do
        local k = tostring(k)
        local v = tonumber(v)
        if k and v then
            Accounts[k] = v
        end
    end
end)

QBCore.Functions.CreateCallback('norskpixel-bossmenu:server:GetAccount', function(source, cb, jobname)
    local result = GetAccount(jobname)
    cb(result)
end)

-- Export
function GetAccount(account)
    return Accounts[account] or 0
end

-- Withdraw Money
RegisterServerEvent("norskpixel-bossmenu:server:withdrawMoney")
AddEventHandler("norskpixel-bossmenu:server:withdrawMoney", function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local job = Player.PlayerData.job.name
    if not Accounts[job] then
        Accounts[job] = 0
    end
    if Accounts[job] >= amount and amount > 0 then
        Accounts[job] = Accounts[job] - amount
        Player.Functions.AddMoney("cash", amount)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Ikke nok penge', 'error')
        return
    end
    SaveResourceFile(GetCurrentResourceName(), "./accounts.json", json.encode(Accounts), -1)
    TriggerEvent('norskpixel-log:server:CreateLog', 'bossmenu', 'Udbetal penge', "Der blev udbetalt " .. amount .. ' DKK (' .. job .. ')', src)
end)

-- Deposit Money
RegisterServerEvent("norskpixel-bossmenu:server:depositMoney")
AddEventHandler("norskpixel-bossmenu:server:depositMoney", function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local job = Player.PlayerData.job.name
    if not Accounts[job] then
        Accounts[job] = 0
    end
    if Player.Functions.RemoveMoney("cash", amount) then
        Accounts[job] = Accounts[job] + amount
    else
        TriggerClientEvent('QBCore:Notify', src, 'Ikke nok penge', "error")
        return
    end
    SaveResourceFile(GetCurrentResourceName(), "./accounts.json", json.encode(Accounts), -1)
    TriggerEvent('norskpixel-log:server:CreateLog', 'bossmenu', 'Indsæt penge', "Der blev indsat " .. amount .. ' DKK (' .. job .. ')', src)
end)

RegisterServerEvent("norskpixel-bossmenu:server:addAccountMoney")
AddEventHandler("norskpixel-bossmenu:server:addAccountMoney", function(account, amount)
    if not Accounts[account] then
        Accounts[account] = 0
    end
    Accounts[account] = Accounts[account] + amount
    TriggerClientEvent('norskpixel-bossmenu:client:refreshSociety', -1, account, Accounts[account])
    SaveResourceFile(GetCurrentResourceName(), "./accounts.json", json.encode(Accounts), -1)
end)

RegisterServerEvent("norskpixel-bossmenu:server:removeAccountMoney")
AddEventHandler("norskpixel-bossmenu:server:removeAccountMoney", function(account, amount)
    if not Accounts[account] then
        Accounts[account] = 0
    end
    if Accounts[account] >= amount then
        Accounts[account] = Accounts[account] - amount
    end
    TriggerClientEvent('norskpixel-bossmenu:client:refreshSociety', -1, account, Accounts[account])
    SaveResourceFile(GetCurrentResourceName(), "./accounts.json", json.encode(Accounts), -1)
end)

-- Get Employees
QBCore.Functions.CreateCallback('norskpixel-bossmenu:server:GetEmployees', function(source, cb, jobname)
    local src = source
    local employees = {}
    if not Accounts[jobname] then
        Accounts[jobname] = 0
    end
    local players = exports.oxmysql:executeSync("SELECT * FROM `players` WHERE `job` LIKE '%".. jobname .."%'")
    if players[1] ~= nil then
        for key, value in pairs(players) do
            local isOnline = QBCore.Functions.GetPlayerByCitizenId(value.citizenid)

            if isOnline then
                employees[#employees+1] = {
                    empSource = isOnline.PlayerData.citizenid,
                    grade = isOnline.PlayerData.job.grade,
                    level = isOnline.PlayerData.job.grade.level,
                    isboss = isOnline.PlayerData.job.isboss,
                    name = isOnline.PlayerData.charinfo.firstname .. ' ' .. isOnline.PlayerData.charinfo.lastname
                }
            else
                employees[#employees+1] = {
                    empSource = value.citizenid,
                    grade =  json.decode(value.job).grade,
                    level = json.decode(value.job).grade.level,
                    isboss = json.decode(value.job).isboss,
                    name = json.decode(value.charinfo).firstname .. ' ' .. json.decode(value.charinfo).lastname
                }
            end
        end
    end
    cb(employees)
end)

-- Grade Change
RegisterServerEvent('norskpixel-bossmenu:server:updateGrade')
AddEventHandler('norskpixel-bossmenu:server:updateGrade', function(target, grade)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Employee = QBCore.Functions.GetPlayerByCitizenId(target)
    if grade == nil then
        TriggerClientEvent('QBCore:Notify', src, {text="Boss Menu", caption="Ugyldig grad. Kun cifre, 0 er det laveste."}, "error", 6000)
        return
    end
    if Player.PlayerData.job.grade.level >= grade and grade <= Player.PlayerData.job.grade.level then
        if Employee then
            if Employee.Functions.SetJob(Player.PlayerData.job.name, grade) then
                TriggerEvent('norskpixel-log:server:CreateLog', 'bossmenu', 'Job grad blev ændret', 'lightgreen', Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. ' changed grade to ' .. grade .. ' for ' .. Employee.PlayerData.charinfo.firstname .. ' ' .. Employee.PlayerData.charinfo.lastname .. ' (' .. Player.PlayerData.job.name .. ')', false)
                TriggerClientEvent('QBCore:Notify', src, {text="Boss Menu", caption="Job graden blev ændret!"}, "success")
                TriggerClientEvent('QBCore:Notify', Employee.PlayerData.source, {text="Boss Menu", caption="Tillykke, din nye grad er [" ..grade.."]."}, "success")
            else
                TriggerClientEvent('QBCore:Notify', src, {text="Boss Menu", caption="Grad eksistere ikke"}, "error")
            end
        else
            local playerJob = '%' .. Player.PlayerData.job.name .. '%'
            local result = exports.oxmysql:scalarSync('SELECT job FROM players WHERE citizenid = ? AND job LIKE ?', {target, playerJob})
            if result then
                jobFinal = checkJob(Player.PlayerData.job.name, grade)
                if jobFinal ~= false then
                    TriggerEvent('norskpixel-log:server:CreateLog', 'bossmenu', 'Job grad blev ændret', 'lightgreen', Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. ' changed grade to ' .. jobFinal.grade.name .. ' for '  .. target .. ' (' .. Player.PlayerData.job.name .. ')', false)
                    TriggerClientEvent('QBCore:Notify', src, {text="Boss Menu", caption="Job graden blev ændret!"}, "success")
                    exports.oxmysql:execute('UPDATE players SET job = ? WHERE citizenid = ?', { json.encode(jobFinal), target })
                else
                    TriggerClientEvent('QBCore:Notify', src, {text="Boss Menu", caption="Ugyldig værdi... Brug tal, fra 0 og op efter."}, "error", 6000)
                end
            else
                TriggerClientEvent('QBCore:Notify', src, {text="Boss Menu", caption="Denne person er ikke i bogholderiet"}, "error", 5000)
            end
        end
    else
        TriggerEvent('norskpixel-log:server:CreateLog', 'bossmenu', 'Unfair Job Change', 'lightgreen', Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. ' tried to changed grade to ' .. checkJob(Player.PlayerData.job.name, grade).grade.name .. ' ('.. grade ..') for '  .. target .. ' (' .. Player.PlayerData.job.name .. ') but failed because they are lower rank than the person or are trying to give themselves a promotion.', true)
        TriggerClientEvent('QBCore:Notify', src, {text="Boss Menu",caption="Du har ikke adgang til dette. Dette er blevet reporteret til Staff."}, "error", 8000)
    end
end)

-- Fire Employee
RegisterServerEvent('norskpixel-bossmenu:server:fireEmployee')
AddEventHandler('norskpixel-bossmenu:server:fireEmployee', function(target)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Employee = QBCore.Functions.GetPlayerByCitizenId(target)
    if Employee then
        if Player.PlayerData.job.grade.level >= Employee.PlayerData.job.grade.level then
            if Employee.Functions.SetJob("unemployed", '0') then
                TriggerEvent('norskpixel-log:server:CreateLog', 'bossmenu', 'Job Fire', 'red', Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. ' blev fyret ' .. Employee.PlayerData.charinfo.firstname .. ' ' .. Employee.PlayerData.charinfo.lastname .. ' (' .. Player.PlayerData.job.name .. ')', false)
                TriggerClientEvent('QBCore:Notify', src, {text="Boss Menu",caption="Du er blevet afskediget fra dit job. Du vil modtage dine dokumenter " .. Player.PlayerData.job.label .. " og JobCenteret."}, "error", 5000)
                TriggerClientEvent('QBCore:Notify', Employee.PlayerData.source , {text="Boss Menu", caption="Du blev fyret. Søg venligst et nyt job i retsbygningen (Rådhuset) og afhent dine ejendele."}, "error", 10000)
            else
                TriggerClientEvent('QBCore:Notify', src, {text="Boss Menu", caption="Send en mail med video med alle detaljer vedrørende denne fejl."}, "error")
            end
        else
            TriggerEvent('norskpixel-log:server:CreateLog', 'bossmenu', 'Unfair Firing', 'red', Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. ' forsøgte at fyre ('.. target .. ') hos (' .. Player.PlayerData.job.name .. ') men fejlede fordi personen har en grade under.', true)
            TriggerClientEvent('QBCore:Notify', src, {text="Boss Menu",caption="Du har ikke tilladelse til at gøre dette. Dette er blevet rapporteret til " .. Player.PlayerData.job.label .. " og til byrådet."}, "error", 15000)
        end
    else
        local playerJob = '%' .. Player.PlayerData.job.name .. '%'
        local result = exports.oxmysql:scalarSync('SELECT job FROM players WHERE citizenid = ? AND job LIKE ?', {target, playerJob})
        if result then
            jobFinal = checkJob('unemployed', 0)
            if jobFinal ~= false then
                exports.oxmysql:execute('UPDATE players SET job = ? WHERE citizenid = ?', { json.encode(jobFinal), target })
                TriggerEvent('norskpixel-log:server:CreateLog', 'bossmenu', 'Fired Employee', 'red', Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. ' fired ('.. target .. ') at (' .. Player.PlayerData.job.name .. ')', false)
                TriggerClientEvent('QBCore:Notify', src, {text="Boss Menu",caption="Du er blevet afskediget fra dit job. Du vil modtage dine papire til " .. Player.PlayerData.job.label .. " og JobCenteret."}, "error", 5000)
            else
                TriggerClientEvent('QBCore:Notify', src, {text="Boss Menu", caption="Noget gik galt. Har du prøvet at slå det fra og til igen?"}, "error")
            end
        else
            TriggerClientEvent('QBCore:Notify', src, {text="Boss Menu", caption="Denne person er ikke i bogholderiet."}, "error", 4000)
        end
    end
end)

-- Recruit Player
RegisterServerEvent('norskpixel-bossmenu:server:giveJob')
AddEventHandler('norskpixel-bossmenu:server:giveJob', function(recruit)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(recruit)
    if Player.PlayerData.job.isboss == true then
        if Target and Target.Functions.SetJob(Player.PlayerData.job.name, 0) then
            TriggerClientEvent('QBCore:Notify', src, "Du har ansat " .. (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) .. " til " .. Player.PlayerData.job.label .. "", "success")
            TriggerClientEvent('QBCore:Notify', Target.PlayerData.source , "Du blev ansat hos " .. Player.PlayerData.job.label .. "", "success")
            TriggerEvent('norskpixel-log:server:CreateLog', 'bossmenu', 'Recruit', "Ansat blev " .. (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) .. ' (' .. Player.PlayerData.job.name .. ')', src)
        end
    end
end)

-- Functions
function checkJob(jobName, grade)
    job = {}
    grade = tostring(grade) or '0'
    if QBCore.Shared.Jobs[jobName] then
        job.name = jobName
        job.label = QBCore.Shared.Jobs[jobName].label
        job.onduty = QBCore.Shared.Jobs[jobName].defaultDuty
            if QBCore.Shared.Jobs[jobName].grades[grade] then
                local jobgrade = QBCore.Shared.Jobs[jobName].grades[grade]
                job.grade = {}
                job.grade.name = jobgrade.name
                job.grade.level = tonumber(grade)
                job.payment = jobgrade.payment or 30
                job.isboss = jobgrade.isboss or false
            else
                job.grade = {}
                job.grade.name = 'Invalid Grade'
                job.grade.level = 0
                job.payment = 30
                job.isboss = false
            end
        return job
    end
    return false
end