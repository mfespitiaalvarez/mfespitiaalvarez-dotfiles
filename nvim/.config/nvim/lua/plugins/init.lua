return {
  "christoomey/vim-tmux-navigator",
  {
    "navarasu/onedark.nvim",
    name = "onedark",
    priority = 1000,
    config = function()
      require("onedark").setup({
        -- "dark" is the Atom One Dark palette proper: #282c34 background,
        -- #abb2bf foreground. Ghostty's background is pinned to the same hex
        -- so the editor and the terminal share one surface with no seam.
        style = "dark",
        -- Leave the background opaque; the terminal owns the color.
        transparent = false,
        term_colors = true,
        code_style = {
          comments = "italic",
          keywords = "none",
          functions = "none",
          strings = "none",
          variables = "none",
        },
      })
      require("onedark").load()
    end,
  },
}
