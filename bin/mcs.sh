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


Backup() {
    local name=$1
    [[ -z "$name" ]] && Fail "Navn på verden må angis"
    local timestamp=$(date -Iseconds)
    Status && Fail "Verden må være stoppet."

    # Ta backup
    cp -rp ~/minecraft/worlds/$name ~/minecraft/worlds/$name-${timestamp}
    if [[ $? -eq 0 ]] ; then
        echo "Backup tatt OK til katalog ~/minecraft/worlds/$timestamp"
        exit 0
    else
        echo "Noe gikk galt under backup-kjøring! Sjekk manuelt i katalogen ~/minecraft/worlds"
        exit 1
    fi
}

Create() {
    local name=$1
    [[ -z "$name" ]] && Fail "Navn på verden må angis"
    mkdir -p ~/minecraft/
    cp -rp ~/minecraft/skel ~/minecraft/worlds/$name || Fail "Kopiering av skel til verden $name feilet!"
    perl -pi -e "s/level-name=.*/level-name=$name/" ~/minecraft/worlds/$name/server.properties || Fail "Kunne ikke endre servernavn!"
    echo "Verden $name opprettet."
    echo "Bruk edit-kommandoen for å redigere server.properties før du starter."
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

GetPid() {
    pgrep -f '^java.*minecraft.jar'
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
    local pid=$(GetPid)
    if [[ -n "$pid" ]]; then
        echo "Minecraft server er oppe på pid $pid, verden $(basename $(readlink -f /proc/$pid/cwd))."
        return 0
    else
        echo "Ingen kjørende Minecraft server funnet."
        return 1
    fi
}

Start() {
    local name=$1
    [[ -z "$name" ]] && Fail "Navn på verden må angis"
    cd ~/minecraft/worlds/$name || Fail "Kunne ikke bytte til katalog ~/minecraft/worlds/$name"
    local pid=$(GetPid)
    if [[ -z "$pid" ]] ; then
        nohup java -Xmx1G -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalPacing -XX:+AggressiveOpts -jar ./minecraft.jar nogui >> logs/server.log 2>&1 &
        echo "Minecraft server starter på pid $(GetPid). Bruk \"status\" og \"log\" for å sjekke status."
        exit 0
    else
        echo "En verden kjører allerede på pid $pid. Avsluter uten å starte."
        exit 1
    fi
}

Stop() {
    local pid=$(pgrep -f '^java.*minecraft.jar')
    echo "Killing $pid"
    kill $pid
}

Usage() {
    echo "SYNOPSIS"
    echo "    $(basename $0) <create|delete|edit|list|log|status|start|stop>"
    echo
    echo "PARAMETRE"
    echo "    $(basename $0) backup <navn>"
    echo "        Copies a world directory into a new timestamped directory."
    echo "        All worlds must be stopped."
    echo "    $(basename $0) create <navn>"
    echo "        Oppretter en ny verden. NAvn må angis og kan ikke eksistere fra før."
    echo "    $(basename $0) delete <navn>"
    echo "        Sletter angitt verden. Dette kan ikke angres!"
    echo "    $(basename $0) edit <navn>"
    echo "        Lar deg redigere server.properties til angitt verden."
    echo "        For at endringene skal tre i kraft må verdenen stopper og startes."
    echo "    $(basename $0) list"
    echo "        Lister alle opprettede verdener"
    echo "    $(basename $0) log <navn>"
    echo "        Viser loggen til angitt verden"
    echo "    $(basename $0) status"
    echo "        Viser statusen til en eventuell starter server"
    echo "    $(basename $0) start <navn>"
    echo "        Starter verden med angitt navn"
    echo "    $(basename $0) stop <navn>"
    echo "        Stopper verden med angitt navn. Kan startes igjen for å fortsett der man slapp."
    echo
    echo "BRUK"
    echo "    Git-repoet må klones slik at det ligger i din hjemmekatalog og heter \"minecraft\"."
    echo "    $(basename $0) kan opprette og slette verdener, starte/stoppe verdener, og vise status"
    echo "        og loggen til kjørende verden."
    echo "    Støtter bare én instans pr. maskin nå."
}



#===========================================================
# Hovedprogram
#===========================================================

[[ ! -d ~/minecraft/skel ]] && Fail "Dette git-repoet må klones under din hjemmekatalog, dvs. navngis '~/minecraft'. Avslutter."

CMD=$1
shift

case "$CMD" in
    backup)
        Backup $* ;;
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
