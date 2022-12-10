Lib.Zones = {}
local Active = {}
local Combo = nil

function UpdateComboZone(zone)
  if Combo == nil then

    Combo = ComboZone:Create({zone}, {name="combo", debugPoly=true})
    Active[zone["name"]] = zone
    
    Combo:onPlayerInOutExhaustive(function(isPointInside, point, insideZones, enteredZones, leftZones)

      if enteredZones then
        for i=1, #enteredZones do
          TriggerEvent("zones:enter", enteredZones[i]["name"], enteredZones[i]["data"])
          TriggerServerEvent("zones:enter", enteredZones[i]["name"], enteredZones[i]["data"])
        end
      end
  
      if leftZones then
        for i=1, #leftZones do
          TriggerEvent("zones:leave", leftZones[i]["name"], leftZones[i]["data"])
          TriggerServerEvent("zones:leave", leftZones[i]["name"], leftZones[i]["data"])
        end
      end
    end)

  else
    Combo:AddZone(zone)
    Active[zone["name"]] = zone
  end

end

local function ZoneExist(name)
  if Active[name] then
    return true
  else 
    return false 
  end
end

function Lib.Zones.CreateBoxZone(name, point, length, width, data)
    if ZoneExist(name) then return print("Zone with that name already exists") end
    if not data then data = {} end
    data.name = name
    local box = BoxZone:Create(point, length, width, data)
    UpdateComboZone(box)
end

exports("CreateBoxZone", function(name, point, length, width, data)
    Lib.Zones.CreateBoxZone(name, point, length, width, data)
end)

function Lib.Zones.CreatePolyZone(name, points, data)
    if ZoneExist(name) then return print("Zone with that name already exists") end
    if not data then data = {} end
    data.name = name
    local poly = PolyZone:Create(points, data)
    UpdateComboZone(poly)
end

exports("CreatePolyZone", function(name, points, data)
    Lib.Zones.CreatePolyZone(name, points, data)
end)

function Lib.Zones.CreateCircleZone(name, point, radius, data)
    if ZoneExist(name) then return print("Zone with that name already exists") end
    if not data then data = {} end
    data.name = name
    local circle = CircleZone:Create(point, radius, data)
    UpdateComboZone(circle)
end

exports("CreateCircleZone", function(name, point, radius, data)
    Lib.Zones.CreateCircleZone(name, point, radius, data)
end)

function Lib.Zones.CreateEntityZone(name, entity, data)
    if ZoneExist(name) then return print("Zone with that name already exists") end
    if not data then data = {} end
    data.name = name
    local entity = EntityZone:Create(entity, data)
    UpdateComboZone(entity)
end

exports("CreateEntityZone", function(name, entity, data)
    Lib.Zones.CreateEntityZone(name, entity, data)
end)

function Lib.Zones.DestroyZone(name)
    if not ZoneExist(name) then return print("Zone doesn't exist") end
    if Active[name] then
      Combo:RemoveZone(name)
      Active[name]:destroy()
      Active[name] = nil
    end
end

exports("DestroyZone", function(name)
    Lib.Zones.DestroyZone(name)
end)