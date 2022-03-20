local awful = require('awful')
local beautiful = require('beautiful')
local ruled = require('ruled')
local wibox = require('wibox')
local dpi = require('beautiful.xresources').apply_dpi

require('awful.autofocus')

local ez = require('awesome-ez')

local buttons = require('buttons')
local config = require('config')
local inhibit = require('inhibit')
local tags = require('tags')
local util= require('util')

local options = config.options

awful.client.property.persist('self_tag_name', 'string')
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
    callback = function (c)
        if c.self_tag_name then
            local t = tags.get(c.self_tag_name)
            c:tags({t})
        end
        if c.self_panel then
            util.client.make_panel(c)
        end
    end,
}

client.connect_signal('scanning', function ()
    ruled.client.append_rule(scanning_rule)
end)

client.connect_signal('scanned', function ()
    ruled.client.remove_rule(scanning_rule)
end)

client.connect_signal('request::default_keybindings', function ()
    awful.keyboard.append_client_keybindings(ez.keytable(config.keys.client))
end)

client.connect_signal('request::default_mousebindings', function ()
    awful.mouse.append_client_mousebindings(ez.btntable(config.buttons.client))
end)

client.connect_signal('manage', function (c)
    if awesome.startup then
        if not c.size_hints.user_position
            and not c.size_hints.program_position then
            awful.placement.no_offscreen(c)
        end
    end
end)

client.connect_signal('focus', function (c)
    c.border_color = beautiful.border_focus
    c:raise()
end)

client.connect_signal('unfocus', function (c)
    c.border_color = beautiful.border_normal
    if c.floating then c:lower() end
end)

client.connect_signal('property::floating', function (c)
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
        client.connect_signal('property::'..prop, function (c)
            if c[prop] then
                c[prop] = false
            end
        end)
    end
end

client.connect_signal('request::titlebars', function (c)
    local btns = ez.btntable(config.buttons.titlebar(c))

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
                buttons.hide(c),
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

ruled.client.connect_signal('request::rules', function ()
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
