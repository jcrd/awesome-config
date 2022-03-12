local awful = require('awful')

local util = {}

util.tag = {}
util.layout = {}

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
    util.tag.focus_client(t, 'view_focus')
end

function util.layout.toggle(lo, s, restore)
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

return util
