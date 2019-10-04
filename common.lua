local dovetail = require("awesome-dovetail")
local hooks = require("hooks")

local function terminal(args)
    return {
        string.format("kitty -1 %s", args or ''),
        {
            factory="kitty",
            callback=function (c)
                if not dovetail.layout.get(c.screen).centered then
                    dovetail.command.master(c)
                end
            end,
        },
    }
end

local common = {}

common.clients = {
    browser = {"/usr/bin/qutebrowser",
        {factory="qutebrowser", firejail=true, timeout=3}},
    chromium = {"/usr/bin/chromium",
        {factory="chromium", firejail=true, timeout=3}},
    editor = terminal("vim"),
    term = terminal(),
}

common.globalhooks = hooks.new()

common.layout = dovetail.layout.tile.horizontal.mirror

function common.hide_mouse()
    local geom = mouse.screen.geometry
    mouse.coords({x = geom.width, y = geom.height}, true)
end

return common
