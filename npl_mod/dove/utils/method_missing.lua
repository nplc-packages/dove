--[[
https://gist.github.com/weswigham/7313933
Method missing should be an optional definition on any object.
If a method cannot be found, method_missing is called if available
]]
local field = "__method__missing"

function method_missing(selfs, func)
    local meta = getmetatable(selfs)
    local f
    if meta then
        f = meta.__index
    else
        meta = {}
        f = rawget
    end
    meta.__index = function(self, name)
        local v = f(self, name)
        if v then
            return v
        end

        rawget(self, name)[field] = function(...)
            return func(self, name, ...)
        end
    end

    setmetatable(selfs, meta)
end

debug.setmetatable(
    nil,
    {
        __call = function(self, ...)
            if self[field] then
                return self[field](...)
            end
            return nil
        end,
        __index = function(self, name)
            if name ~= field then
                error("attempt to index a nil value: " .. name)
            end
            return getmetatable(self)[field]
        end,
        __newindex = function(self, name, value)
            if name ~= field then
                error("attempt to index a nil value: " .. name)
            end
            getmetatable(self)[field] = value
        end
    }
)
