#!/bin/bash

echo "👻 REMOVER ENTRADA FANTASMA - CLIPBOARDMANAGER"
echo "=============================================="

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}👻 Entrada fantasma detectada: ClipboardManager aparece mas não existe${NC}"
echo -e "${YELLOW}   Vamos tentar 3 métodos progressivos...${NC}"
echo ""

# MÉTODO 1: Tentar clicar direto
echo -e "${YELLOW}🔄 MÉTODO 1: Tentativa manual guiada${NC}"
echo ""
echo "📱 TENTE FAZER ISTO PRIMEIRO:"
echo "1. Feche as Configurações do Sistema (se estiver aberto)"
echo "2. Aguarde 5 segundos"
echo "3. Reabra: Configurações → Privacidade e Segurança → Acessibilidade"
echo "4. Clique no CADEADO 🔒 (canto inferior esquerdo)"
echo "5. Digite sua senha"
echo "6. Agora clique no (-) ao lado do ClipboardManager"
echo ""

read -p "✅ Conseguiu remover? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo -e "${GREEN}🎉 Ótimo! Problema resolvido!${NC}"
    echo "Agora pode instalar a nova versão:"
    echo "  ./fix_and_install.sh"
    exit 0
fi

echo ""
echo -e "${YELLOW}🔄 MÉTODO 2: Reset específico + reinício de serviços${NC}"
echo ""

# Fechar configurações
sudo killall "System Preferences" 2>/dev/null
sudo killall "System Settings" 2>/dev/null

# Reset específico
echo "🔄 Tentando reset específico..."
sudo tccutil reset Accessibility 2>/dev/null
sudo killall tccd 2>/dev/null
sleep 3

echo "✅ Aguarde 10 segundos e teste novamente..."
sleep 10

echo ""
echo "📱 TESTE NOVAMENTE:"
echo "1. Abra: Configurações → Privacidade e Segurança → Acessibilidade"
echo "2. Verifique se o ClipboardManager sumiu"
echo ""

read -p "✅ Sumiu agora? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo -e "${GREEN}🎉 Perfeito! Problema resolvido!${NC}"
    echo "Agora pode instalar a nova versão:"
    echo "  ./fix_and_install.sh"
    exit 0
fi

echo ""
echo -e "${YELLOW}🔄 MÉTODO 3: Reset mais agressivo${NC}"
echo ""

echo "🔄 Aplicando reset mais profundo..."

# Reset mais agressivo
sudo tccutil reset All 2>/dev/null
sudo rm -rf ~/Library/Caches/com.apple.TCC* 2>/dev/null

# Restart services
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.tccd.plist 2>/dev/null
sleep 2
sudo launchctl load /System/Library/LaunchDaemons/com.apple.tccd.plist 2>/dev/null
sleep 3

echo "✅ Reset aplicado. Aguarde 15 segundos..."
sleep 15

echo ""
echo "📱 TESTE PELA ÚLTIMA VEZ:"
echo "1. Abra: Configurações → Privacidade e Segurança → Acessibilidade"
echo "2. Verifique se o ClipboardManager sumiu"
echo ""

read -p "✅ Resolvido agora? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo -e "${GREEN}🎉 Excelente! Problema resolvido!${NC}"
    echo "Agora pode instalar a nova versão:"
    echo "  ./fix_and_install.sh"
    exit 0
fi

echo ""
echo -e "${RED}😤 ENTRADA FANTASMA PERSISTENTE DETECTADA!${NC}"
echo ""
echo -e "${YELLOW}📋 Esta entrada está 'grudada' no sistema.${NC}"
echo -e "${BLUE}   Você tem 2 opções:${NC}"
echo ""
echo -e "${GREEN}OPÇÃO 1 (Recomendada):${NC} Simplesmente ignore a entrada fantasma"
echo "• Instale a nova versão mesmo assim"
echo "• A nova versão tem Bundle ID diferente"
echo "• Vai funcionar normalmente"
echo "• Comando: ./fix_and_install.sh"
echo ""
echo -e "${RED}OPÇÃO 2 (Extrema):${NC} Reset nuclear (afeta TODOS os apps)"
echo "• Remove TODAS as permissões de acessibilidade"
echo "• Todos os apps precisarão permissão novamente"
echo "• Comando: ./nuclear_remove_accessibility.sh"
echo ""

read -p "🤔 Qual opção escolhe? (1 para ignorar, 2 para nuclear): " -n 1 -r
echo

if [[ $REPLY == "1" ]]; then
    echo ""
    echo -e "${GREEN}✅ Decisão sábia! Ignorando entrada fantasma...${NC}"
    echo ""
    echo "🚀 Instalando nova versão (ela vai funcionar normalmente):"
    echo ""
    read -p "🎯 Prosseguir com instalação? (s/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        ./fix_and_install.sh
    else
        echo "Para instalar depois: ./fix_and_install.sh"
    fi
    
elif [[ $REPLY == "2" ]]; then
    echo ""
    echo -e "${RED}⚠️  Você escolheu o método nuclear!${NC}"
    echo "Execute: ./nuclear_remove_accessibility.sh"
    
else
    echo ""
    echo "Para instalar ignorando a entrada fantasma: ./fix_and_install.sh"
    echo "Para reset nuclear: ./nuclear_remove_accessibility.sh"
fi 