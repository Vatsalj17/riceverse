#
# ~/.bashrc
#
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

###   aliases   ###
alias :q='exit'
alias grep='grep --color=auto'
alias rm='rm -Iv'
alias objdump='objdump -M intel'
alias gitbkp='$HOME/.config/hypr/scripts/backup.sh'
alias gtop='sudo intel_gpu_top'
alias open='xdg-open'
alias todo='dooit'
alias pgsql='/usr/pgadmin4/venv/bin/python /usr/pgadmin4/web/pgAdmin4.py'
alias localsrv='. ~/Codes/Python/Projects/local/.venv/bin/activate && python ~/Codes/Python/Projects/local/main.py && deactivate'
alias sstxt='. ~/Codes/Python/Scripts/imgtotxt/.venv/bin/activate && python ~/Codes/Python/Scripts/imgtotxt/main.py && deactivate'
alias pysrc='. .venv/bin/activate'
alias esp=". ~/esp/esp-idf/export.sh"
alias glog="git log --graph --abbrev-commit --decorate --all --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white) - %an%C(reset)%C(auto)%d%C(reset)'"
alias code='nvim'
alias updatemirrors='sudo reflector --country India,Singapore,Japan --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist && sudo pacman -Syy'

###   exports   ###
PS1='[\u@\h \W]\$ '
export EDITOR=nvim
export VISUAL=nvim
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export GTK_THEME=Adwaita-dark
export GTK_DATA_PREFIX=/usr
export GDK_BACKEND=wayland
export LIBVA_DRIVER_NAME=iHD
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#313244,label:#CDD6F4"
export VEDIC_INSTALL="$HOME/.vedic"
export PYENV_ROOT="$HOME/.pyenv"
export MANPAGER="nvim +Man!"
export BAT_THEME="Catppuccin Mocha"
export DEBUGINFOD_URLS="https://debuginfod.archlinux.org"

path_add() {
    [[ -d $1 && ":$PATH:" != *":$1:"* ]] && PATH="$1:$PATH"
}

path_add "$HOME/.cargo/bin"
path_add "$HOME/.local/share/gem/ruby/3.4.0/bin"
path_add "$VEDIC_INSTALL/bin"
path_add "$PYENV_ROOT/bin"

if [[ -f "$HOME/.env" ]]; then
    set -a
    source "$HOME/.env"
    set +a
fi

###   scripts   ###
if [[ "$TERM" == "xterm-kitty" ]]; then
    fastfetch --config "$HOME/.config/fastfetch/configv.jsonc"
elif [[ "$TERM" == "foot" ]]; then
    fastfetch --config "$HOME/.config/fastfetch/configf.jsonc"
fi

case "$TERM" in xterm-kitty|tmux-256color|foot|xterm-256color)
    eval "$(starship init bash)"
    alias heavy='export STARSHIP_CONFIG=~/.config/starship_heavy.toml'
    alias simple='unset STARSHIP_CONFIG'
    ;;
esac

if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

play() {
    [[ $PWD == *Music* ]] || cd "$HOME/Music/Playlist" || return
    /bin/ls | shuf | xargs -r mpv --vid=no
}

rmspace() {
    for f in *\ *; do
        mv -v "$f" "${f// /_}"
    done
}

ls() {
    if command -v lsd >/dev/null; then
        if [[ "$PWD" == "$HOME/Pictures"* && "$TERM" == "xterm-kitty" ]] && command -v mcat >/dev/null; then
            mcat ls "$@"
        else
            command lsd --color=auto "$@"
        fi
    else
        command ls --color=auto "$@"
    fi
}

cd() {
    if [[ $1 =~ ^-[0-9]+$ ]]; then
        local n=${1#-}
        local path=
        for ((i=0; i<n; i++)); do
            path+="../"
        done
        builtin cd "$path" || return
    else
        builtin cd "$@" || return
    fi
}

codesnap() {
    local file="$1"
    local filename="${file%.*}"
    codesnap -f "$file" -o "${filename}.png" \
        --code-font-family "FiraCode Nerd Font" \
        --has-line-number \
        --start-line-number 1 \
        --mac-window-bar true \
        --has-border \
        --border-color "#ffffff30" \
        --shadow-radius 30 \
        --shadow-color "#00000080" \
        --margin-x 60 \
        --margin-y 60 \
        --scale-factor 3 \
        --title "$file" \
        --title-font-family "FiraCode Nerd Font" \
        --title-color "#ffffff" \
        --background "#1e1e2e"
}

savepow() {
    echo "Initiating Power Saver..."
    sudo bootctl set-default lts.conf
    echo "[+] Bootloader target set to: LTS Kernel"
    echo "1" | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null
    echo "[+] Intel Turbo Boost: DISABLED"
    powerprofilesctl set power-saver
    echo "[+] Platform Profile: Power-Saver"
    echo ">> Survival Mode"
}

resetpow() {
    echo "Restoring Power Mode..."
    sudo bootctl set-default zen.conf
    echo "[+] Bootloader target set to: Zen Kernel"
    echo "0" | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null
    echo "[+] Intel Turbo Boost: ENABLED"
    powerprofilesctl set balanced
    echo "[+] Platform Profile: Balanced"
    echo ">> System restored to normal"
}

__fzf_history_search() {
    local selected
    selected=$(
        builtin history \
        | sed 's/^ *[0-9]\+ *//' \
        | fzf --tac \
              --query "$READLINE_LINE" \
              --height 40% \
              --border
    )
    [[ -n $selected ]] && {
        READLINE_LINE="$selected"
        READLINE_POINT=${#READLINE_LINE}
    }
}

###   binds   ###
bind -x '"\C-r": __fzf_history_search'
