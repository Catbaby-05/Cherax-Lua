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

function Ischat(line)
    local pattern = '^%[Chat|Discord%] '
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
            NETWORK.SEND_CHAT_MESSAGE('[Discord] '.. PlayerName .. ': ' .. Message, false)
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
    g_util.yield(100)
end

g_lua.unregister();