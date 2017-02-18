#!/bin/bash

source docker_osx_display_funcs.sh

docker run --rm -e DISPLAY=$DISPLAY firefox
