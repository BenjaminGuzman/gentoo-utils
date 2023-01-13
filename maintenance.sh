function help {
	echo -e "\033[37;1mCompilation of maintenance commands for Gentoo systems\033[0m"
	echo
	echo -e "\033[37;1mUsage:\033[0m \033[34;1m$0\033[0m \033[32;1m<action>\033[0m [\033[32;1m<action>\033[0m...]"
	echo
	echo -e "\033[37;1mActions:\033[0m"
	echo -e "\033[32;1mupdate\033[0m     Sync packages and update the system"
	echo -e "\033[32;1mclean\033[0m      Clean journal logs and portage distfiles and packages"
	echo
	echo "Executed commands will be interactive (will ask for confirmation)"
}

function update {
	tmpfile=$(mktemp)

	# Update package metadata (version available, dependencies...)
	echo Syncing packages...
	sudo emaint --allrepos sync | tee "$tmpfile"

	update_portage=$(more "$tmpfile" | grep --ignore-case "An update to portage is available" --count)
	if [[ "$update_portage" -gt "0" ]]; then # should actually update portage
		# extract the suggested command to run
		update_portage_cmd=$(awk $'match($0, /To update portage, run \'(.*\)\'/, a) {print a[1]}' "$tmpfile")
		update_portage_cmd="sudo $update_portage_cmd"

		echo "Updating portage with '$update_portage_cmd'..."
		sh -c "$update_portage_cmd"
	fi

	# download updated packages and compile
	echo Downloading and compiling packages...
	sudo emerge --ask --verbose --update --deep --changed-use @world

	echo Remember you can exclude packages from update with --exclude option
	echo Example:
	echo -e "\033[37;1msudo emerge --ask --verbose --update --deep --changed-use @world --exclude=\"www-client/firefox www-client/chromium\"\033[0m"
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
		*)
			echo "Argument $arg was not recognized"
			help
			;;
	esac
done
