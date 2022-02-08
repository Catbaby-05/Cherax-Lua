g_lua.register();

Lines = {}
LogFile = MISC.GET_APPDATA_PATH('Cherax', 'Cherax.log')

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

function Islog(line)
    local pattern = '^%[Info%] '
    local logtable = line:split(' ')
    for i, x in pairs(logtable) do
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
        local pattern2 = 'host%.$'
        if string.find(Rest, pattern2) == nil then
            local pattern3 = 'session$'
            if string.find(Rest, pattern3) == nil then
                local pattern4 = 'Info$'
                if string.find(Rest, pattern4) == nil then
                    local resttable = Rest:split(' ')
                    for i, x in pairs(resttable) do
                        if i == 1 then
                            Infotag = x
                        elseif i == 2 then
                            Message = x
                        else
                            Message = Message .. ' ' .. x
                        end
                    end
                    return Message
                else
                    return false
                end
            else
                return false
            end
        else
            return false
        end
    else
        return false
    end
end

function Main()
    for line in io.lines(LogFile) do
        for i, x in pairs(Lines) do
            if x == line then
                goto continue
            end
        end
        if Islog(line) ~= false then
            table.insert(Lines, line)
            NETWORK.SEND_CHAT_MESSAGE(Islog(line), false)
        end
    ::continue::
    end
end

for line in io.lines(LogFile) do
    if Islog(line) ~= false then
        table.insert(Lines, line)
    end
end

while g_isRunning do
    Main()
    g_util.yield(100)
end