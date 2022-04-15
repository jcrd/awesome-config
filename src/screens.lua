local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')
local dpi = require('beautiful.xresources').apply_dpi

local ez = require('awesome-ez')
local session = require('sessiond_dbus')

local audio = require('widgets.audio')
local clients = require('clients')
local config = require('config')
local util = require('util')

tag.connect_signal('request::default_layouts', function()
    awful.layout.append_default_layouts {
        awful.layout.suit.tile,
        awful.layout.suit.max,
    }
end)

local clock_format = util.icon_markup('', nil, -1500) .. ' %a, %b %e '
    .. util.icon_markup('', nil, -2500) .. ' %l:%M%P'

local clock_widget = wibox.widget.textclock(clock_format)

session.connect_signal('PrepareForSleep', function(before)
    if not before then
        clock_widget:force_update()
    end
end)

local pomo_icon_widget = {
    widget = wibox.widget.textbox,
    handler = function(w, a) w.markup = a .. ' ' end,
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
        audio.widget.icon_markup = function(i)
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
            path = awful.util.get_configuration_dir() .. 'src/widgets',
            config = config.options.pomodoro,
            icon_widget = pomo_icon_widget,
        }
        w = pomo.widget.timer()
    end
    if w then
        table.insert(info, info_widget(w))
    end
end

table.insert(info, info_widget(clock_widget))

local function update_tasklist(widget, c)
    local text = widget:get_children_by_id('text_background')[1]
    local bg = widget:get_children_by_id('background')[1]
    if not c.minimized then
        text.fg = beautiful.fg_focus
        bg.bg = beautiful.bg_focus
    else
        text.fg = beautiful.fg_normal
        bg.bg = beautiful.bg_normal
    end
end

screen.connect_signal('request::desktop_decoration', function(s)
    awful.tag({ 'main' }, s, awful.layout.layouts[1])

    s.mytasklist = awful.widget.tasklist {
        screen          = s,
        filter          = awful.widget.tasklist.filter.currenttags,
        buttons         = ez.btntable(config.buttons.tasklist),
        widget_template = {
            {
                {
                    {
                        id = 'text',
                        widget = wibox.widget.textbox,
                        align = 'center',
                    },
                    id = 'text_background',
                    widget = wibox.container.background,
                },
                left = dpi(10),
                right = dpi(10),
                widget = wibox.container.margin,
            },
            id = 'background',
            widget = wibox.container.background,
            create_callback = function(self, c)
                self:get_children_by_id('text')[1].markup = clients.get_markup(c)
                update_tasklist(self, c)
            end,
            update_callback = update_tasklist,
        },
    }

    s.mywibar = awful.wibar {
        screen = s,
        height = beautiful.wibar_height,
        widget = {
            nil,
            s.mytasklist,
            info,
            layout = wibox.layout.align.horizontal,
            expand = 'none',
        },
    }
end)

if beautiful.desktop_wallpaper then
    screen.connect_signal('request::wallpaper', function(s)
        gears.wallpaper.set(beautiful.desktop_wallpaper)
    end)
end
