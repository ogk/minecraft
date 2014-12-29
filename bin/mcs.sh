#!/bin/bash

#===========================================================
# Deklarasjon av variable + evt. debug
#===========================================================

[[ -n "$DEBUG" ]] && set -x # turn -x on if DEBUG is set to a non-empty string
[[ -n "$NOEXEC" ]] && set -n # turn -n on if NOEXEC is set to a non-empty string
#set -o nounset # Feiler hvis man prøver å bruke en uinitialisert variabel
#set -o errexit # Avslutter umiddelbart hvis et statement returnerer false


#===========================================================
# Deklarasjon av funksjoner
#===========================================================


Create() {
    local name=$1
    [[ -z "$name" ]] && Fail "Navn på verden må angis"
    mkdir -p ~/minecraft/
    cp -rp ~/minecraft/skel ~/minecraft/worlds/$name || Fail "Kopiering av skel til verden $name feilet!"
}

Fail() {
    echo "$1"
    exit 1
}

Log() {
    local name=$1
    [[ -z "$name" ]] && Fail "Navn på verden må angis"
    less +G ~/minecraft/worlds/$name/logs/server.log || Fail "Fant ikke loggfil under $name"
}


Status() {
    local pid=$(pgrep -f '^java.*minecraft.jar')
    if [[ -n "$pid" ]]; then
        echo "Minecraft server er oppe på pid $pid."
        exit 0
    else
        echo "Ingen Minecraft server funnet."
        exit 1
    fi
}

Start() {
    local name=$1
    [[ -z "$name" ]] && Fail "Navn på verden må angis"
    cd ~/minecraft/worlds/$name || Fail "Kunne ikke bytte til katalog ~/minecraft/worlds/$name"
    nohup java -Xmx1G -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalPacing -XX:+AggressiveOpts -jar ./minecraft.jar nogui >> logs/server.log 2>&1 &
}

Stop() {
    echo "Killing $(pgrep -f '^java.*minecraft.jar')"
    pkill -uminecraft -f "^java.*minecraft_server.jar"
}

Usage() {
    echo "Usage:"
     echo "$(basename $0) <create|status|start|stop>"
}

[[ ! -d ~/minecraft/skel ]] && Fail "Dette git-repoet må klones under din hjemmekatalog, dvs. navngis '~/minecraft'. Avslutter."

CMD=$1
shift

case "$CMD" in
    create)
        Create $* ;;
    log)
        Log $* ;;
    start)
        Start $* ;;
    status)
        Status ;;
    stop)
        Stop ;;
    *)
        Usage ;;
esac
