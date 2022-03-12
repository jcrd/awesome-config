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