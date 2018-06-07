--[[
title: application entry
author: chenqh
date: 2017/12/10
desc: basic handler for web application, will handle all client requestes
]]
NPL.load("dotenv")
local App = commonlib.inherit(nil, "Dove.Application")
local Loader = commonlib.gettable("Dove.Utils.Loader")
local Dispatcher = commonlib.gettable("Dove.Middleware.Dispatcher")
local PathHelper = commonlib.gettable("Dove.Utils.PathHelper")
local lfs = commonlib.Files.GetLuaFileSystem()
local AppFileWatcher = commonlib.gettable("NPL.AppFileWatcher")

App.config = {
    dotenv = ".env",
    env = "development",
    port = "8088",
    layout = {
        default_template = "application_layout",
        enable = true
    },
    custom = {},
    file_watcher = {
        enabled = false,
        monitor_directories = {
            "app",
            "config"
        },
        monitored_files = {
            ["lua"] = true,
            ["npl"] = true
        }
    }
    -- default_template = nil
    -- default_template_file = nil
}

function App:ctor()
end

local function load_app()
    Loader.load_files("app/controllers")
    Loader.load_files("app/models")
    Loader.load_files("app/helpers")
    Loader.load_files("config/initializers")
end

local function change_logger_path(env)
    local log_dir = PathHelper.concat(lfs.currentdir(), "log")
    local attr = lfs.attributes(log_dir)
    if not attr or attr.mode == "file" then
        lfs.mkdir(log_dir)
    end
    commonlib.servicelog.GetLogger(""):SetLogFile(format("log/%s.log", env)) -- update log file
end

local function load_file_watcher(config)
    if config.enabled then
        local file_watcher = AppFileWatcher:new():init(config.monitored_files)
        for _, dir in pairs(config.monitor_directories) do
            file_watcher:monitor_directory(dir)
        end
        print('file watcher is enabled')
    end
end

function App:info()
end

function App:start()
    Dotenv.load(self.config.dotenv)
    NPL.load(format("config/environments/%s.lua", self.config.env))
    load_app()
    change_logger_path(self.config.env)
    load_file_watcher(self.config.file_watcher)
    -- 启动web服务器
    WebServer:Start("app", "0.0.0.0", self.config.port)
    log("Application is ready on port " .. self.config.port)
end

function App:handle(msg)
    local req = WebServer.request:new():init(msg)
    local ctx = Dove.Context:new()
    ctx:init(req)
    Dispatcher.handle(ctx)
end
