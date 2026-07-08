-- Bluespec SystemVerilog syntax highlighting. No LSP exists for BSV or
-- Minispec; diagnostics come from running the compiler (`make test`).
return {
  {
    "mtikekar/vim-bsv",
    ft = "bsv",
    init = function()
      -- Minispec (MIT 6.191) is a Bluespec subset, so BSV highlighting is
      -- close enough. Without this, .ms is detected as nroff.
      vim.filetype.add({ extension = { ms = "bsv" } })
    end,
  },
}
