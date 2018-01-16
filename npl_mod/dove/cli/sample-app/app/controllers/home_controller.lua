local _C = commonlib.inherit(Dove.Controller.Base, "Controller.Home")

function _C:index()
    return {message = "Hello world!"}
end
