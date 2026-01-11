-- Timesense.nvim - Competitive Programming Complexity Visualizer
-- Plugin entry point

if vim.g.loaded_timesense == 1 then
  return
end
vim.g.loaded_timesense = 1

-- Define user commands
vim.api.nvim_create_user_command("Timesense", function(opts)
  require("timesense").command(opts.fargs)
end, {
  nargs = "+",
  complete = function()
    return { "complexity", "hide", "toggle", "constraints", "stats" }
  end,
  desc = "Timesense complexity visualizer commands",
})
