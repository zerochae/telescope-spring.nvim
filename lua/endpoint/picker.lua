local pickers = require "telescope.pickers"
local endpoint_finder = require "endpoint.finder"
local endpoint_previewer = require "endpoint.previewer"
local endpoint_actions = require "endpoint.actions"
local conf = require("telescope.config").values

return function(opts, method)
  opts = opts or {}
  -- Cache management is now handled automatically by the framework system

  -- Use method directly instead of converting to annotation
  local finder = endpoint_finder(method)
  local previewer = endpoint_previewer(method)
  local sorter = conf.generic_sorter()

  return pickers
    .new(opts, {
      prompt_title = " Endpoint",
      preview_title = "  Preview",
      finder = finder,
      previewer = previewer,
      sorter = sorter,
      attach_mappings = endpoint_actions,
    })
    :find()
end
