# narrowing.nvim

🎯 A Neovim plugin for Emacs-style narrowing - focus on what matters by isolating text regions in dedicated buffers.

## ✨ Features

- **🎨 Flexible Windows** - Choose between floating windows (default) or splits
- **🔄 Auto-sync** - Changes automatically sync back with `:w`
- **🔒 Buffer Protection** - Original buffer becomes read-only during narrowing  
- **🌈 Visual Feedback** - Highlights narrowed regions in the original buffer
- **📚 Multiple Instances** - Work with multiple narrowed regions simultaneously
- **🎯 Smart Selection** - Visual mode, ranges, folds, and window content
- **⚡ Simple Commands** - Everything through a unified `:Narrowing` command

## 📋 Requirements

- Neovim 0.7.0 or higher

## 📦 Installation

<details>
<summary><b>lazy.nvim</b></summary>

```lua
{
  "tkancf/narrowing-nvim",
  config = function()
    require("narrowing").setup()
  end,
}
```
</details>

<details>
<summary><b>packer.nvim</b></summary>

```lua
use {
  "tkancf/narrowing-nvim",
  config = function()
    require("narrowing").setup()
  end,
}
```
</details>

## 🚀 Quick Start

1. **Select text** in visual mode
2. Run `:Narrowing`
3. Edit in the floating window
4. Save with `:w` to sync changes
5. Close with `:q` or `:wq`

## 📖 Commands

All commands are available through `:Narrowing [subcommand]`:

| Subcommand | Description | Example |
|------------|-------------|---------|
| _(none)_ | Narrow current selection/range | `:Narrowing` |
| `narrow` | Same as above (explicit) | `:Narrowing narrow` |
| `write` | Write changes back to original | `:Narrowing write` |
| `quit` | Close without saving | `:Narrowing quit` |
| `window` | Narrow visible window content | `:Narrowing window` |
| `fold` | Narrow fold at cursor | `:Narrowing fold` |
| `last` | Re-narrow last region | `:Narrowing last` |

### 🎯 Usage Examples

```vim
" Visual mode selection
v<motion>:Narrowing

" Line range
:10,20Narrowing

" Current fold
:Narrowing fold

" Visible window
:Narrowing window

" Open in current window (not floating)
:Narrowing!

" Write and close
:Narrowing! write
```

### 📁 Fold Narrowing

The `fold` subcommand intelligently detects:
- Closed folds at cursor position
- Logical code blocks (functions, classes)
- Indentation-based blocks

Perfect for focusing on:
- Function definitions
- Class implementations
- Configuration sections
- Any foldable content

## ⚙️ Configuration

```lua
require("narrowing").setup({
  -- Window settings
  window = {
    type = "float",        -- "float" or "split"
    position = "center",   -- "center", "left", "right", "top", "bottom"
    width = 0.95,         -- 95% of screen width
    height = 0.9,         -- 90% of screen height
    vertical = true,      -- For split type only
  },
  
  -- Keymaps (disabled by default)
  keymaps = {
    enabled = false,       -- Set to true to enable default keymaps
    narrow = "<leader>nr", -- Visual mode: narrow selection
    write = "<leader>nw",  -- Normal mode: write changes (in narrowed buffer)
    quit = "<leader>nq",   -- Normal mode: quit (in narrowed buffer)
  },
  
  -- Behavior
  sync_on_write = true,      -- Auto-sync on :w
  protect_original = true,   -- Make original read-only
  highlight_region = true,   -- Highlight narrowed region
  highlight_group = "Visual", -- Highlight style
})
```

### 🪟 Window Types

<details>
<summary><b>Floating Window (default)</b></summary>

```lua
window = {
  type = "float",
  position = "center",  -- Centers the floating window
  width = 0.95,        -- Nearly full screen
  height = 0.9,
}
```
</details>

<details>
<summary><b>Split Window</b></summary>

```lua
window = {
  type = "split",
  position = "right",   -- "left", "right", "top", "bottom"
  width = 0.5,         -- 50% of screen
  vertical = true,     -- Vertical split
}
```
</details>

## ⌨️ Keymaps

Keymaps are **disabled by default**. You have two options:

### Option 1: Enable Default Keymaps

```lua
require("narrowing").setup({
  keymaps = {
    enabled = true,  -- Enable default keymaps
  },
})
```

This will set up:
- Visual mode: `<leader>nr` - Narrow selection
- Normal mode: `<leader>nw` - Write changes (in narrowed buffer)
- Normal mode: `<leader>nq` - Quit (in narrowed buffer)

### Option 2: Set Your Own Keymaps

```lua
-- Using <Plug> mapping
vim.keymap.set("v", "gz", "<Plug>(narrowing-narrow)")

-- Or direct function call
vim.keymap.set("v", "gz", function()
  require("narrowing").narrow()
end)
```

## 🔄 Auto-sync Behavior

When `sync_on_write = true` (default):
- `:w` - Saves changes to original buffer
- `:wq` - Saves and closes narrowed buffer
- Original buffer is protected during narrowing

## 💡 Tips

- Use `:Narrowing!` to replace the current window instead of creating a new one
- Combine with folds for function-level editing
- Multiple narrowed buffers can be open simultaneously
- Visual highlighting shows active narrowed regions

## 🙏 Acknowledgments

Inspired by Emacs narrowing and the [NrrwRgn](https://github.com/chrisbra/NrrwRgn) Vim plugin.

## 📄 License

MIT