#!/bin/bash
socket="/tmp/.X11-unix"	# Path to X11 socket
ip=10.254.254.254 	# To make the alias persistent, use this: https://gist.github.com/ralphschindler/535dc5916ccbd06f53c1b0ee5a868c93
display_no=0 		# The display number. See /tmp/.X11-unix/X*

SOCKET_FILE="$socket/X$display_no"
export DISPLAY="$ip:$display_no"

function check_socket {
  if [ ! -S $SOCKET_FILE ]; then
    echo "Couldn't find socket $SOCKET_FILE. Is XQuartz running?"
    exit 1
  fi
}

function check_xquartz_props {
  if [ "$(defaults read org.macosforge.xquartz.X11 no_auth)" == "0" ]; then
    echo "Disable XQuartz option: Authenticate Connections. E.g. defaults write org.macosforge.xquartz.X11 no_auth 1"
    exit 1
  fi
  if [ "$(defaults read org.macosforge.xquartz.X11 nolisten_tcp)" == "0" ]; then
    echo "Disable XQuartz option: Allow Connections from Network Clients. E.g. defaults write org.macosforge.xquartz.X11 nolisten_tcp 1"
    exit 1
  fi
}

function check_socat {
  if ! hash socat 2>/dev/null; then
    echo "Get socat. E.g. brew install socat"
    exit 1
  fi
}

function check_ip {
  if [ -z "$(ifconfig lo0 | grep $ip)" ]; then
    echo "Add a lo0 alias. E.g. sudo ifconfig lo0 alias $ip"
    exit 1
  fi
}

function pre_docker {
  # Check if socket is available
  check_socket
  # Check for XQuartz properties
  check_xquartz_props
  # Check if socat exists
  check_socat
  # Check if ip alias is set
  check_ip

  socat TCP-LISTEN:6000,reuseaddr,fork,bind=$ip UNIX-CLIENT:\"$SOCKET_FILE\" &
  SOCAT_PID=$!

  trap post_docker EXIT # hook the post script to the exit
}

function post_docker {
  kill -9 $SOCAT_PID 2>/dev/null
}

# run the pre script
pre_docker
