local awful = require('awful')

local util = {}

util.tag = {}

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

return util
