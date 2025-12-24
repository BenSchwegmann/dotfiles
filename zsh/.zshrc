# -------------------------
#  Environment / PATH
# -------------------------
# Homebrew environment (muss früh geladen werden, da HOMEBREW_PREFIX verwendet wird)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Herd injected PHP binary
export PATH="$HOME/Library/Application Support/Herd/bin/:$PATH"

# Herd injected PHP configuration dirs
export HERD_PHP_84_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/84/"
export HERD_PHP_85_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/85/"

# Herd injected NVM configuration
export NVM_DIR="$HOME/Library/Application Support/Herd/config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Source Herd's provided shell config if present
[[ -f "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh" ]] && builtin source "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh"


# -------------------------
#  Plugin manager (zinit)
# -------------------------
# zinit core
source $HOMEBREW_PREFIX/opt/zinit/zinit.zsh

# zinit plugins (light-load)
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# zinit snippets (OMZP = oh-my-zsh-plugins collection)
zinit snippet OMZP::git
zinit snippet OMZP::docker
zinit snippet OMZP::gitignore
zinit snippet OMZP::starship

# zinit helper / replay
autoload -Uz compinit && compinit
zinit cdreplay -q


# -------------------------
#  Completion system
# -------------------------

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'


# -------------------------
#  History
# -------------------------
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups


# -------------------------
#  Aliases & small helpers
# -------------------------
alias ls='ls --color'
alias c='clear'
alias y='yazi'

# fzf integration
source <(fzf --zsh)

# zoxide
eval "$(zoxide init zsh)"


# -------------------------
#  Prompt / Prompt tools
# -------------------------
# Starship (note: also referenced via zinit snippet OMZP::starship)

export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"

# cached values
typeset -g _STARSHIP_LAST_SRC=""
typeset -g _STARSHIP_LAST_CHECK=0

_starship_sync_appearance() {
  local now=$(date +%s)
  local throttle=1
  if (( now - _STARSHIP_LAST_CHECK < throttle )); then
    return
  fi
  _STARSHIP_LAST_CHECK=$now

  local src dest mode
  dest="$HOME/.config/starship.toml"

  if defaults read -g AppleInterfaceStyle >/dev/null 2>&1; then
    mode="dark"
    src="$HOME/.config/starship.dark.toml"
  else
    mode="light"
    src="$HOME/.config/starship.light.toml"
  fi

  if [[ -z "$_STARSHIP_LAST_SRC" || "$src" != "$_STARSHIP_LAST_SRC" ]]; then
    if [[ -f "$src" ]]; then
      ln -sf -- "$src" "$dest"
      _STARSHIP_LAST_SRC="$src"
      if [[ -n ${ZSH_VERSION-} && -n ${ZLE_WIDGETS-} ]]; then
        zle reset-prompt 2>/dev/null || true
      fi
    fi
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _starship_sync_appearance

eval "$(starship init zsh)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export EDITOR=nvim
