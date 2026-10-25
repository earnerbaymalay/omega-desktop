# Omega Desktop Setup

Personal, reproducible Arch Linux (EndeavourOS) workstation configuration optimized for local AI development, audio fidelity, and privacy-first network security on the Dell Latitude 7490.

---

## Architecture Overview

- **Operating System:** EndeavourOS Linux (Arch rolling 64-bit)
- **Desktop Environment:** XFCE 4.20
  - **Window Manager Theme:** `Catppuccin-Mauve-Dark`
  - **GTK Theme:** `catppuccin-mocha-mauve-standard+default`
  - **Icon Themes:** `Hatter-Purple` & Papirus
  - **Terminal:** Kitty (`~/.config/kitty/kitty.conf`) with Starship prompt
- **Display Server:** Xorg Modesetting (eDP-1 1920x1080@60.05Hz)
- **Launcher:** macOS-style full-screen application dashboard (`xfce-launcher-toggle` bound to Super via `xcape`)

---

## System Components

### 1. Panel & Widget Ecosystem
- **Top Status Bar (Panel 3):**
  - Live AI Vibe/Hand line counter (`lab lines` / `󰚩·✍`)
  - Live Security & Network Audit Shield (`lab audit` / `󰒃`)
  - Audio switch & profile monitor (`genmon-audio.sh` / `plugin-29`)
  - Local LLM Resident Status (`genmon-ollama.sh`)
  - Hardware thermals & power throttling monitor (`genmon-thermal.sh`)
- **Bottom Dock:**
  - Auto-hiding Docklike taskbar with application clusters

### 2. Audio Engineering (Hi-Fi + Bluetooth)
- **Routing Engine:** PipeWire 1.6+ and WirePlumber
- **Bluetooth Policy (`52-bluez-audio.conf`):**
  - Default to high-bitrate **A2DP SBC-XQ** (~450-550 kbps stereo)
  - Auto-switch to HSP/HFP voice headset disabled to eliminate 8 kHz voice degradation
  - Laptop internal microphone pinned for system calls and voice tools
- **DSP / Equalization:** EasyEffects background service loaded with `LoudnessCrystalEqualizer` preset
- **Control Utilities:**
  - `q1-mode [music|call|status]`: Instant Bluetooth profile toggle
  - `audio-switch`: Rofi-based interactive audio switcher

### 3. AI Engineering & Tooling
- **`lab` CLI:**
  - `lab audit`: Live compliance verification of MAC randomization, DNS-over-TLS, firewall egress, and listener stealth
  - `lab lines`: 24-hour rolling counter of vibe-coded vs. hand-coded lines across transcripts
  - `lab status`: Rich terminal command center dashboard
- **Local LLMs:**
  - Local Ollama running `qwen2.5-coder`, `llama3.2`, `dolphin-mistral`, `nous-hermes2`
  - CLI shortcuts: `ask-qwen`, `ask-llama`, `ask-ollama`
- **Agent Orchestration:**
  - Antigravity CLI (`agy`) & Claude Code
  - Centralized knowledge vault in Obsidian (`OBSIDIAN_AI_VAULT`)

### 4. Privacy & Network Hardening
- **MAC Randomization:** Enforced on scanning and per-connection session
- **DNS:** Quad9 (`9.9.9.9`, `149.112.112.112`) via DNS-over-TLS (DoT port 853) through `systemd-resolved`
- **Firewall:** Default inbound DROP with strict egress policy; mDNS/Avahi broadcast disabled
- **RF Monitoring:** Dedicated `wlan0` interface for wireless monitoring (`wavescope`, `bettercap`)

---

## Installation & Sync

### Idempotent Install
```bash
git clone user@example.com:earnerbaymalay/omega-desktop.git ~/omega-desktop
cd ~/omega-desktop
./install.sh
```

### Automated Snapshots
Configurations are allowlisted via `manifest.txt`. Private keys, tokens, and hardware MACs are scrubbed on copy via `~/.config/omega/redact.tsv` and verified by a leak gate prior to commit.

```bash
# Trigger a manual snapshot
~/omega-desktop/bin/omega-snapshot "update: tuned wireplumber buffer latency"

# Launch terminal guide
~/omega-desktop/bin/omega-guide
```
