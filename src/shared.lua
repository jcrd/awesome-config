local awful = require('awful')
local gears = require('gears')

local shared = {}

shared.client_mem = require('lib.mem'):new()

function shared.client_mem.recorder()
    return gears.table.clone(awful.screen.focused().tiled_clients)
end

return shared
