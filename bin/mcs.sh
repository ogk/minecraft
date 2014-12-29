#!/bin/bash

Fail() {
    echo "$1"
    exit 1
}

Start() {
    cd ~/minecraft/current || Fail "Kunne ikke bytte katalog"
    nohup java -Xmx512M -Xms128M -jar ~/minecraft/current/minecraft_server.jar nogui &
}

Stop() {
    echo "Killing process..."
    pkill -uminecraft -f "^java.*minecraft_server.jar"
}

Usage() {
    echo "Usage:"
     echo "$(basename $0) <start|stop>"
}

case "$1" in
    start)
        Start;;
    stop)
        Stop;;
    *)
        Usage;;
esac



