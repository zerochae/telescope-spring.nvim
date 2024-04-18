local M = {}

M.default_config = {
  prompt_title = "spring api finder",
}

M.methods = {
  GET = "GET",
  POST = "POST",
  PUT = "PUT",
  DELETE = "DELETE",
}

M.annotation = {
  REQUEST_MAPPING = "'@RequestMapping'",
  GET_MAPPING = "'@GetMapping'",
  POST_MAPPING = "'@PostMapping'",
  PUT_MAPPING = "'@PutMapping'",
  DELETE_MAPPING = "'@DeleteMapping'",
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
