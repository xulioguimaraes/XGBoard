#!/bin/bash
# XGBoard - Instalação limpa
# Encerra a versão em execução, reseta permissões antigas (TCC) e instala a build mais recente.

set -e

BUNDLE_ID="com.xgboard.clipboardmanager.v2"
APP_NAME="XGBoard.app"
BUILD_DIR="build"
INSTALL_DIR="/Applications"

echo "🧹 XGBoard — Instalação Limpa"
echo "================================"

echo "→ Encerrando processos do XGBoard…"
pkill -f "XGBoard" 2>/dev/null || true
sleep 1

echo "→ Resetando permissões TCC associadas ao bundle…"
tccutil reset Accessibility "$BUNDLE_ID" 2>/dev/null || true
tccutil reset AppleEvents "$BUNDLE_ID" 2>/dev/null || true

echo "→ Removendo versão anterior em $INSTALL_DIR (se existir)…"
if [ -d "$INSTALL_DIR/$APP_NAME" ]; then
    rm -rf "$INSTALL_DIR/$APP_NAME"
fi

echo "→ Procurando build mais recente…"
APP_PATH=""
if [ -d "$BUILD_DIR/$APP_NAME" ]; then
    APP_PATH="$BUILD_DIR/$APP_NAME"
else
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -type d -name "$APP_NAME" -path "*Build/Products/Debug*" -print 2>/dev/null | head -n 1)
fi

if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo "❌ Build não encontrada. Compile com Xcode (Cmd+B) ou rode ./build_app.sh primeiro."
    exit 1
fi

echo "→ Instalando $APP_PATH em $INSTALL_DIR…"
cp -R "$APP_PATH" "$INSTALL_DIR/"

echo "→ Abrindo XGBoard…"
open "$INSTALL_DIR/$APP_NAME"

echo "✅ Pronto. O atalho global é Cmd+Shift+V (configurável em Configurações)."
