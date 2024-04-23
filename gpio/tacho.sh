#!/bin/bash

gcc -o tacho tacho.c -lwiringPi
WIRINGPI_DEBUG=1 ./tacho
