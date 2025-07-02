#!/bin/bash

echo "🔸 BUILD SIMPLES - XGBoard"
echo "====================================="

# Limpar builds anteriores
echo "🧹 Limpando builds anteriores..."
rm -rf build/
mkdir -p build

echo "🔨 Compilando aplicativo..."

# Build básico para teste local
xcodebuild -project ClipboardManager.xcodeproj \
    -scheme ClipboardManager \
    -configuration Release \
    -derivedDataPath build/DerivedData \
    -archivePath build/ClipboardManager.xcarchive \
    archive

if [ $? -eq 0 ]; then
    echo "✅ Compilação bem-sucedida!"
    
    # Extrair o .app do arquivo
    echo "📦 Extraindo aplicativo..."
    
    # Encontrar o .app dentro do archive
    APP_PATH=$(find build/ClipboardManager.xcarchive -name "*.app" -type d | head -1)
    
    if [ -n "$APP_PATH" ]; then
        # Copiar .app para pasta de build
        cp -R "$APP_PATH" build/
        
        APP_NAME=$(basename "$APP_PATH")
        echo ""
        echo "🎉 SUCESSO!"
        echo "📁 Aplicativo gerado: build/$APP_NAME"
        echo ""
        echo "💡 COMO USAR:"
        echo "• Vá para a pasta: build/"
        echo "• Duplo-clique em: $APP_NAME"
        echo "• Ou arraste para /Applications para instalar"
        echo ""
        echo "⚠️  NOTA: Este build funciona apenas no seu Mac"
        
        # Abrir pasta no Finder
        open build/
    else
        echo "❌ Erro: Não foi possível encontrar o .app gerado"
        exit 1
    fi
else
    echo "❌ Erro na compilação!"
    echo "💡 Verifique os erros acima e tente novamente"
    exit 1
fi 