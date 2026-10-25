#!/usr/bin/env bash
# genmon-audio.sh — Catppuccin XFCE panel widget: current output + BT codec + volume.
# Click opens ~/.local/bin/audio-switch. (Omega audio setup, 2026-10-25)
# Undo: remove the Generic Monitor from the panel, rm ~/.local/bin/genmon-audio.sh

sink=$(pactl get-default-sink 2>/dev/null)
volline=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
vol=$(awk '{printf "%d", $2*100}' <<<"$volline")
muted=""
[[ "$volline" == *MUTED* ]] && muted=" muted"
codec=$(pactl list sinks 2>/dev/null | awk -v s="Name: $sink" 'index($0,s){f=1} f&&/api.bluez5.codec/{gsub(/"/,"",$3); print $3; exit}')
eq=""
if pgrep -x easyeffects >/dev/null; then
    [[ "$(easyeffects -b 3 2>/dev/null)" == 1 ]] && eq=" EQ-off" || eq=" EQ"
fi

glyph_spk=$'\U000F04C3'   # nf-md-speaker
glyph_bt=$'\U000F00B0'    # nf-md-bluetooth_audio
glyph_mute=$'\U000F075F'  # nf-md-volume_off

case "$sink" in
    bluez_output.33_00*) name="Q1";     glyph=$glyph_bt;  color="#cba6f7" ;;
    bluez_output.F8_5C*) name="JBL";    glyph=$glyph_bt;  color="#89b4fa" ;;
    bluez_output.*)      name="BT";     glyph=$glyph_bt;  color="#89b4fa" ;;
    combine_*)           name="Multi";  glyph=$glyph_spk; color="#f9e2af" ;;
    *)                   name="Laptop"; glyph=$glyph_spk; color="#a6adc8" ;;
esac
[[ -n "$muted" ]] && { glyph=$glyph_mute; color="#f38ba8"; }

echo "<txt><span foreground='$color'>$glyph $name${codec:+ $codec} ${vol}%${muted}</span></txt>"
echo "<txtclick>$HOME/.local/bin/audio-switch</txtclick>"
echo "<tool>Output: ${sink:-none}${codec:+
Codec: $codec}
Volume: ${vol}%${muted}${eq:+
EasyEffects:$eq}
Click: switch output / connect Q1 or JBL</tool>"
