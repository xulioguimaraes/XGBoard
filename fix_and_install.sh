#!/bin/bash

echo "🔧 XGBOARD v1.1 - CORREÇÃO AUTOMÁTICA"
echo "====================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}📋 Este script vai:${NC}"
echo "• Parar versões em execução"
echo "• Remover versão antiga (se existir)"
echo "• Instalar a nova versão corrigida"
echo "• Configurar permissões"
echo ""

read -p "🚀 Continuar? (s/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "❌ Cancelado pelo usuário."
    exit 1
fi

echo ""
echo -e "${YELLOW}🔄 Passo 1: Parando processos em execução...${NC}"
pkill -f "clipboard\|xgboard" 2>/dev/null && echo "✅ Processos parados" || echo "ℹ️  Nenhum processo em execução"

echo ""
echo -e "${YELLOW}🔄 Passo 2: Removendo versão antiga...${NC}"
OLD_APP="/Applications/ClipboardManager.app"
if [ -d "$OLD_APP" ]; then
    echo "🗑️  Removendo: $OLD_APP"
    rm -rf "$OLD_APP"
    echo "✅ Versão antiga removida"
else
    echo "ℹ️  Nenhuma versão antiga encontrada"
fi

echo ""
echo -e "${YELLOW}🔄 Passo 3: Verificando build atualizado...${NC}"
if [ ! -d "build/XGBoard.app" ]; then
    echo "⚠️  App não encontrado. Fazendo build..."
    ./scripts/build_distribution.sh
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Erro no build!${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${YELLOW}🔄 Passo 4: Instalando nova versão...${NC}"
NEW_APP="/Applications/XGBoard.app"
if [ -d "$NEW_APP" ]; then
    echo "🔄 Atualizando app existente..."
    rm -rf "$NEW_APP"
fi

cp -R "build/XGBoard.app" "/Applications/"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ XGBoard v1.1 instalado com sucesso!${NC}"
else
    echo -e "${RED}❌ Erro na instalação!${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}🔄 Passo 5: Verificando integridade...${NC}"
if [ -d "$NEW_APP" ]; then
    BUNDLE_ID=$(defaults read "$NEW_APP/Contents/Info.plist" CFBundleIdentifier 2>/dev/null)
    VERSION=$(defaults read "$NEW_APP/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null)
    
    echo "📱 App: $NEW_APP"
    echo "🆔 Bundle ID: $BUNDLE_ID"
    echo "📊 Versão: $VERSION"
    
    if [[ "$BUNDLE_ID" == "com.xgboard.clipboardmanager.v2" ]]; then
        echo -e "${GREEN}✅ Bundle ID correto!${NC}"
    else
        echo -e "${RED}❌ Bundle ID incorreto!${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ App não foi instalado corretamente!${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🔧 CONFIGURAÇÃO MANUAL NECESSÁRIA:${NC}"
echo ""
echo "1. 📱 Abra: Configurações do Sistema"
echo "2. 🔐 Vá para: Privacidade e Segurança → Acessibilidade"
echo "3. 🗑️  Remova qualquer entrada antiga do ClipboardManager/XGBoard"
echo "4. ✅ Execute o app e permita acesso quando solicitado"
echo ""

echo -e "${YELLOW}🚀 Deseja abrir o app agora? (s/n):${NC}"
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo "🔄 Abrindo XGBoard..."
    open "$NEW_APP"
    
    echo ""
    echo -e "${GREEN}🎉 SUCESSO!${NC}"
    echo ""
    echo "📋 O que fazer agora:"
    echo "• Aguarde o app inicializar"
    echo "• Clique no ícone da barra de status"
    echo "• Configure as permissões se solicitado"
    echo "• Teste copiando algo (Cmd+C)"
    echo "• Use Cmd+F2 para abrir rapidamente"
    
else
    echo ""
    echo -e "${GREEN}✅ Instalação concluída!${NC}"
    echo ""
    echo "Para abrir manualmente:"
    echo "  open /Applications/XGBoard.app"
fi

echo ""
echo -e "${BLUE}📖 Para mais informações, leia: CORREÇÕES-v1.1.md${NC}"
echo ""
echo -e "${GREEN}🔧 Correções aplicadas na v1.1:${NC}"
echo "• ✅ Corrigido crash -[NSWindow _changeJustMain]"
echo "• ✅ Novo Bundle ID único (sem conflitos)"  
echo "• ✅ Gerenciamento de janelas simplificado"
echo "• ✅ Mensagens de erro melhoradas"
echo "" 