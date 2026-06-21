-- Leader (must be set before plugins load)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"      -- reserve the gutter so diagnostics don't shift text
opt.scrolloff = 8           -- keep 8 lines visible above/below the cursor
opt.sidescrolloff = 8
opt.termguicolors = true
opt.mouse = ""              -- no mouse anywhere; force keyboard-only motions

-- Indentation: Google C++ default (2 sp). Python (4 sp) and Go (tabs)
-- are handled per-project via .editorconfig in a later module.
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

-- Search
opt.ignorecase = true
opt.smartcase = true        -- case-sensitive only when the query has a capital

-- Snappier LSP / cursor-hold events (default 4000 ms feels laggy)
opt.updatetime = 250

-- Persistent undo across sessions (writes to ~/.local/state/nvim/undo/)
opt.undofile = true

-- Keymaps -----------------------------------------------------------------

-- File explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "project: file explorer" })

-- Diagnostic navigation (works without an LSP attached too)
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "next diagnostic" })
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "prev diagnostic" })

-- Quickfix navigation (pairs with :grep, :cdo, Telescope send-to-quickfix)
vim.keymap.set("n", "]q", "<cmd>cnext<cr>", { desc = "next quickfix" })
vim.keymap.set("n", "[q", "<cmd>cprev<cr>", { desc = "prev quickfix" })

-- Centered half-page jumps (cursor stays in the middle, easier on the eyes)
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "half-page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "half-page up (centered)" })

-- Autocmds ----------------------------------------------------------------

-- Hybrid line numbers: relative on the active window in Normal mode,
-- absolute everywhere else (other splits, Insert mode, terminal unfocused).
-- The `vim.wo.number` guard means we leave windows alone where line
-- numbers were intentionally disabled (Telescope previews, :terminal, etc.).
local numgrp = vim.api.nvim_create_augroup("HybridLineNumbers", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
  group = numgrp,
  callback = function() if vim.wo.number then vim.wo.relativenumber = true end end,
})
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = numgrp,
  callback = function() if vim.wo.number then vim.wo.relativenumber = false end end,
})
