local wezterm = require('wezterm')
local config = wezterm.config_builder()

-- ==========================
-- Appearance
-- ==========================
-- Atom One Dark, hex-for-hex identical to the ghostty config on Linux and to
-- onedark.nvim's "dark" style, so the terminal, the tmux status bar and the
-- editor all sit on the same #282c34 surface with no seam between them.
config.colors = {
  foreground = '#abb2bf',
  background = '#282c34',
  cursor_bg = '#abb2bf',
  cursor_fg = '#282c34',
  cursor_border = '#abb2bf',
  selection_bg = '#3e4451',
  selection_fg = '#abb2bf',
  ansi = {
    '#21252b', -- black
    '#e06c75', -- red
    '#98c379', -- green
    '#e5c07b', -- yellow
    '#61afef', -- blue
    '#c678dd', -- magenta
    '#56b6c2', -- cyan
    '#abb2bf', -- white
  },
  -- One Dark has no separate bright ramp: only black lifts to a visible grey,
  -- the rest repeat the normal colors. This matches ghostty's shipped theme.
  brights = {
    '#767676',
    '#e06c75',
    '#98c379',
    '#e5c07b',
    '#61afef',
    '#c678dd',
    '#56b6c2',
    '#abb2bf',
  },
}
-- Prefer the Nerd Font "Mono" variant so the tmux/catppuccin status bar glyphs
-- render at single-cell width, same as ghostty. Falls back to plain JetBrains
-- Mono if the Nerd Font isn't installed on the Windows host.
config.font = wezterm.font_with_fallback({
  'JetBrainsMono Nerd Font Mono',
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
