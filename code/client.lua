ESX = nil
CreateThread(function()
    while ESX == nil do
        TriggerEvent("esx:getSharedObject", function(obj)
            ESX = obj
        end)
        Wait(500)
    end
end)

RegisterCommand('Lockcar', function()
    doLockSystemToggleLocks()
end)

RegisterKeyMapping('Lockcar', 'Lockcar', 'keyboard', 'U')

local cooldownTime = Config.cooldown
local lastLockTime = 0
local isCooldownActive = false

local function startCooldown()
    isCooldownActive = true
    CreateThread(function()
        Wait(cooldownTime)
        isCooldownActive = false
    end)
end

local function drawVehicleOutline(vehicle, color)
    if not Config.EnableOutline then return end 

    local endTime = GetGameTimer() + Config.OutlineTime
    SetEntityDrawOutline(vehicle, true)
    SetEntityDrawOutlineColor(color.r, color.g, color.b, color.a)
    SetEntityDrawOutlineShader(1)

    CreateThread(function()
        while GetGameTimer() < endTime do
            SetEntityDrawOutline(vehicle, true)
            Wait(50)
        end
        SetEntityDrawOutline(vehicle, false)
    end)
end

local function drawVehicleMarker(vehicle, color)
    if not Config.EnableMarker then return end 

    local endTime = GetGameTimer() + Config.OutlineTime
    CreateThread(function()
        while GetGameTimer() < endTime do
            local coords = GetEntityCoords(vehicle)
            local min, max = GetModelDimensions(GetEntityModel(vehicle))
            local markerHeight = max.z + 1.0
            local vehicleClass = GetVehicleClass(vehicle)
            local markerType = (vehicleClass == 8) and 37 or 36
            DrawMarker(markerType, coords.x, coords.y, coords.z + markerHeight, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, color.r, color.g, color.b, color.a, false, true, 2, false, nil, nil, false)
            if Config.Slow then
                Wait(50)
            else
                Wait(0)
            end
        end
    end)
end

function doLockSystemToggleLocks()
    if isCooldownActive then
        exports["mythic_notify"]:SendAlert("inform", "กรุณารอสักครู่ก่อนที่จะล็อกรถอีกครั้ง")
        return
    end

    local dict = "anim@mp_player_intmenu@key_fob@"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(7)
    end
    local coords = GetEntityCoords(GetPlayerPed(-1))
    local closestVehicle, closestDistance = ESX.Game.GetClosestVehicle(coords)

    if closestDistance >= Config.LockDistance then
        exports["mythic_notify"]:SendAlert("inform", "ไม่มีรถอยู่ไกล้ๆ")
    else
        local nearby_plate = ESX.Math.Trim(GetVehicleNumberPlateText(closestVehicle))
        ESX.TriggerServerCallback("Carkey:isVehicleOwner", function(owner)
            if owner then
                local lock = GetVehicleDoorLockStatus(closestVehicle)
                local vehicleLabel = GetDisplayNameFromVehicleModel(GetEntityModel(closestVehicle))
                vehicleLabel = GetLabelText(vehicleLabel)

                if lock == 1 or lock == 0 then
                    SetVehicleDoorsLocked(closestVehicle, 2)
                    PlayVehicleDoorCloseSound(closestVehicle, 1)
                    exports["mythic_notify"]:SendAlert("error", "ล็อครถเรียบร้อย", 4 * 1000)
                    SendNUIMessage({ type = "lock" })
                    drawVehicleOutline(closestVehicle, Config.LockColor)
                    drawVehicleMarker(closestVehicle, Config.LockColor)
                    lastLockTime = GetGameTimer()
                    startCooldown()

                    if not IsPedInAnyVehicle(PlayerPedId(), true) then
                        TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
                    end
                elseif lock == 2 then
                    SetVehicleDoorsLocked(closestVehicle, 1)
                    PlayVehicleDoorOpenSound(closestVehicle, 0)
                    exports["mythic_notify"]:SendAlert("success", "ปลดล็อครถเรียบร้อย", 4 * 1000)
                    SendNUIMessage({ type = "unlock" })
                    drawVehicleOutline(closestVehicle, Config.UnlockColor)
                    drawVehicleMarker(closestVehicle, Config.UnlockColor)
                    lastLockTime = GetGameTimer()
                    startCooldown()

                    if not IsPedInAnyVehicle(PlayerPedId(), true) then
                        TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
                    end
                end
            else
                exports["mythic_notify"]:SendAlert("error", "คุณไม่ใช่เจ้าของรถ", 4 * 1000)
            end
        end, nearby_plate)
    end
end

RegisterNetEvent("Carkey:useKey")
AddEventHandler("Carkey:useKey", function(plate)
    if isCooldownActive then
        exports["mythic_notify"]:SendAlert("inform", "กรุณารอสักครู่ก่อนที่จะล็อกรถอีกครั้ง")
        return
    end

    local dict = "anim@mp_player_intmenu@key_fob@"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(7)
    end
    local coords = GetEntityCoords(GetPlayerPed(-1))
    cars = ESX.Game.GetVehiclesInArea(coords, 30)
    if #cars == 0 then
        exports["mythic_notify"]:SendAlert("inform", "ไม่มีรถอยู่ไกล้ๆ", 4 * 1000)
    else
        for _, car in ipairs(cars) do
            local nearby_plate = ESX.Math.Trim(GetVehicleNumberPlateText(car))
            if plate == nearby_plate then
                local lock = GetVehicleDoorLockStatus(car)
                if lock == 1 or lock == 0 then
                    SetVehicleDoorsLocked(car, 2)
                    PlayVehicleDoorCloseSound(car, 1)
                    exports["mythic_notify"]:SendAlert("error", "ล็อครถเรียบร้อย", 4 * 1000)
                    SendNUIMessage({ type = "lock" })
                    drawVehicleOutline(car, Config.LockColor)
                    drawVehicleMarker(car, Config.LockColor)
                    lastLockTime = GetGameTimer()
                    startCooldown()
                elseif lock == 2 then
                    SetVehicleDoorsLocked(car, 1)
                    PlayVehicleDoorOpenSound(car, 0)
                    exports["mythic_notify"]:SendAlert("success", "ปลดล็อครถเรียบร้อย", 4 * 1000)
                    SendNUIMessage({ type = "unlock" })
                    drawVehicleOutline(car, Config.UnlockColor)
                    drawVehicleMarker(car, Config.UnlockColor)
                    lastLockTime = GetGameTimer()
                    startCooldown()
                end

                if not IsPedInAnyVehicle(PlayerPedId(), true) then
                    TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
                end
            end
        end
    end
end)
