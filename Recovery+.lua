g_lua.register()

PlayerChar = STATS.STAT_GET_INT(g_util.joaat('MPPLY_LAST_MP_CHAR'));
PlayerDeaths = 0
PlayerKills = 0
RaceLosses = 0
RaceWins = 0

function UnlockFastRun()
    STATS.STAT_SET_INT(g_util.joaat('MP' .. PlayerChar .. '_CHAR_ABILITY_1_UNLCK'), -1, true)
    STATS.STAT_SET_INT(g_util.joaat('MP' .. PlayerChar .. '_CHAR_ABILITY_2_UNLCK'), -1, true)
    STATS.STAT_SET_INT(g_util.joaat('MP' .. PlayerChar .. '_CHAR_ABILITY_3_UNLCK'), -1, true)
    STATS.STAT_SET_INT(g_util.joaat('MP' .. PlayerChar .. '_CHAR_FM_ABILITY_1_UNLCK'), -1, true)
    STATS.STAT_SET_INT(g_util.joaat('MP' .. PlayerChar .. '_CHAR_FM_ABILITY_2_UNLCK'), -1, true)
    STATS.STAT_SET_INT(g_util.joaat('MP' .. PlayerChar .. '_CHAR_FM_ABILITY_3_UNLCK'), -1, true)
    g_gui.add_toast('Fast run unlocked.')
end

function SetPlayerDeathsValue(value)
    PlayerDeaths = value
end

function SetPlayerDeaths()
    STATS.STAT_SET_INT(g_util.joaat('MPPLY_DEATHS_PLAYER'), PlayerDeaths, true)
    g_gui.add_toast('Changed player deaths.')
end

function SetPlayerKillsValue(value)
    PlayerKills = value
end

function SetPlayerKills()
    STATS.STAT_SET_INT(g_util.joaat('MPPLY_KILLS_PLAYERS'), PlayerKills, true)
    g_gui.add_toast('Changed player kills.')
end

function SetRaceLossesValue(value)
    RaceLosses = value
end

function SetRaceLosses()
    STATS.STAT_SET_INT(g_util.joaat('MPPLY_TOTAL_RACES_LOST'), RaceLosses, true)
    g_gui.add_toast('Changed race losses.')
end

function SetRaceWinsValue(value)
    RaceWins = value
end

function SetRaceWins()
    STATS.STAT_SET_INT(g_util.joaat('MPPLY_TOTAL_RACES_WON'), RaceWins, true)
    g_gui.add_toast('Changed race wins.')
end

g_gui.add_button('recovery_unlocks', 'Fast Run', UnlockFastRun)

g_gui.add_input_int('recovery_rank', 'Player Deaths', 0, 0, 1e10, 1, 100, SetPlayerDeathsValue)
g_gui.add_button('recovery_rank', 'Change Player Deaths', SetPlayerDeaths)
g_gui.add_input_int('recovery_rank', 'Player Kills', 0, 0, 1e10, 1, 100, SetPlayerKillsValue)
g_gui.add_button('recovery_rank', 'Change Player Kills', SetPlayerKills)

g_gui.add_input_int('recovery_rank', 'Race Losses', 0, 0, 1e10, 1, 100, SetRaceLossesValue)
g_gui.add_button('recovery_rank', 'Change Race Losses', SetRaceLosses)
g_gui.add_input_int('recovery_rank', 'Race Wins', 0, 0, 1e10, 1, 100, SetRaceWinsValue)
g_gui.add_button('recovery_rank', 'Change Race Wins', SetRaceWins)

while g_isRunning do
    g_util.yield(100)
end

g_lua.unregister()