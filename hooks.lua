local gtable = require("gears.table")

local hooks = {}

hooks.__index = hooks

function hooks.new()
    return setmetatable({}, hooks)
end

function hooks:add(name, f)
    if self[name] then
        table.insert(self[name], f)
    else
        self[name] = {f}
    end
end

function hooks:run(name, data)
    local fs = {}
    if type(name) == "table" then
        for _, n in ipairs(name) do
            fs = gtable.merge(fs, self[n])
        end
    else
        fs = self[name]
    end
    if fs then
        print(string.format("HOOKS.RUN: %s (%d)", name, #fs))
        for _, f in ipairs(fs) do f(data) end
    end
end

return hooks
