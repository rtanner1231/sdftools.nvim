local config = require("sdftools/config")
local Common = require("sdftools/common")
local Popup = require("nui.popup")

local M = {}

local runToggleTerm = function(command)
	local full_command = "TermExec cmd='" .. command .. "'"
	vim.cmd(full_command)
end

local runTerminal = function(command)
	if config.options.terminalSplitDirection == "Vertical" then
		vim.cmd("vsplit")
	else
		vim.cmd("split")
	end

	vim.cmd("terminal " .. command)
end

-- local runNotify = function(command)
--
--     local outPopup=Popup()
--
--
-- 	local outData = ""
-- 	vim.fn
-- 		.jobstart(command, {
-- 			on_stdout = function(_, data)
-- 				for _, v in pairs(data) do
-- 					print(v)
-- 				end
-- 			end,
-- 			on_stderr = function(_, data)
-- 				for _, v in pairs(data) do
-- 					print(v)
-- 				end
-- 			end,
-- 		})
-- 		:wait()
-- 	vim.api.nvim_notify(outData, vim.log.levels.INFO, {})
-- end

M.runCommand = function(command)
	--runNotify(command)

	if config.options.toggleTerm then
		runToggleTerm(command)
	else
		runTerminal(command)
	end
end

return M
