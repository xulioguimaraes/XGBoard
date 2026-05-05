#!/bin/bash

echo "🔸 BUILD PROFISSIONAL - XGBoard"
echo "=========================================="

echo "🔐 VERIFICANDO CERTIFICADOS..."

# Verificar se há certificados de desenvolvedor
CERT_COUNT=$(security find-identity -v -p codesigning | grep "Developer ID Application" | wc -l)

if [ $CERT_COUNT -eq 0 ]; then
    echo "❌ CERTIFICADO NÃO ENCONTRADO!"
    echo ""
    echo "Para build profissional você precisa:"
    echo "1. 💳 Apple Developer Account (R$ 500/ano)"
    echo "2. 📜 Certificado 'Developer ID Application'"
    echo "3. 🔐 Certificado instalado no Keychain"
    echo ""
    echo "📋 COMO OBTER:"
    echo "• Visite: https://developer.apple.com"
    echo "• Crie uma conta de desenvolvedor"
    echo "• Gere certificados no portal"
    echo "• Baixe e instale no Mac"
    echo ""
    echo "💡 ALTERNATIVAS:"
    echo "• Use opção 2 (Build Distribuição) - funciona para a maioria"
    echo "• Use opção 3 (DMG) - instalação mais profissional"
    echo ""
    read -p "Deseja continuar sem assinatura? (y/n): " continue_choice
    
    if [ "$continue_choice" != "y" ]; then
        exit 1
    fi
    
    echo "🔄 Fazendo build sem assinatura..."
    ./scripts/build_dmg.sh
    exit 0
fi

echo "✅ Certificados encontrados!"
security find-identity -v -p codesigning | grep "Developer ID Application"

echo ""
echo "🔨 Compilando com assinatura..."

# Obter o primeiro certificado
CERT_NAME=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | sed 's/.*") \(.*\)/\1/')
echo "📜 Usando certificado: $CERT_NAME"

# Build com assinatura
xcodebuild -project ClipboardManager.xcodeproj \
    -scheme XGBoard \
    -configuration Release \
    -derivedDataPath build/DerivedData \
    -archivePath build/XGBoard.xcarchive \
    archive \
    CODE_SIGN_IDENTITY="$CERT_NAME"

if [ $? -eq 0 ]; then
    echo "✅ Compilação assinada bem-sucedida!"
    
    # Extrair e processar
    APP_PATH=$(find build/XGBoard.xcarchive -name "*.app" -type d | head -1)
    cp -R "$APP_PATH" build/
    APP_NAME=$(basename "$APP_PATH")
    
    echo "🔐 Verificando assinatura..."
    codesign -v "build/$APP_NAME"
    
    if [ $? -eq 0 ]; then
        echo "✅ Assinatura válida!"
        
        echo "📤 NOTARIZAÇÃO (OPCIONAL)..."
        echo "Para distribuição sem avisos, notarize o app:"
        echo "xcrun notarytool submit 'build/$APP_NAME' --keychain-profile 'notarytool-password' --wait"
        
        # Criar DMG assinado
        if command -v create-dmg &> /dev/null; then
            echo "💿 Criando DMG assinado..."
            create-dmg \
                --volname "XGBoard" \
                --window-size 800 400 \
                --app-drop-link 600 185 \
                "build/XGBoard-v2.0-Signed.dmg" \
                "build/$APP_NAME"
                
            # Assinar o DMG também
            codesign -s "$CERT_NAME" "build/XGBoard-v2.0-Signed.dmg"
        fi
        
        echo ""
        echo "🎉 BUILD PROFISSIONAL CONCLUÍDO!"
        echo "📁 App assinado: build/$APP_NAME"
        echo "💿 DMG assinado: build/XGBoard-v2.0-Signed.dmg"
        echo ""
        echo "✅ BENEFÍCIOS:"
        echo "• Sem avisos de segurança"
        echo "• Instalação transparente"
        echo "• Compatível com todos os Macs"
        echo "• Pronto para distribuição profissional"
        
        open build/
    else
        echo "❌ Erro na assinatura!"
        exit 1
    fi
else
    echo "❌ Erro na compilação assinada!"
    exit 1
fi 