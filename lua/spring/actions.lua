local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

return function(prompt_bufnr)
  actions.select_default:replace(function()
    actions.file_edit { prompt_bufnr }
    -- local entry = action_state.get_selected_entry()
    -- actions.close(prompt_bufnr)
  end)
  return true
end
