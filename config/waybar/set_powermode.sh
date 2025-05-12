#!/bin/bash
modes=("performance" "balanced" "power-saver")
current_mode=$(powerprofilesctl get)
current_index=$(echo "${modes[@]}" | tr ' ' '\n' | grep -n "^$current_mode$" | cut -d ':' -f 1)
next_index=$(( (current_index % 3) ))
next_mode="${modes[$next_index]}"
powerprofilesctl set $next_mode
