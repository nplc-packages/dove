--[[
title: route helper
author: chenqh
date: 2018/1/21
desc:
Generally you should use namesapce, scope and resource to build your routes.
But route helper also support a way to add url or rule directlly with url/rule helper,
Please don't use it inside namespace or resource, the wrapper magic won't happen to the directly rule.

local RouteHelper = commonlib.gettable("ActionDispatcher.Routing.RouteHelper")
local resources = RouteHelper.resources
local namespace = RouteHelper.namespace
local scope = RouteHelper.scope
local url = RouteHelper.url
local rule = RouteHelper.rule

RouteHelper.route

]]
_M = commonlib.gettable("ActionDispatcher.Routing.RouteHelper")
local Route = commonlib.gettable("ActionDispatcher.Routing.Route")
local Pluralize = commonlib.gettable("Dove.Utils.Pluralize")
local StringHelper = commonlib.gettable("Dove.Utils.StringHelper")
local Rule = commonlib.gettable("ActionDispatcher.Routing.Rule")
local table_insert = table.insert
local table_concat = table.concat
local singular = Pluralize.singular
local plural = Pluralize.plural

local function join_rules(rules_array)
    local rules = {}
    for _, func_rules in ipairs(rules_array or {}) do
        for _, rule in ipairs(func_rules) do
            table_insert(rules, rule)
        end
    end

    return rules
end

-- merge and add all rules to Route
function _M.route(...)
    local rules = join_rules({...})
    for _, rule in ipairs(rules) do
        rule.url = "/" .. rule.url
        rule.controller = format("%s.%s", "Controller", rule.controller)
        rule:update_origin()
        rule:update_regex()
        Route.add(rule)
    end
end

-- Namespace is a wrapper of resources, which will add namespace to url and controller automatically
function _M.namespace(name, rules)
    rules = join_rules(rules)
    for i = 1, #rules do
        rules[i].url = format("%s/%s", name, rules[i].url)
        rules[i].controller = format("%s.%s", StringHelper.classify(name), rules[i].controller)
    end

    return rules
end

-- Scope looks like a configable namespace, if you enable all options, it will behave same as namespace.
-- It will add scope name to url by default, but you need to config it to add scope name to controller.
function _M.scope(name, options, rules)
    rules = join_rules(rules)
    for i = 1, #rules do
        rules[i].url = format("%s/%s", name, rules[i].url)
        if options.controller then
            rules[i].controller = format("%s.%s", StringHelper.classify(name), rules[i].controller)
        end
    end

    return rules
end

local function url_tail(action, isMember)
    if action == "index" or action == "create" then
        return nil
    end
    if action == "show" or action == "delete" or action == "update" then
        return ":id"
    end
    if action == "edit" or isMember == true then
        return format(":id/%s", action)
    end
    if action == "add" or isMember == false then
        return action
    end
    error(format("Invalid action setting: %s", action))
end

local function build_url_and_controller(action, resource, default_controller, isMember)
    local controller_stack = {}
    local url_stack = {}
    table_insert(controller_stack, singular(resource))
    table_insert(url_stack, plural(resource:lower()))
    table_insert(url_stack, url_tail(action, isMember))

    local url = table_concat(url_stack, "/")
    controller = default_controller or table.concat(controller_stack, ".")

    return url, controller
end

local function build_rest_actions(only, except, resource, default_controller)
    -- defalt actions
    local actionsMap = {
        index = "get", -- action = method
        show = "get",
        add = "get",
        create = "post",
        edit = "get",
        update = "put",
        delete = "delete"
    }
    if (Route.api_only) then
        actionsMap.add = nil
        actionsMap.edit = nil
    end

    if only ~= nil then
        if #only == 0 then
            actionsMap = {}
        else
            for k, _ in pairs(actionsMap) do
                local keep = false
                for _, v in pairs(only) do
                    if (k == v) then
                        keep = true
                    end
                end
                if not keep then
                    actionsMap[k] = nil
                end
            end
        end
    end
    if except ~= nil then -- remove the except
        for _, v in pairs(except) do
            actionsMap[v] = nil
        end
    end

    local result = {}
    local url = nil
    local method = nil
    local controller = nil
    if actionsMap.add then -- make sure action "add" has higher priority than action "show"
        url, controller = build_url_and_controller("add", resource, default_controller)
        table_insert(result, Rule:new():init({"get", url, controller, "add"}))
        actionsMap.add = nil
    end
    for action, method in pairs(actionsMap) do
        url, controller = build_url_and_controller(action, resource, default_controller)
        method = actionsMap[action]
        table_insert(result, Rule:new():init({method, url, controller, action}))
    end

    return result
end

local function build_resource(resource, options)
    local resource = StringHelper.classify(Pluralize.singular(resource))
    local rules = build_rest_actions(options.only, options.except, resource, options.controller)

    if options.members ~= nil then -- add the members
        for _, member in ipairs(options.members) do
            local method = member[1]
            local action = member[2]
            local url, controller = build_url_and_controller(action, resource, options.controller, true)
            table_insert(rules, Rule:new():init({method, url, controller, action}))
        end
    end

    if options.collections ~= nil then -- add the collections
        for _, collection in ipairs(options.collections) do
            local method = collection[1]
            local action = collection[2]
            local url, controller = build_url_and_controller(action, resource, options.controller, false)
            table_insert(rules, Rule:new():init({method, url, controller, action}))
        end
    end

    return rules
end

-- Resources is the core method to generate rules, it will generate restful rules by default.
-- restful action: index, show, create, delete, update, add, edit
-- options:
-- only@table option: define a collection of restful actions, and drop the others
-- except@table option: define a collection of restful actions which you don't need.
-- members@table option: define a collection of resource action, focus on a particular resource.
-- collections@table option: define a collection of resources action.
-- run route_helper_spec to see the details
function _M.resources(resource, options, rules)
    rules = join_rules(rules)
    for i = 1, #rules do
        rules[i].url = format("%s/:%s_id/%s", plural(resource), singular(resource), rules[i].url)
    end
    return join_rules({build_resource(resource, options or {}), rules or {}})
end

_M.resource = _M.resources

-- rule will be added to Route directly
function _M.rule(method, url, controller, action, desc)
    Route.add_rule({method, url, controller, action, desc})
    return {}
end

_M.url = _M.rule
