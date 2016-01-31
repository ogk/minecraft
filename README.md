# MCS

A small script in Norwegian for administering a minecraft instance on a linux server, meant for private use.
(I know about  http://msmhq.com/, but thought it too big and complex to be able to hack it myself.)

This lets you choose between multiple saved worlds, but can only start one instance at a time.

Contains the admin script, the server jar and some skeleton files to start a new world.

A LOT is missing, definitely a work in progress.

# Setup

I recommend to create a dedicated user on your machine called "minecraft" or similar.
Also - use `screen` when using this script, so you can reconnect later.

Clone the repo into the users home dir. It will create a directory `~/minecraft/`.

I would also recommend to add the `bin` directory to your PATH, or make an alias to run mcs script, eg.

`alias mcs='~/minecraft/bin/mcs.sh'`

## Dependencies
* bash
* screen

# Usage

Below I will assume you use an alias `mcs`to start the script .

## Help

`mcs -h` - will list the options with a short description - in Norwegian!

# TODOs

* translate to English
* use screen for running the server
* download the jar instead of having it in the repo (while I initially developed this, I could not find a consistent URL to use)
* add option to run backup
* add bash completion
* add install-function (for PATH or alias, bash completion, possibly cron-backup)
