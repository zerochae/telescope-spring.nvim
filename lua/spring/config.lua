local E = require "spring.enum"

return {
  prompt_title = E.default_config.prompt_title,
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
