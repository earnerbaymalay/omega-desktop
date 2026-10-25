#!/usr/bin/env bash
# genmon-ollama.sh - Catppuccin themed Ollama status monitor for XFCE panel

model=$(ollama ps 2>/dev/null | awk 'NR>1 {print $1}' | head -n 1)

if [ -n "$model" ]; then
    short_model="${model%%:*}"
    echo "<txt><span foreground='#cba6f7'>󰚩 $short_model</span></txt>"
    echo "<tool>Ollama Resident: $model (Click to flush/unload)</tool>"
    echo "<click>bash -c 'ollama stop \"$model\"'</click>"
else
    echo "<txt><span foreground='#6c7086'>󰚩 idle</span></txt>"
    echo "<tool>Ollama Standby (Click to pre-warm Qwen 2.5 Coder)</tool>"
    echo "<click>bash -c 'curl -s -X POST http://localhost:11434/api/generate -d '\''{\"model\": \"qwen2.5-coder:latest\"}'\'' >/dev/null &'</click>"
fi
