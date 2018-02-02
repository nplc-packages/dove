--[[
title: application entry
author: chenqh
date: 2017/12/10
desc: basic handler for web application, will handle all client requestes
]]
local App = commonlib.inherit(nil, "Dove.Application")
local Loader = commonlib.gettable("Dove.Utils.Loader")
local Dispatcher = commonlib.gettable("Dove.Middleware.Dispatcher")
local PathHelper = commonlib.gettable("Dove.Utils.PathHelper")
local lfs = commonlib.Files.GetLuaFileSystem()

App.config = {
    env = "development",
    port = "8088",
    layout = {
        default_template = "application_layout",
        enable = true
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

local function change_logger_path()
    local log_dir = PathHelper.concat(lfs.currentdir(), "log")
    local attr = lfs.attributes(log_dir)
    if not attr or attr.mode == "file" then
        lfs.mkdir(log_dir)
    end
    commonlib.servicelog.GetLogger(""):SetLogFile(format("log/%s.log", self.config.env)) -- update log file
end

function App:info()
end

function App:start()
    NPL.load(format("config/enviroments/%s", self.config.env))
    load_app()
    change_logger_path()
    -- 启动web服务器
    WebServer:Start("app", "0.0.0.0", self.config.port)
    log("Application is ready!")
end

function App:handle(msg)
    local req = WebServer.request:new():init(msg)
    local ctx = Dove.Context:new()
    ctx:init(req)
    Dispatcher.handle(ctx)
end
