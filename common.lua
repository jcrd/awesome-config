local awful = require("awful")

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
            callback = common.setmaster,
        },
    }
end

ws.clients = {
    browser = {"qutebrowser", {factory="qutebrowser", timeout=3}},
    chromium = {"chromium-freeworld", {factory="chromium", timeout=3}},
    editor = terminal("vim"),
    term = terminal(),
}

return common
