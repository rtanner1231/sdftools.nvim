local sdffunction=require('sdftools.sdffunctions')

local M={}

M.command_list={
    {option_text="Menu", value="Menu"},
    {option_text="Deploy",value="Deploy", callback=sdffunction.deploy},
    {option_text="Deploy Current Folder",value="DeployCurrentFolder",callback=sdffunction.deploy_dir},
    {option_text="Deploy Current File",value="DeployCurrentFile",callback=sdffunction.deploy_file},
    --{option_text="Deploy Changes Since Last Commit", value="GitDeployLastCommit",callback=sdffunction.deploy_git_last_commit},
    {option_text="Deploy Unstaged changes",value="GitDeployUnstaged",callback=sdffunction.deploy_git_unstaged},
    {option_text="Deploy Staged Changes",value="GitDeployStaged",callback=sdffunction.deploy_git_staged},
    {option_text="Select Account",value="SelectAccount",callback=sdffunction.select_account},
    {option_text="Import Objects",value="ImportObjects",callback=sdffunction.import_objects},
}

return M
