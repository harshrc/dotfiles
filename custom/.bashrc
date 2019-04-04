# .bashrc

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Source global definitions (taken care of by /etc/profile)
#if [ -f /etc/bash.bashrc ]; then
#. /etc/bash.bashrc
#fi


#---------------
# Some settings
#---------------
# Don't want any coredumps
ulimit -S -c 0
set -o notify
set -o noclobber
set -o ignoreeof
#set -o xtrace          # useful for debuging

# Enable options:
shopt -s cdspell
shopt -s cdable_vars
shopt -s checkhash
shopt -s checkwinsize
shopt -s no_empty_cmd_completion  # bash>=2.04 only
shopt -s cmdhist
shopt -s histappend histreedit histverify
shopt -s extglob    # necessary for programmable completion

# turn off system bell
# taken from https://blog.sleeplessbeastie.eu/2012/12/28/debian-how-to-turn-off-the-system-bell/
if [ -n "$DISPLAY" ]; then
  xset b off
fi

export TERM=xterm-256color

export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
HISTIGNORE='\&:fg:bg:ls:la:s:ll:h:pwd:cd ..:cd ~-:cd -:cd:jobs:set -x:ls -l:ls -al:ls -rt:ls -lrt:?:??:&:mv *:rm *:exec bash'
HISTIGNORE=${HISTIGNORE}':%1:%2:popd:top:pine:mutt:shutdown*'
export HISTIGNORE
# Reduce redundancy in the history file
export HISTCONTROL=ignoredups
export HOSTFILE=$HOME/.hosts    # Put a list of remote hosts in ~/.hosts
export HISTSIZE=10000
export HISTFILESIZE=${HISTSIZE}
#export BASH_COMPLETION=/etc/bash_completion
#from stackoverflow lesmana solution
history() {
  _bash_history_sync
  builtin history "$@"
}

_bash_history_sync() {
  builtin history -a         #1
  HISTFILESIZE=$HISTFILESIZE #2
  builtin history -c         #3
  builtin history -r         #4
}

# Following 3 functions copied from
# http://stackoverflow.com/questions/338285/prevent-duplicates-from-being-saved-in-bash-history
# remove duplicates while preserving input order
function dedup {
   awk '! x[$0]++' $@
}

# removes $HISTIGNORE commands from input
function remove_histignore {
   if [ -n "$HISTIGNORE" ]; then
      # replace : with |, then * with .*
      local IGNORE_PAT=`echo "$HISTIGNORE" | sed s/\:/\|/g | sed s/\*/\.\*/g`
      # negated grep removes matches
      grep -vx "$IGNORE_PAT" $@
   else
      cat $@
   fi
}

# clean up the history file by remove duplicates and commands matching
# $HISTIGNORE entries
function history_cleanup {
   local HISTFILE_SRC=~/.bash_history
   local HISTFILE_DST=/tmp/.$USER.bash_history.clean
   if [ -f $HISTFILE_SRC ]; then
      \cp $HISTFILE_SRC $HISTFILE_SRC.backup
      dedup $HISTFILE_SRC | remove_histignore >| $HISTFILE_DST
      \mv $HISTFILE_DST $HISTFILE_SRC
      chmod go-r $HISTFILE_SRC
      history -c
      history -r
   fi
}

#-----------------------
# Greeting, motd etc...
#-----------------------

# Define some colors first:
BLUE=`tput setf 1`
GREEN=`tput setf 2`
CYAN=`tput setf 3`
RED=`tput setf 4`
MAGENTA=`tput setf 5`
YELLOW=`tput setf 6`
WHITE=`tput setf 7`
NC='\e[0m'              # No Color

#---------------
# Shell Prompt
#---------------

if [[ "${DISPLAY#$HOSTNAME}" != ":0.0" &&  "${DISPLAY}" != ":0" ]]; then  
    HILIT=${RED}   # remote machine: prompt will be partly red
else
    HILIT=${CYAN}  # local machine: prompt will be partly cyan
fi

function parse_gitb {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}


#set xterm title
 case "$TERM" in
   xterm | xterm-color)
     XTERM_TITLE='\[\033]0;$TERM [\H] \w\007\]'   ;;
   *)   
     XTERM_TITLE='\[\033]0; [\H] \w\007\]'   ;;
 esac;


#Important: Always surround non-printing characters like the colors with \[ and \]
# The \[ and \] are necessary to not get line-wrapping problems on the terminal. 

function fastprompt()
{
    unset PROMPT_COMMAND
        case $TERM in
        *term | rxvt )
        PS1="$XTERM_TITLE \[${HILIT}\][\h]\[$NC\] \W \$(parse_gitb)>" ;;
    linux )
        PS1="\[${HILIT}\][\h]\[$NC\] \W \$(parse_gitb)> " ;;
    *)
        PS1="[\h] \W \$(parse_gitb)> " ;;
    esac
    export PROMPT_COMMAND=_bash_history_sync

}

fastprompt     # this is the default prompt 


function urdu()
{
   grep "$@" ~/exe/bin/urdu.dict
}



_killall ()
{
    local cur prev
        COMPREPLY=()
        cur=${COMP_WORDS[COMP_CWORD]}

# get a list of processes (the first sed evaluation
# takes care of swapped out processes, the second
# takes care of getting the basename of the process
    COMPREPLY=( $( /usr/bin/ps -u $USER -o comm  | \
                sed -e '1,1d' -e 's#[]\[]##g' -e 's#^.*/##'| \
                awk '{if ($0 ~ /^'$cur'/) print $0}' ))

        return 0
}



#add bash_completion feature


# Check for recent enough version of bash.
bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}

# Check for interactive shell.
if [ -n "$PS1" ]; then
  if [ $bmajor -eq 2 -a $bminor '>' 04 ] || [ $bmajor -gt 2 ]; then
    if [ -r /etc/bash_completion ]; then
      # Source completion code.
      . /etc/bash_completion
    fi
  fi
fi
unset bash bminor bmajor

# User specific aliases and functions
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:$HOME/tools/lib:
export VIMHOME=~/.vim
export PATH=$PATH:$HOME/exe/bin

export EDITOR="emacsclient -c"
export ALTERNATE_EDITOR=""
export VISUAL="emacsclient -c"


# some more ls aliases
alias ks='la -CF'; alias s='ls --color=auto -CF'
alias ..='cd ..'; alias ...='cd ../../'; alias ....='cd ../../../'
alias em='emacsclient -c '
alias p='pushd';alias o='popd';
alias d='dirs -v';alias f='pushd +1';alias b='pushd -0'
alias g='grep -n --color=auto'

# enable color support of ls and also add handy aliases
# if [ -x /usr/bin/dircolors ]; then
#     eval "`dircolors -b ~/.dircolors`"
#     alias s='ls --color=auto -CF'
#     alias g='grep -n --color=auto'
# fi

