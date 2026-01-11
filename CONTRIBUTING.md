# Contributing to Timesense.nvim

Thank you for considering contributing to Timesense.nvim! This document provides guidelines and instructions for contributing.

## 🎯 Project Goals

- Help competitive programmers catch complexity issues early
- Keep the plugin simple, fast, and deterministic
- No external dependencies (no AI, no LSP, no background processes)
- Contest-safe and fully offline

## 🚀 How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](https://github.com/samonide/timesense.nvim/issues)
2. If not, create a new issue with:
   - Clear description of the bug
   - Steps to reproduce
   - Expected vs actual behavior
   - Neovim version and OS
   - Sample code that triggers the bug

### Suggesting Features

1. Check existing [Issues](https://github.com/samonide/timesense.nvim/issues) and [Discussions](https://github.com/samonide/timesense.nvim/discussions)
2. Create a new issue describing:
   - The feature or enhancement
   - Use case and motivation
   - How it fits with project goals

### Code Contributions

#### Areas We'd Love Help With

- **Language Support**: Add analyzers for Python, Java, Rust, etc.
- **Complexity Patterns**: Improve detection of edge cases and patterns
- **Performance**: Optimize analysis for large files
- **Documentation**: Improve examples, add tutorials
- **Testing**: Add test cases and edge case coverage

#### Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/timesense.nvim.git`
3. Create a branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test thoroughly in Neovim
6. Commit with clear messages
7. Push and create a Pull Request

#### Code Style

- Follow Lua best practices
- Use clear variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Maintain separation between analysis and display logic

#### Testing Your Changes

1. Install the plugin locally:
```lua
{
  dir = '/path/to/your/local/timesense.nvim',
  config = function()
    require('timesense').setup()
  end
}
```

2. Test with various C++ files from `examples/`
3. Test edge cases (empty files, large files, nested loops, etc.)
4. Ensure no errors in `:messages`

### Pull Request Guidelines

- **Title**: Clear, descriptive summary of changes
- **Description**: 
  - What changed and why
  - Related issue number (if applicable)
  - Screenshots/examples for UI changes
- **Testing**: Describe how you tested the changes
- **Breaking Changes**: Note any breaking changes

## 📝 Code Structure

```
Timesense.nvim/
├── plugin/
│   └── timesense.lua         # Plugin entry point, command definitions
├── lua/
│   └── timesense/
│       ├── init.lua          # Main module, command handler
│       ├── config.lua        # Configuration management
│       ├── analyzer.lua      # Complexity analysis logic
│       └── display.lua       # Visual rendering (extmarks)
├── doc/
│   └── timesense.txt         # Vim help documentation
├── examples/
│   └── sample.cpp            # Example files for testing
└── README.md
```

### Module Responsibilities

- **analyzer.lua**: Parse code and calculate complexity (pure logic, no UI)
- **display.lua**: Render extmarks and virtual text (pure UI, no logic)
- **config.lua**: Manage settings and constraints
- **init.lua**: Orchestrate modules and handle commands

## 🧮 Adding Language Support

To add support for a new language:

1. Create `lua/timesense/analyzers/LANGUAGE.lua`
2. Implement `analyze(bufnr)` function that returns:
```lua
{
  loops = { {line, complexity, nesting_level}, ... },
  function_calls = { {line, complexity}, ... },
  space = "O(...)",
  space_items = { {line, complexity}, ... },
  overall_time = "O(...)",
}
```
3. Update `analyzer.lua` to dispatch to language-specific analyzer
4. Add tests and documentation

## 🎨 Design Principles

1. **Simplicity**: Prefer simple heuristics over perfect accuracy
2. **Speed**: Analysis should be instant (<100ms for typical files)
3. **Determinism**: Same code always produces same results
4. **Clarity**: Virtual text should be subtle but informative
5. **No Dependencies**: Keep the plugin self-contained

## 📋 Complexity Detection Guidelines

When adding new complexity patterns:

- Favor conservative estimates (prefer O(n) over O(1) when unsure)
- Focus on common CP patterns
- Document the pattern in `doc/timesense.txt`
- Add test cases

## ❓ Questions?

- Open a [Discussion](https://github.com/samonide/timesense.nvim/discussions)
- Check existing [Issues](https://github.com/samonide/timesense.nvim/issues)

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for helping make Timesense.nvim better! 🚀**
