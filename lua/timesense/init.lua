-- Main module - Command interface and orchestration

local M = {}

local analyzer = require("timesense.analyzer")
local display = require("timesense.display")
local config = require("timesense.config")
local stats = require("timesense.stats")
local dashboard = require("timesense.dashboard")

-- Store last analysis results per buffer
M.last_analysis = {}

-- Setup function for user configuration
function M.setup(user_config)
  config.setup(user_config)
  
  -- Setup time tracking
  stats.setup_tracking()
end

-- Run complexity analysis and display results
local function run_complexity_analysis(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  
  -- Check if buffer is a supported filetype
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  if filetype ~= "cpp" and filetype ~= "c" then
    vim.notify("Timesense: Only C/C++ files are currently supported", vim.log.levels.WARN)
    return
  end
  
  -- Run analysis
  local results = analyzer.analyze(bufnr)
  
  -- Store results
  M.last_analysis[bufnr] = results
  
  -- Display results
  display.display(bufnr, results)
  
  -- Show summary
  vim.notify(
    string.format(
      "Timesense: Time: %s | Space: %s | %d loops analyzed",
      results.overall_time,
      results.space,
      #results.loops
    ),
    vim.log.levels.INFO
  )
end

-- Hide complexity hints
local function hide_complexity(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  display.hide(bufnr)
  vim.notify("Timesense: Complexity hints hidden", vim.log.levels.INFO)
end

-- Toggle complexity visibility
local function toggle_complexity(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local visible = display.toggle(bufnr)
  
  if visible and M.last_analysis[bufnr] then
    -- Re-display last analysis
    display.display(bufnr, M.last_analysis[bufnr])
    vim.notify("Timesense: Complexity hints shown", vim.log.levels.INFO)
  else
    vim.notify("Timesense: Complexity hints hidden", vim.log.levels.INFO)
  end
end

-- Set problem constraints
local function set_constraints(args)
  if #args < 1 then
    vim.notify("Timesense: Usage: :Timesense constraints <n> [time_ms] [memory_mb]", vim.log.levels.ERROR)
    return
  end
  
  local n = tonumber(args[1])
  local time_ms = args[2] and tonumber(args[2])
  local memory_mb = args[3] and tonumber(args[3])
  
  if not n then
    vim.notify("Timesense: Invalid constraint value", vim.log.levels.ERROR)
    return
  end
  
  config.set_constraints(n, time_ms, memory_mb)
  
  local msg = string.format("Timesense: Constraints set - n=%s", n)
  if time_ms then
    msg = msg .. string.format(", time=%dms", time_ms)
  end
  if memory_mb then
    msg = msg .. string.format(", memory=%dMB", memory_mb)
  end
  
  vim.notify(msg, vim.log.levels.INFO)
end

-- Main command handler
function M.command(args)
  if #args == 0 then
    vim.notify("Timesense: Usage: :Timesense <complexity|hide|toggle|constraints|stats>", vim.log.levels.ERROR)
    return
  end
  
  local cmd = args[1]:lower()
  
  if cmd == "complexity" then
    run_complexity_analysis()
  elseif cmd == "hide" then
    hide_complexity()
  elseif cmd == "toggle" then
    toggle_complexity()
  elseif cmd == "constraints" then
    local constraint_args = {}
    for i = 2, #args do
      table.insert(constraint_args, args[i])
    end
    set_constraints(constraint_args)
  elseif cmd == "stats" then
    dashboard.show()
  else
    vim.notify("Timesense: Unknown command: " .. cmd, vim.log.levels.ERROR)
  end
end

return M
