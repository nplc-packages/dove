NPL.load("dove/specs/spec_helper")
local RouteHelper = commonlib.gettable("ActionDispatcher.Routing.RouteHelper")
local Route = commonlib.gettable("ActionDispatcher.Routing.Route")
local resources = RouteHelper.resources
local namespace = RouteHelper.namespace

RouteHelper.route(
    resources(
        "repos",
        {
            only = {"index"},
            members = {
                {"post", "hey"}
            }
        },
        {
            resources("files")
        }
    ),
    namespace(
        "admin",
        {
            resources("users")
        }
    )
)

Route.print()
