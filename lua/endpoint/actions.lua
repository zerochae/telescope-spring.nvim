local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local util = require "endpoint.util"

return function(prompt_bufnr)
  actions.select_default:replace(function()
    actions.close(prompt_bufnr)
    local entry = action_state.get_selected_entry()

    if not entry then
      return
    end

    -- Get the actual file path from preview table
    local preview_table = util.get_preview_table()
    local endpoint = entry.value

    if not preview_table[endpoint] then
      vim.notify("Action data not found for: " .. tostring(endpoint), vim.log.levels.ERROR)
      return
    end

    local file_path = preview_table[endpoint].path

    vim.cmd("edit " .. file_path)

    local bufnr = vim.fn.bufnr()

    vim.api.nvim_set_current_buf(bufnr)
    vim.schedule(function()
      -- Create entry with path info for cursor positioning
      local cursor_entry = {
        path = file_path,
        lnum = preview_table[endpoint].line_number,
        col = preview_table[endpoint].column,
      }
      util.set_cursor_on_entry(cursor_entry, bufnr, 0)
    end)
  end)
  return true
end
