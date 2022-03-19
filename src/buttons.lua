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
    return btn('', {
        awful.button({}, 1, function () c:kill() end),
    })
end

function btns.toggle(c)
    return btn('缾', {
        awful.button({}, 1, function () util.layout.toggle(c.screen) end),
    })
end

function btns.hide(c)
    return btn('', {
        awful.button({}, 1, function ()
            if not c.self_tag_name then
                return
            end
            local t = util.tag.byname(c.self_tag_name, c.screen)
            if t then
                awful.tag.viewtoggle(t)
            end
        end)
    })
end

return btns
