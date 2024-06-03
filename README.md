# Gentoo utils

Compilation of notes and scripts I use for my Gentoo installation

## Scripts

- [waitproc](./waitproc/waitproc.go): Useful to wait for a process to finish and then execute a command, e.g. when you forgot to add `&& do-something` to a command that takes a lot of time like `emerge --ask www-client/chromium`

- [maint](./maintenance.sh): Update and clean your Gentoo system

- [install-tools.sh](./install-tools.sh): Install the above tools


# Notes

--------

## Portage

Update portage metadata

```shell
emerge --sync
```

Fresh installation useful commands

```shell
# install useful tools
emerge --ask app-editors/vim sys-process/htop

# install programming languages and tools
emerge --ask dev-lang/{go,nasm,python,R} dev-java/openjdk dev-util/{valgrind} dev-vcs/{git} dev-java/maven-bin net-libs/nodejs

# install zsh (should configure it after)
emerge --ask app-shells/zsh app-shells/zsh-completions app-shells/gentoo-zsh-completions

# install firewalld and useful network tools
emerge --ask net-firewall/firewalld net-analyzer/nmap net-analyzer/wireshark

# Lock root account
sudo usermod -L --expiredate 1 root
```

Fresh installation useful commands for graphical environments
```shell
# Install XOrg (follow Gentoo manual)
emerge --ask x11-base/xorg-server

# Install all the KDE plasma stuff
emerge --ask kde-plasma/plasma-meta
```

Disable useless (for some workstations) services

```shell
systemctl disable sshd cupsd
```

Uninstall software

```shell
sudo emerge --depclean --verbose --ask <atom>
```

Sometimes you may want to keep (WHOLE) source files and this may come handy

```shell
# show the directory storing the source tar. Copy it to /var/src or whichever location you like
portageq distdir
```

Or... just use the `source` use flag. It may be better 😉


To wait for a process to finish and then execute something
(e.g. wait for compilation to finish and then shutdown)

```
tail --pid <pid> -f /dev/null && shutdown now
```

Or, you could also use the [**waitproc**](./waitproc) bash executable

## Waitproc

Pro tip: if you need to run something that requires super user privileges (e.g. `sudo something`), run waitproc with super user privileges (e.g. `sudo waitproc --pid 12345 something`), this way the child process will also have such privileges

## Kernel

Open menu config

```
cd /usr/src/linux
sudo make menuconfig
```

Recompile and install kernel

```
sudo make -j 4 && sudo make modules_install && sudo make install
```

(change `-j 4` to fit your needs)


Remember to create the symlink `var/src/linux` by using `eselect kernel list` to point to your current kernel version.
(You could also create the symlink yourself with `ln -s /var/src/linux/<version> /var/src/linux`).
Otherwise, some packages may have (minor?) trouble when compiling

### Useful links

- https://linux-hardware.org/ Helpful to find which kernel configs may work well with your hardware.

- https://www.kernelconfig.io/index.html Helpful to understand each kernel config

## Bluetooth

In my installation sometimes bluetooth daemon crashes for some unknown reason
(journal says 'Read Report Reference descriptor failed: Request attribute has encountered an unlikely error').
So, my solution to make it work again is to unload the bluetooth usb kernel module and load it again:

```bash
sudo modprobe --remove btusb && sudo modprobe btusb
```

It may also happen that bluetooth suddenly stops working after reboot (or boot).
For such cases try to cold boot your machine (i.e., shut it down and then boot it up, but do not restart)

## Configurations

I've included some configurations I like in the `config` directory

## Jetbrains products

If your system doesn't support flatpak (which is needed to install [Jetbrains Toolbox](https://www.jetbrains.com/toolbox-app/)),
then you may need to find some workarounds to how to install and use Jetbrains products.
This is the approach I took to do so:

1. Download the tool(s) as `.tar.gz` and decompress under the directory you like (e.g. `~/JetBrains`)

2. Create soft symbolic links to the shell script (e.g., `bin/goland.sh` for GoLand) and place these under your bin directory (`~/bin`). Example: `ln -s ~/JetBrains/GoLand/bin/goland.sh ~/bin/goland`

3. Add aliases to your shell, like this:

```sh
# runs the given command in the background and redirects stdout & stderr to /dev/null 
function run_muted_in_background() {
  cmd="$1"
  bash -c "$cmd > /dev/null 2>&1 &"
}

alias goland="run_muted_in_background goland"
alias clion="run_muted_in_background clion"
alias idea="run_muted_in_background idea"
```

In theory, after you've completed step 2, you can start the tool from a shell but it will be blocked and will show you all the logs, thus making that shell session "unusable". To avoid so, follow step 3.
