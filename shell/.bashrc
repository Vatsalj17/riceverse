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
alias runimg='qemu-system-x86_64 -enable-kvm -boot menu=on -drive file=Imageold.img -m 4G -cpu host -vga virtio -display sdl'
alias gtop='sudo intel_gpu_top'
# alias lfs='qemu-system-x86_64 -enable-kvm -drive file=host-lfs.img -m 4G -cpu host -vga virtio -display sdl -net nic -net user,hostfwd=tcp::2222-:22 -chardev socket,path=/tmp/qga.sock,server=on,wait=off,id=qga0 -device virtio-serial -device virtserialport,chardev=qga0,name=org.qemu.guest_agent.0'
alias lfs='qemu-system-x86_64 \
  -enable-kvm \
  -drive file=host-lfs.img \
  -m 4G \
  -cpu host \
  -device virtio-gpu-pci,xres=1920,yres=1080 \
  -display sdl,gl=on \
  -net nic \
  -net user,hostfwd=tcp::2222-:22 \
  -chardev socket,path=/tmp/qga.sock,server=on,wait=off,id=qga0 \
  -device virtio-serial \
  -device virtserialport,chardev=qga0,name=org.qemu.guest_agent.0'
alias open='xdg-open'
alias todo='dooit'
alias yt='hyprctl dispatch workspace 8 >/dev/null && /opt/brave-bin/brave --password-store=basic --enable-features=UseOzonePlatform --ozone-platform=wayland --profile-directory=Default --app-id=agimnkijcaahngcdmfeangaknmldooml'
alias pgsql='/usr/pgadmin4/venv/bin/python /usr/pgadmin4/web/pgAdmin4.py'
alias localsrv='. ~/Codes/Python/Projects/local/.venv/bin/activate && python ~/Codes/Python/Projects/local/main.py && deactivate'
alias sstxt='. ~/Codes/Python/Scripts/imgtotxt/.venv/bin/activate && python ~/Codes/Python/Scripts/imgtotxt/main.py && deactivate'
alias pysrc='. .venv/bin/activate'
alias esp=". $HOME/esp/esp-idf/export.sh"
alias glog="git log --graph --abbrev-commit --decorate --all --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white) - %an%C(reset)%C(auto)%d%C(reset)'"

###   exports   ###
PS1='[\u@\h \W]\$ '
export PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
export PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
export PERL_MB_OPT="--install_base \"$HOME/perl5\""
export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"
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
export ANDROID_HOME="$HOME/Android/sdk"
export MANPAGER="nvim +Man!"
export BAT_THEME="Catppuccin Mocha"

path_add() {
    [[ -d $1 && ":$PATH:" != *":$1:"* ]] && PATH="$1:$PATH"
}

path_add /sbin
path_add "$HOME/.cargo/bin"
path_add "$HOME/.local/share/gem/ruby/3.4.0/bin"
path_add "$VEDIC_INSTALL/bin"
path_add "$PYENV_ROOT/bin"
path_add "$ANDROID_HOME/cmdline-tools/latest/bin"
path_add "$ANDROID_HOME/platform-tools"

if [[ -f "$HOME/.env" ]]; then
    set -a
    source "$HOME/.env"
    set +a
fi

###   scripts   ###
if [[ "$TERM" == "xterm-kitty" ]]; then
    fastfetch --config $HOME/.config/fastfetch/configv.jsonc
elif [[ "$TERM" == "foot" ]]; then
    fastfetch --config $HOME/.config/fastfetch/configf.jsonc
fi

# rm $HOME/ly-session.log 2> /dev/null

if [[ "$TERM" == "xterm-kitty" || "$TERM" == "tmux-256color" || "$TERM" == "foot" || "$TERM" == "xterm-256color" ]]; then
    eval "$(starship init bash)"
    alias heavy='export STARSHIP_CONFIG=~/.config/starship_heavy.toml'
    alias simple='unset STARSHIP_CONFIG'
fi

if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

play() {
    [[ $PWD == *Music* ]] || cd "$HOME/Music/Playlist" || return
    ls | shuf | xargs -r mpv --vid=no
}

rmspace() {
    for f in *\ *; do
        mv -v "$f" "${f// /_}"
    done
}

while2() {
    last_command="$(fc -ln -1)"
    if [[ -z "$last_command" ]]; then
        echo "No command to loop"
        return 1
    fi
    eval "while true; do $last_command; done"
}

ls() {
    if command -v lsd >/dev/null; then
        if [[ "$PWD" == "$HOME/Pictures"* ]] && command -v mcat >/dev/null; then
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
        builtin cd "$(printf '../%.0s' $(seq 1 ${1#-}))" || return
    else
        builtin cd "$@"
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

__fzf_history_search() {
    local selected
    selected=$(HISTTIMEFORMAT= history | fzf +s --tac --query "$READLINE_LINE" | sed -E 's/ *[0-9]+ +//')
    if [ -n "$selected" ]; then
        READLINE_LINE="$selected"
        READLINE_POINT=${#READLINE_LINE}
    fi
}

###   binds   ###
bind -x '"\C-r": __fzf_history_search'

###   sources   ###
source "$HOME/.cargo/env"
