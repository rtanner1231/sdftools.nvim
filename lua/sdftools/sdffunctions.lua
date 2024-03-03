local Dialog=require('sdftools/util/dialogutil')
local File=require('sdftools/util/fileutil')
local Common=require('sdftools/common')
local FileDeploy=require('sdftools/filedeploy')
local Output=require('sdftools/output')
local Objects=require('sdftools/objects')
local Config=require('sdftools/config')


local M={}

local deploy_project=function()
    local sdf_account=Common.getSuiteCloudAccount()

    local message={sdf_account,"Are you sure you want to deploy?"}

    Dialog.confirm(message,function()
        Output.runCommand('suitecloud project:deploy')
    end)



end


local set_sdf_account=function(sdf_account)
    local sdfTable=Common.getSDFAccountTable()
    sdfTable.defaultAuthId=sdf_account
    local project_path=Common.projectsFilePath()
    File.writeFile(project_path,vim.json.encode(sdfTable))
end


local get_sdf_accounts=function()
    local result=vim.fn.systemlist("suitecloud account:manageauth --list")

    result[1]=result[1]:match("^........(.*)")
    local res={}
    for _,v in pairs(result) do
        local val=v:match("^([^|]+) |")
        table.insert(res,{option_text=v,value=val})
    end


    return res
end

local deploy_files=function(file_list,is_typescript)
    if #file_list==0 then
        Dialog.alert({'No files to deploy'})
        return
    end

    local sdf_account=Common.getSuiteCloudAccount()
    local confirm_message={sdf_account,"Deploy the following files?"}

    for _,v in pairs(file_list) do
        table.insert(confirm_message,v)
    end

    Dialog.confirm(confirm_message,function()
        local command=FileDeploy.get_command_from_files(file_list)

        if is_typescript and Config.options.runTSBuildOnFileUpload then
            command=Config.options.typescriptBuildCommand..' && '..command
        end

        Output.runCommand(command)
    end)
end


--------------------------------------------------------------------------------Entry functions


M.deploy=function()

    deploy_project()
end

M.select_account=function()

    local accounts=get_sdf_accounts()
    Dialog.option('Select SDF Account',accounts,set_sdf_account)
end

M.deploy_dir=function()
    local files,is_typescript=FileDeploy.get_dir_file_list()

    deploy_files(files,is_typescript)

end

M.deploy_file=function()

    local files,is_typescript=FileDeploy.get_single_file_list()

    deploy_files(files,is_typescript)
end

M.deploy_git_last_commit=function()
    local files,is_typescript=FileDeploy.get_last_commit_changes()

    deploy_files(files,is_typescript)
end

M.deploy_git_unstaged=function()
    local files,is_typescript=FileDeploy.get_unstaged_file_list()
    deploy_files(files,is_typescript)
end

M.deploy_git_staged=function()
    local files,is_typescript=FileDeploy.get_staged_file_list()
    deploy_files(files,is_typescript)
end

M.import_objects=function()
    Objects.importObjects()
end


return M
