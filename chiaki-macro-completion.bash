# Bash completion for chiaki-macro
# Install:  sudo cp chiaki-macro-completion.bash /etc/bash_completion.d/

_chiaki_macro() {
    local cur prev words cword
    _init_completion || return

    local cmds="list devices record play delete import orchestrate collage ocr-test orchestrate-init"

    case $prev in
        play|delete)
            # Complete with macro names from macros.json
            local macros=$(python3 -c "
import json, os
try:
    with open(os.path.expanduser('~/.config/chiaki-macro/macros.json')) as f:
        for name in json.load(f).get('macros', {}):
            print(name)
except: pass
" 2>/dev/null)
            COMPREPLY=($(compgen -W "$macros" -- "$cur"))
            return
            ;;
        record)
            # Complete --device with input devices, or --yes, or existing macro names
            if [[ "$cur" == --* ]]; then
                COMPREPLY=($(compgen -W "--device --yes -d -y" -- "$cur"))
            else
                local macros=$(python3 -c "
import json, os
try:
    with open(os.path.expanduser('~/.config/chiaki-macro/macros.json')) as f:
        for name in json.load(f).get('macros', {}):
            print(name)
except: pass
" 2>/dev/null)
                COMPREPLY=($(compgen -W "$macros" -- "$cur"))
            fi
            return
            ;;
        import|orchestrate|orchestrate-init)
            # Complete file paths
            _filedir
            return
            ;;
        collage)
            # Check if --parts is among previous words
            local has_parts=0
            for w in "${words[@]}"; do [[ "$w" == "--parts" ]] && has_parts=1; done
            if (( has_parts )); then
                local macros=$(python3 -c "
import json, os
try:
    with open(os.path.expanduser('~/.config/chiaki-macro/macros.json')) as f:
        for name in json.load(f).get('macros', {}):
            print(name)
except: pass
" 2>/dev/null)
                COMPREPLY=($(compgen -W "$macros" -- "$cur"))
            else
                COMPREPLY=($(compgen -W "--parts" -- "$cur"))
            fi
            return
            ;;
    esac

    # Default: complete subcommand
    COMPREPLY=($(compgen -W "$cmds" -- "$cur"))
}

complete -F _chiaki_macro chiaki-macro
