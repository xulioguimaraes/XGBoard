# Changelog

## v2.0

### Atalho global confiável (corrige bug original)
- Reescrito `HotKeyManager` com Carbon `RegisterEventHotKey` (mesma API que Alfred, Raycast, Maccy).
- Atalho padrão agora é **Cmd+Shift+V** (igual ao Win+V).
- Não exige mais permissão de Acessibilidade.
- Atalho configurável em **Configurações → Atalho Global** (record + restaurar padrão).

### Estabilidade
- `ClipboardMonitor` agora é singleton (`.shared`); fim das instâncias duplicadas e timers concorrentes.
- Removido `WindowGroup` competindo com janelas manuais — sem janela fantasma no launch.
- Sem mais toggling de `setActivationPolicy` (`.regular` ↔ `.accessory`); app permanece accessory.
- Fábrica única `makeWindow` para janela principal e Configurações.
- Removidos workarounds (`asyncAfter`, `makeKey()` redundante, `makeMain()` problemático).

### Persistência
- Histórico migrado de `UserDefaults` para `~/Library/Application Support/XGBoard/`.
- Imagens/PDFs vão para arquivos individuais (`items/<uuid>.bin`); índice em `index.json`.
- Limite de 200 MB com LRU (favoritos preservados); migração automática do `UserDefaults` antigo.
- Deduplicação por SHA-256 (texto e binário) — copiar o mesmo conteúdo duas vezes não duplica.
- Apenas uma representação por copy (uma imagem com 3 formatos não vira 3 entradas).
- `Timer` em `RunLoop.main` com `.common` modes — não pausa quando há menus abertos.

### Limpeza
- Removidos 6 scripts de fix/force/nuclear que viviam contornando bugs agora resolvidos.
- Substituídos por um único `clean_install.sh`.

## v1.1

- Tentativa de corrigir crash `-[NSWindow _changeJustMain]`.
- Bundle ID alterado para `com.xgboard.clipboardmanager.v2`.

## v1.0

- Lançamento inicial.
