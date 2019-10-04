local dbus = require("dbus_proxy")

local session = {}
session.backlights = {}

local function new_backlight(path)
    return dbus.Proxy:new {
        bus = dbus.Bus.SESSION,
        name = "org.sessiond.session1",
        interface = "org.sessiond.session1.Backlight",
        path = path,
    }
end

local function add_backlight(path)
    local bl = new_backlight(path)
    bl.obj_path = path
    session.backlights[bl.Name] = bl
end

local function remove_backlight(path)
    for n, bl in pairs(session.backlights) do
        if bl.obj_path == path then
            session.backlights[n] = nil
        end
    end
end

local function callback(p, appear)
    if appear then
        for _, path in ipairs(p.Backlights) do
            add_backlight(path)
        end
        p:connect_signal(add_backlight, "AddBacklight")
        p:connect_signal(remove_backlight, "RemoveBacklight")
    else
        for n in pairs(session.backlights) do
            session.backlights[n] = nil
        end
    end
end

local proxy = dbus.monitored.new({
        bus = dbus.Bus.SESSION,
        name = "org.sessiond.session1",
        interface = "org.sessiond.session1.Session",
        path = "/org/sessiond/session1",
    }, callback)

function session.lock()
    if proxy.is_connected then
        _, err = proxy:Lock()
        if err then
            io.stderr:write(err)
            return false
        end
        return true
    end
end

return session
