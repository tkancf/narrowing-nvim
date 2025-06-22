if vim.fn.has("nvim-0.7.0") == 0 then
  vim.api.nvim_err_writeln("narrowing.nvim requires at least nvim-0.7.0")
  return
end

if vim.g.loaded_narrowing == 1 then
  return
end
vim.g.loaded_narrowing = 1

local narrowing = require("narrowing")

vim.api.nvim_create_user_command("Narrowing", function(opts)
  local subcommand = opts.fargs[1]
  
  if not subcommand or subcommand == "narrow" then
    narrowing.narrow()
  elseif subcommand == "write" then
    narrowing.write()
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