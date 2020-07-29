local theme_assets = require("beautiful.theme_assets")
local dpi = require("beautiful.xresources").apply_dpi

local util = require('awful.util')
local my_themes_path = util.get_configuration_dir() .. "themes/"

local theme = {}

font_size = 12

theme.wibar_height = dpi(font_size + 4)
theme.master_width_factor = 0.6

theme.font_size = dpi(font_size)
theme.font_name = "Liberation Mono,Font Awesome 5 Free"
theme.font = string.format("%s %dpx", theme.font_name, theme.font_size)

-- special
theme.foreground = "#444444"
theme.background = "#fafafa"

-- black
theme.color0 = "#eeeeee"
theme.color8 = "#bcbcbc"

-- red
theme.color1 = "#af0000"
theme.color9 = "#d70000"

-- green
theme.hl_green = "#00AA00"
theme.color2 = "#008700"
theme.color10 = "#d70087"

-- yellow
theme.color3 = "#5f8700"
theme.color11 = "#8700af"

-- blue
theme.color4 = "#0087af"
theme.color12 = "#d75f00"

-- magenta
theme.color5 = "#878787"
theme.color13 = "#d75f00"

-- cyan
theme.color6 = "#005f87"
theme.color14 = "#005faf"

-- white
theme.color7 = "#444444"
theme.color15 = "#005f87"

theme.highlight = "#FFDD00"

theme.bg_normal = theme.background
theme.bg_focus = theme.color6
theme.fg_normal = theme.foreground
theme.fg_focus = theme.bg_normal

theme.useless_gap = dpi(2)
theme.gap_single_client = false

theme.border_width = dpi(2)
theme.border_normal = theme.bg_normal
theme.border_focus = theme.bg_focus
theme.border_marked = theme.color9

theme.notification_border_width = dpi(1)
theme.notification_border_color = theme.fg_normal

theme.tasklist_disable_icon = true
theme.tasklist_align = "center"

local taglist_squares_size = dpi(4)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
    taglist_squares_size, theme.fg_normal
)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
    taglist_squares_size, theme.fg_normal
)

return theme
