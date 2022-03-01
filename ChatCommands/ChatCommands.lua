g_lua.register()

Lines = {}
LogFile = MISC.GET_APPDATA_PATH('Cherax', 'Cherax.log')
Everyone = false

function Asin(x)
    return g_math.sin(x*3.14159265359/180)
end

function Acos(x)
    return g_math.cos(x*3.14159265359/180)
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

function Help(player)
    if not Everyone and PLAYER.IS_PLAYER_FRIEND(player) == false then
        return
    else
        NETWORK.SEND_CHAT_MESSAGE_AS(player, 'Available commands: /help | /heal | /armor | /spawn <vehicle>', false)
    end
end

function Heal(player)
    if not Everyone and PLAYER.IS_PLAYER_FRIEND(player) == false then
        return
    elseif PLAYER.IS_PLAYER_IN_ANY_VEHICLE(player) == true then
        NETWORK.SEND_CHAT_MESSAGE_AS(player, 'This command is only available while on foot!', false)
    else
        local playercoords = PLAYER.GET_PLAYER_COORDS(player)
        OBJECT.CREATE_AMBIENT_PICKUP(-1888453608, playercoords.x, playercoords.y, playercoords.z, 0, 0, 0, true, true)
        OBJECT.CREATE_AMBIENT_PICKUP(-1888453608, playercoords.x, playercoords.y, playercoords.z, 0, 0, 0, true, true)
        OBJECT.CREATE_AMBIENT_PICKUP(-1888453608, playercoords.x, playercoords.y, playercoords.z, 0, 0, 0, true, true)
        NETWORK.SEND_CHAT_MESSAGE_AS(player, 'Health Replenished!', false)
    end
end

function Armor(player)
    if not Everyone and PLAYER.IS_PLAYER_FRIEND(player) == false then
        return
    elseif PLAYER.IS_PLAYER_IN_ANY_VEHICLE(player) == true then
        NETWORK.SEND_CHAT_MESSAGE_AS(player, 'This command is only available while on foot!', false)
    else
        local playercoords = PLAYER.GET_PLAYER_COORDS(player)
        OBJECT.CREATE_AMBIENT_PICKUP(1274757841, playercoords.x, playercoords.y, playercoords.z, 0, 0, 0, true, true)
        NETWORK.SEND_CHAT_MESSAGE_AS(player, 'Armor Replenished!', false)
    end
end

function Spawn(player, vehicle)
    if not Everyone and PLAYER.IS_PLAYER_FRIEND(player) == false then
        return
    elseif vehicle == nil then
        NETWORK.SEND_CHAT_MESSAGE_AS(player, 'Invalid Vehicle!', false)
    else
        local playerped = PLAYER.GET_PLAYER_PED(player)
        local hash = g_util.joaat(vehicle)
        if STREAMING.IS_MODEL_A_VEHICLE(hash) then
            STREAMING.REQUEST_MODEL(hash)
            while not STREAMING.HAS_MODEL_LOADED(hash) do
                g_util.yield()
            end
            local playercoords = PLAYER.GET_PLAYER_COORDS(player)
            local playerrotation = ENTITY.GET_ENTITY_ROTATION(playerped, 0)
            local x, y = playercoords.x - (Asin(playerrotation.z) * 5), playercoords.y + (Acos(playerrotation.z) * 5)
            local newvehicle = VEHICLE.CREATE_VEHICLE(hash, x, y, playercoords.z + 1, playerrotation.z, true, true, true)
            local color = math.random(0, 160)
            VEHICLE.SET_VEHICLE_COLOURS(newvehicle, color, color)
            NETWORK.SEND_CHAT_MESSAGE_AS(player, 'Spawned ' .. vehicle .. '!', false)
        else
            NETWORK.SEND_CHAT_MESSAGE_AS(player, 'Invalid Vehicle!', false)
        end
    end
end

function GetPlayer(name)
    for x=0, 31 do
        local playername = PLAYER.GET_PLAYER_NAME(x)
        if playername == name then
            return x
        end
    end
end

function IsChat(msg)
    return string.find(msg, '^%[Chat|All%] ') ~= nil
end

function IsCommand(msg)
    return string.find(msg, '^/') ~= nil
end

function HandleCommand(line)
    Lines[line] = true
    local msg = nil
    for i, x in pairs(line:split(' ')) do
        if i == 3 then
            msg = x
        elseif i > 3 then
            msg = msg .. ' ' .. x
        end
    end
    if IsChat(msg) == true then
        local name = nil
        local message = nil
        local player = nil
        for i, x in pairs(string.split(msg, ' wrote: ')) do
            if i == 1 then
                for i2, x2 in pairs(string.split(x, ' ')) do
                    if i2 == 2 then
                        name = x2
                    end
                end
            elseif i == 2 then
                message = x
            end
        end
        if IsCommand(message) == true then
            player = GetPlayer(name)
            if player ~= nil then
                Handle(player, message)
            end
        end
    end
end

function Handle(player, message)
    if string.find(string.lower(message), '^/help') ~= nil then
        Help(player)
    elseif string.find(string.lower(message), '^/heal') ~= nil then
        Heal(player)
    elseif string.find(string.lower(message), '^/armor') ~= nil then
        Armor(player)
    elseif string.find(string.lower(message), '^/spawn') ~= nil then
        local vehicle = nil
        for i, x in pairs(string.split(message, ' ')) do
            if i == 2 then
                vehicle = x
            elseif i > 2 then
                vehicle = vehicle .. ' ' .. x
            end
        end
        Spawn(player, vehicle)
    end
end

for line in io.lines(LogFile) do
    Lines[line] = true
end

g_gui.add_toggle('session_chat_commands', 'Everyone', function(value) Everyone = value end)

while g_isRunning do
    for line in io.lines(LogFile) do
        if Lines[line] == nil then
            HandleCommand(line)
        end
    end
    g_util.yield(100)
end

g_lua.unregister()