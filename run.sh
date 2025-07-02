#!/bin/bash

# XGBoard - Script de execução
# Este script verifica se o Xcode está instalado e abre o projeto

echo "🚀 XGBoard para macOS"
echo "================================"

# Verificar se o Xcode está instalado
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode não está instalado ou não está configurado corretamente"
    echo ""
    echo "Para instalar o Xcode:"
    echo "1. Abra a Mac App Store"
    echo "2. Pesquise por 'Xcode'"
    echo "3. Clique em 'Instalar'"
    echo ""
    echo "Ou instale através da linha de comando:"
    echo "xcode-select --install"
    exit 1
fi

echo "✅ Xcode encontrado"

# Verificar se o projeto existe
if [ ! -f "ClipboardManager.xcodeproj/project.pbxproj" ]; then
    echo "❌ Arquivo de projeto não encontrado"
    echo "Certifique-se de estar no diretório correto do projeto"
    exit 1
fi

echo "✅ Projeto encontrado"

# Abrir o projeto no Xcode
echo "📂 Abrindo projeto no Xcode..."
open ClipboardManager.xcodeproj

echo ""
echo "🎯 Próximos passos:"
echo "1. O Xcode deve abrir automaticamente"
echo "2. Selecione o target 'ClipboardManager'"
echo "3. Pressione Cmd+R para compilar e executar"
echo ""
echo "⚠️  Nota: O app pode solicitar permissões de acessibilidade na primeira execução"
echo "   Vá em: Configurações do Sistema > Privacidade e Segurança > Acessibilidade"
echo ""
echo "🔗 Atalho de teclado padrão: Cmd+Shift+V"
echo "📍 O app aparecerá na barra de status (não no Dock)" 