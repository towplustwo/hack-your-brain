#!/bin/bash

# 🧠 Terminal Brain Hack Prank Script (Final Version with Fixed Logging)
SEEN_LIST=".shown_media.log"
CURRENT_MEDIA=""
FEH_PID=""
MPV_PID=""
CMATRIX_PID=""

# Handle program interruptions (e.g., Ctrl+C)
trap "cleanup_and_exit" INT

# Cleanup function to terminate background processes and log media
cleanup_and_exit() {
  echo -e "\n\e[31m⚠️ Interrupt detected! Cleaning up...\e[0m"
  
  # Kill background processes if they exist
  [[ -n "$FEH_PID" ]] && kill "$FEH_PID" 2>/dev/null
  [[ -n "$MPV_PID" ]] && kill "$MPV_PID" 2>/dev/null
  [[ -n "$CMATRIX_PID" ]] && kill "$CMATRIX_PID" 2>/dev/null
  
  # Log the current media if it is set
  if [[ -n "$CURRENT_MEDIA" ]]; then
    echo "$CURRENT_MEDIA" >> "$SEEN_LIST"
    echo -e "\e[36m✔️ Logged current media: $CURRENT_MEDIA\e[0m"
  fi
  
  # Deduplicate the seen list
  sort -u "$SEEN_LIST" -o "$SEEN_LIST"
  
  exit
}

# Simulates typing out text
type_out() {
  local text="$1"
  for ((i = 0; i < ${#text}; i++)); do
    echo -n "${text:$i:1}"
    sleep 0.02
  done
  echo
}

# Play sound
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

# NEUDALINK Logo
neuralink_logo() {
  echo -e "\e[36m
       ███╗   ██╗███████╗██╗   ██╗██████╗  █████╗ ██╗     ██╗███╗   ██╗██╗  ██╗
       ████╗  ██║██╔════╝██║   ██║██╔══██╗██╔══██╗██║     ██║████╗  ██║██║ ██╔╝
       ██╔██╗ ██║█████╗  ██║   ██║██║  ██║███████║██║     ██║██╔██╗ ██║█████╔╝
       ██║╚██╗██║██╔══╝  ██║   ██║██║  ██║██╔══██║██║     ██║██║╚██╗██║██╔═██╗
       ██║ ╚████║███████╗╚██████╔╝██████╔╝██║  ██║███████╗██║██║ ╚████║██║  ██╗
       ╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝
  \e[0m"
}

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

# Reset seen list if requested
if [[ "$1" == "--reset" ]]; then
  > "$SEEN_LIST"
  echo -e "\e[36m🔁 Seen media list reset!\e[0m"
  exit 0
fi

# Count and display media stats if requested
if [[ "$1" == "--logged" ]]; then
  BASEDIR="brain_images"
  ALL_MEDIA=()
  LOGGED_MEDIA=()

  # Collect all media files across all categories
  for category in "${CATEGORY_MAP[@]}"; do
    CATEGORY_PATH="$BASEDIR/$category"
    if [[ -d "$CATEGORY_PATH" ]]; then
      mapfile -t CATEGORY_FILES < <(find "$CATEGORY_PATH" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.mp4" -o -iname "*.webm" \))
      ALL_MEDIA+=("${CATEGORY_FILES[@]}")
    fi
  done

  # Ensure the seen list file exists
  touch "$SEEN_LIST"
  mapfile -t LOGGED_MEDIA < <(sort -u "$SEEN_LIST") # Remove duplicates

  # Calculate totals
  TOTAL_MEDIA=${#ALL_MEDIA[@]}
  TOTAL_LOGGED=${#LOGGED_MEDIA[@]}
  TOTAL_UNLOGGED=$((TOTAL_MEDIA - TOTAL_LOGGED))

  # Output the stats
  echo -e "\e[36m📊 Media Statistics:\e[0m"
  echo -e "\e[32m  Total Media: $TOTAL_MEDIA\e[0m"
  echo -e "\e[33m  Logged Media: $TOTAL_LOGGED\e[0m"
  echo -e "\e[31m  Unlogged Media: $TOTAL_UNLOGGED\e[0m"
  exit 0
fi

# Show image or video
show_image() {
  local input="$1"
  local media=""
  local basedir="brain_images"

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
    mapfile -t logged_media < <(sort -u "$SEEN_LIST") # Remove duplicates

    local unseen_media=()
    for media_path in "${all_media[@]}"; do
      if [[ ! " ${logged_media[*]} " =~ " ${media_path} " ]]; then
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
    fi
  fi

  # Log media immediately after selection
  CURRENT_MEDIA="$media"
  echo "$CURRENT_MEDIA" >> "$SEEN_LIST"

  local ext="${media##*.}"
  local ext_lower
  ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

  if [[ "$ext_lower" =~ ^(jpg|jpeg|png)$ ]]; then
    if command -v feh &>/dev/null; then
      feh -F --auto-zoom "$media" &
      FEH_PID=$!
      sleep 20
      kill "$FEH_PID" 2>/dev/null
    else
      echo -e "\e[31m❌ 'feh' not found!\e[0m"
    fi
  elif [[ "$ext_lower" =~ ^(gif|mp4|webm)$ ]]; then
    if command -v mpv &>/dev/null; then
      mpv --fs --loop=inf --no-terminal "$media" &
      MPV_PID=$!
      if [[ "$ext_lower" == "gif" ]]; then
        sleep 20
        kill "$MPV_PID" 2>/dev/null
      else
        wait "$MPV_PID"
      fi
    else
      echo -e "\e[31m❌ 'mpv' not found!\e[0m"
    fi
  else
    echo -e "\e[31m❌ Unsupported file type: $ext_lower\e[0m"
  fi

  echo -e "\e[32m🎥 Displaying media: $media\e[0m"
}

# Hacker log simulation
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

# Loading bar animation
loading_bar() {
  echo -ne "\e[32m🔄 LOADING "
  for _ in {1..20}; do
    echo -n "█"
    sleep 0.07
  done
  echo -e " DONE!\e[0m"
  sleep 0.5
}

# Main function
main() {
  clear
  neuralink_logo
  hacker_log
  loading_bar

  cmatrix -b -u 5 &
  CMATRIX_PID=$!

  play_sound "brain_images/hack_theme.wav" &

  sleep 5
  show_image "$1"

  sleep 15
  kill "$CMATRIX_PID" 2>/dev/null
  clear

  echo -e "\e[32m✅ Brain-hack successful! Meme extraction complete.\e[0m"
}

main "$1"
