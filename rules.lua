local awful = require("awful")
local beautiful = require("beautiful")
local ruled = require("ruled")

local bindings = require("bindings")

ruled.client.connect_signal("request::rules", function()
    ruled.client.append_rules {
        {
            id = "global",
            rule = {},
            properties = {
                border_width = beautiful.border_width,
                border_color = beautiful.border_normal,
                focus = awful.client.focus.filter,
                raise = true,
                size_hints_honor = false,
                keys = bindings.clientkeys,
                buttons = bindings.clientbtns,
                screen = awful.screen.preferred,
                placement = awful.placement.no_offscreen,
            },
        },
        {
            id = "floating",
            rule_any = {
                class = {
                    "Pinentry",
                    "Lxappearance",
                },
            },
            properties = {floating = true},
        },
    }
end)
