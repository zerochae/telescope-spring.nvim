local enums = require "endpoint.enum"

local M = {
  prompt_title = enums.default_config.prompt_title,
  cache_ttl = 5000, -- Cache time-to-live in milliseconds
  cache_mode = "persistent", -- Cache mode: "time" (uses TTL), "session" (valid until nvim closes), or "persistent" (file-based cache)
  debug = false, -- Enable debug logging
  
  -- Framework detection
  framework = "auto", -- "auto" for auto-detection, or specify: "spring", "nestjs", "django", "rails", "express"
  framework_paths = {}, -- Path-specific framework overrides: { ["/path/to/project"] = "spring" }
  
  -- Framework-specific configurations
  frameworks = {
    spring = {
      file_patterns = { "**/*.java" },
      exclude_patterns = { "**/target/**", "**/build/**" },
      detection_files = { "pom.xml", "build.gradle", "application.properties", "application.yml" },
      patterns = {
        get = { "@GetMapping", "@RequestMapping.*method.*=.*GET" },
        post = { "@PostMapping", "@RequestMapping.*method.*=.*POST" },
        put = { "@PutMapping", "@RequestMapping.*method.*=.*PUT" },
        delete = { "@DeleteMapping", "@RequestMapping.*method.*=.*DELETE" },
        patch = { "@PatchMapping", "@RequestMapping.*method.*=.*PATCH" },
      },
    },
    nestjs = {
      file_patterns = { "**/*.ts" },
      exclude_patterns = { "**/node_modules/**", "**/dist/**" },
      detection_files = { "package.json" }, -- Will check for @nestjs/* deps
      patterns = {
        get = { "@Get\\(" },
        post = { "@Post\\(" },
        put = { "@Put\\(" },
        delete = { "@Delete\\(" },
        patch = { "@Patch\\(" },
      },
    },
    django = {
      file_patterns = { "**/*.py" },
      exclude_patterns = { "**/__pycache__/**", "**/venv/**", "**/env/**" },
      detection_files = { "manage.py", "requirements.txt", "pyproject.toml" },
      patterns = {
        get = { "def.*get.*\\(", "path\\(.*view.*get" },
        post = { "def.*post.*\\(", "path\\(.*view.*post" },
        put = { "def.*put.*\\(", "path\\(.*view.*put" },
        delete = { "def.*delete.*\\(", "path\\(.*view.*delete" },
        patch = { "def.*patch.*\\(", "path\\(.*view.*patch" },
      },
    },
    rails = {
      file_patterns = { "**/*.rb" },
      exclude_patterns = { "**/tmp/**", "**/log/**" },
      detection_files = { "Gemfile", "config/routes.rb" },
      patterns = {
        get = { "get\\s+['\"]", "def\\s+show", "def\\s+index" },
        post = { "post\\s+['\"]", "def\\s+create" },
        put = { "put\\s+['\"]", "patch\\s+['\"]", "def\\s+update" },
        delete = { "delete\\s+['\"]", "def\\s+destroy" },
        patch = { "patch\\s+['\"]", "def\\s+update" },
      },
    },
    express = {
      file_patterns = { "**/*.js", "**/*.ts" },
      exclude_patterns = { "**/node_modules/**", "**/dist/**" },
      detection_files = { "package.json" }, -- Will check for express deps
      patterns = {
        get = { "\\.get\\(", "router\\.get" },
        post = { "\\.post\\(", "router\\.post" },
        put = { "\\.put\\(", "router\\.put" },
        delete = { "\\.delete\\(", "router\\.delete" },
        patch = { "\\.patch\\(", "router\\.patch" },
      },
    },
  },

  -- Backward compatibility - will be overridden by framework detection
  file_patterns = { "**/*.java" }, -- Fallback if detection fails
  exclude_patterns = { "**/target/**", "**/build/**" }, -- Fallback if detection fails
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
