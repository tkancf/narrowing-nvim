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
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  
  -- Check if we have a valid visual selection
  if start_pos[2] == 0 or end_pos[2] == 0 then
    return nil, nil, nil
  end
  
  local start_line = start_pos[2]
  local start_col = start_pos[3]
  local end_line = end_pos[2]
  local end_col = end_pos[3]

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  
  -- Get the visual mode type from the register
  local visual_mode = vim.fn.visualmode()
  
  if visual_mode == "v" then
    -- Character-wise visual selection
    if #lines == 1 then
      lines[1] = string.sub(lines[1], start_col, end_col)
    else
      lines[1] = string.sub(lines[1], start_col)
      if #lines > 1 then
        lines[#lines] = string.sub(lines[#lines], 1, end_col)
      end
    end
  elseif visual_mode == "\22" then
    -- Block-wise visual selection
    local width = end_col - start_col + 1
    for i, line in ipairs(lines) do
      lines[i] = string.sub(line, start_col, start_col + width - 1)
    end
  end
  -- Line-wise visual selection (V) - use lines as-is

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
  vim.bo[narrow_buf].buftype = ""  -- Allow normal buffer operations like :w
  
  -- Set a temporary buffer name to avoid "No file name" error
  local original_name = vim.api.nvim_buf_get_name(original_buf)
  local base_name = original_name ~= "" and original_name or "untitled"
  
  -- Generate unique buffer name to avoid conflicts
  local counter = 1
  local buf_name = base_name .. " [Narrowed]"
  while vim.fn.bufexists(buf_name) == 1 do
    counter = counter + 1
    buf_name = base_name .. " [Narrowed " .. counter .. "]"
  end
  vim.api.nvim_buf_set_name(narrow_buf, buf_name)
  
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
  
  -- Set up autocommands for :w and :wq behavior
  local augroup = vim.api.nvim_create_augroup("narrowing_buf_" .. narrow_buf, { clear = true })
  
  -- Handle :w (write) command
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    group = augroup,
    buffer = narrow_buf,
    callback = function()
      M.write()
      -- Mark buffer as saved to prevent "No write since last change" warnings
      vim.bo[narrow_buf].modified = false
    end,
  })
  
  -- Override :wq and :x commands with buffer-local abbreviations
  vim.api.nvim_buf_call(narrow_buf, function()
    vim.cmd("cnoreabbrev <buffer> wq lua require('narrowing').write_and_quit()")
    vim.cmd("cnoreabbrev <buffer> x lua require('narrowing').write_and_quit()")
  end)
  
  -- Handle buffer close after write (for :wq)
  vim.api.nvim_create_autocmd("BufUnload", {
    group = augroup,
    buffer = narrow_buf,
    callback = function()
      -- Clean up state when buffer is closed
      M.state.narrowed_buffers[narrow_buf] = nil
      local original_narrowed = M.state.original_buffers[original_buf]
      if original_narrowed then
        for i, buf in ipairs(original_narrowed) do
          if buf == narrow_buf then
            table.remove(original_narrowed, i)
            break
          end
        end
      end
    end,
  })
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

function M.write_and_quit()
  M.write()
  M.quit()
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