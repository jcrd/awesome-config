local log = {}

local debug = os.getenv('AWESOME_DEBUG')

setmetatable(log, {__call = function (_, msg, ...)
    print(string.format(msg, ...))
end})

function log.debug(msg, ...)
    if debug then
        log('[debug] '..msg, ...)
    end
end

return log
