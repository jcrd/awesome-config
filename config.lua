local awful = require('awful')

local session = require('sessiond_dbus')

local cmds = require('cmds')
local audio = require('widgets.audio')
local pomo = require('widgets.pomodoro')
local util = require('util')

local c = {}
local is_laptop = os.getenv('CHASSIS') == 'laptop'

c.tags = {
    panel = {
        key = 'grave',
        cmd = 'kitty',
        rule = { instance = 'kitty' },
        panel = true,
    },
    editor = {
        icon = '',
        key = 'd',
        cmd = 'code',
        rule = { instance = 'code' },
    },
    browser = {
        icon = '',
        key = 'w',
        cmd = 'firefox',
        rule = { class = 'firefox' },
    },
    private = {
        icon = '﫸',
        key = 'r',
        cmd = 'firefox --private-window',
        rule = { class = 'firefox' },
    },
    terminal = {
        icon = '',
        key = 's',
        cmd = 'kitty',
        rule = { instance = 'kitty' },
    },
    notion = {
        icon = '',
        key = 'a',
        cmd = 'notion-app-enhanced',
        rule = { instance = 'notion-app-enhanced' },
    },
    godot = {
        icon = '',
        key = 'e',
        cmd = 'godot',
        rule = { instance = 'Godot_Engine' },
    },
}

c.keys = {
    global = {
        -- Clients.
        ['M-j'] = {awful.client.focus.byidx, 1},
        ['M-k'] = {awful.client.focus.byidx, -1},
        ['M-S-j'] = {awful.client.swap.byidx, 1},
        ['M-S-k'] = {awful.client.swap.byidx, -1},
        ['M-q'] = awful.client.focus.history.previous,

        -- Tags.
        ['M-Tab'] = util.tag.view_toggle,
        ['M-backslash'] = awful.tag.viewnone,

        -- Spawn.
        ['M-p'] = {awful.spawn, 'passless-rofi'},
        ['M-l'] = {awful.spawn, 'rofi -show run'},

        -- Controls.
        ['M-Up'] = {cmds.backlight.inc, 10, is_laptop or 'ddcutil setvcp 10 + %d'},
        ['M-Down'] = {cmds.backlight.dec, 10, is_laptop or 'ddcutil setvcp 10 - %d'},

        ['XF86AudioLowerVolume'] = audio.dec_volume,
        ['XF86AudioRaiseVolume'] = audio.inc_volume,
        ['XF86AudioMute'] = audio.toggle_mute,

        ['Print'] = function () cmds.screenshot(true) end,
        ['S-Print'] = cmds.screenshot,

        ['M-C-r'] = awesome.restart,
        ['M-C-q'] = awesome.quit,

        ['M-Scroll_Lock'] = session.lock,
        ['M-Pause'] = {awful.spawn, 'systemctl suspend'},

        -- Pomodoro.
        ['M-1'] = pomo.toggle,
        ['M-S-1'] = pomo.stop,
    },
    client = {
        ['M-BackSpace'] = function (cl) cl:kill() end,
        ['M-x'] = util.client.hide,
    },
}

c.buttons = {
    client = {
        ['1'] = function (cl) cl:activate { context = 'mouse_click' } end,
        ['M-1'] = function (cl) cl:activate { context = 'mouse_click', action = 'mouse_move' } end,
        ['M-3'] = function (cl) cl:activate { context = 'mouse_click', action = 'mouse_resize' } end,
    },
    taglist = {
        ['1'] = util.tag.view_focus,
        ['3'] = function (t) t:view_only() end,
    },
}

c.rules = {
}

c.options = {
    clients = {
        allow_maximized = false,
    },
    battery = {
        widget_enabled = is_laptop,
        low_percent = 10,
        charged_percent = 95,
    },
    screenshot = {
        dir = '~/screenshots',
        ext = 'png',
    },
    pomodoro = {
        set_length = 4,
        working = 25 * 60,
        short_break = 5 * 60,
        long_break = 20 * 60,
        show_icon = true,
    },
}

c.widgets = {
    'pomodoro',
    'battery',
    'audio',
}

return c
