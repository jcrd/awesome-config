local client_mem = require('shared').client_mem

local util = {}

function util.icon_markup(i, size, rise)
    size = size or 'x-large'
    rise = rise and string.format("rise='%d'", rise) or ''
    return string.format("<span size='%s' %s>%s</span>", size, rise, i)
end

util.client = {}

function util.client.toggle(c, state)
    if state == nil then
        state = c.minimized
    end
    if state then
        c:activate { context = 'client_toggle' }
    else
        c.minimized = true
    end
end

function util.client.toggle_only(c)
    local r = client_mem.recorder()
    local n = 0
    for _, cl in ipairs(c.screen.clients) do
        if cl ~= c and not cl.minimized then
            cl.minimized = true
            n = n + 1
        end
    end
    if n > 0 or c.minimized then
        client_mem:record(r)
        util.client.toggle(c, true)
    end
end

local function minimize(cs, state, ex)
    local test = {}
    for _, c in ipairs(cs) do
        if not (ex and ex[c]) then
            c.minimized = state
            test[c] = true
        end
    end
    return test
end

function util.client.restore()
    local res, min = client_mem:restore()
    if not res then
        return
    end
    minimize(min, true, minimize(res, false))
end

return util
