local _M = commonlib.gettable("Dove.Generator")
local PathHelper = commonlib.gettable("Dove.Utils.PathHelper")
local lfs = commonlib.Files.GetLuaFileSystem()

local function assert_folder(app_path)
    local attr = lfs.attributes(app_path)
    if attr.mode == "directory" then
        error(format("Folder %s already exist!", app_path))
    end
end

function _M.gen_app(app_name, options)
    local sample_path = PathHelper.concat(os.getenv("NPL_PACKAGES"), "/dove/npl_mod/dove/cli/sample-app/.")
    local app_path = PathHelper.concat(lfs.currentdir(), app_name)
    assert_folder(app_path)
    lfs.mkdir(app_path)
    assert(os.execute(format("cp -a '%s' '%s'", sample_path, app_path)))
    print(format("Generate app succeed! input cd %s to check the code.", app_name))
end

function _M.gen_model(model_name, options)
    -- TODO
end
