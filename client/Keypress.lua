Lib.Keypress = {}
local KEY_EVENTS = {}

function Lib.Keypress.AddKeyEvent(key, command, time, disabled, toggle)
    if not time then time = 500 end
    if not disabled then disabled = false end
    if not toggle then toggle = false end
    for i = 1, #KEY_EVENTS do
        if KEY_EVENTS[i].key == key then 
            print(string.format("Keybind %s already exists", key))
            return
        end
    end
    KEY_EVENTS[#KEY_EVENTS + 1] = { key = key, cooldown = false, command = command, time = time, disabled = disabled, toggle = toggle}
end
exports("AddKeyEvent", Lib.Keypress.AddKeyEvent)

local function AddKeyCooldown(index)
    CreateThread(function()
        KEY_EVENTS[index].cooldown = true
        Wait(KEY_EVENTS[index].time)
        KEY_EVENTS[index].cooldown = false
    end)
end

CreateThread(function()
    while true do
        for i = 1, #KEY_EVENTS do
            if not KEY_EVENTS[i].cooldown and not KEY_EVENTS[i].disabled then
                if IsControlJustReleased(0, KEY_EVENTS[i].key) then
                    ExecuteCommand(KEY_EVENTS[i].command)
                    AddKeyCooldown(i)
                end
            else
                if IsDisabledControlPressed(0, KEY_EVENTS[i].key) and IsInputDisabled(0) then
                    ExecuteCommand(KEY_EVENTS[i].command)
                    AddKeyCooldown(i)
                end
            end

            if KEY_EVENTS[i].disabled then
                DisableControlAction(0, KEY_EVENTS[i].key)
            end
        end
        Wait(0)
    end
end)