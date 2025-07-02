# 🚀 XGBoard - Gerenciador de Clipboard Inteligente

<div align="center">

![XGBoard](Resources/XGBoard-Icon.png)

**O clipboard manager mais elegante e rápido para macOS**

[![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## ✨ **RECURSOS PRINCIPAIS**

- 🎯 **Atalho Global**: `Cmd+F2` para acesso instantâneo
- 📋 **Histórico Inteligente**: Até 20 itens de clipboard
- 🔍 **Busca Rápida**: Encontre qualquer item digitando
- 🖼️ **Suporte Completo**: Texto, imagens e conteúdo formatado
- ⚡ **Performance Zero**: Não afeta a velocidade do sistema
- 🎨 **Interface Moderna**: Design nativo do macOS
- 🔐 **Privacidade**: Dados ficam apenas no seu Mac

---

## 🎬 **DEMONSTRAÇÃO**

```
Cmd+F2 → Interface aparece → Digite para buscar → Enter para colar
```

**Funciona em qualquer aplicativo**: Finder, Safari, Xcode, Slack, Discord, etc.

---

## 💾 **INSTALAÇÃO RÁPIDA**

### 🏆 **Método Recomendado: DMG**

1. **📥 Baixe**: `XGBoard-v1.1-Installer.dmg`
2. **📁 Abra** o arquivo DMG
3. **🎯 Arraste** XGBoard para Applications
4. **🚀 Execute** e conceda permissão de acessibilidade

### 📦 **Outros Métodos**

- **ZIP**: `XGBoard-v1.1-macOS.zip` → Extrair → Mover para Applications
- **Automático**: `./fix_and_install.sh` (para desenvolvedores)

### 🔐 **Configuração de Permissões**

⚠️ **OBRIGATÓRIO**: Para atalhos globais funcionarem:

1. Primeira execução → Clique "Abrir Configurações do Sistema"
2. `Privacidade e Segurança` → `Acessibilidade`
3. 🔓 Clique no cadeado → Digite senha
4. ✅ Marque `XGBoard`

**📖 [Guia Completo de Instalação](INSTALAÇÃO.md)**

---

## 🎯 **COMO USAR**

| Ação | Comando | Resultado |
|------|---------|-----------|
| **Abrir Clipboard** | `Cmd+F2` | Interface aparece |
| **Buscar Item** | `Digite texto` | Filtra resultados |
| **Navegar** | `↑↓` ou `Mouse` | Seleciona item |
| **Colar** | `Enter` ou `Duplo-click` | Cola no app atual |
| **Fechar** | `Esc` | Fecha interface |

### 💡 **Dicas Pro**

- 📌 **Ícone na barra**: Clique para abrir rapidamente
- 🔍 **Busca inteligente**: Busca em qualquer parte do texto
- 🖼️ **Preview de imagens**: Vê imagens antes de colar
- 📱 **Sempre disponível**: Funciona mesmo em fullscreen

---

## 🛠️ **PROBLEMAS COMUNS**

<details>
<summary>❌ "O app não pode ser aberto"</summary>

**Solução**: `Configurações` → `Privacidade e Segurança` → `Abrir mesmo assim`
</details>

<details>
<summary>🔄 Permissões solicitadas toda vez</summary>

**Solução**: Execute `./fix_permissions_persistence.sh`
</details>

<details>
<summary>👻 Entrada fantasma na acessibilidade</summary>

**Solução**: Execute `./fix_ghost_entry.sh`
</details>

**📖 [Resolução Completa de Problemas](INSTALAÇÃO.md#-resolução-de-problemas)**

---

## 📊 **ESPECIFICAÇÕES TÉCNICAS**

- **🎯 Compatibilidade**: macOS 13.0+ (Ventura, Sonoma, Sequoia)
- **📏 Tamanho**: 440KB (instalador DMG)
- **⚡ Performance**: < 0.1% CPU, ~10MB RAM
- **🔐 Permissões**: Apenas Acessibilidade (para atalhos)
- **🌐 Network**: Nenhuma conexão necessária
- **💾 Armazenamento**: Local apenas

---

## 🔧 **PARA DESENVOLVEDORES**

### **Build Local**

```bash
# Clone o repositório
git clone [REPO_URL]
cd ClipboardManager

# Build automático
./scripts/build_distribution.sh

# Instalação com correções
./fix_and_install.sh
```

### **Scripts Disponíveis**

- `build_dmg.sh` - Gera instalador DMG
- `fix_permissions_persistence.sh` - Corrige permissões
- `fix_ghost_entry.sh` - Remove entradas fantasma
- `nuclear_remove_accessibility.sh` - Reset total

### **Estrutura do Projeto**

```
ClipboardManager/
├── ClipboardManager/          # Código Swift
├── Resources/                 # Ícones e assets
├── scripts/                   # Scripts de build
├── build/                     # Arquivos gerados
└── INSTALAÇÃO.md             # Guia completo
```

---

## 🆕 **CHANGELOG**

### **v1.1 (Atual)**
- ✅ **Corrigido**: Problema de permissões persistentes
- ✅ **Melhorado**: Bundle ID único para evitar conflitos
- ✅ **Adicionado**: Scripts de diagnóstico e correção
- ✅ **Otimizado**: Interface de instalação DMG

### **v1.0**
- 🎉 **Lançamento inicial**
- 📋 Histórico de clipboard básico
- ⌨️ Atalho global Cmd+F2

---

## ✅ **VERIFICAÇÃO DE INSTALAÇÃO**

Antes de considerar instalado, confirme:

- [ ] ✅ XGBoard em `/Applications`
- [ ] ✅ Permissão de acessibilidade ativa
- [ ] ✅ `Cmd+F2` abre a interface
- [ ] ✅ Ícone na barra superior
- [ ] ✅ Histórico funcionando
- [ ] ✅ Busca operacional

**🎉 Todos marcados? Instalação PERFEITA!**

---

## 📞 **SUPORTE & CONTRIBUIÇÃO**

### **🐛 Bug ou Sugestão?**
- Consulte [INSTALAÇÃO.md](INSTALAÇÃO.md) primeiro
- Execute scripts de diagnóstico
- Abra uma issue detalhada

### **🤝 Contribuir**
- Fork o projeto
- Crie uma branch para sua feature
- Submeta um Pull Request

### **📧 Contato**
- **Desenvolvedor**: [Seu Nome]
- **Versão**: 1.1
- **Suporte**: Via GitHub Issues

---

## 📄 **LICENÇA**

Este projeto está licenciado sob a MIT License - veja [LICENSE](LICENSE) para detalhes.

---

<div align="center">

**⭐ Gostou? Deixe uma estrela!**

*XGBoard v1.1 - Seu clipboard nunca mais será o mesmo!* 🚀

</div>