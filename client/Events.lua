Lib.Events = {}

-- CACHE
local PlayerPedId = PlayerPedId
local PlayerId = PlayerId
local IsPlayerDead = IsPlayerDead
local DoesEntityExist = DoesEntityExist
local GetSeatPedIsTryingToEnter = GetSeatPedIsTryingToEnter
local IsPedInAnyVehicle = IsPedInAnyVehicle
local VehToNet = VehToNet
local IsPedOnMount = IsPedOnMount
local GetMount = GetMount
local NetworkGetNetworkIdFromEntity = NetworkGetNetworkIdFromEntity
local IsPlayerDead = IsPlayerDead

local GetNumberOfEvents = GetNumberOfEvents
local GetEventAtIndex = GetEventAtIndex

local function GetPedVehicleSeat(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    for i=-2,GetVehicleMaxNumberOfPassengers(vehicle) do
        if(GetPedInVehicleSeat(vehicle, i) == ped) then return i end
    end
    return -2
end

exports("InVehicle", function()
    return Lib.Player.inVehicle
end)

exports("Vehicle", function()
    return Lib.Player.currentVehicle
end)

exports("Seat", function()
    return Lib.Player.currentSeat
end)

exports("Horse", function()
    return Lib.Player.currentHorse
end)

exports("Weapon", function()
    return Lib.Player.currentWeapon
end)

exports("HoldingWeapon", function()
    return Lib.Player.holdingWeapon
end)

CreateThread(function()
	while true do

        -- RD2 Events : https://github.com/femga/rdr3_discoveries/blob/master/AI/EVENTS/events.lua
        local size = GetNumberOfEvents(0)
        if size > 0 then
            for i = 0, size - 1 do
                local eventAtIndex = GetEventAtIndex(0, i)
                if EVENTS[eventAtIndex] then
                    if DEBUG then
                        print(EVENTS[eventAtIndex].name)
                    end
                    TriggerEvent("events:listener", EVENTS[eventAtIndex].name, index, eventAtIndex)
                    TriggerServerEvent("events:listener", EVENTS[eventAtIndex].name, index, eventAtIndex)
                end
            end
        end

        local ped = PlayerPedId()
		Lib.Player.ped = ped
        local id = PlayerId()
		Lib.Player.id = id

        -- Vehicles
        if not Lib.Player.inVehicle and not IsPlayerDead(id) then
			if DoesEntityExist(GetVehiclePedIsEntering(ped)) and not Lib.Player.enteringVehicle then
				-- trying to enter a vehicle!
				local vehicle = GetVehiclePedIsEntering(ped)
				local seat = GetSeatPedIsTryingToEnter(ped)
				local netId = VehToNet(vehicle)
				Lib.Player.enteringVehicle = true
                TriggerEvent('events:EnteringVehicle', vehicle, seat, netId)
				TriggerServerEvent('events:EnteringVehicle', vehicle, seat, netId)
                --print(string.format("ATTEMPTING: %s %s %s", vehicle, seat, netId))
			elseif not DoesEntityExist(GetVehiclePedIsEntering(ped)) and not IsPedInAnyVehicle(ped, true) and Lib.Player.enteringVehicle then
				-- vehicle entering aborted
				TriggerServerEvent('events:EnteringAborted')
				Lib.Player.enteringVehicle = false
                --print("aborted")
			elseif IsPedInAnyVehicle(ped, false) then
				-- suddenly appeared in a vehicle, possible teleport
				Lib.Player.enteringVehicle = false
				Lib.Player.inVehicle = true
				Lib.Player.currentVehicle = GetVehiclePedIsUsing(ped)
				Lib.Player.currentSeat = GetPedVehicleSeat(ped)
				local model = GetEntityModel(Lib.Player.currentVehicle)
				local netId = VehToNet(Lib.Player.currentVehicle)
                --print(string.format("ENTERED: %s %s %s", Lib.Player.currentVehicle, Lib.Player.currentSeat, netId))
                TriggerEvent('events:EnteredVehicle', Lib.Player.currentVehicle, Lib.Player.currentSeat, netId)
				TriggerServerEvent('events:EnteredVehicle', Lib.Player.currentVehicle, Lib.Player.currentSeat, netId)
			end
		elseif Lib.Player.inVehicle then
			if not IsPedInAnyVehicle(ped, false) then
				-- bye, vehicle
				local model = GetEntityModel(Lib.Player.currentVehicle)
				local netId = VehToNet(Lib.Player.currentVehicle)
                --print(string.format("LEFT: %s %s %s", Lib.Player.currentVehicle, Lib.Player.currentSeat, netId))
                TriggerEvent('events:LeftVehicle', Lib.Player.currentVehicle, Lib.Player.currentSeat, netId)
				TriggerServerEvent('events:LeftVehicle', Lib.Player.currentVehicle, Lib.Player.currentSeat, netId)
				Lib.Player.inVehicle = false
				Lib.Player.currentVehicle = 0
				Lib.Player.currentSeat = 0
			end
		end

        -- Mounts
        if not Lib.Player.onHorse and not IsPlayerDead(id) then
            if IsPedOnMount(ped) then
                Lib.Player.currentHorse = GetMount(ped)
                Lib.Player.onHorse = true
                local netId = NetworkGetNetworkIdFromEntity(Lib.Player.currentHorse)
                TriggerEvent('events:MountOn', netId)
                TriggerServerEvent('events:MountOn', netId)
            end
        elseif Lib.Player.onHorse then
            if not IsPedOnMount(ped) then
                local netId = NetworkGetNetworkIdFromEntity(Lib.Player.currentHorse)
                TriggerEvent('events:MountOff', netId)
                TriggerServerEvent('events:MountOff', netId)
                Lib.Player.onHorse = false
                Lib.Player.currentHorse = nil
            end
        end

        Wait(0)
	end
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local weapon = Lib.Natives.GetPedCurrentHeldWeapon(ped)
        if not Lib.Player.holdingWeapon and not IsPlayerDead(ped) and weapon ~= `WEAPON_UNARMED`then
            Lib.Player.holdingWeapon = true
            Lib.Player.currentWeapon = weapon
            TriggerEvent('events:holdingWeapon', weapon)
            TriggerServerEvent('events:holdingWeapon', weapon)
        elseif Lib.Player.holdingWeapon and not IsPlayerDead(PlayerPed) and weapon == `WEAPON_UNARMED` then
            TriggerEvent('events:holsterWeapon', weapon)
            TriggerServerEvent('events:holsterWeapon', weapon)
            Lib.Player.currentWeapon = nil
            Lib.Player.holdingWeapon = false
        end
        Wait(300)
    end
end)

-- DON'T TOUCH THIS
EVENTS = {
    [-1980748902]   = { hash = "0x89F02B9A", name = "EVENT_ACQUAINTANCE_PED_DISLIKE" },
	[435938875]	    = { hash = "0x19FBE63B", name = "EVENT_ACQUAINTANCE_PED_HATE" },
	[-1778603064]	= { hash = "0x95FCABC8", name = "EVENT_ACQUAINTANCE_PED_LIKE" },
	[-406996059]	= { hash = "0xE7BDBBA5", name = "EVENT_ACQUAINTANCE_PED_RESPECT" },
	[510893831]	    = { hash = "0x1E739F07", name = "EVENT_ACQUAINTANCE_PED_WANTED" },	
	[1734436639]	= { hash = "0x6761671F", name = "EVENT_ACQUAINTANCE_PED_DISGUISE" },
	[-196899787]	= { hash = "0xF4438C35", name = "EVENT_ACQUAINTANCE_PED_DEAD" },
	[2050604246]	= { hash = "0x7A39BCD6", name = "EVENT_ACQUAINTANCE_PED_THIEF" },
	[1874382407]	= { hash = "0x6FB8CE47", name = "EVENT_AMBIENT_THREAT_LEVEL_MAXED" },
	[-33759860]	    = { hash = "0xFDFCDD8C", name = "EVENT_ANIMAL_DETECTED_PREY" },
	[1545444922]	= { hash = "0x5C1D9E3A", name = "EVENT_ANIMAL_DETECTED_PREDATOR" },
	[1428655956]	= { hash = "0x55278F54", name = "EVENT_ANIMAL_DETECTED_THREAT" },
	[571505700]	    = { hash = "0x22107C24", name = "EVENT_ANIMAL_DETECTED_TRAIN" },
	[2129777492]	= { hash = "0x7EF1D354", name = "EVENT_ANIMAL_PROVOKED" },
	[1312307149]	= { hash = "0x4E3837CD", name = "EVENT_PLAYER_IN_CLOSE_PROXIMITY_TO_HORSE" },
	[205245793]	    = { hash = "0x0C3BCD61", name = "EVENT_COMMUNICATE_EVENT" },
	[1548353157]	= { hash = "0x5C49FE85", name = "EVENT_COP_CAR_BEING_STOLEN" },
	[1924269094]	= { hash = "0x72B20426", name = "EVENT_CRIME_CONFIRMED" },
	[-830063453]	= { hash = "0xCE863CA3", name = "EVENT_CRIME_REPORTED" },
	[-978548489]	= { hash = "0xC5AC88F7", name = "EVENT_DAMAGE" },
	[1589923363]	= { hash = "0x5EC44E23", name = "EVENT_DEAD_PED_FOUND" },
	[-589037342]	= { hash = "0xDCE400E2", name = "EVENT_DRAFT_ANIMAL_DETACHED_FROM_VEHICLE" },
	[443288134]	    = { hash = "0x1A6C0A46", name = "EVENT_DRAGGED_OUT_CAR" },	
	[-296445841]	= { hash = "0xEE54986F", name = "EVENT_DUMMY_CONVERSION" },	
	[1973084963]	= { hash = "0x759AE323", name = "EVENT_EXPLOSION" },
	[-141209784]	= { hash = "0xF7954F48", name = "EVENT_EXPLOSION_HEARD" },
	[1384795140]	= { hash = "0x528A4C04", name = "EVENT_FIRE_NEARBY" },
	[-436506701]	= { hash = "0xE5FB6FB3", name = "EVENT_FOOT_STEP_HEARD" },
	[1570376850]	= { hash = "0x5D9A0C92", name = "EVENT_GET_OUT_OF_WATER" },
	[1949380209]	= { hash = "0x74312E71", name = "EVENT_GIVE_PED_TASK" },
	[157877922]	    = { hash = "0x096906A2", name = "EVENT_GUN_AIMED_AT" },
	[590795301]	    = { hash = "0x2336D225", name = "EVENT_INJURED_CRY_FOR_HELP" },
	[-267776637]	= { hash = "0xF00A0D83", name = "EVENT_INJURED_RIDER" },
	[-464235721]	= { hash = "0xE4545337", name = "EVENT_INJURED_DRIVER" },
	[343470035]	    = { hash = "0x1478EFD3", name = "EVENT_INJURED_OWNER" },
	[-1498867790]	= { hash = "0xA6A917B2", name = "EVENT_CRIME_CRY_FOR_HELP" },
	[871686291]	    = { hash = "0x33F4E093", name = "EVENT_IN_AIR" },
	[1538190288]	= { hash = "0x5BAEEBD0", name = "EVENT_IN_WATER" },
	[1937487669]	= { hash = "0x737BB735", name = "EVENT_INCAPACITATED" },
	[-1430694196]	= { hash = "0xAAB956CC", name = "EVENT_KNOCKEDOUT" },
    [-597386145]	= { hash = "0xDC649C5F", name = "EVENT_LASSO_HIT" },
	[-20789381]	    = { hash = "0xFEC2C77B", name = "EVENT_LEADER_ENTERED_CAR_AS_DRIVER" },
	[-1691761750]	= { hash = "0x9B29C3AA", name = "EVENT_LEADER_ENTERED_COVER" },
	[-69092029]	    = { hash = "0xFBE1BD43", name = "EVENT_LEADER_EXITED_CAR_AS_DRIVER" },
	[1234058372]	= { hash = "0x498E3C84", name = "EVENT_LEADER_HOLSTERED_WEAPON" },
	[1189677571]	= { hash = "0x46E90A03", name = "EVENT_LEADER_LEFT_COVER" },
	[-474465748]	= { hash = "0xE3B83A2C", name = "EVENT_LEADER_UNHOLSTERED_WEAPON" },
	[1907495613]	= { hash = "0x71B212BD", name = "EVENT_MELEE_ACTION" },
	[1034611035]	= { hash = "0x3DAAE95B", name = "EVENT_MOUNTED_COLLISION" },
	[519123279]	    = { hash = "0x1EF1314F", name = "EVENT_MUST_LEAVE_BOAT" },
	[1016266288]	= { hash = "0x3C92FE30", name = "EVENT_NEW_TASK" },
	[304848651]	    = { hash = "0x122B9F0B", name = "EVENT_NONE" },
	[-918452453]	= { hash = "0xC941871B", name = "EVENT_OBJECT_COLLISION" },
	[151661781]	    = { hash = "0x090A2CD5", name = "EVENT_ON_FIRE" },
	[1908962476]	= { hash = "0x71C874AC", name = "EVENT_OPEN_DOOR" },
	[1006186021]	= { hash = "0x3BF92E25", name = "EVENT_SHOVE_PED" },
	[-902797869]	= { hash = "0xCA3065D3", name = "EVENT_VEHICLE_WAITING_ON_PED_TO_MOVE_AWAY" },
	[-1903382559]	= { hash = "0x8E8CAFE1", name = "EVENT_PED_COLLISION_WITH_PED" },
	[-1421834278]	= { hash = "0xAB4087DA", name = "EVENT_PED_COLLISION_WITH_PLAYER" },
	[-815104519]	= { hash = "0xCF6A7DF9", name = "EVENT_PED_ENTERED_MY_VEHICLE" },
	[-1892910243]	= { hash = "0x8F2C7B5D", name = "EVENT_PED_JACKING_MY_VEHICLE" },
	[318280644]	    = { hash = "0x12F893C4", name = "EVENT_PLAYER_COLLISION_WITH_PED"},
	[-2012456100]	= { hash = "0x880C5B5C", name = "EVENT_PLAYER_APPROACHED"},
	[1353184080]	= { hash = "0x50A7F350", name = "EVENT_PLAYER_ON_ROOFTOP"},
	[-947302919]	= { hash = "0xC7894DF9", name = "EVENT_POTENTIAL_BE_WALKED_INTO"},
	[650393230]	    = { hash = "0x26C4368E", name = "EVENT_POTENTIAL_BLAST"},
	[-479306639]	= { hash = "0xE36E5C71", name = "EVENT_POTENTIAL_GET_RUN_OVER"},
	[-971391370]	= { hash = "0xC619BE76", name = "EVENT_POTENTIAL_WALK_INTO_FIRE"},
	[1994340821]	= { hash = "0x76DF39D5", name = "EVENT_POTENTIAL_WALK_INTO_OBJECT"},
	[2085861296]	= { hash = "0x7C53B7B0", name = "EVENT_POTENTIAL_WALK_INTO_VEHICLE"},
	[-295316025]	= { hash = "0xEE65D5C7", name = "EVENT_PROVIDING_COVER"},
	[721285987]	    = { hash = "0x2AFDF363", name = "EVENT_PULLED_FROM_MOUNT"},
	[1551265137]	= { hash = "0x5C766D71", name = "EVENT_RADIO_TARGET_POSITION"},
	[347157807]	    = { hash = "0x14B1352F", name = "EVENT_RAN_OVER_PED"},
	[-885872273]	= { hash = "0xCB32A96F", name = "EVENT_RESPONDED_TO_THREAT"},
	[1074204023]	= { hash = "0x40070D77", name = "EVENT_INCOMING_THREAT"},
	[-2090275807]	= { hash = "0x8368EC21", name = "EVENT_REVIVED"},
	[256981913]	    = { hash = "0x0F513B99", name = "EVENT_SCRIPT_COMMAND"},
	[-1193777941]	= { hash = "0xB8D864EB", name = "EVENT_LASSO_WHIZZED_BY"},
	[-587661767]	= { hash = "0xDCF8FE39", name = "EVENT_SHOT_FIRED"},
	[-412084084]	= { hash = "0xE770188C", name = "EVENT_CRIME_WITNESSED"},
	[-1011311845]	= { hash = "0xC3B89B1B", name = "EVENT_POTENTIAL_CRIME"},
	[-868397664]	= { hash = "0xCC3D4DA0", name = "EVENT_POTENTIAL_THREAT_APPROACHING"},
	[918533970]	    = { hash = "0x36BFB752", name = "EVENT_ARMED_PED_APPROACHING"},
	[-998673475]	= { hash = "0xC47973BD", name = "EVENT_SHOT_FIRED_BASE"},
	[-1507090758]	= { hash = "0xA62B9EBA", name = "EVENT_SHOT_FIRED_BULLET_IMPACT"},
	[-1102089407]	= { hash = "0xBE4F7341", name = "EVENT_SHOT_FIRED_WHIZZED_BY"},
	[-222448429]	= { hash = "0xF2BDB4D3", name = "EVENT_FRIENDLY_AIMED_AT"},
	[-456414135]	= { hash = "0xE4CBAC49", name = "EVENT_SHOUT_TARGET_POSITION"},
	[-660243554]	= { hash = "0xD8A57B9E", name = "EVENT_STUCK_IN_AIR"},
	[379908161]	    = { hash = "0x16A4F041", name = "EVENT_SUSPICIOUS_ACTIVITY"},
	[1753103034]	= { hash = "0x687E3ABA", name = "EVENT_UNIDENTIFIED_PED"},
	[1065635568]	= { hash = "0x3F844EF0", name = "EVENT_VEHICLE_COLLISION"},
	[-85413846]	    = { hash = "0xFAE8B02A", name = "EVENT_VEHICLE_DAMAGE_WEAPON"},
	[-1822495842]	= { hash = "0x935EEB9E", name = "EVENT_VEHICLE_ON_FIRE"},
	[-1054071698]	= { hash = "0xC12C246E", name = "EVENT_WHISTLING_HEARD"},
	[770328215]	    = { hash = "0x2DEA4697", name = "EVENT_DISTURBANCE"},
	[402722103]	    = { hash = "0x18010D37", name = "EVENT_ENTITY_DAMAGED"},
	[-313265754]	= { hash = "0xED53F1A6", name = "EVENT_ENTITY_BROKEN"},
	[2145012826]	= { hash = "0x7FDA4C5A", name = "EVENT_ENTITY_DESTROYED"},
	--[735942751]	    = { hash = "0x2BDD985F", name = "EVENT_PED_CREATED"},
	--[1626561060]	= { hash = "0x60F35A24", name = "EVENT_PED_DESTROYED"},
	[-1863021589]	= { hash = "0x90F48BEB", name = "EVENT_VEHICLE_CREATED"},
	[-1231347001]	= { hash = "0xB69B22C7", name = "EVENT_VEHICLE_DESTROYED"},
	[-2130219717]	= { hash = "0x81076D3B", name = "EVENT_WITHIN_GUN_COMBAT_AREA"},
	[-960741963]	= { hash = "0xC6BC3DB5", name = "EVENT_WITHIN_LAW_RESPONSE_AREA"},
	[-1156527968]	= { hash = "0xBB10C8A0", name = "EVENT_PLAYER_UNABLE_TO_ENTER_VEHICLE"},
	[178452260]	    = { hash = "0x0AA2F724", name = "EVENT_PED_SEEN_DEAD_PED"},
	[-981629276]	= { hash = "0xC57D86A4", name = "EVENT_PLAYER_DEATH"},
	[-1891898498]	= { hash = "0x8F3BEB7E", name = "EVENT_SHOT_FIRED_WHIZZED_BY_ENTITY"},
	[-322032286]	= { hash = "0xECCE2D62", name = "EVENT_PED_RAN_OVER_SCRIPT"},
	[-140551285]	= { hash = "0xF79F5B8B", name = "EVENT_ENTITY_EXPLOSION"},
	[295876924]	    = { hash = "0x11A2B93C", name = "EVENT_CUT_FREE"},
	[1266167444]	= { hash = "0x4B782E94", name = "EVENT_HOGTIED"},
	[-503202760]	= { hash = "0xE201BC38", name = "EVENT_HORSE_STARTED_BREAKING"},
	[-1569206802]	= { hash = "0xA277CDEE", name = "EVENT_BEING_LOOTED"},
	[-507840394]	= { hash = "0xE1BAF876", name = "EVENT_NETWORK_SCRIPT_EVENT"},
	[1976253964]	= { hash = "0x75CB3E0C", name = "EVENT_NETWORK_NETWORK_BAIL"},
	[750867124]	    = { hash = "0x2CC152B4", name = "EVENT_TEXT_MESSAGE_RECEIVED"},
	[1814485447]	= { hash = "0x6C26D9C7", name = "EVENT_NETWORK_PED_LEFT_BEHIND"},
	[-339257625]	= { hash = "0xEBC756E7", name = "EVENT_NETWORK_EMAIL_RECEIVED"},
	[1741908893]	= { hash = "0x67D36B9D", name = "EVENT_NETWORK_AWARD_CLAIMED"},
	[141007368]	    = { hash = "0x08679A08", name = "EVENT_NETWORK_LOOT_CLAIMED"},
	[-1228557305]	= { hash = "0xB6C5B407", name = "EVENT_UNIT_TEST_SCENARIO_EXIT"},
	[432140815]	    = { hash = "0x19C1F20F", name = "EVENT_HEARD_DEAD_PED_COLLISION"},
	[-650256678]	= { hash = "0xD93DDEDA", name = "EVENT_RECOVER_AFTER_KNOCKOUT"},
	[823440502]	    = { hash = "0x3114B476", name = "EVENT_PRE_MELEE_KILL"},
	[-1155600422]	= { hash = "0xBB1EEFDA", name = "EVENT_SEEN_TERRIFIED_PED"},
	[-2031131186]	= { hash = "0x86EF65CE", name = "EVENT_MOUNT_DAMAGED_BY_PLAYER"},
	[1501535693]	= { hash = "0x597F9DCD", name = "EVENT_NEARBY_AMBIENT_THREAT"},
	[-2129179673]	= { hash = "0x81174BE7", name = "EVENT_CALM_HORSE"},
	[-1961481354]	= { hash = "0x8B162B76", name = "EVENT_CALL_FOR_COVER"},
	[2012933482]	= { hash = "0x77FAED6A", name = "EVENT_CAR_UNDRIVEABLE"},
	[182250203]	    = { hash = "0x0ADCEADB", name = "EVENT_CLIMB_LADDER_ON_ROUTE"},
	[1586716140]	= { hash = "0x5E935DEC", name = "EVENT_CLIMB_NAVMESH_ON_ROUTE"},
	[413931470]	    = { hash = "0x18AC17CE", name = "EVENT_COMBAT_TAUNT"},
	[1113682948]	= { hash = "0x42617404", name = "EVENT_ENTITY_DISARMED"},
	[1794914733]	= { hash = "0x6AFC39AD", name = "EVENT_ENTITY_HOGTIED"},
	[2045969979]	= { hash = "0x79F3063B", name = "EVENT_FLUSH_TASKS"},
	[-439157431]	= { hash = "0xE5D2FD49", name = "EVENT_CLEAR_PED_TASKS"},
	[1165534493]	= { hash = "0x4578A51D", name = "EVENT_HEADSHOT_BLOCKED_BY_HAT"},
	[353377915]	    = { hash = "0x15101E7B", name = "EVENT_HOGTIED_ENTITY_PICKED_UP"},
	[-240786091]	= { hash = "0xF1A5E555", name = "EVENT_HITCHING_POST"},
	-- [-1651585854]	= { hash = "0x9D8ECCC2", name = "EVENT_HITCH_ANIMAL"}, -- when horses are created naturally this gets triggered if they are near a hitch spawn.
	[-2122443649]	= { hash = "0x817E147F", name = "EVENT_CATCH_ITEM"},
	[769834622]	    = { hash = "0x2DE2BE7E", name = "EVENT_LOCKED_DOOR"},
	[936374126]	    = { hash = "0x37CFEF6E", name = "EVENT_PEER_WINDOW"},
	[1197193638]	= { hash = "0x475BB9A6", name = "EVENT_PED_TO_CHASE"},
	[-1288743481]	= { hash = "0xB32F55C7", name = "EVENT_PED_TO_FLEE"},
	[-1538469261]	= { hash = "0xA44CD273", name = "EVENT_PERSCHAR_PED_SPAWNED"},
	[-687266558]	= { hash = "0xD7092502", name = "EVENT_PICKUP_CARRIABLE"},
	[1082572570]	= { hash = "0x4086BF1A", name = "EVENT_PLACE_CARRIABLE_ONTO_PARENT"},
	[-1241852893]	= { hash = "0xB5FAD423", name = "EVENT_CARRIABLE_VEHICLE_STOW_START"},
	[867155253]	    = { hash = "0x33AFBD35", name = "EVENT_CARRIABLE_VEHICLE_STOW_COMPLETE"},
	[1811873798]	= { hash = "0x6BFF0006", name = "EVENT_PLAYER_ANTAGONIZED_PED"},
	[-1816722641]	= { hash = "0x93B7032F", name = "EVENT_PLAYER_ESCALATED_PED"},
	[313219550]	    = { hash = "0x12AB59DE", name = "EVENT_PLAYER_GREETED_PED"},
	[-178091376]	= { hash = "0xF5628A90", name = "EVENT_PLAYER_COLLECTED_AMBIENT_PICKUP"},
	[-1312424871]	= { hash = "0xB1C5FC59", name = "EVENT_PLAYER_STRIPPED_WEAPON"},
	[-369170747]	= { hash = "0xE9FEE6C5", name = "EVENT_PLAYER_HAT_EQUIPPED"},
	[-1286831256]	= { hash = "0xB34C8368", name = "EVENT_PLAYER_HAT_KNOCKED_OFF"},
	[498393689]	    = { hash = "0x1DB4E259", name = "EVENT_PLAYER_HAT_REMOVED_AT_SHOP"},
	[2030961287]	= { hash = "0x790E0287", name = "EVENT_PED_HAT_KNOCKED_OFF"},
	[-84591983] = { hash = "0xFAF53A91", name = "EVENT_PLAYER_LOCK_ON_TARGET"},
	[1176209503]	= { hash = "0x461B885F", name = "EVENT_PLAYER_LOOK_FOCUS"},
	[-1682387274]	= { hash = "0x9BB8CEB6", name = "EVENT_PLAYER_MOUNT_WILD_HORSE"},
	[415022413]	    = { hash = "0x18BCBD4D", name = "EVENT_PLAYER_SIM_UPDATE"},
	[832287042]	    = { hash = "0x319BB142", name = "EVENT_PLAYER_ROBBED_PED"},
	[-1024103845]	= { hash = "0xC2F56A5B", name = "EVENT_REACTION_COMBAT_VICTORY"},
	[-378297983]	= { hash = "0xE973A181", name = "EVENT_REACTION_INVESTIGATE_DEAD_PED"},
	[671637744]	    = { hash = "0x280860F0", name = "EVENT_REACTION_INVESTIGATE_THREAT"},
	[1198436399]	= { hash = "0x476EB02F", name = "EVENT_SHOUT_BLOCKING_LOS"},
	[-751866762]	= { hash = "0xD32F6C76", name = "EVENT_STATIC_COUNT_REACHED_MAX"},
	[-2052708993]	= { hash = "0x85A6257F", name = "EVENT_SWITCH_2_NM_TASK"},
	[2034746601]	= { hash = "0x7947C4E9", name = "EVENT_SCENARIO_FORCE_ACTION"},
	[-818205375]	= { hash = "0xCF3B2D41", name = "EVENT_STAT_VALUE_CHANGED"},
	[-60262143] = { hash = "0xFC687901", name = "EVENT_TRANSITION_TO_HOGTIED"},
	[526946626]	    = { hash = "0x1F689142", name = "EVENT_GET_UP"},
	[-1511724297]	= { hash = "0xA5E4EAF7", name = "EVENT_LOOT"},
	[1376140891]	= { hash = "0x52063E5B", name = "EVENT_LOOT_COMPLETE"},
	[-1509407906]	= { hash = "0xA608435E", name = "EVENT_LOOT_VALIDATION_FAIL"},
	[1640116056]	= { hash = "0x61C22F58", name = "EVENT_LOOT_PLANT_START"},
	[-968272321]	= { hash = "0xC649563F", name = "EVENT_MOUNT_REACTION"},
	[-462231716]	= { hash = "0xE472E75C", name = "EVENT_SADDLE_TRANSFER"},
	[1208357138]	= { hash = "0x48061112", name = "EVENT_CARRIABLE_UPDATE_CARRY_STATE"},
	[1081092949]	= { hash = "0x40702B55", name = "EVENT_INVENTORY_ITEM_PICKED_UP"},
	[1505348054]	= { hash = "0x59B9C9D6", name = "EVENT_INVENTORY_ITEM_REMOVED"},
	[1417095237]	= { hash = "0x54772845", name = "EVENT_BUCKED_OFF"},
	[1638298852]	= { hash = "0x61A674E4", name = "EVENT_MOUNT_OVERSPURRED"},
	[71122427]	    = { hash = "0x043D3DFB", name = "EVENT_START_CONVERSATION"},
	[1652530845]	= { hash = "0x627F9E9D", name = "EVENT_STOP_CONVERSATION"},
	[-569301261]	= { hash = "0xDE1126F3", name = "EVENT_MISS_INTENDED_TARGET"},
	[-1246119244]	= { hash = "0xB5B9BAB4", name = "EVENT_PED_ANIMAL_INTERACTION"},
	[-1985279805]	= { hash = "0x89AB08C3", name = "EVENT_CALM_PED"},
	[1327216456]	= { hash = "0x4F1BB748", name = "EVENT_PED_WHISTLE"},
	[1473676746]	= { hash = "0x57D685CA", name = "EVENT_PLAYER_DEBUG_TELEPORTED"},
	[218595333]	    = { hash = "0x0D078005", name = "EVENT_HORSE_BROKEN"},
	[-895552461]	= { hash = "0xCA9EF433", name = "EVENT_PICKUP_SPAWNED"},
	[-1936963085]	= { hash = "0x8C8C49F3", name = "EVENT_DEBUG_SETUP_CUTSCENE_WORLD_STATE"},
	[-1373728085]	= { hash = "0xAE1E92AB", name = "EVENT_WAIT_FOR_INTERACTION"},
	[-617453104]	= { hash = "0xDB3269D0", name = "EVENT_CHALLENGE_REWARD"},
	[-2091944374]	= { hash = "0x834F764A", name = "EVENT_CALCULATE_LOOT"},
	[-1730772208]	= { hash = "0x98D68310", name = "EVENT_OBJECT_INTERACTION"},
	[1352063587]	= { hash = "0x5096DA63", name = "EVENT_CONTAINER_INTERACTION"},
	[2099179610]	= { hash = "0x7D1EF05A", name = "EVENT_ITEM_PROMPT_INFO_REQUEST"},
	[-582361627]	= { hash = "0xDD49DDE5", name = "EVENT_CARRIABLE_PROMPT_INFO_REQUEST"},
	[1553659161]	= { hash = "0x5C9AF519", name = "EVENT_REVIVE_ENTITY"},
	[1784289253]	= { hash = "0x6A5A17E5", name = "EVENT_TRIGGERED_ANIMAL_WRITHE"},
	[1655597605]	= { hash = "0x62AE6A25", name = "EVENT_PLAYER_HORSE_AGITATED_BY_ANIMAL"},
	--[1351025667]	= { hash = "0x50870403", name = "EVENT_CHALLENGE_GOAL_COMPLETE"},
	--[1669410864]	= { hash = "0x63813030", name = "EVENT_CHALLENGE_GOAL_UPDATE"}, -- This one is always running : assuming its for a player steps challenge
	[-1482146560]	= { hash = "0xA7A83D00", name = "EVENT_NETWORK_PLAYER_JOIN_SESSION"},
	[1697477512]	= { hash = "0x652D7388", name = "EVENT_NETWORK_PLAYER_LEFT_SESSION"},
	[-2001102517]	= { hash = "0x88B9994B", name = "EVENT_NETWORK_PLAYER_JOIN_SCRIPT"},
	[-437497832]	= { hash = "0xE5EC5018", name = "EVENT_NETWORK_PLAYER_LEFT_SCRIPT"},
	[-857756425]	= { hash = "0xCCDFACF7", name = "EVENT_NETWORK_SESSION_MERGE_START"},
	[-2119801478]	= { hash = "0x81A6657A", name = "EVENT_NETWORK_SESSION_MERGE_END"},
	[1434205464]	= { hash = "0x557C3D18", name = "EVENT_NETWORK_PLAYER_SPAWN"},
	[-454144443]	= { hash = "0xE4EE4E45", name = "EVENT_NETWORK_PLAYER_COLLECTED_PICKUP"},
	[1274067014]	= { hash = "0x4BF0B846", name = "EVENT_NETWORK_PLAYER_COLLECTED_PORTABLE_PICKUP"},
	[-843924932]	= { hash = "0xCDB2BA3C", name = "EVENT_NETWORK_PLAYER_DROPPED_PORTABLE_PICKUP"},
	[1121131740]	= { hash = "0x42D31CDC", name = "EVENT_NETWORK_EXTENDED_INVITE"},
	[1793200955]	= { hash = "0x6AE2133B", name = "EVENT_NETWORK_PED_DISARMED"},
	[1342634267]	= { hash = "0x5006F91B", name = "EVENT_NETWORK_PED_HAT_SHOT_OFF"},
	[1626145032]	= { hash = "0x60ED0108", name = "EVENT_NETWORK_PLAYER_MISSED_SHOT"},
	[1355399116]	= { hash = "0x50C9BFCC", name = "EVENT_NETWORK_PLAYER_SIGNED_OFFLINE"},
	[-1373301352]	= { hash = "0xAE251598", name = "EVENT_NETWORK_PLAYER_SIGNED_ONLINE"},
	[163683216]	    = { hash = "0x09C19B90", name = "EVENT_NETWORK_SIGN_IN_STATE_CHANGED"},
	[239947537]	    = { hash = "0x0E4D4F11", name = "EVENT_NETWORK_SIGN_IN_START_NEW_GAME"},
	[-1688530399]	= { hash = "0x9B5B1221", name = "EVENT_NETWORK_NETWORK_ROS_CHANGED"},
	[-526667468]	= { hash = "0xE09BB134", name = "EVENT_NETWORK_BAIL_DECISION_PENDING"},
	[701022886]	    = { hash = "0x29C8C2A6", name = "EVENT_NETWORK_BAIL_DECISION_MADE"},
	[-467733578]	= { hash = "0xE41EF3B6", name = "EVENT_NETWORK_HOST_MIGRATION"},
	[995882143]	    = { hash = "0x3B5BF49F", name = "EVENT_NETWORK_IS_VOLUME_EMPTY_RESULT"},
	[557673123]	    = { hash = "0x213D6AA3", name = "EVENT_NETWORK_CHEAT_TRIGGERED"},
	[-1315570756]	= { hash = "0xB195FBBC", name = "EVENT_NETWORK_DAMAGE_ENTITY"},
	[676208328]	    = { hash = "0x284E1EC8", name = "EVENT_NETWORK_INCAPACITATED_ENTITY"},
	[-111015184]	= { hash = "0xF9620AF0", name = "EVENT_NETWORK_KNOCKEDOUT_ENTITY"},
	[-1171710795]	= { hash = "0xBA291CB5", name = "EVENT_NETWORK_REVIVED_ENTITY"},
	[2143094135]	= { hash = "0x7FBD0577", name = "EVENT_NETWORK_PLAYER_ARREST"},
	[1660856426]	= { hash = "0x62FEA86A", name = "EVENT_NETWORK_TIMED_EXPLOSION"},
	[1373658008]	= { hash = "0x51E05B98", name = "EVENT_NETWORK_PRIMARY_CREW_CHANGED"},
	[-1315453179]	= { hash = "0xB197C705", name = "EVENT_NETWORK_CREW_JOINED"},
	[1194448728]	= { hash = "0x4731D758", name = "EVENT_NETWORK_CREW_LEFT"},
	[1028782110]	= { hash = "0x3D51F81E", name = "EVENT_NETWORK_CREW_INVITE_RECEIVED"},
	[1234888675]	= { hash = "0x499AE7E3", name = "EVENT_NETWORK_CREW_CREATION"},
	[2114586158]	= { hash = "0x7E0A062E", name = "EVENT_NETWORK_CREW_DISBANDED"},
	[1068922597]	= { hash = "0x3FB676E5", name = "EVENT_VOICE_SESSION_STARTED"},
	[-231390325]	= { hash = "0xF235438B", name = "EVENT_VOICE_SESSION_ENDED"},
	[295704064]	    = { hash = "0x11A01600", name = "EVENT_VOICE_CONNECTION_REQUESTED"},
	[980298223]	    = { hash = "0x3A6E29EF", name = "EVENT_VOICE_CONNECTION_RESPONSE"},
	[-1905067041]	= { hash = "0x8E72FBDF", name = "EVENT_VOICE_CONNECTION_TERMINATED"},
	[904763044]	    = { hash = "0x35ED96A4", name = "EVENT_CLOUD_FILE_RESPONSE"},
	[1385704366]	= { hash = "0x52982BAE", name = "EVENT_NETWORK_PICKUP_RESPAWNED"},
	[1415355908]	= { hash = "0x545C9E04", name = "EVENT_NETWORK_PRESENCE_STAT_UPDATE"},
	[2108920557]	= { hash = "0x7DB392ED", name = "EVENT_NETWORK_INBOX_MSGS_RCVD"},
	[-1485628607]	= { hash = "0xA7731B41", name = "EVENT_NETWORK_ATTEMPT_HOST_MIGRATION"},
	[545528824]	    = { hash = "0x20841BF8", name = "EVENT_NETWORK_INCREMENT_STAT"},
	[1658389497]	= { hash = "0x62D903F9", name = "EVENT_NETWORK_SESSION_EVENT"},
	[753021595]	    = { hash = "0x2CE2329B", name = "EVENT_NETWORK_CREW_KICKED"},
	[-725272239]	= { hash = "0xD4C53951", name = "EVENT_NETWORK_ROCKSTAR_INVITE_RECEIVED"},
	[543140406]	    = { hash = "0x205FAA36", name = "EVENT_NETWORK_ROCKSTAR_INVITE_REMOVED"},
	[-2095977185]	= { hash = "0x8311ED1F", name = "EVENT_NETWORK_PLATFORM_INVITE_ACCEPTED"},
	[904577075]	    = { hash = "0x35EAC033", name = "EVENT_NETWORK_INVITE_RESULT"},
	[809652668]	    = { hash = "0x304251BC", name = "EVENT_NETWORK_INVITE_RESPONSE"},
	[516249386]	    = { hash = "0x1EC5572A", name = "EVENT_NETWORK_JOIN_REQUEST_TIMED_OUT"},
	[1860341470]	= { hash = "0x6EE28EDE", name = "EVENT_NETWORK_INVITE_UNAVAILABLE"},
	[1827342969]	= { hash = "0x6CEB0A79", name = "EVENT_NETWORK_CASH_TRANSACTION_LOG"},
	[-1308368394]	= { hash = "0xB203E1F6", name = "EVENT_NETWORK_CREW_RANK_CHANGE"},
	[1832265142]	= { hash = "0x6D3625B6", name = "EVENT_NETWORK_VEHICLE_UNDRIVABLE"},
	[1890598297]	= { hash = "0x70B03D99", name = "EVENT_NETWORK_PRESENCE_TRIGGER"},
	[-1002640900]	= { hash = "0xC43CE9FC", name = "EVENT_NETWORK_PRESENCE_EMAIL"},
	[-1325700282]	= { hash = "0xB0FB6B46", name = "EVENT_NETWORK_SPECTATE_LOCAL"},
	[-684883982]	= { hash = "0xD72D7FF2", name = "EVENT_NETWORK_CLOUD_EVENT"},
	[1731288223]	= { hash = "0x67315C9F", name = "EVENT_NETWORK_CASHINVENTORY_TRANSACTION"},
	[446963576]	    = { hash = "0x1AA41F78", name = "EVENT_NETWORK_CASHINVENTORY_DELETE_CHAR"},
	[-1500256914]	= { hash = "0xA693E56E", name = "EVENT_NETWORK_PERMISSION_CHECK_RESULT"},
	[587071841]	    = { hash = "0x22FE0161", name = "EVENT_NETWORK_APP_LAUNCHED"},
	[1027163239]	= { hash = "0x3D394467", name = "EVENT_NETWORK_ONLINE_PERMISSIONS_UPDATED"},
	[-1832939826]	= { hash = "0x92BF8ECE", name = "EVENT_NETWORK_SYSTEM_SERVICE_EVENT"},
	[1629782592]	= { hash = "0x61248240", name = "EVENT_NETWORK_REQUEST_DELAY"},
	[586277309]	    = { hash = "0x22F1E1BD", name = "EVENT_NETWORK_SOCIAL_CLUB_ACCOUNT_LINKED"},
	[-880791236]	= { hash = "0xCB80313C", name = "EVENT_NETWORK_SCADMIN_PLAYER_UPDATED"},
	[-642309294]	= { hash = "0xD9B72352", name = "EVENT_NETWORK_SCADMIN_RECEIVED_CASH"},
	[-2100213574]	= { hash = "0x82D148BA", name = "EVENT_NETWORK_CREW_INVITE_REQUEST_RECEIVED"},
	[-97516606]	    = { hash = "0xFA3003C2", name = "EVENT_NETWORK_LASSO_ATTACH"},
	[-2117667982]	= { hash = "0x81C6F372", name = "EVENT_NETWORK_LASSO_DETACH"},
	[-1065733433]	= { hash = "0xC07A32C7", name = "EVENT_NETWORK_HOGTIE_BEGIN"},
	[-919500771]	= { hash = "0xC931881D", name = "EVENT_NETWORK_HOGTIE_END"},
	[-1471622011]	= { hash = "0xA848D485", name = "EVENT_NETWORK_DRAG_PED"},
	[1727082765]	= { hash = "0x66F1310D", name = "EVENT_NETWORK_DROP_PED"},
	[-648745775]	= { hash = "0xD954ECD1", name = "EVENT_NETWORK_GANG"},
	[678947301]	    = { hash = "0x2877E9E5", name = "EVENT_NETWORK_GANG_WAYPOINT_CHANGED"},
	[2013393302]	= { hash = "0x7801F196", name = "EVENT_NETWORK_BULLET_IMPACTED_MULTIPLE_PEDS"},
	[-885048077]	= { hash = "0xCB3F3CF3", name = "EVENT_NETWORK_VEHICLE_LOOTED"},
	[-1126217932]	= { hash = "0xBCDF4734", name = "EVENT_NETWORK_MINIGAME_REQUEST_COMPLETE"},
	[1694142010]	= { hash = "0x64FA8E3A", name = "EVENT_NETWORK_BOUNTY_REQUEST_COMPLETE"},
	[212329117]	    = { hash = "0x0CA7E29D", name = "EVENT_NETWORK_FRIENDS_LIST_UPDATED"},
	[-716406075]	= { hash = "0xD54C82C5", name = "EVENT_NETWORK_FRIEND_STATUS_UPDATED"},
	[-634062504]	= { hash = "0xDA34F958", name = "EVENT_NETWORK_SC_FEED_POST_NOTIFICATION"},
	[453501714]	    = { hash = "0x1B07E312", name = "EVENT_NETWORK_HUB_UPDATE"},
	[1559647390]	= { hash = "0x5CF6549E", name = "EVENT_NETWORK_PICKUP_COLLECTION_FAILED"},
	[1725992066]	= { hash = "0x66E08C82", name = "EVENT_NETWORK_DEBUG_TOGGLE_MP"},
	[-2036121834]	= { hash = "0x86A33F16", name = "EVENT_NETWORK_PROJECTILE_ATTACHED"},
	[-231935285]	= { hash = "0xF22CF2CB", name = "EVENT_NETWORK_POSSE_CREATED"},
	[1268264445]	= { hash = "0x4B982DFD", name = "EVENT_NETWORK_POSSE_JOINED"},
	[-308071988]	= { hash = "0xEDA331CC", name = "EVENT_NETWORK_POSSE_LEFT"},
	[-421353837]	= { hash = "0xE6E2A693", name = "EVENT_NETWORK_POSSE_DISBANDED"},
	[2058084749]	= { hash = "0x7AABE18D", name = "EVENT_NETWORK_POSSE_KICKED"},
	[-1749240836]	= { hash = "0x97BCB3FC", name = "EVENT_NETWORK_POSSE_DATA_OR_MEMBERSHIP_CHANGED"},
	[415576404]	    = { hash = "0x18C53154", name = "EVENT_NETWORK_POSSE_DATA_CHANGED"},
	[1830788491]	= { hash = "0x6D1F9D8B", name = "EVENT_NETWORK_POSSE_MEMBER_JOINED"},
	[1047667690]	= { hash = "0x3E7223EA", name = "EVENT_NETWORK_POSSE_MEMBER_LEFT"},
	[-1692828063]	= { hash = "0x9B197E61", name = "EVENT_NETWORK_POSSE_MEMBER_DISBANDED"},
	[176872144]	    = { hash = "0x0A8ADAD0", name = "EVENT_NETWORK_POSSE_MEMBER_KICKED"},
	[-1578459229]	= { hash = "0xA1EA9FA3", name = "EVENT_NETWORK_POSSE_MEMBER_SET_ACTIVE"},
	[23105215]	    = { hash = "0x01608EBF", name = "EVENT_NETWORK_POSSE_LEADER_SET_ACTIVE"},
	[237247060]	    = { hash = "0x0E241A54", name = "EVENT_NETWORK_POSSE_PRESENCE_REQUEST_COMPLETE"},
	[-1513138189]	= { hash = "0xA5CF57F3", name = "EVENT_NETWORK_POSSE_STATS_READ_COMPLETE"},
	[797969925]	    = { hash = "0x2F900E05", name = "EVENT_NETWORK_POSSE_EX_INACTIVE_DISBANDED"},
	[-2020006491]	= { hash = "0x879925A5", name = "EVENT_NETWORK_POSSE_EX_ADMIN_DISBANDED"},
	[-45008988]	    = { hash = "0xFD5137A4", name = "EVENT_SCENARIO_ADD_PED"},
	[-456923784]	= { hash = "0xE4C3E578", name = "EVENT_SCENARIO_REMOVE_PED"},
	[-496141780]	= { hash = "0xE26D7A2C", name = "EVENT_SCENARIO_RELEASE_BUTTON"},
	[-843555838]	= { hash = "0xCDB85C02", name = "EVENT_SCENARIO_DESTROY_PROP"},
	[-1267317510]	= { hash = "0xB47644FA", name = "EVENT_UI_QUICK_ITEM_USED"},
	[-346212524]	= { hash = "0xEB5D3754", name = "EVENT_UI_ITEM_INSPECT_ACTIONED"},
	[-930155091]	= { hash = "0xC88EF5AD", name = "EVENT_NETWORK_CASHINVENTORY_NOTIFICATION"},
	[-921472336]	= { hash = "0xC91372B0", name = "EVENT_ERRORS_UNKNOWN_ERROR"},
	[-992702923]	= { hash = "0xC4D48E35", name = "EVENT_ERRORS_ARRAY_OVERFLOW"},
	[397004310]	    = { hash = "0x17A9CE16", name = "EVENT_ERRORS_INSTRUCTION_LIMIT"},
	[2004694700]	= { hash = "0x777D36AC", name = "EVENT_ERRORS_STACK_OVERFLOW"},
	[-1009774763]	= { hash = "0xC3D00F55", name = "EVENT_ERRORS_GLOBAL_BLOCK_INACCESSIBLE"},
	[1028822748]	= { hash = "0x3D5296DC", name = "EVENT_ERRORS_GLOBAL_BLOCK_NOT_RESIDENT"},
	[-2073820292]	= { hash = "0x8464037C", name = "EVENT_INTERACTION"},
	[1225420150]	= { hash = "0x490A6D76", name = "EVENT_INTERACTION_ACTION"},
	[-551147061]	= { hash = "0xDF2629CB", name = "EVENT_REACTION_ANALYSIS_ACTION"},
	[-1922859932]	= { hash = "0x8D637C64", name = "EVENT_ANIMAL_RESPONDED_TO_THREAT"},
	[1379175797]	= { hash = "0x52348D75", name = "EVENT_ANIMAL_TAMING_CALLOUT"},
	[-278948100]	= { hash = "0xEF5F96FC", name = "EVENT_CALL_FOR_BACKUP"},
	[-1360035949]	= { hash = "0xAEEF7F93", name = "EVENT_DEATH"},
	[-268474898]	= { hash = "0xEFFF65EE", name = "EVENT_HELP_AMBIENT_FRIEND"},
	[-1571092257]	= { hash = "0xA25B08DF", name = "EVENT_LASSO_DETACHED"},
	[579261718]	    = { hash = "0x2286D516", name = "EVENT_BOLAS_HIT"},
	[276199831]	    = { hash = "0x10767997", name = "EVENT_PED_ON_VEHICLE_ROOF"},
	[1387172233]	= { hash = "0x52AE9189", name = "EVENT_PLAYER_PROMPT_TRIGGERED"},
	[882658719]	    = { hash = "0x349C4D9F", name = "EVENT_RIDER_DISMOUNTED"},
	[282773725]	    = { hash = "0x10DAC8DD", name = "EVENT_WON_APPROACH_ELECTION"},
	[1272433714]	= { hash = "0x4BD7CC32", name = "EVENT_OWNED_ENTITY_INTERACTION"},
	[-1130756835]	= { hash = "0xBC9A051D", name = "EVENT_DAILY_CHALLENGE_STREAK_COMPLETED"},
	[-1034120588]	= { hash = "0xC25C9274", name = "EVENT_HELP_TEXT_REQUEST"},
	[-745090075]	= { hash = "0xD396D3E5", name = "EVENT_IMPENDING_SAMPLE_PROMPT"},
	[2058130545]	= { hash = "0x7AAC9471", name = "EVENT_NETWORK_PROJECTILE_NO_DAMAGE_IMPACT"},
	[1699948728]	= { hash = "0x655328B8", name = "EVENT_NETWORK_NOMINATED_GET_UPCOMING_CONTENT_RESPONSE"},
	[1588672286]	= { hash = "0x5EB1371E", name = "EVENT_NETWORK_NOMINATED_GO_TO_NEXT_CONTENT_RESPONSE"},
}