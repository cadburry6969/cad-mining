QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

RegisterServerEvent('qb-mining:GiveStone')
AddEventHandler('qb-mining:GiveStone', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)    
    if math.random(0, 100) <= Config.ChanceToGetItem then     
        Player.Functions.AddItem('stone', 1)        
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items['stone'], "add")
    end
end)

RegisterServerEvent("qb-mining:WashStones")
AddEventHandler("qb-mining:WashStones", function(x,y,z)
  	local src = source
  	local Player = QBCore.Functions.GetPlayer(src)
	local pick = Config.Items
    if Player.Functions.GetItemByName('stone').amount >= 10 then
        Player.Functions.RemoveItem('stone', 10)
        Player.Functions.AddItem('washedstone', 10)
        TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['stone'], "remove")
        TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['washedstone'], "add")    
    end
end)

RegisterNetEvent("qb-mining:Melting")
AddEventHandler("qb-mining:Melting", function(item, count)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local luck = math.random(1, 100)   
    local randomItem = nil             
    if luck == 100 then
        randomItem = "diamond"
        itemInfo = QBCore.Shared.Items[randomItem]
        Player.Functions.RemoveItem("washedstone", 1)
        Player.Functions.AddItem(randomItem, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "add")
        TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['washedstone'], "remove")
    elseif luck >= 80 and luck <= 90 then
        randomItem = "emerald"
        itemInfo = QBCore.Shared.Items[randomItem]
        Player.Functions.RemoveItem("washedstone", 1)
        Player.Functions.AddItem(randomItem, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "add")
        TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['washedstone'], "remove")
    elseif luck >= 50 and luck <= 80 then
        randomItem = "bluediamond"
        itemInfo = QBCore.Shared.Items[randomItem]
        Player.Functions.RemoveItem("washedstone", 1)
        Player.Functions.AddItem(randomItem, math.random(1,2))
        TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "add")
        TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['washedstone'], "remove")
    elseif luck >= 10 and luck <= 50 then
        randomItem = "whitepearl"
        itemInfo = QBCore.Shared.Items[randomItem]
        Player.Functions.RemoveItem("washedstone", 1)
        Player.Functions.AddItem(randomItem, math.random(1,3))
        TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "add")
        TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['washedstone'], "remove")
    elseif luck >= 0 and luck <= 10 then
        Player.Functions.RemoveItem("washedstone", 1)
        TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['washedstone'], "remove")
    end
    Citizen.Wait(500)
end)

RegisterServerEvent('qb-mining:SellWashedStones')
AddEventHandler('qb-mining:SellWashedStones', function()
    local src = source    
    local item = {}
    local Player = QBCore.Functions.GetPlayer(src)    
    item = Config.ItemList[math.random(1, #Config.ItemList)]
    if Player.Functions.GetItemByName(item.name).amount > 0 then   
        Player.Functions.RemoveItem(item.name, 1) 
        Player.Functions.AddMoney("cash", item.price, "sold-items")
    end    
    TriggerClientEvent('QBCore:Notify', src, "You have sold your items.")
    Wait(10)
end)

QBCore.Functions.CreateCallback('qb-mining:HasItem', function(source, cb, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player ~= nil then 
      local Item = Player.Functions.GetItemByName(item)
      if Item ~= nil then
        cb(true)
      else
        cb(false)
      end
    else
      cb(false)
    end
  end)