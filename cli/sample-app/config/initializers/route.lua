--[[
desc: config your routes here.

]]
local Route = commonlib.gettable("ActionDispatcher.Routing.Route")
local RouteHelper = commonlib.gettable("ActionDispatcher.Routing.RouteHelper")
local join = RouteHelper.join
local resources = RouteHelper.resources
local namespace = RouteHelper.namespace

RouteHelper.route(
    -- add your route definitions here
    resources("home", {only = {"index"}})
)
