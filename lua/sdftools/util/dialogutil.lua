

local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local M={}

local table_length=function(tbl)
    local count=0
    for _ in pairs(tbl) do
        count=count+1
    end
    return count

end

local max_chars=function(tbl)
    local max=0
    for _,v in pairs(tbl) do
        local cl=string.len(v)
        if cl>max then
            max=cl
        end
    end
    return max
end

M.confirm=function(message_lines,confirm_callback,cancel_callback)

    local message_height=table_length(message_lines)
    local max_width=max_chars(message_lines)

    local popup=Popup({
        enter=true,
        focusable=true,
        position="50%",
        size={
            height=message_height+2,
            width=max_width+5
        },
        border={
            style="rounded",
            text={
                bottom="[Y]es [N]o"
            }
        },
        buf_options={
            modifiable=true,
            readonly=false
        }
    })
    popup:mount()

    local confirm_keys={'Y','y','<enter>'}
    local cancel_keys={'N','n','<esc>'}



    for _,v in pairs(cancel_keys) do
        popup:map('n',v,function(bufnr)
            if(cancel_callback~=nil) then
                pcall(cancel_callback)
            end

            popup:unmount()
        end,{noremap=true})
    end
    
    for _,v in pairs(confirm_keys) do
        popup:map('n',v,function(bufnr)
            popup:unmount()
            if(confirm_callback~=nil) then
                pcall(confirm_callback)
            end

        end,{noremap=true})
    end



    popup:on(event.BufLeave, function()
        popup:unmount()
    end)

    local lines={''}

    for _,v in pairs(message_lines) do
        table.insert(lines,v)
    end

    vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, lines)

    vim.api.nvim_buf_set_option(popup.bufnr,'modifiable',false)
    vim.api.nvim_buf_set_option(popup.bufnr,'readonly',true)

end

--options: {option_text: string, value: string, [key:string]}
M.option=function(message,options,selection_callback)
    local option_text_vals={}

    for _,v in pairs(options) do
        table.insert(option_text_vals,v.option_text)
    end

    local max_width=max_chars(option_text_vals)+8

    if string.len(message)>max_width then
        max_width=string.len(message)+2
    end

    local height=table_length(options)

    local popup=Popup({
        enter=true,
        focusable=true,
        position="50%",
        size={
            height=height+2,
            width=max_width
        },
        border={
            style="rounded",
            text={
                top=message
            }
        },
        buf_options={
            modifiable=true,
            readonly=false
        }
    })
    popup:mount()

    local lines={''}

    local current_key=1
    local line_mapping_set={}

    for _,v in pairs(options) do

        local key_to_use=tostring(current_key)
        local key_text='['..current_key..']'

        if v.key~=nil then
            key_to_use=v.key
            key_text='['..v.key..']'
        end

        popup:map('n',key_to_use,function(bufnr)
            popup:unmount()
            selection_callback(v.value)

        end,{noremap=true})

        table.insert(lines,key_text..': '..v.option_text)

        line_mapping_set[current_key+1]=v.value
        current_key=current_key+1

        
    end

    popup:map('n','<enter>',function(bufnr)
        local r=vim.api.nvim__buf_stats(0).current_lnum
        if line_mapping_set[r]~=nil then
            popup:unmount()
            selection_callback(line_mapping_set[r])
        end
        
    end)

    popup:map('n','<esc>',function(bufnr)

        popup:unmount()
    end,{noremap=true})



    popup:on(event.BufLeave, function()
        popup:unmount()
    end)

    vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, lines)

    vim.api.nvim_buf_set_option(popup.bufnr,'modifiable',false)
    vim.api.nvim_buf_set_option(popup.bufnr,'readonly',true)
end

M.alert=function(message_lines)

    local message_height=table_length(message_lines)
    local max_width=max_chars(message_lines)

    local popup=Popup({
        enter=true,
        focusable=true,
        position="50%",
        size={
            height=message_height+2,
            width=max_width+5
        },
        border={
            style="rounded",
        },
        buf_options={
            modifiable=true,
            readonly=false
        }
    })
    popup:mount()

    local close_keys={'<esc>','q','<enter>'}



    for _,v in pairs(close_keys) do
        popup:map('n',v,function(bufnr)

            popup:unmount()
        end,{noremap=true})
    end
    



    popup:on(event.BufLeave, function()
        popup:unmount()
    end)

    local lines={''}

    for _,v in pairs(message_lines) do
        table.insert(lines,v)
    end

    vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, lines)

    vim.api.nvim_buf_set_option(popup.bufnr,'modifiable',false)
    vim.api.nvim_buf_set_option(popup.bufnr,'readonly',true)

end

return M;
