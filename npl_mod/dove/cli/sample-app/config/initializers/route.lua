--[[
desc: config your routes here.
format:
{
    urls = {
        {method, url, controller, action}
    },
    rules = {
        {method, rule, controller, action}
    },
    resources = {
        your_resources = {

        }
    },
    namespaces = {
        resources = {
            ...
        }
    }
}
]]
local Route = commonlib.gettable("ActionDispatcher.Routing.Route")

local routes = {
    urls = {
        {"get", "/", "Controller.Home", "index"}
    }
}

Route.init(routes)
