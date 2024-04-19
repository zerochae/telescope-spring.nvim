local previewers = require "telescope.previewers"

local bufnr = vim.api.nvim_get_current_buf()

local preview_by_method = function(self, entry, method)
  -- add content
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

  -- add syntax highlighting in previewer
  local ft = (vim.filetype.match { buf = bufnr } or "diff"):match "%w+"
  require("telescope.previewers.utils").highlighter(self.state.bufnr, ft)
end

local spring_previewer = function(method)
  return previewers.new_buffer_previewer {
    define_preview = function(self, entry)
      preview_by_method(self, entry, method)
    end,
  }
end

return spring_previewer
