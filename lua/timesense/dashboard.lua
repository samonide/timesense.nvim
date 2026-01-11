-- Dashboard UI module - creates floating window with stats

local M = {}

local stats = require("timesense.stats")

-- Create centered floating window
local function create_float()
  local width = 60
  local height = 20
  
  local buf = vim.api.nvim_create_buf(false, true)
  
  -- Calculate center position
  local ui = vim.api.nvim_list_uis()[1]
  local win_width = ui.width
  local win_height = ui.height
  
  local col = math.floor((win_width - width) / 2)
  local row = math.floor((win_height - height) / 2)
  
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
    title = " Timesense Stats ",
    title_pos = "center",
  }
  
  local win = vim.api.nvim_open_win(buf, true, opts)
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  
  -- Set window options
  vim.api.nvim_win_set_option(win, "cursorline", true)
  vim.api.nvim_win_set_option(win, "winblend", 0)
  
  -- Close on q or ESC
  vim.keymap.set("n", "q", ":close<CR>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<ESC>", ":close<CR>", { buffer = buf, silent = true })
  
  return buf, win
end

-- Format a bar chart
local function create_bar(percentage, width)
  local filled = math.floor(percentage * width / 100)
  local empty = width - filled
  return string.rep("█", filled) .. string.rep("░", empty)
end

-- Generate dashboard content
local function generate_content()
  local data = stats.get_stats()
  local lines = {}
  local highlights = {}
  
  -- Header
  table.insert(lines, "")
  table.insert(lines, "  ⏱️  CODING STATISTICS")
  table.insert(lines, "")
  table.insert(lines, string.rep("─", 58))
  table.insert(lines, "")
  
  -- Total time
  local total_formatted = stats.format_time(data.total_time or 0)
  table.insert(lines, string.format("  Total Coding Time: %s", total_formatted))
  table.insert(highlights, { line = #lines - 1, col_start = 23, col_end = 23 + #total_formatted, hl_group = "Number" })
  
  -- Sessions
  table.insert(lines, string.format("  Total Sessions:    %d", data.sessions or 0))
  table.insert(highlights, { line = #lines - 1, col_start = 23, col_end = 30, hl_group = "Number" })
  
  -- Last session
  if data.last_session then
    table.insert(lines, string.format("  Last Session:      %s", data.last_session))
  end
  
  table.insert(lines, "")
  table.insert(lines, string.rep("─", 58))
  table.insert(lines, "")
  
  -- Top languages
  table.insert(lines, "  📊 TOP LANGUAGES")
  table.insert(lines, "")
  
  local top_langs = stats.get_top_languages(5)
  
  if #top_langs == 0 then
    table.insert(lines, "  No data yet. Start coding!")
  else
    local max_time = top_langs[1].time
    
    for i, lang_data in ipairs(top_langs) do
      local lang = lang_data.lang
      local time = lang_data.time
      local formatted = stats.format_time(time)
      local percentage = math.floor((time / max_time) * 100)
      
      -- Language name and time
      local line = string.format("  %d. %-12s %s", i, lang:upper(), formatted)
      table.insert(lines, line)
      table.insert(highlights, { line = #lines - 1, col_start = 5, col_end = 5 + #lang, hl_group = "String" })
      
      -- Bar chart
      local bar = create_bar(percentage, 40)
      table.insert(lines, string.format("     %s %d%%", bar, percentage))
      table.insert(highlights, { line = #lines - 1, col_start = 5, col_end = 45, hl_group = "Comment" })
      table.insert(highlights, { line = #lines - 1, col_start = 46, col_end = 50, hl_group = "Number" })
      
      table.insert(lines, "")
    end
  end
  
  table.insert(lines, "")
  table.insert(lines, string.rep("─", 58))
  table.insert(lines, "")
  table.insert(lines, "  Press 'q' or ESC to close")
  
  return lines, highlights
end

-- Show stats dashboard
function M.show()
  local buf, win = create_float()
  local lines, highlights = generate_content()
  
  -- Set content
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  
  -- Apply highlights
  local ns = vim.api.nvim_create_namespace("timesense_dashboard")
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, ns, hl.hl_group, hl.line, hl.col_start, hl.col_end)
  end
  
  -- Title highlight
  vim.api.nvim_buf_add_highlight(buf, ns, "Title", 1, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, ns, "Title", 8, 0, -1)
end

return M
