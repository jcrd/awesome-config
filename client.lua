local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

local dovetail = require("awesome-dovetail")

local function toggle_titlebar(c, state)
    if state then
        awful.titlebar.hide(c)
    else
        awful.titlebar.show(c)
    end
end

local function filter(c)
    return function (...)
        if dovetail.layout.masterp(c) then
            return dovetail.widget.tasklist.filter.master(...)
        else
            return dovetail.widget.tasklist.filter.stack(...)
        end
    end
end

client.connect_signal("request::titlebars", function (c)
    local widget = awful.widget.tasklist {
        screen = c.screen,
        filter = filter(c),
    }
    local opts = {
        size = beautiful.wibar_height,
    }
    awful.titlebar(c, opts).widget = widget

    c:connect_signal("dovetail::master::update", function ()
        widget:emit_signal("widget::redraw_needed")
    end)
end)

client.connect_signal("property::floating", function (c)
    if c.floating then
        c.skip_taskbar = true
        awful.placement.centered(c)
    end
    toggle_titlebar(c, c.floating)
end)

client.connect_signal("property::fullscreen", function (c)
    toggle_titlebar(c, not c.fullscreen)
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
