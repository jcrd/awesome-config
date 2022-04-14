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

function util.client.toggle(c)
    if c.minimized then
        c:activate { context = 'client_toggle' }
    else
        c.minimized = true
    end
end

function util.layout.toggle(s)
    awful.layout.inc(1, s or awful.screen.focused())
end

return util
