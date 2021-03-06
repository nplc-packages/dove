--[[
title: dove app framework marshal Dispatcher
author: chenqh
date: 2017/12/10
desc: dove marshal Dispatcher, handle all middlewares in pipeline
]]
local _M = commonlib.gettable("Dove.Middleware.Dispatcher")

_M.pipeline = {}
_M.services = {}

local function add_to_pipeline(middleware)
    _M.pipeline[#_M.pipeline + 1] = middleware
end

local function add_service(middleware, lib)
    _M.services[middleware] = lib
end

local function traversal(ctx)
    local function dispatch(i)
        local middleware = _M.pipeline[i]
        if (middleware) then
            _M.services[middleware].handle(ctx)
            dispatch(i + 1)
        end
    end
    dispatch(1)
end

-- Register middleware to dispatcher pipeline follow FIFO strategy
-- @param middleware is a string, the name of the middleware lib
function _M.register(middleware)
    if (type(middleware) ~= "string") then
        error("please register with the middleware class name")
    end
    local middleware_lib = commonlib.gettable(middleware)
    if (type(middleware_lib) ~= "table") then
        error("Invalid middleware!")
    end
    if (type(middleware_lib.handle) ~= "function") then
        error(format("please implement 'handle' method for middleware %s", middleware))
    end
    if (_M.services[middleware] ~= nil) then
        log(format("warning: service %s already existed, will ignore it.", middleware))
        return
    end
    add_to_pipeline(middleware)
    add_service(middleware, middleware_lib)
end

-- alias of register
function _M.use(middleware)
    return _M.register(middleware)
end

-- Dispatcher entry, handle the contex from client request
-- @param ctx is the context of a request
function _M.handle(ctx)
    xpcall(
        function()
            traversal(ctx)
        end,
        function(e)
            log("error: Dispatcher.traversal failed.")
            log(e)
            log(debug.traceback())
            if APP.config.env ~= 'production' then
                ctx.response:send(format("exception: %s \n debug: %s", e, debug.traceback()))
            else
                ctx.response:status(500):send("")
            end
        end
    )

    if (string.find(ctx.response.statusline, "302")) then
        ctx.response:send("")
    elseif (ctx.request._isAsync) then
        log("a async request.")
    else
        ctx.response:finish()
        ctx.response:End()
    end
end
