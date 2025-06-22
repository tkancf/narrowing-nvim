# narrowing.nvim

A Neovim plugin that provides Emacs-style narrowing functionality, similar to NrrwRgn but built specifically for Neovim. Focus on and edit specific regions of text in isolated buffers.

## Features

- **Unified command interface**: Single `:Narrowing` command with subcommands for all functionality
- **Flexible window types**: Split windows (like NrrwRgn) or floating windows
- **Auto-sync on write**: Changes automatically sync back to original buffer with `:w`
- **Region highlighting**: Visual feedback showing narrowed region in original buffer
- **Buffer protection**: Original buffer becomes read-only during narrowing
- **Multiple instances**: Support for multiple narrowed regions simultaneously
- **Visual mode support**: Character-wise, line-wise, and block-wise selections
- **NrrwRgn-inspired features**: Window narrowing, last region re-selection, and more
- **Configurable behavior**: Extensive customization options

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

### Basic Narrowing

1. **Select a region**: Use visual mode to select text, or specify line ranges
2. **Narrow the region**: Execute `:Narrowing` or `:Narrowing narrow`
3. **Edit**: Make changes in the narrowed buffer
4. **Write back**: Use `:w` to automatically sync changes, or `:Narrowing write` to write explicitly
5. **Close**: Use `:q` to close, or `:wq` to write and close

### Commands

#### Primary Command
- `:Narrowing [subcommand]` - Main command with optional subcommands

#### Subcommands
- `:Narrowing` or `:Narrowing narrow` - Narrow selected region or range
- `:Narrowing write` - Write changes back to original buffer
- `:Narrowing quit` - Close narrowed buffer without saving
- `:Narrowing window` - Narrow current window's visible content
- `:Narrowing last` - Re-narrow the last narrowed region

#### Range Support
- `:10,20Narrowing` - Narrow lines 10-20
- `:'<,'>Narrowing` - Narrow visual selection
- `:Narrowing` (in visual mode) - Narrow current selection

#### Bang Modifiers
Add `!` to open in the current window instead of a split:
- `:Narrowing!` - Open narrowed buffer in current window
- `:Narrowing! write` - Write back and close the narrowed buffer
- `:Narrowing! window` - Narrow window content in current window

### Auto-sync Behavior

When `sync_on_write` is enabled (default):
- `:w` automatically writes changes back to the original buffer
- `:wq` writes changes and closes the narrowed buffer
- The original buffer is protected (read-only) during narrowing

## Configuration

```lua
require("narrowing").setup({
  window = {
    type = "float",        -- "split" or "float"
    position = "center",   -- "left", "right", "top", "bottom", "center"
    width = 0.95,         -- Window width (0-1 for percentage)
    height = 0.9,         -- Window height (0-1 for percentage)
    vertical = true,      -- Use vertical splits (for split type)
  },
  keymaps = {
    narrow = "<leader>nr", -- Keymap to narrow selection
    write = "<leader>nw",  -- Keymap to write changes
    quit = "<leader>nq",   -- Keymap to quit without saving
  },
  sync_on_write = true,      -- Auto-sync on :w
  protect_original = true,   -- Make original buffer read-only
  highlight_region = true,   -- Highlight narrowed region
  highlight_group = "Visual", -- Highlight group to use
})
```

## Commands Reference

All functionality is available through the unified `:Narrowing` command:

| Command | Description |
|---------|-------------|
| `:Narrowing` | Narrow current selection or range |
| `:Narrowing narrow` | Same as above (explicit) |
| `:Narrowing write` | Write changes back to original buffer |
| `:Narrowing quit` | Close narrowed buffer without saving |
| `:Narrowing window` | Narrow current window's visible content |
| `:Narrowing last` | Re-narrow the last narrowed region |

### Examples

```vim
" Narrow lines 10-20
:10,20Narrowing

" Narrow visual selection
:'<,'>Narrowing

" Narrow current window content
:Narrowing window

" Write changes back
:Narrowing write

" Re-narrow last region
:Narrowing last

" Open in current window (bang modifier)
:Narrowing! window
```

## Keymaps

Default keymaps (can be customized in setup):

- `<leader>nr` - Narrow current visual selection
- `<leader>nw` - Write changes (in narrowed buffer)
- `<leader>nq` - Quit without saving (in narrowed buffer)

## License

MIT
