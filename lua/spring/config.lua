local default_config = require("spring.enum").default_config

return {
  prompt_title = default_config.prompt_title,
  get = {
    prompt_title = default_config.get_prompt_title,
  },
  post = {
    prompt_title = default_config.post_prompt_title,
  },
  put = {
    prompt_title = default_config.put_prompt_title,
  },
  delete = {
    prompt_title = default_config.delete_prompt_title,
  },
}
