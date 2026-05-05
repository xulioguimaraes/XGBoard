#!/bin/bash

echo "🔸 BUILD DMG - XGBoard"
echo "================================"

# Verificar se create-dmg está instalado
if ! command -v create-dmg &> /dev/null; then
    echo "📦 Instalando create-dmg..."
    if command -v brew &> /dev/null; then
        brew install create-dmg
    else
        echo "❌ Homebrew não encontrado. Instale com:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo "   brew install create-dmg"
        exit 1
    fi
fi

# Primeiro fazer o build de distribuição
echo "🔨 Compilando aplicativo..."
scripts/build_distribution.sh

if [ $? -ne 0 ]; then
    echo "❌ Erro na compilação!"
    exit 1
fi

echo ""
echo "💿 Criando instalador DMG..."

# Encontrar o .app
APP_PATH=$(find build -name "*.app" -type d | head -1)
APP_NAME=$(basename "$APP_PATH")

if [ -z "$APP_PATH" ]; then
    echo "❌ Erro: App não encontrado!"
    exit 1
fi

# Criar DMG simples (sem background customizado)
create-dmg \
    --volname "XGBoard Installer" \
    --window-pos 200 120 \
    --window-size 800 400 \
    --icon-size 100 \
    --icon "$APP_NAME" 200 190 \
    --hide-extension "$APP_NAME" \
    --app-drop-link 600 185 \
    "build/XGBoard-v2.0-Installer.dmg" \
    "build/$APP_NAME"

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 DMG CRIADO COM SUCESSO!"
    echo "📁 Arquivo: build/XGBoard-v2.0-Installer.dmg"
    echo ""
    echo "💡 COMO USAR O DMG:"
    echo "• Duplo-clique no arquivo .dmg"
    echo "• Arraste o XGBoard para Applications"
    echo "• Ejete o DMG"
    echo "• Execute o app da pasta Applications"
    echo ""
    echo "✅ VANTAGENS DO DMG:"
    echo "• Instalação profissional"
    echo "• Interface amigável"
    echo "• Fácil distribuição"
    
    # Mostrar tamanho
    SIZE=$(du -h "build/XGBoard-v2.0-Installer.dmg" | cut -f1)
    echo "📏 Tamanho: $SIZE"
    
    # Abrir pasta
    open build/
else
    echo "❌ Erro ao criar DMG!"
    echo "💡 Continuando com arquivo ZIP..."
fi 