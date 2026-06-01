[ -n "${BASH_VERSION:-}" ] || { command -v bash >/dev/null 2>&1 || { echo "bash is required" >&2; exit 1; }; [ -f "$0" ] && exec bash "$0" "$@"; exec bash -c "$(cat)"; }
echo "==> installing..."
command -v apt-get >/dev/null 2>&1 && { apt-get update -y; apt-get install -y curl grc fastfetch; } || true
command -v dnf >/dev/null 2>&1 && dnf install -y curl grc fastfetch || true
command -v yum >/dev/null 2>&1 && yum install -y curl grc fastfetch || true
command -v pacman >/dev/null 2>&1 && pacman -Sy --noconfirm curl grc fastfetch || true
command -v apk >/dev/null 2>&1 && apk add --no-cache curl grc fastfetch || true
command -v zypper >/dev/null 2>&1 && zypper --non-interactive install curl grc fastfetch || true
command -v brew >/dev/null 2>&1 && brew install fastfetch grc || true
if ! command -v fastfetch >/dev/null 2>&1; then
ARCH=$(uname -m)
case "$ARCH" in x86_64) FF_ARCH="amd64" ;; aarch64|arm64) FF_ARCH="aarch64" ;; armv7l) FF_ARCH="armv7l" ;; i686|i386) FF_ARCH="i686" ;; riscv64) FF_ARCH="riscv64" ;; *) FF_ARCH="amd64" ;; esac
curl -sL "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-${FF_ARCH}.tar.gz" -o /tmp/ff.tar.gz
tar -xzf /tmp/ff.tar.gz -C /tmp
FF_BIN=$(find /tmp -maxdepth 3 -type f -name fastfetch 2>/dev/null | head -n1)
[ -n "$FF_BIN" ] && { install -Dm755 "$FF_BIN" /usr/local/bin/fastfetch 2>/dev/null || { mkdir -p ~/.local/bin; install -Dm755 "$FF_BIN" ~/.local/bin/fastfetch; }; }
rm -f /tmp/ff.tar.gz
fi
[ -f ~/.local/bin/fastfetch ] && ! grep -q 'PATH=.local/bin' ~/.bashrc 2>/dev/null && echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
cat > ~/.bash_colors <<'COLORS'
export HISTSIZE=100000
export HISTFILESIZE=200000
export HISTTIMEFORMAT="%F %T "
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend 2>/dev/null || true
PROMPT_COMMAND="history -a; ${PROMPT_COMMAND}"
if ls --color=auto >/dev/null 2>&1; then alias ls='ls --color=auto'; alias ll='ls -alF --color=auto'; alias la='ls -A --color=auto'; else alias ls='ls -G'; alias ll='ls -alFG'; alias la='ls -AG'; fi
alias grep='grep --color=auto'
if command -v grc >/dev/null 2>&1 && [ "$TERM" != "dumb" ]; then for cmd in ping tail df du free netstat ps ss stat systemctl journalctl; do command -v "$cmd" >/dev/null 2>&1 && alias "$cmd"="grc -es --colour=auto $cmd"; done; fi
if [ "$(id -u)" -ne 0 ]; then PS1='\[\e[38;5;81m\]\u\[\e[93m\]@\[\e[38;5;42m\]\h\[\e[0m\] \[\e[38;5;32m\]\w\[\e[0m\] \$ '; else PS1='\[\e[91m\]\u\[\e[93m\]@\[\e[38;5;42m\]\h\[\e[0m\] \[\e[38;5;32m\]\w\[\e[0m\] # '; fi
if [[ $- == *i* ]]; then command -v fastfetch >/dev/null 2>&1 && fastfetch; fi
COLORS
sed -i 's/^\([[:space:]]*source.*abashrc\)/# \1/' ~/.bashrc 2>/dev/null || true
sed -i 's/^\([[:space:]]*source.*bash_colors\)/# \1/' ~/.bashrc 2>/dev/null || true
grep -qxF 'if [ -f ~/.bash_colors ]; then source ~/.bash_colors; fi' ~/.bashrc 2>/dev/null || echo 'if [ -f ~/.bash_colors ]; then source ~/.bash_colors; fi' >> ~/.bashrc
touch ~/.hushlogin 2>/dev/null || true
[ -d /etc/update-motd.d ] && chmod -x /etc/update-motd.d/* 2>/dev/null || true
[ -f /etc/ssh/sshd_config ] && { sed -i 's/^#*PrintMotd.*/PrintMotd no/' /etc/ssh/sshd_config 2>/dev/null || true; systemctl restart sshd >/dev/null 2>&1 || service ssh restart >/dev/null 2>&1 || true; }
echo "✅ done. run: source ~/.bashrc"
