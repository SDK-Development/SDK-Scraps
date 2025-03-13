local isWorking = false
local objects = {}
local points = {}
local blips = {}
local NPC = nil

local getWorkingTranslation = function ()
    if isWorking then
        return Config.Messages.STOP_WORKING
    else
        return Config.Messages.START_WORKING
    end
end

local changeWorkingState = function ()
    exports.ox_target:removeLocalEntity(NPC)
    exports.ox_target:disableTargeting(true)
    exports.ox_target:disableTargeting(false)
    exports.ox_target:addLocalEntity(NPC, {
        {
            label = getWorkingTranslation(),
            icon = "fa-solid fa-briefcase",
            onSelect = function()
                Debug('NPC work option selected. Current status:', isWorking)
                if isWorking then
                    stopWorking()
                else
                    startWork()
                end
            end
        },
        {
            label = Config.Messages.SELL_ITEMS,
            icon = "fa-solid fa-dollar-sign",
            onSelect = function()
                local success = lib.callback.await('sdk-recycling:server:sellItems')
                if success then
                    Notification(Config.Messages.ITEMS_SOLD)
                else
                    Notification(Config.Messages.NO_ITEMS_TO_SELL)
                end
            end
        }
    })
end

cleanup = function()
    Debug('Cleaning up objects, points and blips')
    for _, object in ipairs(objects) do
        if DoesEntityExist(object) then
            DeleteEntity(object)
        end
    end

    for _, point in ipairs(points) do
        if point.remove then
            point:remove()
        end
    end

    for _, blip in ipairs(blips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end

    objects = {}
    points = {}
    blips = {}
end

createObjectBlip = function (coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, Config.BlipScraps.Sprite)
    SetBlipColour(blip, Config.BlipScraps.Color)
    SetBlipScale(blip, Config.BlipScraps.Scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.BlipScraps.Name)
    EndTextCommandSetBlipName(blip)
    return blip
end

local createStartJobBlip = function ()
    local blip = AddBlipForCoord(Config.NPC.Location.x, Config.NPC.Location.y, Config.NPC.Location.z)
    SetBlipSprite(blip, Config.BlipStart.Sprite)
    SetBlipColour(blip, Config.BlipStart.Color)
    SetBlipScale(blip, Config.BlipStart.Scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.BlipStart.Name)
    EndTextCommandSetBlipName(blip)
    return blip
end

createStartJobBlip()

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    Debug('Resource stopping, cleaning up...')
    cleanup()
end)

startWork = function()
    Debug('Attempting to start work')
    if isWorking then
        stopWorking()
        return false
    end
    spawnObjects()
    isWorking = true  -- Set isWorking to true BEFORE calling changeWorkingState
    changeWorkingState()
    lib.callback.await('sdk-recycling:server:startWork')
    Notification(Config.Messages.STARTED_WORKING)
    Debug('Started working')
    return true
end

stopWorking = function()
    Debug('Stopping work')
    isWorking = false
    changeWorkingState()
    Notification(Config.Messages.STOPPED_WORKING)
    cleanup()
    lib.callback.await('sdk-recycling:server:stopWork')
end

spawnObjects = function()
    for i, objectLocation in ipairs(Config.ObjectPossibleLocations) do
        local randomObject = Config.Objects[math.random(#Config.Objects)]
        Debug('Spawning object:', randomObject .. " with ID: " .. i)

        local object = CreateObject(randomObject, 
            objectLocation.x,
            objectLocation.y,
            objectLocation.z - 1.0,
            true, true, true
        )

        SetEntityAsMissionEntity(object, true, true)
        SetEntityDynamic(object, true)
        FreezeEntityPosition(object, true)
        
        table.insert(objects, object)

        -- Create blip
        local blip = createObjectBlip(objectLocation)
        table.insert(blips, blip)

        local point = lib.points.new({
            coords = objectLocation,
            distance = 10,
        })
        
        table.insert(points, point)
        
        function point:nearby()
            DrawMarker(
                Config.MarkerSettings.Type,
                self.coords.x,
                self.coords.y,
                self.coords.z + 1.2,
                0.0, 0.0, 0.0,
                0.0, 180.0, 0.0,
                1.0, 1.0, 1.0,
                Config.MarkerSettings.Color.r, Config.MarkerSettings.Color.g, Config.MarkerSettings.Color.b, Config.MarkerSettings.Color.a,
                Config.MarkerSettings.Bouncing, true, 2, false,
                "", "", false
            )
        end


        exports.ox_target:addLocalEntity(object, {
            {
                label = Config.Messages.SEARCH,
                icon = "fa-solid fa-search",
                canInteract = function()
                    return isWorking and not IsPedInAnyVehicle(PlayerPedId(), false)
                end,
                onSelect = function()
                    SearchObject(object)
                end
            }
        })
    end
end

spawnNPC = function()
    local model = GetHashKey(Config.NPC.Model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end

    NPC = CreatePed(4, model,
        Config.NPC.Location.x,
        Config.NPC.Location.y,
        Config.NPC.Location.z - 1,
        Config.NPC.Location.w,
        false,
        true
    )

    SetEntityHeading(NPC, Config.NPC.Location.w)
    FreezeEntityPosition(NPC, true)
    SetEntityInvincible(NPC, true)
    SetBlockingOfNonTemporaryEvents(NPC, true)

    SetModelAsNoLongerNeeded(model)

    return NPC
end

addNPCOptions = function(target)
    Debug('Adding NPC options')
    exports.ox_target:addLocalEntity(target, {
    {
        label = getWorkingTranslation(),
        icon = "fa-solid fa-briefcase",
        onSelect = function()
            Debug('NPC work option selected. Current status:', isWorking)
            if isWorking then
                stopWorking()
            else
                startWork()
            end
        end
    },
    {
        label = Config.Messages.SELL_ITEMS,
        icon = "fa-solid fa-dollar-sign",
        onSelect = function()
            local success = lib.callback.await('sdk-recycling:server:sellItems')
            if success then
                Notification(Config.Messages.ITEMS_SOLD)
            else
                Notification(Config.Messages.NO_ITEMS_TO_SELL)
            end
        end
    }})
end

doProgress = function(duration, dict, clip, prop)
    return lib.progressCircle({
        duration = duration or Config.SearchTime,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = dict or 'amb@prop_human_bum_bin@base',
            clip = clip or 'base'
        },
        prop = prop
    })
end

SearchObject = function(object)
    Debug('Attempting to search object')
    if doProgress(
        Config.SearchTime,
        'amb@prop_human_bum_bin@base',
        'base'
    ) then
        local success = lib.callback.await('sdk-recycling:server:searchObject', false)
        Debug('Search callback result:', success)
        
        if success then
            Notification(Config.Messages.ITEM_FOUND)
            for i, obj in ipairs(objects) do
                if obj == object then
                    if points[i] and points[i].remove then
                        Debug('Removing point at index:', i)
                        points[i]:remove()
                    end
                    if blips[i] then
                        Debug('Removing blip at index:', i)
                        RemoveBlip(blips[i])
                    end
                    table.remove(points, i)
                    table.remove(objects, i)
                    table.remove(blips, i)
                    Debug('Deleting object')
                    DeleteEntity(object)
                    break
                end
            end
        end
    end
end

CreateThread(function()
    NPC = spawnNPC()
    addNPCOptions(NPC)
end)

--- CALLBACK TO SEND NOTIFICATION TO PLAYERS
--- FROM SERVER SIDE CODE!
lib.callback.register('sdk-recycling:client:showNotification', function(message)
    Notification(message)
end)


exports("startWork", startWork)