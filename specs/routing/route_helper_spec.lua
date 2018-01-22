NPL.load("specs/spec_helper.lua")

local RouteHelper = commonlib.gettable("ActionDispatcher.Routing.RouteHelper")
local Route = commonlib.gettable("ActionDispatcher.Routing.Route")
local resources = RouteHelper.resources
local namespace = RouteHelper.namespace
local scope = RouteHelper.scope
local url = RouteHelper.url
local rule = RouteHelper.rule

describe(
    "route helper",
    function()
        local contexts

        before(
            function()
                Route.api_only = true

                RouteHelper.route(
                    url("get", "/", "Controller.Home", "index"),
                    resources(
                        "repos",
                        {
                            only = {"index", "create"},
                            except = {"create"}
                        },
                        {
                            resources("files")
                        }
                    ),
                    namespace(
                        "admin",
                        {
                            resources(
                                "users",
                                {
                                    only = {},
                                    collections = {
                                        {"get", "hello"}
                                    }
                                }
                            )
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
            end
        )

        after(
            function()
                Route.rules = {}
            end
        )

        context(
            "url",
            function()
                it(
                    "should add url to route rule",
                    function()
                        assert_not_equal(Route.find_rule("get", "/"), nil)
                    end
                )
            end
        )

        context(
            "resources",
            function()
                it(
                    "should add resoruces to route rule",
                    function()
                        assert_not_equal(Route.find_rule("get", "/repos"), nil)
                    end
                )
                it(
                    "should keep the 'only' option, and drop the others",
                    function()
                        assert_not_equal(Route.find_rule("get", "/repos"), nil)
                        assert_equal(Route.find_rule("get", "/repos/:id"), nil)
                        assert_equal(Route.find_rule("post", "/repos"), nil)
                    end
                )
                it(
                    "remove all restful if only equal {}",
                    function()
                        assert_equal(Route.find_rule("get", "/admin/users"), nil)
                    end
                )
            end
        )

        context(
            "namespace",
            function()
                it(
                    "should add namespace to controller",
                    function()
                        local rule = Route.find_rule("get", "/admin/users/hello")
                        assert_equal(rule.controller, "Controller.Admin.User")
                    end
                )
            end
        )
    end
)
