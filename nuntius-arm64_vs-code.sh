#!/usr/bin/env bash
set -ex

# Verificar si la imagen es nuntiusdev/nuntius-arm64
if [[ "$(uname -m)" != "aarch64" ]]; then
  echo "Error: Este script solo debe ejecutarse en la imagen nuntiusdev/nuntius-arm64"
  exit 1
fi

# Instalar VS Code
ARCH="arm64"
wget -q https://update.code.visualstudio.com/latest/linux-deb-${ARCH}/stable -O vs_code.deb
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y ./vs_code.deb
rm vs_code.deb

# Configurar icono de escritorio
mkdir -p /usr/share/icons/hicolor/apps
wget -q -O /usr/share/icons/hicolor/apps/vscode.svg https://kasm-static-content.s3.amazonaws.com/icons/vscode.svg || { echo "Error: No se pudo descargar el icono"; exit 1; }

DESKTOP_FILE="/usr/share/applications/code.desktop"
if [[ -f "$DESKTOP_FILE" ]]; then
  sed -i '/Icon=/c\Icon=/usr/share/icons/hicolor/apps/vscode.svg' "$DESKTOP_FILE"
  sed -i 's|Exec=/usr/share/code/code %F|Exec=/usr/share/code/code --no-sandbox %F|' "$DESKTOP_FILE"
  cp "$DESKTOP_FILE" "$HOME/Desktop/"
  chmod +x "$HOME/Desktop/code.desktop"
  chown 1000:1000 "$HOME/Desktop/code.desktop"
else
  echo "Advertencia: No se encontró el archivo $DESKTOP_FILE"
fi

# Instalación de herramientas para desarrollo en Python
apt-get install -y python3-setuptools python3-venv python3-virtualenv

# Limpieza final
chown -R 1000:0 "$HOME"
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
if [[ -z "${SKIP_CLEAN+x}" ]]; then
  apt-get autoclean
  rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
fi
