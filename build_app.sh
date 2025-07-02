#!/bin/bash

# Script para gerar executável do XGBoard
# Julio Carvalho - XGBoard v1.0

echo "🚀 XGBOARD - GERADOR DE EXECUTÁVEL"
echo "=============================================="
echo ""

# Verificar se o Xcode está instalado
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode não encontrado. Instale o Xcode antes de continuar."
    exit 1
fi

echo "📋 Escolha o tipo de build:"
echo ""
echo "1) 🔸 BUILD SIMPLES - Para teste local"
echo "2) 🔸 BUILD DISTRIBUIÇÃO - Para outros Macs"
echo "3) 🔸 BUILD + DMG - Instalador completo"
echo "4) 🔸 BUILD PROFISSIONAL - Com assinatura (requer Developer Account)"
echo ""
read -p "Digite sua escolha (1-4): " choice

case $choice in
    1)
        echo ""
        echo "🔨 Gerando build simples..."
        ./scripts/build_simple.sh
        ;;
    2)
        echo ""
        echo "🔨 Gerando build para distribuição..."
        ./scripts/build_distribution.sh
        ;;
    3)
        echo ""
        echo "🔨 Gerando build + DMG..."
        ./scripts/build_dmg.sh
        ;;
    4)
        echo ""
        echo "🔨 Gerando build profissional..."
        ./scripts/build_professional.sh
        ;;
    *)
        echo "❌ Opção inválida!"
        exit 1
        ;;
esac

echo ""
echo "✅ Processo concluído!" 