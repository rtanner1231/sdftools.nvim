local File = require("sdftools/util/fileutil")

local M = {}

M.projectsFilePath = function()
    local cwd = vim.fn.getcwd()
    return File.pathcombine(cwd, "project.json")
end

M.getSDFAccountTable = function()
    local projPath = M.projectsFilePath()
    if File.fileExists(projPath) then
        local content = File.readFile(projPath)
        local projTable = vim.json.decode(content)
        return projTable
    else
        --this is the current structure of the project.json file.
        --This is somewhat brittle since Netsuite could change the structure
        return {
            defaultAuthId = ""
        }
    end
end

M.getSuiteCloudAccount = function()
    local accountTable = M.getSDFAccountTable()
    if accountTable then
        return accountTable.defaultAuthId
    else
        return ""
    end
end

M.isSDFProject = function()
    local project_path = M.projectsFilePath()
    if File.fileExists(project_path) == true then
        return true
    else
        return false
    end
end

M.splitString = function(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

return M
