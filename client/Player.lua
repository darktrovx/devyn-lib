Lib.Player = {
    onHorse = false,
    currentHorse = nil,
    inVehicle = false,
    enteringVehicle = false,
    currentVehicle = nil,
    currentSeat = nil,
    currentWeapon = nil,
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