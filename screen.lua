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

-- Workaround for: https://github.com/awesomeWM/awesome/issues/2780
-- With three tags, select in this order:
-- 3, 2, 3, 1, 3,
-- then close the client on tag 3, removing the volatile tag.
-- Tag 1 will have focus, press M-1 to switch to previous tag
-- (see bindings.lua) and no tag will be selected.
local function always_view_tag(s)
    s:connect_signal("tag::history::update", function (s)
        if #s.selected_tags == 0 and s.tags[1] then
            s.tags[1]:view_only()
        end
    end)
end

local function set_taglist_index(self, _, i)
    self:get_children_by_id('index_role')[1].markup = '<b> '..i..' </b>'
end

dovetail.get_tag = viewport
awful.screen.connect_for_each_screen(function (s)
    viewport.connect(s)

    always_view_tag(s)

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
