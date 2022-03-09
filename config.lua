local awful = require('awful')

local session = require('sessiond_dbus')

local cmds = require('cmds')
local audio = require('widgets.audio')

local c = {}
local is_laptop = os.getenv('CHASSIS') == 'laptop'

c.tags = {
    editor = {
        cmd = 'code',
        rule = { instance = 'code' },
    },
    browser = {
        cmd = 'firefox',
        rule = { class = 'Firefox' },
    },
    terminal = {
        cmd = 'kitty',
        rule = { instance = 'kitty' },
    },
    notion = {
        cmd = 'notion-app-enhanced',
        rule = { instance = 'notion-app-enhanced' },
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
        ['M-t'] = {awful.layout.inc, -1},

        -- Tags.
        ['M-Tab'] = awful.tag.history.restore,
        ['M-backslash'] = awful.tag.viewnone,

        -- Spawn.
        ['M-p'] = {awful.spawn, 'passless-rofi'},
        ['M-l'] = {awful.spawn, 'rofi -show run'},
        ['M-d'] = {cmds.tag.view_smart, 'editor'},
        ['M-w'] = {cmds.tag.view_smart, 'browser'},
        ['M-s'] = {cmds.tag.view_smart, 'terminal'},
        ['M-a'] = {cmds.tag.view_smart, 'notion'},

        -- Controls.
        ['M-Up'] = {cmds.backlight.inc, 10, is_laptop or 'ddcutil setvcp 10 + %d'},
        ['M-Down'] = {cmds.backlight.dec, 10, is_laptop or 'ddcutil setvcp 10 - %d'},

        ['XF86AudioLowerVolume'] = {audio.dec_volume, 0.05},
        ['XF86AudioRaiseVolume'] = {audio.inc_volume, 0.05},
        ['XF86AudioMute'] = audio.toggle_mute,

        ['Print'] = function () cmds.screenshot(true) end,
        ['S-Print'] = cmds.screenshot,

        ['M-C-r'] = awesome.restart,
        ['M-C-q'] = awesome.quit,

        ['M-Scroll_Lock'] = session.lock,
        ['M-Pause'] = {awful.spawn, 'systemctl suspend'},
    },
    client = {
        ['M-BackSpace'] = function (cl) cl:kill() end,
    },
}

c.buttons = {
    client = {
        ['1'] = function (cl) cl:activate { context = 'mouse_click' } end,
        ['M-1'] = function (cl) cl:activate { context = 'mouse_click', action = 'mouse_move' } end,
        ['M-3'] = function (cl) cl:activate { context = 'mouse_click', action = 'mouse_resize' } end,
    },
    titlebar = function (cl)
        return {
            ['1'] = function () cl:activate { context = 'titlebar', action = 'mouse_move' } end,
            ['3'] = function () cl:activate { context = 'titlebar', action = 'mouse_resize' } end,
        }
    end,
    taglist = {
        ['1'] = cmds.tag.view_focus,
        ['M-1'] = function (t) t:view_only() end,
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
        working = 25,
        short_break = 5,
        long_break = 20,
    },
}

c.widgets = {
    'pomodoro',
    'battery',
    'audio',
}

return c
