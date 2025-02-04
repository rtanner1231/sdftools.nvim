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

local runCommandInPopup = function(command)
	-- Open a floating window to act as the terminal
	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.6)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = (vim.o.lines - height) / 2,
		col = (vim.o.columns - width) / 2,
		style = "minimal",
		border = "single",
	})

	-- Start the terminal in the buffer and run the command
	vim.fn.termopen(command)

	-- Function to close the window and delete the buffer
	local close_popup = function()
		vim.api.nvim_buf_delete(buf, { force = true }) -- Delete the buffer
	end

	-- Map the 'q' key to close the popup window and delete the buffer
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
		noremap = true,
		silent = true,
		callback = close_popup, -- Use the callback to call the function
	})

	-- Set up an autocommand to close the popup when the window loses focus
	local close_on_lose_focus = vim.api.nvim_create_augroup("ClosePopupOnLoseFocus", { clear = true })
	vim.api.nvim_create_autocmd("WinLeave", {
		group = close_on_lose_focus,
		buffer = buf,
		callback = close_popup,
	})
end

M.runCommand = function(command)
	runCommandInPopup(command)
end

return M
