local isOnJob = false
local trashCollected = 0
local currentTruck = nil
local QBCore = exports['qb-core']:GetCoreObject()
local trashBags = {}
local trashSpawnRate = 60000 -- Adjust spawn rate in milliseconds

-- Create the NPC
Citizen.CreateThread(function()
    local model = GetHashKey("s_m_y_garbage")
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end

    local npc = CreatePed(4, model, -1103.8, -1692.5, 4.4, 0.0, false, true) -- Update coordinates
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    exports['ox_target']:AddBoxZone("garbage_job", vector3(-1103.8, -1692.5, 4.4), 1, 1, {
        name="garbage_job",
        heading=0,
        debugPoly=false,
        minZ=4.4,
        maxZ=6.4
    }, {
        options = {
            {
                event = "garbage:openJobMenu",
                icon = "fas fa-trash",
                label = "Garbage Job",
            }
        },
        distance = 1.5
    })
end)

-- Job menu
RegisterNetEvent('garbage:openJobMenu')
AddEventHandler('garbage:openJobMenu', function()
    local menu = {
        {
            header = "Garbage Job",
            isMenuHeader = true
        },
        {
            header = "Start Job",
            txt = "",
            params = {
                event = "garbage:startJob"
            }
        },
        {
            header = "Invite Players",
            txt = "",
            params = {
                event = "garbage:invitePlayers"
            }
        },
        {
            header = "Close Menu",
            txt = "",
            params = {
                event = "qb-menu:closeMenu"
            }
        }
    }
    exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent('garbage:startJob')
AddEventHandler('garbage:startJob', function()
    if not isOnJob then
        isOnJob = true
        trashCollected = 0

        -- Spawn garbage truck
        local model = GetHashKey("trash")
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end

        currentTruck = CreateVehicle(model, -1103.8, -1692.5, 4.4, 0.0, true, false) -- Update coordinates
        SetVehicleNumberPlateText(currentTruck, "GARBAGE")
        TaskWarpPedIntoVehicle(PlayerPedId(), currentTruck, -1)

        -- Start the trash collection process
        TriggerEvent('garbage:startCollecting')
    end
end)

RegisterNetEvent('garbage:startCollecting')
AddEventHandler('garbage:startCollecting', function()
    -- Start the random trash spawn timer
    Citizen.CreateThread(function()
        while isOnJob do
            Wait(trashSpawnRate)
            if isOnJob then
                SpawnRandomTrash()
            end
        end
    end)
end)

function SpawnRandomTrash()
    local x = math.random(-1100, -1000)
    local y = math.random(-1700, -1600)
    local z = 4.4

    local trashBag = CreateObject(GetHashKey("prop_rub_binbag_01"), x, y, z, true, true, true)
    PlaceObjectOnGroundProperly(trashBag)
    table.insert(trashBags, trashBag)

    exports['ox_target']:AddBoxZone("trash_bag_"..x.."_"..y, vector3(x, y, z), 1, 1, {
        name="trash_bag_"..x.."_"..y,
        heading=0,
        debugPoly=false,
        minZ=z - 1,
        maxZ=z + 1
    }, {
        options = {
            {
                event = "garbage:collectTrash",
                icon = "fas fa-hand",
                label = "Pick Up Trash",
                args = { trashBag = trashBag }
            }
        },
        distance = 1.5
    })
end

RegisterNetEvent('garbage:collectTrash')
AddEventHandler('garbage:collectTrash', function(data)
    local trashBag = data.trashBag

    -- Pick up the trash bag
    TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
    Citizen.Wait(5000) -- Adjust wait time as needed
    ClearPedTasks(PlayerPedId())

    -- Carry the trash bag to the truck
    AttachEntityToEntity(trashBag, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

    -- Add event to place the trash bag in the truck
    exports['ox_target']:AddBoxZone("trash_truck", GetEntityCoords(currentTruck), 3, 3, {
        name="trash_truck",
        heading=0,
        debugPoly=false,
        minZ=GetEntityCoords(currentTruck).z - 1,
        maxZ=GetEntityCoords(currentTruck).z + 1
    }, {
        options = {
            {
                event = "garbage:placeTrashInTruck",
                icon = "fas fa-hand",
                label = "Place Trash in Truck",
                args = { trashBag = trashBag }
            }
        },
        distance = 2.5
    })
end)

RegisterNetEvent('garbage:placeTrashInTruck')
AddEventHandler('garbage:placeTrashInTruck', function(data)
    local trashBag = data.trashBag

    -- Place the trash bag in the truck
    DeleteObject(trashBag)
    trashCollected = trashCollected + 1

    -- Clean up ox_target for the trash bag
    exports['ox_target']:RemoveZone("trash_bag_"..GetEntityCoords(trashBag).x.."_"..GetEntityCoords(trashBag).y)

    -- Check if all trash is collected
    if #trashBags == 0 then
        TriggerServerEvent('garbage:completeJob', trashCollected)
        isOnJob = false
        DeleteVehicle(currentTruck)
    end
end)

RegisterNetEvent('garbage:payPlayer')
AddEventHandler('garbage:payPlayer', function(payment)
    QBCore.Functions.Notify("You received $" .. payment .. " for your work!", "success")
end)

-- Utility function to get nearby players
function GetNearbyPlayers()
    local players = QBCore.Functions.GetPlayersInArea(GetEntityCoords(PlayerPedId()), 10.0)
    local nearbyPlayers = {}

    for _, player in ipairs(players) do
        table.insert(nearbyPlayers, GetPlayerServerId(player))
    end

    return nearbyPlayers
end
