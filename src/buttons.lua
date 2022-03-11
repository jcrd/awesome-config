local awful = require('awful')
local wibox = require('wibox')

local util  = require('util')

local btns = {}

local function btn(text, buttons)
    return wibox.widget {
        widget = wibox.widget.textbox,
        text = text,
        buttons = buttons,
    }
end

function btns.close(c)
    return btn('', {
        awful.button({}, 1, function () c:kill() end),
    })
end

function btns.max(c)
    return btn('', {
        awful.button({}, 1, function ()
            util.layout.toggle(awful.layout.suit.max, c.screen, true)
        end),
    })
end

function btns.magnify(c)
    return btn('', {
        awful.button({}, 1, function ()
            util.layout.toggle(awful.layout.suit.magnifier, c.screen, true)
        end),
    })
end

return btns
