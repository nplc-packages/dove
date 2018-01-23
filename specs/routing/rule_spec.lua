NPL.load("specs/spec_helper.lua")

local RouteHelper = commonlib.gettable("ActionDispatcher.Routing.RouteHelper")
local Route = commonlib.gettable("ActionDispatcher.Routing.Route")
local Rule = commonlib.gettable("ActionDispatcher.Routing.Rule")

describe(
    "ActionDispatcher.Routing.Rule",
    function()
        before(
            function()
                rule = Rule:new():init({"get", "/users/:user_id/repos/:id", "Controller.Repo", "show", "show repo"})
            end
        )
        after(
            function()
                rule = nil
            end
        )
        context(
            ":init",
            function()
                it(
                    "should return a rule",
                    function()
                        assert_equal(rule.method, "get")
                        assert_equal(rule.url, "/users/:user_id/repos/:id")
                        assert_equal(rule.controller, "Controller.Repo")
                        assert_equal(rule.action, "show")
                        assert_equal(rule.desc, "show repo")
                        assert_equal(rule.regex, "^/users/%w+/repos/%w+/?$")
                    end
                )
            end
        )

        context(
            ":update_origin",
            function()
                it(
                    "should uptate origin data",
                    function()
                        rule.controller = "Controller.Admin.Repo"
                        rule:update_origin()
                        assert_equal(rule.controller, "Controller.Admin.Repo")
                    end
                )
            end
        )

        context(
            ":update_regex",
            function()
                it(
                    "should uptate origin data",
                    function()
                        rule.url = "/users/:user_id/repos/:id/show"
                        rule:update_regex()
                        assert_equal(rule.regex, "^/users/%w+/repos/%w+/show/?$")
                    end
                )
            end
        )

        context(
            ":generate_url",
            function()
                it(
                    "should generate url",
                    function()
                        local params = {user_id = 1, id = 1}
                        assert_equal(rule:generate_url(params), "/users/1/repos/1")
                    end
                )
                it(
                    "should raise error if parameter missing",
                    function()
                        local params = {user_id = 1}
                        assert_error(
                            function()
                                rule:generate_url(params)
                            end
                        )
                    end
                )
            end
        )

        context(
            ":complete_extra_params",
            function()
                it(
                    "should add extra params",
                    function()
                        local params = {}
                        rule:complete_extra_params("/users/1/repos/1", params)
                        assert_equal(params["id"], "1")
                        assert_equal(params["user_id"], "1")
                    end
                )
                it(
                    "should allow to use friendly id",
                    function()
                        local params = {}
                        rule:complete_extra_params("/users/leo/repos/abc", params)
                        assert_equal(params["id"], "abc")
                        assert_equal(params["user_id"], "leo")
                    end
                )
                it(
                    "should overwrite the params",
                    function()
                        local params = {id = "abc", user_id = "leo"}
                        rule:complete_extra_params("/users/1/repos/1", params)
                        assert_equal(params["id"], "1")
                        assert_equal(params["user_id"], "1")
                    end
                )
            end
        )
    end
)
