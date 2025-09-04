local M = {}

M.default_config = {
  prompt_title = "endpoint finder",
  get_prompt_title = "get endpoints",
  post_prompt_title = "post endpoints",
  put_prompt_title = "put endpoints",
  delete_prompt_title = "delete endpoints",
  patch_prompt_title = "patch endpoints",
}

M.methods = {
  ALL = "ALL",
  GET = "GET",
  POST = "POST",
  PUT = "PUT",
  DELETE = "DELETE",
  PATCH = "PATCH",
}

-- Legacy Spring annotations (DEPRECATED - use framework-specific implementations)
-- These are kept for backward compatibility only
M.annotation = {
  REQUEST_MAPPING = "@RequestMapping",
  GET_MAPPING = "@GetMapping",
  POST_MAPPING = "@PostMapping",
  PUT_MAPPING = "@PutMapping",
  DELETE_MAPPING = "@DeleteMapping",
  PATCH_MAPPING = "@PatchMapping",
}

-- Legacy command constants (DEPRECATED)
M.cmd = {
  GET_ROOT = "git rev-parse --show-toplevel",
  GREP = "grep",
}

-- Legacy args constants (DEPRECATED)
M.args = {
  EXACT = "-E",
  ALL_JAVA_FILE = "/**/*.java",
}

return M
