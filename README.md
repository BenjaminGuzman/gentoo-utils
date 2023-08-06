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

Or... just use the `doc` use flag. It may be better 😉


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

## Bluetooth

In my installation sometimes bluetooth daemon crashes for some unknown reason
(journal says 'Read Report Reference descriptor failed: Request attribute has encountered an unlikely error').
So, my solution to make it work again is to unload the bluetooth usb kernel module and load it again:

```bash
sudo modprobe --remove btusb && sudo modprobe btusb
```

## Configurations

I've included some configurations I like in the `config` directory
