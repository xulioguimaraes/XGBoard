#!/bin/bash

echo "🧹 LIMPEZA DE PERMISSÕES - XGBoard v1.1"
echo "========================================="

echo ""
echo "📋 Este script ajuda a limpar conflitos de permissões"
echo "   entre versões antigas e a nova versão do XGBoard."
echo ""

# Verificar se existe versão antiga instalada
OLD_APP_PATH="/Applications/ClipboardManager.app"
if [ -d "$OLD_APP_PATH" ]; then
    echo "❗ VERSÃO ANTIGA ENCONTRADA!"
    echo "   Caminho: $OLD_APP_PATH"
    echo ""
    
    read -p "🗑️  Deseja remover a versão antiga? (s/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo "🔄 Removendo versão antiga..."
        rm -rf "$OLD_APP_PATH"
        echo "✅ Versão antiga removida!"
    else
        echo "⚠️  Versão antiga mantida. Pode causar conflitos."
    fi
    echo ""
fi

# Verificar se existe nova versão instalada
NEW_APP_PATH="/Applications/XGBoard.app"
if [ -d "$NEW_APP_PATH" ]; then
    echo "✅ Nova versão encontrada: $NEW_APP_PATH"
else
    echo "❌ Nova versão não encontrada em Applications"
    echo "   Certifique-se de instalar primeiro o XGBoard.app"
fi

echo ""
echo "🔧 PRÓXIMOS PASSOS MANUAIS:"
echo ""
echo "1. 📱 Abra 'Configurações do Sistema'"
echo "2. 🔐 Vá em 'Privacidade e Segurança'"
echo "3. 🎛️  Clique em 'Acessibilidade'"
echo "4. 🗑️  Remova qualquer versão antiga do XGBoard/ClipboardManager"
echo "5. ✅ Adicione a nova versão (XGBoard) se solicitado"
echo ""
echo "💡 IMPORTANTE:"
echo "   • Use apenas uma versão por vez"
echo "   • Reinicie o XGBoard após mudanças nas permissões"
echo "   • O bundle ID mudou para: com.xgboard.clipboardmanager.v2"
echo ""

# Verificar processos em execução
RUNNING_PROCESSES=$(ps aux | grep -i "clipboard\|xgboard" | grep -v grep)
if [ ! -z "$RUNNING_PROCESSES" ]; then
    echo "⚠️  PROCESSOS EM EXECUÇÃO:"
    echo "$RUNNING_PROCESSES"
    echo ""
    echo "💡 Considere reiniciar estes processos após as mudanças."
fi

echo "🎉 LIMPEZA CONCLUÍDA!"
echo ""
echo "🚀 Para testar:"
echo "   • Abra o XGBoard"
echo "   • Teste o atalho Cmd+F2"
echo "   • Copie algo e verifique se aparece no histórico"
echo "" 