local previewers = require "telescope.previewers"
local conf = require("telescope.config").values
local U = require "spring.util"

local create_preview_table = function(annotation)
  U.create_spring_preview_table(annotation)
end

return function(annotation)
  return previewers.new_buffer_previewer {
    define_preview = function(self, entry)
      create_preview_table(annotation)
      local spring_preview_table = U.get_spring_priview_table()
      local endpoint = entry[1]

      local path = spring_preview_table[endpoint].path
      local line_number = spring_preview_table[endpoint].line_number
      local column = spring_preview_table[endpoint].column
      entry.path = path
      entry.lnum = line_number
      entry.col = column
      local bufnr = self.state.bufnr

      conf.buffer_previewer_maker(path, bufnr, {
        callback = function()
          U.set_cursor_on_entry(entry, bufnr, self.state.winid)
        end,
      })
    end,
  }
end
