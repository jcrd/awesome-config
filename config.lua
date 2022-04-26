local awful = require('awful')

local session = require('sessiond_dbus')

local cmds = require('cmds')
local audio = require('widgets.audio')
local pomo = require('widgets.pomodoro')

local c = {}
local is_laptop = os.getenv('CHASSIS') == 'laptop'

c.clients = {
    {
        key = 'grave',
        cmd = 'kitty --name panel',
        rule = { instance = 'panel' },
        panel = true,
    },
    {
        key = 'd',
        cmd = 'code',
        rule = { instance = 'code' },
        icon = '',
    },
    {
        key = 'w',
        cmd = 'google-chrome',
        rule = { instance = 'google-chrome' },
        icon = '',
    },
    {
        key = 's',
        cmd = 'kitty',
        rule = { instance = 'kitty' },
        icon = '',
    },
    {
        key = 'a',
        cmd = 'notion-app-enhanced',
        rule = { instance = 'notion-app-enhanced' },
        icon = '',
    },
}

c.keys = {
    global = {
        -- Clients.
        ['M-j'] = { awful.client.focus.byidx, 1 },
        ['M-k'] = { awful.client.focus.byidx, -1 },
        ['M-S-j'] = { awful.client.swap.byidx, 1 },
        ['M-S-k'] = { awful.client.swap.byidx, -1 },
        ['M-Tab'] = awful.client.focus.history.previous,
        ['M-q'] = cmds.client.restore,

        -- Layout.
        ['M-c'] = cmds.layout.toggle,

        -- Spawn.
        ['M-p'] = { awful.spawn, 'passless-rofi' },
        ['M-l'] = { awful.spawn, 'rofi -show run' },

        -- Controls.
        ['M-Up'] = { cmds.backlight.inc, 10, is_laptop or 'ddcutil setvcp 10 + %d' },
        ['M-Down'] = { cmds.backlight.dec, 10, is_laptop or 'ddcutil setvcp 10 - %d' },

        ['XF86AudioLowerVolume'] = audio.dec_volume,
        ['XF86AudioRaiseVolume'] = audio.inc_volume,
        ['XF86AudioMute'] = audio.toggle_mute,

        ['Print'] = function() cmds.screenshot(true) end,
        ['S-Print'] = cmds.screenshot,

        ['M-C-r'] = awesome.restart,
        ['M-C-q'] = awesome.quit,

        ['M-Scroll_Lock'] = session.lock,
        ['M-Pause'] = { awful.spawn, 'systemctl suspend' },

        -- Pomodoro.
        ['M-1'] = pomo.toggle,
        ['M-S-1'] = pomo.stop,
    },
    client = {
        ['M-S-BackSpace'] = function(cl) cl:kill() end,
        ['M-BackSpace'] = cmds.client.toggle,
    },
}

c.buttons = {
    client = {
        ['1'] = function(cl) cl:activate { context = 'mouse_click' } end,
        ['M-1'] = function(cl) cl:activate { context = 'mouse_click', action = 'mouse_move' } end,
        ['M-3'] = function(cl) cl:activate { context = 'mouse_click', action = 'mouse_resize' } end,
    },
    tasklist = {
        ['1'] = cmds.client.toggle,
        ['3'] = cmds.client.toggle_only,
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
