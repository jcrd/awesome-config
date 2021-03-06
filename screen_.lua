local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

local launch = require("awesome-launch")
local dovetail = require("awesome-dovetail")
local viewport = require("awesome-viewport")

local audio = require("audio")
local common = require("common")

local myclock = wibox.widget.textclock(
    "<span size=\"smaller\" rise=\"1000\"></span> %a, %b %e  %l:%M%P")

common.hooks:add("refresh", function () myclock:force_update() end)

launch.widget.color = beautiful.color8
launch.widget.border_color = beautiful.fg_normal

tag.connect_signal("request::default_layouts", function ()
    awful.layout.append_default_layouts {
        dovetail.layout.left,
        awful.layout.suit.max,
    }
end)

local info = {
    {
        audio.widget.volumebar(),
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
}

if os.getenv('CHASSIS') == 'laptop' then
    table.insert(info, 1, {
        require('battery').widget.time(),
        widget = wibox.container.margin,
        left = 10,
        right = 10,
    })
end

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
screen.connect_signal("request::desktop_decoration", function (s)
    awful.tag.add("main", {
        screen = s,
        selected = true,
        layout = awful.layout.layouts[1],
    })

    viewport.connect(s)
    always_view_tag(s)

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

    s.myclientlist = {
        {
            launch.widget.launchbar {
                screen = s,
            },
            awful.widget.tasklist {
                screen = s,
                filter = awful.widget.tasklist.filter.currenttags,
            },
            layout = wibox.layout.fixed.horizontal,
        },
        layout = wibox.container.constraint,
        width = s.geometry.width / 2,
    }

    s.mywibox = awful.wibar {
        height = beautiful.wibar_height,
        screen = s,
    }

    s.mywibox:setup {
        s.mytaglist,
        s.myclientlist,
        info,
        layout = wibox.layout.align.horizontal,
        expand = "none",
    }
end)

screen.connect_signal("request::wallpaper", function (s)
    gears.wallpaper.set(beautiful.bg_normal)
end)
