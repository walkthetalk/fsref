#!/usr/bin/env sh

./initcmos.sh
./initmotor.sh
./initpwm.sh
./closestream.sh 0
./closestream.sh 1

#./opens1.sh 0 640 400 0 0 640 400 20 20 280 200
./openstream.sh 0 640 400 0 0 640 400 0 1 320 200

