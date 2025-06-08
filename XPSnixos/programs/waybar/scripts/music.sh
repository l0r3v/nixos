#!/bin/bash

status=$(playerctl status 2>/dev/null)
artist=$(playerctl metadata artist 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)

# Escape caratteri per Waybar
escape() {
    echo "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g'
}

safe_artist=$(escape "$artist")
safe_title=$(escape "$title")

case "$status" in
    Playing) icon="" ;;
    Paused) icon="" ;;
    *) icon="" ;;
esac

if [ -n "$artist" ] && [ -n "$title" ]; then
    echo "{\"text\": \"$icon $safe_artist - $safe_title\", \"class\": \"visible\"}"
else
    echo "{\"text\": \"\", \"class\": \"hidden\"}"
fi
