# telescope-endpoint.nvim

A powerful Telescope picker for quickly finding and navigating web framework API endpoints with customizable UI and smart caching.

**Supported Frameworks:**
- 🍃 Spring Boot (Java)
- 🐦 NestJS (TypeScript/JavaScript) 
- 🐍 Django (Python) - Coming soon
- 💎 Rails (Ruby) - Coming soon
- ⚡ Express (Node.js) - Coming soon

## ✨ Features

- 🔍 **Multi-Framework Support**: Automatically detects and supports Spring Boot, NestJS, and more
- 🎨 **Customizable UI**: Configurable icons, colors, and display options
- ⚡ **Smart Caching**: Multiple cache modes including persistent disk storage
- 🔗 **Path Variable Support**: Handles complex path variables and routing patterns
- 📍 **Precise Navigation**: Jump directly to the exact line with annotation highlighting
- 🌈 **Syntax Highlighting**: Preview window with framework-specific syntax highlighting
- 🤖 **Auto-Detection**: Automatically detects your project's framework
- 🔧 **Easy Setup**: Just call `require("endpoint").setup()` to get started

## 🚀 Usage

### Simple Commands (Recommended)

```vim
:Endpoint Get      " Find all GET endpoints
:Endpoint Post     " Find all POST endpoints  
:Endpoint Put      " Find all PUT endpoints
:Endpoint Delete   " Find all DELETE endpoints
:Endpoint Patch    " Find all PATCH endpoints
```

### Cache Management Commands

```vim
:Endpoint ClearCache    " Clear all cached data
:Endpoint CacheStatus   " Show current cache status
```

### Telescope Extension

```vim
:Telescope endpoint        " Default picker
:Telescope endpoint get    " GET endpoints
:Telescope endpoint post   " POST endpoints
:Telescope endpoint put    " PUT endpoints
:Telescope endpoint delete " DELETE endpoints
:Telescope endpoint patch  " PATCH endpoints
```

### Legacy Spring Commands (Still Supported)

```vim
:Spring Get               " Find all GET endpoints (legacy)
:SpringGetMapping         " Find all GET endpoints (legacy)
:Telescope spring get     " GET endpoints (legacy)
```

## 📦 Installation

> **⚠️ Important**: You must call `require("endpoint").setup()` in a `config` function for the plugin to work properly. The `opts` table alone is not sufficient.

### lazy.nvim

```lua
{
  "zerochae/telescope-spring.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  cmd = {
    "Endpoint",
    "Spring", -- Legacy support
  },
  config = function()
    require("endpoint").setup({
      -- Framework configuration
      framework = "auto", -- "auto", "spring", "nestjs", "django", "rails", "express"
      
      -- Optional: Path-based framework overrides
      framework_paths = {
        ["/path/to/spring/project"] = "spring",
        ["/path/to/nestjs/project"] = "nestjs",
      },
      
      -- Cache configuration
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

### Minimal Setup

```lua
{
  "zerochae/telescope-spring.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  cmd = { "Endpoint", "Spring" },
  config = function()
    require("endpoint").setup()
  end,
}
```

### packer.nvim

```lua
use {
  "zerochae/telescope-spring.nvim",
  requires = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("endpoint").setup() -- This is required!
  end,
}
```

## ⚙️ Configuration

### Default Configuration

```lua
require("endpoint").setup({
  -- Framework configuration
  framework = "auto",                       -- "auto", "spring", "nestjs", "django", "rails", "express"
  framework_paths = {},                     -- Path-based framework overrides
  
  -- Cache configuration
  cache_ttl = 5000,                         -- Cache TTL in milliseconds (time/session modes)
  cache_mode = "time",                      -- Cache mode: "time", "session", or "persistent"
  debug = false,                            -- Enable debug logging
  
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
require("endpoint").setup({
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
:Endpoint ClearCache    " Clear all cache files for current project
:Endpoint CacheStatus   " Show detailed cache information
```

**Cache Files Structure:**
```
~/.local/share/nvim/telescope-endpoint/my-project/
├── find_cache.lua    " Endpoint data (paths, methods, locations)
└── metadata.lua      " Scan history and project metadata
```

**When to use persistent mode:**
- ✅ Large projects with many API endpoints
- ✅ Frequent nvim restarts during development
- ✅ Want maximum performance after initial scan
- ❌ Small projects (overhead not worth it)
- ❌ API endpoints change very frequently

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

## 🌍 Framework Support Status

| Framework | Status | Endpoint Patterns | Auto-Detection |
|-----------|--------|------------------|----------------|
| Spring Boot | ✅ Stable | `@GetMapping`, `@PostMapping`, `@RequestMapping` | `pom.xml`, `*.gradle` |
| NestJS | ✅ Stable | `@Get()`, `@Post()`, `@Controller()` | `package.json` + NestJS deps |
| Django | 🚧 Coming Soon | `path()`, `@api_view` | `manage.py`, Django in requirements |
| Rails | 🚧 Coming Soon | `get`, `post`, `resources` | `Gemfile` + Rails gem |
| Express | 🚧 Coming Soon | `app.get()`, `router.post()` | `package.json` + Express deps |

## ⚡️ Requirements

- [Neovim](https://neovim.io/) >= 0.8.0
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [ripgrep](https://github.com/BurntSushi/ripgrep) (for fast searching)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 🔄 Migration from telescope-spring.nvim

If you're upgrading from the Spring-only version:

1. **Update your setup call**:
   ```lua
   -- Old
   require("spring").setup()
   
   -- New
   require("endpoint").setup()
   ```

2. **Update commands** (optional - old commands still work):
   ```vim
   " Old
   :Spring Get
   
   " New (recommended)
   :Endpoint Get
   ```

3. **Update Telescope extension**:
   ```vim
   " Old
   :Telescope spring get
   
   " New
   :Telescope endpoint get
   ```

All your existing configuration and cache will continue to work!

### Framework-Specific Configuration

The plugin automatically detects your framework, but you can override detection:

```lua
require("endpoint").setup({
  -- Explicit framework selection
  framework = "spring", -- or "nestjs", "django", "rails", "express"
  
  -- Path-based framework overrides (useful for monorepos)
  framework_paths = {
    ["/home/user/spring-project"] = "spring",
    ["/home/user/nestjs-api"] = "nestjs",
    ["/home/user/django-app"] = "django",
  },
  
  debug = true, -- Enable to see framework detection logs
})
```

### Framework Detection

The plugin uses these files to detect your framework:

- **Spring Boot**: `pom.xml`, `build.gradle`, `build.gradle.kts`
- **NestJS**: `package.json` (with @nestjs dependencies)
- **Django**: `manage.py`, `requirements.txt` (with Django)
- **Rails**: `Gemfile` (with Rails gem)
- **Express**: `package.json` (with Express dependencies)

## 📄 License

This project is licensed under the MIT License.

## ⭐ Star History

If this plugin helps you, please consider giving it a star! ✨
