QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('garbage:startJob')
AddEventHandler('garbage:startJob', function()
    local Player = QBCore.Functions.GetPlayer(source)
    TriggerClientEvent('garbage:beginJob', source)
end)

RegisterServerEvent('garbage:invitePlayers')
AddEventHandler('garbage:invitePlayers', function(nearbyPlayers)
    for _, playerId in pairs(nearbyPlayers) do
        TriggerClientEvent('garbage:receiveInvite', playerId, source)
    end
end)

RegisterServerEvent('garbage:completeJob')
AddEventHandler('garbage:completeJob', function(trashCollected)
    local Player = QBCore.Functions.GetPlayer(source)
    local payment = math.floor(trashCollected * 10) -- Adjust the multiplier as needed
    Player.Functions.AddMoney('cash', payment)
    TriggerClientEvent('garbage:payPlayer', source, payment)
end)
