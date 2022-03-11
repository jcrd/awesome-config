local awful = require('awful')
local gears = require('gears')
local ruled = require('ruled')

local log = require('log')
local util = require('util')

local tags = {}

tags.rules = {}

awful.client.property.persist('self_tag_name', 'string')

local function tagbyname(n, s)
    s = s or awful.screen.focused()
    for _, t in ipairs(s.tags) do
        if t.name == n then
            return t, false
        end
    end
    return awful.tag.add(n, {
        screen = s,
        layout = awful.layout.layouts[1],
        volatile = true,
    }), true
end

tag.connect_signal('request::default_layouts', function ()
    awful.layout.append_default_layouts {
        awful.layout.suit.tile,
        awful.layout.suit.max,
        awful.layout.suit.magnifier,
    }
end)

tag.connect_signal('property::layout', function (t)
    local lo = t.screen.mylayouts
    lo[2] = lo[1]
    lo[1] = t.layout
end)

ruled.client.add_rule_source('tag_rule_source', function (c, props, cbs)
    for name, data in pairs(tags.rules) do
        if ruled.client.match(c, data.rule) then
            log.debug('[tags] Matched client: %s, %s', c.class, c.instance)
            local t, new = tagbyname(name)
            gears.table.crush(props, {
                tag = t,
                self_tag_name = name,
            })
            if new then
                table.insert(cbs, function ()
                    util.tag.view_focus(t)
                end)
            end
            return
        end
    end
end)

function tags.get(name, cmd, s)
    local t, new = tagbyname(name, s)
    if new and cmd then
        log.debug('[tags] Spawning client: %s', cmd)
        awful.spawn(cmd)
    end
    return t
end

return tags
