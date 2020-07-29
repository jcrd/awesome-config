local awful = require("awful")

local function terminal(args)
    return {
        string.format("kitty %s", args or ''),
        {
            callback = awful.client.setmaster,
        },
    }
end

local common = {}

common.clients = {
    browser = {"qutebrowser", {factory="qutebrowser", timeout=3}},
    chromium = {"chromium-freeworld", {factory="chromium", timeout=3}},
    editor = terminal("vim"),
    term = terminal(),
}

function common.hide_mouse()
    local geom = mouse.screen.geometry
    mouse.coords({x = geom.width, y = geom.height}, true)
end

return common
