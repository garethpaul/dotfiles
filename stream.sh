#!/bin/bash

# Set the input MP4 file path
input_file="$1"

# Set the output RTMP URL
output_rtmp_url="$2"

# Set the initial start time to 00:00:00
start_time="00:00:00"

# Function to gracefully stop the script
stop_script() {
  echo "Stopping the script..."
  kill $ffmpeg_pid
  exit 0
}

# Register the signal handler
trap stop_script SIGINT SIGTERM

# Check if the input file exists
if [ ! -f "$input_file" ]; then
  echo "Input file not found: $input_file"
  exit 1
fi

while true; do
  # Start FFmpeg with the specified start time and settings
  if ffmpeg -re -ss "$start_time" -i "$input_file" \
    -c:v libx264 -preset fast -r 30 -g 60 -b:v 3500k \
    -s 1280x720 -aspect 16:9 -maxrate 6000k -bufsize 6000k -pix_fmt yuv420p \
    -c:a aac -b:a 128k -ar 48000 -f flv "$output_rtmp_url"; then

    echo "$(date) - FFmpeg exited normally. Stream ended."
    break
  else
    ffmpeg_exit_code=$?

    # FFmpeg exited with an error, update the start time
    if [ "$start_time" == "00:00:00" ]; then
      start_time="00:00:10"
    else
      # Extract hours, minutes, and seconds from the start time
      IFS=':' read -ra time_parts <<< "$start_time"
      hours=${time_parts[0]}
      minutes=${time_parts[1]}
      seconds=${time_parts[2]}

      # Increment the start time by 10 seconds
      seconds=$((seconds + 10))
      if [ $seconds -ge 60 ]; then
        seconds=$((seconds - 60))
        minutes=$((minutes + 1))
      fi
      if [ $minutes -ge 60 ]; then
        minutes=$((minutes - 60))
        hours=$((hours + 1))
      fi

      # Format the updated start time
      start_time=$(printf "%02d:%02d:%02d" $hours $minutes $seconds)
    fi

    echo "$(date) - FFmpeg exited with code $ffmpeg_exit_code. Restarting stream from $start_time..."
    sleep 2
  fi
done
