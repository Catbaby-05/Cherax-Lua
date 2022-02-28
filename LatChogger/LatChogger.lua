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

function IsLog(msg)
    return string.find(msg, '^%[Info%] ') ~= nil and string.find(msg, 'host%.$') == nil and string.find(msg, 'session$') == nil and string.find(msg, 'Info$') == nil and string.find(msg, ' is spectating ') == nil and string.find(msg, ' is no longer spectating%.$') == nil and string.find(msg, '^Kicking ') == nil and string.find(msg, '^Hooking enabled%.') == nil
end

function SendLog(line)
    Lines[line] = true
    local msg = nil
    for i, x in pairs(line:split(' ')) do
        if i == 3 then
            msg = x
        elseif i > 3 then
            msg = msg .. ' ' .. x
        end
    end
    if IsLog(msg) == true then
        local message = nil
        for i, x in pairs(msg:split(' ')) do
            if i == 2 then
                message = x
            elseif i > 2 then
                message = message .. ' ' .. x
            end
        end
        NETWORK.SEND_CHAT_MESSAGE(message, false)
    end
end

for line in io.lines(LogFile) do
    Lines[line] = true
end

while g_isRunning do
    for line in io.lines(LogFile) do
        if Lines[line] == nil then
            SendLog(line)
        end
    end
    g_util.yield(100)
end