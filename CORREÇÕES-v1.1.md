# 🔧 XGBoard v1.1 - Correções de Crash e Permissões

## 🐛 PROBLEMAS IDENTIFICADOS E CORRIGIDOS

### **Problema Principal: Crash ao Abrir**
- **Causa**: O app estava fazendo mudanças constantes na política de ativação (`NSApp.setActivationPolicy`) entre `.regular` e `.accessory`
- **Erro Específico**: `-[NSWindow _changeJustMain]` crash quando tentava fazer uma janela "main" em modo `.accessory`
- **Correção**: Simplificado o gerenciamento de janelas, removido chamadas problemáticas como `makeMain()`, reduzido mudanças de política

### **Problema Secundário: Bundle Identifier**
- **Causa**: Bundle ID `com.xgboard.app` conflitando com versões anteriores
- **Correção**: Alterado para `com.xgboard.clipboardmanager.v2` (único e exclusivo)
- **Benefício**: Evita conflitos de permissões com instalações anteriores

### **Problema de Permissões**
- **Causa**: Versões antigas nas configurações de acessibilidade
- **Correção**: Novo bundle ID + script de limpeza automática

---

## 🚀 COMO RESOLVER OS PROBLEMAS

### **Passo 1: Pare o App Atual**
```bash
# Mate todos os processos do clipboard manager
pkill -f "clipboard\|xgboard" 2>/dev/null || true
```

### **Passo 2: Execute o Script de Limpeza**
```bash
# Na pasta do projeto
./scripts/cleanup_permissions.sh
```

### **Passo 3: Instale a Nova Versão**
```bash
# Instalar o app corrigido
cp -R build/XGBoard.app /Applications/
```

### **Passo 4: Limpe as Permissões de Acessibilidade**
1. **Abra**: Configurações do Sistema
2. **Vá para**: Privacidade e Segurança → Acessibilidade  
3. **Remova**: Qualquer entrada antiga do "ClipboardManager" ou "XGBoard"
4. **Adicione**: A nova versão quando solicitado

### **Passo 5: Teste o App**
```bash
# Abrir a nova versão
open /Applications/XGBoard.app
```

---

## ✨ MELHORIAS NA v1.1

### **Estabilidade**
- ✅ Corrigido crash `-[NSWindow _changeJustMain]`
- ✅ Simplificado gerenciamento de janelas
- ✅ Reduzido mudanças de política de ativação
- ✅ Melhor tratamento de erros

### **Compatibilidade**
- ✅ Bundle ID único: `com.xgboard.clipboardmanager.v2`
- ✅ Sem conflitos com versões anteriores
- ✅ Permissões independentes

### **Usabilidade**
- ✅ Mensagens de erro mais claras
- ✅ Instruções específicas para permissões
- ✅ Script de limpeza automático

---

## 🔍 LOGS DE DEBUG

### **Antes (v1.0) - Problemático:**
```
🚀 Tentando abrir janela principal...
📋 Política alterada para .regular
🎯 Ativando janela: ...
window.makeMain()  ← CRASH AQUI
```

### **Depois (v1.1) - Corrigido:**
```
🚀 XGBoard iniciando...
✅ XGBoard iniciado com sucesso!
🚀 Abrindo janela principal...
🎯 Mostrando janela: XGBoard - Gerenciador de Área de Transferência
```

---

## 📱 TESTANDO A CORREÇÃO

### **Teste 1: Inicialização**
- App deve iniciar sem crash
- Ícone deve aparecer na barra de status
- Não deve haver erros no console

### **Teste 2: Abertura de Janela**
- Clicar no ícone da barra de status
- Usar atalho Cmd+F2
- Janela deve abrir normalmente

### **Teste 3: Funcionalidades**
- Copiar texto (Cmd+C)
- Verificar se aparece no histórico
- Testar favoritos e filtros

---

## 🔧 COMANDOS ÚTEIS

### **Verificar Processos:**
```bash
ps aux | grep -i "clipboard\|xgboard"
```

### **Ver Logs do Sistema:**
```bash
log show --predicate 'eventMessage contains "XGBoard"' --info --last 1h
```

### **Resetar Permissões (se necessário):**
```bash
tccutil reset Accessibility com.xgboard.clipboardmanager.v2
```

---

## 🎯 PONTOS IMPORTANTES

1. **Use apenas uma versão por vez** - Desinstale versões antigas
2. **Bundle ID mudou** - Sistema vai tratar como app novo
3. **Permissões são independentes** - Precisa configurar novamente
4. **Crash foi corrigido na base** - Não deve mais acontecer

---

## 📞 SUPORTE

Se ainda houver problemas:

1. **Execute primeiro**: `./scripts/cleanup_permissions.sh`
2. **Verifique**: Console.app para erros específicos  
3. **Teste**: Em usuário limpo do macOS (se possível)

**A correção elimina a causa raiz do crash identificado no relatório.** 