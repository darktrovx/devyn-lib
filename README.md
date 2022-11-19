# This script is a WIP and is by no means complete.
Releasing because some people have asked for it and hopefully it helps some others as well.

License: https://creativecommons.org/licenses/by-nc-nd/2.0/

# Natives
I've added these because some natives are named and some aren't.
Also some natives change between versions or just don't work at all.
```
Usage:
lib.Natives.NativeNameHere(arg1, arg2, ...)
```

# Blips
```
Add Blip -- returns the blip id.
There are preset colors and blip styles in the client/Blips.lua
lib.Blips.Create(style, color, sprite, scale, name)

Remove Blip
lib.Blips.Remove(blipId)
```

# Keypress
RedM doesn't have RegisterKeybind yet, instead of running a thread for each key you can run one
and add keybinds with the lib.
```
exports["devyn-lib"]:AddKeyEvent(key, command, time, disabled, toggle)
or if you loaded the entire lib
lib.Keypress.AddKeyEvent(key, command, time, disabled, toggle)
```

# Player
```
lib.Player.onHorse
lib.Player.currentHorse
lib.Player.inVehicle
lib.Player.enteringVehicle
lib.Player.currentVehicle
lib.Player.currentSeat
lib.Player.currentWeapon
lib.Player.holdingWeapon
```

# Exports
```
Load the lib: this will allow you to use any util inside the lib.
local lib = exports["devyn-lib"]:Load()

```

# Events
```
Events: These are events the game triggers whenever it interacts with the player.
If you want to trigger some code when a specific event happens you can use these events instead of creating a new thread each time.
TriggerEvent("events:listener", eventName, index, eventAtIndex)
TriggerServerEvent("events:listener", eventName, index, eventAtIndex)

Player Vehicle Events.
TriggerEvent('events:EnteringVehicle', vehicle, seat, netId)
TriggerServerEvent('events:EnteringVehicle', vehicle, seat, netId)
TriggerServerEvent('events:EnteringAborted')
TriggerEvent('events:EnteredVehicle', currentVehicle, currentSeat, netId)
TriggerServerEvent('events:EnteredVehicle', currentVehicle, currentSeat, netId)
TriggerEvent('events:LeftVehicle', currentVehicle, currentSeat, netId)
TriggerServerEvent('events:LeftVehicle', currentVehicle, currentSeat, netId)

Player Mounting Events.
TriggerEvent('events:MountOn', netId)
TriggerServerEvent('events:MountOn', netId)
TriggerEvent('events:MountOff', netId)
TriggerServerEvent('events:MountOff', netId)

Player Weapon Events.
TriggerEvent('events:holdingWeapon', weapon)
TriggerServerEvent('events:holdingWeapon', weapon)
TriggerEvent('events:holsterWeapon', weapon)
TriggerServerEvent('events:holsterWeapon', weapon)

```
