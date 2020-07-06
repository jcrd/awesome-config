local awful = require("awful")
local beautiful = require("beautiful")
local ruled = require("ruled")

ruled.client.connect_signal("request::rules", function ()
    ruled.client.append_rule {
        id = "global",
        rule = {},
        properties = {
            focus = awful.client.focus.filter,
            raise = true,
            size_hints_honor = false,
            screen = awful.screen.preferred,
            placement = awful.placement.no_offscreen,
        },
    }

    ruled.client.append_rule {
        id = "titlebars",
        rule_any = {type = "normal"},
        properties = {titlebars_enabled = true},
    }

    ruled.client.append_rule {
        id = "floating",
        rule_any = {
            class = {
                "Pinentry",
                "Lxappearance",
            },
        },
        properties = {floating = true},
    }
end)

ruled.notification.connect_signal("request::rules", function ()
    ruled.notification.append_rule {
        rule = {},
        properties = {
            screen = awful.screen.preferred,
            implicit_timeout = 5,
        },
    }
end)
