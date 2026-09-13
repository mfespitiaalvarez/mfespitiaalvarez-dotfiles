# dotfiles

My Ghostty + tmux + Neovim configs, laid out for [GNU stow](https://www.gnu.org/software/stow/).

Everything is themed **Atom One Dark** — the terminal background, the tmux status
bar and the editor all sit on `#282c34` so there's no seam between them.

## Layout

Each top-level directory is a "stow package" that mirrors `$HOME`:

```
.
├── ghostty/
│   └── .config/ghostty/    -> ~/.config/ghostty/    (Linux)
├── tmux/
│   └── .tmux.conf          -> ~/.tmux.conf
├── nvim/
│   └── .config/nvim/       -> ~/.config/nvim/
└── wezterm/
    └── .config/wezterm/    -> ~/.config/wezterm/    (Windows only)
```

Ghostty is the Linux terminal; wezterm is the Windows one (its config has a WSL
block that drops straight into the Ubuntu distro). Only stow `wezterm` on Windows
hosts — on Linux, leave it alone.

Both carry the same Atom One Dark palette, hex-for-hex, so a session looks
identical whichever host it's on.

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

# 3. Symlink (-t is required unless the repo sits directly in $HOME)
stow -t ~ tmux nvim ghostty
```

`stow` defaults its target to the repo's **parent** directory, which is only `$HOME`
if you cloned straight into it. This repo lives at `~/dev/.mfespitiaalvarez_dotfiles`,
so `stow tmux` on its own would link into `~/dev/`. Always pass `-t ~`.

`stow -t ~ tmux` creates `~/.tmux.conf` as a symlink into the repo. Same for nvim and
ghostty — `~/.config/nvim/` and `~/.config/ghostty/` end up pointing here.

If a real file is already in the way, stow refuses and tells you which one. Move or delete it, then re-run.

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

To uninstall on a machine: `stow -D -t ~ tmux nvim ghostty` removes the symlinks (originals stay in the repo).

## Adding a new tool

1. Create `<tool>/` mirroring its location under `$HOME`.
2. Move the config in.
3. `stow -t ~ <tool>`.
