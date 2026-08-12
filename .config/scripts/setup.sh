#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"
REPO_URL="git@github.com:GarrenMiller/dotfiles.git"
BRANCH="main"

say()  { printf "\033[1;36m==> %s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m==> %s\033[0m\n" "$*"; }

# `config` = git, but rooted at $HOME. Works before the bare repo exists
# (the bare repo is created below before this is ever used).
config() { git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"; }

# 1. Clone the bare repo if it doesn't exist yet
if [[ ! -d "$DOTFILES_DIR" ]]; then
  say "Cloning dotfiles into $DOTFILES_DIR"
  git clone --bare "$REPO_URL" "$DOTFILES_DIR"
else
  say "Bare repo already exists at $DOTFILES_DIR"
fi

# 2. Persist the `config` alias in shell rc files (idempotent)
ALIAS_LINE="alias config='/usr/bin/git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME'"
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  if [[ -f "$rc" ]] && ! grep -qF "alias config=" "$rc"; then
    say "Adding config alias to $rc"
    printf '\n# Dotfiles: manage everything in ~/.dotfiles (bare repo) via the `config` alias\n%s\n' "$ALIAS_LINE" >> "$rc"
  fi
done

# 3. Hide untracked files (stored in the bare repo's config, not ~/.gitconfig)
config config --local status.showUntrackedFiles no

# 4. Check out files into $HOME, backing up anything that conflicts
backup_dir="$HOME/.dotfiles-backup"
if config checkout "$BRANCH" 2>/dev/null; then
  say "Checked out dotfiles onto $BRANCH"
else
  warn "Conflicts detected; moving them to $backup_dir"
  config checkout "$BRANCH" 2>&1 \
    | grep -E '^\s+\.' \
    | awk '{print $1}' \
    | while read -r f; do
        mkdir -p "$(dirname "$backup_dir/$f")"
        mv "$HOME/$f" "$backup_dir/$f"
      done
  config checkout "$BRANCH"
fi

# 5. nvim plugins (vim-plug)
if command -v nvim >/dev/null 2>&1; then
  say "Installing nvim plugins (vim-plug)"
  nvim --headless "+PlugInstall --sync" +qall >/dev/null 2>&1 || true
fi

# 6. powerlevel10k (sourced by ~/.zshrc)
if [[ ! -d "$HOME/powerlevel10k" ]]; then
  say "Cloning powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k"
fi

say "Done! Restart your shell or run: source ~/.zshrc"
