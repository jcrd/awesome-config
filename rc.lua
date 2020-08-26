local log = require("log")

log.debug('starting...')

if not pcall(require, "luarocks.loader") then
    local d = string.format(';%s/.luarocks/share/lua/5.3', os.getenv('HOME'))
    package.path = package.path..d..'/?.lua'..d..'/?/init.lua'
end

local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
require("awful.autofocus")
require("awful.remote")

beautiful.init(awful.util.get_configuration_dir()
    .. "themes/papercolor/theme.lua")

local session = require("sessiond_dbus")

local common = require("common")
require("screen_")
require("rules_")
require("client_")
require("bindings_")

awesome.connect_signal("startup", function ()
    log.debug('started')
    common.hide_mouse()
end)

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
