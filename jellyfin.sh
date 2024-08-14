#!/bin/bash
set -x #echo on

#Tools required
sudo cp /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d/
sudo ln -s /usr/local/bin/jellyfin-setup.sh /config/jellyfin-setup.sh
sudo apt update
sudo apt install -y psmisc wget curl nano geany transmission

# Download, extract jellyfin
wget -O jellyfin.tar.gz https://repo.jellyfin.org/files/server/linux/stable/v10.9.9/arm64/jellyfin_10.9.9-arm64.tar.gz
# wget -O jellyfin.tar.gz https://repo.jellyfin.org/files/server/linux/stable/10.8.13/arm64/jellyfin_10.8.13_arm64.tar.gz
sudo mkdir -p /opt/jellyfin
sudo rm -rf /opt/jellyfin/*
sudo tar xvzf jellyfin.tar.gz --strip 1 -C /opt/jellyfin
rm jellyfin.tar.gz

# Setup jellyfin apt and install ffmpeg
curl -fsSL https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/jellyfin.gpg > /dev/null
echo "deb [arch=$( dpkg --print-architecture )] https://repo.jellyfin.org/$( awk -F'=' '/^ID=/{ print $NF }' /etc/os-release ) $( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release ) main" | sudo tee /etc/apt/sources.list.d/jellyfin.list
sudo apt update && sudo apt install -y jellyfin-ffmpeg5

# Create the service unit file
JELLYFINDIR="/opt/jellyfin"
FFMPEGDIR="/usr/share/jellyfin-ffmpeg"
SERVICE_NAME="jellyfin"
WORK_DIR=/config
DIRECTORY=${WORK_DIR}/jellyfin-configs

SERVICE_UNIT="#!/bin/bash
### BEGIN INIT INFO
# Provides:          jellyfin
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Jellyfin media server
# Description:       Jellyfin is a Free Software Media System
### END INIT INFO

start() {
    echo \"Starting Jellyfin...\"
    nohup $JELLYFINDIR/jellyfin -d $DIRECTORY/data -C $DIRECTORY/cache -c $DIRECTORY/config -l $DIRECTORY/log --ffmpeg $FFMPEGDIR/ffmpeg > /dev/null 2>&1 &
}

stop() {
    echo \"Stopping Jellyfin...\"
    killall jellyfin
}

status() {
    # if ps aux | grep -q \"$JELLYFINDIR/jellyfin\"; then
    if pidof \"$JELLYFINDIR/jellyfin\" > /dev/null; then
        echo \"Jellyfin is running\"
    else
        echo \"Jellyfin is not running.\"
    fi
}

case \"\$1\" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        stop
        sleep 2
        start
        ;;
    *)
        echo \"Usage: \$0 {start|stop|restart|status}\"
        exit 1
        ;;
esac

exit 0
"

# Save the service unit file to the systemd directory
echo "$SERVICE_UNIT" | sudo tee "/etc/init.d/$SERVICE_NAME" > /dev/null

# Reload init.d and start the service
sudo chmod +x /etc/init.d/"$SERVICE_NAME"
sudo update-rc.d "$SERVICE_NAME" defaults
sudo service "$SERVICE_NAME" start

echo "$SERVICE_NAME service has been set up and started."

# File browser
wget -O filebrowser.tar.gz https://github.com/filebrowser/filebrowser/releases/download/v2.30.0/linux-arm64-filebrowser.tar.gz
sudo mkdir -p /opt/filebrowser
sudo rm -rf /opt/filebrowser/*
sudo tar xvzf filebrowser.tar.gz -C /opt/filebrowser
rm filebrowser.tar.gz

# Create the service unit file
FILEBROWSERDIR="/opt/filebrowser"
SERVICE_NAME="filebrowser"

SERVICE_UNIT="#!/bin/bash
### BEGIN INIT INFO
# Provides:          filebrowser
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Filebrowser server
# Description:       Filebrowser is a Free Software file manager System
### END INIT INFO

start() {
    echo \"Starting filebrowser...\"
    nohup $FILEBROWSERDIR/filebrowser --root /config > /dev/null 2>&1 &
}

stop() {
    echo \"Stopping filebrowser...\"
    killall filebrowser
}

status() {
    # if ps aux | grep -q \"$FILEBROWSERDIR/filebrowser\"; then
    if pidof \"$FILEBROWSERDIR/filebrowser\" > /dev/null; then
        echo \"filebrowser is running\"
    else
        echo \"filebrowser is not running.\"
    fi
}

case \"\$1\" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        stop
        sleep 2
        start
        ;;
    *)
        echo \"Usage: \$0 {start|stop|restart|status}\"
        exit 1
        ;;
esac

exit 0
"

# Save the service unit file to the systemd directory
echo "$SERVICE_UNIT" | sudo tee "/etc/init.d/$SERVICE_NAME" > /dev/null

# Reload init.d and start the service
sudo chmod +x /etc/init.d/"$SERVICE_NAME"
sudo update-rc.d "$SERVICE_NAME" defaults
sudo service "$SERVICE_NAME" start

echo "$SERVICE_NAME service has been set up and started."
