local picker = {}

local Path = require("plenary.path")
local popup = require("plenary.popup")

local fileutil = require("sdftools.util.fileutil")

-- Helper function to get the list of directories in the given path
-- local function get_directories(path)
-- 	return fileutil.scanDirDirectories(path)
-- end

local function get_directories(path)
	local directories = fileutil.scanDirDirectories(path)
	local result = {}
	for _, dir_path in ipairs(directories) do
		local name = dir_path:match("([^/]+)$")
		table.insert(result, { path = dir_path, name = " " .. name })
	end
	return result
end

local function get_dir_names(dirs)
	local result = {}
	for _, dir in ipairs(dirs) do
		table.insert(result, dir.name)
	end
	return result
end

local function get_parent_dir(path)
	return Path:new(path):parent():absolute()
end

local function get_directories_in_same_level(path)
	local parent_dir = get_parent_dir(path)
	return get_directories(parent_dir)
end

local function find_index_by_path(list, path)
	for i, entry in ipairs(list) do
		if entry.path == path then
			return i
		end
	end
	return nil
end

local function lock_buffer(bufnr)
	vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
end

local function unlock_buffer(bufnr)
	vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
end

-- Function to create and display the directory picker
function picker.open_directory_picker(callback, selectedDirectory)
	local cwd = vim.fn.getcwd()
	local initialDirectory = cwd
	if selectedDirectory then
		initialDirectory = get_parent_dir(selectedDirectory)
	end
	print(initialDirectory)
	local directories = get_directories(initialDirectory)
	local selected_index = 1

	-- Create a floating window
	local width = 50
	local height = 10
	local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
	local win_id, win = popup.create(get_dir_names(directories), {
		title = "Upload Directory (l=down, k=up)",
		borderchars = borderchars,
		minwidth = width,
		minheight = height,
		pos = "center",
		highlight = "DirectoryPicker",
		borderhighlight = "DirectoryPickerBorder",
	})

	if selectedDirectory then
		local initial_index = find_index_by_path(directories, selectedDirectory)
		if initial_index then
			selected_index = initial_index
			vim.api.nvim_win_set_cursor(win.win_id, { initial_index, 0 })
		end
	end

	local winBuf = vim.api.nvim_win_get_buf(win.win_id)

	lock_buffer(winBuf)

	vim.api.nvim_set_option_value("cursorline", true, { win = win.win_id })

	-- Prevent entering insert mode by using an autocmd
	vim.api.nvim_create_autocmd("BufEnter", {
		buffer = winBuf,
		callback = function()
			vim.cmd("setlocal noinsertmode")
		end,
	})

	-- Keybindings
	vim.api.nvim_buf_set_keymap(winBuf, "n", "j", "", {
		callback = function()
			selected_index = math.min(selected_index + 1, #directories)
			vim.api.nvim_win_set_cursor(win.win_id, { selected_index, 0 })
		end,
	})

	vim.api.nvim_buf_set_keymap(winBuf, "n", "k", "", {
		callback = function()
			selected_index = math.max(selected_index - 1, 1)
			vim.api.nvim_win_set_cursor(win.win_id, { selected_index, 0 })
		end,
	})

	vim.api.nvim_buf_set_keymap(winBuf, "n", "l", "", {
		callback = function()
			local selected_dir = directories[selected_index]
			local oldDirectories = directories
			directories = get_directories(selected_dir.path)
			if #directories == 0 then
				directories = oldDirectories
				return
			end
			unlock_buffer(winBuf)
			vim.api.nvim_buf_set_lines(winBuf, 0, -1, false, get_dir_names(directories))
			selected_index = 1
			vim.api.nvim_win_set_cursor(win.win_id, { selected_index, 0 })
			lock_buffer(winBuf)
		end,
	})

	vim.api.nvim_buf_set_keymap(winBuf, "n", "h", "", {
		callback = function()
			local parent_dir = Path:new(directories[selected_index].path):parent():absolute()
			if parent_dir == cwd then
				return
			end
			directories = get_directories_in_same_level(parent_dir)
			unlock_buffer(winBuf)
			vim.api.nvim_buf_set_lines(winBuf, 0, -1, false, get_dir_names(directories))
			selected_index = 1
			vim.api.nvim_win_set_cursor(win.win_id, { selected_index, 0 })
			lock_buffer(winBuf)
		end,
	})

	vim.api.nvim_buf_set_keymap(winBuf, "n", "<CR>", "", {
		callback = function()
			local selected_dir = directories[selected_index]
			vim.api.nvim_win_close(win.win_id, true)
			callback(selected_dir.path)
		end,
	})

	vim.api.nvim_buf_set_keymap(winBuf, "n", "q", "", {
		callback = function()
			vim.api.nvim_win_close(win.win_id, true)
		end,
	})
end

return picker
