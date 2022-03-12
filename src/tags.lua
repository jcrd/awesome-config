local awful = require('awful')
local gears = require('gears')
local ruled = require('ruled')

local log = require('log')
local util = require('util')

local tags = {}

tags.rules = {}

local pending_rules = {}

local function tagbyname(n, s)
    s = s or awful.screen.focused()
    local t = util.tag.byname(n, s)
    if t then
        return t, false
    end
    return awful.tag.add(n, {
        screen = s,
        layout = awful.layout.layouts[1],
        volatile = true,
    }), true
end

local function add_pending_rule(t, data)
    local n = t.name

    data.timer = gears.timer {
        timeout = 5,
        callback = function ()
            if pending_rules[n] then
                pending_rules[n] = nil
            end
        end,
    }

    pending_rules[n] = data
    data.timer:start()
end

local function handle_rule(name, data, pending, c, props, cbs)
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
    if data.panel then
        table.insert(cbs, util.client.make_panel)
    end
    if pending then
        data.timer:stop()
        pending_rules[name] = nil
    end
end

local function process_rules(ruleset, pending, c, ...)
    for name, data in pairs(ruleset) do
        if ruled.client.match(c, data.rule) then
            if not c.self_panel or data.panel then
                handle_rule(name, data, pending, c, ...)
                return true
            end
        end
    end
    return false
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

ruled.client.add_rule_source('tag_rule_source', function (...)
    if not process_rules(pending_rules, true, ...) then
        process_rules(tags.rules, false, ...)
    end
end)

function tags.get(name, data, s)
    local t, new = tagbyname(name, s)
    if new and data.cmd then
        add_pending_rule(t, data)
        log.debug('[tags] Spawning client: %s', data.cmd)
        awful.spawn(data.cmd)
    end
    return t
end

return tags
