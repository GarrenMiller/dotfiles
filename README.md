# dotfiles

My dotfiles, managed as a [bare git repository](https://www.atlassian.com/git/tutorials/dotfiles)
backed by GitHub. Files are checked out directly into `$HOME`, and everything is
driven through a `config` alias that just wraps git:

```sh
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```

## Setting up a new machine

```sh
# 1. Clone the bare repo
git clone --bare git@github.com:GarrenMiller/dotfiles.git "$HOME/.dotfiles"

# 2. Check out files into $HOME
#    This brings in .zshrc, which defines the `config` alias, along with your
#    .gitconfig, .p10k.zsh, and ~/.config/ files.
git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" checkout main

# 3. Install plugins and tools (nvim plugins, powerlevel10k)
"$HOME/.config/scripts/setup.sh"
```

Then restart your shell (or run `source ~/.zshrc`) and `config` will work.

> If step 2 fails because a file already exists (e.g. you already had a
> `~/.zshrc`), just run the setup script — it moves conflicting files to
> `~/.dotfiles-backup/` and retries the checkout.

## Managing dotfiles

`config` is just git, so anything you'd do with git works:

```sh
config status                 # see what changed
config add .zshrc             # track a change
config commit -m "update zshrc"
config push
```

## What the setup script does

- Clones the bare repo if `~/.dotfiles` is missing
- Sets `status.showUntrackedFiles no` (hides untracked files from `config status`)
- Checks out `main` into `$HOME`, backing up conflicting files to `~/.dotfiles-backup/`
- Installs nvim plugins via vim-plug
- Clones [powerlevel10k](https://github.com/romkatv/powerlevel10k) if missing

It's idempotent — safe to re-run anytime.
