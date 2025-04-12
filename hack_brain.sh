#!/bin/bash

# 🧠 Terminal Brain Hack Prank Script (WSL Edition v0.5 - Media Logging Mode!)
SEEN_LIST=".shown_media.log"

# Reset seen list if requested
if [[ "$1" == "--reset" ]]; then
  rm -f "$SEEN_LIST"
  echo -e "\e[36m🔁 Seen media list reset!\e[0m"
  exit 0
fi

echo -e "\e[35m🧪 Arg 1 received: '$1'\e[0m"

declare -A CATEGORY_MAP=(
  [1]="1_animal_faces"
  [2]="2_wholesome_memes"
  [3]="3_weird_stuff"
  [4]="4_giga_chad"
  [5]="5_classic_memes"
  [6]="6_hot"
  [7]="7_cute"
  [8]="8_love_them"
  [9]="9_prankster"
  [10]="10_surprise_me"
)

type_out() {
  local text="$1"
  for ((i = 0; i < ${#text}; i++)); do
    echo -n "${text:$i:1}"
    sleep 0.02
  done
  echo
}

play_sound() {
  local sound_file="$1"
  if [[ -f "$sound_file" ]]; then
    local sound_path
    sound_path=$(wslpath -w "$sound_file")
    powershell.exe -c "(New-Object Media.SoundPlayer '$sound_path').PlaySync();"
  else
    echo -e "\e[31m❌ Sound file '$sound_file' not found!\e[0m"
  fi
}

show_image() {
  local input="$1"
  local media=""
  local basedir="brain_images"
  local log_media="true"

  if [[ "$input" =~ ^[0-9]+$ ]]; then
    local category="${CATEGORY_MAP[$input]}"
    if [[ -z "$category" ]]; then
      echo -e "\e[33m⚠️ Invalid category number. Choosing random...\e[0m"
      category=$(shuf -n1 -e "${CATEGORY_MAP[@]}")
    fi
    local folder="$basedir/$category"
    echo -e "\e[36m📁 Using category folder: $folder\e[0m"

    local all_media=()
    mapfile -t all_media < <(find "$folder" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.mp4" -o -iname "*.webm" \))

    touch "$SEEN_LIST"
    local unseen_media=()
    for media_path in "${all_media[@]}"; do
      if ! grep -Fxq "$media_path" "$SEEN_LIST"; then
        unseen_media+=("$media_path")
      fi
    done

    if [[ ${#unseen_media[@]} -eq 0 ]]; then
      echo -e "\e[33m🔄 All media shown. Resetting list...\e[0m"
      > "$SEEN_LIST"
      unseen_media=("${all_media[@]}")
    fi

    media=$(printf "%s\n" "${unseen_media[@]}" | shuf -n1)

  else
    log_media="false"
    echo -e "\e[34m🔍 Searching for file: $input.*\e[0m"
    for ext in jpg jpeg png gif mp4 webm; do
      local file="$basedir/${input}.${ext}"
      if [[ -f "$file" ]]; then
        media="$file"
        echo -e "\e[32m✅ Found: $media\e[0m"
        break
      fi
    done

    if [[ -z "$media" ]]; then
      echo -e "\e[33m📸 No specific media found. Picking random...\e[0m"
      local all_files
      mapfile -t all_files < <(find "$basedir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.mp4" -o -iname "*.webm" \))
      media=$(printf "%s\n" "${all_files[@]}" | shuf -n1)
      log_media="true"
      echo -e "\e[36m🎲 Random media: $media\e[0m"
    fi
  fi

  # Log media if appropriate
  if [[ "$log_media" == "true" ]]; then
    echo "$media" >> "$SEEN_LIST"
  fi

  local ext="${media##*.}"
  local ext_lower
  ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

  if [[ "$ext_lower" =~ ^(jpg|jpeg|png)$ ]]; then
    if command -v feh &>/dev/null; then
      feh -F --auto-zoom "$media" &
    else
      echo -e "\e[31m❌ 'feh' not found!\e[0m"
    fi
  elif [[ "$ext_lower" =~ ^(gif|mp4|webm)$ ]]; then
    if command -v mpv &>/dev/null; then
      mpv --fs --loop=inf --no-terminal "$media" &
    else
      echo -e "\e[31m❌ 'mpv' not found!\e[0m"
    fi
  else
    echo -e "\e[31m❌ Unsupported file type: $ext_lower\e[0m"
  fi

  FEH_PID=$!
}

hacker_log() {
  echo -ne "\e[32m"
  type_out "[LOG] Accessing neuron map..."
  type_out "[LOG] Establishing neural uplink..."
  type_out "[INFO] Synaptic pulse synchronization in progress..."
  type_out "[TRACE] Cortex activity: 94% match with Subject-X..."
  type_out "[WARN] Hippocampus interference detected..."
  type_out "[PASSCODE] 🧬 BRAIN_ID: 0x420-69-Neuron.exe"
  type_out "[✔] Brain-sync protocol accepted."
  type_out "[INPUT] Enter your name to proceed with neural sync: \c"
  read -r USERNAME
  type_out "[!] Hello, $USERNAME. We are inside your mind now."
  type_out "[!] Loading memes into long-term memory..."
  type_out "[HINT] You probably shouldn't have clicked that."
  type_out "[💀] Detected: One questionable taste in memes."
  type_out "[WARNING] You are not alone in this terminal."
  type_out "[🧠] Injecting chaos... please stand by."

  for stage in "█▒▒▒▒▒▒▒▒" "███▒▒▒▒▒▒" "█████▒▒▒▒" "███████▒▒" "█████████"; do
    echo -ne "\e[32mDecrypting: $stage\r"
    sleep 0.2
  done
  echo -e "\e[0m"
}

loading_bar() {
  echo -ne "\e[32m🔄 LOADING "
  for _ in {1..20}; do
    echo -n "█"
    sleep 0.07
  done
  echo -e " DONE!\e[0m"
  sleep 0.5
}

main() {
  clear
  hacker_log
  loading_bar

  cmatrix -b -u 5 &
  CMATRIX_PID=$!

  play_sound "brain_images/hack_theme.wav" &

  sleep 5
  show_image "$1"

  sleep 15
  kill "$CMATRIX_PID" 2>/dev/null
  kill "$FEH_PID" 2>/dev/null
  clear

  echo -e "\e[32m✅ Brain-hack successful! Meme extraction complete.\e[0m"
}

main "$1"
