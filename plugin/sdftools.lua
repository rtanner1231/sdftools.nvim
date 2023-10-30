local Common=require('sdftools/common')
local Commands=require('sdftools/commands')
local sdfTools=require('sdftools')

vim.api.nvim_create_user_command("SDF",function(opts)
   if #opts.fargs==0 then
    sdfTools.runCommand('Menu')
    return
   end

    if not Common.isSDFProject() then
        return
    end


    sdfTools.runCommand(opts.args)

end,{
        nargs='?',
        complete=function(_,_,_)
            local cList={}
            for _,v in pairs(Commands.command_list) do
                table.insert(cList,v.value)
            end
            return cList
        end

    })
