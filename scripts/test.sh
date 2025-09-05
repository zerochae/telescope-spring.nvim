#!/bin/bash
set -e

# --- Configuration ---
DEPS_DIR="test/deps"
PLENARY_URL="https://github.com/nvim-lua/plenary.nvim"
TELESCOPE_URL="https://github.com/nvim-telescope/telescope.nvim"
MINIMAL_INIT="test/minimal_init.lua"

# --- Helper Functions ---
clone_plugin() {
  local url=$1
  local name=$(basename "$url" .git)
  local path="$DEPS_DIR/$name"
  if [ ! -d "$path" ]; then
    echo "Cloning $name..."
    git clone --depth 1 "$url" "$path"
  else
    echo "$name already exists. Skipping clone."
  fi
}

# --- Main Script ---

# 1. Create dependencies directory
mkdir -p "$DEPS_DIR"

# 2. Clone required plugins
echo "Setting up test dependencies..."
clone_plugin "$PLENARY_URL"
clone_plugin "$TELESCOPE_URL"
echo "Dependencies are set up."

# 3. Run the tests
echo "Running tests..."
nvim --headless \
  -i NONE \
  -u "$MINIMAL_INIT" \
  -c "PlenaryBustedDirectory test/ { minimal_init = '$MINIMAL_INIT' }"

echo "Tests finished."
