#!/bin/bash

# default configuration values
INSTALLATION_DIR="$HOME/bin"
SOFT_LINKS=0

# colors
WHITE_BRIGHT="\033[97m"
WHITE_BOLD="\033[97;1m"
BLUE_BOLD="\033[94;1m"
CYAN_UNDERLINE="\033[96;4m"
YELLOW="\033[33m"
RED="\033[91m"
GREEN="\033[92m"
RESET="\033[0m"
BOLD="\033[1m"

function help {
	echo "Install helper tools to the installation directory"
	echo
	echo -en "$WHITE_BOLD"
	echo -e "Usage:$RESET $BLUE_BOLD$0$RESET [$YELLOW-s$RESET|$YELLOW-h$RESET] [$CYAN_UNDERLINE<installation dir>$RESET]"
	echo -en "$WHITE_BOLD"
	echo -e "Options:$RESET"
	echo -e "  $YELLOW-s$RESET:     Use soft links (symlinks) instead of hard links"
	echo -e "  $YELLOW-h$RESET:     Print this message and exit"
	echo
	echo -e "Default installation dir: $WHITE_BRIGHT$INSTALLATION_DIR$RESET"
}

function link_cmd {
	cmd_name="$1"
	link_name="$2"
	cwd=$(pwd)

	ln_exit_code=0

	echo -e -n "\t$link_name -> $cwd/$cmd_name... "
	if [[ "$SOFT_LINKS" -eq "1" ]]; then
		ln -s "$cwd/$cmd_name" "$INSTALLATION_DIR/$link_name"
		ln_exit_code="$?"
	else
		ln "$cwd/$cmd_name" "$INSTALLATION_DIR/$link_name"
		ln_exit_code="$?"
	fi

	print_status "$ln_exit_code"
}

function print_status {
	status_code="$1"

	if [[ "$status_code" -eq "0" ]]; then
		echo -en "$GREEN"
		echo Success.
		echo -en "$RESET"
	else
		echo -en "$RED"
		echo Failed.
		echo -en "$RESET"
	fi
}

while getopts "sh" opt; do
	case $opt in
		h)
			help
			exit 0
			;;
		s)
			SOFT_LINKS=1
			;;
		\?|\*)
			echo "$opt is not recognized and therefore ignored"
			;;
	esac
done

if [[ "$SOFT_LINKS" -eq "1" ]]; then
	echo -en "$YELLOW"
	echo -e "[NOTE]: Using$BOLD soft$RESET$YELLOW links$RESET"
else
	echo -en "$YELLOW"
	echo -e "[NOTE]: Using$BOLD hard$RESET$YELLOW links$RESET"
fi

if [[ -n "$1" && "$1" != "-s" ]]; then # -s option is not given or is given as 2nd argument
	INSTALLATION_DIR="$1"
elif [[ "$1" == "-s" && -n "$2" ]]; then # -s option is the first argument, 2nd arg is the installation dir
	INSTALLATION_DIR="$2"
fi

echo -en "Ensuring directory $WHITE_BRIGHT$INSTALLATION_DIR$RESET exists... "
mkdir -p "$INSTALLATION_DIR" || exit 1
print_status "$?"

# check if waitproc binary exist and if not, compile it
if [[ ! -x "waitproc/waitproc" ]]; then
	echo -en "$YELLOW"
	echo "waitproc binary doesn't exist"
	echo -en "$RESET"
	echo "Trying to compile it..."
	go build -o waitproc/waitproc waitproc/waitproc.go && echo Sucessfully built waitproc binary && cd ..
fi

if [[ "$SOFT_LINKS" -eq "1" ]]; then
	echo "Creating symlinks for:"
else
	echo "Creating hard links for:"
fi

link_cmd waitproc/waitproc waitproc
link_cmd maintenance.sh maint
