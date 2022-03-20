local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')
local dpi = require('beautiful.xresources').apply_dpi

local ez = require('awesome-ez')
local session = require('sessiond_dbus')

local audio = require('widgets.audio')
local config = require('config')
local util = require('util')


local clock_format = util.icon_markup('', nil, -1500)..' %a, %b %e '
                   ..util.icon_markup('', nil, -2500)..' %l:%M%P'

local clock_widget = wibox.widget.textclock(clock_format)

session.connect_signal('PrepareForSleep', function (before)
    if not before then
        clock_widget:force_update()
    end
end)

local pomo_icon_widget = {
    widget = wibox.widget.textbox,
    handler = function (w, a) w.markup = a..' ' end,
    assets = {
        stopped = util.icon_markup(''),
        working = util.icon_markup(''),
        short_break = util.icon_markup(''),
        long_break = util.icon_markup(''),
    },
}

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
        audio.widget.icon_markup = function (i)
            return util.icon_markup(i, 'xx-large')
        end
        w = audio.widget.volumebar()
    elseif name == 'battery' then
        if config.options.enable_battery_widget then
            local batt = require('widgets.battery')
            batt.init {
                upower_dbus = require('upower_dbus'),
            }
            batt.widget.icon_markup = util.icon_markup
            w = batt.widget.time()
        end
    elseif name == 'pomodoro' then
        local pomo = require('widgets.pomodoro')
        pomo.init {
            path = awful.util.get_configuration_dir()..'src/widgets',
            config = config.options.pomodoro,
            icon_widget = pomo_icon_widget,
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

local function taglist_update(self, t)
    local w = self:get_children_by_id('icon_bg_role')[1]
    w.fg = t.selected and beautiful.fg_focus or beautiful.fg_normal
end

screen.connect_signal('request::desktop_decoration', function (s)
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = function (t) return not t.panel end,
        buttons = ez.btntable(config.buttons.taglist),
        widget_template = {
            {
                {
                    {
                        {
                            {
                                id = 'icon_text_role',
                                widget = wibox.widget.textbox,
                                forced_width = beautiful.font_size + dpi(2),
                            },
                            id = 'icon_bg_role',
                            widget = wibox.container.background,
                        },
                        right = dpi(4),
                        widget = wibox.container.margin,
                    },
                    {
                            id = 'text_role',
                            widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                left = dpi(6),
                right = dpi(6),
                widget = wibox.container.margin,
            },
            id = 'background_role',
            widget = wibox.container.background,
            create_callback = function (self, t)
                if t.icon_text then
                    local w = self:get_children_by_id('icon_text_role')[1]
                    w.markup = util.icon_markup(t.icon_text, 'xx-large')
                end
                taglist_update(self, t)
            end,
            update_callback = taglist_update,
        },
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
