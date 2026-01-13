-- Display module - Handle extmarks and virtual text rendering

local M = {}

-- Namespace for extmarks
M.namespace = vim.api.nvim_create_namespace("timesense")

-- Track visibility state
M.visible = true

-- Clear all extmarks in buffer
function M.clear(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, M.namespace, 0, -1)
end

-- Format complexity string with icon
local function format_complexity(complexity, config)
  return string.format("%s %s", config.virtual_text_icon, complexity)
end

-- Display loop complexity
local function display_loop(bufnr, loop_info, config)
  local text = format_complexity(loop_info.complexity, config)
  
  vim.api.nvim_buf_set_extmark(bufnr, M.namespace, loop_info.line - 1, 0, {
    virt_text = { { text, config.virtual_text_hl_group } },
    virt_text_pos = "eol",
    hl_mode = "combine",
  })
end

-- Display function call complexity
local function display_function_call(bufnr, call_info, config)
  local text = format_complexity(call_info.complexity, config)
  
  vim.api.nvim_buf_set_extmark(bufnr, M.namespace, call_info.line - 1, 0, {
    virt_text = { { text, config.virtual_text_hl_group } },
    virt_text_pos = "eol",
    hl_mode = "combine",
  })
end

-- Display overall complexity near top of file
local function display_overall(bufnr, time_complexity, space_complexity, config)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 100, false)
  local target_line = 0
  
  -- Find a good place to show overall complexity
  -- Prioritize: #include, using namespace, function definitions, or first non-comment line
  for i, line in ipairs(lines) do
    local trimmed = line:match("^%s*(.-)%s*$")
    
    -- Skip empty lines and pure comment lines
    if trimmed ~= "" and not trimmed:match("^//") and not trimmed:match("^/%*") then
      if line:match("^#include") or 
         line:match("^#define") or
         line:match("^using namespace") or
         line:match("int main%(") or
         line:match("void main%(") or
         line:match("void solve%(") or
         line:match("int solve%(") or
         line:match("class%s+%w+") or
         line:match("struct%s+%w+") then
        target_line = i - 1
        break
      elseif target_line == 0 then
        -- First non-empty, non-comment line as fallback
        target_line = i - 1
      end
    end
  end
  
  -- Format overall text
  local overall_text = string.format(
    "%s Time: %s | Space: %s",
    config.virtual_text_icon,
    time_complexity,
    space_complexity
  )
  
  vim.api.nvim_buf_set_extmark(bufnr, M.namespace, target_line, 0, {
    virt_text = { { overall_text, "DiagnosticInfo" } },
    virt_text_pos = "eol",
    hl_mode = "combine",
    priority = 1000, -- Higher priority for overall
  })
end

-- Display all analysis results
function M.display(bufnr, analysis_results)
  local config = require("timesense.config").config
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  
  -- Clear existing marks
  M.clear(bufnr)
  
  if not M.visible then
    return
  end
  
  -- Display overall complexity
  display_overall(bufnr, analysis_results.overall_time, analysis_results.space, config)
  
  -- Display loop complexities
  for _, loop_info in ipairs(analysis_results.loops) do
    display_loop(bufnr, loop_info, config)
  end
  
  -- Display function call complexities
  for _, call_info in ipairs(analysis_results.function_calls) do
    display_function_call(bufnr, call_info, config)
  end
end

-- Toggle visibility
function M.toggle(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  M.visible = not M.visible
  
  if not M.visible then
    M.clear(bufnr)
  end
  
  return M.visible
end

-- Hide (set visibility to false and clear)
function M.hide(bufnr)
  M.visible = false
  M.clear(bufnr)
end

-- Show (set visibility to true, but don't re-run analysis)
function M.show()
  M.visible = true
end

return M
