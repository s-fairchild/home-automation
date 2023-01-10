#!/bin/bash
# Mounted inside v4l2rtspserver container and executed by bash entrypoint

/usr/local/bin/v4l2rtspserver \
    -W 1280 \
    -H 720 \
    -F 30 \
    -S1 \
    -R home -U user:"${SECRET}" \
    -C1 -A48000 -aS16_LE \
    -u "${URL}" \
    /dev/video0,hw:CARD=Camera,DEV=0
