# Gentoo utils

Compilation of notes/scripts I use for my Gentoo installation

## Notes

[notes.md](./notes.md): Useful notes and commands 

## Scripts

- [waitproc](./waitproc): Useful to wait for a process to finish and then execute a command, e.g. when you forgot to add `&& do-something` to a command that takes a lot of time like `emerge --ask www-client/chromium`

- [upgrade](./upgrade): Sync repositories and update them (download and compile)

- [upgrade-kernel](./upgrade-kernel): TODO (not yet implemented). Upgrade your kernel. It also handles kernel config backup.

- [install-tools.sh](./install-tools.sh): Install the above tools inside ~/bin and update your PATH
