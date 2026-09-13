#!/usr/bin/env bash
# Wires a fresh WSL distro to its Windows host: the ~/win shortcut, the
# Windows-side wezterm bootstrap, shared cloud credentials, and tmux's plugin
# manager. Everything here is idempotent — safe to re-run.
#
#   ./windows/wsl-host-setup.sh
#
# Only covers the parts that are WSL<->Windows glue. The dotfiles themselves
# are stow's job (see the README); the steps needing sudo or the Windows GUI
# are printed at the end rather than done for you.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ---------------------------------------------------------------------------
# Locate the Windows home
# ---------------------------------------------------------------------------
# cmd.exe via WSL interop is the only reliable way to get the Windows username
# (%USERPROFILE% isn't exported into the Linux environment). It prints CRLF, so
# strip the CR. Run it from /mnt/c: cmd.exe refuses a WSL cwd with a warning.
win_user="$(cd /mnt/c && cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r\n')"
win_home="/mnt/c/Users/${win_user}"

if [[ -z "${win_user}" || ! -d "${win_home}" ]]; then
  echo "error: couldn't resolve the Windows home (got '${win_home}')." >&2
  echo "       Is interop enabled, and is the profile under C:\\Users?" >&2
  exit 1
fi
echo "Windows home: ${win_home}"

# link <target> <linkname> — points linkname at target, backing up anything
# real that's already sitting there.
link() {
  local target="$1" name="$2"
  if [[ -e "${name}" && ! -L "${name}" ]]; then
    mv "${name}" "${name}.bak"
    echo "  moved existing ${name} -> ${name}.bak"
  fi
  ln -sfn "${target}" "${name}"
  echo "  ${name} -> ${target}"
}

# ---------------------------------------------------------------------------
# ~/win — short path to the Windows profile
# ---------------------------------------------------------------------------
# Saves typing /mnt/c/Users/<you> constantly, and gives tab-completion a root
# for Downloads, Desktop, etc. Needs `metadata` in /etc/wsl.conf's automount
# options or permissions on the other side read as 0777 root-owned.
echo "Linking Windows home:"
link "${win_home}" "${HOME}/win"

# ---------------------------------------------------------------------------
# Windows-side config files
# ---------------------------------------------------------------------------
# Copied, not symlinked: Windows apps read these before WSL is necessarily up,
# and a Linux symlink under /mnt/c isn't something wezterm.exe will follow.
# Re-run this script after editing anything in windows/.
echo "Copying Windows-side configs:"
for f in .wezterm.lua .wslconfig; do
  cp "${repo_root}/windows/${f}" "${win_home}/${f}"
  echo "  ${win_home}/${f}"
done

# ---------------------------------------------------------------------------
# Shared cloud credentials
# ---------------------------------------------------------------------------
# One login serves both sides: `az login` in Windows and the AWS CLI in WSL
# read the same token cache. Only linked if the Windows side actually exists —
# a fresh box won't have them until you've logged in over there once.
echo "Linking shared credentials:"
for d in .aws .azure; do
  if [[ -d "${win_home}/${d}" ]]; then
    link "${win_home}/${d}" "${HOME}/${d}"
  else
    echo "  skipped ${d} (no ${win_home}/${d} yet)"
  fi
done

# Docker Desktop writes ~/.docker/contexts and ~/.docker/features.json as links
# into the Windows profile itself once WSL integration is switched on for this
# distro — don't create those by hand, just enable the toggle.

# ---------------------------------------------------------------------------
# tmux plugin manager
# ---------------------------------------------------------------------------
# .tmux.conf ends with `run '~/.tmux/plugins/tpm/tpm'`; without this clone the
# status bar comes up unstyled and every @plugin line is inert.
tpm_dir="${HOME}/.tmux/plugins/tpm"
if [[ -d "${tpm_dir}" ]]; then
  echo "tpm: already installed"
else
  echo "tpm: cloning"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "${tpm_dir}"
fi

# ---------------------------------------------------------------------------
cat <<NOTE

Done. Remaining steps that need sudo or the Windows side:

  1. /etc/wsl.conf — systemd, default user, and the metadata automount that
     makes /mnt/c permissions work:
       sudo cp ${repo_root}/windows/wsl.conf /etc/wsl.conf
       # edit the [user] default= line if your username isn't 'mfea'

  2. From a Windows terminal, restart WSL so wsl.conf/.wslconfig take effect:
       wsl --shutdown

  3. Install JetBrainsMono Nerd Font on WINDOWS (not in WSL) — wezterm.exe is
     a Windows app and only sees Windows fonts. Grab JetBrainsMono.zip from
     github.com/ryanoasis/nerd-fonts/releases, select all, right-click >
     Install. The config asks for the "Mono" variant first.

  4. Docker Desktop > Settings > Resources > WSL integration > enable for this
     distro, so \`docker\` works from inside WSL.

  5. Install the dotfiles themselves:
       stow -t ~ tmux nvim wezterm
     then open tmux and press prefix + I to fetch the plugins.
NOTE
