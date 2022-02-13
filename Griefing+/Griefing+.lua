g_lua.register()

function Asin(x)
    return g_math.sin(x*3.14159265359/180)
end

function Acos(x)
    return g_math.cos(x*3.14159265359/180)
end

function GetGriefer(PID)
    local playerped = PLAYER.GET_PLAYER_PED(PID)
    local hash = g_util.joaat('oppressor')
    local location = PLAYER.GET_PLAYER_COORDS(PID)
    local rotation = ENTITY.GET_ENTITY_ROTATION(playerped, 0)
    local x, y = location.x + (Asin(rotation.z) * 5), location.y - (Acos(rotation.z) * 5)
    STREAMING.REQUEST_MODEL(hash)
    while not STREAMING.HAS_MODEL_LOADED(hash) do
        g_util.yield()
    end
    local vehicle = VEHICLE.CREATE_VEHICLE(hash, x, y, location.z, rotation.z, true, true, true)
    ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
    VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)
    VEHICLE.SET_VEHICLE_MOD(vehicle, 10, 0, false)
    local jesushash = g_util.joaat('U_M_M_Jesus_01')
    STREAMING.REQUEST_MODEL(jesushash)
    while not STREAMING.HAS_MODEL_LOADED(jesushash) do
        g_util.yield()
    end
    local jesus = PED.CREATE_PED(0, jesushash, x, y, location.z, rotation.z, true, true)
    ENTITY.SET_ENTITY_INVINCIBLE(jesus, true)
    WEAPON.GIVE_DELAYED_WEAPON_TO_PED(jesus, 1834241177, 20, true)
    PED.SET_PED_INTO_VEHICLE(jesus, vehicle, -1)
    PED.SET_PED_COMBAT_ATTRIBUTES(jesus, 5, true)
    PED.SET_PED_COMBAT_ATTRIBUTES(jesus, 46, true)
    PED.SET_PED_COMBAT_ATTRIBUTES(jesus, 1, true)
    PED.SET_PED_COMBAT_ATTRIBUTES(jesus, 3, false)
    PED.SET_PED_COMBAT_ATTRIBUTES(jesus, 1424, true)
    TASK.TASK_COMBAT_PED(jesus, playerped, 0, 16)
end

Players = {}

function SetSpawn(value, PID)
    Players[PID] = value
end

function Spawn(PID)
    local playerped = PLAYER.GET_PLAYER_PED(PID)
    local location = PLAYER.GET_PLAYER_COORDS(PID)
    local rotation = ENTITY.GET_ENTITY_ROTATION(playerped, 0)
    local womanhash = g_util.joaat('A_F_Y_Topless_01')
    STREAMING.REQUEST_MODEL(womanhash)
    while not STREAMING.HAS_MODEL_LOADED(womanhash) do
        g_util.yield()
    end
    local woman = PED.CREATE_PED(0, womanhash, location.x, location.y, location.z, rotation.z, true, true)
    PED.SET_PED_COMBAT_ATTRIBUTES(woman, 5, true)
    PED.SET_PED_COMBAT_ATTRIBUTES(woman, 46, true)
    TASK.TASK_COMBAT_PED(woman, playerped, 0, 16)
end

for i=0, 31 do
    g_gui.add_button('player_options_griefing_' .. i, 'Spawn Extreme Griefer Jesus', function() GetGriefer(g_util.get_selected_player()) end)
    g_gui.add_toggle('player_options_griefing_' .. i, 'Spawn Angry Naked Women', function(value) SetSpawn(value, g_util.get_selected_player()) end)
end

while g_isRunning do
    for i=0, 31 do
        local value = Players[i]
        if value then
            Spawn(i)
        end
    end
    g_util.yield()
end

g_lua.unregister()