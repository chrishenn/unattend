set windows-shell := ['pwsh', '-c']

[unix]
s: sync

[unix]
sync message="sync":
    git commit -am "{{ message }}" && git pull && git push

[unix]
syncr message="sync":
    git commit -a -m "{{ message }}" || true && git pull && git push
    $HOST_SSH -At "cd ${HOST_REPO} && git pull"

[unix]
sync_init message="sync":
    git commit -a -m "{{ message }}" || true && git pull && git push
    $HOST_SSH -At "rm -rf /users/chris/unattend && cd $HOST_REPO/.. && git clone https://github.com/chrishenn/unattend.git"

[windows]
ssh:
    pwsh -c "$env:HOST_SSH -At 'cd $env:HOST_REPO && pwsh'"
