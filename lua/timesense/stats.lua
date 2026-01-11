-- Stats tracking module - tracks coding time and language usage

local M = {}

-- Path to stats file
local stats_file = vim.fn.stdpath("data") .. "/timesense_stats.json"

-- Current session data
M.session = {
  start_time = nil,
  current_lang = nil,
  last_active = nil,
}

-- Load stats from disk
local function load_stats()
  local file = io.open(stats_file, "r")
  if not file then
    return {
      total_time = 0,
      languages = {},
      sessions = 0,
      last_session = nil,
    }
  end
  
  local content = file:read("*all")
  file:close()
  
  local ok, data = pcall(vim.json.decode, content)
  if not ok then
    return {
      total_time = 0,
      languages = {},
      sessions = 0,
      last_session = nil,
    }
  end
  
  return data
end

-- Save stats to disk
local function save_stats(stats)
  local file = io.open(stats_file, "w")
  if file then
    file:write(vim.json.encode(stats))
    file:close()
  end
end

-- Get current stats
function M.get_stats()
  return load_stats()
end

-- Format time in human readable format
function M.format_time(seconds)
  if seconds < 60 then
    return string.format("%ds", seconds)
  elseif seconds < 3600 then
    return string.format("%dm %ds", math.floor(seconds / 60), seconds % 60)
  else
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    return string.format("%dh %dm", hours, mins)
  end
end

-- Start tracking session
function M.start_session()
  M.session.start_time = os.time()
  M.session.last_active = os.time()
  M.session.current_lang = vim.bo.filetype
end

-- Update activity timestamp
function M.update_activity()
  local now = os.time()
  
  -- If inactive for more than 5 minutes, start new session
  if M.session.last_active and (now - M.session.last_active) > 300 then
    M.end_session()
    M.start_session()
    return
  end
  
  M.session.last_active = now
  
  -- Update language if changed
  local current_ft = vim.bo.filetype
  if current_ft ~= "" and current_ft ~= M.session.current_lang then
    M.session.current_lang = current_ft
  end
end

-- End current session and save stats
function M.end_session()
  if not M.session.start_time then
    return
  end
  
  local duration = os.time() - M.session.start_time
  
  -- Ignore very short sessions (< 10 seconds)
  if duration < 10 then
    M.session = { start_time = nil, current_lang = nil, last_active = nil }
    return
  end
  
  local stats = load_stats()
  
  -- Update total time
  stats.total_time = (stats.total_time or 0) + duration
  stats.sessions = (stats.sessions or 0) + 1
  stats.last_session = os.date("%Y-%m-%d %H:%M:%S")
  
  -- Update language stats
  if M.session.current_lang and M.session.current_lang ~= "" then
    stats.languages = stats.languages or {}
    local lang = M.session.current_lang
    stats.languages[lang] = (stats.languages[lang] or 0) + duration
  end
  
  save_stats(stats)
  
  -- Reset session
  M.session = { start_time = nil, current_lang = nil, last_active = nil }
end

-- Get top languages sorted by time
function M.get_top_languages(limit)
  local stats = load_stats()
  local langs = {}
  
  for lang, time in pairs(stats.languages or {}) do
    table.insert(langs, { lang = lang, time = time })
  end
  
  table.sort(langs, function(a, b)
    return a.time > b.time
  end)
  
  if limit then
    local result = {}
    for i = 1, math.min(limit, #langs) do
      table.insert(result, langs[i])
    end
    return result
  end
  
  return langs
end

-- Setup autocmds for tracking
function M.setup_tracking()
  -- Start session on enter
  vim.api.nvim_create_autocmd({ "VimEnter" }, {
    callback = function()
      M.start_session()
    end,
  })
  
  -- Update activity on various events
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI" }, {
    callback = function()
      M.update_activity()
    end,
  })
  
  -- Save on exit
  vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
    callback = function()
      M.end_session()
    end,
  })
end

return M
