#!/bin/bash

cd /usr/src/linux || exit 1
sudo make -j 8
sudo make modules_install
sudo make install
