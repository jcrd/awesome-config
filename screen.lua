local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

local launch = require("awesome-launch")
local ws = require("awesome-launch.workspace")
local dovetail = require("awesome-dovetail")
local viewport = require("awesome-viewport")

local audio = require("audio")
local common = require("common")
local globalhooks = require("globalhooks")

local myclock = wibox.widget.textclock(
    "<span size=\"smaller\" rise=\"1000\"></span> %a, %b %e  %l:%M%P")

globalhooks:add("refresh", function () myclock:force_update() end)

launch.widget.color = beautiful.color8
launch.widget.border_color = beautiful.fg_normal

local myvolumebar = audio.widget.volumebar()

function set_taglist_index(self, _, i)
    self:get_children_by_id('index_role')[1].markup = '<b> '..i..' </b>'
end

dovetail.get_tag = viewport
awful.screen.connect_for_each_screen(function (s)
    viewport.connect(s)
    ws.add("scratch", {props={
                screen=s,
                selected=true,
                volatile=false,
                layout=common.layout,
        }})

    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        widget_template = {
            {
                {
                    id = 'index_role',
                    widget = wibox.widget.textbox,
                },
                {
                    {
                        id = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    id = 'background_role',
                    widget = wibox.container.background,
                },
                layout = wibox.layout.fixed.horizontal,
            },
            layout = wibox.layout.fixed.horizontal,
            create_callback = set_taglist_index,
            update_callback = set_taglist_index,
        },
    }

    s.mystacklist = awful.widget.tasklist {
        screen = s,
        filter = dovetail.widget.tasklist.filter.stack,
        layout = {
            max_widget_size = s.geometry.width / 6,
            layout = wibox.layout.flex.horizontal,
        },
    }

    s.mymasterlist = awful.widget.tasklist {
        screen = s,
        filter = dovetail.widget.tasklist.filter.master,
        layout = {
            max_widget_size = s.geometry.width / 6,
            layout = wibox.layout.flex.horizontal,
        },
    }

    s.launchbar = launch.widget.launchbar {
        screen = s,
    }

    s.mywibox = awful.wibar({
            height = beautiful.wibar_height,
            screen = s,
        })

    s.mywibox:setup {
        s.mytaglist,
        {
            {
                s.launchbar,
                s.mystacklist,
                s.mymasterlist,
                layout = wibox.layout.fixed.horizontal,
            },
            layout = wibox.container.constraint,
            width = s.geometry.width / 2,
        },
        {
            {
                myvolumebar,
                widget = wibox.container.margin,
                left = 10,
                right = 10,
            },
            {
                {
                    myclock,
                    widget = wibox.container.margin,
                    left = 10,
                    right = 10,
                },
                widget = wibox.container.background,
                fg = beautiful.fg_focus,
                bg = beautiful.bg_focus,
            },
            layout = wibox.layout.fixed.horizontal,
        },
        layout = wibox.layout.align.horizontal,
        expand = "none",
    }
    gears.wallpaper.set(beautiful.bg_normal)
end)
