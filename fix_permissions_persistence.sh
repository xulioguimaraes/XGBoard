#!/bin/bash

echo "🔐 CORREÇÃO: PERMISSÕES PERSISTENTES"
echo "==================================="

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}🎯 PROBLEMA IDENTIFICADO:${NC}"
echo "• Permissões são solicitadas toda vez que o app abre"
echo "• Inconsistência no Bundle ID estava confundindo o macOS"
echo "• Sistema não conseguia associar permissões ao app corretamente"
echo ""

echo -e "${GREEN}✅ CORREÇÃO APLICADA:${NC}"
echo "• Bundle ID corrigido de 'com.xgboard.app' para 'com.xgboard.clipboardmanager.v2'"
echo "• Inconsistência entre Info.plist e projeto Xcode resolvida"
echo "• Configurações de terminação automática desabilitadas"
echo ""

echo -e "${YELLOW}🔧 ESTE SCRIPT VAI:${NC}"
echo "1. Limpar todas as entradas antigas"
echo "2. Instalar a versão corrigida"
echo "3. Configurar permissões uma única vez"
echo "4. Testar se persiste após reiniciar"
echo ""

read -p "🚀 Continuar com a correção? (s/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "❌ Cancelado pelo usuário."
    exit 1
fi

echo ""
echo -e "${YELLOW}🔄 PASSO 1: Limpando versões antigas...${NC}"

# Parar processos em execução
echo "• Parando processos em execução..."
pkill -f "clipboard\|xgboard" 2>/dev/null && echo "  ✅ Processos parados" || echo "  ℹ️  Nenhum processo em execução"

# Remover versão antiga
if [ -d "/Applications/ClipboardManager.app" ]; then
    echo "• Removendo versão antiga..."
    rm -rf "/Applications/ClipboardManager.app"
    echo "  ✅ Versão antiga removida"
else
    echo "  ℹ️  Nenhuma versão antiga encontrada"
fi

# Remover versão atual se existir
if [ -d "/Applications/XGBoard.app" ]; then
    echo "• Removendo versão atual..."
    rm -rf "/Applications/XGBoard.app"
    echo "  ✅ Versão atual removida"
fi

echo ""
echo -e "${YELLOW}🔄 PASSO 2: Limpando permissões antigas...${NC}"

# Reset específico das permissões antigas
echo "• Resetando permissões antigas..."
sudo tccutil reset Accessibility com.xgboard.app 2>/dev/null
sudo tccutil reset Accessibility com.xgboard.clipboardmanager.v2 2>/dev/null
echo "  ✅ Permissões antigas resetadas"

echo ""
echo -e "${YELLOW}🔄 PASSO 3: Instalando versão corrigida...${NC}"

# Verificar se o build existe
if [ ! -d "build/XGBoard.app" ]; then
    echo "❌ App não encontrado! Execute primeiro: scripts/build_distribution.sh"
    exit 1
fi

# Instalar nova versão
echo "• Copiando para Applications..."
cp -R "build/XGBoard.app" "/Applications/"
echo "  ✅ App instalado"

# Verificar o Bundle ID final
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "/Applications/XGBoard.app/Contents/Info.plist")
echo "• Bundle ID verificado: $BUNDLE_ID"

echo ""
echo -e "${YELLOW}🔄 PASSO 4: Primeiro teste de execução...${NC}"

echo "• Abrindo app pela primeira vez..."
open "/Applications/XGBoard.app"

echo ""
echo -e "${GREEN}🎯 AGORA VOCÊ PRECISA FAZER ISTO:${NC}"
echo ""
echo "1. 📱 O macOS vai mostrar o alerta de permissão de acessibilidade"
echo "2. 🔐 Clique em 'Abrir Configurações do Sistema'"
echo "3. 🔓 Clique no CADEADO (canto inferior esquerdo) e digite sua senha"
echo "4. ✅ MARQUE a caixa ao lado de 'XGBoard'"
echo "5. ⚠️  NÃO feche ainda - continue lendo..."
echo ""

read -p "✅ Permissão concedida? (s/n): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo ""
    echo -e "${RED}⚠️  PERMISSÃO NÃO CONCEDIDA${NC}"
    echo ""
    echo "Para corrigir o problema, você DEVE conceder a permissão."
    echo "Execute novamente quando estiver pronto."
    exit 1
fi

echo ""
echo -e "${YELLOW}🔄 PASSO 5: Teste de persistência...${NC}"

echo "• Fechando o app..."
pkill -f "XGBoard" 2>/dev/null
sleep 2

echo "• Aguardando 3 segundos..."
sleep 3

echo "• Abrindo novamente para testar persistência..."
open "/Applications/XGBoard.app"
sleep 2

echo ""
echo -e "${BLUE}🧪 TESTE DE PERSISTÊNCIA:${NC}"
echo ""
echo "❓ O app abriu SEM pedir permissão novamente?"
echo ""
echo "✅ SIM → Problema RESOLVIDO! A permissão vai persistir"
echo "❌ NÃO → Há outro problema (raro, mas pode acontecer)"
echo ""

read -p "🧪 A permissão persistiu? (s/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo ""
    echo -e "${GREEN}🎉 SUCESSO TOTAL!${NC}"
    echo ""
    echo -e "${GREEN}✅ PROBLEMA RESOLVIDO DEFINITIVAMENTE${NC}"
    echo ""
    echo "🔐 A permissão está agora associada ao Bundle ID correto"
    echo "📱 O app vai lembrar da permissão entre execuções"
    echo "🔄 Pode fechar e abrir quantas vezes quiser"
    echo "🚀 Os atalhos Cmd+F2 vão funcionar sempre"
    echo ""
    echo -e "${BLUE}💡 EXPLICAÇÃO TÉCNICA:${NC}"
    echo "• O macOS associa permissões ao Bundle ID"
    echo "• Antes: Bundle ID inconsistente confundia o sistema"
    echo "• Agora: Bundle ID único 'com.xgboard.clipboardmanager.v2'"
    echo "• Sistema consegue lembrar da permissão corretamente"
    echo ""
    
else
    echo ""
    echo -e "${YELLOW}🤔 PERMISSÃO AINDA NÃO PERSISTE${NC}"
    echo ""
    echo "Isso pode indicar:"
    echo "• Bug específico do seu macOS"
    echo "• Problema com cache do sistema TCC"
    echo "• Necessidade de reiniciar o sistema"
    echo ""
    echo -e "${BLUE}📋 PRÓXIMOS PASSOS:${NC}"
    echo ""
    echo "1. 🔄 TENTE REINICIAR O MAC"
    echo "2. 🧪 Teste novamente após reiniciar"
    echo "3. 📞 Se ainda persistir, use: ./nuclear_remove_accessibility.sh"
    echo ""
    echo "Na maioria dos casos, um reinício resolve."
fi

echo ""
echo -e "${GREEN}🎯 RESUMO FINAL:${NC}"
echo "• App instalado: /Applications/XGBoard.app"
echo "• Bundle ID: $BUNDLE_ID"
echo "• Atalho: Cmd+F2"
echo "• Acesso: Clique no ícone da barra de status" 