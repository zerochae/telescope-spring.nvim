local pickers = require "telescope.pickers"
local spring_finder = require "spring.finder"
local default_config = require("spring.enum").default_config

local spring_picker = function(opts)
  return pickers.new(opts, {
    prompt_title = default_config.prompt_title,
    finder = spring_finder,
  })
end

return function(opts)
  spring_picker(opts or {}):find()
end
