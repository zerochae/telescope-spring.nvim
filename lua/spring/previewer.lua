local previewers = require "telescope.previewers"
local conf = require("telescope.config").values
local U = require "spring.util"

local previewer = function(self, entry)
  local preview_table = U.get_spring_priviewer_table()
  local endpoint = entry[1]

  local path = preview_table[endpoint].path
  local line_number = preview_table[endpoint].line_number
  local column = preview_table[endpoint].column
  entry.lnum = line_number
  entry.col = column
  local bufnr = self.state.bufnr

  conf.buffer_previewer_maker(path, bufnr, {
    callback = function()
      local lnum, lnend = entry.lnum - 1, (entry.lnend or entry.lnum) - 1
      local middle_ln = math.floor(lnum + (lnend - lnum) / 2)
      pcall(vim.api.nvim_win_set_cursor, self.state.winid, { middle_ln, 0 })
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd "norm! zz"
      end)
    end,
  })
end

local spring_previewer = function()
  return previewers.new_buffer_previewer {
    define_preview = previewer,
  }
end

return spring_previewer
