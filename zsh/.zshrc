# ----------------------------
# Oh My Zsh
# ----------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # Disabled — using Starship instead

plugins=(git)

source $ZSH/oh-my-zsh.sh

# ----------------------------
# Completion (fish-like)
# ----------------------------
autoload -Uz compinit
zstyle ':completion:*' menu select
zmodload zsh/complist

if [[ ! -f ~/.zcompdump ]]; then
  compinit
else
  compinit -C
fi

# ----------------------------
# Fish-like UX
# ----------------------------
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ----------------------------
# Autojump
# ----------------------------
if [[ -f /usr/share/autojump/autojump.zsh ]]; then
  source /usr/share/autojump/autojump.zsh
elif [[ -f /usr/share/autojump/autojump.bash ]]; then
  # autojump.bash uses bash's `complete` builtin which is incompatible with zsh
  complete() { :; }
  source /usr/share/autojump/autojump.bash
  unfunction complete
  # PROMPT_COMMAND is bash-only; use zsh's chpwd hook for directory tracking
  chpwd_functions+=(autojump_add_to_database)
fi

# ----------------------------
# Editor
# ----------------------------
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# ----------------------------
# Aliases
# ----------------------------
alias vim=nvim

# ----------------------------
# PATH
# ----------------------------
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

# ----------------------------
# Starship prompt (must be last)
# ----------------------------
export STARSHIP_CONFIG_TITLE=false
eval "$(starship init zsh)"
