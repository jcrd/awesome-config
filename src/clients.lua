local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local ruled = require('ruled')
local wibox = require('wibox')
local dpi = require('beautiful.xresources').apply_dpi

require('awful.autofocus')

local ez = require('awesome-ez')

local buttons = require('buttons')
local config = require('config')
local inhibit = require('inhibit')
local util = require('util')

local options = config.options

local clients = {}

clients.rules = {}
local pending_rules = {}

awful.client.property.persist('self_panel', 'boolean')

local function inhibitor_who(rule)
    if rule.who then
        return rule.who
    end
    local who
    for _, v in pairs(rule) do
        if who then
            break
        end
        if type(v) == 'table' then
            for k, n in pairs(v) do
                if k == 'class' or k == 'instance' then
                    who = n
                    break
                end
            end
        end
    end
    return who or 'unknown'
end

local scanning_rule = {
    rule = {},
    callback = function(c)
        if c.self_panel then
            util.client.make_panel(c)
        end
    end,
}

client.connect_signal('scanning', function()
    ruled.client.append_rule(scanning_rule)
end)

client.connect_signal('scanned', function()
    ruled.client.remove_rule(scanning_rule)
end)

client.connect_signal('request::default_keybindings', function()
    awful.keyboard.append_client_keybindings(ez.keytable(config.keys.client))
end)

client.connect_signal('request::default_mousebindings', function()
    awful.mouse.append_client_mousebindings(ez.btntable(config.buttons.client))
end)

client.connect_signal('manage', function(c)
    if awesome.startup then
        if not c.size_hints.user_position
            and not c.size_hints.program_position then
            awful.placement.no_offscreen(c)
        end
    end
end)

client.connect_signal('focus', function(c)
    c.border_color = beautiful.border_focus
    c:raise()
end)

client.connect_signal('unfocus', function(c)
    c.border_color = beautiful.border_normal
    if c.floating then c:lower() end
end)

client.connect_signal('property::floating', function(c)
    if c.floating then
        awful.placement.centered(c)
        c:raise()
    end
end)

if not options.clients.allow_maximized then
    local props = {
        'maximized',
        'maximized_vertical',
        'maximized_horizontal',
    }

    for _, prop in ipairs(props) do
        client.connect_signal('property::' .. prop, function(c)
            if c[prop] then
                c[prop] = false
            end
        end)
    end
end

client.connect_signal('request::titlebars', function(c)
    local click = false
    local btns = {
        awful.button({}, 1, function()
            if click then
                click = false
                util.layout.toggle(c.screen)
            else
                click = true
                gears.timer {
                    timeout = 0.33,
                    autostart = true,
                    single_shot = true,
                    callback = function()
                        click = false
                    end,
                }
                c:activate { context = 'titlebar', action = 'mouse_move' }
            end
        end),
        awful.button({}, 3, function() util.client.toggle(c) end),
    }

    awful.titlebar(c).widget = {
        {
            layout = wibox.layout.fixed.horizontal,
        },
        {
            {
                align = 'center',
                widget = awful.titlebar.widget.titlewidget(c),
            },
            buttons = btns,
            layout = wibox.layout.flex.horizontal,
        },
        {
            {
                buttons.close(c),
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(14),
            },
            widget = wibox.container.margin,
            right = dpi(6),
        },
        layout = wibox.layout.align.horizontal,
    }
end)

ruled.client.connect_signal('request::rules', function()
    ruled.client.append_rule {
        id = 'global',
        rule = {},
        properties = {
            focus = awful.client.focus.filter,
            raise = true,
            screen = awful.screen.preferred,
            placement = awful.placement.no_offscreen,
        },
    }

    ruled.client.append_rule {
        id = 'titlebars',
        rule_any = { type = { 'normal', 'dialog' } },
        properties = { titlebars_enabled = true },
    }

    for _, r in ipairs(config.rules) do
        if r.inhibit then
            local t = type(r.inhibit)
            r.callback = inhibit.callback(inhibitor_who(r),
                (t == 'string' or t == 'table') and r.inhibit)
            r.inhibit = nil
            r.who = nil
        end
        ruled.client.append_rule(r)
    end
end)

ruled.client.add_rule_source('panel_rule_source', function(c, _, cbs)
    if c.self_panel then
        return
    end
    for cmd, data in pairs(pending_rules) do
        if ruled.client.match(c, data.rule) then
            table.insert(cbs, util.client.make_panel)
            data.timer:stop()
            pending_rules[cmd] = nil
        end
    end
end)

local function add_pending_rule(data)
    data.timer = gears.timer {
        timeout = 5,
        callback = function()
            if pending_rules[data.cmd] then
                pending_rules[data.cmd] = nil
            end
        end,
    }

    pending_rules[data.cmd] = data
    data.timer:start()
end

local function smart_spawn(data)
    local c = client.focus
    if c and ruled.client.match(c, data.rule) then
        util.client.toggle(c)
        return
    end
    local s = awful.screen.focused()
    for _, cl in ipairs(s.all_clients) do
        if ruled.client.match(cl, data.rule) then
            cl:activate { context = 'smart_spawn' }
            return
        end
    end
    if data.panel then
        add_pending_rule(data)
    end
    awful.spawn('systemd-run --user --scope ' .. data.cmd)
end

function clients.keybindings()
    local ks = {}
    for _, data in ipairs(clients.rules) do
        ks['M-' .. data.key] = { smart_spawn, data }
    end
    return ks
end

return clients
