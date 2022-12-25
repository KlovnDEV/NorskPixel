-- This file primarily is for implicit handling for restarts of `norskpixel-core`
-- Whenever norskpixel-core is restarted, the shared object table containing
-- function refs becomes invalid. To solve this, we must reassign our
-- table again with the update function ref pointers at resource start

-- Any changes to the resource name, means this handler won't work anymore

QBCore = exports['norskpixel-core']:GetCoreObject()

AddEventHandler('onResourceStart', function(resName)
    -- We only want to reassign funcref table,
    -- when norskpixel-core resource status changes.
    if resName ~= 'norskpixel-core' then return end
    -- Lets refresh local table with updated func refs
    QBCore = exports['norskpixel-core']:GetCoreObject()
end)