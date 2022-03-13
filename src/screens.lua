local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')

local ez = require('awesome-ez')
local session = require('sessiond_dbus')

local audio = require('widgets.audio')
local config = require('config')

local clock_widget = wibox.widget.textclock(beautiful.clock_format)

session.connect_signal('PrepareForSleep', function (before)
    if not before then
        clock_widget:force_update()
    end
end)

local function info_widget(w)
    return {
        w,
        widget = wibox.container.margin,
        left = beautiful.info_margins,
        right = beautiful.info_margins,
    }
end

local info = {
    layout = wibox.layout.fixed.horizontal,
}

for _, name in ipairs(config.widgets) do
    local w
    if name == 'audio' then
        w = audio.widget.volumebar()
    elseif name == 'battery' then
        if config.options.enable_battery_widget then
            local batt = require('widgets.battery')
            batt.init {
                upower_dbus = require('upower_dbus'),
            }
            w = batt.widget.time()
        end
    elseif name == 'pomodoro' then
        local pomo = require('widgets.pomodoro')
        pomo.init {
            path = awful.util.get_configuration_dir()..'src/widgets',
            config = config.options.pomodoro,
        }
        w = pomo.widget.timer()
    end
    if w then
        table.insert(info, info_widget(w))
    end
end

table.insert(info, {
    info_widget(clock_widget),
    widget = wibox.container.background,
    fg = beautiful.fg_focus,
    bg = beautiful.bg_focus,
})

-- local function index_markup(i)
--     i = i or #awful.screen.focused().tags + 1
--     return '<b> '..i..' </b>'
-- end

-- local function set_taglist_index(self, _, i)
--     self:get_children_by_id('index_role')[1].markup = index_markup(i)
-- end

screen.connect_signal('request::desktop_decoration', function (s)
    s.mylayouts = {}

    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = function (t) return not t.panel end,
        buttons = ez.btntable(config.buttons.taglist),
    }

    s.mywibar = awful.wibar {
        screen = s,
        height = beautiful.wibar_height,
        widget = {
            {
                layout = wibox.layout.fixed.horizontal,
            },
            s.mytaglist,
            info,
            layout = wibox.layout.align.horizontal,
            expand = 'none',
        },
    }
end)

if beautiful.desktop_wallpaper then
    screen.connect_signal('request::wallpaper', function (s)
        gears.wallpaper.set(beautiful.desktop_wallpaper)
    end)
end
