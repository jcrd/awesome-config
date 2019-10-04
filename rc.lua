pcall(require, "luarocks.loader")

local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
require("awful.autofocus")
require("awful.remote")

beautiful.init(awful.util.get_configuration_dir()
    .. "themes/papercolor/theme.lua")

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

do
    local has_error = false
    awesome.connect_signal("debug::error", function (err)
        if not has_error then
            has_error = true
            naughty.notify({
                    preset = naughty.config.presets.critical,
                    title = "Error",
                    text = tostring(err),
                })
            has_error = false
        end
    end)
end

if awesome.startup_errors then
    naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Error during startup",
            text = awesome.startup_errors,
        })
end
