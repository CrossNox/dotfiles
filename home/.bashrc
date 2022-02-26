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

\cat ~/.cache/wal/sequences
source ~/.cache/wal/colors-tty.sh

eval "$(register-python-argcomplete pipx)"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

PATH="$HOME/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Load cargo
export PATH="$PATH:$HOME/.cargo/bin"

export EDITOR=nvim


NNN_FCOLORS_VENV=${PIPX_HOME:-$HOME/.local/pipx}/venvs/pywal/bin/python
export NNN_FCOLORS=$( $NNN_FCOLORS_VENV ~/.config/wal/rgb2xterm256.py )
export NNN_OPTS="deHG"
export LC_COLLATE="C"
export NNN_FIFO="/tmp/nnn.fifo"
export NNN_PLUG="p:preview-tui"
export NNN_STARTUP_PLUGINS="p"
export SPLIT="v"

function nnn ()
{
	command nnn -P $NNN_STARTUP_PLUGINS "$@";
}

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

NB_COLOR_THEME=ocean

# time nbtodos


export PATH="$PATH:$HOME/.spicetify"


# BEGIN_KITTY_SHELL_INTEGRATION
if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; fi
# END_KITTY_SHELL_INTEGRATION
