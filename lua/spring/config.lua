local E = require "spring.enum"

local M = {
  prompt_title = E.default_config.prompt_title,
  cache_ttl = 5000, -- Cache time-to-live in milliseconds
  file_patterns = { "**/*.java" }, -- File patterns to search
  exclude_patterns = { "**/target/**", "**/build/**" }, -- Patterns to exclude
  rg_additional_args = "", -- Additional ripgrep arguments
  
  -- UI customization
  ui = {
    show_icons = false,   -- Show method icons (📥 GET, 📤 POST, etc.)
    show_method = true,   -- Show method text (GET, POST, PUT, DELETE)
    method_colors = {
      GET = "TelescopeResultsNumber",      -- Default: Green-ish
      POST = "TelescopeResultsConstant",   -- Default: Blue-ish  
      PUT = "TelescopeResultsKeyword",     -- Default: Orange-ish
      DELETE = "TelescopeResultsSpecialChar", -- Default: Red-ish
    },
    method_icons = {
      GET = "📥",    -- Recommended: meaningful icons
      POST = "📤", 
      PUT = "✏️",
      DELETE = "🗑️",
    },
  },
  
  get = {
    prompt_title = E.default_config.get_prompt_title,
  },
  post = {
    prompt_title = E.default_config.post_prompt_title,
  },
  put = {
    prompt_title = E.default_config.put_prompt_title,
  },
  delete = {
    prompt_title = E.default_config.delete_prompt_title,
  },
}

return M
