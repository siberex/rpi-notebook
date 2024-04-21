#!/bin/bash

BASEDIR="$( cd "$(dirname "$0")" ; pwd -P )"

rsync -avz --delete "${BASEDIR}"/tacho* pi@pi:/home/pi/tacho/