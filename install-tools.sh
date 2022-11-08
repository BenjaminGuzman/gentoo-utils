#!/bin/bash

function help {
	echo "Install helper tools to ~/bin and modify your PATH variable"
	echo
	echo "Syntax: $0 [-l|-h]"
	echo "Options:"
	echo " -l:	Use symlinks instead of directly copying the binaries to ~/bin"
	echo " -h:	Print this message and exit"
}

function cp_cmd {
	cmd_name="$1"
	new_cmd_name="$2"
	out_path="$HOME/bin/$new_cmd_name"

	echo -e -n "\t$cmd_name... "
	cp "$cmd_name" "$out_path"
	chmod 0744 "$out_path"
	echo Done.
}

function symlink_cmd {
	cmd_name="$1"
	link_name="$2"
	cwd=`pwd`

	echo -e -n "\t$link_name... "
	cd ~/bin
	ln -s "$cwd/$cmd_name" "$link_name"
	cd "$cwd"
	echo Done.
}

symlinks=0
while getopts "lh" opt; do
	case $opt in
		h)
			help
			exit 0
			;;
		l)
			echo [NOTE]: Using symlinks
			symlinks=1
			;;
		\?)
			echo "$option is not recognized and therefore ignored"
			;;
	esac
done

echo -n "Creating ~/bin... "
mkdir -p ~/bin
echo Done

if [[ "$symlinks" == 0 ]]; then # direct copy (don't use symlinks)
	echo "Copying binaries:"
	cp_cmd waitproc/waitproc waitproc
	cp_cmd upgrade.sh upgrade
else
	echo "Creating symlinks for:"
	symlink_cmd waitproc/waitproc waitproc
	symlink_cmd upgrade.sh upgrade
fi
