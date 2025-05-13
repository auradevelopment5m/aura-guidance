local _a=exports['qb-core']:GetCoreObject()
local _b=require'config'

RegisterNetEvent('aura-guidance:server:setRoutingBucket',function()
    local _c=source
    local _d=_a.Functions.GetPlayer(_c)
    
    if _d then
        SetPlayerRoutingBucket(_c,_b.routingBucket)
        print(string.format("Player %s moved to routing bucket %s for tour",GetPlayerName(_c),_b.routingBucket))
    end
end)

RegisterNetEvent('aura-guidance:server:resetRoutingBucket',function()
    local _c=source
    local _d=_a.Functions.GetPlayer(_c)
    
    if _d then
        SetPlayerRoutingBucket(_c,0)
        print(string.format("Player %s returned to default routing bucket",GetPlayerName(_c)))
    end
end)