#!/bin/bash

<<<<<<< Updated upstream
cd /usr/src/linux || exit 1
=======
cd /usr/src/linux
>>>>>>> Stashed changes
sudo make -j 8
sudo make modules_install
sudo make install
