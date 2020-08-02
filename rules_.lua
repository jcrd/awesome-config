local awful = require("awful")
local beautiful = require("beautiful")
local ruled = require("ruled")

local session = require("sessiond_dbus")

local inhibitors = {
    ["Chromium-freeworld"] = {"Netflix", "YouTube"},
}

local function uninhibit(c)
    if c.inhibit_id then
        session.uninhibit(c.inhibit_id)
        c.inhibit_id = nil
    end
end

local function toggle_inhibit(class, names)
    return function (c)
        local found
        for _, name in ipairs(names) do
            if not c.inhibit_id and c.active
                and string.find(c.name, name) == 1 then
                c.inhibit_id = session.inhibit(class, name)
                found = true
                break
            end
        end
        if not found then
            uninhibit(c)
        end
    end
end

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

    for class, names in pairs(inhibitors) do
        ruled.client.append_rule {
            id = string.format("%s inhibitor", class),
            rule = {class = class},
            callback = function (c)
                c.toggle_inhibit = toggle_inhibit(class, names)
                c:connect_signal("property::name", c.toggle_inhibit)
                c:connect_signal("property::active", c.toggle_inhibit)
                c:connect_signal("property::valid", function ()
                    if not c.valid then uninhibit(c) end
                end)
            end,
        }
    end
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
