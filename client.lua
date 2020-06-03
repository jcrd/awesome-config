local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

local dovetail = require("awesome-dovetail")

local function filter(c)
    if dovetail.layout.masterp(c) then
        return dovetail.widget.tasklist.filter.master
    else
        return dovetail.widget.tasklist.filter.stack
    end
end

client.connect_signal("request::titlebars", function (c)
    local opts = {
        size = beautiful.wibar_height,
    }
    awful.titlebar(c, opts).widget = awful.widget.tasklist {
        screen = c.screen,
        filter = filter(c),
    }

    if not c.titlebar_requested then
        c.titlebar_requested = true
        c:connect_signal("dovetail::master::update", function (cl)
            client.emit_signal("request::titlebars", cl)
        end)
    end
end)

client.connect_signal("property::floating", function (c)
    if c.floating then
        awful.titlebar.hide(c)
        awful.placement.centered(c)
    else
        awful.titlebar.show(c)
    end
end)

client.connect_signal("manage", function (c)
    if awesome.startup then
        if not c.size_hints.user_position
            and not c.size_hints.program_position then
            awful.placement.no_offscreen(c)
        end
    end
end)

client.connect_signal("focus", function (c)
    c.border_color = beautiful.border_focus
    if c.floating then c:raise() end
end)

client.connect_signal("unfocus", function (c)
    c.border_color = beautiful.border_normal
end)
