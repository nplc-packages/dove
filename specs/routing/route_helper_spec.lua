NPL.load("specs/spec_helper.lua")

local RouteHelper = commonlib.gettable("ActionDispatcher.Routing.RouteHelper")
local Route = commonlib.gettable("ActionDispatcher.Routing.Route")
local resources = RouteHelper.resources
local namespace = RouteHelper.namespace
local scope = RouteHelper.scope
local url = RouteHelper.url
local rule = RouteHelper.rule

describe(
    "ActionDispatcher.Routing.RouteHelper",
    function()
        after(
            function()
                Route.clear()
            end
        )
        context(
            "#url",
            function()
                it(
                    "should add url to route rule",
                    function()
                        url("get", "/", "Controller.Home", "index")
                        assert_not_equal(Route.parse("get", "/"), nil)
                    end
                )
            end
        )

        context(
            "#rule",
            function()
                it(
                    "should add url to route rule",
                    function()
                        rule("get", "^/search/%w+/?$", "Controller.Home", "index")
                        assert_not_equal(Route.parse("get", "/search/1"), nil)
                    end
                )
            end
        )

        context(
            "#resources",
            function()
                before(
                    function()
                        RouteHelper.route(
                            resources("blobs"),
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
                            resources(
                                "users",
                                {
                                    only = {},
                                    collections = {
                                        {"post", "sign_up"}
                                    }
                                }
                            )
                        )
                    end
                )
                context(
                    "test",
                    function()
                        it(
                            "should add resoruces to route rule",
                            function()
                                assert_not_equal(Route.parse("get", "/blobs"), nil)
                            end
                        )
                        it(
                            "should keep the 'only' option, and drop the others",
                            function()
                                assert_not_equal(Route.parse("get", "/repos"), nil)
                                assert_equal(Route.parse("get", "/repos/:id"), nil)
                                assert_equal(Route.parse("post", "/repos"), nil)
                            end
                        )
                        it(
                            "remove all restful if only equal {}",
                            function()
                                assert_equal(Route.parse("get", "/users"), nil)
                            end
                        )
                        it(
                            "should add nested resources",
                            function()
                                assert_not_equal(Route.parse("get", "/repos/1/files"), nil)
                            end
                        )
                    end
                )
            end
        )


        context(
            "#resources with dash",
            function()
                before(
                    function()
                        RouteHelper.route(
                            resources("dash_blobs"),
                            resources(
                                "dash_repos",
                                {
                                    only = {"index", "create"},
                                    except = {"create"}
                                },
                                {
                                    resources("files")
                                }
                            )
                        )
                    end
                )
                context(
                    "test",
                    function()
                        it(
                            "should add resoruces to route rule",
                            function()
                                assert_not_equal(Route.parse("get", "/dash_blobs"), nil)
                            end
                        )
                        it(
                            "should keep the 'only' option, and drop the others",
                            function()
                                assert_not_equal(Route.parse("get", "/dash_repos"), nil)
                                assert_equal(Route.parse("get", "/dash_repos/:id"), nil)
                                assert_equal(Route.parse("post", "/dash_repos"), nil)
                            end
                        )
                    end
                )
            end
        )

        context(
            "#namespace",
            function()
                it(
                    "should add namespace to controller",
                    function()
                        RouteHelper.route(namespace("admin", {resources("users")}))
                        local rule = Route.parse("get", "/admin/users")
                        assert_equal(rule.controller, "Controller.Admin.User")
                        assert_equal(#Route.rules, 7)
                    end
                )
            end
        )

        context(
            "#scope",
            function()
                it(
                    "should not add scope to controller",
                    function()
                        RouteHelper.route(scope("admin", {}, {resources("users")}))
                        local rule = Route.parse("get", "/admin/users")
                        assert_equal(rule.controller, "Controller.User")
                    end
                )
                it(
                    "should add scope to controller if it was enabled",
                    function()
                        RouteHelper.route(scope("admin", {controller = true}, {resources("users")}))
                        local rule = Route.parse("get", "/admin/users")
                        assert_equal(rule.controller, "Controller.Admin.User")
                    end
                )
            end
        )
    end
)
