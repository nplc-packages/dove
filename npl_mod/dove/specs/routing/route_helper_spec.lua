NPL.load("dove/specs/spec_helper")
local RouteHelper = commonlib.gettable("ActionDispatcher.Routing.RouteHelper")
local Route = commonlib.gettable("ActionDispatcher.Routing.Route")
local resources = RouteHelper.resources
local namespace = RouteHelper.namespace
local scope = RouteHelper.scope
local url = RouteHelper.url
local rule = RouteHelper.rule

Route.api_only = true

RouteHelper.route(
    url("get", "/", "Controller.Home", "index"),
    resources(
        "repos",
        {},
        {
            resources("files")
        }
    ),
    namespace(
        "admin",
        {
            resources("users")
        }
    ),
    scope(
        "department",
        {},
        {
            resources("users")
        }
    )
)

Route.print()
