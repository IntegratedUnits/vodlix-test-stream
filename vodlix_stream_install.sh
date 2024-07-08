#!/bin/bash

# Variables
SERVICE_NAME="vodlix_stream.service"
SCRIPT_NAME="vodlix_stream.sh"
INSTALL_DIR="/usr/local/bin"
SYSTEMD_DIR="/etc/systemd/system"
HLS_DIR="/var/www/html/stream/live_stream_%v"

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Create the HLS directory if it doesn't exist
mkdir -p $HLS_DIR

# Generate the FFmpeg command script
cat <<EOL > $SCRIPT_NAME
#!/bin/bash

ffmpeg -f lavfi -i color=color=white:s=1920x1080:r=30 -vf "drawtext=text='%{localtime\\:%Y-%m-%d %H\\:%M\\:%S %Z}':x=(w-tw)/2:y=(h-th)/2:fontsize=70:fontcolor=black, drawtext=text='ABR 360p/720p/1080p':x=(w-tw)/2:y=(h-th)/2+80:fontsize=50:fontcolor=black" -f hls -hls_time 30 -hls_list_size 5 -hls_flags delete_segments -var_stream_map "v:0 v:1 v:2" -master_pl_name master.m3u8 -c:v libx264 -b:v:0 800k -s:v:0 640x360 -b:v:1 2800k -s:v:1 1280x720 -b:v:2 5000k -s:v:2 1920x1080 -preset fast -hls_segment_filename "$HLS_DIR/segment_%03d.ts" "$HLS_DIR/stream.m3u8"
EOL

# Make the shell script executable
chmod +x $SCRIPT_NAME
mv $SCRIPT_NAME $INSTALL_DIR/

# Generate the systemd service file
cat <<EOL > $SERVICE_NAME
[Unit]
Description=Vodlix Test Stream
After=network.target

[Service]
ExecStart=$INSTALL_DIR/$SCRIPT_NAME
Restart=always
User=nobody
Group=nogroup

[Install]
WantedBy=multi-user.target
EOL

# Move the service file to the systemd directory
mv $SERVICE_NAME $SYSTEMD_DIR/

# Reload the systemd daemon
systemctl daemon-reload

# Enable the service to start on boot
systemctl enable $SERVICE_NAME

# Start the service
systemctl start $SERVICE_NAME

# Check the status of the service
systemctl status $SERVICE_NAME

echo "Installation complete. The vodlix stream service is now running."
