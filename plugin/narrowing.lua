if vim.fn.has("nvim-0.7.0") == 0 then
  vim.api.nvim_err_writeln("narrowing.nvim requires at least nvim-0.7.0")
  return
end

if vim.g.loaded_narrowing == 1 then
  return
end
vim.g.loaded_narrowing = 1

local narrowing = require("narrowing")

vim.api.nvim_create_user_command("Narrow", function()
  narrowing.narrow()
end, { range = true })

vim.api.nvim_create_user_command("NarrowWrite", function()
  narrowing.write()
end, {})

vim.api.nvim_create_user_command("NarrowQuit", function()
  narrowing.quit()
end, {})

vim.keymap.set("v", "<Plug>(narrowing-narrow)", function()
  narrowing.narrow()
end, { silent = true })