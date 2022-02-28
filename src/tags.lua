local awful = require('awful')
local gears = require('gears')
local ruled = require('ruled')
local log = require('log')

local tags = {}

awful.client.property.persist('self_tag_name', 'string')

local function tagbyname(n, s)
    s = s or awful.screen.focused()
    for _, t in ipairs(s.tags) do
        if t.name == n then
            return t
        end
    end
end

tag.connect_signal('request::default_layouts', function ()
    awful.layout.append_default_layouts {
        awful.layout.suit.tile,
        awful.layout.suit.max,
        awful.layout.suit.magnifier,
    }
end)

local pending_rules = {}

ruled.client.add_rule_source('spawn_rule_source', function (c, props)
    for name, data in pairs(pending_rules) do
        if ruled.client.match(c, data.client.rule) then
            log.debug('[tags] Matched client: %s, %s', c.class, c.instance)
            gears.table.crush(props, data.client.properties)
            data.timer:stop()
            pending_rules[name] = nil
            return
        end
    end
end)

function tags.get(name, client, s)
    local t = tagbyname(name, s)
    if not t then
        t = awful.tag.add(name, {
            screen = s or awful.screen.focused(),
            layout = awful.layout.layouts[1],
            volatile = true,
        })
        if client then
            local data = {}

            client.properties = client.properties or {}
            client.properties.tag = t
            client.properties.self_tag_name = name

            data.client = client
            data.timer = gears.timer {
                timeout = 5,
                callback = function ()
                    if pending_rules[name] then
                        pending_rules[name] = nil
                    end
                end,
            }

            pending_rules[name] = data
            data.timer:start()

            log.debug('[tags] Spawning client: %s', client.cmd)
            awful.spawn(client.cmd)
        end
    end
    return t
end

return tags
