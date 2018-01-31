NPL.load("specs/spec_helper.lua")

local RouteHelper = commonlib.gettable("ActionDispatcher.Routing.RouteHelper")
local Route = commonlib.gettable("ActionDispatcher.Routing.Route")
local Rule = commonlib.gettable("ActionDispatcher.Routing.Rule")
local resources = RouteHelper.resources
local namespace = RouteHelper.namespace
local scope = RouteHelper.scope
local url = RouteHelper.url
local rule = RouteHelper.rule

describe(
    "ActionDispatcher.Routing.Route",
    function()
        after(
            function()
                Route.clear()
            end
        )

        context(
            "#add",
            function()
                it(
                    "should add rule to route rule",
                    function()
                        Route.add(Rule:new():init({"get", "/", "Controller.Home", "index"}))
                        assert_equal(#Route.rules, 1)
                        assert_not_equal(Route.parse("get", "/"), nil)
                    end
                )
            end
        )

        context(
            "#add_rule",
            function()
                it(
                    "should add rule to route rule",
                    function()
                        Route.add_rule({"get", "/", "Controller.Home", "index"})
                        assert_equal(#Route.rules, 1)
                        assert_not_equal(Route.parse("get", "/"), nil)
                    end
                )
            end
        )

        context(
            "#set_api_only",
            function()
                it(
                    "should include all 7 restful default actions",
                    function()
                        RouteHelper.route(resources("repos"))
                        assert_equal(#Route.rules, 7)
                        assert_not_equal(Route.parse("get", "/repos/1/edit"), nil)
                        assert_not_equal(Route.find_rule("get", "^/repos/add/?$"), nil)
                    end
                )
                it(
                    "should not include add and edit if api only",
                    function()
                        Route.set_api_only(true)
                        RouteHelper.route(resources("repos"))
                        assert_equal(#Route.rules, 5)
                        assert_equal(Route.find_rule("get", "^/repos/add/?$"), nil)
                        assert_equal(Route.parse("get", "/repos/1/edit"), nil)
                    end
                )
            end
        )

        context(
            "#clear",
            function()
                it(
                    "should remove all rules",
                    function()
                        RouteHelper.route(resources("repos"))
                        assert_not_equal(#Route.rules, 0)
                        Route.clear()
                        assert_equal(#Route.rules, 0)
                    end
                )
            end
        )

        context(
            "#parse",
            function()
                it(
                    "should return the match",
                    function()
                        RouteHelper.route(resources("repos"))
                        assert_equal(Route.parse("get", "/repos/1").url, "/repos/:id")
                    end
                )
                it(
                    "should return nil if no match",
                    function()
                        assert_equal(Route.parse("get", "/users/1/edit"), nil)
                    end
                )
            end
        )

        context(
            "#find rule",
            function()
                it(
                    "should return the match",
                    function()
                        RouteHelper.route(resources("repos"))
                        assert_equal(Route.find_rule("get", "^/repos/%w+/?$").url, "/repos/:id")
                        assert_equal(Route.find_rule("get", "/repos/:id").url, "/repos/:id")
                    end
                )
                it(
                    "should return nil if no match",
                    function()
                        assert_equal(Route.find_rule("get", "^/repos/%w+/?$"), nil)
                    end
                )
                it(
                    "should match action",
                    function()
                        RouteHelper.route(resources("repos"))
                        assert_equal(Route.find_rule("get", "Repo#show").url, "/repos/:id")
                        assert_equal(Route.find_rule("get", "Controller.Repo#show").url, "/repos/:id")
                    end
                )
            end
        )

        context(
            "#find rule by url",
            function()
                it(
                    "should return the match",
                    function()
                        RouteHelper.route(resources("repos"))
                        assert_equal(Route.find_rule_by_url("get", "/repos/:id").url, "/repos/:id")
                    end
                )
                it(
                    "should return nil if no match",
                    function()
                        assert_equal(Route.find_rule_by_url("get", "/repos/:id"), nil)
                        RouteHelper.route(resources("repos"))
                        assert_equal(Route.find_rule_by_url("get", "/users/:id"), nil)
                    end
                )
            end
        )

        context(
            "#find rule by action",
            function()
                before(
                    function()
                        RouteHelper.route(resources("repos"))
                    end
                )
                it(
                    "should return the match",
                    function()
                        assert_equal(Route.find_rule_by_action("get", "Controller.Repo", "show").url, "/repos/:id")
                    end
                )
                it(
                    "should return nil if no match",
                    function()
                        assert_equal(Route.find_rule_by_action("get", "Controller.User", "show"), nil)
                        assert_equal(Route.find_rule_by_action("get", "Controller.Repo", "hello"), nil)
                    end
                )
                it(
                    "should not allow incomplete controller",
                    function()
                        assert_equal(Route.find_rule_by_action("get", "Repo", "show"), nil)
                    end
                )
            end
        )
    end
)
