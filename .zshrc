# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

KEYTIMEOUT=1
source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

. "$HOME/.local/bin/env"
alias rfswift='/Users/garrenmiller/.rfswift/bin/rfswift'

# Added by LM Studio CLI tool (lms)
export PATH="$PATH:/Users/garrenmiller/.lmstudio/bin"

# opencode
export PATH=/Users/garrenmiller/.opencode/bin:$PATH

# Android stuff
export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/emulator

# Dotfiles: manage everything in ~/.dotfiles (bare repo) via the `config` alias
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
