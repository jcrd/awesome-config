local mem = {}
mem.__index = mem

local function cmp(t1, t2)
    if #t1 ~= #t2 then
        return false
    end
    local test = {}
    for _, t in ipairs(t1) do
        test[t] = true
    end
    for _, t in ipairs(t2) do
        if test[t] then
            test[t] = nil
        else
            test[t] = true
        end
    end
    return #test == 0
end

function mem:new()
    local m = {
        history = {},
        recorder = function() return {} end,
    }
    return setmetatable(m, self)
end

function mem:record(tbl)
    tbl = tbl or self.recorder()
    self:remove(tbl)
    table.insert(self.history, tbl)
    return tbl
end

function mem:remove(tbl)
    for i, t in ipairs(self.history) do
        if cmp(t, tbl) then
            table.remove(self.history, i)
            return
        end
    end
end

function mem:purge(sub)
    for i, t in ipairs(self.history) do
        for j, s in ipairs(t) do
            if s == sub then
                table.remove(t, j)
                if #t == 0 then
                    table.remove(self.history, i)
                end
            end
        end
    end
end

function mem:restore()
    if #self.history == 0 then
        return
    end
    local r = table.remove(self.history)
    self:record()
    return r, self.history[#self.history]
end

return mem
