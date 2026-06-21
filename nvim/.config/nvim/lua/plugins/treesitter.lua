return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",          -- stable branch (the `main` rewrite is async-only/experimental)
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "go", "cpp", "bash" },
      auto_install = true,     -- grab a parser automatically when opening a new filetype
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
