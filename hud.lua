local naughty = require('naughty')

local hud = {}

function hud.clientinfo(c)
    c = c or client.focus
    if not c then return end
    local props = {
        valid = c.valid,
        window = c.window,
        name = c.name,
        type = c.type,
        class = c.class,
        instance = c.instance,
        screen = c.screen.index,
        startup_id = c.startup_id,
        wm_launch_id = c.wm_launch_id,
        single_instance_id = c.single_instance_id,
        cmdline = c.cmdline,
    }
    local text = ""
    for k, v in pairs(props) do
        text = text .. string.format('\n%s: %s', k, v)
    end
    naughty.notify({
            title = 'Client info',
            text = text,
            position = 'top_middle',
        })
end

return hud
