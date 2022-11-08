## Portage

Update portage metadata

```
emerge --sync
```

Fresh installation useful commands

```
# install useful tools
emerge --ask app-editors/neovim sys-process/htop

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
```
# Install XOrg (follow Gentoo manual)
emerge --ask x11-base/xorg-server

# Install all the KDE plasma stuff
emerge --ask kde-plasma/plasma-meta
```

Disable useless (for some workstations) services

```
systemctl disable sshd
```

Sometimes you may want to keep (WHOLE) source files and this may come handy

```
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


Remember to create the symlink `var/src/linux` to point to the actual kernel version `/var/src/<actual kernel version>`.
Otherwise some packages may have (minor?) trouble when compiling
