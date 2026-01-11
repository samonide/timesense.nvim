-- Configuration and constraint management

local M = {}

-- Default configuration
M.defaults = {
  -- Visual settings
  virtual_text_icon = "🧠",
  virtual_text_hl_group = "Comment",
  enabled = true,
  
  -- Problem constraints (can be overridden per problem)
  constraints = {
    n = nil,           -- Problem size
    time_limit_ms = nil,  -- Time limit in milliseconds
    memory_limit_mb = nil, -- Memory limit in MB
  },
  
  -- Complexity thresholds for warnings
  thresholds = {
    time_warning = 1e8,  -- Operations per second threshold
    space_warning = 256, -- MB threshold
  },
}

-- Current configuration (merged with user settings)
M.config = vim.deepcopy(M.defaults)

-- User-defined constraints for current session/file
M.user_constraints = {}

-- Setup function to merge user config
function M.setup(user_config)
  M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
end

-- Set problem constraints
function M.set_constraints(n, time_ms, memory_mb)
  M.user_constraints = {
    n = tonumber(n),
    time_limit_ms = tonumber(time_ms),
    memory_limit_mb = tonumber(memory_mb),
  }
end

-- Get current constraints (user-defined or defaults)
function M.get_constraints()
  return vim.tbl_deep_extend("force", M.config.constraints, M.user_constraints)
end

-- Check if analysis should show warnings based on constraints
function M.should_warn(operations, space_mb)
  local constraints = M.get_constraints()
  local warnings = {}
  
  if constraints.n and constraints.time_limit_ms then
    local max_ops = (constraints.time_limit_ms / 1000) * M.config.thresholds.time_warning
    if operations > max_ops then
      table.insert(warnings, string.format("⚠️  Time: ~%.2e ops (limit ~%.2e)", operations, max_ops))
    end
  end
  
  if constraints.memory_limit_mb and space_mb then
    if space_mb > constraints.memory_limit_mb then
      table.insert(warnings, string.format("⚠️  Space: ~%d MB (limit %d MB)", space_mb, constraints.memory_limit_mb))
    end
  end
  
  return warnings
end

return M
