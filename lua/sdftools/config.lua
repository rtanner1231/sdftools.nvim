local M = {}

local defaults = {
	typescriptPath = "/TypeScripts/",
	sourceDir = "src",
	runTSBuildOnFileUpload = true,
	typescriptBuildCommand = "npm run build",
}

M.options = defaults

M.setup = function(opts)
	M.options = vim.tbl_deep_extend("force", defaults, opts)
end

return M
