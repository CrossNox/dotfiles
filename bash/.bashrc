# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
source /usr/share/autojump/autojump.bash
source ~/.alias
source ~/.config/powerline/.powerline

eval "$(register-python-argcomplete pipx)"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
source ~/.rvm/scripts/rvm

PATH="/home/nox/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/nox/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/nox/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/nox/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/nox/perl5"; export PERL_MM_OPT;

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Load cargo
export PATH="$PATH:$HOME/.cargo/bin"

export EDITOR=nvim

BLK="0B" CHR="0B" DIR="04" EXE="06" REG="00" HARDLINK="06" SYMLINK="06" MISSING="00" ORPHAN="09" FIFO="06" SOCK="0B" OTHER="06"
export NNN_FCOLORS="$BLK$CHR$DIR$EXE$REG$HARDLINK$SYMLINK$MISSING$ORPHAN$FIFO$SOCK$OTHER"
export NNN_OPTS="de"
export LC_COLLATE="C"
export NNN_FIFO="/tmp/nnn.fifo"
export NNN_PLUG="p:preview-tui"
export SPLIT="v"

# n () # to cd on quit
# {
#     if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
#         echo "nnn is already running"
#         return
#     fi
#     export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
#     nnn "$@
#     if [ -f "$NNN_TMPFILE" ]; then
#             . "$NNN_TMPFILE"
#             rm -f "$NNN_TMPFILE" > /dev/null
#     fi
# }

export PATH="$PATH:$HOME/go/bin"

source /home/nox/.bash_completions/odd.sh

NB_COLOR_THEME=ocean

nbtodos
