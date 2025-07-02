#!/bin/bash

echo "☢️  REMOÇÃO NUCLEAR - ENTRADA FANTASMA"
echo "====================================="

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${RED}☢️  MÉTODO NUCLEAR PARA ENTRADAS FANTASMA${NC}"
echo -e "${BLUE}   Use quando a entrada aparece mas o app não existe mais${NC}"
echo ""

echo -e "${YELLOW}⚠️  IMPORTANTE:${NC}"
echo "• Este método VAI RESETAR TODAS as permissões de acessibilidade"
echo "• TODOS os apps vão precisar de permissão novamente"
echo "• É a única forma garantida de limpar entradas fantasma"
echo "• Você vai precisar reconfigurar outros apps de acessibilidade"
echo ""

echo -e "${RED}📋 APPS QUE PODEM SER AFETADOS:${NC}"
echo "• Screenshots automáticos"
echo "• Automação de tarefas"
echo "• Apps de produtividade"
echo "• Controle remoto"
echo "• Etc..."
echo ""

read -p "🚨 CONTINUAR COM RESET TOTAL? (digite 'NUCLEAR'): " -r
if [[ ! $REPLY == "NUCLEAR" ]]; then
    echo "❌ Cancelado. Digite 'NUCLEAR' para confirmar."
    exit 1
fi

echo ""
echo -e "${YELLOW}🔄 INICIANDO PROCEDIMENTO NUCLEAR...${NC}"

echo ""
echo -e "${YELLOW}🔄 PASSO 1: Fechando Configurações do Sistema...${NC}"
sudo killall "System Preferences" 2>/dev/null
sudo killall "System Settings" 2>/dev/null
sudo killall "Configurações do Sistema" 2>/dev/null
echo "✅ Configurações fechadas"

echo ""
echo -e "${YELLOW}🔄 PASSO 2: Parando serviços de segurança...${NC}"
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.tccd.plist 2>/dev/null
sudo killall tccd 2>/dev/null
echo "✅ Serviços parados"

echo ""
echo -e "${YELLOW}🔄 PASSO 3: RESET NUCLEAR do banco TCC...${NC}"
# Reset TOTAL de acessibilidade - remove TUDO
sudo tccutil reset All
sudo tccutil reset Accessibility
echo "✅ Reset nuclear aplicado"

echo ""
echo -e "${YELLOW}🔄 PASSO 4: Limpando TODOS os caches relacionados...${NC}"
# Limpeza profunda de caches
sudo rm -rf ~/Library/Caches/com.apple.TCC* 2>/dev/null
sudo rm -rf /Library/Caches/com.apple.TCC* 2>/dev/null
sudo rm -rf ~/Library/Preferences/com.apple.TCC* 2>/dev/null
sudo rm -rf /Library/Preferences/com.apple.TCC* 2>/dev/null

# Limpeza de Launch Services (pode conter referências fantasma)
sudo /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user 2>/dev/null

echo "✅ Caches eliminados"

echo ""
echo -e "${YELLOW}🔄 PASSO 5: Reiniciando serviços...${NC}"
sudo launchctl load /System/Library/LaunchDaemons/com.apple.tccd.plist 2>/dev/null
sleep 2
sudo launchctl start com.apple.tccd 2>/dev/null
echo "✅ Serviços reiniciados"

echo ""
echo -e "${GREEN}☢️  PROCEDIMENTO NUCLEAR CONCLUÍDO!${NC}"
echo ""
echo -e "${RED}🔄 AGORA É OBRIGATÓRIO:${NC}"
echo ""
echo "1. 🔄 REINICIE O MAC COMPLETAMENTE"
echo "2. ⏰ Aguarde 2-3 minutos após ligar"
echo "3. 📱 Abra: Configurações do Sistema"
echo "4. 🔐 Vá em: Privacidade e Segurança → Acessibilidade"
echo "5. 👀 A lista deve estar COMPLETAMENTE VAZIA"
echo ""
echo -e "${YELLOW}📋 APÓS VERIFICAR QUE ESTÁ LIMPO:${NC}"
echo "  ./fix_and_install.sh"
echo ""
echo -e "${BLUE}💡 OBSERVAÇÕES:${NC}"
echo "• Outros apps vão pedir permissão novamente (normal)"
echo "• Screenshots podem parar de funcionar temporariamente"
echo "• Apps de automação precisarão ser reconfigurados"
echo ""
echo -e "${GREEN}✅ Se a entrada ainda aparecer após reiniciar, é bug do macOS${NC}"
echo -e "${GREEN}   Nesse caso, simplesmente ignore e instale a nova versão${NC}" 