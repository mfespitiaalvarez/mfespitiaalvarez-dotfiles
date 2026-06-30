return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        -- Add "matlab_ls" here if MATLAB is installed on this machine.
        ensure_installed = { "pyright", "clangd", "marksman" },
      })

      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local opts = { buffer = event.buf }
          vim.keymap.set("n", "gd",         vim.lsp.buf.definition,  opts)
          vim.keymap.set("n", "K",          vim.lsp.buf.hover,       opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,      opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },
}
