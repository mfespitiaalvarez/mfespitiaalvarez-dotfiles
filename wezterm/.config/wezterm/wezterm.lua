local wezterm = require('wezterm')
local config = wezterm.config_builder()

-- ==========================
-- Appearance
-- ==========================
-- Mirrors the built-in "Ubuntu" scheme from Windows Terminal — aubergine
-- background with the Tango ANSI palette.
config.colors = {
  foreground = '#EEEEEC',
  background = '#300A24',
  cursor_bg = '#BBBBBB',
  cursor_fg = '#300A24',
  cursor_border = '#BBBBBB',
  selection_bg = '#B5D5FF',
  selection_fg = '#300A24',
  ansi = {
    '#2E3436', -- black
    '#CC0000', -- red
    '#4E9A06', -- green
    '#C4A000', -- yellow
    '#3465A4', -- blue
    '#75507B', -- magenta
    '#06989A', -- cyan
    '#D3D7CF', -- white
  },
  brights = {
    '#555753',
    '#EF2929',
    '#8AE234',
    '#FCE94F',
    '#729FCF',
    '#AD7FA8',
    '#34E2E2',
    '#EEEEEC',
  },
}
config.font = wezterm.font_with_fallback({
  'JetBrains Mono',
  'Cascadia Code',
  'Menlo',
})
config.font_size = 12.0
config.line_height = 1.0

config.window_padding = {
  left = 6,
  right = 6,
  top = 4,
  bottom = 0,
}

config.window_decorations = 'RESIZE'
config.scrollback_lines = 10000
config.audible_bell = 'Disabled'

-- Don't translate wheel events to arrow keys on the alt screen. tmux + nvim both
-- run on the alt screen with mouse reporting disabled; wezterm's default would
-- otherwise send Up/Down on scroll, producing fake "mouse scroll" inside nvim.
config.alternate_buffer_wheel_scroll_speed = 0

-- ==========================
-- Tab bar
-- ==========================
-- tmux already manages the multiplexing layer, so keep wezterm's chrome quiet.
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.tab_max_width = 32

-- ==========================
-- WSL integration
-- ==========================
-- On Windows hosts, default to the Ubuntu WSL distro so wezterm drops straight
-- into the Linux home where tmux/nvim live. No-op on Linux/macOS.
if wezterm.target_triple:find('windows') then
  config.wsl_domains = wezterm.default_wsl_domains()
  config.default_domain = 'WSL:Ubuntu'
end

-- ==========================
-- Keybindings
-- ==========================
-- Leave C-a, C-{hjkl}, M-{hjkl} alone — tmux + vim-tmux-navigator own those.
config.disable_default_key_bindings = false
config.keys = {
  -- Reload config without restarting
  { key = 'r', mods = 'CTRL|SHIFT', action = wezterm.action.ReloadConfiguration },
  -- Paste — Ctrl+Shift+V is the X11/Linux convention; keep it explicit on all platforms
  { key = 'v', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom('Clipboard') },
  { key = 'c', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo('Clipboard') },
}

return config
