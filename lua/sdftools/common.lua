local File=require('sdftools/util/fileutil')

local M={}

M.projectsFilePath=function()
    local cwd=vim.fn.getcwd()
    return File.pathcombine(cwd,'project.json')
end

M.getSDFAccountTable=function()

    local projPath=M.projectsFilePath()
    if File.fileExists(projPath) then
        local content=File.readFile(projPath)
        local projTable=vim.json.decode(content)
        return projTable
    else
        return nil
    end
end

M.getSuiteCloudAccount =function()
    local accountTable=M.getSDFAccountTable()
    if accountTable then
        return accountTable.defaultAuthId
    else
        return ''
    end
end

M.isSDFProject=function()

    local project_path=M.projectsFilePath()
    if File.fileExists(project_path)==true then
        return true
    else
        return false
    end
end

return M
