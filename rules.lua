local awful = require("awful")
local beautiful = require("beautiful")

local bindings = require("bindings")

awful.rules.rules = {
    {
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
        rule_any = {
            class = {
                "Pinentry",
                "Lxappearance",
            },
        },
        properties = {floating = true},
    },
}
