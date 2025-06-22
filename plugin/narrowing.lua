if vim.fn.has("nvim-0.7.0") == 0 then
  vim.api.nvim_err_writeln("narrowing.nvim requires at least nvim-0.7.0")
  return
end

if vim.g.loaded_narrowing == 1 then
  return
end
vim.g.loaded_narrowing = 1

local narrowing = require("narrowing")

-- Unified Narrowing command with all functionality
vim.api.nvim_create_user_command("Narrowing", function(opts)
  local subcommand = opts.fargs[1]
  
  if not subcommand or subcommand == "narrow" then
    -- Default narrow behavior - use range if provided, otherwise visual selection
    if opts.range > 0 then
      narrowing.narrow_region(opts.line1, opts.line2, opts.bang)
    else
      narrowing.narrow_region(vim.fn.line("'<"), vim.fn.line("'>"), opts.bang)
    end
  elseif subcommand == "write" then
    narrowing.widen_region(opts.bang)
  elseif subcommand == "quit" then
    narrowing.quit()
  elseif subcommand == "window" then
    narrowing.narrow_window(opts.bang)
  elseif subcommand == "last" then
    narrowing.narrow_last(opts.bang)
  elseif subcommand == "fold" then
    narrowing.narrow_fold(opts.bang)
  else
    vim.api.nvim_err_writeln("Unknown subcommand: " .. subcommand)
    vim.api.nvim_echo({
      {"Usage: :Narrowing [narrow|write|quit|window|last|fold]", "Normal"}
    }, false, {})
  end
end, { 
  range = true,
  bang = true,
  nargs = "?",
  complete = function(_, _, _)
    return { "narrow", "write", "quit", "window", "last", "fold" }
  end,
})

vim.keymap.set("v", "<Plug>(narrowing-narrow)", function()
  narrowing.narrow()
end, { silent = true })