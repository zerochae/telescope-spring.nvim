local previewers = require "telescope.previewers"
local conf = require("telescope.config").values
local util = require "endpoint.util"

local create_preview_table = function(method)
  -- TODO: Update to use framework-agnostic preview table creation
  -- For now, convert method to annotation for backward compatibility
  local annotation = "@" .. method:sub(1, 1):upper() .. method:sub(2):lower() .. "Mapping"
  util.create_spring_preview_table(annotation)
end

return function(method)
  return previewers.new_buffer_previewer {
    define_preview = function(self, entry)
      create_preview_table(method)
      local preview_table = util.get_preview_table()
      local endpoint = entry.value

      -- Check if preview table entry exists
      if not preview_table[endpoint] then
        vim.notify("Preview data not found for: " .. tostring(endpoint), vim.log.levels.WARN)
        return
      end

      local path = preview_table[endpoint].path
      local line_number = preview_table[endpoint].line_number
      local column = preview_table[endpoint].column
      entry.path = path
      entry.lnum = line_number
      entry.col = column
      local bufnr = self.state.bufnr

      conf.buffer_previewer_maker(path, bufnr, {
        callback = function()
          vim.schedule(function()
            util.set_cursor_on_entry(entry, bufnr, self.state.winid)

            -- Add highlighting for the annotation line
            local ns_id = vim.api.nvim_create_namespace "spring_annotation_highlight"
            vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

            if entry.lnum then
              vim.api.nvim_buf_add_highlight(
                bufnr,
                ns_id,
                "TelescopePreviewMatch", -- Use Telescope's match highlight
                entry.lnum - 1, -- 0-indexed
                0,
                -1
              )
            end
          end)
        end,
      })
    end,
  }
end
