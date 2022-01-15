
local cameras = nil
local openedcam = false


RegisterNetEvent('lucid:dialog:registerDialog')
AddEventHandler('lucid:dialog:registerDialog', function(newDialog)
    table.insert(Config.Dialogs, newDialog)
end)


Citizen.CreateThread(function()
   TriggerEvent('lucid:dialog:registerDialog',  {
       peds = { 
           {
               name = "Test Ped 2",-- Display name of the ped on the screen
               model =  GetHashKey('a_m_y_beach_01'),-- Ped model / https://wiki.rage.mp/index.php?title=Peds
               ped_handler = nil, -- Don't touch
               coords = vector3(1086.6611328125, -3114.05517578125, 5.8719458580017),
               heading = 0,
               draw_text3d_enable = false,
               draw_text3d_label = "E - I created from external file",
               questionLabel = "What do you want 2", -- This will display as ped question                    
           },
       },
       buttons = { -- Buttons to will display on screen
            {
               text = "Test Button 1", value = "test-btn1", icon = "fas fa-pills"
            }, 
            {
               text = "Test Button 2", value = "test-btn2", icon = "fas fa-pills" 
            },  
         },
         onClicked = function(value)
            if(value == "test-btn1") then
                print('Pressed Test Button 1 do something')
                elseif(value == "test-btn2") then
                print('Pressed Test Button 2 do something')
            end
        end
     })
end)

RegisterNetEvent('lucid:dialog:open')
AddEventHandler("lucid:dialog:open", function(k, buttons, name, question, entity)
    SetNuiFocus(true, true)
    createCamera(entity)
    SendNUIMessage({
        action = "setdialog",
        name = name,
        dialogIndex = k,
        buttons = buttons,
        question = question
    })
end)



function closeCam()
    if openedcam then
        SetCamActive(cameras['ped'], false)
        DestroyCam(cameras['ped'], true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)
        openedcam = false
    end
end


function GetClosestPed()
    local closestPed = 0
  
    for ped in EnumeratePeds() do
        local distanceCheck = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(ped), true)
        if distanceCheck <= 1.7 and not IsPedAPlayer(ped) and IsEntityAMissionEntity(ped) then
            closestPed = ped
            break
        end
    end

    return closestPed
end

function createCamera(ent)
    if(ent) == nil then
        
        ent = GetClosestPed()
    end
    local pedCoords = GetEntityCoords(PlayerPedId(), true)
    local coordsCam = GetOffsetFromEntityInWorldCoords(ent, 0.0, 0.5, 0.65)
    local entity = GetEntityCoords(ent)
    local cam1 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", (coordsCam.x), (coordsCam.y ), (coordsCam.z ), 0.00, 0.00, 10.00, 50.0, false, 2)
    cameras = {
        ['ped'] = cam1,
    }
    PointCamAtCoord(cameras.ped, entity.x, entity.y, (entity.z + 0.65))
    openedcam = true
    SetCamActive(cameras.ped, true)
    RenderScriptCams(true, true, 500, true, true)
    SetEntityVisible(PlayerPedId(), false)
end


RegisterNUICallback("close", function(data)
    SetNuiFocus(false,false)
    SetEntityVisible(PlayerPedId(), true)
    closeCam()
end)


RegisterNUICallback("triggerevent", function(data)
    local index = data.btnIndex
    local dialogIndex = data.dialogIndex
    Config.Dialogs[dialogIndex].onClicked(data.value)
    SendNUIMessage({
        action="close"
    })
    closeCam()
    SetEntityVisible(PlayerPedId(), true)
    SetNuiFocus(false, false)
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ply = PlayerPedId()
        local coords = GetEntityCoords(ply, true)
        for k,v in pairs(Config.Dialogs) do
            if v.peds then
                for _,ped in pairs(v.peds) do

          
                    local dist = #(coords - ped.coords)
                    if dist < 100.0 then
                        if ped and ped.ped_handler == nil and ped.model  then
                            createPed(ped)
                        end
                    else
                        if (ped.ped_handler) then
                            deletePed(ped.ped_handler)
                            ped.ped_handler = nil
                        end 
                    end
                end
            end
        end
    end
end)



RegisterNetEvent('lucid:spawncar')
AddEventHandler('lucid:spawncar', function(model, color)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end
    local coords = GetEntityCoords(PlayerPedId(), true)
    local veh = CreateVehicle(model, coords.x,coords.y + 4.0, coords.z, 0, true, true)
    SetVehicleCustomPrimaryColour(veh, color)
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
end)


local time = 3000
Citizen.CreateThread(function()
    while true do
    Citizen.Wait(time)
        local ply = PlayerPedId()
        local coords = GetEntityCoords(ply, true)
        local nearcoords = false

        for k,v in pairs(Config.Dialogs) do
            if v.peds then
                for _, ped in pairs(v.peds) do
                    if ped.coords then
                        local dist = #(ped.coords - coords)
                        if dist < 10 then
                            time = 0
                            nearcoords = true
                            if dist < 1.7 then
                                if ped.draw_text3d_enable then
                                    DrawText3D(ped.coords.x,ped.coords.y,ped.coords.z + 1.0,ped.draw_text3d_label)
                                end
                                if IsControlJustPressed(0, 38) then
                                    TriggerEvent('lucid:dialog:open', k, v.buttons, ped.name, ped.questionLabel,  ped.ped_handler )
                                end
                            else
                                if not nearcoords then
                                    time = 2000
                                end
                            end          
                        end
                    end
                end
            end
        end
    end
end)




RegisterNetEvent('lucid:close:dialog')
AddEventHandler('lucid:close:dialog', function()
     SendNUIMessage({
        action="close"
    })
    closeCam()
    SetNuiFocus(false, false)
end)




function createPed(ped)
    RequestModel(ped.model)
    while not HasModelLoaded(ped.model) do
        Wait(0)
    end
    ped.ped_handler = CreatePed(1, ped.model, ped.coords.x,ped.coords.y,ped.coords.z - 1.0, ped.heading, false, true)
    SetEntityHeading(ped.ped_handler, ped.heading)
    TaskSetBlockingOfNonTemporaryEvents(ped.ped_handler, true)
    SetPedFleeAttributes(ped.ped_handler, 0, 0)
    SetPedCombatAttributes(ped.ped_handler, 17, 1)
    SetPedSeeingRange(ped.ped_handler, 0.0)
    SetPedHearingRange(ped.ped_handler, 0.0)
    SetPedAlertness(ped.ped_handler, 0)
    SetPedKeepTask(ped.ped_handler, true)
    SetEntityInvincible(ped.ped_handler, true)
    SetBlockingOfNonTemporaryEvents(ped.ped_handler, true)
    FreezeEntityPosition(ped.ped_handler, true)
    SetModelAsNoLongerNeeded(ped.model)   
end

DrawText3D = function(x, y, z, text)
	SetTextScale(0.27, 0.26)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    ClearDrawOrigin()
end



function deletePed(ped)
    DeleteEntity(ped)
end





--[[The MIT License (MIT)
Copyright (c) 2017 IllidanS4
Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:
The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
]]



local entityEnumerator = {
    __gc = function(enum)
      if enum.destructor and enum.handle then
        enum.destructor(enum.handle)
      end
      enum.destructor = nil
      enum.handle = nil
    end
  }
  
  local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
      local iter, id = initFunc()
      if not id or id == 0 then
        disposeFunc(iter)
        return
      end
      
      local enum = {handle = iter, destructor = disposeFunc}
      setmetatable(enum, entityEnumerator)
      
      local next = true
      repeat
        coroutine.yield(id)
        next, id = moveFunc(iter)
      until not next
      
      enum.destructor, enum.handle = nil, nil
      disposeFunc(iter)
    end)
  end


function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
  end


