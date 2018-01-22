--[[
title:  route manager
author: chenqh
date:   2017/11/22
desc:   Load the route config and manage it globally
example
------------------------------------------------------
router.parse(request)

GET /users
=> route.users.index
=> commonlib.gettable("controller.user").index
GET /users/:id
=> route.users.show
=> commonlib.gettable("controller.user").show -- params[:id] = :id
POST /users/
=> route.users.create
=> commonlib.gettable("controller.user").create
PUT /users/:id
=> route.users.update
=> commonlib.gettable("controller.user").update
DELETE /users/:id
=> route.users.delete
=> commonlib.gettable("controller.user").delete
GET /users/:id/pages
=> try route.users.members.pages.index
=> commonlib.gettable("controller.page").index -- params[:user_id] = :id
=> or route.users.actions.pages
=> commonlib.gettable("controller.user").pages -- params[:id] = :id
POST /users/add_pages
=> try route.users.add_pages
=> commonlib.gettable("controller.user").add_pages
GET /user/pages
=> route.users.collections.pages.index
=> commonlib.gettable("controller.user.page").index
]]
local Pluralize = commonlib.gettable("Dove.Utils.Pluralize")
local StringHelper = commonlib.gettable("Dove.Utils.StringHelper")
local RegexHelper = commonlib.gettable("ActionDispatcher.Routing.RegexHelper")
local Rule = commonlib.gettable("ActionDispatcher.Routing.Rule")
local _M = commonlib.gettable("ActionDispatcher.Routing.Route")

local routeMatcher = {
    get = "show",
    post = "create",
    delete = "delete",
    put = "update"
}

local is_plural = Pluralize.is_plural
local singular = Pluralize.singular
local plural = Pluralize.plural
local table_concat = table.concat
local table_insert = table.insert
local deepcopy = commonlib.deepcopy

_M.routes = {}
_M.rules = {}
_M.api_only = false -- the default restful actions will not include :add and :edit if api only

function _M.add_rule(rule)
    _M.add(Rule:new():init(rule))
end

function _M.add(rule)
    table_insert(_M.rules, rule)
end

function _M.init(source)
    _M.routes = {} -- recreate
    build_urls(source.urls)
    build_namespaces(source.namespaces)
    build_resources(source.resources)
    build_rules(source.rules)
end

function _M.set_api_only(config_value)
    _M.api_only = not (not (config_value))
end

function _M.print()
    for _, rule in ipairs(_M.rules) do
        log(format("%s %s \n", table_concat(rule.origin, "  "), rule.regex))
    end
end

function _M.parse(method, url)
    local method = method:lower()
    for _, r in ipairs(_M.rules) do
        if (r.method == method and url:match(r.regex)) then
            return deepcopy(r) -- keep route rules save
        end
    end
    error("Invalid url: " .. url)
end

function _M.find_rule(url, method)
    local temp = StringHelper.split(url, "[^#]+")
    local rule = nil
    if (#temp == 2) then -- controller#action
        local controller = temp[1]
        local action = temp[2]
        if (not controller:match("^Controller.")) then
            controller = "Controller." .. controller
        end
        rule = _M.find_rule_by_action(method, controller, action)
    else -- /users/:id
        rule = _M.find_rule_by_url(method, url)
    end
    return rule
end

function _M.find_rule_by_url(method, url)
    local method = method:lower()
    local regex = RegexHelper.formulize(url)
    for _, r in ipairs(_M.rules) do
        if (r.regex == regex and r.method == method) then
            return deepcopy(r)
        end
    end
end

function _M.find_rule_by_action(method, controller, action)
    local method = method:lower()
    for _, r in ipairs(_M.rules) do
        if (r.action == action and r.controller == controller and r.method == method) then
            return deepcopy(r)
        end
    end
end
