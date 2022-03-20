local awful = require('awful')
local wibox = require('wibox')

local util  = require('util')

local btns = {}

local function btn(text, buttons)
    return wibox.widget {
        widget = wibox.widget.textbox,
        markup = util.icon_markup(text, 'xx-large'),
        buttons = buttons,
    }
end

function btns.close(c)
    return btn('窱', {
        awful.button({}, 1, function () c:kill() end),
    })
end

function btns.hide(c)
    return btn('絛', {
        awful.button({}, 1, function () util.client.hide(c) end)
    })
end

return btns
