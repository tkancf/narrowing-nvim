local M = {}

M.state = {
  narrowed_buffers = {},
  original_buffers = {}
}

function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", {
    window = {
      position = "right",
      width = 0.5,
      height = 0.8,
    },
    keymaps = {
      narrow = "<leader>nr",
      write = "<leader>nw",
      quit = "<leader>nq",
    },
  }, opts)
end

function M.get_visual_selection()
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
    return nil, nil, nil
  end

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  
  local start_line = start_pos[2]
  local start_col = start_pos[3]
  local end_line = end_pos[2]
  local end_col = end_pos[3]

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  
  if mode == "v" then
    if #lines == 1 then
      lines[1] = string.sub(lines[1], start_col, end_col)
    else
      lines[1] = string.sub(lines[1], start_col)
      if #lines > 1 then
        lines[#lines] = string.sub(lines[#lines], 1, end_col)
      end
    end
  end

  return lines, start_line, end_line
end

function M.narrow()
  local lines, start_line, end_line = M.get_visual_selection()
  if not lines then
    vim.notify("No visual selection", vim.log.levels.WARN)
    return
  end

  local original_buf = vim.api.nvim_get_current_buf()
  local original_win = vim.api.nvim_get_current_win()
  
  local narrow_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(narrow_buf, 0, -1, false, lines)
  
  local filetype = vim.bo[original_buf].filetype
  vim.bo[narrow_buf].filetype = filetype
  vim.bo[narrow_buf].modifiable = true
  
  local width = math.floor(vim.o.columns * M.config.window.width)
  local height = math.floor(vim.o.lines * M.config.window.height)
  
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    col = vim.o.columns - width - 2,
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " Narrowed Region ",
    title_pos = "center",
  }
  
  local narrow_win = vim.api.nvim_open_win(narrow_buf, true, win_opts)
  
  M.state.narrowed_buffers[narrow_buf] = {
    original_buf = original_buf,
    start_line = start_line,
    end_line = end_line,
    window = narrow_win,
  }
  
  M.state.original_buffers[original_buf] = M.state.original_buffers[original_buf] or {}
  table.insert(M.state.original_buffers[original_buf], narrow_buf)
  
  vim.keymap.set("n", M.config.keymaps.write, function() M.write() end, { buffer = narrow_buf })
  vim.keymap.set("n", M.config.keymaps.quit, function() M.quit() end, { buffer = narrow_buf })
end

function M.write()
  local narrow_buf = vim.api.nvim_get_current_buf()
  local info = M.state.narrowed_buffers[narrow_buf]
  
  if not info then
    vim.notify("Not in a narrowed buffer", vim.log.levels.WARN)
    return
  end
  
  local lines = vim.api.nvim_buf_get_lines(narrow_buf, 0, -1, false)
  
  vim.api.nvim_buf_set_lines(
    info.original_buf,
    info.start_line - 1,
    info.end_line,
    false,
    lines
  )
  
  vim.notify("Changes written to original buffer", vim.log.levels.INFO)
end

function M.quit()
  local narrow_buf = vim.api.nvim_get_current_buf()
  local info = M.state.narrowed_buffers[narrow_buf]
  
  if not info then
    vim.notify("Not in a narrowed buffer", vim.log.levels.WARN)
    return
  end
  
  vim.api.nvim_win_close(info.window, true)
  vim.api.nvim_buf_delete(narrow_buf, { force = true })
  
  M.state.narrowed_buffers[narrow_buf] = nil
  
  local original_narrowed = M.state.original_buffers[info.original_buf]
  if original_narrowed then
    for i, buf in ipairs(original_narrowed) do
      if buf == narrow_buf then
        table.remove(original_narrowed, i)
        break
      end
    end
  end
end

return M