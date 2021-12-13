local QBCore = exports['qb-core']:GetCoreObject()
local mining = false
local isWashing = false
local isMelting = false

Citizen.CreateThread(function()
    Wait(1000)
    AddMineBlip()
    Citizen.CreateThread(function()
        while true do
            local sleep = 100
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), vector3(Config.Sell.x, Config.Sell.y, Config.Sell.z), true) <= 3.0 then
                sleep = 0
                DrawText3D(Config.Sell.x, Config.Sell.y, Config.Sell.z, 'Press ~g~G~w~ to Sell Items')
                if IsControlJustReleased(0, 47) then
                    TriggerServerEvent('qb-mining:SellWashedStones')
                    sleep = 0
                end
            end
            Wait(sleep)
        end
    end)
    while true do    
        local sleep = 0
        local closeTo = 0
        for k, v in pairs(Config.MiningPositions) do
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), v.coords, true) <= 2.5 then
                closeTo = v
                break
            end
        end

        for k, v in pairs(Config.MiningPositions) do
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), v.coords, true) <= 15 then
                DrawMarker(2, v.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, -0.15, 195, 60, 60, 222, false, false, false, true, false, false, false)
                sleep = 0
            end
        end

        if type(closeTo) == 'table' then
            while GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), closeTo.coords, true) <= 2.5 do
                Wait(0)
                ShowHelpNotify(Strings['press_mine'])
                DrawMarker(2, closeTo.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, -0.15, 195, 60, 60, 222, false, false, false, true, false, false, false)
                QBCore.Functions.TriggerCallback('qb-mining:HasItem', function(hasItem)
                    if hasItem then
                        if IsControlJustReleased(0, 38) then
                            local player, distance = QBCore.Functions.GetClosestPlayer()
                            if distance == -1 or distance >= 4.0 then
                                mining = true
                                SetEntityCoords(PlayerPedId(), closeTo.coords)
                                SetEntityHeading(PlayerPedId(), closeTo.heading)
                                FreezeEntityPosition(PlayerPedId(), true)

                                local model = loadModel(GetHashKey(Config.Objects['pickaxe']))
                                local axe = CreateObject(model, GetEntityCoords(PlayerPedId()), true, false, false)
                                AttachEntityToEntity(axe, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.09, 0.03, -0.02, -78.0, 13.0, 28.0, false, true, true, true, 0, true)

                                while mining do
                                    Wait(0)
                                    SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'))
                                    ShowHelpNotify(Strings['mining_info'])
                                    DisableControlAction(0, 24, true)
                                    if IsDisabledControlJustReleased(0, 24) then
                                        local dict = loadDict('melee@hatchet@streamed_core')
                                        TaskPlayAnim(PlayerPedId(), dict, 'plyr_rear_takedown_b', 8.0, -8.0, -1, 2, 0, false, false, false)
                                        local timer = GetGameTimer() + 800
                                        while GetGameTimer() <= timer do Wait(0) DisableControlAction(0, 24, true) end
                                        ClearPedTasks(PlayerPedId())
                                        TriggerServerEvent('qb-mining:GiveStone')
                                    elseif IsControlJustReleased(0, 194) then
                                        break
                                    end
                                end
                                mining = false
                                DeleteObject(axe)
                                FreezeEntityPosition(PlayerPedId(), false)
                            else
                                QBCore.Functions.Notify(Strings['someone_close'])                        
                            end
                            sleep = 250
                        end
                    else
                        QBCore.Functions.Notify(Strings['No_item']) 
                    end
                end, 'pickaxe')
            end            
        end
        Wait(sleep)
    end
end)

local washingcoords = Config.WashingCoords
local meltingcoords = Config.MeltingCoords

Citizen.CreateThread(function()
	local sleep
	while not washingcoords do
		Citizen.Wait(0)
	end
	while true do
		sleep = 5
		local player = GetPlayerPed(-1)
		local playercoords = GetEntityCoords(player)
		local dist = #(vector3(playercoords.x,playercoords.y,playercoords.z)-vector3(washingcoords.x,washingcoords.y,washingcoords.z))
		if dist <= 3 and not isWashing then
			sleep = 5
			DrawText3D(washingcoords.x, washingcoords.y, washingcoords.z, 'Press ~g~E~w~ to wash')
			if IsControlJustPressed(1, 51) then
				isWashing = true
				QBCore.Functions.TriggerCallback('qb-mining:GetInvItem', function(result)
                        if result then
                            washing()
                        else
                            QBCore.Functions.Notify("You don't have material", "error")
                            isWashing = false
                        end
				end, 'stone')
			end
		else
			sleep = 1500
		end
		Citizen.Wait(sleep)
	end
end)

Citizen.CreateThread(function()
	local sleep
	while not meltingcoords do
		Citizen.Wait(0)
	end
	while true do
		sleep = 5
		local player = GetPlayerPed(-1)
		local playercoords = GetEntityCoords(player)
		local dist = #(vector3(playercoords.x,playercoords.y,playercoords.z)-vector3(meltingcoords.x,meltingcoords.y,meltingcoords.z))
		if dist <= 3 and not isMelting then
			sleep = 5
			DrawText3D(meltingcoords.x, meltingcoords.y, meltingcoords.z, 'Press ~g~E~w~ to melt')
			if IsControlJustPressed(1, 51) then
				isMelting = true
				QBCore.Functions.TriggerCallback('qb-mining:GiveInvItem', function(result)
                        if result then
                            melting()
                        else
                            QBCore.Functions.Notify("You don't have enough ", "error")
                            isMelting = false
                        end
				end, 'washedstone')
			end
		else
			sleep = 1500
		end
		Citizen.Wait(sleep)
	end
end)

function washing()
	local player = GetPlayerPed(-1)
	SetEntityCoords(player, washingcoords.x,washingcoords.y,washingcoords.z-1, 0.0, 0.0, 0.0, false)
	SetEntityHeading(player, 286.84)
	FreezeEntityPosition(player, true)
	local dict = loadDict('amb@prop_human_bum_bin@idle_a')
    TaskPlayAnim((player), 'amb@prop_human_bum_bin@idle_a', 'idle_a', 8.0, 8.0, -1, 81, 0, 0, 0, 0)

    QBCore.Functions.Notify("Check Inventory for weight or else item wont get added.")

	QBCore.Functions.Progressbar("wash-", "Washing..", 15000, false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {}, {}, {}, function() -- Done
		FreezeEntityPosition(player, false)
        TriggerServerEvent('qb-mining:WashStones')
		isWashing = false
	end, function() -- Cancel
		isWashing = false
		ClearPedTasksImmediately(player)
		FreezeEntityPosition(player, false)
	end)

end

function melting()
	local player = GetPlayerPed(-1)
	SetEntityCoords(player, meltingcoords.x,meltingcoords.y,meltingcoords.z-1, 0.0, 0.0, 0.0, false)
	SetEntityHeading(player, 236.00)
	FreezeEntityPosition(player, true)
	local dict = loadDict('amb@prop_human_bum_bin@idle_a')
    TaskPlayAnim((player), 'amb@prop_human_bum_bin@idle_a', 'idle_a', 8.0, 8.0, -1, 81, 0, 0, 0, 0)

    QBCore.Functions.Notify("Check Inventory for weight or else item wont get added.")

	QBCore.Functions.Progressbar("melt-", "Melting..", 20000, false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {}, {}, {}, function() -- Done
		FreezeEntityPosition(player, false)
        TriggerServerEvent('qb-mining:Melting')
		isMelting = false
	end, function() -- Cancel
		isMelting = false
		ClearPedTasksImmediately(player)
		FreezeEntityPosition(player, false)
	end)

end

function loadModel(model)
    while not HasModelLoaded(model) do Wait(0) RequestModel(model) end
    return model
end

function loadDict(dict, anim)
    while not HasAnimDictLoaded(dict) do Wait(0) RequestAnimDict(dict) end
    return dict
end

function ShowHelpNotify(msg)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

function AddMineBlip()
    local blip = AddBlipForCoord(vector3(2992.77, 2750.64, 42.78))
    SetBlipSprite(blip, 527)
    SetBlipColour(blip, 46)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Mining")
    EndTextCommandSetBlipName(blip)
end

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)

    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

local peds = {
	{type=4, hash= GetHashKey("cs_natalia"), x = Config.Sell.x,  y = Config.Sell.y,  z = Config.Sell.z - 1.0, h = Config.Sell.h},
}

Citizen.CreateThread(function()
	for _, item in pairs(peds) do
		RequestModel(item.hash)
		while not HasModelLoaded(item.hash) do
			Wait(1)
		end
		ped =  CreatePed(item.type, item.hash, item.x, item.y, item.z, item.a, false, true)
		SetBlockingOfNonTemporaryEvents(ped, true)
		SetPedDiesWhenInjured(ped, false)
		SetEntityHeading(ped, item.h)
		SetPedCanPlayAmbientAnims(ped, true)
		SetPedCanRagdollFromPlayerImpact(ped, false)
		SetEntityInvincible(ped, true)
		FreezeEntityPosition(ped, true)
	end
end)
