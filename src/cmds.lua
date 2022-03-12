local awful = require('awful')

local session = require('sessiond_dbus')

local cmds = {}

cmds.config = {}

local function backlight_cmd(func, v, cmd)
    if type(cmd) == 'string' then
        awful.spawn(string.format(cmd, v))
    else
        local bl = session.backlights.default
        bl[func](v)
    end
end

cmds.backlight = {}

function cmds.backlight.inc(...)
    backlight_cmd('inc_brightness', ...)
end

function cmds.backlight.dec(...)
    backlight_cmd('dec_brightness', ...)
end

function cmds.screenshot(region)
    local dir = string.gsub(cmds.config.options.screenshot.dir, '~', os.getenv('HOME'))
    local path = string.format('%s/%s.%s', dir, os.date('%F-%H-%M-%S'),
        cmds.config.options.screenshot.ext)
    awful.spawn.with_shell(string.format('mkdir -p %s && import %s %s',
        dir,
        region and '' or '-window root',
        path))
end

return cmds
