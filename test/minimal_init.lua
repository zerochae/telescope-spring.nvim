-- test/minimal_init.lua

-- Set up runtimepath to include dependencies and the current plugin
local project_root = vim.fn.fnamemodify("./", ":p")
local deps_path = project_root .. "test/deps"

vim.opt.runtimepath:prepend(deps_path .. "/plenary.nvim")
vim.opt.runtimepath:prepend(deps_path .. "/telescope.nvim")
vim.opt.runtimepath:prepend(project_root)

-- Minimal configuration for telescope
-- We need to load telescope before setting it up
require("telescope")
require("telescope").setup {}

-- Plenary is automatically loaded by busted, so no extra setup is needed.
