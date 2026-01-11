# Timesense.nvim

Complexity analyzer and coding stats tracker for competitive programming.

## Features

- Inline complexity hints (`🧠 O(n)`, `🧠 O(n²)`)
- Coding time and language statistics dashboard
- STL function detection (sort, binary_search, etc.)
- Zero dependencies, fully offline

## Installation

```lua
-- lazy.nvim
{
  'samonide/timesense.nvim',
  config = function()
    require('timesense').setup()
  end,
  cmd = 'Timesense',
  ft = { 'cpp', 'c' },
}
```

## Quick Start

```vim
:Timesense complexity   " Analyze code complexity
:Timesense stats        " View coding statistics
:Timesense toggle       " Show/hide hints
```

See [USAGE.md](USAGE.md) for detailed documentation.

## Requirements

- Neovim 0.8+
- Currently supports C/C++ (Python/Java planned)

## License

MIT

**A Neovim plugin for competitive programmers** that visualizes time and space complexity estimates using simple rule-based static analysis.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Neovim](https://img.shields.io/badge/Neovim-0.8+-green.svg)

## 🎯 Purpose

Timesense helps competitive programmers **catch complexity issues early** by displaying inline complexity hints directly in your code. No AI, no LSP, no background analysis—just fast, deterministic heuristics that run on command.

## ✨ Features

- **Visual Complexity Hints**: See `🧠 O(n)`, `🧠 O(n²)`, etc. beside loops and function calls
- **Overall Summary**: Time and space complexity displayed at the top of your file
- **Manual Trigger**: Analysis only runs when you explicitly command it
- **Contest-Safe**: No external dependencies, works fully offline
- **C++ Support**: Detects loops, nested loops, STL functions, and more
- **Configurable**: Customize icons, highlighting, and visibility

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'samonide/timesense.nvim',
  config = function()
    require('timesense').setup({
      -- Optional: customize settings
      virtual_text_icon = '🧠',
      virtual_text_hl_group = 'Comment',
    })
  end,
  cmd = 'Timesense', -- Lazy load on command
  ft = { 'cpp', 'c' }, -- Or lazy load on filetype
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'samonide/timesense.nvim',
  config = function()
    require('timesense').setup()
  end
}
```

## 🚀 Usage

### Commands

| Command | Description |
|---------|-------------|
| `:Timesense complexity` | Analyze and display complexity hints |
| `:Timesense hide` | Remove all complexity hints |
| `:Timesense toggle` | Toggle hint visibility |
| `:Timesense constraints <n> [time_ms] [memory_mb]` | Set problem constraints |

### Example Workflow

```vim
" Open your competitive programming solution
vim solution.cpp

" Run complexity analysis
:Timesense complexity

" Set problem constraints (n=10^5, 2000ms time limit, 256MB memory)
:Timesense constraints 100000 2000 256

" Hide hints temporarily
:Timesense hide

" Show them again
:Timesense toggle
```

## 📝 Example

Given this C++ code:

```cpp
#include <bits/stdc++.h>
using namespace std;

void solve() {
    int n;
    cin >> n;
    vector<int> arr(n);              // 🧠 Time: O(n) | Space: O(n)
    
    for (int i = 0; i < n; i++) {    // 🧠 O(n)
        cin >> arr[i];
    }
    
    sort(arr.begin(), arr.end());    // 🧠 O(n log n)
    
    for (int i = 0; i < n; i++) {    // 🧠 O(n²)
        for (int j = i + 1; j < n; j++) {
            cout << arr[i] + arr[j] << " ";
        }
    }
}
```

Timesense will display:
- Overall complexity at the top: `🧠 Time: O(n²) | Space: O(n)`
- Individual hints beside each loop and significant operation

## ⚙️ Configuration

Full configuration options:

```lua
require('timesense').setup({
  -- Icon shown in virtual text
  virtual_text_icon = '🧠',
  
  -- Highlight group for virtual text
  virtual_text_hl_group = 'Comment',
  
  -- Enable by default
  enabled = true,
  
  -- Default problem constraints
  constraints = {
    n = nil,
    time_limit_ms = nil,
    memory_limit_mb = nil,
  },
  
  -- Thresholds for warnings
  thresholds = {
    time_warning = 1e8,  -- Operations per second
    space_warning = 256, -- MB
  },
})
```

## 🧮 Complexity Detection

### Time Complexity Patterns

| Pattern | Detected Complexity |
|---------|-------------------|
| `for (i = 0; i < n; i++)` | O(n) |
| `for (i = 0; i < n; i *= 2)` | O(log n) |
| `for (i = 0; i * i < n; i++)` | O(√n) |
| Nested loops | Multiplied (e.g., O(n) × O(n) = O(n²)) |
| `sort()` | O(n log n) |
| `binary_search()`, `lower_bound()` | O(log n) |

### Space Complexity Patterns

| Pattern | Detected Complexity |
|---------|-------------------|
| `vector<int> v(n)` | O(n) |
| `int arr[n]` | O(n) |
| `vector<vector<int>> v` | O(n²) |
| Constant size arrays | O(1) |

## 🎯 Design Philosophy

- **No AI**: Pure rule-based analysis for predictable, fast results
- **No LSP**: Works without language servers or compilation
- **No Background Analysis**: Only runs when you trigger it
- **Contest-Safe**: Fully offline, no external dependencies
- **Heuristic**: Approximate complexity is good enough for CP

## 🛠️ Supported Languages

- ✅ C++ (primary support)
- ✅ C (basic support)
- 🔜 Python (planned)
- 🔜 Java (planned)

## 📋 Requirements

- Neovim 0.8+
- No external dependencies

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Add support for more languages
- Improve complexity detection patterns

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

Built for competitive programmers who want to quickly validate their solution complexity without leaving their editor.

---

**Happy Coding! 🚀**
