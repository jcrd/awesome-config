local awful = require("awful")

local ws = require("awesome-launch.workspace")

local rofi = {}
rofi.workspace = {}
rofi.workspace.dirs = {'~/code'}

function rofi.workspace.new()
    local dirs = table.concat(rofi.workspace.dirs, ' ')
    local cmd = string.format("find %s -maxdepth 2 -name %s", dirs, ws.filename)
    cmd = cmd.." -printf '%h\n' | rofi -dmenu -p 'workspace'"
    awful.spawn.easy_async_with_shell(cmd, function (out)
        out = string.gsub(out, '\n', '')
        if out == '' then return end
        local t = ws.new(out:match("([^/]+)$"), {
            props = {layout = awful.layout.layouts[1]},
            load_workspace = out,
        })
        t:view_only()
    end)
end

return rofi
