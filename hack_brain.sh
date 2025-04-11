#!/bin/bash

# 🧠 Terminal Brain Hack Prank Script (WSL Edition)
# Requirements: feh (or fallback: xdg-open), cmatrix, ffmpeg (.wav), PowerShell (for sound in WSL)

echo -e "\e[35m🧪 Arg 1 received: '$1'\e[0m"

# 🎵 Function to play sound (WSL-compatible)
play_sound() {
  local SOUND_FILE="$1"
  if [ -f "$SOUND_FILE" ]; then
    SOUND_PATH=$(wslpath -w "$SOUND_FILE")
    powershell.exe -c "(New-Object Media.SoundPlayer '$SOUND_PATH').PlaySync();"
  else
    echo -e "\e[31m❌ Sound file '$SOUND_FILE' not found!\e[0m"
  fi
}

# 🖼️ Function to display image (specific if given, else random)
show_image() {
  local BASENAME="$1"
  local IMAGE=""
  local SEARCH_DIR="brain_images"

  if [[ -n "$BASENAME" ]]; then
    echo -e "\e[34m🔍 Searching for image: $BASENAME.*\e[0m"
    for EXT in jpg JPG jpeg JPEG png PNG; do
      FILE="$SEARCH_DIR/${BASENAME}.${EXT}"
      if [[ -f "$FILE" ]]; then
        IMAGE="$FILE"
        echo -e "\e[32m✅ Found: $IMAGE\e[0m"
        break
      fi
    done
  fi

  if [[ -z "$IMAGE" ]]; then
    echo -e "\e[33m📸 No specific image found. Picking random...\e[0m"
    IMAGE=$(find "$SEARCH_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)
    echo -e "\e[36m🎲 Random image: $IMAGE\e[0m"
  fi

  # Try feh, fallback to xdg-open, else warn
  if command -v feh >/dev/null; then
    feh -F "$IMAGE" &
  elif command -v xdg-open >/dev/null; then
    xdg-open "$IMAGE" &
  else
    echo -e "\e[31m⚠️ No image viewer found (feh/xdg-open). Cannot display: $IMAGE\e[0m"
  fi

  FEH_PID=$!
}

# 💻 Hacker-style logs (dramatic mode)
hacker_log() {
  echo -ne "\e[32m[LOG] Accessing neuron map...\e[0m"; sleep 1; echo
  echo -ne "\e[32m[LOG] Establishing neural uplink...\e[0m"; sleep 1; echo
  echo -ne "\e[32m[INFO] Synaptic pulse synchronization in progress...\e[0m"; sleep 1; echo
  echo -ne "\e[32m[TRACE] Cortex activity: 94% match with Subject-X...\e[0m"; sleep 1; echo
  echo -ne "\e[32m[WARN] Hippocampus interference detected...\e[0m"; sleep 1; echo
  echo -ne "\e[32m[PASSCODE] 🧬 BRAIN_ID: 0x420-69-Neuron.exe\e[0m"; sleep 1; echo
  echo -ne "\e[32m[✔] Brain-sync protocol accepted.\e[0m"; sleep 1; echo
  echo -ne "\e[32m[INPUT] Enter your name to proceed with neural sync:\e[0m "; read USERNAME
  sleep 1

  echo -ne "\e[32m[!] Hello, $USERNAME. We are inside your mind now.\e[0m"; sleep 1; echo
  echo -ne "\e[32m[!] Loading memes into long-term memory...\e[0m"; sleep 1; echo
  echo -ne "\e[32m[HINT] You probably shouldn't have clicked that.\e[0m"; sleep 1; echo
  echo -ne "\e[32m[💀] Detected: One questionable taste in memes.\e[0m"; sleep 1; echo
  echo -ne "\e[32m[WARNING] You are not alone in this terminal.\e[0m"; sleep 1; echo
  echo -ne "\e[32m[🧠] Injecting chaos... please stand by.\e[0m"; sleep 1; echo

  for stage in "█▒▒▒▒▒▒▒▒" "███▒▒▒▒▒▒" "█████▒▒▒▒" "███████▒▒" "█████████"; do
    echo -ne "\e[32mDecrypting: $stage\r"; sleep 0.3
  done
  echo
  echo -e "\e[0m"
}

# 🔄 Loading bar
loading_bar() {
  echo -ne "\e[32m🔄 LOADING "
  for i in {1..20}; do
    echo -n "█"
    sleep 0.1
  done
  echo -e " DONE!\e[0m"
  sleep 1
}

# 🧠 Main orchestration
main() {
  clear
  hacker_log
  loading_bar

  cmatrix -b -u 5 &
  CMATRIX_PID=$!

  play_sound "brain_images/hack_theme.wav" &

  sleep 4
  show_image "$1"

  sleep 8
  kill $CMATRIX_PID 2>/dev/null
  kill $FEH_PID 2>/dev/null
  clear

  echo -e "\e[32m✅ Brain-hack successful! Meme extraction complete.\e[0m"
}

main "$1"
