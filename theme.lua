local dpi = require('beautiful.xresources').apply_dpi

local font = {
    name = 'Hack',
    size = dpi(13),
}

local colors = {
    fg = '#444444',
    bg = '#fafafa',
    bg_alt = '#bcbcbc',
    focus = '#005faf',
}

return {
    font = string.format('%s %dpx', font.name, font.size),
    font_size = font.size,
    info_margins = dpi(10),
    wibar_height = dpi(20),

    master_width = 0.6,

    useless_gap = 2,
    gap_single_client = false,

    border_width = 3,
    notification_border_width = 1,

    fg_normal = colors.fg,
    bg_normal = colors.bg,
    bg_normal_alt = colors.bg_alt,
    border_normal = colors.bg,
    border_normal_floating = colors.bg_alt,
    notification_border_color = colors.fg,

    fg_focus = colors.bg,
    bg_focus = colors.focus,
    border_focus = colors.focus,

    desktop_wallpaper = colors.bg,

    clock_format = '<span size=\'smaller\' rise=\'1000\'></span> %a, %b %e  %l:%M%P',
}
