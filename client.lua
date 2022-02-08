local bodycamActive = false
local cameraHandle = nil
local videoNumber = math.random(10000000,99999999)
local bwvAllowed = false

local toggleOnDraw = true -- If true will toggle bodycam on when player draws their taser.

RegisterCommand("bwv", function(source, args, rawCommand)
    bwvAllowed = not bwvAllowed
    
    if bwvAllowed then
        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "bodyOn", 0.3)
        ShowNotification("Your bodycam is now ~g~activated~s~.")
    else
        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "bodyOff", 0.3)
        ShowNotification("Your bodycam is now ~r~deactivated~s~.")
    end
end)

RegisterKeyMapping('bwv', 'Toggle Bodycam', 'keyboard', '')

RegisterCommand("bwview", function(source, args, rawCommand)
    if not IsPedInAnyVehicle(GetPlayerPed(PlayerId()), false) and bwvAllowed then
        if bodycamActive then
            Disablebody()
        else
            Enablebody()
        end
    end
end)

RegisterKeyMapping('bwview', 'Toggle Bodycam View', 'keyboard', '')

RegisterNetEvent("oBodycam:bodycamOn")

AddEventHandler("oBodycam:bodycamOn", function()
    if not bwvAllowed then
        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "bodyOn", 0.3)
        ShowNotification("Your bodycam is now ~g~activated~s~.")
		bwvAllowed = true
	end
end)

Citizen.CreateThread(function()
    while true do
        if bwvAllowed then
            TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "bodyOn", 0.3)
            ShowNotification("Your bodycam is still ~r~recording~s~.")
        end

        Citizen.Wait(120000)
    end
end)

Citizen.CreateThread(function()
    while true do
        if bodycamActive then
            if bodycamActive and IsPedInAnyVehicle(GetPlayerPed(PlayerId()), false) then
                Disablebody()
                bodycamActive = false
            end

            if not IsPedInAnyVehicle(GetPlayerPed(PlayerId()), false) and bodycamActive then
                Updatebodycam()
            end

        end
        Citizen.Wait(1000)
    end
end)

local lastWeapon = GetHashKey('WEAPON_UNARMED');
local oldWeapon = GetHashKey('WEAPON_UNARMED');

Citizen.CreateThread( function()
	while true do
        if toggleOnDraw then
            local PlayerPed = PlayerPedId();
            local PlayerWeapon = GetSelectedPedWeapon(PlayerPed)

            if DoesEntityExist( PlayerPed ) and not IsEntityDead( PlayerPed ) and not IsPedInAnyVehicle(PlayerPed, true) then
                if lastWeapon ~= PlayerWeapon then
                    oldWeapon = lastWeapon
                    lastWeapon = PlayerWeapon

                    if lastWeapon == GetHashKey("WEAPON_STUNGUN") then
                        TriggerEvent("oBodycam:bodycamOn")
                    end
                end
            end
        end

        if bodycamActive then
            SetFollowPedCamViewMode(4)
        end

        Citizen.Wait(0)
    end
end)

function Enablebody()
    SetTimecycleModifier("scanline_cam_cheap")
    SetTimecycleModifierStrength(1.5)
    SendNUIMessage({
        type = "enablebody"
    })
    bodycamActive = true
end

function Disablebody()
    ClearTimecycleModifier("scanline_cam_cheap")
    SetFollowPedCamViewMode(0)
    SendNUIMessage({
        type = "disablebody"
    })
    bodycamActive = false
end

function Updatebodycam()
    local gameTime = GetGameTimer()
    local year, month, day, hour, minute, second = GetLocalTime() 
    
    SendNUIMessage({
        type = "updatebody",
        info = {
            gameTime = gameTime,
            clockTime = {year = year, month = month, day = day, hour = hour, minute = minute, second = second},
            videoNumber = videoNumber
        }
    })
end

function ShowNotification(string)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(string)
    DrawNotification(true, false)
end