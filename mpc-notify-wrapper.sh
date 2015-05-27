#!/usr/bin/env bash
icon=/usr/share/icons/Numix-Circle/scalable/apps/sonata.svg

mpc $1

case $1 in
    play|pause|next|prev|toggle)
        notification=$(cat <(mpc | sed '2!d' | awk '{print $1}') <(mpc | head -n1) | sed 'N;s/\n/ /') &> /dev/null
        notify-send -i $icon "mpc $1" "$notification"
        ;;
    stop) notify-send -i $icon "mpc $1" "MPD stream stopped" ;;
esac
