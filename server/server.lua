ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback('mx_aduty:getValues', function(source, cb)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerGroup = xPlayer.getGroup()

    cb(playerGroup)
end)

ESX.RegisterServerCallback('mx_aduty:getPlayerCoords', function(source, cb)
    local source = source
    local xPlayers = ESX.GetExtendedPlayers()
    local coords = {}

    for _, xPlayer in pairs(xPlayers) do 
        if xPlayer.source ~= source then
            coords[#coords + 1] = {coords = xPlayer.coords, playerId = xPlayer.source, name = GetPlayerName(xPlayer.source)}
        end
    end

    cb(coords)
end)