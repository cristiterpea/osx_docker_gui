# Docker GUI on OSX, with better security (lo0 binding)
If you're looking for a way to run apps with GUI inside a docker container, on MacOS/OSX, here's one way of doing it.

https://medium.com/@cristiterpea/running-docker-gui-apps-on-osx-the-safer-way-8bbdbea2241c

---

In previous existing solutions, you were either required:
 - to bind to *:6000 (by enabling XQuartz "Allow connections from network clients" option) - opening to potential remote attacks.
 - to ssh to the docker container

---

It appears that a docker container can connect to its host, through lo0 interface - by adding an alias.

Used socat for forwarding /tmp/.X11-unix/X0 to a socket bound to port 6000 of a lo0 alias.
```
$ socat TCP-LISTEN:6000,reuseaddr,fork,bind=$ip UNIX-CLIENT:\"$SOCKET_FILE\" &
$ netstat -an | grep LISTEN
tcp4       0      0  10.254.254.254.6000    *.*                    LISTEN
```

---

## Install pre-requisites:
- XQuartz: https://www.xquartz.org
- socat: brew install socat
- Docker
- Add persistent lo0 alias: https://gist.github.com/ralphschindler/535dc5916ccbd06f53c1b0ee5a868c93 (or add a temporary alias, for testing: sudo ifconfig lo0 alias 10.254.254.254/24)


## Run example:
```
docker build -t firefox .
./run.sh
```


## Tested with:
- MacOS Sierra 10.12.3
- Docker 1.13.1 (15353)
- XQuartz 2.7.11 (xorg-server 1.18.4)


## More details:
Read run.sh and docker_osx_display_funcs.sh


## Thanks:
To Swen for the lo0 idea. (https://github.com/Photonios/qt-meetup-demo/blob/master/run.sh)
