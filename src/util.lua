local awful = require('awful')

local util = {}

util.client = {}
util.layout = {}

function util.icon_markup(i, size, rise)
    size = size or 'x-large'
    rise = rise and string.format("rise='%d'", rise) or ''
    return string.format("<span size='%s' %s>%s</span>", size, rise, i)
end

function util.client.make_panel(c)
    c.self_panel = true
    c.floating = true
    c.skip_taskbar = true
    awful.placement.scale(c, { to_percent = 0.5 })
    awful.placement.centered(c)
end

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
    local n = 0
    for _, cl in ipairs(c.screen.clients) do
        if cl ~= c and not cl.minimized then
            cl.minimized = true
            n = n + 1
        end
    end
    util.client.toggle(c, n > 0 or c.minimized)
end

function util.layout.toggle(s)
    awful.layout.inc(1, s or awful.screen.focused())
end

return util
