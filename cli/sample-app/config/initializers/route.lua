--[[
desc: config your routes here.
]]
local Route = commonlib.gettable("ActionDispatcher.Routing.Route")
local RouteHelper = commonlib.gettable("ActionDispatcher.Routing.RouteHelper")
local resources = RouteHelper.resources
local namespace = RouteHelper.namespace
local scope = RouteHelper.scope
local url = RouteHelper.url
local rule = RouteHelper.rule

RouteHelper.route(
    -- add your route definitions here
    url("get", "/", "Controller.Home", "index")
)
