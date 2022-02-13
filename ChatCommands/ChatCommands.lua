g_lua.register();

Lines = {}
LogFile = MISC.GET_APPDATA_PATH('Cherax', 'Cherax.log')
FriendsOnly = true
PI = 3.14159265359
PI_180 = PI/180

function Asin(x)
    return g_math.sin(x*PI_180)
end

function Acos(x)
    return g_math.cos(x*PI_180)
end

function string:split(inSplitPattern, outResults)
    if not outResults then
        outResults = {}
    end
    local theStart = 1
    local theSplitStart, theSplitEnd = string.find(self, inSplitPattern, theStart)
    while theSplitStart do
        table.insert(outResults, string.sub(self, theStart, theSplitStart-1))
        theStart = theSplitEnd + 1
        theSplitStart, theSplitEnd = string.find(self, inSplitPattern, theStart)
    end
    table.insert(outResults, string.sub(self, theStart))
    return outResults
end

function Ischat(line)
    local pattern = '^%[Chat|All%] '
    local chattable = line:split(' ')
    for i, x in pairs(chattable) do
        if i == 1 then
            Date1 = x
        elseif i == 2 then
            Date = Date1 .. ' ' .. x
        elseif i == 3 then
            Rest = x
        else
            Rest = Rest .. ' ' .. x
        end
    end
    if string.find(Rest, pattern) ~= nil then
        return line:split(' wrote: ')
    else
        return false
    end
end

function Handle(player, command)
    Ped = PLAYER.GET_PLAYER_PED(player)
    if string.lower(command) == 'help' then
        if FriendsOnly and PLAYER.IS_PLAYER_FRIEND(player) == false then
            NETWORK.SEND_CHAT_MESSAGE_AS(player, 'You do not have access to this command!', false)
            goto last
        end
        NETWORK.SEND_CHAT_MESSAGE_AS(player, 'Available commands: /help | /heal | /armor | /spawn <vehicle>', false)
    elseif string.lower(command) == 'heal' then
        if FriendsOnly and PLAYER.IS_PLAYER_FRIEND(player) == false then
            NETWORK.SEND_CHAT_MESSAGE_AS(player, 'You do not have access to this command!', false)
            goto last
        end
        if PLAYER.IS_PLAYER_IN_ANY_VEHICLE(player) == true then
            NETWORK.SEND_CHAT_MESSAGE_AS(player, 'This command is only available while on foot!', false)
            goto last
        end
        local playercoords = PLAYER.GET_PLAYER_COORDS(player)
        OBJECT.CREATE_AMBIENT_PICKUP(-1888453608, playercoords.x, playercoords.y, playercoords.z, 0, 0, 0, true, true)
        OBJECT.CREATE_AMBIENT_PICKUP(-1888453608, playercoords.x, playercoords.y, playercoords.z, 0, 0, 0, true, true)
        OBJECT.CREATE_AMBIENT_PICKUP(-1888453608, playercoords.x, playercoords.y, playercoords.z, 0, 0, 0, true, true)
        NETWORK.SEND_CHAT_MESSAGE_AS(player, 'Health Replenished!', false)
    elseif string.lower(command) == 'armor' then
        if FriendsOnly and PLAYER.IS_PLAYER_FRIEND(player) == false then
            NETWORK.SEND_CHAT_MESSAGE_AS(player, 'You do not have access to this command!', false)
            goto last
        end
        if PLAYER.IS_PLAYER_IN_ANY_VEHICLE(player) == true then
            NETWORK.SEND_CHAT_MESSAGE_AS(player, 'This command is only available while on foot!', false)
            goto last
        end
        local playercoords = PLAYER.GET_PLAYER_COORDS(player)
        OBJECT.CREATE_AMBIENT_PICKUP(1274757841, playercoords.x, playercoords.y, playercoords.z, 0, 0, 0, true, true)
        NETWORK.SEND_CHAT_MESSAGE_AS(player, 'Armor Replenished!', false)
    elseif string.find(string.lower(command), '^spawn') ~= nil then
        if FriendsOnly and PLAYER.IS_PLAYER_FRIEND(player) == false then
            NETWORK.SEND_CHAT_MESSAGE_AS(player, 'You do not have access to this command!', false)
            goto last
        end
        local argtable = command:split(' ')
        for i, x in pairs(argtable) do
            if i == 1 then
                Prefix = x
            elseif i == 2 then
                Name = x
            else
                Name = Name .. ' ' .. x
            end
        end
        if Name == nil then
            NETWORK.SEND_CHAT_MESSAGE_AS(player, 'Invalid Vehicle!', false)
        else
            local hash = g_util.joaat(Name)
            if STREAMING.IS_MODEL_A_VEHICLE(hash) then
                STREAMING.REQUEST_MODEL(hash)
                while not STREAMING.HAS_MODEL_LOADED(hash) do
                    g_util.yield()
                end
                local playercoords = PLAYER.GET_PLAYER_COORDS(player)
                local playerrotation = ENTITY.GET_ENTITY_ROTATION(Ped, 0)
                local x, y = playercoords.x - (Asin(playerrotation.z) * 5), playercoords.y + (Acos(playerrotation.z) * 5)
                local vehicle = VEHICLE.CREATE_VEHICLE(hash, x, y, playercoords.z + 1, playerrotation.z, true, true, true)
                local color = math.random(0, 160)
                VEHICLE.SET_VEHICLE_COLOURS(vehicle, color, color)
                NETWORK.SEND_CHAT_MESSAGE_AS(player, 'Spawned ' .. Name .. '!', false)
            else
                NETWORK.SEND_CHAT_MESSAGE_AS(player, 'Invalid Vehicle!', false)
            end
        end
    end
::last::
end

function Main()
    for line in io.lines(LogFile) do
        for i, x in pairs(Lines) do
            if x == line then
                goto continue
            end
        end
        if Ischat(line) ~= false then
            for i, x in pairs(Ischat(line)) do
                if i == 1 then
                    Prefix = x
                elseif i == 2 then
                    Message = x
                end
            end
            for i, x in pairs(Prefix:split(' ')) do
                if i == 4 then
                    PlayerName = x
                end
            end
            table.insert(Lines, line)
            for x=0, 31 do
                local name = PLAYER.GET_PLAYER_NAME(x)
                if name == PlayerName then
                    if string.find(Message, '^/') then
                        RawCommand = Message:split('/')
                        for i, x in pairs(RawCommand) do
                            if i == 2 then
                                Command = x
                            end
                        end
                        Handle(x, Command)
                    end
                end
            end
        end
        ::continue::
    end
end

for line in io.lines(LogFile) do
    if Ischat(line) ~= false then
        table.insert(Lines, line)
    end
end

while g_isRunning do
    Main()
    g_util.yield()
end

g_lua.unregister();