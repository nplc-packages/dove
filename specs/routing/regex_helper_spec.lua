NPL.load("specs/spec_helper.lua")
local RegexHelper = commonlib.gettable("ActionDispatcher.Routing.RegexHelper")
local formulize = RegexHelper.formulize

describe(
    "ActionDispatcher.Routing.RegexHelper",
    function()
        local contexts
        context(
            "#formulize",
            function()
                it(
                    "should accept :id",
                    function()
                        assert_equal(formulize("/users/:id"), "^/users/%w+/?$")
                    end
                )
                it(
                    "should accept :user_id",
                    function()
                        assert_equal(formulize("/users/:user_id/files/:id"), "^/users/%w+/files/%w+/?$")
                    end
                )
            end
        )
    end
)