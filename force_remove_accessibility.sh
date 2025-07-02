#!/bin/bash

echo "🚨 FORÇAR REMOÇÃO - ACESSIBILIDADE TRAVADA"
echo "=========================================="

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${RED}⚠️  ESTE SCRIPT FORÇA A REMOÇÃO DE PERMISSÕES TRAVADAS${NC}"
echo -e "${BLUE}   Use quando não conseguir desativar pelas Configurações${NC}"
echo ""

echo -e "${YELLOW}📋 Este script vai:${NC}"
echo "• Parar todos os processos relacionados"
echo "• Forçar reset das permissões via terminal"
echo "• Remover apps das pastas Applications"
echo "• Limpar cache do sistema"
echo "• Reiniciar serviços de permissões"
echo ""

read -p "🚀 Continuar? (DIGITE 'SIM' em maiúsculas): " -r
if [[ ! $REPLY == "SIM" ]]; then
    echo "❌ Cancelado. Digite 'SIM' para confirmar."
    exit 1
fi

echo ""
echo -e "${YELLOW}🔄 PASSO 1: Parando TODOS os processos...${NC}"
sudo pkill -f "clipboard" 2>/dev/null
sudo pkill -f "xgboard" 2>/dev/null
sudo pkill -f "ClipboardManager" 2>/dev/null
echo "✅ Processos finalizados"

echo ""
echo -e "${YELLOW}🔄 PASSO 2: Removendo apps das Applications...${NC}"
sudo rm -rf "/Applications/ClipboardManager.app" 2>/dev/null && echo "✅ ClipboardManager.app removido" || echo "ℹ️  ClipboardManager.app não encontrado"
sudo rm -rf "/Applications/XGBoard.app" 2>/dev/null && echo "✅ XGBoard.app removido" || echo "ℹ️  XGBoard.app não encontrado"

echo ""
echo -e "${YELLOW}🔄 PASSO 3: Reset FORÇADO das permissões...${NC}"
# Reset geral de acessibilidade
sudo tccutil reset Accessibility
echo "✅ Reset geral aplicado"

# Reset específico por bundle ID
BUNDLE_IDS=("com.xgboard.app" "com.xgboard.clipboardmanager.v2" "ClipboardManager" "XGBoard")
for bundle_id in "${BUNDLE_IDS[@]}"; do
    sudo tccutil reset Accessibility "$bundle_id" 2>/dev/null
    echo "✅ Reset: $bundle_id"
done

echo ""
echo -e "${YELLOW}🔄 PASSO 4: Limpando cache do sistema...${NC}"
sudo rm -rf ~/Library/Caches/com.apple.TCC* 2>/dev/null
sudo rm -rf /Library/Caches/com.apple.TCC* 2>/dev/null
echo "✅ Cache limpo"

echo ""
echo -e "${YELLOW}🔄 PASSO 5: Reiniciando serviços de segurança...${NC}"
sudo killall -HUP tccd 2>/dev/null
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.tccd.plist 2>/dev/null
sudo launchctl load /System/Library/LaunchDaemons/com.apple.tccd.plist 2>/dev/null
echo "✅ Serviços reiniciados"

echo ""
echo -e "${GREEN}🎉 LIMPEZA FORÇADA CONCLUÍDA!${NC}"
echo ""
echo -e "${BLUE}📱 AGORA VERIFIQUE MANUALMENTE:${NC}"
echo ""
echo "1. 🔄 REINICIE O MAC (recomendado)"
echo "2. 📱 Abra: Configurações do Sistema"
echo "3. 🔐 Vá em: Privacidade e Segurança → Acessibilidade"
echo "4. 👀 Verifique se a lista está limpa"
echo ""
echo -e "${GREEN}✅ Se ainda aparecer alguma entrada, clique no (-) para remover${NC}"
echo ""
echo -e "${YELLOW}🚀 PRÓXIMO PASSO:${NC}"
echo "Após confirmar que a lista está limpa:"
echo "  ./fix_and_install.sh"
echo ""
echo -e "${RED}⚠️  Se ainda não funcionar, REINICIE o Mac antes de continuar${NC}" 