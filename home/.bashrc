#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ls='colorls --color=auto'
alias icat='kitty +kitten icat'
alias play='/bin/ls | shuf | xargs mpv'
PS1='[\u@\h \W]\$ '

if [[ "$TERM" == "xterm-kitty" ]]; then
    neofetch --config /home/Vatsal/.config/neofetch/configv.conf
fi

eval "$(ssh-agent -s)" &> /dev/null
ssh-add ~/.ssh/id_ed25519 &> /dev/null

PATH="/home/Vatsal/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/Vatsal/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/Vatsal/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/Vatsal/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/Vatsal/perl5"; export PERL_MM_OPT;
export PATH=$PATH:/sbin
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/share/gem/ruby/3.3.0/bin:$PATH"
export EDITOR=nvim
export VISUAL=nvim
export QT_QPA_PLATFORMTHEME=qt6ct

if [[ "$TERM" == "xterm-kitty" || "$TERM" == "tmux-256color" ]]; then
    eval "$(starship init bash)"  
fi

cd() {
    if [[ $1 =~ ^-[0-9]+$ ]]; then
        num=${1#-}  # Remove the leading '-'
        path=""
        for ((i=0; i<num; i++)); do
            path+="../"
        done
        builtin cd "$path" || return
    else
        builtin cd "$@"
    fi
}

source $(dirname $(gem which colorls))/tab_complete.sh

