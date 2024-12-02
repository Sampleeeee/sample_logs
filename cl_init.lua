--[[Citizen.CreateThread(function()
    local isDead = false
    local hasBeenDead = false
	local diedAt

    while true do
        Wait(0)

        local player = PlayerId()

        if NetworkIsPlayerActive(player) then
            local ped = PlayerPedId()

            if IsPedFatallyInjured(ped) and not isDead then
                isDead = true
                if not diedAt then
                	diedAt = GetGameTimer()
                end

                local killer = PlayerPedId()
				local killerentitytype = GetEntityType(killer)
                local killerweapon = nil
				local killertype = -1
				local killerinvehicle = false
				local killervehiclename = ''
                local killervehicleseat = 0
				if killerentitytype == 1 then
					killertype = GetPedType(killer)
					if IsPedInAnyVehicle(killer, false) == 1 then
						killerinvehicle = true
						killervehiclename = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(killer)))
                        killervehicleseat = GetPedVehicleSeat(killer)
					else killerinvehicle = false
					end
				end

				local killerid = GetPlayerServerId(killer)
				if killer ~= ped and killerid ~= nil and NetworkIsPlayerActive(killerid) then killerid = GetPlayerServerId(killerid)
				else killerid = -1
				end

                if killer == ped or killer == -1 then
                    TriggerServerEvent('sample_logs:OnPlayerDied', killertype, { table.unpack(GetEntityCoords(ped)) })
                    hasBeenDead = true
                else
                    TriggerServerEvent('sample_logs:OnPlayerKilled', killerid, {killertype=killertype, weaponhash = killerweapon, killerinveh=killerinvehicle, killervehseat=killervehicleseat, killervehname=killervehiclename, killerpos={table.unpack(GetEntityCoords(ped))}})
                    hasBeenDead = true
                end
            elseif not IsPedFatallyInjured(ped) then
                isDead = false
                diedAt = nil
            end

            -- check if the player has to respawn in order to trigger an event
            if not hasBeenDead and diedAt ~= nil and diedAt > 0 then
                TriggerServerEvent('sample_logs:OnPlayerWasted', { table.unpack(GetEntityCoords(ped)) })

                hasBeenDead = true
            elseif hasBeenDead and diedAt ~= nil and diedAt <= 0 then
                hasBeenDead = false
            end
        end
    end
end)]]--

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local p = PlayerPedId()

        if IsEntityDead(p) then
            Citizen.Wait(500)

            local killer = PlayerId()
            local vehicle = false
            local pedKiller = GetPedSourceOfDeath(p)
            local causeHash = GetPedCauseOfDeath(p)
            local weapon = WEAPONS[tostring(causeHash)]

            if IsEntityAPed(pedKiller) and IsPedAPlayer(pedKiller) then
                killer = NetworkGetPlayerIndexFromPed(pedKiller)
            elseif IsEntityAVehicle(pedKiller) then
                local driver = GetPedInVehicleSeat(pedKiller, -1)

                if IsEntityAPed(driver) and IsPedAPlayer(driver) then
                    killer = NetworkGetPlayerIndexFromPed(driver)
                    vehicle = VehToNet(pedKiller)
                end
            end

            local coords = GetEntityCoords(p)
            TriggerServerEvent('sample_logs:OnPlayerKilled', GetPlayerServerId(killer), weapon, vehicle, coords, GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z)))
        end

        while IsEntityDead(PlayerPedId()) do
			Citizen.Wait(0)
		end
    end
end)


WEAPONS = {
    [tostring(`WEAPON_UNARMED`)] = 'Unarmed',
    [tostring(`WEAPON_KNIFE`)] = 'Knife',
    [tostring(`WEAPON_NIGHTSTICK`)] = 'Nightstick',
    [tostring(`WEAPON_HAMMER`)] = 'Hammer',
    [tostring(`WEAPON_BAT`)] = 'Baseball Bat',
    [tostring(`WEAPON_GOLFCLUB`)] = 'Golf Club',
    [tostring(`WEAPON_CROWBAR`)] = 'Crowbar',
    [tostring(`WEAPON_PISTOL`)] = 'Pistol',
    [tostring(`WEAPON_COMBATPISTOL`)] = 'Combat Pistol',
    [tostring(`WEAPON_APPISTOL`)] = 'AP Pistol',
    [tostring(`WEAPON_PISTOL50`)] = 'Pistol .50',
    [tostring(`WEAPON_MICROSMG`)] = 'Micro SMG',
    [tostring(`WEAPON_SMG`)] = 'SMG',
    [tostring(`WEAPON_ASSAULTSMG`)] = 'Assault SMG',
    [tostring(`WEAPON_ASSAULTRIFLE`)] = 'Assault Rifle',
    [tostring(`WEAPON_CARBINERIFLE`)] = 'Carbine Rifle',
    [tostring(`WEAPON_ADVANCEDRIFLE`)] = 'Advanced Rifle',
    [tostring(`WEAPON_MG`)] = 'MG',
    [tostring(`WEAPON_COMBATMG`)] = 'Combat MG',
    [tostring(`WEAPON_PUMPSHOTGUN`)] = 'Pump Shotgun',
    [tostring(`WEAPON_SAWNOFFSHOTGUN`)] = 'Sawed-Off Shotgun',
    [tostring(`WEAPON_ASSAULTSHOTGUN`)] = 'Assault Shotgun',
    [tostring(`WEAPON_BULLPUPSHOTGUN`)] = 'Bullpup Shotgun',
    [tostring(`WEAPON_STUNGUN`)] = 'Stun Gun',
    [tostring(`WEAPON_SNIPERRIFLE`)] = 'Sniper Rifle',
    [tostring(`WEAPON_HEAVYSNIPER`)] = 'Heavy Sniper',
    [tostring(`WEAPON_REMOTESNIPER`)] = 'Remote Sniper',
    [tostring(`WEAPON_GRENADELAUNCHER`)] = 'Grenade Launcher',
    [tostring(`WEAPON_GRENADELAUNCHER_SMOKE`)] = 'Smoke Grenade Launcher',
    [tostring(`WEAPON_RPG`)] = 'RPG',
    [tostring(`WEAPON_PASSENGER_ROCKET`)] = 'Passenger Rocket',
    [tostring(`WEAPON_AIRSTRIKE_ROCKET`)] = 'Airstrike Rocket',
    [tostring(`WEAPON_STINGER`)] = 'Stinger [Vehicle]',
    [tostring(`WEAPON_MINIGUN`)] = 'Minigun',
    [tostring(`WEAPON_GRENADE`)] = 'Grenade',
    [tostring(`WEAPON_STICKYBOMB`)] = 'Sticky Bomb',
    [tostring(`WEAPON_SMOKEGRENADE`)] = 'Tear Gas',
    [tostring(`WEAPON_BZGAS`)] = 'BZ Gas',
    [tostring(`WEAPON_MOLOTOV`)] = 'Molotov',
    [tostring(`WEAPON_FIREEXTINGUISHER`)] = 'Fire Extinguisher',
    [tostring(`WEAPON_PETROLCAN`)] = 'Jerry Can',
    [tostring(`OBJECT`)] = 'Object',
    [tostring(`WEAPON_BALL`)] = 'Ball',
    [tostring(`WEAPON_FLARE`)] = 'Flare',
    [tostring(`VEHICLE_WEAPON_TANK`)] = 'Tank Cannon',
    [tostring(`VEHICLE_WEAPON_SPACE_ROCKET`)] = 'Rockets',
    [tostring(`VEHICLE_WEAPON_PLAYER_LASER`)] = 'Laser',
    [tostring(`AMMO_RPG`)] = 'Rocket',
    [tostring(`AMMO_TANK`)] = 'Tank',
    [tostring(`AMMO_SPACE_ROCKET`)] = 'Rocket',
    [tostring(`AMMO_PLAYER_LASER`)] = 'Laser',
    [tostring(`AMMO_ENEMY_LASER`)] = 'Laser',
    [tostring(`WEAPON_RAMMED_BY_CAR`)] = 'Rammed by Car',
    [tostring(`WEAPON_BOTTLE`)] = 'Bottle',
    [tostring(`WEAPON_GUSENBERG`)] = 'Gusenberg Sweeper',
    [tostring(`WEAPON_SNSPISTOL`)] = 'SNS Pistol',
    [tostring(`WEAPON_VINTAGEPISTOL`)] = 'Vintage Pistol',
    [tostring(`WEAPON_DAGGER`)] = 'Antique Cavalry Dagger',
    [tostring(`WEAPON_FLAREGUN`)] = 'Flare Gun',
    [tostring(`WEAPON_HEAVYPISTOL`)] = 'Heavy Pistol',
    [tostring(`WEAPON_SPECIALCARBINE`)] = 'Special Carbine',
    [tostring(`WEAPON_MUSKET`)] = 'Musket',
    [tostring(`WEAPON_FIREWORK`)] = 'Firework Launcher',
    [tostring(`WEAPON_MARKSMANRIFLE`)] = 'Marksman Rifle',
    [tostring(`WEAPON_HEAVYSHOTGUN`)] = 'Heavy Shotgun',
    [tostring(`WEAPON_PROXMINE`)] = 'Proximity Mine',
    [tostring(`WEAPON_HOMINGLAUNCHER`)] = 'Homing Launcher',
    [tostring(`WEAPON_HATCHET`)] = 'Hatchet',
    [tostring(`WEAPON_COMBATPDW`)] = 'Combat PDW',
    [tostring(`WEAPON_KNUCKLE`)] = 'Knuckle Duster',
    [tostring(`WEAPON_MARKSMANPISTOL`)] = 'Marksman Pistol',
    [tostring(`WEAPON_MACHETE`)] = 'Machete',
    [tostring(`WEAPON_MACHINEPISTOL`)] = 'Machine Pistol',
    [tostring(`WEAPON_FLASHLIGHT`)] = 'Flashlight',
    [tostring(`WEAPON_DBSHOTGUN`)] = 'Double Barrel Shotgun',
    [tostring(`WEAPON_COMPACTRIFLE`)] = 'Compact Rifle',
    [tostring(`WEAPON_SWITCHBLADE`)] = 'Switchblade',
    [tostring(`WEAPON_REVOLVER`)] = 'Heavy Revolver',
    [tostring(`WEAPON_FIRE`)] = 'Fire',
    [tostring(`WEAPON_HELI_CRASH`)] = 'Heli Crash',
    [tostring(`WEAPON_RUN_OVER_BY_CAR`)] = 'Run over by Car',
    [tostring(`WEAPON_HIT_BY_WATER_CANNON`)] = 'Hit by Water Cannon',
    [tostring(`WEAPON_EXHAUSTION`)] = 'Exhaustion',
    [tostring(`WEAPON_EXPLOSION`)] = 'Explosion',
    [tostring(`WEAPON_ELECTRIC_FENCE`)] = 'Electric Fence',
    [tostring(`WEAPON_BLEEDING`)] = 'Bleeding',
    [tostring(`WEAPON_DROWNING_IN_VEHICLE`)] = 'Drowning in Vehicle',
    [tostring(`WEAPON_DROWNING`)] = 'Drowning',
    [tostring(`WEAPON_BARBED_WIRE`)] = 'Barbed Wire',
    [tostring(`WEAPON_VEHICLE_ROCKET`)] = 'Vehicle Rocket',
    [tostring(`WEAPON_BULLPUPRIFLE`)] = 'Bullpup Rifle',
    [tostring(`WEAPON_ASSAULTSNIPER`)] = 'Assault Sniper',
    [tostring(`VEHICLE_WEAPON_ROTORS`)] = 'Rotors',
    [tostring(`WEAPON_RAILGUN`)] = 'Railgun',
    [tostring(`WEAPON_AIR_DEFENCE_GUN`)] = 'Air Defence Gun',
    [tostring(`WEAPON_AUTOSHOTGUN`)] = 'Automatic Shotgun',
    [tostring(`WEAPON_BATTLEAXE`)] = 'Battle Axe',
    [tostring(`WEAPON_COMPACTLAUNCHER`)] = 'Compact Grenade Launcher',
    [tostring(`WEAPON_MINISMG`)] = 'Mini SMG',
    [tostring(`WEAPON_PIPEBOMB`)] = 'Pipebomb',
    [tostring(`WEAPON_POOLCUE`)] = 'Poolcue',
    [tostring(`WEAPON_WRENCH`)] = 'Wrench',
    [tostring(`WEAPON_SNOWBALL`)] = 'Snowball',
    [tostring(`WEAPON_ANIMAL`)] = 'Animal',
    [tostring(`WEAPON_COUGAR`)] = 'Cougar',
    ["-842959696"] = "Fall Damage"
   }

