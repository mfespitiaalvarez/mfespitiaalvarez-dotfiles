return {
  {
    "saghen/blink.cmp",
    -- A release tag makes lazy download a prebuilt Rust fuzzy-matcher binary,
    -- so you don't need cargo. (Fallback: build = "cargo build --release".)
    version = "*",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      -- "enter" preset keeps your old habits: <CR> accepts, <C-Space> toggles,
      -- <C-n>/<C-p> select, <C-e> hides. Leaves <Tab> free for AI ghost text.
      keymap = { preset = "enter" },
      appearance = { nerd_font_variant = "mono" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        -- blink's own inline preview; keep off so it won't clash with
        -- Supermaven/Codeium AI ghost text if we add that later.
        ghost_text = { enabled = false },
      },
      -- Prefer the fast Rust matcher, warn (don't error) if it isn't available.
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
