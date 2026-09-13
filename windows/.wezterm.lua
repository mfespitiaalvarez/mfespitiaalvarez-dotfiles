-- Goes to C:\Users\<you>\.wezterm.lua on the Windows host.
--
-- The real config is the stowed one on the WSL side
-- (~/.config/wezterm/wezterm.lua -> this repo). Windows wezterm.exe can't see
-- that, so this shim reads it back out through wsl.exe and evaluates it. The
-- Windows profile then holds exactly one file that never needs editing again;
-- every real change happens in the repo.
--
-- Two things learned the hard way, don't "simplify" them away:
--
--   * Don't read via \\wsl.localhost\Ubuntu\... — Lua's dofile can't open those
--     reliably, because the 9P share is sometimes still cold when wezterm
--     starts.
--   * Use wezterm.run_child_process, NOT io.popen. io.popen goes through
--     cmd.exe, and a GUI app spawning a console child makes Windows allocate a
--     console for it — which Windows Terminal then hosts as a visible window on
--     every launch and every Ctrl+Shift+R reload. run_child_process spawns with
--     CREATE_NO_WINDOW.
--
-- `sh -c` (rather than cat'ing an absolute path) so ~ expands to whatever the
-- distro's default user is — no Linux username baked in here. If the distro
-- isn't named Ubuntu, change the -d argument; `wsl.exe -l -v` lists them.
local wezterm = require('wezterm')
local ok, stdout, stderr = wezterm.run_child_process({
  'wsl.exe', '-d', 'Ubuntu', '--',
  'sh', '-c', 'cat ~/.config/wezterm/wezterm.lua',
})
assert(ok, 'failed to read wezterm.lua from WSL: ' .. (stderr or '?'))
return assert(load(stdout, '@~/.config/wezterm/wezterm.lua (via wsl)'))()
