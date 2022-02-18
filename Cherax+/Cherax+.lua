g_lua.register()

PlayerChar = STATS.STAT_GET_INT(g_util.joaat('MPPLY_LAST_MP_CHAR'))
SuperSpeed = false
UnlimitedBoost = false
Formula = false
BennyOriginal = false
BennyBespoke = false
PlayerDeaths = 0
PlayerKills = 0
RaceLosses = 0
RaceWins = 0
MsPlayed = 0
DMlosses = 0
DMwins = 0
TimeInVehicles = 0
TimeInHeists = 0
FastestSpeed = 0
MoneyEarned = 0
MoneySpent = 0

function Asin(x)
    return g_math.sin(x*3.14159265359/180)
end

function Acos(x)
    return g_math.cos(x*3.14159265359/180)
end

function SetUnlimitedBoost(value)
    if not value then
       VEHICLE.SET_VEHICLE_ROCKET_BOOST_ACTIVE(PLAYER.GET_PLAYER_VEHICLE(PLAYER.PLAYER_ID()), false)
    end
    UnlimitedBoost = value
end

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

function UnlockFastRun()
    STATS.STAT_SET_INT(g_util.joaat('MP' .. PlayerChar .. '_CHAR_ABILITY_1_UNLCK'), -1, true)
    STATS.STAT_SET_INT(g_util.joaat('MP' .. PlayerChar .. '_CHAR_ABILITY_2_UNLCK'), -1, true)
    STATS.STAT_SET_INT(g_util.joaat('MP' .. PlayerChar .. '_CHAR_ABILITY_3_UNLCK'), -1, true)
    STATS.STAT_SET_INT(g_util.joaat('MP' .. PlayerChar .. '_CHAR_FM_ABILITY_1_UNLCK'), -1, true)
    STATS.STAT_SET_INT(g_util.joaat('MP' .. PlayerChar .. '_CHAR_FM_ABILITY_2_UNLCK'), -1, true)
    STATS.STAT_SET_INT(g_util.joaat('MP' .. PlayerChar .. '_CHAR_FM_ABILITY_3_UNLCK'), -1, true)
    g_gui.add_toast('Fast run unlocked.')
end

function MaxMentalState()
    STATS.STAT_SET_FLOAT(g_util.joaat('MP' .. PlayerChar .. '_PLAYER_MENTAL_STATE'), 100.0, true)
    g_gui.add_toast('Mental state set to max.')
end

function ResetMentalState()
    STATS.STAT_SET_FLOAT(g_util.joaat('MP' .. PlayerChar .. '_PLAYER_MENTAL_STATE'), 0.0, true)
    g_gui.add_toast('Mental state reset.')
end

function SetPlayerDeaths()
    if tonumber(PlayerDeaths) and tonumber(PlayerDeaths) > 0 then
        STATS.STAT_SET_INT(g_util.joaat('MPPLY_DEATHS_PLAYER'), tonumber(PlayerDeaths), true)
        g_gui.add_toast('Changed player deaths.')
    else
        g_gui.add_toast('Invalid value.')
    end
end

function SetPlayerKills()
    if tonumber(PlayerKills) and tonumber(PlayerKills) > 0 then
        STATS.STAT_SET_INT(g_util.joaat('MPPLY_KILLS_PLAYERS'), tonumber(PlayerKills), true)
        g_gui.add_toast('Changed player kills.')
    else
        g_gui.add_toast('Invalid value.')
    end
end

function SetRaceLosses()
    if tonumber(RaceLosses) and tonumber(RaceLosses) > 0 then
        STATS.STAT_SET_INT(g_util.joaat('MPPLY_TOTAL_RACES_LOST'), tonumber(RaceLosses), true)
        g_gui.add_toast('Changed race losses.')
    else
        g_gui.add_toast('Invalid value.')
    end
end

function SetRaceWins()
    if tonumber(RaceWins) and tonumber(RaceWins) > 0 then
        STATS.STAT_SET_INT(g_util.joaat('MPPLY_TOTAL_RACES_WON'), tonumber(RaceWins), true)
        g_gui.add_toast('Changed race wins.')
    else
        g_gui.add_toast('Invalid value.')
    end
end

function SetTimePlayed()
    if tonumber(MsPlayed) and tonumber(MsPlayed) > 0 then
        STATS.STAT_SET_INT(g_util.joaat('MP' .. PlayerChar .. '_TOTAL_PLAYING_TIME'), tonumber(MsPlayed) * 3600000, true)
        g_gui.add_toast('Changed total playtime.')
    else
        g_gui.add_toast('Invalid value.')
    end
end

function SetDeathMatchLosses()
    if tonumber(DMlosses) and tonumber(DMlosses) > 0 then
        STATS.STAT_SET_INT(g_util.joaat('MPPLY_TOTAL_DEATHMATCH_LOST'), tonumber(DMlosses), true)
        g_gui.add_toast('Changed deathmatch losses.')
    else
        g_gui.add_toast('Invalid value.')
    end
end

function SetDeathMatchWins()
    if tonumber(DMwins) and tonumber(DMwins) > 0 then
        STATS.STAT_SET_INT(g_util.joaat('MPPLY_TOTAL_DEATHMATCH_WON'), tonumber(DMwins), true)
        g_gui.add_toast('Changed deathmatch wins.')
    else
        g_gui.add_toast('Invalid value.')
    end
end

function SetTimeInVehicles()
    if tonumber(TimeInVehicles) and tonumber(TimeInVehicles) > 0 then
        STATS.STAT_SET_INT(g_util.joaat('MP' .. PlayerChar .. '_TIME_IN_CAR'), tonumber(TimeInVehicles) * 3600000, true)
        g_gui.add_toast('Changed time in vehicles.')
    else
        g_gui.add_toast('Invalid value.')
    end
end

function SetTimeInHeists()
    if tonumber(TimeInHeists) and tonumber(TimeInHeists) > 0 then
        STATS.STAT_SET_INT(g_util.joaat('MP' .. PlayerChar .. '_HEIST_TOTAL_TIME'), tonumber(TimeInHeists) * 3600000, true)
        g_gui.add_toast('Changed time in heists')
    else
        g_gui.add_toast('Invalid value.')
    end
end

function SetFastestSpeed()
    if tonumber(FastestSpeed) and tonumber(FastestSpeed) > 0 then
        STATS.STAT_SET_INT(g_util.joaat('MP' .. PlayerChar .. '_FASTEST_SPEED'), tonumber(FastestSpeed), true)
        g_gui.add_toast('Changed fastest speed')
    else
        g_gui.add_toast('Invalid value.')
    end
end

function SetMoneyEarned()
    if tonumber(MoneyEarned) and tonumber(MoneyEarned) > 0 then
        STATS.STAT_SET_INT(g_util.joaat('MPPLY_TOTAL_EARNED'), tonumber(MoneyEarned), true)
        g_gui.add_toast('Changed earned money.')
    else
        g_gui.add_toast('Invalid value.')
    end
end

function SetMoneySpent()
    if tonumber(MoneySpent) and tonumber(MoneySpent) > 0 then
        STATS.STAT_SET_INT(g_util.joaat('MPPLY_TOTAL_SPENT'), tonumber(MoneySpent), true)
        g_gui.add_toast('Changed spent money.')
    else
        g_gui.add_toast('Invalid value.')
    end
end

function Window()
    if g_gui.is_open() then
        g_imgui.set_next_window_size(vec2(225,300))
        if g_imgui.begin_window('Cherax+ By KaasToast', ImGuiWindowFlags_NoResize) then
            if g_imgui.begin_tab_bar('tab_bar', ImGuiTabBarFlags_None) then
                if g_imgui.begin_tab_item('Vehicle', ImGuiTabItemFlags_None) then
                    if g_imgui.begin_child('vehicle_options', vec2(), true) then
                        g_imgui.add_checkbox('Super Speed', function(value) SuperSpeed = value end)
                        g_imgui.add_checkbox('Unlimited Boost', function(value) SetUnlimitedBoost(value) end)
                        g_imgui.add_checkbox('Formula 1 Tires', function(value) SetFormula(value) end)
                        g_imgui.add_checkbox('Benny\'s Original Tires', function(value) SetBennyOriginal(value) end)
                        g_imgui.add_checkbox('Benny\'s Bespoke Tires', function(value) SetBennyBespoke(value) end)
                        g_imgui.end_child()
                    end
                    g_imgui.end_tab_item()
                end
                if g_imgui.begin_tab_item('Recovery', ImGuiTabItemFlags_None) then
                    if g_imgui.begin_child('recovery_options', vec2(), true) then
                        g_imgui.add_button('Unlock Fast Run', vec2(185,20), function() UnlockFastRun() end)
                        g_imgui.add_button('Max Mental State', vec2(185,20), function() MaxMentalState() end)
                        g_imgui.add_button('Reset Mental State', vec2(185,20), function() ResetMentalState() end)
                        g_imgui.separator()
                        g_imgui.add_input_string('##1', function(value) MsPlayed = value end)
                        g_imgui.add_button('Change Playtime In Hours', vec2(185,20), function() SetTimePlayed() end)
                        g_imgui.add_input_string('##2', function(value) TimeInVehicles = value end)
                        g_imgui.add_button('Change Time In Vehicles', vec2(185,20), function() SetTimeInVehicles() end)
                        g_imgui.add_input_string('##3', function(value) TimeInHeists = value end)
                        g_imgui.add_button('Change Time In Heists', vec2(185,20), function() SetTimeInHeists() end)
                        g_imgui.separator()
                        g_imgui.add_input_string('##4', function(value) PlayerDeaths = value end)
                        g_imgui.add_button('Change Player Deaths', vec2(185,20), function() SetPlayerDeaths() end)
                        g_imgui.add_input_string('##5', function(value) PlayerKills = value end)
                        g_imgui.add_button('Change Player Kills', vec2(185,20), function() SetPlayerKills() end)
                        g_imgui.separator()
                        g_imgui.add_input_string('##6', function(value) RaceLosses = value end)
                        g_imgui.add_button('Change Race Losses', vec2(185,20), function() SetRaceLosses() end)
                        g_imgui.add_input_string('##7', function(value) RaceWins = value end)
                        g_imgui.add_button('Change Race Wins', vec2(185,20), function() SetRaceWins() end)
                        g_imgui.separator()
                        g_imgui.add_input_string('##8', function(value) DMlosses = value end)
                        g_imgui.add_button('Change Deathmatch Losses', vec2(185,20), function() SetDeathMatchLosses() end)
                        g_imgui.add_input_string('##9', function(value) DMwins = value end)
                        g_imgui.add_button('Change Deathmatch Wins', vec2(185,20), function() SetDeathMatchWins() end)
                        g_imgui.separator()
                        g_imgui.add_input_string('##10', function(value) MoneyEarned = value end)
                        g_imgui.add_button('Change Money Earned', vec2(185,20), function() SetMoneyEarned() end)
                        g_imgui.add_input_string('##10', function(value) MoneySpent = value end)
                        g_imgui.add_button('Change Money Spent', vec2(185,20), function() SetMoneySpent() end)
                        g_imgui.separator()
                        g_imgui.add_input_string('##11', function(value) FastestSpeed = value end)
                        g_imgui.add_button('Change Fastest Speed', vec2(185,20), function() SetFastestSpeed() end)
                    end
                end
            end
        end
    end
end

g_hooking.register_D3D_hook(Window)

while g_isRunning do
    local vehicle = PLAYER.GET_PLAYER_VEHICLE(PLAYER.PLAYER_ID())
    if vehicle then
        if SuperSpeed then
            VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, 1000)
        else
            VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, 0)
        end
        if UnlimitedBoost then
            VEHICLE.SET_VEHICLE_ROCKET_BOOST_PERCENTAGE(vehicle, 100)
        end
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