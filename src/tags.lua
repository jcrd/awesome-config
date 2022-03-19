local awful = require('awful')
local gears = require('gears')
local ruled = require('ruled')

local log = require('log')
local util = require('util')

local tags = {}

tags.rules = {}

local pending_rules = {}

local function tagbyname(n, data, s)
    s = s or awful.screen.focused()
    local t = util.tag.byname(n, s)
    if t then
        return t, false
    end
    return awful.tag.add(n, {
        screen = s,
        layout = awful.layout.layouts[1],
        volatile = true,
        icon_text = data.icon or '',
    }), true
end

local function has_focused_client(t)
    for _, c in ipairs(t:clients()) do
        if c == client.focus then
            return true
        end
    end
    return false
end

local function with_tag(func)
    return function (name)
        local data = tags.rules[name]
        if not data then
            return
        end
        local t = tags.get(name, data)
        if t then
            func(t)
        end
    end
end

local view_smart = with_tag(function (t)
    if not t.selected then
        util.tag.view_focus(t)
        return
    end

    if has_focused_client(t) then
        awful.tag.viewtoggle(t)
    else
        util.tag.focus_client(t, 'view_smart')
    end
end)

local view_only = with_tag(function (t) t:view_only() end)

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
    local t, new = tagbyname(name, data)
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
    }
end)

ruled.client.add_rule_source('tag_rule_source', function (...)
    if not process_rules(pending_rules, true, ...) then
        process_rules(tags.rules, false, ...)
    end
end)

function tags.get(name, data, s)
    local t, new = tagbyname(name, data, s)
    t.panel = data.panel
    if new and data.cmd then
        add_pending_rule(t, data)
        log.debug('[tags] Spawning client: %s', data.cmd)
        awful.spawn('systemd-run --user --scope '..data.cmd)
    end
    return t
end

function tags.keybindings()
    local ks = {}
    for name, data in pairs(tags.rules) do
        ks['M-'..data.key] = {view_smart, name}
        ks['M-S-'..data.key] = {view_only, name}
    end
    return ks
end

return tags
