g_lua.register()

PlayerChar = STATS.STAT_GET_INT(g_util.joaat('MPPLY_LAST_MP_CHAR'));
PlayerDeaths = 0
PlayerKills = 0
RaceLosses = 0
RaceWins = 0
MsPlayed = 0
DMlosses = 0
DMwins = 0

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

function SetTimePlayedValue(value)
    MsPlayed = value * 3600000
end

function SetTimePlayed()
    STATS.STAT_SET_INT(g_util.joaat('MP' .. PlayerChar .. '_TOTAL_PLAYING_TIME'), MsPlayed, true)
    g_gui.add_toast('Changed total playtime.')
end

function SetDeathMatchLossesValue(value)
    DMlosses = value
end

function SetDeathMatchLosses()
    STATS.STAT_SET_INT(g_util.joaat('MPPLY_TOTAL_DEATHMATCH_LOST'), DMlosses, true)
    g_gui.add_toast('Changed deathmatch losses.')
end

function SetDeathMatchWinsValue(value)
    DMwins = value
end

function SetDeathMatchWins()
    STATS.STAT_SET_INT(g_util.joaat('MPPLY_TOTAL_DEATHMATCH_WON'), DMwins, true)
    g_gui.add_toast('Changed deathmatch wins.')
end

g_gui.add_button('recovery_unlocks', 'Fast Run', UnlockFastRun)
g_gui.add_button('recovery_unlocks', 'Max Mental State', MaxMentalState)
g_gui.add_button('recovery_unlocks', 'Reset Mental State', ResetMentalState)

g_gui.add_input_int('recovery_rank', 'Playtime Hours', 0, 0, 1e10, 1, 100, SetTimePlayedValue)
g_gui.add_button('recovery_rank', 'Change Playtime', SetTimePlayed)

g_gui.add_input_int('recovery_rank', 'Player Deaths', 0, 0, 1e10, 1, 100, SetPlayerDeathsValue)
g_gui.add_button('recovery_rank', 'Change Player Deaths', SetPlayerDeaths)
g_gui.add_input_int('recovery_rank', 'Player Kills', 0, 0, 1e10, 1, 100, SetPlayerKillsValue)
g_gui.add_button('recovery_rank', 'Change Player Kills', SetPlayerKills)

g_gui.add_input_int('recovery_rank', 'Race Losses', 0, 0, 1e10, 1, 100, SetRaceLossesValue)
g_gui.add_button('recovery_rank', 'Change Race Losses', SetRaceLosses)
g_gui.add_input_int('recovery_rank', 'Race Wins', 0, 0, 1e10, 1, 100, SetRaceWinsValue)
g_gui.add_button('recovery_rank', 'Change Race Wins', SetRaceWins)

g_gui.add_input_int('recovery_rank', 'Deathmatch Losses', 0, 0, 1e10, 1, 100, SetDeathMatchLossesValue)
g_gui.add_button('recovery_rank', 'Change Deathmath Losses', SetDeathMatchLosses)
g_gui.add_input_int('recovery_rank', 'Deathmatch Wins', 0, 0, 1e10, 1, 100, SetDeathMatchWinsValue)
g_gui.add_button('recovery_rank', 'Change Deathmatch Wins', SetDeathMatchWins)

while g_isRunning do
    g_util.yield()
end

g_lua.unregister()