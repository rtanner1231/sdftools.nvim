local File = require("sdftools/util/fileutil")
local Config = require("sdftools/config")

local M = {}

local function cleansTSPath(tspath)
	if string.sub(tspath, 1, 1) ~= "/" then
		tspath = "/" .. tspath
	end
	if string.sub(tspath, string.len(tspath)) ~= "/" then
		tspath = tspath .. "/"
	end
	return tspath
end

--for the given path to the typescript file, return the javascript path
local resolve_typescript_file = function(tsfile, tspath)
	tspath = cleansTSPath(tspath)

	local ts_rem = string.gsub(tsfile, tspath, "")

	local res = File.pathcombine("/SuiteScripts", ts_rem)

	--we should only be here if last two characters are ts
	local ret = string.sub(res, 1, string.len(res) - 2) .. "js"

	return ret
end

--remove anything before /SuiteScripts in the path
local resolve_javascript_file = function(jsfile)
	local ind = string.find(jsfile, "/SuiteScripts")

	if ind == nil then
		return nil
	end

	return string.sub(jsfile, ind, string.len(jsfile))
end

--For each file in table files
--Update path to be relative to CWD
local get_relative_paths = function(files)
	local cwd = vim.fn.getcwd()

	local ret = {}

	for _, v in pairs(files) do
		local rel = string.gsub(v, cwd, "")
		table.insert(ret, rel)
	end

	return ret
end

local get_final_paths = function(relpaths)
	local final_paths = {}
	local is_typescript = false

	for _, v in pairs(relpaths) do
		local name = v
		local ext = File.getFileExt(name)

		if ext == ".js" or ext == ".ts" then
			if ext == ".ts" and Config.options.typescriptPath ~= nil then
				name = resolve_typescript_file(name, Config.options.typescriptPath)
				is_typescript = true
			elseif ext == ".js" then
				name = resolve_javascript_file(name)
			else
				name = nil
			end

			if name ~= nil then
				table.insert(final_paths, name)
			end
		end
	end

	return final_paths, is_typescript
end

local get_git_command_file_list = function(command)
	local result_lines = vim.fn.systemlist(command)

	local normalized_lines = {}

	for _, v in pairs(result_lines) do
		table.insert(normalized_lines, "/" .. v)
	end

	local final_paths, is_typescript = get_final_paths(normalized_lines)

	return final_paths, is_typescript
end

local get_file_list_from_files = function(files)
	local rel_paths = get_relative_paths(files)

	local final_paths, is_typescript = get_final_paths(rel_paths)

	--print(vim.inspect({files=files,rel_paths=rel_paths,final_paths=final_paths, is_typescript=is_typescript}))

	return final_paths, is_typescript
end

M.get_current_directory = function()
	local full_path = vim.api.nvim_buf_get_name(0)
	return File.getDirFromPath(full_path)
end

--opts: {typescript_path:string}
M.get_dir_file_list = function(recursive, dir)
	-- local full_path = vim.api.nvim_buf_get_name(0)
	--
	-- local dir = File.getDirFromPath(full_path)

	local dir_files = File.scanDir(dir, recursive)

	return get_file_list_from_files(dir_files)
end

M.get_single_file_list = function()
	local full_path = vim.api.nvim_buf_get_name(0)

	return get_file_list_from_files({ full_path })
end

M.get_last_commit_changes = function()
	return get_git_command_file_list("git diff --name-only HEAD~1")
end

M.get_unstaged_file_list = function()
	return get_git_command_file_list("git diff --name-only")
end

M.get_staged_file_list = function()
	return get_git_command_file_list("git diff --name-only --staged")
end

M.get_command_from_files = function(files)
	local param = ""

	for _, v in pairs(files) do
		if string.len(param) > 0 then
			param = param .. " "
		end

		param = param .. '"' .. v .. '"'
	end

	return "suitecloud file:upload --paths " .. param
end

return M
