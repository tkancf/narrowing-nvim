# narrowing.nvim

A Neovim plugin that provides Emacs-style narrowing functionality, similar to NrrwRgn but built specifically for Neovim. Focus on and edit specific regions of text in isolated buffers.

## Features

- **NrrwRgn-style commands**: `:NR`, `:WR`, `:NW`, `:NRL` with full compatibility
- **Flexible window types**: Split windows (like NrrwRgn) or floating windows
- **Auto-sync on write**: Changes automatically sync back to original buffer with `:w`
- **Region highlighting**: Visual feedback showing narrowed region in original buffer
- **Buffer protection**: Original buffer becomes read-only during narrowing
- **Multiple instances**: Support for multiple narrowed regions simultaneously
- **Visual mode support**: Character-wise, line-wise, and block-wise selections
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

1. **Select a region**: Use visual mode to select text, or use line ranges with Ex commands
2. **Narrow the region**: Execute `:NR` (or `:NarrowRegion`)
3. **Edit**: Make changes in the narrowed buffer
4. **Write back**: Use `:w` to automatically sync changes, or `:WR` to write and stay open
5. **Close**: Use `:q` to close, or `:wq` to write and close

### NrrwRgn-Compatible Commands

- `:NR [range]` - Narrow the selected region (current line if no range)
- `:NarrowRegion [range]` - Same as `:NR` (long form)
- `:WR` - Write changes back to original buffer
- `:WidenRegion` - Same as `:WR` (long form)
- `:NW` - Narrow the current window's visible content
- `:NarrowWindow` - Same as `:NW` (long form)
- `:NRL` - Re-narrow the last narrowed region

### Bang Modifiers

Add `!` to most commands to open in the current window instead of a split:
- `:NR!` - Open narrowed buffer in current window
- `:WR!` - Write back and close the narrowed buffer
- `:NW!` - Narrow window content in current window

### Auto-sync Behavior

When `sync_on_write` is enabled (default):
- `:w` automatically writes changes back to the original buffer
- `:wq` writes changes and closes the narrowed buffer
- The original buffer is protected (read-only) during narrowing

## Configuration

```lua
require("narrowing").setup({
  window = {
    type = "split",        -- "split" or "float"
    position = "right",    -- "left", "right", "top", "bottom"
    width = 0.5,          -- Window width (0-1 for percentage)
    height = 0.8,         -- Window height (0-1 for percentage)
    vertical = true,      -- Use vertical splits
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

## Commands

### Primary Commands (NrrwRgn-compatible)
- `:NR [range]` - Narrow region (current line if no range given)
- `:NarrowRegion [range]` - Narrow region (long form)
- `:WR` - Write changes back to original buffer
- `:WidenRegion` - Write changes back (long form)
- `:NW` - Narrow current window's visible content
- `:NarrowWindow` - Narrow window content (long form)
- `:NRL` - Re-narrow the last narrowed region

### Legacy Commands (backward compatibility)
- `:Narrowing [narrow|write|quit]` - Legacy subcommand interface

## Keymaps

Default keymaps (can be customized in setup):

- `<leader>nr` - Narrow current visual selection
- `<leader>nw` - Write changes (in narrowed buffer)
- `<leader>nq` - Quit without saving (in narrowed buffer)

## License

MIT
