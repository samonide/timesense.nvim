# Usage Guide

## Commands

### Complexity Analysis
```vim
:Timesense complexity
```
Analyzes the current buffer and displays inline complexity hints as virtual text.

### Stats Dashboard
```vim
:Timesense stats
```
Opens a floating window showing coding statistics:
- Total coding time
- Number of sessions
- Top 5 languages with usage bars
- Last session timestamp

### Visibility Control
```vim
:Timesense hide       " Remove all hints
:Timesense toggle     " Toggle visibility
```

### Problem Constraints
```vim
:Timesense constraints <n> [time_ms] [memory_mb]
```
Set problem constraints for TLE/MLE warnings.

**Example:**
```vim
" n=10^5, 2000ms time limit, 256MB memory
:Timesense constraints 100000 2000 256
```

## Configuration

### Basic Setup
```lua
require('timesense').setup({
  virtual_text_icon = '🧠',
  virtual_text_hl_group = 'Comment',
  enabled = true,
})
```

### Full Configuration
```lua
require('timesense').setup({
  -- Visual settings
  virtual_text_icon = '🧠',          -- Icon shown in hints
  virtual_text_hl_group = 'Comment', -- Highlight group
  enabled = true,                     -- Enable by default
  
  -- Problem constraints
  constraints = {
    n = nil,              -- Problem size
    time_limit_ms = nil,  -- Time limit
    memory_limit_mb = nil, -- Memory limit
  },
  
  -- Warning thresholds
  thresholds = {
    time_warning = 1e8,   -- Operations per second
    space_warning = 256,  -- MB
  },
})
```

### Custom Keybindings
```lua
vim.keymap.set('n', '<leader>tc', ':Timesense complexity<CR>', { desc = 'Analyze complexity' })
vim.keymap.set('n', '<leader>ts', ':Timesense stats<CR>', { desc = 'Show stats' })
vim.keymap.set('n', '<leader>tt', ':Timesense toggle<CR>', { desc = 'Toggle hints' })
```

## Complexity Patterns

### Time Complexity

| Pattern | Complexity |
|---------|------------|
| `for (i = 0; i < n; i++)` | O(n) |
| `for (i = 0; i < n; i *= 2)` | O(log n) |
| `for (i = 0; i < n; i /= 2)` | O(log n) |
| `for (i = 0; i * i < n; i++)` | O(√n) |
| Nested: `for { for { } }` | O(n²) |
| `sort(arr.begin(), arr.end())` | O(n log n) |
| `binary_search(...)` | O(log n) |
| `lower_bound(...)`, `upper_bound(...)` | O(log n) |
| `reverse(...)`, `fill(...)` | O(n) |
| `next_permutation(...)` | O(n) |

### Space Complexity

| Pattern | Complexity |
|---------|------------|
| `vector<int> v(n)` | O(n) |
| `int arr[n]` | O(n) |
| `int arr[1000]` | O(1) |
| `vector<vector<int>>` | O(n²) |
| `int arr[n][m]` | O(n×m) |

## Examples

### Basic Analysis
```cpp
#include <bits/stdc++.h>
using namespace std;

void solve() {
    int n;
    cin >> n;
    vector<int> arr(n);           // Space: O(n)
    
    for (int i = 0; i < n; i++) { // 🧠 O(n)
        cin >> arr[i];
    }
    
    sort(arr.begin(), arr.end()); // 🧠 O(n log n)
    
    for (int i = 0; i < n; i++) { // 🧠 O(n²)
        for (int j = i + 1; j < n; j++) {
            cout << arr[i] + arr[j];
        }
    }
}
```

After running `:Timesense complexity`, you'll see:
- `🧠 Time: O(n²) | Space: O(n)` at the top
- Individual complexity hints beside each loop

### Binary Search Pattern
```cpp
for (int i = 1; i < n; i *= 2) { // 🧠 O(log n)
    cout << i << " ";
}
```

### Square Root Loop
```cpp
for (int i = 0; i * i < n; i++) { // 🧠 O(√n)
    cout << i << " ";
}
```

## Stats Dashboard

The stats dashboard tracks your coding activity automatically:

**Features:**
- Automatic time tracking per language
- Pauses after 5 minutes of inactivity
- Persists data across sessions
- Visual progress bars
- Top 5 languages by time spent

**Storage:**
Stats are saved to `~/.local/share/nvim/timesense_stats.json`

**Dashboard Controls:**
- `q` or `ESC` to close
- Automatically updates on each view

## Tips

1. **Workflow**: Run `:Timesense complexity` before submitting to catch TLE issues
2. **Constraints**: Set problem limits with `:Timesense constraints` for warnings
3. **Stats**: Check `:Timesense stats` to see your coding habits
4. **Toggle**: Use `:Timesense toggle` to hide hints while focusing on logic
