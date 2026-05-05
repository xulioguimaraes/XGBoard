#!/bin/bash

echo "🔸 BUILD DISTRIBUIÇÃO - XGBoard"
echo "========================================="

# Limpar builds anteriores
echo "🧹 Limpando builds anteriores..."
rm -rf build/
mkdir -p build

echo "🔨 Compilando para distribuição..."

# Build otimizado para distribuição
xcodebuild -project ClipboardManager.xcodeproj \
    -scheme XGBoard \
    -configuration Release \
    -derivedDataPath build/DerivedData \
    -archivePath build/XGBoard.xcarchive \
    archive \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

if [ $? -eq 0 ]; then
    echo "✅ Compilação bem-sucedida!"
    
    # Extrair o .app
    echo "📦 Extraindo aplicativo..."
    APP_PATH=$(find build/XGBoard.xcarchive -name "*.app" -type d | head -1)
    
    if [ -n "$APP_PATH" ]; then
        cp -R "$APP_PATH" build/
        APP_NAME=$(basename "$APP_PATH")
        
        echo "🗜️  Otimizando aplicativo..."
        
        # Remover arquivos desnecessários
        find "build/$APP_NAME" -name "*.dSYM" -exec rm -rf {} + 2>/dev/null
        find "build/$APP_NAME" -name "*.plist.bak" -delete 2>/dev/null
        
        # Comprimir em ZIP para distribuição
        echo "📦 Criando arquivo de distribuição..."
        cd build
        zip -r "XGBoard-v2.0-macOS.zip" "$APP_NAME"
        cd ..
        
        echo ""
        echo "🎉 SUCESSO!"
        echo "📁 Arquivo gerado: build/XGBoard-v2.0-macOS.zip"
        echo "📱 App individual: build/$APP_NAME"
        echo ""
        echo "💡 COMO DISTRIBUIR:"
        echo "• Envie o arquivo .zip para outros usuários"
        echo "• Eles devem extrair e arrastar para /Applications"
        echo "• Na primeira execução, podem precisar ir em:"
        echo "  Configurações > Privacidade e Segurança > Abrir mesmo assim"
        echo ""
        echo "⚠️  IMPORTANTE:"
        echo "• Este app não é assinado pela Apple"
        echo "• Usuários verão aviso de segurança na primeira vez"
        echo "• Para evitar avisos, use a opção 4 (Build Profissional)"
        
        # Mostrar tamanho do arquivo
        SIZE=$(du -h "build/XGBoard-v2.0-macOS.zip" | cut -f1)
        echo "📏 Tamanho do arquivo: $SIZE"
        
        # Abrir pasta no Finder
        open build/
    else
        echo "❌ Erro: Não foi possível encontrar o .app gerado"
        exit 1
    fi
else
    echo "❌ Erro na compilação!"
    exit 1
fi 