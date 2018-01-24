#!/usr/bin/env nplc
NPL.load_package("dove")
NPL.load("dove/init")
NPL.load("cli/generator.lua")

local table_insert = table.insert
local table_remove = table.remove
local table_concat = table.concat
local deepcopy = commonlib.deepcopy
local Generator = commonlib.gettable("Dove.Generator")

local function assert_options(key, value)
    if not value then
        error(format("Invalid %s", key))
    end
end

local function create_app(options, ctx)
    local app_name = options[1]
    assert_options("app name", app_name)
    Generator.gen_app(app_name)
end

local function load_local_project()
    local boot = NPL.load("boot.lua")
    if boot == false then
        error("Failed to boot the app, please make sure you are in the root folder of your app.")
    elseif type(boot) == "function" then
        boot({})
    end
end

local function print_routes()
    load_local_project()
    local Route = ActionDispatcher.Routing.Route
    Route.print()
end

local function open_console(options)
    load_local_project()
    local console = commonlib.gettable("System.Nplcmd.Console")
    console.run()
end

local function keep_server_alive(ctx)
    ctx.keep_alive = true
end

local function boot_app(options, ctx)
    load_local_project()
    keep_server_alive(ctx)
end

return function(ctx)
    local args = deepcopy(ctx.arg)
    local operation = args[1]
    assert_options("operation", operation)

    operation = operation:lower()

    table_remove(args, 1)

    if operation == "g" or operation == "generate" then
        generate(args, ctx)
    elseif operation == "n" or operation == "new" then
        create_app(args, ctx)
    elseif operation == "r" or operation == "routes" then
        print_routes(args)
    elseif operation == "c" or operation == "console" then
        open_console(args)
    elseif operation == "start" then
        boot_app(args, ctx)
    else
        print(format("Invalid operation %s", operation))
    end
end
