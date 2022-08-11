ESX = exports['es_extended']:getSharedObject()

local aduty = false
local noclip = false
local vanish = false
local vanishCommands = {'v', 'vanish'}

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        aduty = false
        toggleGodmode()
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

                toggleGodmode()
            elseif aduty then
                getClothing(group)

                toggleGodmode()
            end
        else
            ESX.ShowNotification('['..GetCurrentResourceName()..'] No ~r~Permission ~s~for Aduty')
        end
    end)
end

function toggleGodmode()
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
        ESX.ShowNotification('['..GetCurrentResourceName()..'] Noclip ~g~Enabled')
    elseif not noclip then
        ESX.ShowNotification('['..GetCurrentResourceName()..'] Noclip ~r~Disabled')
    end

    while noclip do
        Wait(1)

        local playerPed = PlayerPedId()
        local isInVehicle = IsPedInAnyVehicle(playerPed, 0)
        local entity = nil
        local x, y, z = nil
        
        if not isInVehicle then
            entity = playerPed
            x, y, z = table.unpack(GetEntityCoords(playerPed, 2))
        else
            entity = GetVehiclePedIsIn(playerPed, 0)
            x, y, z = table.unpack(GetEntityCoords(playerPed, 1))
        end
        
        local dx, dy, dz = GetCamDirection()
        
        SetEntityVelocity(entity, 0.0001, 0.0001, 0.0001)
        
        if IsDisabledControlJustPressed(0, 21) then -- faster when shift pressed
            oldSpeed = currentNoclipSpeed
            currentNoclipSpeed = currentNoclipSpeed * Config.noclipShiftSpeed
        end
        if IsDisabledControlJustReleased(0, 21) then
            currentNoclipSpeed = oldSpeed
        end

        if currentNoclipSpeed == nil then 
            currentNoclipSpeed = Config.noclipSpeed
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
    vanish = not vanish
    local playerPed = PlayerPedId() 

    if vanish then
        SetEntityVisible(playerPed, false, false)
    elseif not vanish then
        SetEntityVisible(playerPed, true, false)
    end
end