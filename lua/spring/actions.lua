local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local U = require "spring.util"

return function(prompt_bufnr)
  actions.select_default:replace(function()
    actions.close(prompt_bufnr)
    local entry = action_state.get_selected_entry()

    if not entry then
      return
    end

    vim.cmd("edit " .. entry.path)

    local bufnr = vim.fn.bufnr()

    vim.api.nvim_set_current_buf(bufnr)
    U.set_cursor_on_entry(entry, bufnr, 0)
  end)
  return true
end
