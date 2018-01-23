NPL.load("specs/spec_helper.lua")

local Router = commonlib.gettable("ActionDispatcher.Routing.Router")
local RouteHelper = commonlib.gettable("ActionDispatcher.Routing.RouteHelper")
local Route = commonlib.gettable("ActionDispatcher.Routing.Route")
local Rule = commonlib.gettable("ActionDispatcher.Routing.Rule")
local resources = RouteHelper.resources
local namespace = RouteHelper.namespace
local scope = RouteHelper.scope
local url = RouteHelper.url
local rule = RouteHelper.rule

describe(
    "ActionDispatcher.Routing.Router",
    function()
        context(
            "#url_for",
            function()
                before(
                    function()
                        RouteHelper.route(resources("repos"))
                    end
                )
                after(
                    function()
                        Route.clear()
                    end
                )

                it(
                    "should return generated url",
                    function()
                        local url = "/repos/:id"
                        local params = {id = "1", q = "abc"}
                        assert_equal(Router.url_for(url, "get", params), "/repos/1?q=abc")
                    end
                )
                it(
                    "should raise error if params not valid",
                    function()
                        local url = "/repos/:id"
                        local params = {q = "abc"}
                        assert_error(
                            function()
                                Router.url_for(url, "get", params)
                            end
                        )
                    end
                )
                it(
                    "should raise error if url not valid",
                    function()
                        local url = "/users/:id"
                        local params = {q = "abc"}
                        assert_error(
                            function()
                                Router.url_for(url, "get", params)
                            end
                        )
                    end
                )
            end
        )
    end
)
