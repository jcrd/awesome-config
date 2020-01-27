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

local audio = require("audio")
local common = require("common")
local hud = require("hud")
local screenshot = require("screenshot")
local session = require("session")

local bindings = {}

launch.spawn.viewport = launch.spawn.here(viewport).raise_or_spawn

bindings.globalkeys = ez.keytable {
    ["M-p"] = function () menubar.show() end,
    ["M-S-<Return>"] = {launch.spawn, "kitty -1", {factory="kitty"}},
    ["M-<Return>"] = {launch.spawn.viewport, unpack(common.clients.term)},
    ["M-b"] = {launch.spawn.viewport, unpack(common.clients.browser)},
    ["M-c"] = {launch.spawn.viewport, unpack(common.clients.chromium)},
    ["M-e"] = {launch.spawn.viewport, unpack(common.clients.editor)},
    ["M-<grave>"] = {panel.toggle, "kitty -1",
        {id="terminal", factory="kitty", scale=0.6}},
    ["M-S-j"] = awful.tag.viewnext,
    ["M-S-k"] = awful.tag.viewprev,
    ["M-<space>"] = dovetail.command.toggle_centered,
    ["M-<Tab>"] = dovetail.command.focus.other,
    ["M-o"] = dovetail.command.master.viewtoggle,
    ["M-x"] = dovetail.command.master.queue,
    ["M-j"] = dovetail.command.focus.stack.next,
    ["M-k"] = dovetail.command.focus.stack.previous,
    ["M-<period>"] = {awful.tag.incmwfact, 0.05},
    ["M-<comma>"] = {awful.tag.incmwfact, -0.05},
    ["M-h"] = {dovetail.command.master.cycle, -1},
    ["M-l"] = {dovetail.command.master.cycle, 1},
    ["M-m"] = common.hide_mouse,
    ["M-q"] = naughty.destroy_all_notifications,
    ["M-C-r"] = awesome.restart,
    ["M-C-q"] = awesome.quit,
    ["M-C-<equal>"] = {awful.spawn, "systemctl suspend"},
    ["M-C-<minus>"] = {awful.spawn, "systemctl poweroff"},
    ["M-<BackSpace>"] = session.lock,
    ["M-<F5>"] = function ()
        session.backlights.intel_backlight:IncBrightness(-100)
    end,
    ["M-<F6>"] = function ()
        session.backlights.intel_backlight:IncBrightness(100)
    end,
    ["<XF86AudioLowerVolume>"] = {audio.inc, -2},
    ["<XF86AudioRaiseVolume>"] = {audio.inc, 2},
    ["<XF86AudioMute>"] = audio.toggle,
    ["<Print>"] = screenshot.take,
    ["S-<Print>"] = {screenshot.take, true},
}

local function with_tag(i, func)
    local s = awful.screen.focused()
    local t = s.tags[i]
    func(t)
end

do
    local keys = {}
    for i=1,9 do
        keys["M-" .. i] = function ()
            with_tag(i, function (t)
                if not t then
                    t = ws.add("scratch",
                        {props={screen=s, layout=common.layout}})
                end
                if t == viewport() then
                    awful.tag.history.restore(s)
                else
                    t:view_only()
                end
            end)
        end
        keys["M-S-" .. i] = function ()
            if client.focus then
                local t = client.focus.screen.tags[i]
                if not t then
                    t = ws.add("scratch",
                        {props={screen=s, layout=common.layout}})
                end
                client.focus:move_to_tag(t)
                t:view_only()
            end
        end
        keys["M-C-" .. i] = function ()
            with_tag(i, function (t)
                if t then
                    awful.tag.viewtoggle(t)
                end
            end)
        end
        keys["M-A-" .. i] = function ()
            with_tag(i, function (t)
                if t then
                    t:delete()
                end
            end)
        end
    end
    bindings.globalkeys = gears.table.join(bindings.globalkeys,
        ez.keytable(keys))
end

bindings.clientkeys = ez.keytable {
    ["M-f"] = function (c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end,
    ["M-t"] = function (c)
        c.floating = not c.floating
    end,
    ["M-s"] = function (c)
        if not dovetail.layout.master(c.screen) then
            dovetail.command.master(c)
        else
            dovetail.command.master.swap()
        end
    end,
    ["M-n"] = function (c)
        c.floating = false
        c.fullscreen = false
        c.maximized = false
        c.maximized_horizontal = false
        c.maximized_vertical = false
        c.sticky = false
        c.ontop = false
    end,
    ["M-S-q"] = function (c) c:kill() end,
    ["M-i"] = hud.clientinfo,
}

bindings.clientbtns = ez.btntable {
    ["1"] = function (c) client.focus = c end,
    ["M-1"] = awful.mouse.client.move,
    ["M-3"] = awful.mouse.client.resize,
}

return bindings
