local awful = require("awful")
local beautiful = require("beautiful")
local ruled = require("ruled")

local inhibit = require("inhibit")

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
        id = "floating",
        rule_any = {
            class = {
                "Pinentry",
                "Lxappearance",
            },
        },
        properties = {floating = true},
    }

    ruled.client.append_rule {
        id = "chromium inhibitor",
        rule = {class = "Chromium-freeworld"},
        callback = inhibit.callback("chromium", "Netflix", "YouTube"),
    }

    ruled.client.append_rule {
        id = "mpv inhibitor",
        rule = {class = "mpv"},
        callback = inhibit.callback("mpv"),
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
