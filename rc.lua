pcall(require, "luarocks.loader")

local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
require("awful.autofocus")
require("awful.remote")

beautiful.init(awful.util.get_configuration_dir()
    .. "themes/papercolor/theme.lua")

local session = require("sessiond_dbus")

local common = require("common")
local bindings = require("bindings")
require("client")
require("screen")
require("rules")

awesome.connect_signal("startup", function ()
    print("--- startup ---")
    common.hide_mouse()
end)

root.keys(bindings.globalkeys)

naughty.connect_signal("request::display", function (n)
    naughty.layout.box {notification = n}
end)

naughty.connect_signal("request::display_error", function (message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Error"..(startup and " during startup!" or "!"),
        message = message,
    }
end)

session.on_backlight_error = function (msg)
    naughty.notification {
        urgency = "critical",
        title = "session.backlights",
        message = msg,
    }
end
