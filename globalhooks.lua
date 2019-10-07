local hooks = require("hooks")

local hs = nil

if not hs then
    hs = hooks.new()
end

return hs
