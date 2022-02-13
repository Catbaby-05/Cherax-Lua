g_lua.register()

Formula = false
BennyOriginal = false
BennyBespoke = false

function SetFormula(value)
    if value then
        BennyOriginal = false
        BennyBespoke = false
    end
    Formula = value
end

function SetBennyOriginal(value)
    if value then
        Formula = false
        BennyBespoke = false
    end
    BennyOriginal = value
end

function SetBennyBespoke(value)
    if value then
        Formula = false
        BennyOriginal = false
    end
    BennyBespoke = value
end

g_gui.add_toggle('vehicle_quick_actions', 'Formula 1 Tires', SetFormula)
g_gui.add_toggle('vehicle_quick_actions', 'Benny\'s Original Tires', SetBennyOriginal)
g_gui.add_toggle('vehicle_quick_actions', 'Benny\'s Bespoke Tires', SetBennyBespoke)

while g_isRunning do
    local vehicle = PLAYER.GET_PLAYER_VEHICLE(PLAYER.PLAYER_ID())
    if vehicle then
        if Formula then
            VEHICLE.SET_VEHICLE_WHEEL_TYPE(vehicle, 10)
        end
        if BennyOriginal then
            VEHICLE.SET_VEHICLE_WHEEL_TYPE(vehicle, 8)
        end
        if BennyBespoke then
            VEHICLE.SET_VEHICLE_WHEEL_TYPE(vehicle, 9)
        end
    end
    g_util.yield()
end

g_lua.unregister()