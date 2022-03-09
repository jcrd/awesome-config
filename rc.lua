local awful = require('awful')
local beautiful = require('beautiful')

local ez = require('awesome-ez')
local session = require('sessiond_dbus')

beautiful.init(awful.util.get_configuration_dir()..'/theme.lua')

require('widgets.audio').init {
    logger = require('log'),
    sessiond_dbus = session,
}

local config = require('config')
require('cmds').config = config

awful.keyboard.append_global_keybindings(ez.keytable(config.keys.global))

require('tags').rules = config.tags
require('screens')
require('clients')
require('notifs')

session.connect()
