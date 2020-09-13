local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")

local ws = require("awesome-launch.workspace")

local common = require("common")

local function terminal(args)
    return {
        string.format("kitty %s", args or ''),
        {
            systemd = true,
            raise_callback = function (c)
                gears.timer.delayed_call(function ()
                    common.setmaster(c)
                end)
            end,
        },
    }
end

ws.clients = {
    browser = {"qutebrowser --target window",
        {factory="qutebrowser", systemd=true, timeout=3}},
    chromium = {"chromium-freeworld",
        {factory="chromium", systemd=true, timeout=3}},
    editor = terminal("vim"),
    term = terminal(),
}

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
    awful.client.setslave(c)
end)

client.connect_signal("focus", function (c)
    c.border_color = beautiful.border_focus
    if c.floating then c:raise() end
end)

client.connect_signal("unfocus", function (c)
    c.border_color = beautiful.border_normal
end)
