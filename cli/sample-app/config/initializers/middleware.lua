--[[
desc: add your middleware here.
]]
local Dispatcher = commonlib.gettable("Dove.Middleware.Dispatcher")

Dispatcher.use("ActionDispatcher.Processor") -- core processor of dove framework
