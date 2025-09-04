local M = {}

M.default_config = {
  prompt_title = "spring api finder",
  get_prompt_title = "get api finder",
  post_prompt_title = "post api finder",
  put_prompt_title = "put api finder",
  delete_prompt_title = "delete api finder",
  patch_prompt_title = "patch api finder",
}

M.methods = {
  ALL = "ALL",
  GET = "GET",
  POST = "POST",
  PUT = "PUT",
  DELETE = "DELETE",
  PATCH = "PATCH",
}

M.annotation = {
  REQUEST_MAPPING = "@RequestMapping",
  GET_MAPPING = "@GetMapping",
  POST_MAPPING = "@PostMapping",
  PUT_MAPPING = "@PutMapping",
  DELETE_MAPPING = "@DeleteMapping",
  PATCH_MAPPING = "@PatchMapping",
}

M.cmd = {
  GET_ROOT = "git rev-parse --show-toplevel",
  GREP = "grep",
}

M.args = {
  EXACT = "-E",
  ALL_JAVA_FILE = "/**/*.java",
}

return M
