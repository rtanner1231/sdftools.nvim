
local M={}

local defaults={
    typescriptPath='/TypeScripts/',
    toggleTerm=false,
    terminalSplitDirection='Horizontal',
}

M.options=defaults

M.setup=function(opts)
    M.options=vim.tbl_deep_extend('force',defaults,opts)
end

return M
