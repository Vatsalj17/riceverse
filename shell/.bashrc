#
# ~/.bashrc
#
# If not running interactively, don't do anything
[[ $- != *i* ]] && return


###   aliases   ###
alias :q='exit'
alias grep='grep --color=auto'
alias objdump='objdump -M intel'
# alias ls='ls --color=auto'
alias icat='kitty +kitten icat'
alias play='pwd | grep Music > /dev/null && /bin/ls | shuf | xargs mpv --vid=no'
alias gitbkp='$HOME/.config/hypr/scripts/backup.sh'
alias rmspace='for f in *\ *; do mv "$f" "${f// /_}"; done'
alias kx='while true; do pkill xdg-mime; done'
alias ko='while true; do pkill xdg-open; done'
alias runimg='qemu-system-x86_64 -enable-kvm -boot menu=on -drive file=Imageold.img -m 4G -cpu host -vga virtio -display sdl'
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
alias code="nvim"
alias glog="git log --graph --abbrev-commit --decorate --all --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white) - %an%C(reset)%C(auto)%d%C(reset)'"
alias heavy='export STARSHIP_CONFIG=~/.config/starship_heavy.toml'
alias simple='unset STARSHIP_CONFIG'


###   exports   ###
PS1='[\u@\h \W]\$ '
PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;
export EDITOR=nvim
export VISUAL=nvim
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export QT_QPA_PLATFORMTHEME=qt6ct
export GTK_THEME=Adwaita-dark
export GTK_DATA_PREFIX=/usr
export GDK_BACKEND=wayland
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

export PATH="$PATH:/sbin"
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$HOME/.local/share/gem/ruby/3.4.0/bin"
export PATH="$PATH:$VEDIC_INSTALL/bin"
export PATH="$PATH:$PYENV_ROOT/bin"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

if [[ -f "$HOME/.env" ]]; then
    set -a
    source "$HOME/.env"
    set +a
fi


###   eval    ###
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)" > /dev/null
fi
ssh-add ~/.ssh/id_ed25519 &> /dev/null

# eval "$(pyenv init --path)"
# eval "$(pyenv init -)"

###   scripts   ###
if [[ "$TERM" == "xterm-kitty" ]]; then
    fastfetch --config $HOME/.config/fastfetch/configv.jsonc
fi

# rm $HOME/ly-session.log 2> /dev/null

if [[ "$TERM" == "xterm-kitty" || "$TERM" == "tmux-256color" ]]; then
    eval "$(starship init bash)"  
fi

if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# >>> juliaup initialize >>>
# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:$HOME/.juliaup/bin:*)
        ;;

    *)
        export PATH=$HOME/.juliaup/bin${PATH:+:${PATH}}
        ;;
esac
# <<< juliaup initialize <<<

while2() {
    last_command="$(fc -ln -1)"
    if [[ -z "$last_command" ]]; then
        echo "No command to loop"
        return 1
    fi
    eval "while true; do $last_command; done"
}

sudol() {
    last_command="$(fc -ln -1)"
    if [[ -z "$last_command" ]]; then
        echo "No command to re-run with sudo."
        return 1
    fi
    eval "sudo $last_command"
}

ls() {
    if [[ "$PWD" == "$HOME/Pictures"* ]]; then
        mcat ls "$@"
    else
        command lsd --color=auto "$@"
    fi
}

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
# source $(dirname $(gem which colorls))/tab_complete.sh
source "$HOME/.cargo/env"
# if [[ $TERM == "xterm-kitty" ]]; then source "$HOME/.config/hypr/scripts/funny.sh"; fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
# export SDKMAN_DIR="$HOME/.sdkman"
# [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
