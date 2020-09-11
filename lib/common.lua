local awful = require("awful")

local hooks = require("hooks")

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

if not common.hooks then
    common.hooks = hooks.new()
end

return common
