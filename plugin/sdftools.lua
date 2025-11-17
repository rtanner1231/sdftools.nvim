local Common = require('sdftools/common')
local Commands = require('sdftools/commands')
local sdfTools = require('sdftools')

vim.api.nvim_create_user_command("SDF", function(opts)
    local run_command = function()
        if #opts.fargs == 0 then
            sdfTools.runCommand('Menu')
            return
        end
        sdfTools.runCommand(opts.args)
    end

    --Check if the current project already has a project.json file
    if not Common.isSDFProject() then
        --If not, allow the user to select an account which will create the file
        --Calls the run_command function when the account is selected
        --Doing it this way because the select dialog runs async
        sdfTools.initialize_project(run_command)

        return
    end


    run_command()
end, {
    nargs = '?',
    complete = function(_, _, _)
        local cList = {}
        for _, v in pairs(Commands.command_list) do
            table.insert(cList, v.value)
        end
        return cList
    end

})
