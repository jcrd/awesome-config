local awful = require('awful')
local beautiful = require('beautiful')

local ez = require('awesome-ez')
local session = require('sessiond_dbus')

beautiful.init(awful.util.get_configuration_dir() .. '/theme.lua')

require('widgets.audio').init {
    logger = require('log'),
    sessiond_dbus = session,
}

local config = require('config')
require('cmds').config = config

local clients = require('clients')
clients.config = config.clients

require('screens')
require('notifs')

awful.keyboard.append_global_keybindings(ez.keytable(config.keys.global))
awful.keyboard.append_global_keybindings(ez.keytable(clients.keybindings()))

session.connect()
