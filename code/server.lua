ESX = nil

TriggerEvent("esx:getSharedObject", function(obj)
    ESX = obj
end)

local function isAuthorized(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer and xPlayer.getGroup() ~= 'user'
end

local function sendToDiscord(webhook, message)
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
end

ESX.RegisterServerCallback("Carkey:isVehicleOwner", function(source, cb, plate)
    if not isAuthorized(source) then
        cb(false)
        return
    end
    
    local identifier = GetPlayerIdentifier(source, 0)
    local status, result = pcall(function()
        MySQL.Async.fetchAll("SELECT owner FROM owned_vehicles WHERE owner = @owner AND plate = @plate", {
            ["@owner"] = identifier,
            ["@plate"] = plate
        }, function(result)
            if result[1] then
                cb(result[1].owner == identifier)
            else
                cb(false)
            end
        end)
    end)

    if not status then
        print("Error in Carkey:isVehicleOwner: " .. tostring(result))
        cb(false)
    end
end)

ESX.RegisterServerCallback("Carkey:getVehicleKeys", function(source, cb)
    if not isAuthorized(source) then
        cb({})
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    local status, result = pcall(function()
        local KeyInventory = {}
        local Vehicle_Key = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @identifier", {
            ["@identifier"] = xPlayer.identifier
        })

        for _, vehicle in ipairs(Vehicle_Key) do
            table.insert(KeyInventory, {
                label = vehicle.plate,
                count = 1,
                limit = -1,
                type = "item_key",
                name = "key",
                usable = true,
                rare = false,
                canRemove = true
            })
        end

        cb(KeyInventory)
    end)

    if not status then
        print("Error in Carkey:getVehicleKeys: " .. tostring(result))
        cb({})
    end
end)

RegisterServerEvent("Carkey:giveKey")
AddEventHandler("Carkey:giveKey", function(target, type, plate)
    if not isAuthorized(source) then
        return
    end

    local sourceXPlayer = ESX.GetPlayerFromId(source)
    local targetXPlayer = ESX.GetPlayerFromId(target)
    local identifier = GetPlayerIdentifiers(source)[1]
    local identifier_target = GetPlayerIdentifiers(target)[1]

    if type == "item_key" then
        local status, result = pcall(function()
            MySQL.Async.execute("UPDATE owned_vehicles SET owner = @newplayer WHERE owner = @identifier AND plate = @plate", {
                ["@identifier"] = identifier,
                ["@newplayer"] = identifier_target,
                ["@plate"] = plate
            }, function(affectedRows)
                if affectedRows > 0 then
                    sendToDiscord(Config.Webhooks.sendToDiscordsource, "**" .. sourceXPlayer.name .. " ส่งกุญแจรถทะเบียน " .. plate .. " ให้กับ " .. targetXPlayer.name .. "**")
                    TriggerClientEvent('okokNotify:Alert', source, "แจ้งเตือน", "ส่งกุญแจรถทะเบียน  " .. plate .. "", 4000, 'success')
                    sendToDiscord(Config.Webhooks.sendToDiscordtarget, "**" .. targetXPlayer.name .. " ได้รับกุญแจรถทะเบียน " .. plate .. " จาก " .. sourceXPlayer.name .. "**")
                    TriggerClientEvent('okokNotify:Alert', target, "แจ้งเตือน", "ได้รับกุญแจรถทะเบียน  " .. plate .. "", 4000, 'success')
                end
            end)
        end)

        if not status then
            print("Error in Carkey:giveKey: " .. tostring(result))
        end
    end
end)

