local config=require('sdftools/config')
local Commands=require('sdftools/commands')
local Dialog=require('sdftools/util/dialogutil')

local M={}



M.runCommand=function(command)
    if command=='Menu' then
        M.show_function_menu()
        return
    end

    for _,v in pairs(Commands.command_list) do
        if v.value==command then
            v.callback()
            return
        end
    end
end

M.show_function_menu=function()
    local menu_list={}
    for _,v in pairs(Commands.command_list) do
        if v.value~='Menu' then
            table.insert(menu_list,v)
        end
    end


    Dialog.option('Select Command',menu_list,M.runCommand)
end

M.setup=config.setup

M.commands=Commands.command_list

return M
