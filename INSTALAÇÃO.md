# 🚀 XGBoard - Guia de Instalação Completo

## 📋 **VISÃO GERAL**

XGBoard é um gerenciador de clipboard inteligente para macOS que permite:
- ✅ **Histórico de clipboard** com até 20 itens
- ✅ **Atalho global** `Cmd+F2` para acesso rápido
- ✅ **Interface moderna** e intuitiva
- ✅ **Busca instantânea** nos itens copiados
- ✅ **Suporte a texto e imagens**

---

## 💾 **OPÇÕES DE INSTALAÇÃO**

### 🏆 **OPÇÃO 1: INSTALADOR DMG (Recomendado)**

**✨ Experiência mais profissional e fácil**

#### **Passo a Passo:**

1. **📥 Baixe o instalador**
   ```
   XGBoard-v1.1-Installer.dmg
   ```

2. **📁 Abra o arquivo DMG**
   - Duplo-clique no arquivo `.dmg` baixado
   - Uma janela com o XGBoard será aberta

3. **🎯 Instale o aplicativo**
   - **Arraste** o ícone `XGBoard` para a pasta `Applications`
   - Aguarde a cópia ser concluída

4. **💿 Ejete o instalador**
   - Clique no ícone de ejetar ao lado do DMG no Finder
   - Ou arraste o DMG para a Lixeira

5. **🚀 Execute o XGBoard**
   - Abra a pasta `Applications`
   - Duplo-clique em `XGBoard`

---

### 📦 **OPÇÃO 2: ARQUIVO ZIP**

**🔧 Para usuários que preferem extração manual**

#### **Passo a Passo:**

1. **📥 Baixe o arquivo ZIP**
   ```
   XGBoard-v1.1-macOS.zip
   ```

2. **📂 Extraia o conteúdo**
   - Duplo-clique no arquivo `.zip`
   - Um arquivo `XGBoard.app` será extraído

3. **🎯 Mova para Applications**
   - Arraste `XGBoard.app` para `/Applications`
   - Ou use o Finder: `Ir` → `Aplicações`

4. **🚀 Execute o aplicativo**
   - Abra a pasta `Applications`
   - Duplo-clique em `XGBoard`

---

### ⚡ **OPÇÃO 3: INSTALAÇÃO AUTOMÁTICA**

**🤖 Script que faz tudo automaticamente**

#### **Para Desenvolvedores/Power Users:**

```bash
# Clone o repositório
git clone [REPOSITÓRIO]
cd ClipboardManager

# Execução automática (recomendada)
./fix_and_install.sh
```

**Este script:**
- 🧹 Remove versões antigas automaticamente
- 🔨 Compila a versão mais recente
- 📦 Instala em `/Applications`
- 🔐 Configura permissões necessárias

---

## 🔐 **CONFIGURAÇÃO DE PERMISSÕES**

### **⚠️ IMPORTANTE: Permissão de Acessibilidade Necessária**

Para que os atalhos globais (`Cmd+F2`) funcionem, é **obrigatório** conceder permissão de acessibilidade:

#### **Primeira Execução:**

1. **🚀 Abra o XGBoard**
   - Uma mensagem aparecerá solicitando permissão

2. **⚙️ Abra Configurações do Sistema**
   - Clique em `"Abrir Configurações do Sistema"`
   - Ou vá manualmente: `🍎 Menu Apple` → `Configurações do Sistema`

3. **🔐 Navegue para Acessibilidade**
   - `Privacidade e Segurança` → `Acessibilidade`

4. **🔓 Desbloqueie as configurações**
   - Clique no **cadeado** (canto inferior esquerdo)
   - Digite sua **senha de administrador**

5. **✅ Ative o XGBoard**
   - Marque a **caixa de seleção** ao lado de `XGBoard`
   - A permissão será concedida

6. **🎉 Pronto!**
   - Feche as Configurações
   - O atalho `Cmd+F2` agora funciona globalmente

---

## 🛠️ **RESOLUÇÃO DE PROBLEMAS**

### **❌ Problema: "O app não pode ser aberto"**

**Causa:** macOS bloqueia apps não assinados pela Apple

**✅ Solução:**
1. `🍎 Menu Apple` → `Configurações do Sistema`
2. `Privacidade e Segurança`
3. Role para baixo até encontrar a mensagem sobre XGBoard
4. Clique em `"Abrir mesmo assim"`
5. Confirme clicando em `"Abrir"`

### **🔄 Problema: Permissões solicitadas toda vez**

**Causa:** Conflito com versões anteriores

**✅ Solução Automática:**
```bash
./fix_permissions_persistence.sh
```

**✅ Solução Manual:**
1. Remova `/Applications/ClipboardManager.app` (versão antiga)
2. Remova `/Applications/XGBoard.app` (versão atual)
3. Reset permissões: `sudo tccutil reset Accessibility`
4. Reinstale usando o DMG
5. Conceda permissão apenas uma vez

### **👻 Problema: Entrada "fantasma" na acessibilidade**

**Causa:** Versão antiga permanece nas configurações

**✅ Solução:**
```bash
./fix_ghost_entry.sh
```

### **🆘 Problema: Nada funciona**

**Solução Extrema (último recurso):**
```bash
./nuclear_remove_accessibility.sh
```
⚠️ **Cuidado:** Remove TODAS as permissões de acessibilidade

---

## 🎯 **USANDO O XGBOARD**

### **🔥 Atalhos Principais:**

| Ação | Atalho | Descrição |
|------|--------|-----------|
| **Abrir Clipboard** | `Cmd+F2` | Abre o histórico de clipboard |
| **Buscar** | `Digite` | Busca instantânea nos itens |
| **Selecionar** | `↑↓` ou `Click` | Navega pelos itens |
| **Colar** | `Enter` ou `Duplo-click` | Cola o item selecionado |
| **Fechar** | `Esc` | Fecha a janela |

### **💡 Dicas de Uso:**

- 📌 **Ícone na barra superior**: Clique para abrir rapidamente
- 🔍 **Busca inteligente**: Digite qualquer palavra para filtrar
- 🖼️ **Suporte a imagens**: Imagens copiadas aparecem com preview
- 📝 **Histórico persistente**: Itens são salvos entre execuções
- ⚡ **Performance**: Zero impacto na velocidade do sistema

---

## 🔧 **DESINSTALAÇÃO**

Para remover completamente o XGBoard:

```bash
# 1. Parar o aplicativo
pkill -f "XGBoard"

# 2. Remover o app
rm -rf /Applications/XGBoard.app

# 3. Limpar permissões (opcional)
sudo tccutil reset Accessibility com.xgboard.clipboardmanager.v2

# 4. Remover dados do usuário (opcional)
rm -rf ~/Library/Preferences/com.xgboard.clipboardmanager.v2.plist
```

---

## 📞 **SUPORTE**

### **🐛 Encontrou um bug?**
- Verifique se seguiu todos os passos de instalação
- Tente a "Solução Automática" de permissões
- Execute `./fix_permissions_persistence.sh`

### **💡 Precisa de ajuda?**
- Consulte a seção "Resolução de Problemas"
- Execute os scripts de diagnóstico disponíveis
- Verifique se sua versão do macOS é compatível (13.0+)

---

## ✅ **LISTA DE VERIFICAÇÃO**

Antes de considerar a instalação completa, confirme:

- [ ] ✅ XGBoard está em `/Applications`
- [ ] ✅ Permissão de acessibilidade concedida
- [ ] ✅ Atalho `Cmd+F2` funciona
- [ ] ✅ Ícone aparece na barra superior
- [ ] ✅ Histórico de clipboard funciona
- [ ] ✅ Busca por itens funciona

**🎉 Se todos os itens estão marcados, sua instalação está PERFEITA!**

---

## 🆕 **ATUALIZAÇÕES**

Para atualizar para uma nova versão:

1. **📥 Baixe a nova versão**
2. **🗑️ Remova a versão antiga** (opcional, mas recomendado)
3. **📦 Instale normalmente** usando qualquer método acima
4. **✅ Não precisa reconfigurar permissões** (Bundle ID é o mesmo)

---

*XGBoard v1.1 - Seu clipboard nunca mais será o mesmo! 🚀* 