local ESX = exports['es_extended']:getSharedObject()

local aduty = false
local noclip = false
local vanish = false
local currentPlayerBlips = {}
local vanishCommands = {'v', 'vanish'}

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if aduty then
            toggleAduty()
        end

        if vanish then
            toggleVanish()
        end
    end
end)

for k, v in pairs(vanishCommands) do
    RegisterCommand(v, function(source, args, Rawcommand)
        toggleVanish()
    end)
end

RegisterKeyMapping('aduty', 'Toggle aduty', 'keyboard', '')
RegisterCommand('aduty', function(source, args, Rawcommand)
    toggleAduty()

    if vanish then
        toggleVanish()
    end

    if noclip then
        toggleNoclip()
    end
end)

RegisterKeyMapping('toggleNoclip', 'Toggle noclip', 'keyboard', 'F11')
RegisterCommand('toggleNoclip', function(source, args, Rawcommand)
    if aduty then
        toggleNoclip()
    end
end)

function toggleAduty()
    ESX.TriggerServerCallback('mx_aduty:getValues', function(group, playerLicense)
        if Config.AdutyClothing[group] then
            aduty = not aduty
            
            if aduty then
                ESX.ShowNotification('['..GetCurrentResourceName()..'] Aduty ~g~Enabled')
            elseif not aduty then
                ESX.ShowNotification('['..GetCurrentResourceName()..'] Aduty ~r~Disabled')
            end

            if not aduty then
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                    TriggerEvent('skinchanger:loadSkin', skin)
                end)

                toggleNameDisplay()
                toggleGodmode()
                refreshBlips()
            elseif aduty then
                getClothing(group)

                
                refreshBlips()
                toggleNameDisplay()
                toggleGodmode()
            end
        else
            ESX.ShowNotification('['..GetCurrentResourceName()..'] No ~r~Permission ~s~for Aduty')
        end
    end)
end

function toggleGodmode()
    CreateThread(function()
        local playerPed = PlayerPedId()
        local playerId = PlayerId()

        for k, v in pairs(Config.GodmodeOptions) do
            while aduty do
                Wait(5)
                if aduty then
                    SetPedCanRagdoll(playerPed, not v['noRagdoll'])
                    
                    if v['clearPedBlood'] then
                        ClearPedBloodDamage(playerPed)
                        ResetPedVisibleDamage(playerPed)
                    end

                    if v['infiniteStamina'] then
                        RestorePlayerStamina(playerId, 1.0)
                    end

                    if v['godmode'] then
                        SetPlayerInvincible(playerId, true)
                        SetEntityInvincible(playerPed, true)
                        SetEntityCanBeDamaged(playerPed, false)
                    end
                elseif not aduty then
                    print(true)
                    SetPedCanRagdoll(playerPed, v['noRagdoll'])

                    if v['godmode'] then
                        SetPlayerInvincible(playerId, false)
                        SetEntityInvincible(playerPed, false)
                        SetEntityCanBeDamaged(playerPed, true)
                    end   
                end
            end
        end
    end)
end

function toggleNameDisplay()
    CreateThread(function()
        local playerPed = PlayerPedId()
        local playerId = PlayerId()

        while aduty do
            Wait(5)
            local players = GetActivePlayers()

            for i = 1, #players do
                local playerPed = PlayerPedId()
                local playersPed = GetPlayerPed(players[i])

                local headCoord = GetPedBoneCoords(playersPed, 0x796E, 0, 0, 0)
                local playerCoord = GetEntityCoords(playerPed)
                local playerIds = GetPlayerServerId(players[i])
                local playernames = GetPlayerName(players[i])
                local playerHealth = math.floor(GetEntityHealth(playersPed) / GetEntityMaxHealth(playersPed) * 100)
                local playerArmor = GetPedArmour(playersPed)

                local dist = #(headCoord.xyz - playerCoord.xyz)
                
                -- if playersPed ~= playerPed then
                    if dist < Config.DistanceESP then
                        local playerName = '['..playerIds..'] '..playernames..'\nHealth: ~r~'..playerHealth

                        if playerArmor > 0 then
                            playerName = '['..playerIds..'] '..playernames..'\nHealth: ~r~'..playerHealth..' ~s~Armor: ~b~'..playerArmor
                        end

                        Draw3DText(headCoord.x, headCoord.y, headCoord.z + 0.4, playerName, 255, 255, 255, 0.25)
                    
                        Draw3DText(headCoord.x, headCoord.y, headCoord.z + 0.2, ".", 255, 255, 255, 0.5)
                    end
                -- end
            end
        end
    end)
end

function getClothing(group)
    local playerPed = PlayerPedId()
    
    TriggerEvent('skinchanger:getSkin', function(skin)
        if skin.sex == 0 then
            TriggerEvent("skinchanger:loadClothes", skin, Config.AdutyClothing[group].male)
        else
            TriggerEvent("skinchanger:loadClothes", skin, Config.AdutyClothing[group].female)
        end
    end)
end

local currentcurrentNoclipSpeed = Config.noclipSpeed
local oldSpeed = nil

local function GetCamDirection()
    local playerPed = PlayerPedId()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(playerPed)
    local pitch = GetGameplayCamRelativePitch()
    
    local x = -math.sin(heading * math.pi / 180.0)
    local y = math.cos(heading * math.pi / 180.0)
    local z = math.sin(pitch * math.pi / 180.0)
    
    local len = math.sqrt(x * x + y * y + z * z)
    if len ~= 0 then
        x = x / len
        y = y / len
        z = z / len
    end
    
    return x, y, z
end

function toggleNoclip()
    noclip = not noclip

    if noclip then
        CLNotify("Noclip on")
    else
        CLNotify("Noclip off")
    end

    while noclip do
        Wait(1)

        local playerPed = PlayerPedId()
        local isInVehicle = IsPedInAnyVehicle(playerPed, false)
        local entity = nil
        local x, y, z

        if not isInVehicle then
            entity = playerPed
            x, y, z = table.unpack(GetEntityCoords(playerPed, false))
        else
            entity = GetVehiclePedIsIn(playerPed, false)
            x, y, z = table.unpack(GetEntityCoords(entity, false))
        end

        local dx, dy, dz = GetCamDirection()

        SetEntityVelocity(entity, 0.0001, 0.0001, 0.0001)

        local currentNoclipSpeed = Config.noclipSpeed  -- Standardgeschwindigkeit

        if IsDisabledControlJustPressed(0, 21) then -- Schneller wenn Shift gedrückt
            currentNoclipSpeed = currentNoclipSpeed * Config.noclipShiftSpeed
        end

        if IsDisabledControlPressed(0, 32) then
            x = x + currentNoclipSpeed * dx
            y = y + currentNoclipSpeed * dy
            z = z + currentNoclipSpeed * dz
        end

        if IsDisabledControlPressed(0, 269) then
            x = x - currentNoclipSpeed * dx
            y = y - currentNoclipSpeed * dy
            z = z - currentNoclipSpeed * dz
        end

        if IsDisabledControlPressed(0, 22) then
            z = z + currentNoclipSpeed
        end

        if IsDisabledControlPressed(0, 36) then
            z = z - currentNoclipSpeed
        end

        SetEntityCoordsNoOffset(entity, x, y, z, true, true, true)
    end
end

function toggleVanish()
    if aduty then
        vanish = not vanish
        local playerPed = PlayerPedId() 

        if vanish then
            SetEntityVisible(playerPed, false, false)
        elseif not vanish then
            SetEntityVisible(playerPed, true, false)
        end
    else
        SetEntityVisible(playerPed, true, false)
    end
end

-- RegisterCommand('testcoords', function(source, args, Rawcommand)
--     enableBlips()
-- end)

function refreshBlips()
    CreateThread(function()
        while aduty do
            enableBlips()
            
            Wait(5000)
        end

        if not aduty then
            for i = 1, #currentPlayerBlips do
                RemoveBlip(currentPlayerBlips[i])
        
                currentPlayerBlips[i] = nil
            end
        end
    end)
end

function enableBlips()

    for i = 1, #currentPlayerBlips do
        RemoveBlip(currentPlayerBlips[i])

        currentPlayerBlips[i] = nil
    end

    ESX.TriggerServerCallback('mx_aduty:getPlayerCoords', function(playerCoords) 
        for i = 1, #playerCoords do
            local user = playerCoords[i]

            blip = AddBlipForCoord(user.coords.x, user.coords.y, user.coords.z)

            SetBlipSprite(blip, 1)
            SetBlipColour(blip, 0)
            SetBlipAsShortRange(blip, true)
            SetBlipDisplay(blip, 4)
            ShowHeadingIndicatorOnBlip(blip, true)
            SetBlipRotation(blip, math.ceil(user.coords.heading))
            SetBlipCategory(blip, 7)
            ShowNumberOnBlip(blip, user.playerId)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(user.name)
            EndTextCommandSetBlipName(blip)

            table.insert(currentPlayerBlips, blip)
        end
    end)
end

function Draw3DText(x, y, z, msg, r, g, b, size)
    SetDrawOrigin(x, y, z, 0)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(0, size or 0.2)
    SetTextColour(r, g, b, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(msg)
    DrawText(0, 0)
    ClearDrawOrigin()
end
