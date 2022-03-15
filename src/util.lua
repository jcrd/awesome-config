local awful = require('awful')

local util = {}

util.tag = {}
util.layout = {}
util.client = {}

function util.icon_markup(i, size, rise)
    size = size or 'x-large'
    rise = rise and string.format("rise='%d'", rise) or ''
    return string.format("<span size='%s' %s>%s</span>", size, rise, i)
end

function util.tag.byname(n, s)
    for _, t in ipairs(s.tags) do
        if t.name == n then
            return t
        end
    end
end

function util.tag.focus_client(t, ctx)
    for _, c in ipairs(t:clients()) do
        if c.self_tag_name then
            c:activate { raise = true, context = ctx or 'focus_client' }
            return
        end
    end
end

function util.tag.view_focus(t)
    awful.tag.viewtoggle(t)
    if t.selected then
        util.tag.focus_client(t, 'view_focus')
    end
end

function util.layout.toggle(lo, restore, s)
    s = s or awful.screen.focused()
    if lo == s.mylayouts[1] then
        if restore then
            lo = s.mylayouts[2]
        else
            lo = awful.layout.layouts[1]
        end
    end
    awful.layout.set(lo)
end

function util.client.make_panel(c)
    c.self_panel = true
    c.floating = true
    c.skip_taskbar = true
    awful.placement.scale(c, { to_percent = 0.5 })
    awful.placement.centered(c)
end

return util
