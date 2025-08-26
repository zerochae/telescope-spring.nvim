-- Auto-setup with lazy.nvim opts or default config
vim.defer_fn(function()
  if not vim.g.spring_setup_called then
    -- Check if lazy.nvim passed opts
    local lazy_opts = vim.g.lazy_spring_opts or {}
    local spring = require("spring")
    spring.setup(lazy_opts)
    vim.g.spring_setup_called = true
  end
end, 100)