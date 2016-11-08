# Path to your oh-my-zsh installation.
export ZSH=/Users/gpj/.oh-my-zsh

ZSH_THEME="agnoster"

alias zshrc="subl ~/.zshrc"
alias bundle!="bundle install && rake install"
alias be="bundle exec"
alias bu="bundle update"
alias ri="rake install"
alias gcm="git checkout master"
alias gpull="git pull"
alias gpush="git push"
alias gbranch="git checkout -b"
alias gclone="git clone"

function o() {
  z $1 && open .
}

export LANG=en_US.UTF-8

# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default ""
  fi
}

source $ZSH/oh-my-zsh.sh
source $HOME/.keys
