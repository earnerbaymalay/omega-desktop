#!/usr/bin/env bash
# genmon-thermal.sh - Catppuccin themed CPU temp & power monitor for XFCE panel

temp=$(sensors 2>/dev/null | awk '/Package id 0:/ {print $4}' | tr -d '+')
[ -z "$temp" ] && temp="N/A"

# Color code: green (<60), yellow (60-75), peach/red (>75)
deg=${temp%%.*}
color="#a6e3a1"
if [ "$deg" -gt 75 ] 2>/dev/null; then
    color="#f38ba8"
elif [ "$deg" -gt 60 ] 2>/dev/null; then
    color="#fab387"
fi

echo "<txt><span foreground='$color'> $temp</span></txt>"
echo "<tool>Intel i5-8350U CPU Package: $temp (Click to inspect btop)</tool>"
echo "<click>kitty -e btop</click>"
