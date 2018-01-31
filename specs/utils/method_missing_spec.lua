NPL.load("specs/spec_helper.lua")

local _M = {}

_M:method_missing(
    function(self, name, ...)
        local args = {...}
        if name:match("^test_") then
            local func = name:gsub("^(test_)", "%1")
            print(func)
            _G[func](args)
        else
            error("attempt to call a nil function")
        end
    end
)

describe(
    "method missing",
    function()
        it(
            "call test functions",
            function()
                assert_not_error(
                    function()
                        _M.test_print("hello")
                    end
                )
            end
        )
        it(
            "show error when method is invalid",
            function()
                assert_not_error(
                    function()
                        _M.error_print("hello")
                    end
                )
            end
        )
    end
)
