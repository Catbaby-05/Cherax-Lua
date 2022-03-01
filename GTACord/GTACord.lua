g_lua.register()

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

function IsChat(msg)
    return string.find(msg, '^%[Chat|Discord%] ') ~= nil
end

function HandleChat(line)
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
        if name ~= nil then
            NETWORK.SEND_CHAT_MESSAGE('[Discord] '.. name .. ': ' .. message, false)
        end
    end
end

for line in io.lines(LogFile) do
    Lines[line] = true
end

while g_isRunning do
    for line in io.lines(LogFile) do
        if Lines[line] == nil then
            HandleChat(line)
        end
    end
    g_util.yield(100)
end

g_lua.unregister()