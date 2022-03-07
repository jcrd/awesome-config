local awful = require('awful')

local session = require('sessiond_dbus')

local tags = require('tags')

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

local function with_tag(func)
    return function (name)
        local client = cmds.config.tags[name]
        if not client then
            return
        end
        local t = tags.get(name, client)
        if t then
            func(t)
        end
    end
end

cmds.tag = {}

function cmds.tag.view_focus(t)
    awful.tag.viewtoggle(t)

    for _, c in ipairs(t:clients()) do
        if c.self_tag_name then
            c:activate { raise = true, context = 'view_focus' }
            return
        end
    end
end

cmds.tag.view_toggle = with_tag(cmds.tag.view_focus)
cmds.tag.view_only = with_tag(function (t) t:view_only() end)

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
