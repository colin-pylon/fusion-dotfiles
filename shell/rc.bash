# Sourced from ~/.bashrc. A long-lived shell (tmux, a one-shot `coder ssh`)
# can carry a GIT_ASKPASS/GIT_SSH_COMMAND under a /tmp/coder.* dir that is gone
# once that ssh session ends, and a GITHUB_TOKEN minted at login that expires;
# the box's gh wrapper and git credential helper mint fresh tokens instead.
export GIT_ASKPASS=/bin/coder
export GIT_SSH_COMMAND='/bin/coder gitssh --'
unset GITHUB_TOKEN
