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
    perl -pi -e "s/level-name=.*/level-name=$name/" ~/minecraft/worlds/$name/server.properties || Fail "Kunne ikke endre servernavn!"
    echo "Verden $name opprettet."
}

Delete() {
    local name=$1
    [[ -z "$name" ]] && Fail "Navn på verden må angis"
    printf "Er du HELT sikker på at du vil slette $name? (j/n): "
    read svar
    [[ "$svar" != j ]] && Fail "Avbryter."
    rm -r ~/minecraft/worlds/$name || Fail "Sletting av verden $name feilet!"
    echo "Verden $name slettet."
}

Edit() {
    local name=$1
    [[ -z "$name" ]] && Fail "Navn på verden må angis"
    echo "Trykk ENTER for å åpne server.properties i en editor. Vennligst behold \"level-name\" uendret, så det matcher katalognavnet."
    read svar
    ${EDITOR:-vi} ~/minecraft/worlds/$name/server.properties || Fail "Kunne ikke åpne server.properties under $name for redigering."
}

Fail() {
    echo "$1"
    exit 1
}

List() {
    ls ~/minecraft/worlds || Fail "Fant ikke worlds-katalog"
}

Log() {
    local name=$1
    [[ -z "$name" ]] && Fail "Navn på verden må angis"
    less +G ~/minecraft/worlds/$name/logs/server.log || Fail "Fant ikke loggfil under $name"
}

Status() {
    local pid=$(pgrep -f '^java.*minecraft.jar')
    if [[ -n "$pid" ]]; then
        echo "Minecraft server er oppe på pid $pid, verden $(basename $(readlink -f /proc/$pid/cwd))."
        exit 0
    else
        echo "Ingen kjørende Minecraft server funnet."
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
    local pid=$(pgrep -f '^java.*minecraft.jar')
    echo "Killing $pid"
    kill $pid
}

Usage() {
    echo "Usage:"
    echo "$(basename $0) <create|delete|list|log|status|start|stop>"
    echo "Git-repoet må klones slik at det ligger i din hjemmekatalog og heter \"minecraft\"."
    echo "Det kan opprette og slette verdener, starte, stoppe verdener, og vise status og loggen til kjørende verden."
    echo "Du må manuelt redigere server.properties for å endre "
    echo "Støtter bare én instans pr. maskin nå."
}

[[ ! -d ~/minecraft/skel ]] && Fail "Dette git-repoet må klones under din hjemmekatalog, dvs. navngis '~/minecraft'. Avslutter."

CMD=$1
shift

case "$CMD" in
    create)
        Create $* ;;
    delete)
        Delete $* ;;
    edit)
        Edit $* ;;
    list)
        List ;;
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
