local Working = {}
local Framework = Config.Framework

lib.callback.register('sdk-recycling:server:startWork', function(source)
  if Working[source] then
      return false
  end
  Working[source] = true
end)

lib.callback.register('sdk-recycling:server:stopWork', function(source)
  Working[source] = nil
end)

lib.callback.register('sdk-recycling:server:searchObject', function(source)
    if not Working[source] then
        Debug('Player not working:', source)
        return false
    end

    local Player = Framework == 'ESX' and ESX.GetPlayerFromId(source) or QBCore.Functions.GetPlayer(source)
    if not Player then
        Debug('Player not found:', source)
        return false 
    end

    local item = Config.PossibleItems[math.random(#Config.PossibleItems)]

    local amount = math.random(item.amount[1], item.amount[2])
    Debug('Giving item:', item.name, 'amount:', amount)

    local success = false
    if Framework == 'ESX' then
        success = Player.addInventoryItem(item.name, amount)
    else 
        success = Player.Functions.AddItem(item.name, amount)
    end

    Debug('Item give result:', success)
    if not success then
        Debug('Failed to give item:', item.name, 'to player:', source)
    end

    return true
end)

lib.callback.register('sdk-recycling:server:sellItems', function(source)
    if not Working[source] then
        lib.callback.await('sdk-recycling:client:showNotification', source, Config.Messages.MUST_WORK_TO_SELL)
        Debug('Player not working:', source)
        return false
    end

    local Player = Framework == 'ESX' and ESX.GetPlayerFromId(source) or QBCore.Functions.GetPlayer(source)
    if not Player then
        Debug('Player not found:', source)
        return false
    end

    local totalMoney = 0
    local itemsSold = false

    for _, item in pairs(Config.PossibleItems) do
        local itemCount = 0
        
        if Framework == 'ESX' then
            local inventoryItem = Player.getInventoryItem(item.name)
            itemCount = inventoryItem and inventoryItem.count or 0
        else
            local inventoryItem = Player.Functions.GetItemByName(item.name)
            itemCount = inventoryItem and inventoryItem.amount or 0
        end
            
        if itemCount > 0 then
            local itemValue = (item.sellPrice or 0) * itemCount
            totalMoney = totalMoney + itemValue
            itemsSold = true
            
            if Framework == 'ESX' then
                Player.removeInventoryItem(item.name, itemCount)
            else
                Player.Functions.RemoveItem(item.name, itemCount)
            end

            lib.callback.await('sdk-recycling:client:showNotification', source, Config.Messages.ITEMS_SOLD)
        else
            lib.callback.await('sdk-recycling:client:showNotification', source, Config.Messages.NO_ITEMS_TO_SELL)
            Debug("Player " .. source .. " has no " .. item.name .. " to sell.")
        end
    end

    if itemsSold then
        Debug('Adding money to player:', totalMoney)
        if Framework == 'ESX' then
            Debug('Adding money to player via ESX, MONEY:', totalMoney)
            Player.addMoney(totalMoney)
        else
            Debug('Adding money to player via QBCore, MONEY:', totalMoney)
            Player.Functions.AddMoney('cash', totalMoney)
        end
        return true, totalMoney
    end

    return false
end)

AddEventHandler('playerDropped', function (reason, resourceName, clientDropReason)
    Debug('Player ' .. GetPlayerName(source) .. ' dropped (Reason: ' .. reason .. ')' .. ' so removed him from Working table!')
    Working[source] = nil
end)