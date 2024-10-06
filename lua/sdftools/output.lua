local config = require("sdftools/config")

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

M.runCommand = function(command)
	if config.options.toggleTerm then
		runToggleTerm(command)
	else
		runTerminal(command)
	end
end

return M
