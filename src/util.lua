local awful = require('awful')

local util = {}

util.tag = {}
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

function util.tag.view_toggle(s)
    s = s or awful.screen.focused()
    if #s.selected_tags <= 1 then
        awful.tag.history.restore()
        return
    end
    if not (client.focus and client.focus.self_tag_name) then
        return
    end
    local t = util.tag.byname(client.focus.self_tag_name, s)
    t:view_only()
end

function util.client.make_panel(c)
    c.self_panel = true
    c.floating = true
    c.skip_taskbar = true
    awful.placement.scale(c, { to_percent = 0.5 })
    awful.placement.centered(c)
end

function util.client.hide(c)
    if not c.self_tag_name then
        return
    end
    local t = util.tag.byname(c.self_tag_name, c.screen)
    if t then
        awful.tag.viewtoggle(t)
    end
end

return util
