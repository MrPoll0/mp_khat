ESX = nil 
Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end

  while ESX.GetPlayerData().job == nil do
    Citizen.Wait(10)
  end

  ESX.PlayerData = ESX.GetPlayerData()
end) 

--------------------------------------------------------------    ----     --------------------------------------------------------------
--------------------------------------------------------------    VARIABLES   -----------------------------------------------------------
--------------------------------------------------------------    ----     --------------------------------------------------------------

local probabilidad = 0
local secondsRemaining = 0 
local isRecolecting = false
local incircle = false
local num = math.random(1,5)
local proc = {}
local arbustos = {}
local processer = {}
local tpinto = {}
local tpout = {}
local coords = false
local done = false
local money = 150

--------------------------------------------------------------    ----     --------------------------------------------------------------
--------------------------------------------------------------   HILO PRINCIPAL   -------------------------------------------------------
--------------------------------------------------------------    ----     --------------------------------------------------------------

Citizen.CreateThread(function()
  while true do
      Citizen.Wait(1)
      if coords == false then 
        ESX.TriggerServerCallback('mp_khat:coords', function(procC, arbustosC, processerC, tpintoC, tpoutC)
          proc = procC
          arbustos = arbustosC
          processer = processerC
          tpinto = tpintoC
          tpout = tpoutC
          coords = true
        end)
      else
        for k,v in pairs(arbustos)do
          if isRecolecting == false and GetDistanceBetweenCoords(arbustos[num].x, arbustos[num].y, arbustos[num].z, GetEntityCoords(PlayerPedId(),true)) < 1.5 then
            DrawText3D(arbustos[num].x, arbustos[num].y, arbustos[num].z, "~y~ " .. "[~w~" .. "E~y~" .. "] ~b~" .. " - Recolectar ~w~" .. "| Esta planta parece interesante...", 0, 255, 255)
            if IsControlJustPressed(0,38) and isRecolecting == false then
              isRecolecting = true
              secondsRemaining = 10
            end
          end
          if isRecolecting == true then
            DrawText3D(arbustos[num].x, arbustos[num].y, arbustos[num].z, "Recolectando...", 0, 255, 255)
            if secondsRemaining == 0 then
              isRecolecting = false
              probabilidad = math.random(1, 100)
              if probabilidad > 50 then
                TriggerServerEvent('mp_droga:givekhat', source)
              elseif probabilidad < 50 then
                TriggerEvent("pNotify:SendNotification", {text = "Parece que no has encontrado nada, la próxima vez será.", type = "info", timeout = math.random(10000, 10000), layout = "centerRight"})
              end
            end
          end
        end
        if GetDistanceBetweenCoords(tpinto.x, tpinto.y, tpinto.z, GetEntityCoords(PlayerPedId(),true)) <= 1 then -- coordenadas puerta interior
          DisplayHelpText("Presiona ~INPUT_CONTEXT~ para salir")
          if IsControlJustPressed(0,38) then
           DoScreenFadeOut(1000)
           while IsScreenFadingOut() do 
             Citizen.Wait(0) 
           end
           NetworkFadeOutEntity(PlayerPedId(), true, false)
           Wait(1000)
           SetEntityCoords(PlayerPedId(), tpout.x, tpout.y, tpout.z)
           SetEntityHeading(PlayerPedId(), 172.15)
           NetworkFadeInEntity(PlayerPedId(), 0)
           Wait(1000)
           SimulatePlayerInputGait(PlayerId(), 1.0, 100, 1.0, 1, 0)
           DoScreenFadeIn(1000)
           while IsScreenFadingIn() do 
             Citizen.Wait(0)
         end
        end
        end
        if GetDistanceBetweenCoords(tpout.x, tpout.y, tpout.z, GetEntityCoords(PlayerPedId(),true)) <= 1 then
          DisplayHelpText("Presiona ~INPUT_CONTEXT~ para entrar")
          if IsControlJustPressed(0,38) then
           DoScreenFadeOut(1000)
           while IsScreenFadingOut() do 
             Citizen.Wait(0) 
           end
           NetworkFadeOutEntity(PlayerPedId(), true, false)
           Wait(1000)
           SetEntityCoords(PlayerPedId(), tpinto.x, tpinto.y, tpinto.z)  -- coordenadas mapeo interior casa
           SetEntityHeading(PlayerPedId(), 172.15)
           NetworkFadeInEntity(PlayerPedId(), 0)
           Wait(1000)
           SimulatePlayerInputGait(PlayerId(), 1.0, 100, 1.0, 1, 0)
           DoScreenFadeIn(1000)
           while IsScreenFadingIn() do 
             Citizen.Wait(0)
         end
        end
        end
        if GetDistanceBetweenCoords(processer.x, processer.y, processer.z, GetEntityCoords(PlayerPedId(),true)) <= 15 then 
          DrawMarker(1, processer.x, processer.y, processer.z - 1, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, 1.5001, 1555, 0, 0,255, 0, 0, 0,0)
          if GetDistanceBetweenCoords(processer.x, processer.y, processer.z, GetEntityCoords(PlayerPedId(),true)) < 1 then
            
            if incircle == true then
              DisplayHelpText("Presiona ~INPUT_CONTEXT~ para ~r~" .. "procesar")
            end
            incircle = true
            if IsControlJustPressed(0, 38) then
              TriggerServerEvent('mp_droga:removekhat')
            end
          elseif GetDistanceBetweenCoords(processer.x, processer.y, processer.z, GetEntityCoords(PlayerPedId(),true)) > 1 then 
            incircle = false
          end
        end
        if GetDistanceBetweenCoords(proc.x, proc.y, proc.z, GetEntityCoords(PlayerPedId(),true)) <= 3 then
	        DrawText3D(proc.x, proc.y, proc.z + 1, "~y~ " .. "[~w~" .. "E~y~" .. "] ~b~" .. "- Hablar con Pollo", 255,0,0)
	        if IsControlJustPressed(1,38) then
	          OpenMenu()
	        end
	      end
      end
  end
end)

Citizen.CreateThread(function()
  while true do 
    Citizen.Wait(0)
    if isRecolecting then
        Citizen.Wait(1000)
        if(secondsRemaining > 0)then
          secondsRemaining = secondsRemaining - 1
        end
    end
  end
end)

--------------------------------------------------------------    ----     --------------------------------------------------------------
--------------------------------------------------------------   TP A INTERIOR/EXTERIOR    -------------------------------------------------------
--------------------------------------------------------------    ----     --------------------------------------------------------------


--------------------------------------------------------------    ----     --------------------------------------------------------------
--------------------------------------------------------------    NPC      --------------------------------------------------------------
--------------------------------------------------------------    ----     --------------------------------------------------------------

Citizen.CreateThread(function()
    modelHash = GetHashKey("G_M_Y_Lost_03")
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(1)
    end
    while true do 
      Citizen.Wait(0)
      if coords == false then 
          ESX.TriggerServerCallback('mp_khat:coords', function(procC, arbustosC, processerC, tpintoC, tpoutC)
            proc = procC
            arbustos = arbustosC
            processer = processerC
            tpinto = tpintoC
            tpout = tpoutC
            coords = true
          end)
      else
        if done == false then
          --createNPC()
          --createNPC2()
          done = true
        end
      end
    end
end)

function createNPC()
  created_ped2 = CreatePed(5, modelHash , proc.x, proc.y, proc.z - 1, proc.h, false, true)
  FreezeEntityPosition(created_ped2, true)
  SetEntityInvincible(created_ped2, true)
  SetBlockingOfNonTemporaryEvents(created_ped2, true)
  TaskStartScenarioInPlace(created_ped2, "WORLD_HUMAN_DRINKING", 0, true)
end

function createNPC2()
  created_ped3 = CreatePed(5, modelHash , processer.x, processer.y, processer.z - 1, processer.h, false, true)
  FreezeEntityPosition(created_ped3, true)
  SetEntityInvincible(created_ped3, true)
  SetBlockingOfNonTemporaryEvents(created_ped3, true)
  TaskStartScenarioInPlace(created_ped3, "WORLD_HUMAN_PICNIC", 0, true)
end

function OpenMenu()

  local elements = {
    {label = "Si" ,value = "yes"},
    {label = "No" ,value = "no"}
  }

  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'menu_vender',
    {
      title  = "¿Tienes algo de Khat procesado? Te lo compro.",
      align = "right",
      elements = elements
    },
    function(data, menu)
      if data.current.value == "yes" then                                                        
        TriggerServerEvent('mp_droga:removekhatproc', money)
        menu.close()
      else
        menu.close()
      end
    end,
    function(data, menu)
      menu.close()
    end
  )
end

--------------------------------------------------------------    ----     --------------------------------------------------------------
--------------------------------------------------------------    FUNCIONES   -----------------------------------------------------------
--------------------------------------------------------------    ----     --------------------------------------------------------------

function DrawText3D(x,y,z, text, r,g,b) -- some useful function, use it if you want!
  local onScreen,_x,_y=World3dToScreen2d(x,y,z)
  local px,py,pz=table.unpack(GetGameplayCamCoords())
  local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

  local scale = (1/dist)*2
  local fov = (1/GetGameplayCamFov())*100
  local scale = scale*fov
 
  if onScreen then
      SetTextScale(0.0*scale, 0.55*scale)
      SetTextFont(0)
      SetTextProportional(1)
      -- SetTextScale(0.0, 0.55)
      SetTextColour(r, g, b, 255)
      SetTextDropshadow(0, 0, 0, 0, 255)
      SetTextEdge(2, 0, 0, 0, 150)
      SetTextDropShadow()
      SetTextOutline()
      SetTextEntry("STRING")
      SetTextCentre(1)
      AddTextComponentString(text)
      DrawText(_x,_y)
  end
end

function drawTxt(x,y ,width,height,scale, text, r,g,b,a, outline)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    if(outline)then
      SetTextOutline()
  end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

function DisplayHelpText(str)
  SetTextComponentFormat("STRING")
  AddTextComponentString(str)
  DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

    
Citizen.CreateThread(function()
  Citizen.Wait(1000)
  RequestIpl("bkr_biker_interior_placement_interior_0_biker_dlc_int_01_milo")
  RequestIpl("bkr_biker_interior_placement_interior_1_biker_dlc_int_02_milo")
  RequestIpl("bkr_biker_interior_placement_interior_2_biker_dlc_int_ware01_milo")
  RequestIpl("bkr_biker_interior_placement_interior_3_biker_dlc_int_ware02_milo")
  RequestIpl("bkr_biker_interior_placement_interior_4_biker_dlc_int_ware03_milo")
  RequestIpl("bkr_biker_interior_placement_interior_5_biker_dlc_int_ware04_milo")
  RequestIpl("bkr_biker_interior_placement_interior_6_biker_dlc_int_ware05_milo")
  RequestIpl("ex_exec_warehouse_placement_interior_1_int_warehouse_s_dlc_milo")
  RequestIpl("ex_exec_warehouse_placement_interior_0_int_warehouse_m_dlc_milo")
  RequestIpl("ex_exec_warehouse_placement_interior_2_int_warehouse_l_dlc_milo")
  
  end)