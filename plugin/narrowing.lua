if vim.fn.has("nvim-0.7.0") == 0 then
  vim.api.nvim_err_writeln("narrowing.nvim requires at least nvim-0.7.0")
  return
end

if vim.g.loaded_narrowing == 1 then
  return
end
vim.g.loaded_narrowing = 1

local narrowing = require("narrowing")

-- NrrwRgn-style commands
vim.api.nvim_create_user_command("NR", function(opts)
  narrowing.narrow_region(opts.line1, opts.line2, opts.bang)
end, { range = true, bang = true })

vim.api.nvim_create_user_command("NarrowRegion", function(opts)
  narrowing.narrow_region(opts.line1, opts.line2, opts.bang)
end, { range = true, bang = true })

vim.api.nvim_create_user_command("WR", function(opts)
  narrowing.widen_region(opts.bang)
end, { bang = true })

vim.api.nvim_create_user_command("WidenRegion", function(opts)
  narrowing.widen_region(opts.bang)
end, { bang = true })

vim.api.nvim_create_user_command("NW", function(opts)
  narrowing.narrow_window(opts.bang)
end, { bang = true })

vim.api.nvim_create_user_command("NarrowWindow", function(opts)
  narrowing.narrow_window(opts.bang)
end, { bang = true })

vim.api.nvim_create_user_command("NRL", function(opts)
  narrowing.narrow_last(opts.bang)
end, { bang = true })

-- Keep backward compatibility with old Narrowing command
vim.api.nvim_create_user_command("Narrowing", function(opts)
  local subcommand = opts.fargs[1]
  
  if not subcommand or subcommand == "narrow" then
    narrowing.narrow_region(vim.fn.line("'<"), vim.fn.line("'>"), false)
  elseif subcommand == "write" then
    narrowing.widen_region(false)
  elseif subcommand == "quit" then
    narrowing.quit()
  else
    vim.api.nvim_err_writeln("Unknown subcommand: " .. subcommand)
    vim.api.nvim_echo({
      {"Usage: :Narrowing [narrow|write|quit]", "Normal"}
    }, false, {})
  end
end, { 
  range = true,
  nargs = "?",
  complete = function(_, _, _)
    return { "narrow", "write", "quit" }
  end,
})

vim.keymap.set("v", "<Plug>(narrowing-narrow)", function()
  narrowing.narrow()
end, { silent = true })