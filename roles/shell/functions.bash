# make a directory then cd into it
function mkcd() { mkdir "$1" && cd "$1"; }

# recursively set ownership
function mkmine() { sudo chown -R ${USER} ${1:-.}; }

# simple calculator
function calc() { echo "$*" | bc; }

# make a tar.gz
function mktar() { tar cvzpf "${1%%/}.tar.gz" "${1%%/}/"; }

# sort a directory's used space and displays total gigabytes
dusort() { sudo \du -x -B 1048576 $1 | sort -rn | head -n10; }

# extract different archives automatically
extract () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xvjf $1   ;;
      *.tar.gz)    tar xvzf $1   ;;
      *.bz2)       bunzip2 $1    ;;
      *.gz)        gunzip $1     ;;
      *.tar)       tar xf $1     ;;
      *.tbz2)      tar xjf $1    ;;
      *.tgz)       tar xzf $1    ;;
      *.zip)       unzip $1      ;;
      *.Z)         uncompress $1 ;;
      *.rar)       7z x $1       ;;
      *.7z)        7z x $1       ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi }

# packs $2-$n into $1 depending on $1's extension.  add more file types as needed
function pack() {
	 if [ $# -lt 2 ] ; then
	    echo -e "\npack() usage:"
	    echo -e "\tpack archive_file_name file1 file2 ... fileN"
	    echo -e "\tcreates archive of files 1-N\n"
	 else
	   DEST=$1
	   shift

	   case $DEST in
		*.tar.bz2)		tar -cvjf $DEST "$@" ;;
		*.tar.gz)		tar -cvzf $DEST "$@" ;;
		*.zip)			zip -r $DEST "$@" ;;
		*.xpi)			zip -r $DEST "$@" ;;
		*)				echo "Unknown file type - $DEST" ;;
	   esac
	 fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# like sleep, but spits out a . every second
function delay() {
	 typeset -i NUM
	 NUM=$1
	 if [ $NUM -gt 0 ] ; then
	     for i in `seq $NUM` ; do sleep 1 ; echo -n '.' ; done
	     echo ""
	 else
	     echo "Invalid argument.  Please use a positive integer."
	 fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# screen attach.  if multiple, presents a menu for choosing.
function ssx() {
    OPTS=`screen -ls | grep "[0-9]\." | while read line ; do echo "$line" | sed -e 's/\s/_/g' ; done`

    case $(echo $OPTS | wc -w) in
	0)
	    echo -e "\nNo screen sessions open\n"
	    ;;
	1)
	    SESSION=$OPTS
	    echo -e "\nAttaching to only available screen"
	    ;;
	*)
	    echo -e "\nPick a screen session"
	    select opt in $OPTS ; do
		SESSION=$opt
		break;
	    done
	    ;;
    esac

    screen -x $(echo $SESSION | sed -e 's/\..*//')
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Human readable file size
# (because `du -h` doesn't cut it for me).
function hrfs() {
    printf "%s" "$1" |
    awk '{
            i = 1;
            split("B KB MB GB TB PB EB ZB YB WTFB", v);
            value = $1;
            # confirm that the input is a number
            if ( value + .0 == value ) {
                while ( value >= 1024 ) {
                    value/=1024;
                    i++;
                }
                if ( value == int(value) ) {
                    printf "%d %s", value, v[i]
                } else {
                    printf "%.1f %s", value, v[i]
                }
            }
        }' |
    sed -e ":l" \
        -e "s/\([0-9]\)\([0-9]\{3\}\)/\1,\2/; t l"
    #    └─ add thousands separator
    #       (changes "1023.2 KB" to "1,023.2 KB")
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Search history.
function qh() {
    #           ┌─ enable colors for pipe
    #           │  ("--color=auto" enables colors only if
    #           │  the output is in the terminal)
    grep --color=always "$*" "$HISTFILE" |       less -RX
    # display ANSI color escape sequences in raw form ─┘│
    #       don't clear the screen after quitting less ─┘
}
