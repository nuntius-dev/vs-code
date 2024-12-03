#!/usr/bin/env bash
set -e

# Install vsCode
ARCH=$(arch | sed -e 's/aarch64/arm64/' -e 's/x86_64/x64/')
wget -qO vs_code.deb https://update.code.visualstudio.com/latest/linux-deb-${ARCH}/stable
apt-get update && apt-get install -y ./vs_code.deb && rm vs_code.deb

# Configure desktop icon
ICON_PATH="/usr/share/icons/hicolor/apps/vscode.svg"
DESKTOP_FILE="/usr/share/applications/code.desktop"
wget -qO $ICON_PATH https://raw.githubusercontent.com/nuntius-dev/vs-code/refs/heads/main/vscode.svg
sed -i -e "s#Icon=.*#Icon=$ICON_PATH#" \
       -e "s#/usr/share/code/code#/usr/share/code/code --no-sandbox#" $DESKTOP_FILE
cp $DESKTOP_FILE $HOME/Desktop && chmod +x $HOME/Desktop/code.desktop
chown 1000:1000 $HOME/Desktop/code.desktop

# Install Python development tools
apt-get install -y python3-setuptools python3-venv python3-virtualenv

# Cleanup
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
[ -z "${SKIP_CLEAN+x}" ] && apt-get autoclean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
