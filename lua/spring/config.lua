local enums = require "spring.enum"

local M = {
  prompt_title = enums.default_config.prompt_title,
  cache_ttl = 5000, -- Cache time-to-live in milliseconds
  cache_mode = "time", -- Cache mode: "time" (uses TTL) or "session" (valid until nvim closes)
  file_patterns = { "**/*.java" }, -- File patterns to search
  exclude_patterns = { "**/target/**", "**/build/**" }, -- Patterns to exclude
  rg_additional_args = "", -- Additional ripgrep arguments

  -- UI customization
  ui = {
    show_icons = false, -- Show method icons (📥 GET, 📤 POST, etc.)
    show_method = true, -- Show method text (GET, POST, PUT, DELETE)
    method_colors = {
      GET = "TelescopeResultsNumber", -- Default: Green-ish
      POST = "TelescopeResultsConstant", -- Default: Blue-ish
      PUT = "TelescopeResultsKeyword", -- Default: Orange-ish
      DELETE = "TelescopeResultsSpecialChar", -- Default: Red-ish
      PATCH = "TelescopeResultsFunction", -- Default: Purple-ish
    },
    method_icons = {
      GET = "📥", -- Recommended: meaningful icons
      POST = "📤",
      PUT = "✏️",
      DELETE = "🗑️",
      PATCH = "🔧", -- Wrench (fixing/patching)
    },
  },

  get = {
    prompt_title = enums.default_config.get_prompt_title,
  },
  post = {
    prompt_title = enums.default_config.post_prompt_title,
  },
  put = {
    prompt_title = enums.default_config.put_prompt_title,
  },
  delete = {
    prompt_title = enums.default_config.delete_prompt_title,
  },
  patch = {
    prompt_title = enums.default_config.patch_prompt_title,
  },
}

return M
