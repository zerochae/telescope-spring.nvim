local E = require "spring.enum"

return {
  prompt_title = E.default_config.prompt_title,
  cache_ttl = 5000, -- Cache time-to-live in milliseconds
  file_patterns = { "**/*.java" }, -- File patterns to search
  exclude_patterns = { "**/target/**", "**/build/**" }, -- Patterns to exclude
  rg_additional_args = "", -- Additional ripgrep arguments
  
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
