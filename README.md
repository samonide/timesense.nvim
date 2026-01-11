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

## Disclaimer

This project used AI assistance (GitHub Copilot) for code comments, documentation, and development guidance.

## License

MIT
