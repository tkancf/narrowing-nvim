# narrowing.nvim

A Neovim plugin that provides Emacs-style narrowing functionality, allowing you to focus on and edit specific regions of text in isolated buffers.

## Features

- Focus on selected text regions in separate floating windows
- Preserve syntax highlighting in narrowed buffers
- Write changes back to the original buffer
- Support for visual mode selections (character, line, and block)
- Configurable window placement and keybindings

## Requirements

- Neovim 0.7.0 or higher

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "tkancf/narrowing-nvim",
  config = function()
    require("narrowing").setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "tkancf/narrowing-nvim",
  config = function()
    require("narrowing").setup()
  end,
}
```

## Usage

1. Select text in visual mode
2. Use one of the following methods to narrow:
   - Execute `:Narrow` command
   - Use the default keymap `<leader>nr` (in visual mode)

3. Edit the narrowed content in the floating window
4. Save changes back to original buffer:
   - Execute `:NarrowWrite` command
   - Use the default keymap `<leader>nw` (in the narrowed buffer)

5. Close without saving:
   - Execute `:NarrowQuit` command
   - Use the default keymap `<leader>nq` (in the narrowed buffer)

## Configuration

```lua
require("narrowing").setup({
  window = {
    position = "right",  -- Window position: "right", "left", "top", "bottom"
    width = 0.5,         -- Window width (0-1 for percentage)
    height = 0.8,        -- Window height (0-1 for percentage)
  },
  keymaps = {
    narrow = "<leader>nr",  -- Keymap to narrow selection
    write = "<leader>nw",   -- Keymap to write changes
    quit = "<leader>nq",    -- Keymap to quit without saving
  },
})
```

## Commands

- `:Narrow` - Narrow the current visual selection
- `:NarrowWrite` - Write changes from narrowed buffer to original
- `:NarrowQuit` - Close narrowed buffer without saving

## Keymaps

Default keymaps (can be customized in setup):

- `<leader>nr` - Narrow current visual selection
- `<leader>nw` - Write changes (in narrowed buffer)
- `<leader>nq` - Quit without saving (in narrowed buffer)

## License

MIT
