# dotfiles

My terminal + tmux + Neovim configs (Ghostty on Linux, WezTerm on Windows/WSL), laid out for [GNU stow](https://www.gnu.org/software/stow/).

Everything is themed **Atom One Dark** — the terminal background, the tmux status
bar and the editor all sit on `#282c34` so there's no seam between them.

## Layout

Each top-level directory is a "stow package" that mirrors `$HOME` — except
`windows/`, which isn't stowed at all (see below):

```
.
├── ghostty/
│   └── .config/ghostty/    -> ~/.config/ghostty/    (native Linux)
├── tmux/
│   └── .tmux.conf          -> ~/.tmux.conf
├── nvim/
│   └── .config/nvim/       -> ~/.config/nvim/
├── wezterm/
│   └── .config/wezterm/    -> ~/.config/wezterm/    (WSL)
└── windows/                   copied by hand to the Windows host — NOT stowed
    ├── .wezterm.lua           -> C:\Users\<you>\.wezterm.lua
    ├── .wslconfig             -> C:\Users\<you>\.wslconfig
    ├── wsl.conf               -> /etc/wsl.conf  (inside the distro)
    └── wsl-host-setup.sh      does all of the above + the ~/win symlink
```

Ghostty is the terminal on native Linux; wezterm is the terminal on a Windows
laptop running WSL. Both carry the same Atom One Dark palette, hex-for-hex, so
a session looks identical whichever host it's on.

Note where the wezterm package gets stowed: **inside WSL**, not on Windows.
`wezterm.exe` is a Windows program and can't read a stowed Linux config, so the
Windows profile gets a small bootstrap (`windows/.wezterm.lua`) that reads the
real config back out of WSL. Full story in
[Windows + WSL host setup](#windows--wsl-host-setup). On a native Linux box,
ignore `wezterm/` and `windows/` entirely.

## Required packages (Debian / Ubuntu / gLinux)

```bash
sudo apt update && sudo apt install -y \
  git stow \
  tmux neovim \
  xclip \
  curl unzip \
  build-essential \
  nodejs npm \
  ripgrep fd-find
```

Why each:

| Package           | Used for                                                                   |
| ----------------- | -------------------------------------------------------------------------- |
| `git`             | clone / pull this repo                                                     |
| `stow`            | symlink the dotfiles into `$HOME`                                          |
| `tmux`            | the multiplexer itself                                                     |
| `neovim` (≥0.10)  | the editor                                                                 |
| `xclip`           | tmux `Y` binding → system clipboard on native Linux (e.g. CloudTop)        |
| `curl`, `unzip`   | Mason downloads LSP servers as zip/tarball                                 |
| `build-essential` | `gcc` + `make` for nvim-treesitter parser compilation                      |
| `nodejs`, `npm`   | Mason installs `pyright` and `marksman` via npm                            |
| `ripgrep`         | telescope `<leader>pg` (`live_grep`) requires it                           |
| `fd-find`         | telescope `<leader>pf` (`find_files`) — faster, respects `.gitignore`      |

> On Debian/Ubuntu `fd` installs as `fdfind`. Optional: `mkdir -p ~/.local/bin && ln -s $(which fdfind) ~/.local/bin/fd` so it's available as `fd`.

If `apt`'s `neovim` is older than 0.10, grab the AppImage or PPA — Mason and treesitter need it.

### Plus: tree-sitter CLI (not an apt package)

`nvim-treesitter` is pinned to its `main` branch, which requires the external `tree-sitter` binary at build time. Install via npm:

```bash
sudo npm install -g tree-sitter-cli
```

No-sudo alternative (user-prefix npm):

```bash
mkdir -p ~/.npm-global && npm config set prefix ~/.npm-global
echo 'export PATH=$HOME/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
npm install -g tree-sitter-cli
```

Verify with `tree-sitter --version` from a fresh shell, then run `:TSUpdate` in nvim.

**If npm install gives `GLIBC_2.XX not found`** (common on older Debian / enterprise Linux like gLinux), the npm prebuilt binary is too new for the system glibc. Build from source via cargo instead:

```bash
# install rust toolchain if needed
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env

npm uninstall -g tree-sitter-cli   # remove the broken npm one
cargo install tree-sitter-cli       # builds against local glibc; takes a few min
tree-sitter --version
```

## Install on a new machine

```bash
# 1. Install prereqs (see above)

# 2. Clone (pick any path; example uses $HOME)
git clone <repo-url> ~/dotfiles
cd ~/dotfiles

# 3. Symlink. Pick the terminal package for this host:
#      native Linux -> ghostty      WSL -> wezterm
stow -t ~ tmux nvim ghostty

# 4. tmux plugin manager (.tmux.conf sources it; without it the status bar
#    comes up unstyled and every @plugin line is inert)
git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then start tmux and press `prefix + I` (capital i) to install the plugins.

`stow` defaults its target to the repo's **parent** directory, which is `$HOME` only
if you cloned straight into it. This repo currently sits at `~/mfespitiaalvarez_dotfiles`,
where the default happens to be right — but clone it one level deeper and `stow tmux`
would quietly link into the wrong directory. Always pass `-t ~`.

`stow -t ~ tmux` creates `~/.tmux.conf` as a symlink into the repo. Same for nvim and
the terminal package — `~/.config/nvim/` and `~/.config/{ghostty,wezterm}/` end up
pointing here.

If a real file is already in the way, stow refuses and tells you which one. Move or delete it, then re-run.

## Windows + WSL host setup

On a Windows laptop the shell, tmux, nvim and the dotfiles all live inside WSL,
but the terminal is a Windows program. That split is the only awkward part, and
it's what everything in `windows/` exists to bridge.

`wezterm.exe` starts before WSL is necessarily running and reads its config from
the **Windows** profile, so it can't use the stowed Linux one. Rather than keep
two copies in sync, the Windows profile holds a 15-line bootstrap
(`windows/.wezterm.lua`) that shells out to `wsl.exe` and evaluates the real
config from the repo. The Windows side then never needs touching again — every
change happens in `wezterm/.config/wezterm/wezterm.lua` and takes effect on the
next `Ctrl+Shift+R`.

The config itself sets `default_domain = 'WSL:Ubuntu'`, so opening wezterm drops
straight into the Linux home with tmux and nvim on the same `#282c34` surface.

### Rebuilding from scratch

After a factory reset, in this order:

```powershell
# In Windows PowerShell (admin), reboot when it asks:
wsl --install -d Ubuntu
```

Install [WezTerm](https://wezterm.org/install/windows.html) and
[Docker Desktop](https://docs.docker.com/desktop/install/windows-install/) on
Windows, then install **JetBrainsMono Nerd Font on Windows too** — download
`JetBrainsMono.zip` from the
[nerd-fonts releases](https://github.com/ryanoasis/nerd-fonts/releases), select
all, right-click → Install. wezterm.exe is a Windows app and only sees Windows
fonts; installing the font inside WSL does nothing for it. The config asks for
the `Mono` variant first, so the tmux status-bar glyphs stay single-cell.

Then inside the Ubuntu distro:

```bash
# prereqs from the package list above, plus:
sudo apt install -y git stow

git clone <repo-url> ~/mfespitiaalvarez_dotfiles
cd ~/mfespitiaalvarez_dotfiles

# WSL <-> Windows glue: ~/win, the Windows-side config files, shared cloud
# credentials, tpm. Idempotent, safe to re-run after editing windows/.
./windows/wsl-host-setup.sh

# the configs themselves
stow -t ~ tmux nvim wezterm

# the one step the script can't do for you (needs sudo)
sudo cp windows/wsl.conf /etc/wsl.conf
```

Finally, from Windows: `wsl --shutdown` to apply `wsl.conf`/`.wslconfig`, then
enable **Docker Desktop → Settings → Resources → WSL integration** for the
distro. Docker Desktop creates `~/.docker/contexts` and `~/.docker/features.json`
as links into the Windows profile itself once that toggle is on — don't make
those by hand.

### What the glue actually does

| Piece | Why |
| --- | --- |
| `~/win -> /mnt/c/Users/<you>` | Short path to the Windows profile — `~/win/Downloads` instead of `/mnt/c/Users/<you>/Downloads`, and tab-completion from the Linux side. |
| `~/.aws`, `~/.azure -> ~/win/.aws`, `~/win/.azure` | One login serves both sides; `az login` in Windows and the CLIs in WSL share a token cache. Only linked once the Windows-side directories exist. |
| `/etc/wsl.conf` → `automount options = "metadata"` | Without it every file under `/mnt/c` reads as 0777 root-owned, `chmod` silently does nothing, and symlinks made there don't stick. |
| `/etc/wsl.conf` → `systemd=true` | Services behave like a normal Ubuntu box instead of needing manual starts. |
| `.wslconfig` → `networkingMode=mirrored` | `localhost` works in both directions — a server bound in WSL is reachable from a Windows browser and vice versa. Windows 11 22H2+. |

### Gotchas worth not rediscovering

Both are already handled in `windows/.wezterm.lua`; the comments there say so
too, so don't "simplify" them away:

- **Reading the config over `\\wsl.localhost\...` doesn't work.** Lua's `dofile`
  can't open those paths reliably, because the 9P share is sometimes still cold
  when wezterm starts. Shell out through `wsl.exe` instead.
- **`io.popen` makes a console window flash on every launch.** It goes through
  `cmd.exe`, and a GUI app spawning a console child makes Windows allocate a
  console, which Windows Terminal then hosts as a visible window — on startup
  and on every `Ctrl+Shift+R`. `wezterm.run_child_process` spawns with
  `CREATE_NO_WINDOW` and stays quiet.

If wezterm opens to an error instead of a shell, run the bootstrap's command by
hand from PowerShell to see what broke:

```powershell
wsl.exe -d Ubuntu -- sh -c 'cat ~/.config/wezterm/wezterm.lua'
```

Empty output means the stow step didn't run or the distro's default user isn't
the one holding the dotfiles (`[user] default=` in `/etc/wsl.conf`). A different
distro name means editing the `-d Ubuntu` argument; `wsl.exe -l -v` lists them.

## Switching over a machine that already has configs

```bash
mv ~/.tmux.conf ~/.tmux.conf.bak
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.config/ghostty ~/.config/ghostty.bak
cd <this-repo>
stow -t ~ tmux nvim ghostty
```

Verify with `ls -l ~/.tmux.conf` — should show `-> .../tmux/.tmux.conf`.

First nvim launch will bootstrap lazy.nvim and install plugins; first `:Mason` use will install the configured LSP servers (`pyright`, `clangd`, `marksman`).

## Day-to-day

Edits to files in this repo are live — the symlink means tmux/nvim see changes instantly. `git diff` reflects reality.

```bash
# pull updates from another machine
git pull

# push your changes
git add -u && git commit -m "..." && git push
```

To uninstall on a machine: `stow -D -t ~ tmux nvim ghostty wezterm` removes the symlinks (originals stay in the repo).

## Adding a new tool

1. Create `<tool>/` mirroring its location under `$HOME`.
2. Move the config in.
3. `stow -t ~ <tool>`.
