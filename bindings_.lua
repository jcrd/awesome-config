local awful = require("awful")
local gears = require("gears")
local menubar = require("menubar")
local naughty = require("naughty")

local ez = require("awesome-ez")
local launch = require("awesome-launch")
local panel = require("awesome-launch.panel")
local ws = require("awesome-launch.workspace")
local dovetail = require("awesome-dovetail")
local viewport = require("awesome-viewport")
local session = require("sessiond_dbus")

local audio = require("audio")
local common = require("common")
local hud = require("hud")
local rofi = require("rofi")
local screenshot = require("screenshot")

launch.spawn.viewport = launch.spawn.here(viewport).raise_or_spawn

local function focus_byidx(i)
    if dovetail.layout() then
        dovetail.focus.byidx(i)
    else
        awful.client.focus.byidx(i)
    end
end

awful.keyboard.append_global_keybindings(ez.keytable {
    ["M-p"] = {awful.spawn, "rofi -show run"},
    ["M-l"] = {awful.spawn, "passless-rofi"},
    ["M-w"] = rofi.workspace.new,
    ["M-S-Return"] = {launch.spawn, "kitty"},
    ["M-Return"] = {launch.spawn.viewport, unpack(ws.clients.term)},
    ["M-b"] = {launch.spawn.viewport, unpack(ws.clients.browser)},
    ["M-c"] = {launch.spawn.viewport, unpack(ws.clients.chromium)},
    ["M-e"] = {launch.spawn.viewport, unpack(ws.clients.editor)},
    ["M-grave"] = {panel.toggle, "kitty", {id="terminal", scale=0.6}},
    ["M-Tab"] = awful.tag.history.restore,
    ["M-S-j"] = awful.tag.viewnext,
    ["M-S-k"] = awful.tag.viewprev,
    ["M-f"] = dovetail.focus.other,
    ["M-j"] = {focus_byidx, 1},
    ["M-k"] = {focus_byidx, -1},
    ["M-o"] = {awful.layout.inc, 1},
    ["M-period"] = {awful.tag.incmwfact, 0.05},
    ["M-comma"] = {awful.tag.incmwfact, -0.05},
    ["M-m"] = common.hide_mouse,
    ["M-d"] = naughty.destroy_all_notifications,
    ["M-C-r"] = awesome.restart,
    ["M-C-q"] = awesome.quit,
    ["M-C-equal"] = {awful.spawn, "systemctl suspend"},
    ["M-C-minus"] = {awful.spawn, "systemctl poweroff"},
    ["M-BackSpace"] = session.lock,
    ["M-Down"] = function ()
        session.backlights.default.dec_brightness()
    end,
    ["M-Up"] = function ()
        session.backlights.default.inc_brightness()
    end,
    ["XF86AudioLowerVolume"] = {audio.inc, -2},
    ["XF86AudioRaiseVolume"] = {audio.inc, 2},
    ["XF86AudioMute"] = audio.toggle,
    ["Print"] = screenshot.take,
    ["S-Print"] = {screenshot.take, true},
})

local function with_tag(func)
    return function (i)
        local s = awful.screen.focused()
        local t = s.tags[i]
        if not t then
            local p = s.tags[i - 1]
            if i > #s.tags + 1
                or p and p.name == "scratch" and #p:clients() == 0 then
                return
            else
                t = ws.new("scratch", {props={
                    layout = awful.layout.layouts[1],
                }})
            end
        end
        func(t)
    end
end

awful.keyboard.append_global_keybindings(ez.keytable {
    ["M-<numrow>"] = with_tag(function (t)
        if t == viewport() then
            awful.tag.history.restore()
        else
            t:view_only()
        end
    end),
    ["M-S-<numrow>"] = with_tag(function (t)
        if client.focus then
            client.focus:move_to_tag(t)
            t:view_only()
        end
    end),
    ["M-C-<numrow>"] = with_tag(function (t)
        if t then
            awful.tag.viewtoggle(t)
        end
    end),
    ["M-A-<numrow>"] = with_tag(function (t)
        if t then
            t:delete()
        end
    end),
})

client.connect_signal("request::default_keybindings", function ()
    awful.keyboard.append_client_keybindings(ez.keytable {
        ["M-g"] = function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        ["M-t"] = function (c)
            c.floating = not c.floating
        end,
        ["M-s"] = function (c)
            awful.client.setmaster(c)
        end,
        -- Normalize client.
        ["M-n"] = function (c)
            c.floating = false
            c.fullscreen = false
            c.maximized = false
            c.maximized_horizontal = false
            c.maximized_vertical = false
            c.sticky = false
            c.ontop = false
        end,
        ["M-S-d"] = function (c) c:kill() end,
        ["M-i"] = hud.clientinfo,
    })
end)

client.connect_signal("request::default_mousebindings", function ()
    awful.mouse.append_client_mousebindings(ez.btntable {
        ["1"] = function (c) client.focus = c end,
        ["M-1"] = awful.mouse.client.move,
        ["M-3"] = awful.mouse.client.resize,
    })
end)
