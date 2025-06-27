local M = {}

-- State management similar to NrrwRgn
M.state = {
  narrowed_buffers = {},
  original_buffers = {},
  instance_id = 1,
  last_region = nil,
}

function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", {
    window = {
      type = "float", -- "split" or "float"
      position = "center", -- "left", "right", "top", "bottom", "center"
      width = 0.95, -- almost full screen width
      height = 0.9, -- almost full screen height
      vertical = true, -- for split windows
    },
    keymaps = {
      enabled = false,  -- Set to true to enable default keymaps
      narrow = "<leader>nr",
      write = "<leader>nw",
      quit = "<leader>nq",
      fold = "<leader>nf",  -- Normal mode: narrow fold at cursor
    },
    sync_on_write = true, -- auto-sync on :w like NrrwRgn
    protect_original = true, -- make original buffer read-only
    highlight_region = true, -- highlight narrowed region
    highlight_group = "Visual", -- highlight group for region
  }, opts)
  
  -- Store config globally for plugin access
  vim.g.narrowing_config = M.config
  
  -- Set up highlight group if needed
  if M.config.highlight_region then
    vim.api.nvim_set_hl(0, "NarrowingRegion", { link = M.config.highlight_group })
  end
  
  -- Set up keymaps if enabled
  if M.config.keymaps.enabled then
    -- Visual mode keymap for narrow
    if M.config.keymaps.narrow then
      vim.keymap.set("v", M.config.keymaps.narrow, function()
        M.narrow()
      end, { silent = true, desc = "Narrow selection" })
    end
    
    -- Normal mode keymap for fold
    if M.config.keymaps.fold then
      vim.keymap.set("n", M.config.keymaps.fold, function()
        M.narrow_fold(false)
      end, { silent = true, desc = "Narrow fold at cursor" })
    end
  end
end

-- Get next available instance ID
function M.get_next_instance_id()
  local id = M.state.instance_id
  while M.state.narrowed_buffers[id] do
    id = id + 1
  end
  M.state.instance_id = id + 1
  return id
end

-- Get fold range at current cursor position
function M.get_fold_range()
  local current_line = vim.fn.line(".")
  
  -- First, check if current line is in a closed fold
  local fold_start = vim.fn.foldclosed(current_line)
  local fold_end = vim.fn.foldclosedend(current_line)
  
  if fold_start ~= -1 and fold_end ~= -1 then
    return fold_start, fold_end
  end
  
  -- If not in a closed fold, try to detect foldable range
  -- Save current fold settings
  local save_pos = vim.fn.getcurpos()
  local save_fdm = vim.opt.foldmethod:get()
  local save_fdc = vim.opt.foldcolumn:get()
  
  -- Temporarily set fold method to indent to detect logical blocks
  vim.opt.foldmethod = "indent"
  vim.opt.foldcolumn = "1"
  
  -- Force fold calculation
  vim.cmd("normal! zx")
  
  -- Now check for fold range again
  fold_start = vim.fn.foldclosed(current_line)
  fold_end = vim.fn.foldclosedend(current_line)
  
  -- If still no fold, try to find logical block based on indentation
  if fold_start == -1 or fold_end == -1 then
    local current_indent = vim.fn.indent(current_line)
    fold_start = current_line
    fold_end = current_line
    
    -- Find start: go backwards to find start of current indentation block
    for line = current_line - 1, 1, -1 do
      local line_text = vim.fn.getline(line)
      if line_text:match("^%s*$") then
        -- Skip blank lines
        goto continue_start
      end
      local line_indent = vim.fn.indent(line)
      if line_indent < current_indent then
        break
      end
      if line_indent == current_indent then
        fold_start = line
      end
      ::continue_start::
    end
    
    -- Find end: go forwards to find end of current indentation block
    for line = current_line + 1, vim.fn.line("$") do
      local line_text = vim.fn.getline(line)
      if line_text:match("^%s*$") then
        -- Skip blank lines
        goto continue_end
      end
      local line_indent = vim.fn.indent(line)
      if line_indent < current_indent then
        break
      end
      if line_indent >= current_indent then
        fold_end = line
      end
      ::continue_end::
    end
  end
  
  -- Restore original fold settings
  vim.opt.foldmethod = save_fdm
  vim.opt.foldcolumn = save_fdc
  vim.fn.setpos('.', save_pos)
  vim.cmd("normal! zx")
  
  -- Validate the range
  if fold_start <= 0 then fold_start = 1 end
  if fold_end <= 0 then fold_end = vim.fn.line("$") end
  if fold_start > fold_end then fold_start, fold_end = fold_end, fold_start end
  
  return fold_start, fold_end
end

-- Get visual selection similar to NrrwRgn
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

-- Highlight region in original buffer
function M.highlight_region(buf, start_line, end_line, namespace)
  if not M.config.highlight_region then return end
  
  vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
  for line = start_line, end_line do
    vim.api.nvim_buf_add_highlight(buf, namespace, "NarrowingRegion", line - 1, 0, -1)
  end
end

-- Make original buffer read-only
function M.protect_buffer(buf, protect)
  if not M.config.protect_original then return end
  
  if protect then
    vim.api.nvim_buf_set_option(buf, "readonly", true)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
  else
    vim.api.nvim_buf_set_option(buf, "readonly", false)
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
  end
end

-- Create narrowed window (split or float)
function M.create_narrow_window(narrow_buf, instance_id, bang)
  local original_name = vim.api.nvim_buf_get_name(0)
  local base_name = vim.fn.fnamemodify(original_name, ":t:r")
  if base_name == "" then base_name = "untitled" end
  
  local buf_name = "Narrowing_" .. base_name .. "_" .. instance_id
  vim.api.nvim_buf_set_name(narrow_buf, buf_name)
  
  if M.config.window.type == "float" then
    -- Create floating window
    local width = math.floor(vim.o.columns * M.config.window.width)
    local height = math.floor(vim.o.lines * M.config.window.height)
    
    -- Calculate position based on config
    local col, row
    if M.config.window.position == "center" then
      col = math.floor((vim.o.columns - width) / 2)
      row = math.floor((vim.o.lines - height) / 2)
    elseif M.config.window.position == "right" then
      col = vim.o.columns - width - 2
      row = math.floor((vim.o.lines - height) / 2)
    elseif M.config.window.position == "left" then
      col = 2
      row = math.floor((vim.o.lines - height) / 2)
    elseif M.config.window.position == "top" then
      col = math.floor((vim.o.columns - width) / 2)
      row = 2
    elseif M.config.window.position == "bottom" then
      col = math.floor((vim.o.columns - width) / 2)
      row = vim.o.lines - height - 4
    else
      -- Default to center
      col = math.floor((vim.o.columns - width) / 2)
      row = math.floor((vim.o.lines - height) / 2)
    end
    
    local win_opts = {
      relative = "editor",
      width = width,
      height = height,
      col = col,
      row = row,
      style = "minimal",
      border = "rounded",
      title = " " .. buf_name .. " ",
      title_pos = "center",
    }
    
    return vim.api.nvim_open_win(narrow_buf, true, win_opts)
  else
    -- Create split window
    if bang then
      -- Open in current window if bang is used
      vim.api.nvim_set_current_buf(narrow_buf)
      return vim.api.nvim_get_current_win()
    else
      -- Create split
      local split_cmd
      if M.config.window.vertical then
        if M.config.window.position == "left" then
          split_cmd = "topleft vsplit"
        else
          split_cmd = "botright vsplit"
        end
      else
        if M.config.window.position == "top" then
          split_cmd = "topleft split"
        else
          split_cmd = "botright split"
        end
      end
      
      vim.cmd(split_cmd)
      vim.api.nvim_set_current_buf(narrow_buf)
      
      -- Resize window
      if M.config.window.vertical then
        local width = math.floor(vim.o.columns * M.config.window.width)
        vim.cmd("vertical resize " .. width)
      else
        local height = math.floor(vim.o.lines * M.config.window.height)
        vim.cmd("resize " .. height)
      end
      
      return vim.api.nvim_get_current_win()
    end
  end
end

-- Legacy function for backward compatibility
function M.narrow()
  local lines, start_line, end_line = M.get_visual_selection()
  if not lines then
    vim.notify("No visual selection", vim.log.levels.WARN)
    return
  end
  
  M.narrow_region(start_line, end_line, false)
end

-- Main narrowing function similar to NrrwRgn
function M.narrow_region(start_line, end_line, bang)
  start_line = start_line or vim.fn.line(".")
  end_line = end_line or start_line
  bang = bang or false
  
  local original_buf = vim.api.nvim_get_current_buf()
  local original_win = vim.api.nvim_get_current_win()
  local instance_id = M.get_next_instance_id()
  
  -- Get lines from the region
  local lines = vim.api.nvim_buf_get_lines(original_buf, start_line - 1, end_line, false)
  
  -- Create narrowed buffer
  local narrow_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(narrow_buf, 0, -1, false, lines)
  
  -- Set buffer options
  local filetype = vim.bo[original_buf].filetype
  vim.bo[narrow_buf].filetype = filetype
  vim.bo[narrow_buf].modifiable = true
  vim.bo[narrow_buf].buftype = ""  -- Allow normal buffer operations like :w
  
  -- Create narrowed window
  local narrow_win = M.create_narrow_window(narrow_buf, instance_id, bang)
  
  -- Create namespace for highlighting
  local namespace = vim.api.nvim_create_namespace("narrowing_" .. instance_id)
  
  -- Highlight region in original buffer
  M.highlight_region(original_buf, start_line, end_line, namespace)
  
  -- Protect original buffer
  M.protect_buffer(original_buf, true)
  
  M.state.narrowed_buffers[instance_id] = {
    narrow_buf = narrow_buf,
    original_buf = original_buf,
    original_win = original_win,
    start_line = start_line,
    end_line = end_line,
    window = narrow_win,
    namespace = namespace,
  }
  
  -- Store last region for :NRL command
  M.state.last_region = {
    buf = original_buf,
    start_line = start_line,
    end_line = end_line,
  }
  
  M.state.original_buffers[original_buf] = M.state.original_buffers[original_buf] or {}
  table.insert(M.state.original_buffers[original_buf], instance_id)
  
  -- Set up buffer-local keymaps if enabled
  if M.config.keymaps.enabled then
    vim.keymap.set("n", M.config.keymaps.write, function() M.widen_region(false) end, { buffer = narrow_buf })
    vim.keymap.set("n", M.config.keymaps.quit, function() M.quit() end, { buffer = narrow_buf })
  end
  
  -- Set up auto-sync on write if enabled
  if M.config.sync_on_write then
    local augroup = vim.api.nvim_create_augroup("narrowing_" .. instance_id, { clear = true })
    
    -- Handle :w (write) command - auto-sync back to original
    vim.api.nvim_create_autocmd("BufWriteCmd", {
      group = augroup,
      buffer = narrow_buf,
      callback = function()
        -- Prevent multiple writes by checking if already processed
        local info = M.state.narrowed_buffers[instance_id]
        if info and not info.writing then
          M.write_to_original(instance_id)
          -- Mark buffer as saved
          vim.bo[narrow_buf].modified = false
        end
        -- Return true to indicate we've handled the write
        return true
      end,
    })
    
    -- Override :wq and :x commands
    vim.api.nvim_buf_call(narrow_buf, function()
      -- Use <expr> abbreviations to only expand at the beginning of command line
      vim.cmd([[cnoreabbrev <buffer> <expr> wq (getcmdtype() == ':' && getcmdline() == 'wq') ? "lua require('narrowing').widen_region(true)" : 'wq']])
      vim.cmd([[cnoreabbrev <buffer> <expr> x (getcmdtype() == ':' && getcmdline() == 'x') ? "lua require('narrowing').widen_region(true)" : 'x']])
    end)
  end
  
  -- Handle window/buffer cleanup
  local cleanup_augroup = vim.api.nvim_create_augroup("narrowing_cleanup_" .. instance_id, { clear = true })
  
  vim.api.nvim_create_autocmd({"WinClosed", "BufUnload"}, {
    group = cleanup_augroup,
    callback = function(args)
      local target_win = tonumber(args.match)
      if target_win == narrow_win or args.buf == narrow_buf then
        vim.schedule(function()
          M.cleanup_narrowed_buffer(instance_id)
        end)
      end
    end,
  })
end

-- Write changes to original buffer (like NrrwRgn :WR)
function M.write_to_original(instance_id)
  local info = M.state.narrowed_buffers[instance_id]
  if not info then
    vim.notify("Not in a narrowed buffer", vim.log.levels.WARN)
    return false
  end
  
  -- Check if we're already in the process of writing to avoid recursion
  if info.writing then
    vim.notify("Already writing, skipping duplicate write", vim.log.levels.DEBUG)
    return false
  end
  info.writing = true
  
  local lines = vim.api.nvim_buf_get_lines(info.narrow_buf, 0, -1, false)
  
  -- Update the end line based on the new content length
  local new_end_line = info.start_line + #lines - 1
  
  -- Temporarily make original buffer modifiable
  M.protect_buffer(info.original_buf, false)
  
  -- Delete the old content first to avoid issues with different line counts
  vim.api.nvim_buf_set_lines(
    info.original_buf,
    info.start_line - 1,
    info.end_line,
    false,
    {}
  )
  
  -- Then insert the new content
  vim.api.nvim_buf_set_lines(
    info.original_buf,
    info.start_line - 1,
    info.start_line - 1,
    false,
    lines
  )
  
  -- Update the end line for future writes
  info.end_line = new_end_line
  
  -- Restore protection
  M.protect_buffer(info.original_buf, true)
  
  info.writing = false
  vim.notify(string.format("Changes written to original buffer (lines %d-%d)", info.start_line, new_end_line), vim.log.levels.INFO)
  return true
end

-- Widen region (NrrwRgn :WR command)
function M.widen_region(close_after)
  local narrow_buf = vim.api.nvim_get_current_buf()
  local instance_id = nil
  
  -- Find the instance ID for this buffer
  for id, info in pairs(M.state.narrowed_buffers) do
    if info.narrow_buf == narrow_buf then
      instance_id = id
      break
    end
  end
  
  if not instance_id then
    vim.notify("Not in a narrowed buffer", vim.log.levels.WARN)
    return
  end
  
  -- Write changes back
  if M.write_to_original(instance_id) then
    if close_after then
      M.cleanup_narrowed_buffer(instance_id)
    end
  end
end

-- Narrow window content (NrrwRgn :NW command)
function M.narrow_window(bang)
  local start_line = vim.fn.line("w0")
  local end_line = vim.fn.line("w$")
  M.narrow_region(start_line, end_line, bang)
end

-- Narrow fold at current cursor position
function M.narrow_fold(bang)
  local fold_start, fold_end = M.get_fold_range()
  
  if fold_start == fold_end then
    vim.notify("No meaningful fold range found at cursor position", vim.log.levels.WARN)
    return
  end
  
  -- Store the fold information for visual feedback
  local fold_info = {
    start_line = fold_start,
    end_line = fold_end,
    total_lines = fold_end - fold_start + 1
  }
  
  vim.notify(string.format("Narrowing fold: lines %d-%d (%d lines)", 
    fold_start, fold_end, fold_info.total_lines), vim.log.levels.INFO)
  
  M.narrow_region(fold_start, fold_end, bang)
end

-- Narrow last region (NrrwRgn :NRL command)
function M.narrow_last(bang)
  if not M.state.last_region then
    vim.notify("No previous narrowed region", vim.log.levels.WARN)
    return
  end
  
  local last = M.state.last_region
  if not vim.api.nvim_buf_is_valid(last.buf) then
    vim.notify("Previous buffer no longer exists", vim.log.levels.WARN)
    return
  end
  
  -- Switch to the original buffer first
  local current_buf = vim.api.nvim_get_current_buf()
  if current_buf ~= last.buf then
    vim.api.nvim_set_current_buf(last.buf)
  end
  
  M.narrow_region(last.start_line, last.end_line, bang)
end

-- Cleanup narrowed buffer
function M.cleanup_narrowed_buffer(instance_id)
  local info = M.state.narrowed_buffers[instance_id]
  if not info then return end
  
  -- Clear highlighting
  vim.api.nvim_buf_clear_namespace(info.original_buf, info.namespace, 0, -1)
  
  -- Restore original buffer protection
  M.protect_buffer(info.original_buf, false)
  
  -- Force delete the buffer to clean up
  if vim.api.nvim_buf_is_valid(info.narrow_buf) then
    vim.api.nvim_buf_delete(info.narrow_buf, { force = true })
  end
  
  -- Clean up state
  M.state.narrowed_buffers[instance_id] = nil
  local original_narrowed = M.state.original_buffers[info.original_buf]
  if original_narrowed then
    for i, id in ipairs(original_narrowed) do
      if id == instance_id then
        table.remove(original_narrowed, i)
        break
      end
    end
  end
end

-- Legacy quit function
function M.quit()
  local narrow_buf = vim.api.nvim_get_current_buf()
  local instance_id = nil
  
  -- Find the instance ID for this buffer
  for id, info in pairs(M.state.narrowed_buffers) do
    if info.narrow_buf == narrow_buf then
      instance_id = id
      break
    end
  end
  
  if instance_id then
    M.cleanup_narrowed_buffer(instance_id)
  end
end

-- Legacy write function for backward compatibility
function M.write()
  M.widen_region(false)
end

function M.write_and_quit()
  M.widen_region(true)
end

return M