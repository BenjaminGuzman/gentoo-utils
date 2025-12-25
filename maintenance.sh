#!/usr/bin/bash

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

function print_update_cmd_help {
	echo -e "Remember you can exclude packages from update with $WHITE_BOLD--exclude$RESET flag"
	echo Example:
	echo -e "$WHITE_BOLD sudo emerge --ask --verbose --update --deep --changed-use @world --exclude=\"www-client/firefox www-client/chromium\"$RESET"
	echo
	echo Also remember you can configure the builds to use all computing power.
	echo If most of the packages are small, you can build packages concurrently,
	echo i.e., while you have package A compiling, you can have package B being downloaded.
	echo Example:
	echo -e "$WHITE_BOLD sudo MAKEOPTS=\"-j$(( $(nproc) / 2 ))\" emerge --ask --jobs=2 --load-average=$(nproc) --verbose --update --deep --changed-use @world $RESET"
}

function help {
	echo -e "$WHITE_BRIGHT Compilation of maintenance commands for Gentoo systems$RESET"
	echo
	echo -e "$WHITE_BRIGHT Usage:$RESET $BLUE_BOLD$0$RESET $YELLOW<action>$YELLOW [$YELLOW<action>$YELLOW...]"
	echo
	echo -e "$WHITE_BOLD Actions:$RESET"
	echo -e "  $YELLOW update$RESET     Sync packages and update the system"
	echo -e "  $YELLOW clean$RESET      Clean journal logs and portage distfiles and packages"
	echo
	echo "Executed commands will be interactive (will ask for confirmation)"
	echo
	print_update_cmd_help
}

function update {
	tmpfile=$(mktemp)

	# Update package metadata (version available, dependencies...)
	echo Syncing packages...
	echo -e " (a copy of this command logs will be stored in $WHITE_BOLD$tmpfile$RESET)"
	sudo emaint --allrepos sync | tee "$tmpfile"

	update_portage=$(more "$tmpfile" | grep --ignore-case "An update to portage is available" --count)
	if [[ "$update_portage" -gt "0" ]]; then # should update portage first
		# extract the suggested command to run
		awk_extract_portage_cmd="match(\$0, /To update portage,? run '(.*)'/, a) {print a[1]}"
		update_portage_cmd=$(awk "$awk_extract_portage_cmd" "$tmpfile")
		update_portage_cmd="sudo $update_portage_cmd"

		echo "Updating portage with '$update_portage_cmd'..."
		sh -c "$update_portage_cmd"
	fi

	# download updated packages and compile
	echo Downloading and compiling packages...
	echo -e " (a copy of this command logs will be stored in $WHITE_BOLD$tmpfile$RESET)"
	sudo emerge --ask --verbose --update --deep --changed-use @world | tee "$tmpfile"

	print_update_cmd_help
}

function clean {
	echo -e "Clean logs older than \033[92m<amount>\033[0m/\033[91mn\033[97m \033[0m"
	echo "<amount> examples: 1months, 2w (2 weeks), 3h (3 hours). See manual for journalctl"
	echo -n "Default: 1months. Answer: "
	read -r ans
	if [[ "$ans" == "" ]]; then
		ans="1months"
	fi

	if [[ "$ans" == "n" || "$ans" == "N" ]]; then
		echo "Won't clean logs"
	else
		sudo journalctl --vacuum-time="$ans"
	fi

	echo Cleaning distfiles...
	sudo eclean --interactive distfiles

	echo Cleaning packages...
	sudo eclean --interactive packages

	echo -e "$WHITE_BOLD Tip$RESET: Remove user cache (rm -rf ~/.cache) and clean kernel (eclean-kernel)"
}

if [[ "$#" -lt "1" ]]; then
	echo -e "\033[91mYou must provide an action\033[0m"
	help
	exit 1
fi

for arg in "$@"; do
	case $arg in
		update)
			echo -e "\033[94m*** Updating the system ***\033[0m"
			update
			;;
		clean)
			echo -e "\033[94m*** Cleaning the system ***\033[0m"
			clean
			;;
		-h)
			help
			;;
		*)
			echo "Argument $arg was not recognized"
			help
			;;
	esac
done
