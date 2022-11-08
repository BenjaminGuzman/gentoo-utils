#!/bin/bash
# Update package metadata (version available, dependencies...)
echo Syncing packages...
sudo emaint --allrepos sync

# download updated packages and compile
echo Downloading and compiling packages...
sudo emerge --ask --verbose --update --deep --changed-use @world

