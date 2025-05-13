local _a=exports['qb-core']:GetCoreObject()
local _b=require'config'
local _c,_d,_e,_f,_g,_h=false,nil,1,nil,nil,{}
local _targetSystem = nil

local function GetTargetSystem()
    if _targetSystem then return _targetSystem end
    
    local success = pcall(function() return exports.ox_target end)
    if success then
        _targetSystem = 'ox_target'
        return 'ox_target'
    end
    
    success = pcall(function() return exports['qb-target'] end)
    if success then
        _targetSystem = 'qb-target'
        return 'qb-target'
    end
    
    print("ERROR: Neither ox_target nor qb-target was found!")
    return nil
end

local function AddTargetToEntity(entity, options)
    local targetSystem = GetTargetSystem()
    if not targetSystem then return false end
    
    if targetSystem == 'ox_target' then
        exports.ox_target:addLocalEntity(entity, options)
    elseif targetSystem == 'qb-target' then
        local qbOptions = {
            options = {},
            distance = 2.5
        }
        
        for _, option in ipairs(options) do
            table.insert(qbOptions.options, {
                type = "client",
                event = "",
                icon = option.icon,
                label = option.label,
                action = option.onSelect,
                canInteract = option.canInteract
            })
        end
        
        exports['qb-target']:AddTargetEntity(entity, qbOptions)
    end
    
    return true
end

local function _i(j,k,l)return j+(k-j)*l end

local function _j()
    local m=CreateCam("DEFAULT_SCRIPTED_CAMERA",true)
    SetCamActive(m,true)
    RenderScriptCams(true,false,1,true,true)
    return m
end

local function _k()
    if _d then
        SetCamActive(_d,false)
        DestroyCam(_d,true)
        RenderScriptCams(false,false,1,true,true)
        _d=nil
    end
end

local function _l()
    SetPauseMenuActive(false)
    DisableControlAction(0,200,true)
    DisableControlAction(0,202,true)
    DisableControlAction(0,322,true)
end

local function _m(n)
    local o=PlayerId()
    SetPlayerControl(o,not n,false)
    local p=PlayerPedId()
    if n then
        SetEntityCollision(p,false,false)
        FreezeEntityPosition(p,true)
        SetEntityInvincible(p,true)
    else
        SetEntityCollision(p,true,true)
        FreezeEntityPosition(p,false)
        SetEntityInvincible(p,false)
    end
end

local function _n(q,r,s,t,u)
    local v=GetGameTimer()
    local w=v+u
    CreateThread(function()
        while GetGameTimer()<w do
            local x=(GetGameTimer()-v)/u
            local y=vec3(
                _i(q.x,r.x,x),
                _i(q.y,r.y,x),
                _i(q.z,r.z,x)
            )
            local z=vec3(
                _i(s.x,t.x,x),
                _i(s.y,t.y,x),
                _i(s.z,t.z,x)
            )
            SetCamCoord(_d,y.x,y.y,y.z)
            SetCamRot(_d,z.x,z.y,z.z,2)
            Wait(0)
        end
        SetCamCoord(_d,r.x,r.y,r.z)
        SetCamRot(_d,t.x,t.y,t.z,2)
    end)
end

local function _o(q,s,A,B)
    local C=A.coords
    local r=vec3(C.x,C.y,C.z)
    local t=vec3(0,0,C.w)

    if not _d then _d=_j()end

    local D=_b.cameraTransitionTime*1.3

    local function E()
        local F=GetCamCoord(_d)
        local G=GetCamRot(_d,2)
        local H=vector3(-math.sin(math.rad(G.z)),math.cos(math.rad(G.z)),0.0)
        local I=F-(H*2.0)
        local p=PlayerPedId()
        SetEntityCoords(p,I.x,I.y,I.z,false,false,false,false)
        SetEntityHeading(p,G.z)
    end

    local J=vec3(q.x,q.y,q.z+300.0)
    CreateThread(function()
        local v=GetGameTimer()
        while GetGameTimer()-v<D do
            E()
            Wait(0)
        end
    end)
    _n(q,J,s,vec3(-90.0,0.0,C.w),D)
    Wait(D)

    local K=vec3(r.x,r.y,r.z+300.0)
    CreateThread(function()
        local v=GetGameTimer()
        while GetGameTimer()-v<D*1.5 do
            E()
            Wait(0)
        end
    end)
    _n(J,K,vec3(-90.0,0.0,C.w),vec3(-90.0,0.0,C.w),D*1.5)
    Wait(D*1.5)

    CreateThread(function()
        local v=GetGameTimer()
        while GetGameTimer()-v<D do
            E()
            Wait(0)
        end
    end)
    _n(K,r,vec3(-90.0,0.0,C.w),t,D)
    Wait(D)

    local L=A.icon or _b.thoughtDefaultIcon
    local M=_b.locationViewTime
    exports['aura-thoughts']:ShowTemporaryThought(A.text,L,M)

    Wait(_b.locationViewTime)

    if B then B()end
end

local function _p()
    if not _c then return end
    _c=false
    DoScreenFadeOut(1000)
    Wait(1000)
    _k()
    TriggerServerEvent("aura-guidance:server:resetRoutingBucket")
    local p=PlayerPedId()
    SetEntityCoords(p,_f.x,_f.y,_f.z,false,false,false,false)
    SetEntityHeading(p,_g)
    _m(false)
    Wait(500)
    DoScreenFadeIn(3000)
    lib.notify({title='Tour Guide',description='Tour ended',type='success'})
end

local function _q()
    if _c then return end
    _c=true
    _e=1
    local p=PlayerPedId()
    _f=GetEntityCoords(p)
    _g=GetEntityHeading(p)
    TriggerServerEvent("aura-guidance:server:setRoutingBucket")
    _m(true)
    _d=_j()
    local q=GetEntityCoords(p)
    local s=GetGameplayCamRot(2)
    SetCamCoord(_d,q.x,q.y,q.z+1.0)
    SetCamRot(_d,s.x,s.y,s.z,2)

    CreateThread(function()
        while _c do
            _l()
            Wait(0)
        end
    end)

    CreateThread(function()
        while _c do
            if _e<=#_b.tourLocations then
                local A=_b.tourLocations[_e]
                local F=GetCamCoord(_d)
                local G=GetCamRot(_d,2)
                _o(F,G,A,function()
                    _e=_e+1
                end)
            else
                _p()
                break
            end
            Wait(0)
        end
    end)
end

local function _r()
    lib.requestModel(_b.pedModel,500)
    if not HasModelLoaded(_b.pedModel)then return end

    for _,C in ipairs(_b.tourGuideLocations)do
        local N=CreatePed(4,_b.pedModel,C.x,C.y,C.z-1.0,C.w,false,true)
        if DoesEntityExist(N)then
            FreezeEntityPosition(N,true)
            SetEntityInvincible(N,true)
            SetBlockingOfNonTemporaryEvents(N,true)
            if _b.pedScenario then
                TaskStartScenarioInPlace(N,_b.pedScenario,0,true)
            end
            
            AddTargetToEntity(N, {
                {
                    name='start_tour',
                    icon='fas fa-map-marked',
                    label='Start Tour',
                    onSelect=function()
                        if not _c then
                            _q()
                        else
                            lib.notify({
                                title='Tour Guide',
                                description='A tour is already in progress',
                                type='error'
                            })
                        end
                    end
                }
            })
            
            table.insert(_h,N)
        end
    end
end

local function _s()
    for _,N in ipairs(_h)do
        if DoesEntityExist(N)then
            DeleteEntity(N)
        end
    end
    _h={}
end

AddEventHandler('onResourceStart',function(O)
    if GetCurrentResourceName()==O then
        _r()
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded',function()
    _r()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload',function()
    if _c then
        _p()
    end
end)

AddEventHandler('onResourceStop',function(O)
    if GetCurrentResourceName()==O then
        if _c then
            _p(true)
        end
        _s()
    end
end)

CreateThread(function()
    Wait(1000)
    local targetSystem = GetTargetSystem()
    if targetSystem then
        print("Using target system: " .. targetSystem)
    else
        print("ERROR: No compatible target system found!")
    end
end)
