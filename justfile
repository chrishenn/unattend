ssh:
    $HOST_SSH -At "cd ${HOST_REPO} && pwsh"

cm:
    $HOST_SSH -At "mise use -g chezmoi && $HOME/.local/share/mise/installs/chezmoi/latest/chezmoi init chrishenn --apply --force"

keys:
    #!/bin/bash
    # just for reference. Handled by script in chezmoi chrishenn/dotfiles
    # use 'cm' recipe above to accomplish the same
    keyf="C:\ProgramData\ssh\administrators_authorized_keys"
    echo "$(op read 'op://homelab/dkey/public key')" | $HOST_SSH "touch $keyf && cat >> $keyf"

alias s := sync
sync message="sync":
    git commit -a -m "{{message}}" || true && git pull && git push
    $HOST_SSH -At "cd ${HOST_REPO} && git commit -a -m '{{message}}' || true && git pull && git push"
