#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[[ -f ~/.welcome_screen ]] && . ~/.welcome_screen

_set_liveuser_PS1() {
    PS1='[\u@\h \W]\$ '
    if [ "$(whoami)" = "liveuser" ] ; then
        local iso_version="$(grep ^VERSION= /usr/lib/endeavouros-release 2>/dev/null | cut -d '=' -f 2)"
        if [ -n "$iso_version" ] ; then
            local prefix="eos-"
            local iso_info="$prefix$iso_version"
            PS1="[\u@$iso_info \W]\$ "
        fi
    fi
}
_set_liveuser_PS1
unset -f _set_liveuser_PS1

ShowInstallerIsoInfo() {
    local file=/usr/lib/endeavouros-release
    if [ -r $file ] ; then
        cat $file
    else
        echo "Sorry, installer ISO info is not available." >&2
    fi
}


alias ls='ls --color=auto'
alias ll='ls -lav --ignore=..'   # show long listing of all except ".."
alias l='ls -lav --ignore=.?*'   # show long listing but no hidden dotfiles except "."

[[ "$(whoami)" = "root" ]] && return

[[ -z "$FUNCNEST" ]] && export FUNCNEST=100          # limits recursive functions, see 'man bash'

## Use the up and down arrow keys for finding a command in history
## (you can write some initial letters of the command first).
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

################################################################################
## Some generally useful functions.
## Consider uncommenting aliases below to start using these functions.
##
## October 2021: removed many obsolete functions. If you still need them, please look at
## https://github.com/EndeavourOS-archive/EndeavourOS-archiso/raw/master/airootfs/etc/skel/.bashrc

_open_files_for_editing() {
    # Open any given document file(s) for editing (or just viewing).
    # Note1:
    #    - Do not use for executable files!
    # Note2:
    #    - Uses 'mime' bindings, so you may need to use
    #      e.g. a file manager to make proper file bindings.

    if [ -x /usr/bin/exo-open ] ; then
        echo "exo-open $@" >&2
        setsid exo-open "$@" >& /dev/null
        return
    fi
    if [ -x /usr/bin/xdg-open ] ; then
        for file in "$@" ; do
            echo "xdg-open $file" >&2
            setsid xdg-open "$file" >& /dev/null
        done
        return
    fi

    echo "$FUNCNAME: package 'xdg-utils' or 'exo' is required." >&2
}

#------------------------------------------------------------

## Aliases for the functions above.
## Uncomment an alias if you want to use it.
##

# alias ef='_open_files_for_editing'     # 'ef' opens given file(s) for editing
# alias pacdiff=eos-pacdiff
################################################################################



# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"

# Default agy to ~/Desktop/AI CLI WORK when opening terminal and typing agy
agy() {
    local default_ws="$HOME/Desktop/AI CLI WORK"
    if [ "$PWD" = "$HOME" ]; then
        cd "$default_ws" && $HOME/.local/bin/agy "$@"
    else
        $HOME/.local/bin/agy "$@"
    fi
}

# Default claude to ~/Desktop/AI CLI WORK when opening terminal and typing claude
claude() {
    local default_ws="$HOME/Desktop/AI CLI WORK"
    if [ "$PWD" = "$HOME" ]; then
        cd "$default_ws" && /usr/bin/claude "$@"
    else
        /usr/bin/claude "$@"
    fi
}

alias aiwork='cd "$HOME/Desktop/AI CLI WORK"'
alias lg='lazygit'
alias clip='xclip -selection clipboard'
alias clippaste='xclip -selection clipboard -o'
# Smart venv manager (activates existing .venv or creates and activates new one)
venv() {
    if [ ! -d ".venv" ]; then
        echo "Creating virtualenv at .venv via uv..."
        uv venv .venv
    fi
    # shellcheck disable=SC1091
    source .venv/bin/activate
}
alias activate='source .venv/bin/activate'

# Obsidian Central AI Knowledge Base Integration
export OBSIDIAN_AI_VAULT="$HOME/Obsidian/AI-Knowledge-Base"
alias ai-notes='obsidian'

ask-ollama() {
    local model="qwen2.5-coder:latest"
    local positional=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -m|--model)
                if [[ $# -lt 2 || -z "$2" ]]; then
                    echo "Error: -m/--model requires a model argument" >&2
                    return 1
                fi
                model="$2"
                shift 2
                ;;
            --)
                shift
                positional+=("$@")
                break
                ;;
            *)
                positional+=("$1")
                shift
                ;;
        esac
    done

    set -- "${positional[@]}"

    if [ ! -t 0 ]; then
        local stdin_data
        stdin_data="$(command cat)"
        if [ -n "$stdin_data" ] && [ -n "$*" ]; then
            printf "%s\n\nTask: %s\n" "$stdin_data" "$*" | ollama run "$model"
        elif [ -n "$stdin_data" ]; then
            printf "%s\n" "$stdin_data" | ollama run "$model"
        elif [ -n "$*" ]; then
            ollama run "$model" "$*"
        else
            echo "Error: No prompt provided and stdin was empty." >&2
            echo "Usage: ask-ollama [-m model] [prompt] (or pipe via stdin)" >&2
            return 1
        fi
    else
        if [ $# -gt 0 ]; then
            ollama run "$model" "$*"
        else
            ollama run "$model"
        fi
    fi
}
alias ask-qwen='ask-ollama -m qwen2.5-coder:latest'
alias ask-llama='ask-ollama -m llama3.2:latest'
alias ask-dolphin='ask-ollama -m dolphin-mistral:latest'
alias ask-hermes='ask-ollama -m nous-hermes2:latest'
alias ask-ab='ask-ollama -m qwen-abliterated:latest'

alias ollama-warm='curl -s -X POST http://localhost:11434/api/generate -d '\''{"model": "qwen2.5-coder:latest"}'\'' >/dev/null &'

ollama-stop() {
    if [ -n "$1" ]; then
        ollama stop "$1"
    else
        local running
        running=$(ollama ps | awk 'NR>1 {print $1}')
        if [ -n "$running" ]; then
            echo "Stopping resident models: $running"
            for m in $running; do
                ollama stop "$m"
            done
        else
            echo "No resident models currently loaded."
        fi
    fi
}
alias ollama-flush='ollama-stop'

# Universal AI CLI Dispatcher & Quick Helpers
ai-help() {
    if command -v agy-widget >/dev/null 2>&1; then
        agy-widget
    else
        echo "Antigravity CLI Suite"
    fi
}

ai() {
    case "$1" in
        status)
            echo -e "\033[38;2;203;166;247m── 🤖 Live AI Telemetry ──\033[0m"
            echo -n "Ollama Engine: "
            ollama ps 2>/dev/null | awk 'NR>1 {print $1 " (" $3 " " $4 ")"}' | grep . || echo "Standby (no resident model)"
            echo -n "Knowledge Base: "
            ai-kb status 2>/dev/null | grep "Total Notes" || echo "Active (~/Obsidian/AI-Knowledge-Base)"
            echo "Assistants:    claude (Claude Code) · agy (Antigravity/Gemini)"
            echo "Interactive:   oterm (Terminal Chat TUI)"
            ;;
        warm)
            ollama-warm
            echo "Pre-warming qwen2.5-coder into RAM..."
            ;;
        stop)
            ollama-stop "$2"
            ;;
        flush)
            ollama-flush
            ;;
        work)
            cd "$HOME/Desktop/AI CLI WORK" && venv
            ;;
        help|cmd|commands|widget)
            ai-help
            ;;
        menu)
            agy-menu
            ;;
        "")
            ai status
            ;;
        *)
            ask-qwen "$@"
            ;;
    esac
}

# Quick query alias: ? "how to extract tar.xz" or cat file | ? "explain"
alias '?'='ask-qwen'

# Non-blocking background warmup for Ollama Qwen 2.5 Coder
if [[ $- == *i* ]]; then
    (curl -s -X POST http://localhost:11434/api/generate -d '{"model": "qwen2.5-coder:latest"}' > /dev/null 2>&1 &)
fi



# --- Terminal Customizations (ASCII Banner, Syntax Highlighting, Prompt) ---

# 1. Syntax Highlighting (Bash Line Editor)
[[ $- == *i* ]] && source ~/.local/share/blesh/ble.sh

# 2. Modern Commands (bat -> cat, eza -> ls, yazi, trash, du/ps)
alias cat='bat --style=plain'
alias man='batman'
alias ls='eza --icons=always --color=always'
alias ll='eza -la --icons=always --color=always'
alias du='dust'
alias tp='trash-put'
alias tl='trash-list'
alias trestore='trash-restore'

# Yazi shell wrapper (changes directory on exit)
y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# 3. Custom Prompt (Starship)
eval "$(starship init bash)"

# 4. System Telemetry & AI Workstation Banner (Fastfetch + EndeavourOS + Antigravity Widget)
if [[ $- == *i* ]]; then
    fastfetch
    if command -v agy-widget >/dev/null 2>&1; then
        agy-widget --banner
    fi
fi

# 5. Zoxide (Smarter cd)
eval "$(zoxide init bash)"

# 6. FZF Key Bindings
if [ -f /usr/share/fzf/key-bindings.bash ]; then
    source /usr/share/fzf/key-bindings.bash
    source /usr/share/fzf/completion.bash
fi

# 7. Colorful standard commands
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ip='ip -color=auto'
alias diff='diff --color=auto'

# Font & Wallpaper Tuning Shortcuts
alias set-wallpaper="$HOME/Desktop/AI CLI WORK/set-wallpaper.sh"
alias font-tune="$HOME/Desktop/AI CLI WORK/font-tune.sh"

# --- Antigravity Suite & System Security Baked Commands ---
alias cc='command-center'
alias agy-cmd='agy-widget'
alias agy-help='agy-widget'
alias sys-backup='$HOME/Desktop/AI\ CLI\ WORK/Scripts/backup-system-configs.sh'
alias sec-status='command-center --json 2>/dev/null | jq -r ".network | \"🔒 MAC: \(.current_mac) (rand=\(.is_anonymized))\n🛡️ DoT: \(.dot_encrypted) (Quad9:853)\n🔥 Firewall: \(.firewall_target)\n🔇 mDNS Disabled: \(.mDNS_disabled)\"" || resolvectl status wlan0'
alias sec-audit='$HOME/Desktop/AI\ CLI\ WORK/Scripts/git-security-hook.sh'
alias throttled-status='systemctl status throttled --no-pager'
alias ananicy-status='systemctl status ananicy-cpp --no-pager'
alias oom-status='systemctl status nohang --no-pager'
alias wifi-home='nmcli connection up REDACTED-NET'
alias wifi-hotspot='nmcli connection up "REDACTED-NET"'
alias scope-cap='$HOME/Desktop/AI\ CLI\ WORK/pentest-scope/scoped-capture.sh'


fi

# OpenSSH agent (systemd user unit ssh-agent.socket) - added for GitHub SSH key
if [ -z "$SSH_AUTH_SOCK" ] || [ "$SSH_AUTH_SOCK" = "${XDG_RUNTIME_DIR:-/run/user/$UID}/gcr/ssh" ]; then
    export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$UID}/ssh-agent.socket"
fi
