#!/bin/bash

echo "🗑️  REMOVER CLIPBOARD MANAGER - ACESSIBILIDADE"
echo "=============================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}📋 Este script vai remover todas as entradas relacionadas ao ClipboardManager${NC}"
echo -e "${BLUE}   das configurações de acessibilidade do macOS.${NC}"
echo ""

echo -e "${YELLOW}⚠️  IMPORTANTE:${NC}"
echo "• Isso vai remover TODAS as permissões de acessibilidade dos apps relacionados"
echo "• Você precisará conceder permissões novamente para a nova versão"
echo "• Recomendado: Feche todos os apps do clipboard antes de continuar"
echo ""

read -p "🚀 Continuar com a remoção? (s/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "❌ Cancelado pelo usuário."
    exit 1
fi

echo ""
echo -e "${YELLOW}🔄 Passo 1: Parando processos em execução...${NC}"
pkill -f "clipboard\|xgboard" 2>/dev/null && echo "✅ Processos parados" || echo "ℹ️  Nenhum processo em execução"

echo ""
echo -e "${YELLOW}🔄 Passo 2: Removendo permissões de acessibilidade...${NC}"

# Lista de possíveis bundle IDs para remover
BUNDLE_IDS=(
    "com.xgboard.app"
    "com.xgboard.clipboardmanager.v2"
    "ClipboardManager"
    "XGBoard"
)

for bundle_id in "${BUNDLE_IDS[@]}"; do
    echo "🗑️  Removendo: $bundle_id"
    tccutil reset Accessibility "$bundle_id" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $bundle_id removido${NC}"
    else
        echo -e "${YELLOW}⚠️  $bundle_id não encontrado ou já removido${NC}"
    fi
done

echo ""
echo -e "${YELLOW}🔄 Passo 3: Verificação manual necessária...${NC}"
echo ""
echo -e "${BLUE}👆 AGORA VOCÊ PRECISA FAZER MANUALMENTE:${NC}"
echo ""
echo "1. 📱 Abra: Configurações do Sistema"
echo "2. 🔐 Vá em: Privacidade e Segurança → Acessibilidade"
echo "3. 👀 Procure por entradas relacionadas a:"
echo "   • ClipboardManager"
echo "   • XGBoard"
echo "   • Qualquer app de clipboard antigo"
echo "4. 🗑️  Clique no (-) para remover cada entrada"
echo "5. 🔒 Clique em 'Feito' ou 'OK'"
echo ""

echo -e "${GREEN}🎯 RESULTADO ESPERADO:${NC}"
echo "• Lista de acessibilidade limpa"
echo "• Sem entradas antigas do clipboard manager"
echo "• Pronto para instalar a nova versão"
echo ""

echo -e "${BLUE}🚀 PRÓXIMO PASSO:${NC}"
echo "Instale a nova versão do XGBoard:"
echo "  ./fix_and_install.sh"
echo ""

echo -e "${GREEN}✅ Script concluído!${NC}"
echo -e "${YELLOW}⚠️  Lembre-se de fazer a verificação manual nas Configurações do Sistema${NC}" 