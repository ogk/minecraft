#!/bin/bash
java -Xmx1G -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalPacing -XX:+AggressiveOpts -jar ./minecraft.jar nogui >> logs/server.log 2>&1 &

