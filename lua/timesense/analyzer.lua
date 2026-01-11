-- Complexity Analyzer - Rule-based static analysis for C++

local M = {}

-- Complexity class for easier manipulation
local Complexity = {}
Complexity.__index = Complexity

function Complexity.new(time, space, description)
  return setmetatable({
    time = time or "O(1)",
    space = space or "O(1)",
    description = description or "",
  }, Complexity)
end

-- Multiply two complexity strings (for nested loops)
local function multiply_complexity(c1, c2)
  -- Simple heuristic multiplication
  -- O(1) * anything = anything
  if c1 == "O(1)" then return c2 end
  if c2 == "O(1)" then return c1 end
  
  -- Extract the inner part
  local inner1 = c1:match("O%((.+)%)")
  local inner2 = c2:match("O%((.+)%)")
  
  if not inner1 or not inner2 then return "O(n²)" end
  
  -- Common patterns
  if inner1 == "n" and inner2 == "n" then return "O(n²)" end
  if inner1 == "n" and inner2 == "log n" then return "O(n log n)" end
  if inner1 == "log n" and inner2 == "n" then return "O(n log n)" end
  if inner1 == "n²" and inner2 == "n" then return "O(n³)" end
  if inner1 == "n" and inner2 == "n²" then return "O(n³)" end
  
  -- Default to squared
  return "O(" .. inner1 .. " × " .. inner2 .. ")"
end

-- Analyze a single loop line
local function analyze_loop_line(line)
  -- Check for log complexity patterns
  -- i *= 2, i /= 2, i <<= 1, i >>= 1, i = i * 2, i = i / 2
  if line:match("[%w_]+%s*[*%%]=%s*2") or 
     line:match("[%w_]+%s*/=%s*2") or
     line:match("[%w_]+%s*<<=") or
     line:match("[%w_]+%s*>>=") or
     line:match("[%w_]+%s*=%s*[%w_]+%s*[*/]%s*2") then
    return "O(log n)"
  end
  
  -- Check for sqrt patterns
  -- i * i < n, i * i <= n
  if line:match("[%w_]+%s*%*%s*[%w_]+%s*[<>]=?%s*[%w_]+") then
    return "O(√n)"
  end
  
  -- Default: linear
  return "O(n)"
end

-- Analyze for loop complexity
local function analyze_for_loop(line)
  -- Pattern: for (init; condition; increment)
  local init, cond, incr = line:match("for%s*%((.-)%;(.-)%;(.-)%)")
  
  if incr then
    return analyze_loop_line(incr)
  end
  
  return "O(n)"
end

-- Analyze while loop complexity
local function analyze_while_loop(line)
  -- Try to detect common patterns in condition
  if line:match("while%s*%(.*[*/].*%)") then
    return "O(log n)"
  end
  
  return "O(n)"
end

-- Detect standard library function complexities
local function analyze_function_call(line)
  -- sort() -> O(n log n)
  if line:match("sort%s*%(") then
    return { time = "O(n log n)", is_call = true }
  end
  
  -- binary_search, lower_bound, upper_bound -> O(log n)
  if line:match("binary_search%s*%(") or 
     line:match("lower_bound%s*%(") or
     line:match("upper_bound%s*%(") then
    return { time = "O(log n)", is_call = true }
  end
  
  -- next_permutation, prev_permutation -> O(n)
  if line:match("next_permutation%s*%(") or 
     line:match("prev_permutation%s*%(") then
    return { time = "O(n)", is_call = true }
  end
  
  -- reverse, fill -> O(n)
  if line:match("reverse%s*%(") or 
     line:match("fill%s*%(") then
    return { time = "O(n)", is_call = true }
  end
  
  return nil
end

-- Analyze space complexity from declarations
local function analyze_space(lines)
  local space_items = {}
  
  for i, line in ipairs(lines) do
    -- Vector/array declarations: vector<int> v(n), int arr[n]
    if line:match("vector%s*<") or line:match("int%s+%w+%s*%[") or 
       line:match("long%s+long%s+%w+%s*%[") or line:match("string%s+%w+%s*%[") then
      
      -- Try to detect size
      local size = line:match("%[%s*(%w+)%s*%]") or line:match("%((%w+)%)")
      if size and size:match("^%d+$") then
        -- Constant size
        table.insert(space_items, { line = i, complexity = "O(1)" })
      elseif size then
        -- Variable size (assume O(n))
        table.insert(space_items, { line = i, complexity = "O(n)" })
      else
        table.insert(space_items, { line = i, complexity = "O(n)" })
      end
    end
    
    -- 2D arrays/vectors
    if line:match("vector%s*<.*vector%s*<") or 
       line:match("%[%s*%w+%s*%]%s*%[%s*%w+%s*%]") then
      table.insert(space_items, { line = i, complexity = "O(n²)" })
    end
  end
  
  -- Calculate overall space
  local max_space = "O(1)"
  for _, item in ipairs(space_items) do
    if item.complexity == "O(n²)" then
      max_space = "O(n²)"
    elseif item.complexity == "O(n)" and max_space ~= "O(n²)" then
      max_space = "O(n)"
    end
  end
  
  return max_space, space_items
end

-- Main analysis function
function M.analyze(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  
  local results = {
    loops = {},          -- { line, complexity, nesting_level }
    function_calls = {}, -- { line, complexity }
    space = "O(1)",      -- Overall space complexity
    space_items = {},    -- Individual space allocations
    overall_time = "O(1)", -- Overall time complexity
  }
  
  -- Track nesting level
  local nesting_stack = {}
  local current_complexity = "O(1)"
  
  -- Analyze space first
  results.space, results.space_items = analyze_space(lines)
  
  -- Analyze time complexity
  for i, line in ipairs(lines) do
    local trimmed = line:match("^%s*(.-)%s*$")
    
    -- Skip comments and empty lines
    if not trimmed:match("^//") and not trimmed:match("^%s*$") then
      
      -- Detect loops
      local loop_type = nil
      local complexity = "O(1)"
      
      if trimmed:match("^for%s*%(") then
        loop_type = "for"
        complexity = analyze_for_loop(trimmed)
      elseif trimmed:match("^while%s*%(") then
        loop_type = "while"
        complexity = analyze_while_loop(trimmed)
      elseif trimmed:match("^do%s*{") or trimmed:match("^do%s*$") then
        loop_type = "do"
        complexity = "O(n)"
      end
      
      if loop_type then
        -- Calculate effective complexity with nesting
        local effective = complexity
        for _, parent_complexity in ipairs(nesting_stack) do
          effective = multiply_complexity(parent_complexity, effective)
        end
        
        table.insert(results.loops, {
          line = i,
          complexity = effective,
          base_complexity = complexity,
          nesting_level = #nesting_stack,
        })
        
        -- Push to stack
        table.insert(nesting_stack, complexity)
        
        -- Update overall time complexity
        if effective ~= "O(1)" then
          results.overall_time = effective
        end
      end
      
      -- Detect closing braces to pop nesting
      if trimmed:match("^}") and #nesting_stack > 0 then
        table.remove(nesting_stack)
      end
      
      -- Detect function calls
      local func_analysis = analyze_function_call(trimmed)
      if func_analysis then
        table.insert(results.function_calls, {
          line = i,
          complexity = func_analysis.time,
        })
      end
    end
  end
  
  return results
end

return M
