# telescope-spring.nvim

A powerful Telescope picker for quickly finding and navigating Spring Boot API endpoints with customizable UI and smart caching.

## ✨ Features

- 🔍 **Fast Endpoint Discovery**: Quickly find Spring Boot API endpoints by HTTP method
- 🎨 **Customizable UI**: Configurable icons, colors, and display options
- ⚡ **Smart Caching**: Multiple cache modes including persistent disk storage
- 🔗 **Path Variable Support**: Handles complex path variables and RequestMapping patterns
- 📍 **Precise Navigation**: Jump directly to the exact line with annotation highlighting
- 🌈 **Syntax Highlighting**: Preview window with Java syntax highlighting
- 🔧 **Easy Setup**: Just call `require("spring").setup()` to get started

## 🚀 Usage

### Simple Commands (Recommended)

```vim
:Spring Get      " Find all GET endpoints
:Spring Post     " Find all POST endpoints  
:Spring Put      " Find all PUT endpoints
:Spring Delete   " Find all DELETE endpoints
:Spring Patch    " Find all PATCH endpoints
```

### Cache Management Commands

```vim
:Spring ClearCache    " Clear all cached data
:Spring CacheStatus   " Show current cache status
```

### Alternative Commands

```vim
:SpringGetMapping     " Find all GET endpoints
:SpringPostMapping    " Find all POST endpoints  
:SpringPutMapping     " Find all PUT endpoints
:SpringDeleteMapping  " Find all DELETE endpoints
:SpringPatchMapping   " Find all PATCH endpoints
```

### Telescope Extension

```vim
:Telescope spring        " Default picker
:Telescope spring get    " GET endpoints
:Telescope spring post   " POST endpoints
:Telescope spring put    " PUT endpoints
:Telescope spring delete " DELETE endpoints
:Telescope spring patch  " PATCH endpoints
```

## 📦 Installation

> **⚠️ Important**: You must call `require("spring").setup()` in a `config` function for the plugin to work properly. The `opts` table alone is not sufficient.

### lazy.nvim

```lua
{
  "zerochae/telescope-spring.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  cmd = {
    "Spring",
    "SpringGetMapping",
    "SpringPostMapping",
    "SpringPutMapping", 
    "SpringDeleteMapping",
    "SpringPatchMapping",
  },
  config = function()
    require("spring").setup({
      -- Optional: customize settings
      cache_ttl = 5000, -- Cache time in milliseconds (time/session modes)
      cache_mode = "time", -- Cache mode: "time", "session", or "persistent"
      debug = false, -- Enable debug logging
      
      ui = {
        show_icons = true,   -- Show method icons
        show_method = true,  -- Show method text (GET, POST, etc.)
        
        -- Customize icons (requires show_icons = true)
        method_icons = {
          GET    = "📥",
          POST   = "📤", 
          PUT    = "✏️",
          DELETE = "🗑️",
          PATCH  = "🔧",
        },
        
        -- Customize colors
        method_colors = {
          GET    = "DiagnosticOk",      -- Green
          POST   = "DiagnosticInfo",    -- Blue
          PUT    = "DiagnosticWarn",    -- Yellow
          DELETE = "DiagnosticError",   -- Red
          PATCH  = "DiagnosticHint",    -- Purple
        },
      },
    })
  end,
}
```

### lazy.nvim

```lua
{
  "zerochae/telescope-spring.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  cmd = {
    "Spring",
    "SpringGetMapping",
    "SpringPostMapping",
    "SpringPutMapping", 
    "SpringDeleteMapping",
    "SpringPatchMapping",
  },
  config = function()
    require("spring").setup({
      ui = {
        show_icons = true,
        show_method = true,
      },
    })
  end,
}
```

### packer.nvim

```lua
use {
  "zerochae/telescope-spring.nvim",
  requires = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("spring").setup() -- This is required!
  end,
}
```

## ⚙️ Configuration

### Default Configuration

```lua
require("spring").setup({
  cache_ttl = 5000,                         -- Cache TTL in milliseconds (time/session modes)
  cache_mode = "time",                      -- Cache mode: "time", "session", or "persistent"
  debug = false,                            -- Enable debug logging
  file_patterns = { "**/*.java" },          -- File patterns to search
  exclude_patterns = {                      -- Patterns to exclude
    "**/target/**", 
    "**/build/**" 
  },
  
  ui = {
    show_icons = false,                     -- Show method icons
    show_method = true,                     -- Show method text
    
    method_colors = {
      GET = "TelescopeResultsNumber",
      POST = "TelescopeResultsConstant", 
      PUT = "TelescopeResultsKeyword",
      DELETE = "TelescopeResultsSpecialChar",
      PATCH = "TelescopeResultsFunction",
    },
    
    method_icons = {
      GET = "📥",
      POST = "📤",
      PUT = "✏️", 
      DELETE = "🗑️",
      PATCH = "🔧",
    },
  },
})
```

### Display Options

You can customize how endpoints are displayed:

```lua
-- Option 1: Icons only
ui = {
  show_icons = true,
  show_method = false,
}
-- Result: 📥 /api/users

-- Option 2: Method text only (default)
ui = {
  show_icons = false,
  show_method = true,
}
-- Result: GET /api/users

-- Option 3: Both icons and method text
ui = {
  show_icons = true,
  show_method = true,
}
-- Result: 📥 GET /api/users

-- Option 4: Minimal (path only)
ui = {
  show_icons = false,
  show_method = false,
}
-- Result: /api/users
```

### Icon Themes

Choose from different icon themes:

```lua
-- Theme 1: Meaningful Icons (Default)
method_icons = {
  GET    = "📥",  -- Inbox (receiving data)
  POST   = "📤",  -- Outbox (sending data)
  PUT    = "✏️",   -- Pencil (editing)
  DELETE = "🗑️",  -- Trash (deleting)
  PATCH  = "🔧",  -- Wrench (fixing/patching)
}

-- Theme 2: Geometric
method_icons = {
  GET    = "▼",   -- Down arrow
  POST   = "▲",   -- Up arrow
  PUT    = "◆",   -- Diamond
  DELETE = "✖",   -- X mark
  PATCH  = "◉",   -- Circle with dot
}
```

## 🔧 Advanced Features

### Caching System

The plugin includes an intelligent caching system with three modes:

```lua
{
  cache_ttl = 10000,   -- Cache for 10 seconds (time/session modes only)
  cache_mode = "time", -- Cache mode: "time", "session", or "persistent"
  debug = false,       -- Enable debug logging for troubleshooting
}
```

**Cache Modes:**
- `"time"`: Cache expires after the specified TTL (default)
- `"session"`: Cache remains valid until nvim is closed
- `"persistent"`: Cache is saved to disk and persists across nvim sessions

### Persistent Cache Mode

The persistent cache mode offers the best performance for large projects:

```lua
require("spring").setup({
  cache_mode = "persistent",
  debug = false, -- Set to true for troubleshooting
})
```

**Features:**
- 📁 **Project-specific caching**: Each project gets its own cache directory
- 💾 **Disk storage**: Cache survives nvim restarts and system reboots  
- 🚀 **Instant loading**: No re-scanning on subsequent launches
- 🔄 **Smart invalidation**: Automatically detects when annotations need re-scanning
- 🗂️ **Cache location**: `~/.local/share/nvim/telescope-spring/[project-name]/`

**Cache Management:**
```vim
:SpringClearCache    " Clear all cache files for current project
:SpringCacheStatus   " Show detailed cache information
```

**Cache Files Structure:**
```
~/.local/share/nvim/telescope-spring/my-project/
├── find_cache.lua    " Endpoint data (paths, methods, locations)
└── metadata.lua      " Scan history and project metadata
```

**When to use persistent mode:**
- ✅ Large Spring Boot projects with many controllers
- ✅ Frequent nvim restarts during development
- ✅ Want maximum performance after initial scan
- ❌ Small projects (overhead not worth it)
- ❌ Controllers change very frequently

### Custom File Patterns

Customize which files to search:

```lua
{
  file_patterns = { "**/*.java", "**/*.kt" },  -- Java and Kotlin
  exclude_patterns = { 
    "**/target/**", 
    "**/build/**", 
    "**/node_modules/**" 
  },
}
```

## 🖥️ Demo

![demo](https://github.com/zerochae/telescope-spring.nvim/assets/84373490/2ec7c4d3-d91d-458d-a42d-06dbbff9d541)

### Search by RequestMapping Value
![search by request mapping value](https://github.com/zerochae/telescope-spring.nvim/assets/84373490/90bd05c7-87ee-4a4d-a1bc-d7a55f4a9cea)

### Search Variable Values  
![Search in variable path](https://github.com/zerochae/telescope-spring.nvim/assets/84373490/3622ea76-096a-4eb4-8e49-c328798fbbb7)

## ⚡️ Requirements

- [Neovim](https://neovim.io/) >= 0.8.0
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [ripgrep](https://github.com/BurntSushi/ripgrep) (for fast searching)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.
