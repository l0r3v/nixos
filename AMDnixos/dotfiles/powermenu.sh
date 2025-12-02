#!/bin/bash

CHOICE=$(echo -e "⏻ shutdown\n reboot\n suspend\n hibernate\n logout" | \
         rofi -dmenu -p "Power Menu:" \
              -font "FiraCode Nerd Font 12")

confirm() {
    CONFIRM=$(echo -e "No\nYes" | rofi -dmenu -p "Are you sure?" -font "FiraCode Nerd Font 12")
    [[ "$CONFIRM" == "Yes" ]]
}

case $CHOICE in
    "⏻ shutdown")
        if confirm; then
            systemctl poweroff
        fi
        ;;
    " reboot")
        if confirm; then
            systemctl reboot
        fi
        ;;
    " suspend")
        systemctl suspend
        ;;
    " hibernate")
        systemctl hibernate
        ;;
    " logout")
        hyprctl dispatch exit
        ;;
    *)
        exit 0
        ;;
esac
