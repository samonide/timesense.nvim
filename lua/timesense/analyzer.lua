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

-- Compare two complexity strings and return the dominant one
local function get_dominant_complexity(c1, c2)
  -- Complexity hierarchy (from lowest to highest)
  local hierarchy = {
    ["O(1)"] = 1,
    ["O(α(n))"] = 2,  -- Union-Find amortized
    ["O(log n)"] = 3,
    ["O(log² n)"] = 4,
    ["O(√n)"] = 5,
    ["O(L)"] = 6,  -- Trie operations (length of string)
    ["O(n)"] = 7,
    ["O(n log n)"] = 8,
    ["O(n log log n)"] = 9,  -- Sieve
    ["O(n√n)"] = 10,
    ["O(n²)"] = 11,
    ["O(n² log n)"] = 12,
    ["O(n³)"] = 13,
    ["O(V+E)"] = 14,  -- Graph traversal
    ["O(V×E)"] = 15,  -- Bellman-Ford
    ["O(E log V)"] = 16,  -- Dijkstra
    ["O(2^n)"] = 17,
    ["O(n!)"] = 18,
  }
  
  local rank1 = hierarchy[c1] or 100
  local rank2 = hierarchy[c2] or 100
  
  return rank1 >= rank2 and c1 or c2
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
  if inner1 == "n" and inner2 == "n log n" then return "O(n² log n)" end
  if inner1 == "n log n" and inner2 == "n" then return "O(n² log n)" end
  if inner1 == "n²" and inner2 == "n" then return "O(n³)" end
  if inner1 == "n" and inner2 == "n²" then return "O(n³)" end
  if inner1 == "log n" and inner2 == "log n" then return "O(log² n)" end
  if inner1 == "√n" and inner2 == "n" then return "O(n√n)" end
  if inner1 == "n" and inner2 == "√n" then return "O(n√n)" end
  
  -- Default to squared
  return "O(" .. inner1 .. " × " .. inner2 .. ")"
end

-- Analyze a single loop line
local function analyze_loop_line(line)
  -- Check for log complexity patterns
  -- i *= 2, i /= 2, i <<= 1, i >>= 1, i = i * 2, i = i / 2
  if line:match("[%w_]+%s*%*=%s*2") or 
     line:match("[%w_]+%s*/=%s*2") or
     line:match("[%w_]+%s*<<=%s*%d+") or
     line:match("[%w_]+%s*>>=%s*%d+") or
     line:match("[%w_]+%s*=%s*[%w_]+%s*%*%s*2") or
     line:match("[%w_]+%s*=%s*[%w_]+%s*/%s*2") then
    return "O(log n)"
  end
  
  -- Bitwise optimization: i = i & (i-1) for counting set bits
  if line:match("[%w_]+%s*&=%s*%(.-%-.-%)") or 
     line:match("[%w_]+%s*=%s*[%w_]+%s*&%s*%(.-%-.-%)") then
    return "O(log n)"
  end
  
  -- Check for sqrt patterns
  -- i * i < n, i * i <= n, i <= sqrt(n)
  if line:match("[%w_]+%s*%*%s*[%w_]+%s*[<>]=?%s*[%w_]+") or
     line:match("sqrt%s*%(") then
    return "O(√n)"
  end
  
  -- Check for i += i patterns (also log)
  if line:match("[%w_]+%s*%+=%s*[%w_]+") then
    local var = line:match("([%w_]+)%s*%+=")
    if var and line:match(var .. "%s*%+=%s*" .. var) then
      return "O(log n)"
    end
  end
  
  -- Default: linear
  return "O(n)"
end

-- Analyze for loop complexity
local function analyze_for_loop(line)
  -- Range-based for loop: for(auto x : container) or for(int x : arr)
  if line:match("for%s*%(.-%s*:%s*.-%)") then
    return "O(n)"
  end
  
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
  -- sort(), stable_sort() -> O(n log n)
  if line:match("sort%s*%(") or line:match("stable_sort%s*%(") then
    return { time = "O(n log n)", is_call = true }
  end
  
  -- binary_search, lower_bound, upper_bound, equal_range -> O(log n)
  if line:match("binary_search%s*%(") or 
     line:match("lower_bound%s*%(") or
     line:match("upper_bound%s*%(") or
     line:match("equal_range%s*%(") then
    return { time = "O(log n)", is_call = true }
  end
  
  -- next_permutation, prev_permutation, reverse, fill, copy, move -> O(n)
  if line:match("next_permutation%s*%(") or 
     line:match("prev_permutation%s*%(") or
     line:match("reverse%s*%(") or
     line:match("fill%s*%(") or
     line:match("copy%s*%(") or
     line:match("move%s*%(") or
     line:match("swap%s*%(") or
     line:match("rotate%s*%(") or
     line:match("unique%s*%(") or
     line:match("remove%s*%(") or
     line:match("find%s*%(") or
     line:match("count%s*%(") or
     line:match("accumulate%s*%(") then
    return { time = "O(n)", is_call = true }
  end
  
  -- nth_element, partition -> O(n) average
  if line:match("nth_element%s*%(") or
     line:match("partition%s*%(") then
    return { time = "O(n)", is_call = true }
  end
  
  -- set_union, set_intersection, set_difference -> O(n)
  if line:match("set_union%s*%(") or
     line:match("set_intersection%s*%(") or
     line:match("set_difference%s*%(") then
    return { time = "O(n)", is_call = true }
  end
  
  -- make_heap, push_heap, pop_heap -> O(log n)
  if line:match("push_heap%s*%(") or
     line:match("pop_heap%s*%(") then
    return { time = "O(log n)", is_call = true }
  end
  
  -- make_heap, sort_heap -> O(n log n)
  if line:match("make_heap%s*%(") or
     line:match("sort_heap%s*%(") then
    return { time = "O(n log n)", is_call = true }
  end
  
  -- __gcd, gcd -> O(log n)
  if line:match("__gcd%s*%(") or line:match("gcd%s*%(") then
    return { time = "O(log n)", is_call = true }
  end
  
  -- priority_queue/set/map operations: insert, erase, find -> O(log n)
  if line:match("%.insert%s*%(") or 
     line:match("%.erase%s*%(") or
     line:match("%.find%s*%(") or
     line:match("%.count%s*%(") or
     line:match("%.lower_bound%s*%(") or
     line:match("%.upper_bound%s*%(") then
    return { time = "O(log n)", is_call = true }
  end
  
  -- Unordered map/set operations: insert, find, erase -> O(1) average
  if line:match("unordered_") and (line:match("%.insert%s*%(") or 
     line:match("%.find%s*%(") or line:match("%.erase%s*%(")
  ) then
    return { time = "O(1)", is_call = true }
  end
  
  -- String operations
  if line:match("%.substr%s*%(") or
     line:match("%.find%s*%(") and line:match("string") or
     line:match("%.compare%s*%(") then
    return { time = "O(n)", is_call = true }
  end
  
  -- memset, memcpy -> O(n)
  if line:match("memset%s*%(") or line:match("memcpy%s*%(")
  then
    return { time = "O(n)", is_call = true }
  end
  
  -- pow, sqrt, log, exp -> O(1) or O(log n)
  if line:match("pow%s*%(") or line:match("sqrt%s*%(") or
     line:match("log%s*%(") or line:match("exp%s*%(")
  then
    return { time = "O(1)", is_call = true }
  end
  
  -- KMP, Z-algorithm (if custom implementation detected)
  if line:match("kmp%s*%(") or line:match("z_algorithm%s*%(")
  then
    return { time = "O(n)", is_call = true }
  end
  
  -- Sieve of Eratosthenes
  if line:match("sieve%s*%(") then
    return { time = "O(n log log n)", is_call = true }
  end
  
  -- Matrix operations
  if line:match("multiply_matrix%s*%(") or line:match("matmul%s*%(")
  then
    return { time = "O(n³)", is_call = true }
  end
  
  -- DFS/BFS (graph traversal)
  if line:match("dfs%s*%(") or line:match("bfs%s*%(")
  then
    return { time = "O(V+E)", is_call = true }
  end
  
  -- Dijkstra
  if line:match("dijkstra%s*%(")
  then
    return { time = "O(E log V)", is_call = true }
  end
  
  -- Floyd-Warshall
  if line:match("floyd%s*%(") or line:match("warshall%s*%(")
  then
    return { time = "O(n³)", is_call = true }
  end
  
  -- Bellman-Ford
  if line:match("bellman%s*%(") then
    return { time = "O(V×E)", is_call = true }
  end
  
  -- Union-Find / DSU operations
  if line:match("%.find_set%s*%(") or line:match("%.union_set%s*%(") or
     line:match("find_parent%s*%(") or line:match("unite%s*%(")
  then
    return { time = "O(α(n))", is_call = true }
  end
  
  -- Segment tree / Fenwick tree operations
  if line:match("%.query%s*%(") or line:match("%.update%s*%(") or
     line:match("segment_tree") or line:match("fenwick%s*%(")
  then
    return { time = "O(log n)", is_call = true }
  end
  
  -- Trie operations
  if line:match("trie") and (line:match("%.insert%s*%(") or line:match("%.search%s*%(")
  ) then
    return { time = "O(L)", is_call = true }
  end
  
  -- next() iterator operation
  if line:match("next%s*%(") or line:match("prev%s*%(")
  then
    return { time = "O(1)", is_call = true }
  end
  
  return nil
end

-- Analyze space complexity from declarations
local function analyze_space(lines)
  local space_items = {}
  
  for i, line in ipairs(lines) do
    -- Vector/array declarations: vector<int> v(n), int arr[n]
    if line:match("vector%s*<") or 
       line:match("int%s+%w+%s*%[") or 
       line:match("long%s+long%s+%w+%s*%[") or 
       line:match("string%s+%w+%s*%[") or
       line:match("set%s*<") or
       line:match("map%s*<") or
       line:match("unordered_set%s*<") or
       line:match("unordered_map%s*<") or
       line:match("priority_queue%s*<") or
       line:match("queue%s*<") or
       line:match("stack%s*<") or
       line:match("deque%s*<") then
      
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
    
    -- 2D arrays/vectors/maps
    if line:match("vector%s*<.*vector%s*<") or 
       line:match("map%s*<.*vector%s*<") or
       line:match("%[%s*%w+%s*%]%s*%[%s*%w+%s*%]") then
      table.insert(space_items, { line = i, complexity = "O(n²)" })
    end
    
    -- Segment tree, Fenwick tree (typically O(n))
    if line:match("segment_tree") or line:match("fenwick") or line:match("bit%s*%[")
    then
      table.insert(space_items, { line = i, complexity = "O(n)" })
    end
    
    -- DSU/Union-Find parent array
    if line:match("parent%s*%[") or line:match("rank%s*%[") then
      table.insert(space_items, { line = i, complexity = "O(n)" })
    end
    
    -- Adjacency list for graphs
    if line:match("vector%s*<.*>%s+adj%s*%[") or line:match("graph%s*%[")
    then
      table.insert(space_items, { line = i, complexity = "O(V+E)" })
    end
  end
  
  -- Calculate overall space - take the maximum
  local max_space = "O(1)"
  for _, item in ipairs(space_items) do
    max_space = get_dominant_complexity(max_space, item.complexity)
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
    functions = {},      -- Per-function complexity summaries
  }
  
  -- Track nesting level and current context
  local nesting_stack = {}
  local brace_depth = 0
  
  -- Track current function
  local current_function = nil
  local function_stack = {}
  
  -- Analyze space first
  results.space, results.space_items = analyze_space(lines)
  
  -- Analyze time complexity
  for i, line in ipairs(lines) do
    local trimmed = line:match("^%s*(.-)%s*$")
    
    -- Track opening braces for scope depth
    local open_braces = 0
    local close_braces = 0
    for c in line:gmatch(".") do
      if c == "{" then open_braces = open_braces + 1 end
      if c == "}" then close_braces = close_braces + 1 end
    end
    
    -- Detect function definitions
    local func_match = trimmed:match("^([%w_]+)%s+([%w_]+)%s*%(") or 
                       trimmed:match("^(void)%s+([%w_]+)%s*%(") or
                       trimmed:match("^(int)%s+([%w_]+)%s*%(") or
                       trimmed:match("^(bool)%s+([%w_]+)%s*%(") or
                       trimmed:match("^(long%s+long)%s+([%w_]+)%s*%(")
    
    if func_match and not trimmed:match("^if%s*%(") and not trimmed:match("^while%s*%(") and 
       not trimmed:match("^for%s*%(") and not trimmed:match("^switch%s*%(") then
      -- Extract function name (second capture group)
      local func_name = trimmed:match("^[%w_]+%s+([%w_]+)%s*%(") or
                        trimmed:match("^void%s+([%w_]+)%s*%(") or
                        trimmed:match("^int%s+([%w_]+)%s*%(") or
                        trimmed:match("^bool%s+([%w_]+)%s*%(") or
                        trimmed:match("^long%s+long%s+([%w_]+)%s*%(")
      
      if func_name and func_name ~= "if" and func_name ~= "while" and 
         func_name ~= "for" and func_name ~= "switch" then
        -- Start tracking new function
        current_function = {
          name = func_name,
          line = i,
          time_complexity = "O(1)",
          space_complexity = "O(1)",
          start_depth = brace_depth + open_braces,
        }
        table.insert(function_stack, current_function)
      end
    end
    
    -- Skip comments and empty lines
    if not trimmed:match("^//") and not trimmed:match("^%s*$") then
      
      -- Detect loops
      local loop_type = nil
      local base_complexity = "O(1)"
      
      if trimmed:match("^for%s*%(") then
        loop_type = "for"
        base_complexity = analyze_for_loop(trimmed)
      elseif trimmed:match("^while%s*%(") then
        loop_type = "while"
        base_complexity = analyze_while_loop(trimmed)
      elseif trimmed:match("^do%s*{") or trimmed:match("^do%s*$") then
        loop_type = "do"
        base_complexity = "O(n)"
      end
      
      if loop_type then
        -- Calculate effective complexity with nesting
        local effective = base_complexity
        for _, parent_complexity in ipairs(nesting_stack) do
          effective = multiply_complexity(parent_complexity, effective)
        end
        
        table.insert(results.loops, {
          line = i,
          complexity = effective,
          base_complexity = base_complexity,
          nesting_level = #nesting_stack,
        })
        
        -- Push to stack
        table.insert(nesting_stack, base_complexity)
        
        -- Update overall time complexity - compare and take dominant
        if effective ~= "O(1)" then
          results.overall_time = get_dominant_complexity(results.overall_time, effective)
          -- Update current function complexity
          if current_function then
            current_function.time_complexity = get_dominant_complexity(
              current_function.time_complexity, effective)
          end
        end
      end
      
      -- Detect closing braces to pop nesting
      if trimmed:match("^}") and #nesting_stack > 0 then
        table.remove(nesting_stack)
      end
      
      -- Detect function calls
      local func_analysis = analyze_function_call(trimmed)
      if func_analysis then
        -- Calculate effective complexity considering current nesting
        local call_base_complexity = func_analysis.time
        local effective_call_complexity = call_base_complexity
        
        -- If we're inside loops, multiply the function call complexity
        for _, parent_complexity in ipairs(nesting_stack) do
          effective_call_complexity = multiply_complexity(parent_complexity, effective_call_complexity)
        end
        
        table.insert(results.function_calls, {
          line = i,
          complexity = effective_call_complexity,
          base_complexity = call_base_complexity,
          nesting_level = #nesting_stack,
        })
        
        -- Update overall time complexity with effective function call complexity
        if effective_call_complexity ~= "O(1)" then
          results.overall_time = get_dominant_complexity(results.overall_time, effective_call_complexity)
          -- Update current function complexity
          if current_function then
            current_function.time_complexity = get_dominant_complexity(
              current_function.time_complexity, effective_call_complexity)
          end
        end
      end
    end
    
    -- Update brace depth
    brace_depth = brace_depth + open_braces - close_braces
    
    -- Check if we're exiting a function
    if current_function and brace_depth < current_function.start_depth then
      -- Function ended, save it to results
      table.insert(results.functions, {
        name = current_function.name,
        line = current_function.line,
        time_complexity = current_function.time_complexity,
        space_complexity = current_function.space_complexity,
      })
      table.remove(function_stack)
      current_function = function_stack[#function_stack]
    end
  end
  
  -- Add any remaining functions
  for _, func in ipairs(function_stack) do
    table.insert(results.functions, {
      name = func.name,
      line = func.line,
      time_complexity = func.time_complexity,
      space_complexity = func.space_complexity,
    })
  end
  
  return results
end

return M
