local awful = require("awful")
local gears = require("gears")

local ws = require("awesome-launch.workspace")

local common = {}

function common.setmaster(c)
    if c ~= awful.client.getmaster(c.screen) then
        awful.client.setmaster(c)
    end
end

function common.hide_mouse()
    local geom = mouse.screen.geometry
    mouse.coords({x = geom.width, y = geom.height}, true)
end

local function terminal(args)
    return {
        string.format("kitty %s", args or ''),
        {
            callback = function (c)
                gears.timer.delayed_call(function ()
                    common.setmaster(c)
                end)
            end,
        },
    }
end

ws.clients = {
    browser = {"qutebrowser --target window", {factory="qutebrowser", timeout=3}},
    chromium = {"chromium-freeworld", {factory="chromium", timeout=3}},
    editor = terminal("vim"),
    term = terminal(),
}

return common
