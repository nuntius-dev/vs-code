#!/usr/bin/env bash
set -ex

# Install VS Code
ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/x64/g')
wget -q https://update.code.visualstudio.com/latest/linux-deb-${ARCH}/stable -O vs_code.deb
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y ./vs_code.deb

# Desktop icon
mkdir -p /usr/share/icons/hicolor/apps
wget -q -O /usr/share/icons/hicolor/apps/vscode.svg https://kasm-static-content.s3.amazonaws.com/icons/vscode.svg || { echo "Error: Icon download failed"; exit 1; }
sed -i '/Icon=/c\Icon=/usr/share/icons/hicolor/apps/vscode.svg' /usr/share/applications/code.desktop
sed -i 's#/usr/share/code/code#/usr/share/code/code --no-sandbox##' /usr/share/applications/code.desktop
cp /usr/share/applications/code.desktop $HOME/Desktop
chmod +x $HOME/Desktop/code.desktop
chown 1000:1000 $HOME/Desktop/code.desktop
rm vs_code.deb

# Conveniences for python development
apt-get update
apt-get install -y python3-setuptools python3-venv python3-virtualenv

# Cleanup for app layer
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
fi
