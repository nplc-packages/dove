local _M = commonlib.gettable("Dove.Generator")
local PathHelper = commonlib.gettable("Dove.Utils.PathHelper")
local lfs = commonlib.Files.GetLuaFileSystem()

local function assert_app(app_path)
    local attr = lfs.attributes(PathHelper.concat(app_path, "boot.lua"))
    if attr and attr.mode == "file" then
        error("Your app was already initialized! Please dont't init again!")
    end
end

function _M.gen_app(options)
    local sample_path = PathHelper.concat("cli/sample-app/.")
    local app_path = lfs.currentdir()
    assert_app(app_path)
    assert(os.execute(format("cp -a '%s' '%s'", sample_path, app_path)))
    print(format("Generate app succeed!"))
end

function _M.gen_model(model_name, options)
    -- TODO
end
