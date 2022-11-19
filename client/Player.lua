Lib.Player = {
    ped = false,
    id = false,
    onHorse = false,
    currentHorse = false,
    inVehicle = false,
    enteringVehicle = false,
    currentVehicle = false,
    currentSeat = false,
    currentWeapon = false,
    holdingWeapon = false,
}

function Lib.Player.CreateKey(key, value)
    if Lib.Player[key] == nil then
        Lib.Player[key] = value
    end
end
exports('CreateKey', Lib.Player.CreateKey)

function Lib.Player.UpdateKey(key, value)
    if Lib.Player[key] then
        Lib.Player[key] = value
    else
        print(string.format("Key %s does not exist", key))
    end
end
exports('UpdateKey', Lib.Player.UpdateKey)

function Lib.Player.RemoveKey(key)
    if Lib.Player[key] then
        Lib.Player[key] = nil
    else
        print(string.format("Key %s does not exist", key))
    end
end
exports('RemoveKey', Lib.Player.RemoveKey)

function Lib.Player.GetKey(key)
    if Lib.Player[key] then
        return Lib.Player[key]
    else
        print(string.format("Key %s does not exist", key))
    end
end
exports('GetKey', Lib.Player.GetKey)


local WaterHashes = {
    [1] = -247856387,
    [2] = -1504425495,
    [3] = -1369817450,
    [4] = -1356490953,
    [5] = -1781130443,
    [6] = -1300497193,
    [7] = -1276586360,
    [8] = -1410384421,
    [9] =  370072007,
    [10] =  650214731,
    [11] =  592454541,
    [12] =  -804804953,
    [13] =  1245451421,
    [14] =  -218679770,
    [15] =  -1817904483,
    [16] =  -811730579,
    [17] =  -1229593481,
    [18] =  -105598602,
    [19] =  1755369577,
    [20] =  -557290573,
    [21] =  -2040708515,
    [22] =  370072007,
    [23] =  231313522,
    [24] =  2005774838,
    [25] =  -1287619521,
    [26] =  -1308233316,
    [27] =  -196675805,
}

function Lib.Player.InWater()
    local coords = GetEntityCoords(Lib.Player.ped)
    local water = Lib.Natives.GetWaterMapZoneAtCoords(coords.x, coords.y, coords.z)

    for i=1, #WaterHashes, 1 do
        if water == WaterTypes[i] then
            return true
        end
    end
end