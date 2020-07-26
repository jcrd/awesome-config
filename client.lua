local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

client.connect_signal("property::floating", function (c)
    if c.floating then
        c.skip_taskbar = true
        awful.placement.centered(c)
    else
        c.skip_taskbar = false
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
