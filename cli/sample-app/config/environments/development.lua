--[[
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
}
]]

local config = APP.config

config.file_watcher.enabled = true
