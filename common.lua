local dovetail = require("awesome-dovetail")

local function terminal(args)
    return {
        string.format("kitty %s", args or ''),
        {
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
    browser = {"qutebrowser",
        {factory="qutebrowser", firejail=true, timeout=3}},
    chromium = {"chromium-freeworld",
        {factory="chromium", timeout=3}},
    editor = terminal("vim"),
    term = terminal(),
}

common.layout = dovetail.layout.tile.horizontal.mirror

function common.hide_mouse()
    local geom = mouse.screen.geometry
    mouse.coords({x = geom.width, y = geom.height}, true)
end

return common
