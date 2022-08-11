ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback('mx_aduty:getValues', function(source, cb)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()
    
    cb(playerGroup)
end)